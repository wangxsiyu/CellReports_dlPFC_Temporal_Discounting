classdef S_optimizer < S_optimizer_fmincon & S_loss
    methods
        function output = optimize_model(obj, loss, model, varargin)
            W.print('fitting model: %s', model.name);
            tic
            if ~isempty(loss) && W.is_stringorchar(loss)
                obj.set_loss_mode(loss);
            end
            loss_fun = obj.get_loss_func(model, varargin{:});
            switch obj.optimizer
                case 'fmincon'
                    output = obj.fmincon(loss_fun, model.X0, model.LB, model.UB);
            end
            output.time_MLE = toc;
            output.model = model;
            W.print('elapsed time: %.2f', output.time_MLE);
            output = obj.format_output(output);
            output = obj.loss_obj.format_output(output, varargin{:});
        end
        function output = format_output(~, output)
            model = output.model;
            if isprop(model, 'name_parameters') && ~isempty(model.name_parameters) 
                if length(model.name_parameters) == length(output.params)
                    output.params_table = array2table(output.params, 'VariableNames', model.name_parameters);
                else
                    disp(output.params)
                    error('name of parameters does not match the number of parameters');
                end
            end 
        end
    end
end



            
