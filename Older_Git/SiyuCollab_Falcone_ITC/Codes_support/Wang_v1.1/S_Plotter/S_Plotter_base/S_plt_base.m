classdef S_plt_base < S_plt_files & ...
        S_plt_colors & ...
        S_plt_params & ...
        S_handle & ...
        matlab.mixin.Copyable
    properties
        custom_vars
        plt_switch
    end
    properties(Access = protected)
        fig
        planner
        axi
    end
    methods
        function obj = S_plt_base()
            obj.custom_vars = struct;
            obj.plt_switch = W.struct('isshow', true, 'addABCs', false, 'executemode', 1);
        end
        function set_execute_mode(obj, i)
            obj.plt_switch.executemode = i;
        end
        function set_custom_variables(obj, varargin)
            obj.custom_vars = W.struct_set(obj.custom_vars, varargin{:});
        end
        function set_plt_switch(obj, varargin)
            obj.plt_switch = W.struct_set(obj.plt_switch, varargin{:});
        end
    end
end

