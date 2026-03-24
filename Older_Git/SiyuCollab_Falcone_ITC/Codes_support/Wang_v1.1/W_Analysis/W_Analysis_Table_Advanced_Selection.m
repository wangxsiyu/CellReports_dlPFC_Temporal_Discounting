classdef W_Analysis_Table_Advanced_Selection < handle
    methods(Static)
        %% select row indices for each subject (out of table of trials)
        function [rowid, tab] = tab_select_rows_by_conds(data, cond_fds)
            % In a table where each row is a trial, select row indicies for each subject 
            % based on the uniqueness of fields cond_fds (e.g. {'subjectID', 'date'})
            [cond, tab] = W.tab_getcombinedID(data, cond_fds);
            tab = unique(tab, 'stable');
            conds = tab.combinedID;
            rowid = cell(length(conds), 1);
            wtb = waitbar(0, 'selectsubject');
            for i = 1:length(conds)
                waitbar(i/length(conds), wtb, sprintf('extracting index for subject %d', i));
                rowid{i} = find(strcmp(cond, conds{i}));
            end
            tab.rowid = rowid;
            close(wtb);
        end
        %% get combined ID based on several fields (e.g., subjectID x date x time)
        function [str, out] = tab_getcombinedID(tab, fds, sep)
            % this is to compute a combined condition by treating
            % everything as strings
            if ~exist('sep', 'var') || isempty(sep)
                sep = ', ';
            end
            if ~exist('fds', 'var') || isempty(fds)
                fds = tab.Properties.VariableNames;
            end
            fds = W.str2cell(fds);
            n = length(fds);
            % wtb = waitbar(0, 'Starting');
            str = [];
%             fdsout = [];
            for i = 1:n
                % waitbar(i/n, wtb, ...
                %     sprintf("tab getcombinedID: field %d/%d, %s", i, n, fds{i}));
                if ~ismember(fds{i}, W.fieldnames(tab))
                    W.warning('field %s does not exist', fds{i});
                    continue;
%                 else
%                     fdsout = [fdsout fds(i)];
                end
                te = tab.(fds{i});
                if isnumeric(te)
                    if any(isnan(te))% watch NaNs, since string(NaN) = <missing>.
                        te = W.arrayfun(@(x)string(num2str(x)), te);
                    end
                end
                te = string(te);
                if size(te, 2) > 1 % use ',' to separate numbers in a matrix
                    te = join(te, ',');
                end
                if contains(sep, ',') % replace ',' in data with '.'
                    te = replace(te, ',', '.');
                end
                if isempty(str)
                    str = te;
                else
                    str = strcat(str, sep, te);
                end
            end
            % close(wtb);
            if isempty(str)
                W.error('tab_getconbineIDs: no fields exists');
                return;
%                 tab.dummyID = repmat("dummyID", size(tab,1),1);
%                 str = tab.dummyID;
%                 fdsout = ["dummyID"];
            end
            out = W.str_parse2cell(str, ',');
            out = W.table_namesfirst(out, fds{:});
            out = W.tab_str2double(out);
            out.combinedID = str;
        end
        %% get subject information (out of table of trials)
        function [tabuniq, uniq] = tab_uniquerow(tab, idxsub)
            if ~exist('idxsub', 'var') || isempty(idxsub)
                idxsub = {1:size(tab,1)};
            end
            idxsub = W.encell(idxsub);
            fs = tab.Properties.VariableNames;
            n_field = length(fs);
            n_sub = length(idxsub);
            flag_uniq = true(1, n_field);
            tout = cell(n_field, n_sub);
            for fi = 1:n_field
                for si = 1:n_sub
                    lines = idxsub{si};
                    td = tab.(fs{fi})(lines,:);
                    tout{fi, si} = W.unique(td, 'rows');
                    if size(tout{fi, si}, 1) ~= 1 % if it's not unique
                        flag_uniq(fi) = false;
                        break;
                    end
                end
            end
            uniq = [];
            for si = 1:n_sub
                for fi = find(flag_uniq)
                    uniq(si).(fs{fi}) = tout{fi, si};
                end
            end
            tabuniq = struct2table(uniq);
        end
%         %% get multi group names
%         function out = tab_uniquerow_bycond(tab, gpvar, gpID, varargin)
%             if ~exist('gpID', 'var') || isempty(gpID)
%                 gpID = unique(gpvar);
%             end
%             idxs = W.arrayfun(@(x) gpvar == x, gpID, false);
%             out = W.tab_uniquerow(tab, idxs, varargin{:});
%         end
    end
end