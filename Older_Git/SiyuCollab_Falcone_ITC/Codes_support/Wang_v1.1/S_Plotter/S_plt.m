classdef S_plt < S_plt_planner
    properties
    end
    methods
        function obj = S_plt(varargin)
            obj.set_files(varargin{:});
        end
    end
end