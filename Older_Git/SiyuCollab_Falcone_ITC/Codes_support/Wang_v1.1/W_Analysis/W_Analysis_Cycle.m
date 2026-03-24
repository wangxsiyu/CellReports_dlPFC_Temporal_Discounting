classdef W_Analysis_Cycle < handle
    methods(Static)
        %% a % b - set 0 to b
        function out = mod0(a,b,varargin)
            out = mod(a,b,varargin{:});
            if any(out == 0,'all')
                out(out == 0) = b;
            end
        end
        function a = cycle_fwd(a, n)
            a = W.mod0(a+1, n);
        end
        function a = cycle_bwd(a, n)
            a = W.mod0(a-1, n);
        end
        function lst = cycle_arange(a, b, n)
            if b >= a
                lst = a:b;
            else
                lst = [a:n 1:b];
            end
        end
        function dis = cycle_dist(a, b, n)
            if b >= a
                dis = b - a;
            else
                dis = (n - a) + b;
            end
        end
    end
end