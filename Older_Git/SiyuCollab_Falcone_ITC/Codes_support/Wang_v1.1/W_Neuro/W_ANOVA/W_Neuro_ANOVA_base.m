classdef W_Neuro_ANOVA_base < handle
    methods(Static)
        function [anova] = anovan_core(anovafunc, spikes, setting)
            anova = struct;
            if isempty(spikes.cells)
                return;
            end
            if isfield(spikes, 'info_cells')
                anova.info_cells = spikes.info_cells;
            else
                anova.info_cells = table;
            end
            if isfield(anova, 'info_session')
                anova.info_session = spikes.info_session;
            end
            anova.anova_setting = setting;
            W.print('running W.anovan_core');
            %% loop over cells
            anova.cells = W.neuro_looper_singlecell(spikes.cells, anovafunc, ...
                setting.factors, 'varnames', setting.factornames, setting.anova_params{:}, ...
                'namejob', 'W.anovan');
            anova.cells = W.cellfun_assign_to_cellofstruct(anova.cells, 'is_significant', @(x)x.p_factors < setting.alpha, anova.cells);
            anova.cells = W.cellfun_assign_to_cellofstruct(anova.cells, 'any_significant', @(x)any(x.is_significant), anova.cells);
            %% get actual factor names
            anova.anova_setting.factornames_anova = unique(W.cellfun_vertcat(@(x)x.name_factors, anova.cells), 'rows');
            %%
            if size(anova.cells{1}.p_factors,2) == 1 % single interval
                ttab = table(W.cellfun_horzcat(@(x)x.p_factors, anova.cells)');
                ttab = W.tab_decombine(ttab);
                ttab.Properties.VariableNames = anova.anova_setting.factornames_anova;
                anova.info_cells = horzcat(anova.info_cells, ttab);
            end
        end
    end
    methods(Static, Access = protected)
        function [spikes, setting] = format_anova_params(spikes, games, factornames, varargin)
            setting = W.struct('alpha', 0.05, ...
                'factornames', {}, ...
                'factornames_in_data', {}, ...
                'window_significance', [-Inf, Inf]);
            [setting, anova_params] = W.struct_set(setting, 'factornames', factornames, varargin{:}, 'option_merge', 'set');
            setting.anova_params = W.empty2cell(anova_params);
            %% format factornames
            setting.factornames = W.string(setting.factornames);
            if isempty(setting.factornames_in_data)
                setting.factornames_in_data = setting.factornames;
            end
            setting.factornames_in_data = W.string(setting.factornames_in_data);
            setting.anova_params = [setting.anova_params, {'varnames', setting.factornames}];
            %% format spikes, copy time_at, time_win
            if ~iscell(spikes)
                setting.time_at = spikes.time_at;
                setting.time_window = spikes.time_win;
                spikes = W.encell(spikes.cells);
            else
                setting.time_at = [];
                setting.time_window = [];
            end
            setting.ncell = length(spikes);
            if isempty(spikes)
                return;
            end
            setting.ntime = size(spikes{1},2);
            %% format factors
            factors = W.arrayfun(@(x)games.(x), setting.factornames_in_data);
            for i = 1:length(factors)
                if ~isnumeric(factors{i}) || islogical(factors{i})
                    factors{i} = W.strs_find_matches(factors{i}, unique(factors{i}));
                end
%                 if size(factors{i},2) == 1
%                     factors{i} = repmat(factors{i},1,st.ntime);
%                 end
            end
            setting.factors = factors;
            %% get index support
            if isfield(setting, 'window_significance') && ~isempty(setting.time_at) && ~isempty(setting.time_window)
                setting.idx_significant_window = find(setting.time_at - setting.time_window/2 >= setting.window_significance(1) & ...
                    setting.time_at + setting.time_window/2 <= setting.window_significance(2));
            else
                setting.idx_significant_window = 1:setting.ntime;
            end
        end
    end
end