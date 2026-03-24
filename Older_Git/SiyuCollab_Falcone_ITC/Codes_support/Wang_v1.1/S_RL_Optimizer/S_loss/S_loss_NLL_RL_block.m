classdef S_loss_NLL_RL_block < S_loss_base_NLL
    methods
        %% calculate log likelihood block
        function [NLL] = loss(~, params, model, data, logprob_inf)   
            if ~exist('logprob_inf', 'var') || isempty(logprob_inf)
                logprob_inf = -999;
            end 
            % data block x feature
            n_block = size(data, 1);
            n_trial = size(data.action, 2);
            model.set_params(params); % turn array of parameters into names
            p = nan(n_block, n_trial);
            model.RL_reset();
            for bi = 1:n_block
                tdata = data(bi,:);
                tdata = W.tab_block2trial(tdata, n_trial);
                if ismethod(model, 'reset_block') 
                    model.RL_reset_block();
                end
                for i = 1:n_trial
                    % episodic tasks
                    [cp] = model.RL_policy(tdata(i,:));
                    p(bi, i) = cp(tdata.action(i));
                    model.RL_update(tdata(i,:));
                end
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
            nTrial = size(data,1) * size(data.action, 2);
            output.aic = W_AICBIC.aic_mean(output.LL, length(output.params), nTrial);
            output.bic = W_AICBIC.bic_mean(output.LL, length(output.params), nTrial);
        end
    end
end