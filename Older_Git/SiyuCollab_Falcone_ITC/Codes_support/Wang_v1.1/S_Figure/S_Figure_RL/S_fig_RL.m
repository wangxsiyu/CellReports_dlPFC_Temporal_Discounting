classdef S_fig_RL < handle
    methods(Static)
        function plt = ax_model_comparison(plt, models)
            nms = fieldnames(models{1});
            tp = W.cellfun(@(md)structfun(@(x)rmfield(x, {'model','params_array', 'params'}), md), models);
            figdata = {};
            for i = 1:length(nms)
                paramfits = struct2table(W.cellfun(@(x)x(i), tp));
                figdata{1}(:,i) = paramfits.AIC;
                figdata{2}(:,i) = paramfits.BIC;
            end
            %%
            plt.figure(1,2,'gapH_custom', [0.05, 1]);
            plt.setfig_all('xlabel', '', 'xtick', 1:length(nms), 'xticklabel', nms, ...
                'ylim', [], 'xtickangle', 45, 'xlim', [0.5 length(nms) + 0.5]);
            plt.setfig('ylabel', {'AIC', 'BIC'});
            for i = 1:2
                [av, se] = W.avse(figdata{i});
                plt.ax(i);
                plt.plot([], av, se, 'line', 'color', 'black');
            end
            plt.update;
        end
    end
end