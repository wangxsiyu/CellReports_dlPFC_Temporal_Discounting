classdef W_Analysis_Table_Advanced_Format < handle
    methods(Static)
        %% convert trial x feature to block x feature (vector of trials)
        function [tab, sub] = tab_trial2block(data, idxsub, varargin)
            if ~exist('idxsub', 'var') || isempty(idxsub)
                if isempty(varargin)
                    idxsub = {1:size(data,1)};
                else
                    idxsub = W.tab_select_rows_by_conds(data, varargin{:});
                end
            end
            [~, sub] = W.tab_uniquerow(data, idxsub);
            fs = data.Properties.VariableNames;
            fs = setdiff(fs, fieldnames(sub));
            flag = [];
            for fi = 1:length(fs)
                for si = 1:length(idxsub)
                    lines = idxsub{si};
                    td = data.(fs{fi})(lines,:);
                    if size(td,2) == 1
                        flag(fi) = 1;
                    else
                        flag(fi) = 0;
                        break;
                    end
                end
            end
            MT = max(cellfun(@(x)length(x), idxsub));
            for si = 1:length(idxsub)
                lines = idxsub{si};
                for fi = find(flag)
                    td = data.(fs{fi})(lines,:);
                    sub(si).(fs{fi}) = W.extend(td', MT);
                end
            end
            tab = struct2table(sub);
        end
        function out = tab_block2trial(data, n)
            [ncol, fnms] = W.fieldsize(data, [], 2);
            if ~exist('n', 'var') || isempty(n)
                n = max(ncol);
            end
            id = ncol == n;
            fnms = fnms(id);
            data = data(:, id);

            f = @(x)W.tab_fill_ID(W.arrayfun_horzcat(@(t)W.table(t, x.(t)'), fnms), 'trialID');
            out = W.arrayfun_vertcat(@(k)W.tab_fill(f(data(k,:)), 'blockID', k), 1:size(data,1));
        end
    end
end