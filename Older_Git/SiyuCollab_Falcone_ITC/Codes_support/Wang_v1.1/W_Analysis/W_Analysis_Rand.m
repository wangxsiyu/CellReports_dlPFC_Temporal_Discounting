classdef W_Analysis_Rand < handle
    methods(Static)
        function out = randsample_bycond(a, id, n)
            if length(n) == 1
                n = repmat(n, 1, length(id));
            end
            out = W.create_dtype(class(a),0);
            id = W.num2rank(id);
            for i = 1:max(id)
                tid = datasample(find(id == i), n(i), 'Replace', true);
                te = a(tid,:);
                out = vertcat(out, te);
            end
        end
    end
end