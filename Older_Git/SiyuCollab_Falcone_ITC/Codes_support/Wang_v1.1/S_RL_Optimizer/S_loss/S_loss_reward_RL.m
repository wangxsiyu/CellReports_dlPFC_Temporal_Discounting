classdef S_loss_reward_RL < S_loss_base
    methods
        %% calculate log likelihood
        function [NLL] = loss(~, params, model, data)
            % data trial x feature
            n_trial = size(data, 1);
            model.set_params(params); % turn array of parameters into names
            r = nan(1, n_trial);
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
                ta = model.sample_actions(cp);
                r(i) = tdata.rewards(ta);
                tdata.action = ta;
                tdata.reward = r(i);
                model.RL_update(tdata);
            end
            NLL = -mean(r);
        end
    end
end