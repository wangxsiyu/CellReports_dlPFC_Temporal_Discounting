classdef S_plt_planner_stats < S_plt_planner_core
    methods
        function sigstar(obj, x, y, p, varargin)
            opt = struct('dx',0, 'dy',0);
            [opt, vars] = W.struct_set_endoptions(opt, varargin{:});
            dx = opt.dx;
            dy = opt.dy;
            strp = obj.getstatstars(p);
            len = W.cell_length(strp);
            dx = dx * (len)/2;
            plotdata = W.struct('x', x + dx, 'y', y + dy, 'strp', strp);
            plotparams = W.struct('varargin', vars);
            obj.planner.axes{obj.axi}.plots{end+1} = W.struct('func', 'sigstar', ...
                'plotdata', plotdata, 'plotparams', plotparams);
            obj.execute('sigstar', plotdata, plotparams);
        end
        
        function out = getstatstars(~, p0, option, nons)
            if ~exist('option','var') || isempty(option)
                option = 'stars'; %value
            end
            if ~exist('nons', 'var') || isempty(nons) || all(isnan(nons))
                nons = ' ';%'n.s.';
            end
            out = cell(size(p0));
            for i = 1:numel(p0)
                p = p0(i);
                if p<=1E-3
                    stars='***';
                elseif p<=1E-2
                    stars='**';
                elseif p<=0.05
                    stars='*';
                elseif p > 0.05
                    stars = nons;
                elseif isnan(p)
                    stars = 'n.a.';
                else
                    stars=' ';
                end
                if strcmp(option, 'value')
                    out{i} = sprintf("%.3f", p);
                else
                    out{i} = string(stars);
                end
            end
        end
    end
end