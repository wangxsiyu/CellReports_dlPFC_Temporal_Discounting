classdef W_Neuro_Trajectory < handle
    methods(Static)
        function out = neuro_trajectory_bycond(cells, games, varargin)
            [id, idtab] = W.tab_getcombinedID(games, varargin);
            out.cond_trajs = unique(idtab, 'rows');
            id = W.arrayfun(@(x)find(out.cond_trajs.combinedID == x), id);
            trajs = W.trajectory_bycond(cells.pc, id);
            out.trajs = trajs;
            out.info_session = cells.info_session;
        end
        function trajs = trajectory_bycond(cells, varargin)
            % st: cell of length number of cells
            % each cell is ntrial x ntime
            trajs = W.neuro_looper_singlecell(cells, 'W.average_bycond', varargin{:});
        end
        function av = average_bycond(a, cond2av, conds)
            if ~exist('conds', 'var') || isempty(conds)
                conds = unique(cond2av);
            end
            idx = W.arrayfun(@(x)cond2av == x, conds, false);
            av = NaN(length(idx), size(a, 2));
            is1 = W.cellfun(@(x)any(x), idx);
            av(is1,:) = W.cellfun_vertcat(@(x)...
                W.avse(a(x,:)), ...
                idx(is1));
        end
    end
end