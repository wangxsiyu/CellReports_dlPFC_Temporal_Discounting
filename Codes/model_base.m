classdef model_base < S_RL_model
    methods
        function obj = model_base()
            obj.name_parameters = {'beta', 'k', 'thres'};
            obj.X0 = [NaN, NaN, 0];
            NMAX = inf;
            obj.LB = [0, 0, -NMAX];
            obj.UB = [NMAX, NMAX, NMAX];
        end
        function [cp, LV] = policy(obj, params, LV, data)
            D = data.delay;
            R = data.drop;
            DV = R/(1 + params.k * D);
%             cp = W_RL.softmax_binary(DV, params.thres, params.beta);
            cp = 1./(1 + exp(-params.beta * DV - params.thres));
            cp = [1-cp, cp];
            LV.DV = DV;
        end
    end
end