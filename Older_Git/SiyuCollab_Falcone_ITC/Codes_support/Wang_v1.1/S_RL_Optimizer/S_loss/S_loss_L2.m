classdef S_loss_L2 < S_loss_base
    methods
        function loss = loss(~, params, model, y, varargin)
            model.set_params(params);
            ypred = model.predict(varargin{:});
            loss = sum((y - ypred).^2, [], 'omitnan');
        end
    end
end