classdef S_plt_executor_core < S_plt_executor_core_figure & ...
        S_plt_executor_core_aesthetics & ...
        S_plt_executor_core_files
    methods(Access = protected)
        function execute(obj, func, varargin)
            if strcmp(func, 'save')
                if obj.plt_switch.executemode == 2
                    obj.execute_planner(obj.planner);
                end
                obj.execute_save(varargin{:});
            elseif obj.plt_switch.executemode == 1
                obj.execute_immediately(func, varargin{:});
            end
        end
        function execute_immediately(obj, func, varargin)
            obj.(sprintf('execute_%s', func))(varargin{:});
        end
        %% execute planner (reproduce a plot)
        function execute_planner(obj, planner)
            obj.execute_figure(planner.fig);
            obj.execute_update_preaxes(planner);
            for i = 1:planner.fig.n_axes
                obj.ax(i);
                obj.execute_planner_axes(planner.axes{i});
            end
            obj.execute_update_postaxes(planner);
%             obj.param_plt = obj.fig.restore_param_plt;
        end
        function execute_planner_axes(obj, ax)
%             input_setfig = W.struct2cell(ax.custom_axes);
%             obj.setfig_ax(input_setfig{:});
            for pi = 1:length(ax.plots)
                tp = ax.plots{pi};
                obj.execute_immediately(tp.func, tp.plotdata, tp.plotparams);
            end
            obj.execute_update_axes(ax.custom_axes);
        end
    end
end