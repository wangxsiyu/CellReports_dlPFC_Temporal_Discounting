classdef S_loss_NLL_RL < handle
    methods
        %% calculate log likelihood
        function [NLL] = loss(~, params, model, data, logprob_inf)  
            if ~exist('logprob_inf', 'var') || isempty(logprob_inf)
                logprob_inf = -999;
            end
            % data trial x feature
            n_trial = size(data, 1);
            model.set_params(params); % turn array of parameters into names
            p = nan(1, n_trial);
            for i = 1:n_trial
                tdata = data(i,:);
                if i == 1 || tdata.resetID
                    model.RL_reset();
                end
                % episodic tasks
                if ismethod(model, 'reset_block') && (i == 1 || data.blockID(i) ~= data.blockID(i-1))
                    model.RL_reset_block();
                end
                [cp] = model.RL_policy(tdata);
                p(i) = cp(tdata.action);
                model.RL_update(tdata);
            end
            logp = log(p);
            logp(isinf(logp)) = logprob_inf;
            LL = mean(logp, 'all', 'omitnan');
            if isnan(LL)
                W.warning('all NaNs in loglikelihood:');
                disp(model.params);
            end
            NLL = -LL;
        end
        function output = format_output(obj, output, data)
            output.LL = -output.loss;
            output.L = exp(output.LL);
            nTrial = size(data, 1);
            output.aic = W_AICBIC.aic_mean(output.LL, length(output.params), nTrial);
            output.bic = W_AICBIC.bic_mean(output.LL, length(output.params), nTrial);
        end
    end
end