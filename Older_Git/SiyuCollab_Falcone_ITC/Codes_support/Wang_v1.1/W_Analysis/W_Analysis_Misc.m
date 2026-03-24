classdef W_Analysis_Misc < handle
    methods(Static)
        function H = entropy_bernoulli(ps)
            H = NaN(size(ps));
            for i = 1:length(ps)
                p = ps(i);
                if p == 0 || p == 1
                    H(i) = 0;
                else
                    H(i) = (-p*log(p)-(1-p)*log(1-p))/log(2);
                end
            end
        end
        %% turn numbers into ranks
        function out = num2rank(a)
            val = unique(a);
            out = arrayfun(@(x)find(x == val), a);
        end
        %% normalize
        function p = prob_normalize(p)
            p = p ./ sum(p);
        end
        %% bound values
        function a = boundvalue(a, rg)
            a(a < rg(1)) = rg(1);
            a(a > rg(2)) = rg(2);
        end
        %% shuffle
        function v=shuffle(v)
             v=v(randperm(length(v)));
        end
    end
end