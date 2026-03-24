classdef S_fig_Neuro_ANOVA < handle
    methods(Static)
        function plt = ax_slidingwindow_ANOVA(plt, anova, varargin)
            opts = W.struct('plottype', 'line', 'color', []);
            if isfield(plt.custom_vars, 'color_anova')
                opts.color = plt.translate_colors(plt.custom_vars.color_anova);
            end
            [opts, vars] = W.struct_set_endoptions(opts, varargin{:});
            anova = W.encell(anova);
            leg_anova = anova{1}.anova_setting.factornames_anova;
            time_at = anova{1}.anova_setting.time_at;
            perc_sig = W.cellfun(@(anv)W.cellfun(@(x)x.is_significant, anv.cells), anova, false);
            if length(perc_sig) == 1
                [av, se] = W.cell_avse(perc_sig{1});
            else
                te = W.cellfun(@(x)W.cell_mean(x), perc_sig);
                [av, se] = W.cell_avse(te);
            end
            if ~isempty(opts.color)
                plt.plot(time_at, av, se, opts.plottype, 'color', opts.color);
            else
                plt.plot(time_at, av, se, opts.plottype);
            end
            plt.dashY(0, [-1, 1]);
            plt.setfig_ax('xlabel', 'time (ms)', ...
                'ylabel', 'p(significant neurons)', ...
                'legend', leg_anova, 'xlim', [min(time_at), max(time_at)], ...
                'ylim', [0 1]);
        end
        function plt = ax_slidingwindow_ANOVA_omega(plt, anova, varargin)
            opts = W.struct('plottype', 'line', 'color', []);
            if isfield(plt.custom_vars, 'color_anova')
                opts.color = plt.translate_colors(plt.custom_vars.color_anova);
            end
            [opts, vars] = W.struct_set_endoptions(opts, varargin{:});
            anova = W.encell(anova);
            leg_anova = anova{1}.anova_setting.factornames_anova;
            time_at = anova{1}.anova_setting.time_at;
            w2 = W.cellfun(@(anv)W.cellfun(@(x)x.w2_factors, anv.cells), anova, false);
            if length(w2) == 1
                [av, se] = W.cell_avse(w2{1});
            else
                te = W.cellfun(@(x)W.cell_mean(x), w2);
                [av, se] = W.cell_avse(te);
            end
            if ~isempty(opts.color)
                plt.plot(time_at, av, se, opts.plottype, 'color', opts.color);
            else
                plt.plot(time_at, av, se, opts.plottype);
            end
            plt.dashY(0, [-1, 1]);
            plt.setfig_ax('xlabel', 'time (ms)', ...
                'ylabel', 'explained variance (w^2)', ...
                'legend', leg_anova, 'xlim', [min(time_at), max(time_at)], ...
                'ylim', [0 1]);
        end
    end
end