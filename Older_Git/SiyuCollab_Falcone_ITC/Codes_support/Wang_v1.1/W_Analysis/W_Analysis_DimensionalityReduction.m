classdef W_Analysis_DimensionalityReduction < handle
    methods(Static)
        function [pcinfo, score] = pca(varargin)
            [pcinfo.coeff, score,~,~, pcinfo.r2, pcinfo.mu] = pca(varargin{:});
        end 
        function newpc = project2pc(pcinfo, newdata)
           newpc = W.decell(W.cellfun(@(x)(x - pcinfo.mu) * pcinfo.coeff, W.encell(newdata)));
        end
    end
end