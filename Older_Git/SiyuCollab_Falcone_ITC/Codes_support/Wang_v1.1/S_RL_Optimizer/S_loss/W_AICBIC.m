classdef W_AICBIC < handle
    methods(Static)
        function a = aic(LL, nParam)
            a = (-2 * LL) + (2 * nParam); 
        end
        function a = aic_mean(LL, nParam, nTrial)
            LL = LL * nTrial;
            a = (-2 * LL) + (2 * nParam); 
        end
        function b = bic(LL, nParam, nTrial)
            b = (-2 * LL) + (nParam * log(nTrial));
        end
        function b = bic_mean(LL, nParam, nTrial)
            LL = LL * nTrial;
            b = (-2 * LL) + (nParam * log(nTrial));
        end        
    end
end