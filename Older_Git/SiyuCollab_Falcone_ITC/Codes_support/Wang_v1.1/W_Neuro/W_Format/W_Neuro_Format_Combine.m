classdef W_Neuro_Format_Combine < handle
    methods(Static)
        %% cells across sessions
        function out = format_combinecells(varargin)
            cells = W.decell(varargin);
            if ~iscell(cells) || ~isstruct(cells{1})
                cells = W.load(cells);
            end
            out = rmfield(cells{1}, {'cells', 'info_cells'});
            cells = W.cell_squeeze(cells);
            out.cells = W.cellfun_horzcat(@(x)x.cells, cells);
            out.info_cells = W.cellfun_vertcat(@(x)x.info_cells, cells);
        end
        function out = format_combinecells_and_games(cells, games)
            [cells, idcells] = W.cell_squeeze(cells);
            out = W.format_combinecells(cells);
            out.games = games(idcells);
            out.info_cells.gameID = W.arrayfun_vertcat(@(x)ones(length(cells{x}.cells),1) * x, 1:length(cells));
        end
    end
end