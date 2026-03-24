classdef W_Neuro_Select_SignificantCells < handle
    methods(Static)
        function cells = filter_cells_significance(cells, games, varargin)
            anova = W.anovan_pooledovertime(cells, games, varargin{:});
            idx_select = find(anova.info_cells.perc_significant);
            cells = W.select_cells(cells, idx_select, "ANOVA");
        end
    end
end