classdef S_plt_colors < handle
    properties
        S_colors
    end
    methods
        function obj = S_plt_colors()
            obj.S_colors = SW_colors;
        end
        function col = interpolatecolors(obj, cols, vals, x)
            cols = obj.translate_colors(cols);
            col = [0 0 0];
            for i = 1:3 % loop over RGB
                tcol = cellfun(@(x)x(i), cols);
                col(i) = interp1q(W.vert(vals), W.vert(tcol), x);
            end
        end
        function col = translate_colors(obj, col)
            if isempty(col)
                return;
            end
            col = W.str2cell(col);
            id_str = cellfun(@(x)W.is_stringorchar(x), col);
            if any(id_str)
                col(id_str) = W.cellfun(@(x)obj.str2color(x), col(id_str), false);
            end
        end
        function col = str2color(obj, str)
            str = char(str);
            [num, idx] = W.str_select(str);
            if isnan(num)
                num = 100;
            end
            str = str(~idx);
            try
                col = obj.S_colors.(str);
            catch
                col = [0,0,0];
                W.warning('color %s not found, use black instead', str);
            end
            col = col * num/100 + (1-num/100) * [1 1 1];
        end
    end
end