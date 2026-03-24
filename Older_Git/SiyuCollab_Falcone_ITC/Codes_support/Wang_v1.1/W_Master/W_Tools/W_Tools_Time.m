classdef W_Tools_Time < handle
    methods(Static)
        %% same as datetime, but with extra string parts included
        function str = str_datetime(str, varargin)
            str = W.string(str);
            [~, idxnum] = arrayfun(@(x)W.str_select(x, 'digit'), str, 'UniformOutput', false);
            digits = W.arrayfun(@(x)str{x}(idxnum{x}), 1:length(str));
            [strs] = cellfun(@(x)W.str_select(x, '!digit'), str, 'UniformOutput', false);
            strs = W.cellfun(@(x)W.iif(iscell(x), x, {x}), strs, false);
            newdigits = W.cellfun(@(x)W.datetime(x, varargin{:}), digits);
            str = arrayfun(@(x)string(strcat(strs{x}{1}, newdigits{x}, strs{x}{2:end})), 1:length(str));
        end
        %% datetime format change
        function out = datetime(str, informat, outformat, yrhead)
            if ~exist('yrhead', 'var')
                yrhead = '20';
            end
            % can have "dd", "mm", "yyyy" or "yy"
            % and "HH", "MM", "SS"
            str = char(str);
            str = str(W.func('W.str_select', 2, str));
            informat = char(informat);
            outformat = char(outformat);
            dd = str(informat == 'd');
            mm = str(informat == 'm');
            yy = str(informat == 'y');
            HH = str(informat == 'H');
            MM = str(informat == 'M');
            SS = str(informat == 'S');
            if length(yy) == 2
                yy = [yrhead, yy];
            end
            out = outformat;
            if any(outformat == 'd')
                out(outformat == 'd') = dd;
            end
            if any(outformat == 'm')
                out(outformat == 'm') = mm;
            end
            if any(outformat == 'S')
                out(outformat == 'S') = SS;
            end
            if any(outformat == 'M')
                out(outformat == 'M') = MM;
            end
            if any(outformat == 'H')
                out(outformat == 'H') = HH;
            end
            if sum(outformat == 'y') == 2
                yy = yy(3:end);
            end
            out(outformat == 'y') = yy;
        end
    end
end