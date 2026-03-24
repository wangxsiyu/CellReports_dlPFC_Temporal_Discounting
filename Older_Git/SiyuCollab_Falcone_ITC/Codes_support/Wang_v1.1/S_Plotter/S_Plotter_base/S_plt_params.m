classdef S_plt_params < handle	
    properties
        param_plt
        S_pltparams
    end
    methods
        function obj = S_plt_params()
            obj.S_pltparams = SW_plot_parameters;
            obj.load_S_params();
        end
        function load_S_params(obj, param, varargin)
            if ~exist('param', 'var') || isempty(param)
                param = 'default';
            end
            if W.is_stringorchar(param)
                param = obj.S_pltparams.(param);
            end
            obj.param_plt = param;
            obj.param_scale(varargin{:});
        end
        function param_scale(obj, ratio, ratiofont)
            if ~exist('ratio', 'var') || isempty(ratio)
                ratio = 1;
            end
            if ~exist('ratiofont', 'var')|| isempty(ratiofont)
                ratiofont = ratio;
            end
            param = obj.param_plt;
            fnms = W.fieldnames(param);
            id_font = contains(fnms, 'font');
            t1 = W.struct_sub(param, fnms(id_font));
            t2 = W.struct_sub(param, fnms(~id_font));
            param1 = structfun(@(x)x * ratiofont, t1, 'UniformOutput', false);
            param2 = structfun(@(x)x * ratio, t2, 'UniformOutput', false);
            obj.param_plt = W.struct_merge(param1, param2);
        end        
    end
end