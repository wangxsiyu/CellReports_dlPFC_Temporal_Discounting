classdef W_Neuro_Looper < handle
    methods(Static)
        function output = neuro_looper_singlecell(cells, func, varargin)
            st = W.struct('loginterval', 50, 'namejob', 'run singlecell', 'cellinput', {});
            [st, vars] = W.struct_set_endoptions(st, varargin{:});
            ncell = length(cells);
            output = cell(1, ncell);
            func = W.str2func(func);
            for ci = 1:ncell
                if mod(ci, st.loginterval) == 0 || ci == ncell
                    W.print('%s, at cell# %d/%d', st.namejob, ci, ncell);
                end
                if isempty(st.cellinput)
                    output{ci} = func(cells{ci}, vars{:});
                else
                    te = W.cellfun(@(x)W.decell_once(x(ci)), st.cellinput, false);
                    output{ci} = func(cells{ci}, te{:}, vars{:});
                end
            end
        end
    end
end