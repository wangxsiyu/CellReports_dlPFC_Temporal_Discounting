classdef S_plt_executor_stats < S_plt_executor_core
    methods
        function execute_sigstar(obj, plotdata, plotparams)
            opt_params = struct('Color', 'black', ...
                'FontSize', obj.param_plt.fontsize_axes, ...
                'HorizontalAlignment', 'left');
            opt_params = W.struct_set(opt_params, plotparams.varargin{:});
            opt_params.Color = obj.translate_colors(opt_params.Color);   
            tt = text(plotdata.x, plotdata.y, plotdata.strp, ...
                'Color', opt_params.Color{1}, ...
                'FontSize', opt_params.FontSize, ...
                'HorizontalAlignment', opt_params.HorizontalAlignment);
            set(tt,'Rotation',90);
        end
    end
    methods(Access = private)
    end
end