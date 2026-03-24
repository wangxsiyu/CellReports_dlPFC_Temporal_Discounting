classdef W_Neuro_ANOVA_SlidingWindow < W_Neuro_ANOVA_base
    methods(Static)
        function [anova] = anovan_slidingwindow(spikes, games, varargin)
            if isempty(spikes.cells)
                anova = [];
                return;
            end
            [spikes.cells, setting] = W.format_anova_params(spikes, games, varargin{:});
            anova = W.anovan_core('W.anovan_slidingwindow_singlecell', spikes, setting);
             %% auto info_cells
            anova.info_cells.perc_significant = W.vert(cellfun(@(x)mean(x.any_significant(anova.anova_setting.idx_significant_window)), anova.cells));
        end
        function result = anovan_slidingwindow_singlecell(spikes, factors, varargin)
            % spikes - ntrial x ntime
            % factors - ntrial x nfeature or {ntrial x 1}_nfeature
            if iscell(factors)
                factors = W.cellfun_horzcat(@(x)x, factors);
            end
            ntime = size(spikes, 2);
            result = W.struct('p_factors', [], 'coef_factors_terms', []);
            for ti = 1:ntime
                idxnan = isnan(spikes(:, ti)) | any(isnan(factors),2);
                [tresult] = W.anovan(spikes(~idxnan, ti), factors(~idxnan,:), ...
                    'display','off', varargin{:});
                if ti == 1 % one time
                    result = tresult;
                else
                    result = W.struct_append(result, tresult, 2, [], {'name_factors_terms', 'name_factors'});
                end
            end
        end
        function anova = anovan_mergefactors(anova, oldfactors, newfactor)
            names = anova.cells{1}.name_factors;
            oldfactors = string(oldfactors);
            newfactor = string(newfactor);
            id = W.strs_find_matches(oldfactors, names);
            idother = setdiff(1:length(names), id);
            anova.anova_setting.factornames_anova = [newfactor anova.anova_setting.factornames_anova(idother)];
            anova.cells = W.cellfun_assign_to_cellofstruct(anova.cells, 'name_factors', @(x)[newfactor names(idother)], anova.cells);

            anova.cells = W.cellfun_assign_to_cellofstruct(anova.cells, 'w2_factors', @(x)[sum(x.w2_factors(id,:), 1); x.w2_factors(idother,:)], anova.cells);
            anova.cells = W.cellfun_assign_to_cellofstruct(anova.cells, 'p_factors', @(x)[min(x.p_factors(id,:), [], 1); x.p_factors(idother,:)], anova.cells);
            anova.cells = W.cellfun_assign_to_cellofstruct(anova.cells, 'is_significant', @(x)[any(x.is_significant(id,:), 1); x.is_significant(idother,:)], anova.cells);
            anova.cells = W.cellfun_assign_to_cellofstruct(anova.cells, 'any_significant', @(x)any(x.is_significant, 1), anova.cells);
        end
    end
end