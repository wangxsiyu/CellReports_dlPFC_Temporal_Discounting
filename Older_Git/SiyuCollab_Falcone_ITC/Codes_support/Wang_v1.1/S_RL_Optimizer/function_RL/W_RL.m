classdef W_RL < handle
     properties
     end
     methods(Static)
         function p = softmax_binary(v1, v2, beta)
             if isempty(v2)
                 dq = v1;
             else
                 dq = v2 - v1;
             end
             p = 1./(1 + exp(-dq * beta));
             p = [1-p, p];
         end
         function p = softmax_binary_bias(v1, v2, beta, bias)
             if isempty(v2)
                 dq = v1;
             else
                 dq = v2 - v1;
             end
             dq = dq + bias;
             p = 1./(1 + exp(-dq * beta));
             p = [1-p, p];
         end
     end
end