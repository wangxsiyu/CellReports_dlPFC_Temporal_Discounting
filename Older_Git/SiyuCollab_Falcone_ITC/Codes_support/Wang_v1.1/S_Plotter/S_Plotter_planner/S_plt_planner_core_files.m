classdef S_plt_planner_core_files < S_plt_executor
    methods
        function save(obj, varargin)
            obj.execute('save', varargin{:});
        end
    end
end