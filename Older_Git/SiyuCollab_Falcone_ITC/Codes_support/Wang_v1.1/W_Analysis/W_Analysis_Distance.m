classdef W_Analysis_Distance < handle
    methods(Static)
        function dist = dist_L2(x, y)
            dist = sum((x - y).^2);
        end
    end
end