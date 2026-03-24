classdef S_plt_executor_plot < S_plt_executor_core
    methods
        function execute_plot(obj, plotdata, plotparams)
            x = plotdata.x;
            y = plotdata.y;
            errbar = plotdata.errorbar;
            func = eval(sprintf('@obj.execute_plot_%s', plotparams.plottype));
            func(x, y, errbar, plotparams.varargin{:}); % NEED TO CHANGE
        end
        function execute_dashXY(obj, plotdata, plotparams)
            opt_params = struct('color', 'black', ...
                'LineWidth', obj.param_plt.linewidth/2);
            opt_params = W.struct_set(opt_params, plotparams.varargin{:});
            opt_params.color = obj.translate_colors(opt_params.color);   
            hold on;
            plot(plotdata.x, plotdata.y, '--', 'LineWidth', opt_params.LineWidth, ...
                'color', opt_params.color{1});
        end
    end
    methods(Access = private)
        function execute_plot_line(obj, x, y, errbar, varargin)
            nls = length(y);
            % ----------- Set optional variables
            opt_params = W.struct('color', [], 'LineStyle', '-', 'addtolegend', 1, ...
                'MarkerSize', obj.param_plt.markersize, 'CapSize', obj.param_plt.capsize_errorbar, ...
                'LineWidth', obj.param_plt.linewidth);
            opt_params = W.struct_set(opt_params, varargin{:});
            opt_params.color = obj.translate_colors(opt_params.color);
            opt_params = W.struct_autofilln(opt_params, nls);
            % ----------- plot
            for li = 1:nls
                tx = x{li};
                ty = y{li};
                terr = errbar{li};
                if all(isnan(ty))
                    eb = plot(NaN, NaN);
                else
                    hold on;
                    if isempty(terr)
                        eb = plot(tx, ty, opt_params.LineStyle{li}, ...
                            'LineWidth', opt_params.LineWidth{li});
                        eb.MarkerSize = opt_params.MarkerSize{li};
                    else
                        eb = errorbar(tx, ty, terr, terr, opt_params.LineStyle{li}, ...
                            'LineWidth', opt_params.LineWidth{li});
                        eb.CapSize = opt_params.CapSize{li};
                    end
                    if li <= length(opt_params.color) && ~isempty(opt_params.color{li}) 
                        eb.Color = opt_params.color{li};
                        eb.MarkerFaceColor = opt_params.color{li};
                    end
                    hold off;
                end
                if opt_params.addtolegend{li}
                    obj.fig.object_list{obj.axi}(end + 1) = eb;
                end
            end
        end
        function execute_plot_shade(obj, x, y, errbar, varargin)
            nls = length(y);
            % ----------- Set optional variables
            opt_params = W.struct('color', [], 'LineStyle', '-', 'addtolegend', 1, ...
                'MarkerSize', obj.param_plt.markersize, 'facealpha', 0.5, ...
                'LineWidth', obj.param_plt.linewidth);
            opt_params = W.struct_set(opt_params, varargin{:});
            opt_params.color = obj.translate_colors(opt_params.color);
            opt_params = W.struct_autofilln(opt_params, nls);
            % ----------- plot
            tx = cell(1, nls);
            ty = cell(1, nls);
            for li = 1:nls
                hold on;
                tx0 = x{li};
                ty0 = y{li};
                terr0 = errbar{li};
                
                [~, idnan1] = W.nan_exclude_prepost(ty0);
                [~, idnan2] = W.nan_exclude_prepost(terr0);
                tid = intersect(idnan1, idnan2);

                tx{li} = tx0(tid);
                ty{li} = ty0(tid);
                terr = terr0(tid);

                top = ty{li} + terr;
                bot = ty{li} - terr;
                yy = [top bot(end:-1:1)];
                xx = [tx{li} tx{li}(end:-1:1)];
                if li <= length(opt_params.color) && ~isempty(opt_params.color{li}) 
                    f = fill(xx, yy, opt_params.color{li} * 0.5 + [1 1 1] * 0.5);
                else
                    f = fill(xx, yy, [0 0 0]);
                end
                set(f, 'linestyle', 'none','facealpha',opt_params.facealpha{li});
            end
            for li = 1:nls
                if all(isnan(ty{li}))
                    eb = plot(NaN, NaN);
                else
                    eb = plot(tx{li}, ty{li}, opt_params.LineStyle{li}, ...
                        'LineWidth', opt_params.LineWidth{li});
                    eb.MarkerSize = opt_params.MarkerSize{li};

                    if li <= length(opt_params.color) && ~isempty(opt_params.color{li})
                        eb.Color = opt_params.color{li};
                        eb.MarkerFaceColor = opt_params.color{li};
                    end
                end
                if opt_params.addtolegend{li}
                    obj.fig.object_list{obj.axi}(end + 1) = eb;
                end
            end
        end
        function execute_plot_bar(obj, x, y, errbar, varargin)
            nls = length(y);
            if nls > 1
                W.print('multiple barplots not implemented, only the first bar will be plotted');
            end
            % ----------- Set optional variables
            opt_params = struct('color', [], 'LineStyle', '.', ...
                'barside', 'both', ...
                'addtolegend', 1, 'individualcolor', 0, ...
                'facecolorratio', 0.5, ...
                'LineWidth', obj.param_plt.linewidth, ...
                'CapSize', obj.param_plt.capsize_errorbar);
            opt_params = W.struct_set(opt_params, varargin{:});
            opt_params.color = obj.translate_colors(opt_params.color);
            opt_params = W.struct_autofilln(opt_params, nls);
            
            li = 1;
            tx = x{li};
            ty = y{li};
            terr = errbar{li};
            if ~isempty(terr)
                switch opt_params.barside{1}
                    case 'both'
                        terrneg = terr;
                        terrpos = terr;
                    case '+'
                        terrneg = terr * 0;
                        terrpos = terr;
                    case '-'
                        terrneg = terr;
                        terrpos = terr * 0;
                    case 'auto1'
                        terrneg = terr .* (ty <= 0);
                        terrpos = terr .* (ty >= 0);
                end
            end
            
            if all(isnan(ty))
                bb = bar(NaN, NaN);
            else
                hold on;
                if opt_params.individualcolor{li}
                    for i = 1:length(tx)
                        bb = bar(tx(i), ty(i));
                        if li <= length(opt_params.color) && ~isempty(opt_params.color{li})                          
                            ratio = opt_params.facecolorratio{li};
                            bb.FaceColor = ratio * ([1 1 1]) + (1-ratio) * opt_params.color{li}{i};
                        end
                        if ~isempty(terr)
                            eb = errorbar(tx(i), ty(i), terrneg(i), terrpos(i), opt_params.LineStyle{li}, ...
                                'LineWidth', opt_params.LineWidth{li});
                            eb.CapSize = opt_params.CapSize{li};
                            if li <= length(opt_params.color) && ~isempty(opt_params.color{li})
                                eb.MarkerFaceColor = opt_params.color{li}{i};
                                eb.Color = opt_params.color{li}{i};
                            end
                        end
                    end
                else
                    bb = bar(tx, ty);
                    if li <= length(opt_params.color) && ~isempty(opt_params.color{li})
                        bb.FaceColor = opt_params.color{li};
                    end
                    if ~isempty(terr)
                        eb = errorbar(tx, ty, terrneg, terrpos, opt_params.LineStyle{li}, ...
                            'LineWidth', opt_params.LineWidth{li});
                        eb.CapSize = opt_params.CapSize{li};
                        if li <= length(opt_params.color) && ~isempty(opt_params.color{li})
                            eb.MarkerFaceColor = opt_params.color{li};
                            eb.Color = opt_params.color{li};
                        end
                    end
                end
                hold off;
            end
            if opt_params.addtolegend{li}
                obj.fig.object_list{obj.axi}(end + 1) = bb;
            end
        end
    end
end