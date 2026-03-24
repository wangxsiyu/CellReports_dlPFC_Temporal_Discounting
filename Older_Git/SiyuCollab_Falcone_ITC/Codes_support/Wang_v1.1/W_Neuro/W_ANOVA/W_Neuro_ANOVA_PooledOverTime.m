classdef W_Neuro_ANOVA_PooledOverTime < W_Neuro_ANOVA_base
    methods(Static)
        function [anova] = anovan_pooledovertime(spikes, games, varargin)
            [spikes.cells, setting] = W.format_anova_params(spikes, games, varargin{:});
            cells = W.cellfun(@(x)x(:, setting.idx_significant_window), spikes.cells, false);
            cells = W.cellfun(@(x)mean(x, 2), cells, false); % mean firing count 
            spikes.cells = cells;
            anova = W.anovan_core('W.anovan_pooled_singlecell', spikes, setting);
            %% auto info_cells
            anova.info_cells.perc_significant = W.vert(cellfun(@(x)x.any_significant, anova.cells));
        end
        function [result] = anovan_pooled_singlecell(spikes, factors, varargin)
            % spikes - ntrial x ntime
            % factors - ntrial x nfeature or {ntrial x 1}_nfeature
            if iscell(factors)
                factors = W.cellfun_horzcat(@(x)x, factors);
            end
            idxnan = isnan(spikes) | any(isnan(factors),2);
            [result] = W.anovan(spikes(~idxnan), factors(~idxnan,:), ...
                'display','off', varargin{:});
        end
    end
end