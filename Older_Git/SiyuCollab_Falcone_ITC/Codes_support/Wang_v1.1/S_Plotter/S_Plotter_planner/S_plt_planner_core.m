classdef S_plt_planner_core < S_plt_planner_core_figure & ...
        S_plt_planner_core_aesthetics & ...
        S_plt_planner_core_files 
    properties
        % planner
        %   fig:  custom_fig
        %   axes: custom_axes, plots
        %   operations: list of operations
    end
    methods
        function obj = S_plt_planner_core()
            obj.reset_planner();
        end
        function reset_planner(obj)
            fig = struct('custom_fig', struct('ABClabels', []));
            obj.planner = W.struct('fig', fig, 'axes', {});
        end
    end
end