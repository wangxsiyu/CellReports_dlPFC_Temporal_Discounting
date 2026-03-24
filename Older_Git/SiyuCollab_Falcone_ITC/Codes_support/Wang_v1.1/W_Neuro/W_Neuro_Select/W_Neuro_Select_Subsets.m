classdef W_Neuro_Select_Subsets < handle
    methods(Static)
        %% add cell/trial index
        function [idx] = select_addindex_cellsANDtrials(cells, games, func)
            func = W.str2func(func);
            idx = func(cells, games);
            if ~isfield(idx, 'idx_cells')
                idx.idx_cells = repmat({1:length(cells.cells)}, 1, length(idx.idx_trials));
            end
            if ~isfield(idx, 'idx_trials')
                idx.idx_trials = repmat({1:size(games,1)}, 1, length(idx.idx_cells));
            end
            idx.ncond = length(idx.idx_cells);
            if ~isfield(idx, 'convert2struct')
                idx.convert2struct = false;
            end
        end
        %% cells and trials
        function [cells, games] = select_trials(cells, games, idx_select)
            if ~exist('idx_select', 'var') || isempty(idx_select)
                idx_select = games.is_complete == 1;
            elseif ~isnumeric(idx_select) && ~islogical(idx_select) % idx_select could be a function
                idx_select = W.str2func(idx_select);
                idx_select = idx_select(games);
            end
            if islogical(idx_select)
                idx_select = find(idx_select);
            end
            games = games(idx_select,:);
            if iscell(cells)
                tcells = cells;
            else
                nm = char(intersect(fieldnames(cells), {'cells', 'pc', 'x1D'}));
                tcells = W.encell(cells.(nm));
            end
            if istable(tcells{1})
                for i = 1:length(tcells)
                    x = tcells{i};
                    x = x(ismember(x.trialID, idx_select),:);
                    x.trialID = W.changem(x.trialID, 1:length(idx_select), idx_select);
                    tcells{i} = x;
                end
            else
                tcells = W.cellfun(@(x)x(idx_select,:), tcells, false);
            end
            tcells = W.decell(tcells);
            if iscell(cells)
                cells = tcells;
            else
                cells.(nm) = tcells;
            end
        end

        function cells = select_cells(cells, idx_select, notes)
            if ~exist('notes', 'var') || isempty(notes)
                notes = '';
            end
            idx_select = logical(idx_select);
            if isfield(cells, 'cells')
                cells.cells = cells.cells(idx_select);
                cells.info_cells = cells.info_cells(idx_select,:);
                cells.info_session.notes_exclude_cells = notes;
            end
%             if isfield(cells, 'idx_neurons_kept')
%                 cells.idx_neurons_kept = cells.idx_neurons_kept(idx_select);
%                 cells.notes_exclusion{end+1} = W.decell(notes); 
%             else
%                 cells.idx_neurons_kept = idx_select;
%                 cells.notes_exclusion = W.encell(notes);
%             end
%             if isfield(cells, 'info_spikes') && ~isempty(cells.info_spikes)
%                 cells.info_spikes = structfun(@(x)W.vert(x), cells.info_spikes, 'UniformOutput', false);
%                 cells.info_spikes = structfun(@(x)x(idx_select,:), cells.info_spikes, 'UniformOutput', false);
%             end
        end
    end
end