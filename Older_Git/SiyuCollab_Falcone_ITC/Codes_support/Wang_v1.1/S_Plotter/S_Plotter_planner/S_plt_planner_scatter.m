classdef S_plt_planner_scatter < S_plt_planner_core
    methods
        function scatter(obj, x, y, type, varargin) 
            x = W.vert(x);
            y = W.vert(y);
            idnan = isnan(x) | isnan(y);
            x = x(~idnan);
            y = y(~idnan);
            if isempty(x) || isempty(y)
                W.warning('scatter: all Nans');
                return;
            end
            % ----------- get plot type
            if ~exist('type', 'var') || isempty(type)
                type = 'dot';
            end
            plotdata = W.struct('x', x, 'y', y);
            plotparams = W.struct('plottype', type, 'varargin', varargin);
            obj.planner.axes{obj.axi}.plots{end+1} = W.struct('func', 'scatter', ...
                'plotdata', plotdata, 'plotparams', plotparams);
            obj.execute('scatter', plotdata, plotparams);
        end
    end
end