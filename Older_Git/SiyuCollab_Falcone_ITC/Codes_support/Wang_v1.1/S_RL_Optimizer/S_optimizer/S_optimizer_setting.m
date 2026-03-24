classdef S_optimizer_setting < handle
    properties
        option_optimizer
        optimizer
    end
    methods
        function obj = S_optimizer_setting()
            obj.setup_optimizer('fmincon');
        end
        function setup_optimizer(obj, optimizer, varargin)
            obj.optimizer = optimizer;
            switch optimizer
                case 'fmincon'
                    opt = W.struct('optimizer_options', [], ...
                        'bound_inf', 99, ...
                        'repeat', 1, ...
                        'exitflags', []);
            end
            obj.option_optimizer = W.struct_set(opt, varargin{:});
        end
    end
end