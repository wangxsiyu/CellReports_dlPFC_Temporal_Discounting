classdef model_YP_time < S_RL_model
    methods
        function obj = model_YP_time()
            obj.name_parameters = {'beta', 'k', 'value_future', 'timeYP'};
            obj.X0 = [NaN, NaN, 0, 0];
            NMAX = inf;
            obj.LB = [0, 0, -NMAX, -NMAX];
            obj.UB = [NMAX, NMAX, NMAX, NMAX];
        end
        function cp = policy(obj, data)
            params = obj.params;
            VF = params.value_future;
            func = @(R, D) R/(1 + params.k * D);
            D = data.delay;
            R = data.drop;
            tYP = params.timeYP;
            if data.is_yellow_1st
                V2 = func(VF, 0); % reject in yellow
                V1_future = func(VF, D + tYP); % accept in purple
                V1_now = func(R, D + tYP); % accept in purple
            else
                V2 = func(VF, tYP); % reject in yellow
                V1_future = func(VF, D); % accept in purple
                V1_now = func(R, D); 
            end
            V1 = V1_now + V1_future;
            cp = W.softmax_binary(V1, V2, params.beta);
        end
    end
end