classdef W_Analysis_Average < handle
    methods(Static)
        %% basic
        function [av, se, n] = avse(a, ismedian)
            if ~exist('ismedian', 'var') || isempty(ismedian)
                ismedian = false;
            end
            if ismedian
                av = median(a, 1, 'omitnan');
                n = sum(~isnan(a),1);
                se = av * NaN;
            else
                av = mean(a,1,'omitnan');
                n = sum(~isnan(a),1);
                se = std(a,[],1,'omitnan')./sqrt(n);
            end
        end
    end
end