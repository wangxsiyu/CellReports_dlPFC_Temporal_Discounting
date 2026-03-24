classdef S_optimizer_fmincon < S_optimizer_setting
    properties
        % optimizer setting
        %         optimizer_options
        %         repeat
        %         exit_condition 
        %         bound_inf % replace inf with this number
        %         logprob_inf
    end
    methods
        %% initial value
        function [X0] = fmincon_X0(~, LB, UB, X0opt, iteri)
            if ~exist('X0opt', 'var') || isempty(X0opt)
                X0opt = NaN(1, length(LB));
            end
            if ~iscell(X0opt)
                X0opt = W.arrayfun(@(x)x, X0opt, false);
            end
            X0 = NaN(1, length(LB));
            for i = 1:length(LB)
                if isnumeric(X0opt{i})
                    if length(X0opt{i}) > 1 % specify X0 for each round
                        X0(i) = X0opt{i}(iteri);
                    else
                        X0(i) = X0opt{i};
                    end
                    if isnan(X0(i)) % random sample
                        X0(i) = (UB(i) - LB(i)) .* rand + LB(i);
                    end
                else % use a function to generate X0
                    func = W.str2func(X0opt{i});
                    X0(i) = func(iteri);
                end
            end
        end
        %% fit model
        function [output] = fmincon(obj, lossfun, X0opt, LB, UB)
            opt = obj.option_optimizer;
            UB(isinf(UB)) = sign(UB(isinf(UB))) * opt.bound_inf;
            LB(isinf(LB)) = sign(LB(isinf(LB))) * opt.bound_inf;
            vobj = Inf;
            exitflag = NaN;
            params_fit = [];
            lossfun = W.str2func(lossfun);
            for i = 1:opt.repeat
%                 try
                X0 = obj.fmincon_X0(LB, UB, X0opt, i);
                [txfit, tvobj, tflag, ~, ~, ~, hessian] = fmincon(lossfun, X0, [],[],[],[], LB, UB, opt.optimizer_options);
%                 catch
%                     tnll = Inf;
%                     tflag = NaN;
%                 end
                if tvobj < vobj
                    vobj = tvobj;
                    params_fit = txfit;
                    exitflag = tflag;
                end
                if ~isempty(opt.exitflags) && ismember(exitflag, opt.exitflags)
                    break;
                end
            end
            output = W.struct('params', params_fit, 'exitflag', exitflag, 'loss',vobj, 'hessian', hessian);
        end
    end
end