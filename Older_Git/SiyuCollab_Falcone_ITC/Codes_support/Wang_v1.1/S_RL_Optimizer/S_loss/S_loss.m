classdef S_loss < handle
    properties
        loss_obj
        loss_func
        loss_func_data
    end
    methods
        function obj = S_loss()
            obj.set_loss_mode('NLL_RL');
        end
        function set_loss_mode(obj, loss_mode)
            obj.loss_obj = eval(sprintf('S_loss_%s()', loss_mode));
        end
        function [loss, lossdata] = get_loss_func(obj, model, varargin)
            [loss_mode, vars] = W.varargin_get_endoptions('loss_mode', varargin{:});
            if ~W.isempty(loss_mode)
                obj.set_loss_mode(loss_mode.loss_mode);
            end                
            lossobj = obj.loss_obj;
            loss = @(x)lossobj.loss(x, model, vars{:});
            lossdata = @(x, data)lossobj.loss(x, model, data, vars{2:end}); % the first element should be data
            obj.loss_func = loss;
            obj.loss_func_data = lossdata;
        end
    end
end