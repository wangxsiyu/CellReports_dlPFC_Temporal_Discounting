classdef S_RL_evaluator < S_handle
    methods
        function [LV, datanew] = evaluate_model_on_data(obj, params, model, data, is_simulate)
            % combinations
            % is_simulate  is_matchdata
            %       1           0            simulate both choice and observation  
            %       1           1            simulate choice, not observation 
            %       0           ~            goodness of fit to data
            n_trial = size(data, 1);
            model.set_params(params);
            if is_simulate
                assert(isobject(obj.env), 'load env first');
                env = obj.env;
            end
            % generate data
            datanew = cell(1, n_trial);
%             simu_choice = nan(n_trial, 1);
%             simu_reward = nan(n_trial, 1);
            LVs = cell(1, n_trial);
            for i = 1:n_trial
                tdata = data(i, :);
                if is_simulate 
                    env.set_observation(tdata);
                end
                if i == 1 || tdata.resetID
%                     if is_simulate
%                         env.reset(tdata);
%                     end
                    model.reset();
                end
                if i == 1 || data.blockID(i) ~= data.blockID(i-1)
                    if ismethod(model, 'reset_block')
                        model.reset_block();
                    end
%                     if is_simulate && ismethod(env, 'reset_block')
%                         env.reset_block(tdata);
%                     end
                end
%                 if is_simulate && ismethod(env, 'reset_trial')
%                     env.reset_trial(tdata);
%                 end
                [cp] = model.RL_policy(tdata);
%                 if any(isnan(cp))
%                     simu_choice = NaN; % why does this occur?
%                 else
%                     simu_choice = model.sample_action(cp);
%                 end
                if is_simulate
                    tdata.action = model.sample_actions(cp);
                end
                tchoice = tdata.action;
%                 latentvariables.is_simulated = is_simulate + 0;
%                 latentvariables.action = tchoice;
                p = cp(tchoice);                
                if ismethod(model, 'format_output')
                    tLV = model.format_output();
                else
                    tLV = model.latentvariables;
                end
                LVs{i} = W.struct_set(tLV, ...
                    'action_likelihood', p, ...
                    'LLtrial', log(p));
%                 end

                if is_simulate
                    [simu_reward] = env.step(simu_choice);
                    tdata.reward = simu_reward;
                end
%                 treward = tdata.reward;
                model.update(tdata);
%                 tdata = struct2table(tdata, 'AsArray',true);
                datanew{i} = tdata;
            end
            
%             datanew.action = simu_choice;
%             datanew.reward = simu_reward; 
            
            datanew = W.tab_vertcat(datanew{:});
            LV = W.cellofstruct2table(LVs);
%             %% round
%             LV = W.tab_roundfloats(LV, 3);
%             if ismini && istable(LV)
%                 LV = LV(:, ["action_dist", "action_likelihood", "simuchoice", "action", "is_simulated"]);
%             end
        end
    end
end