classdef S_plt_planner_plot < S_plt_planner_core
    methods
        function plot(obj, x, y, errbar, type, varargin)
            % x/y = array[line x points] or {line1, line2, line3, etc}
            % ----------- unify input format
            if ismatrix(y) % turn all lines to cell format
                y = W.arrayfun(@(t)y(t, :), 1:size(y,1), false);
            end
            if ~exist('x','var') || isempty(x)
                x = 1:length(y{1});
            end
            if ismatrix(x)
                x = W.arrayfun(@(t)x(t, :), 1:size(x,1), false);
            end
            if length(x) == 1
                x = repmat(x, 1, length(y));
            end

            if ~exist('errbar', 'var') || isempty(errbar)
                errbar = repmat({[]}, 1, length(y));
            elseif exist('errbar', 'var') && ismatrix(errbar)
                errbar = W.arrayfun(@(t)errbar(t, :), 1:size(errbar,1), false);
            end

            % ----------- get plot type
            if ~exist('type', 'var') || isempty(type)
                type = 'line';
            end
            plotdata = W.struct('x', x, 'y', y, ...
                'errorbar', errbar);
            plotparams = W.struct('plottype', type, 'varargin', varargin);
            obj.planner.axes{obj.axi}.plots{end+1} = W.struct('func', 'plot', ...
                'plotdata', plotdata, 'plotparams', plotparams);
            obj.execute('plot', plotdata, plotparams);
        end
        function dashY(obj, x, yrg, varargin)
            if ~exist('yrg', 'var') || isempty(yrg)
                yrg = ylim;
            end
            plotdata = W.struct('x', [x x], 'y', yrg(:));
            plotparams = W.struct('varargin', varargin);
            obj.planner.axes{obj.axi}.plots{end+1} = W.struct('func', 'dashXY', ...
                'plotdata', plotdata, 'plotparams', plotparams);
            obj.execute('dashXY', plotdata, plotparams);
        end
        function dashX(obj, y, xrg, varargin)
            if ~exist('xrg', 'var') || isempty(xrg)
                xrg = xlim;
            end
            plotdata = W.struct('x', xrg(:), 'y', [y y]);
            plotparams = W.struct('varargin', varargin);
            obj.planner.axes{obj.axi}.plots{end+1} = W.struct('func', 'dashXY', ...
                'plotdata', plotdata, 'plotparams', plotparams);
            obj.execute('dashXY', plotdata, plotparams);
        end
    end
end