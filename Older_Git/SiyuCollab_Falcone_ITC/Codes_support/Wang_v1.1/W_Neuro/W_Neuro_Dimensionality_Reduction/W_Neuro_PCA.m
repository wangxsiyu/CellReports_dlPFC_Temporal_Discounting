classdef W_Neuro_PCA < handle
    methods(Static)
        function pc = neuro_PCA_denoisedtraj(cells, games, func_traj, varargin)
            if ~exist('func_traj', 'var') || isempty(func_traj)
                trajs = cells.cells;
            else
                func_traj = W.str2func(func_traj);
                trajs = func_traj(cells, games);
            end
            pc = W.neuro_PCA(cells, trajs, varargin{:});
        end
        function pc = neuro_PCA(cells, trajs, timerange_traj, ndim)
            pc = rmfield(cells, {'cells', 'info_cells'});
            if ~isfield(cells, 'time_at')
                cells.time_at = 1:size(cells.cells{1},2);
            end
            if exist('timerange_traj', 'var') && length(timerange_traj) == 2
                pc.pca_range_idx = [find(timerange_traj(1)<=cells.time_at, 1, 'first'), ...
                    find(timerange_traj(2)>=cells.time_at, 1, 'last')];
            else
                pc.pca_range_idx = [1 length(cells.time_at)];
            end
            pc.pca_window = cells.time_at(pc.pca_range_idx);
            tid = pc.pca_range_idx(1):pc.pca_range_idx(2);
            ts = W.cell_NxMK2KxMN(trajs);
            spikes = W.cell_NxMK2KxMN(cells.cells);
            ts = ts(tid);
            ts = vertcat(ts{:});
            %% pca
            pcinfo = W.pca(ts);
            %% get pcs
            tpc = W.project2pc(pcinfo, spikes);
            pc.pc = W.cell_NxMK2KxMN(tpc);
            if exist('ndim', 'var') && isnumeric(ndim)
                pc = W.neuro_PCA_subspace(pc, ndim);
            end
            pc.info_pc = pcinfo;
        end
        function pc = neuro_PCA_subspace(pc, ndim)
            pc.pc = pc.pc(1:ndim);
        end
    end
end