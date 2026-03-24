classdef W_Tools_Table < handle
    methods(Static)
        function tab = table(varargin)
            str = W.struct(varargin{:});
            tab = struct2table(str);
        end
        function tab = table_namesfirst(arr, varargin)
            varnames = varargin;
            assert(size(arr,2) == length(varnames));
            tab = table(arr);
            tab = splitvars(tab,'arr','NewVariableNames',varnames);
        end
        %% fieldnames
        function fnms = fieldnames(d)
            if isempty(d)
                fnms = [];
                return;
            end
            fnms = fieldnames(d);
            fnms = setdiff(fnms, {'Row','Properties','Variables'}, 'stable');
            fnms = W.string(fnms);
        end
        function bool = tab_isfield(tab, varargin)
            fnms = W.string(W.decell(varargin));
            bool = W.strs_have_matches(fnms, W.fieldnames(tab));
        end
        %% rename
        function tab = tab_prefix(tab, prefix, fn)
            if ~exist('fn', 'var') || isempty(fn)
                fn = tab.Properties.VariableNames;
            end
            fnew = strcat(prefix, '_', fn);
            tab = renamevars(tab, fn, fnew);
        end
        function tab = tab_suffix(tab, suffix, fn)
            if ~exist('fn', 'var') || isempty(fn)
                fn = tab.Properties.VariableNames;
            end
            fnew = strcat(fn, '_', suffix);
            tab = renamevars(tab, fn, fnew);
        end
        %% get fieldsize for tables or structures
        function [out, fnms] = fieldsize(d, fnms, idx)
            % d - table/structure
            % fnms - field names
            % idx - fieldsize dimension
            fnms0 = W.fieldnames(d);
            if ~exist('fnms', 'var') || isempty(fnms)
                fnms = fnms0;
            end
            tfnms = intersect(fnms, fnms0, 'stable'); % stable means in the order of fnms (1st list)
            out0 = W.arrayfun(@(x)size(d.(x)), tfnms, 0); % get size of each field
            mz = max(cellfun(@(x)length(x), out0)); % get maximal size dimension
            tt = W.cellfun_vertcat(@(x)W.extend(x, mz), out0);
            if ~exist('idx', 'var') || isempty(idx)
                idx = 1:size(tt,2); % default value
            end
            tt = tt(:, idx); 
            out = NaN(length(fnms), size(tt,2)); 
            idx = arrayfun(@(x)find(strcmp(x, fnms)), tfnms);
            out(idx,:) = tt;
        end
        %% read/write
        function out = readtable(filename, varargin)
            if length(varargin) >= 1 && strcmp(varargin{1}, 'TextscanFormats')
                fmt = datastore(filename);
                fmt.TextscanFormats = W.decell({varargin{2:end}});
                out = read(fmt);
            else
                out = readtable(filename, varargin{:});
            end
            out = W.tab_autofieldcombine(out, 1);
        end     
        function writetable(tab, filename, is_squeeze, varargin)
            arguments
                tab table;
                filename string;
                is_squeeze logical = false;
            end
            arguments(Repeating)
                varargin;
            end
            if is_squeeze
                tab = W.tab_autofieldcombine(tab);
                W.error('tab squeezing not yet implemented, need to add');
%                 tab = W.tab_squeeze(tab);
            end
            tab = W.tab_denested(tab); % a column of the table is table
            filename = W.deext(filename);
            filename = W.enext(filename, 'csv');
            W.mkdir(fileparts(filename));
            writetable(tab, filename, varargin{:});
        end      
        %% concatenate tables
        function out = tab_vertcat(varargin)
            varargin = W.encell(W.decell(varargin));
            var = varargin(cellfun(@(x)~isempty(x), varargin));
            if isempty(var)
                out = table;
                return;
            end
            try
                out = vertcat(var{:});
            catch
                varnames = W.cellfun(@(x)x.Properties.VariableNames, var, false);
                fn = unique([varnames{:}]);
                sz = cellfun(@(x)W.fieldsize(x, fn, 2), var, 'UniformOutput', false); 
                sz = horzcat(sz{:}); % #fn x #table
                sz_max = max(sz, [], 2); % #fn x 1
                for i = 1:length(fn) % field names
                    idnotnan = find(~isnan(sz(i,:)));
                    dtype = W.arrayfun(@(x)class(var{x}.(fn{i})), idnotnan, false); 
                    dtype = W.string(unique(dtype));
                    if length(dtype) > 1
                        if ~all(ismember(dtype, {'string', 'char', 'cell'}))
                            for j = 1:size(sz,2)
                                var{j}.(fn{i}) = [];
                            end
                        else
                            dtype = 'string';
                            sz_max(i) = 1;
                            for j = 1:size(sz, 2)
                                if ~isnan(sz(i,j))
                                    var{j}.(fn{i}) = string(var{j}.(fn{i}));
                                end
                            end
                        end
                    else
                        switch dtype
                            case 'char' % turn chars to strings
                                dtype = 'string';
                                sz_max(i) = 1;
                                for j = 1:size(sz, 2)
                                    if ~isnan(sz(i,j))
                                        var{j}.(fn{i}) = string(var{j}.(fn{i}));
                                    end
                                end
                            case 'table' % ignore subtable
                                W.warning('tab_vertcat: ignoring sub-table - %s', fn{i});
                                for j = 1:size(sz,2)
                                    if ismember(fn{i}, var{j}.Properties.VariableNames)
                                        var{j}.(fn{i}) = [];
                                    end
                                end
                                continue;
                        end
                    end
                    for j = 1:size(sz, 2) % # of tables
                        if isnan(sz(i,j)) || sz(i,j) == 0
                            var{j}.(fn{i}) = W.create_dtype(dtype, [size(var{j},1), sz_max(i)]);
                        elseif sz(i,j) ~= sz_max(i)
                            var{j}.(fn{i}) = W.extend(var{j}.(fn{i}), sz_max(i));
                        end
                    end
                end
                out = vertcat(var{:});
            end
        end
        
        function tab = tab_horzcat(a, b, option) % merge b into a
            arguments
                a table;
                b table;
                option string = 'ignore';
                % ignore - ignore the duplicated names in b
                % overwrite - ignore the duplicated names in a
                % duplicate - save both, name the 2nd table's version as X_duplicate
            end
            if size(a,1) ~= size(b,1)
                W.error('tab_horzcat: table a and b should have the same number of rows');
                return
            end
            c = intersect(a.Properties.VariableNames, b.Properties.VariableNames);
            if ~isempty(c)
                for ci = 1:length(c)
                    if strcmp(option, 'duplicate')
                        W.print('duplicating field %s from the 2nd table', c{ci});
                        b.([c{ci} '_duplicate']) = b.(c{ci});
                        b.(c{ci}) = [];
                    elseif strcmp(option, 'ignore')
                        W.print('ignoring field %s from the 2nd table', c{ci});
                        b.(c{ci}) = [];
                    elseif strcmp(option, 'overwrite')
                        W.print('overwrite field %s from the 1st table', c{ci});
                        a.(c{ci}) = [];
                    end
                end
            end
            tab = horzcat(a, b);
        end        

        function tab = tab_horzcats(varargin)
            tabs = varargin;
            tab = tabs{1};
            for i = 2:length(tabs)
                tab = W.tab_horzcat(tab, tabs{i}, 'overwrite');
            end
        end
        %% format table
        function tab = tab_autofieldcombine(tab, isnested)
            arguments
                tab table;
                isnested logical = false;
            end
            fs = tab.Properties.VariableNames;
            % get fieldnames with underscores _
            is_ = find(contains(fs, '_'));
            idx_ = strfind(fs, '_');
            % exclude fieldnames with non-number suffix
            tstr_suffix = W.arrayfun(@(x)fs{x}(idx_{x}(end)+1:end), is_, 0);
            idxnonnum_ = cellfun(@(x)isempty(str2double(x)) || isnan(str2double(x)), tstr_suffix);
            is_ = is_(~idxnonnum_); 
                % is_ : indices that have the format fn_number
            % get unique fieldnames with fn_number
            fs_ = unique(W.arrayfun(@(x)fs{x}(1:idx_{x}(end)), is_, false));
            flag = false;
            for fi = 1:length(fs_)
                fn = fs_{fi};
                fs = tab.Properties.VariableNames;
                is_ = find(contains(fs, '_'));
                idx_ = strfind(fs, '_');
                idx_col = find(arrayfun(@(x)ismember(x, is_) && length(fn) < length(fs{x}) && ...
                    strcmp(fs{x}(1:length(fn)),fn) && idx_{x}(end) == length(fn), 1:length(fs)));
                    % idx_col is the table columns with the name fn_X
                ord = arrayfun(@(x)str2double(fs{x}(idx_{x}(end)+1:end)), idx_col);

                while any(isnan(ord))
                    tid = ~isnan(ord);
                    idx_col = idx_col(tid);
                    ord = arrayfun(@(x)str2double(fs{x}(idx_{x}(end)+1:end)), idx_col);
                end

                if isempty(ord) % no numbers
                    W.warning('tab_autofieldcombine: empty ord, should not happen!!!')
                    continue;
                end
                if length(W.unique_nan(ord,0)) ~= max(ord) % missing elements, ord has to be 1,2,3,...,n
                    W.warning('tab_autofieldcombine: len != max, ignored. %s', fn);
                    continue;
                end
                flag = true; % some combining operation was done
                [~, idx] = sort(ord);
                idx_col = idx_col(idx);
                if all(W.fieldsize(tab, fs(idx_col), 2) == 1) && ...
                        all(cellfun(@(x)isnumeric(tab.(x)), fs(idx_col)))
                    % if all fields have 1 column & numeric, combine those columns in
                    % a single matrix
                    tab = mergevars(tab, fs(idx_col), 'NewVariableName', fn(1:end-1));
                else 
                    % otherwise, save the whole table (consisting of the n
                    % variables) as the new variable
                    tab.(fn(1:end-1)) = tab(:, idx_col);
                    tab = removevars(tab, fs(idx_col));
                end
            end
            if isnested == 1 && flag 
                tab = W.tab_autofieldcombine(tab, isnested);
            end
        end
        function tab = tab_decombine(tab, isnested)
            arguments
                tab table;
                isnested logical = false;
            end
            flag = false;
            fnms = W.fieldnames(tab);
            for fi = 1:length(fnms)
                fn = fnms{fi};
                if size(tab.(fn),2) > 1
                    flag = true;
                    newnames = W.arrayfun(@(x)strcat(fn, '_', num2str(x)), 1:size(tab.(fn),2));
                    tab = splitvars(tab, fn, 'NewVariableNames', newnames);
                end
            end
            if isnested == 1 && flag
                tab = W.tab_decombine(tab, isnested);
            end
        end
        % no columns are tables.
        function tab = tab_denested(tab, usedigitonly)
             if ~exist('usedigitonly', 'var') || isempty(usedigitonly)
                 usedigitonly = false;
             end
             fs = tab.Properties.VariableNames;
             idtab = find(cellfun(@(x)istable(tab.(x)), fs));
             for it = idtab
                 fn = fs{it};
                 te = tab.(fn); % this is the sub-table
                 if usedigitonly
                     te.Properties.VariableNames = W.arrayfun(@(x)strcat(fn, '_', num2str(x)), 1:size(te,2));
                 else
                     te = W.tab_prefix(te, fn, []);
                 end
                 tab = removevars(tab, fn);
                 tab = W.tab_horzcat(tab, te);
             end
             if ~isempty(idtab)
                 tab = W.tab_denested(tab);
             end
        end
        %% turn columns into rows
        function tab = tab_horz_if_1D(tab, isforce)
            if ~exist('isforce', 'var') || isempty(isforce)
                isforce = false;
            end
            sz = W.fieldsize(tab);
            if all(sz(:,2) == 1) || isforce
                tab = W.struct2table_if_1D(W.table2struct(tab), isforce);
            end
        end
        %% table to struct
        function str = table2struct(tab)
            str = table2struct(tab, "ToScalar", true);
        end
        %% table fill columns
        function tab = tab_fill(tab, varargin)
            if nargin == 2 % in this case, varargin should be a table (with 1 row)
                fn = varargin{1};
                tab = W.tab_horzcat(tab, repmat(fn, size(tab,1), 1));
            else
                i = 1;
                while i+1 <= length(varargin)
                    fn = varargin{i}; % fieldname
                    x = varargin{i+1}; % value (1 row)
                    tab.(fn) = repmat(x, size(tab,1), 1);
                    i = i + 2;
                end
            end
        end
        function tab = tab_fill_ID(tab, IDname)
            if ~exist('IDname', 'var') || isempty(IDname) || ~W.is_stringorchar(IDname)
                IDname = 'tabID';
            end
            if ~ismember(IDname, W.fieldnames(tab))
                tab.(IDname) = W.vert(1:size(tab,1));
            else
                W.print('tab_addID: tab.%s exists, ignore', IDname);
            end
        end
        %% string 2 double
        function tab = tab_str2double(tab)
            fnms = W.fieldnames(tab);
            for i = 1:length(fnms)
                tfn = tab.(fnms(i));
                if W.is_stringorchar(tfn) 
                    tfn = W.string(tfn);
                    te = W.strs_select(tfn, '!digit');
                    if all(arrayfun(@(x)W.isempty(te(x)), 1:length(te)))
                        tab.(fnms(i)) = str2double(tfn);
                    end
                end
            end
        end
    end
end