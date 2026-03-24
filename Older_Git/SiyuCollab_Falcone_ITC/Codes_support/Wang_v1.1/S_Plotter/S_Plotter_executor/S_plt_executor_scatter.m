classdef S_plt_executor_scatter < S_plt_executor_core
    methods
        function execute_scatter(obj, plotdata, plotparams)
            x = plotdata.x;
            y = plotdata.y;
            vars = plotparams.varargin;
            option = plotparams.plottype;
            % ----------- Set optional variables
            opt_params = struct('color', 'black', 'shape', '.', 'addtolegend', 1, ...
                'dotsize', obj.param_plt.dotsize, ...
                'linewidth', obj.param_plt.linewidth, ...
                'autolegend', true);
            opt_params = W.struct_set(opt_params, vars{:});
            opt_params.color = obj.translate_colors(opt_params.color);  

            hold on;
            st = plot(x, y, opt_params.shape, 'MarkerSize', opt_params.dotsize, ...
                'Color', opt_params.color{1});
            if opt_params.addtolegend
                obj.fig.object_list{obj.axi}(end + 1) = st;
            end
            switch option
                case 'corr'
                    l = lsline;
                    set(l, 'color', opt_params.color{1});
                    set(l, 'linewidth', opt_params.linewidth);
                    if opt_params.autolegend
                        [r, p] = corr(x,y);
                        str = sprintf('R = %.2f, p = %g', r, p);
                        obj.setfig_ax('legend', str);
                    end
                case 'diag'
                    xmin = min(min(x), min(y));
                    xmax = max(max(x), max(y));
                    dx = xmax - xmin;
                    xmin = xmin - dx * 0.2;
                    xmax = xmax + dx * 0.2;
                    plot([xmin,xmax], [xmin,xmax], '--k', 'linewidth', opt_params.linewidth);
                    xlim([xmin xmax]);
                    ylim([xmin xmax]);
                otherwise
            end
            hold off;
        end
    end
end