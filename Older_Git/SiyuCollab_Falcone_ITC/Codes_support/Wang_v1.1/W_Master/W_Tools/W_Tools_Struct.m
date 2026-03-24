classdef W_Tools_Struct < handle
    methods(Static)
        function X = struct(varargin)
            X = W.varargin2struct(varargin{:});
        end
        %% struct set
        function [X, unused] = struct_set(X, varargin)
            % unusedparams is returned as a structure
            unused = [];
            vars = W.encell(varargin);
            if isempty(vars)
                return;
            end
            if length(vars) == 1 && W.is_stringorchar(vars{1}) && ...
                    strcmp(vars{1}, 'help')
                W.print('available parameters are:');
                W.print_bullet(W.fieldnames(X));
                return;
            end
            X1 = struct;
            if length(vars) >= 1 && isstruct(vars{1}) % 1st inputs is a structure
                X1 = vars{1};
                vars = vars(2:end);
            end
            option = W.struct('option_merge', []);
            [option, vars] = W.struct_set_endoptions(option, vars{:});
%             if ~isempty(vars) && mod(length(vars), 2) == 1 && ...
%                     W.is_stringorchar(vars{end}) 
%                 option.option_merge = vars{end};
%                 vars = vars(1:end-1);
%             end
            X_new = W.varargin2struct(vars{:});
            X1 = W.struct_merge(X1, X_new, 'overwrite');
            [X, unused] = W.struct_merge(X, X1, option.option_merge);
            unused = W.struct2cell(unused);
        end
        function [X, unused] = struct_set_withdefault(X, ...
                varname_default, varargin)
            vars = W.varargin_withdefault(varname_default, fieldnames(X), varargin{:});
            [X, unused] = W.struct_set(X, vars{:});
        end
        function [X, unused] = struct_set_endoptions(X, varargin)
            [xopt, unused] = W.varargin_get_endoptions(fieldnames(X), varargin{:});
            X = W.struct_merge(X, xopt, 'set');
        end
        %% struct to cell
        function out = struct2cell(st)
            if ~isempty(st) && ~isstruct(st)
                out = st;
                W.warning('struct2cell: input not struct');
                return;
            end
            if W.isempty(st)
                out = {};
                return;
            end
            nms = W.fieldnames(st);
            out = W.arrayfun(@(x){x, st.(x)}, nms, false);
            out = [out{:}];
        end
        %% struct array, struct, table
        function out = structarray2struct(a) %, ishorz)
%             if ~exist('ishorz', 'var') || isempty(ishorz)
%                 ishorz = true;
%             end
            out = W.table2struct(struct2table(a));
%             if ishorz
%                 out = structfun(@(x)W.horz(x), out, 'UniformOutput', false);
%             end
        end
        function s = struct_horz(s)
            s = structfun(@(x)W.horz(x), s, 'UniformOutput', false);
        end
        function out = struct2table_if_1D(s, isforce)
            if ~exist('isforce', 'var') || isempty(isforce)
                isforce = false;
            end
            s = W.struct_horz(s);
            [sz, names] = W.fieldsize(s);
            if isforce
                s = rmfield(s, names(sz(:,1) ~= 1));
            end
            if all(sz(:,1) == 1)
                out = struct2table(s);
            else
                out = s;
            end
        end
        %% operations between structs
        % struct merge - add fields in b that's not in a
        function [a, unused] = struct_merge(a, b, option)
            unused = [];
            if isempty(a)
                a = struct;
            end
            if ~exist('option', 'var') || isempty(option)
                option = 'overwrite';
                % ignore - ignore the duplicated names in b
                % overwrite - ignore the duplicated names in a
                % set - replace the fields in a with corresponding values
                % in b (ignore extra fields in b)
            end
            c = intersect(fieldnames(a), fieldnames(b));
            switch option
                case 'overwrite'
                    a = rmfield(a, c);
                case 'ignore'
                    b = rmfield(b, c);
                case 'set'
                    a = rmfield(a, c);
                    unused = rmfield(b, c);
                    b = rmfield(b, setdiff(fieldnames(b), c));
            end
            a = W.struct_combine(a, b);
        end
        % struct combine - combine fields
        function a = struct_combine(a, b, varargin)
            if isempty(a)
                a = struct;
            end
            a = cell2struct([struct2cell(a); struct2cell(b)], [fieldnames(a); fieldnames(b)], 1);
            if ~isempty(varargin)
                a = W.struct_combine(a, varargin{:});
            end
        end
        %% struct append
        function out = struct_append(a, b, dim, fnms_include, fnms_exclude)
            if ~exist('dim', 'var') || isempty(dim)
                dim = 1;
            end
            if W.isempty(a)
                out = b;
                return
            elseif W.isempty(b)
                out = a;
                return
            end
            fnms_all = unique([W.fieldnames(a),W.fieldnames(b)]);
            fnms = fnms_all;
            if exist('fnms_include', 'var') && ~isempty(fnms_include)
                fnms = intersect(fnms, fnms_include);
            end
            if exist('fnms_exclude', 'var') && ~isempty(fnms_exclude)
                fnms = setdiff(fnms, fnms_exclude);
            end
            out = a;
            for i = 1:length(fnms)
                fn = fnms{i};
                out.(fn) = cat(dim, a.(fn), b.(fn));
            end
        end
        %% sub struct
        function a = struct_sub(a, fnms, isrev)
            if ~exist('isrev', 'var')
                isrev = false;
            end
            fnms = W.string(fnms);
            f = W.fieldnames(a);
            d = struct2cell(a);
            if isrev
                fnms = setdiff(f, fnms);
            end
            tid = W.strs_have_matches(f, fnms);
            a = cell2struct(d(tid), f(tid));
        end
        %% rmfield
        function a = rmfield(a, name)
            if isfield(a, name)
                a = rmfield(a, name);
            end
        end
        %% rename field
        function Snew = struct_rename(Sold, oldnames, newnames)
            % renameStructField does not work for multiple names or struct
            % array
            oldnames = W.encell(oldnames);
            newnames = W.encell(newnames);
            N = numel(Sold);
            Snew = Sold;
            for k=1:numel(oldnames)
                [Snew(1:N).(newnames{k})] = deal(Sold.(oldnames{k})) ;
                Snew = rmfield(Snew, oldnames{k});
            end
        end

        function Snew = struct_pfxsfx(Sold, pfx, sfx)
            oldnames = W.fieldnames(Sold);
            newnames = W.file_prefix(oldnames, pfx);
            newnames = W.file_suffix(newnames, sfx);
            Snew = W.struct_rename(Sold, oldnames, newnames);
        end
        %% specialized - set each field of the struct to be cell(1,n)
        function S = struct_autofilln(S, n)
            fnms = W.fieldnames(S);
            for fi = 1:length(fnms)
                fn = fnms(fi);
                S.(fn) = W.encell(S.(fn));
                if length(S.(fn)) == 1
                    S.(fn) = repmat(S.(fn), 1, n);
                end
            end
        end
    end
end