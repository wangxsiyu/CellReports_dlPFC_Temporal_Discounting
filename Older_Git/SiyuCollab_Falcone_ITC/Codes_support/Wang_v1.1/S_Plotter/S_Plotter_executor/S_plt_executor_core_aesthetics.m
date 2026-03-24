classdef S_plt_executor_core_aesthetics < S_plt_base
    methods
        %% update figure
        function execute_update(obj, planner)
            obj.execute_update_preaxes(planner);
            %%
            fig = obj.fig;
            for axi = 1:fig.n_axes
                set(fig.g,'CurrentAxes',fig.axes(axi));
                obj.execute_update_axes(planner.axes{axi}.custom_axes, planner.fig.param_plt, ...
                    axi);
            end
            %%
            obj.execute_update_postaxes(planner);
            obj.param_plt = obj.fig.restore_param_plt;
        end
        function execute_update_preaxes(obj, planner)
            %% calculate additional cache
            xlms = W.arrayfun(@(x)get(x, 'xlim'), obj.fig.axes, false);
            xlms = vertcat(xlms{:});
            obj.fig.cache.xlm_all = [min(xlms(:,1)), max(xlms(:,2))];
            ylms = W.arrayfun(@(x)get(x, 'ylim'), obj.fig.axes, false);
            ylms = vertcat(ylms{:});
            obj.fig.cache.ylm_all = [min(ylms(:,1)), max(ylms(:,2))];
        end
        function execute_update_postaxes(obj, planner)
            %% link axes
            id = W.cellfun(@(x)isstruct(x.custom_axes) && any(contains(W.fieldnames(x.custom_axes), 'linkaxes')) && x.custom_axes.linkaxes, planner.axes);
            obj.fig.cache.hlink = linkprop(arrayfun(@(x)ancestor(x, 'axes'), obj.fig.axes(id)),{'CameraPosition','CameraUpVector'});
            %% addABC
            offset_addABCs = arrayfun(@(x)planner.fig.custom_fig.addABCs_offset_title(planner.fig.xy == x), ...
                1:obj.fig.n_axes);
            obj.execute_addABCs(planner.fig.custom_fig.ABClabels, offset_addABCs, planner.fig.param_plt);
        end
        function execute_update_axes(obj, custom_axes, param_plt, axi)
            if ~exist('param_plt', 'var') || isempty(param_plt)
                param_plt = obj.param_plt;
            end
            if isempty(custom_axes)
                return;
            end
            % set font size
            set(gca, 'FontSize', param_plt.fontsize_axes);
            fnms = fieldnames(custom_axes);
            for fi = 1:length(fnms)
                switch fnms{fi}
                    case 'xlim'
                        if ~isempty(custom_axes.xlim)
                            xlm = custom_axes.xlim;
                            xlm(isnan(xlm)) = obj.fig.cache.xlm_all(isnan(xlm));
                            xlim(xlm);
                        end
                    case 'ylim'
                        if ~isempty(custom_axes.ylim)
                            ylm = custom_axes.ylim;
                            ylm(isnan(ylm)) = obj.fig.cache.ylm_all(isnan(ylm));
                            ylim(ylm);
                        end
                    case 'xlabel'
                        custom_axes.xlabel = W.str_capitalize1(custom_axes.xlabel);
                        xlabel(custom_axes.xlabel, 'FontSize', param_plt.fontsize_label);
                    case 'ylabel'
                        custom_axes.ylabel = W.str_capitalize1(custom_axes.ylabel);
                        ylabel(custom_axes.ylabel, 'FontSize', param_plt.fontsize_label);
                    case 'zlabel'
                        custom_axes.zlabel = W.str_capitalize1(custom_axes.zlabel);
                        zlabel(custom_axes.zlabel, 'FontSize', param_plt.fontsize_label);
                    case 'title'
                        custom_axes.title = W.str_capitalize1(custom_axes.title);
                        custom_axes.title = W.str_de_(custom_axes.title);
                        title(custom_axes.title,'FontWeight','normal','FontSize', param_plt.fontsize_title);
                    case 'xtick'
                        if isfield(custom_axes, 'xticklabel')
                            set(gca,'XTick', custom_axes.xtick, 'XTickLabel', custom_axes.xticklabel);
							
							% myLabels = { '1', '2', '3', '4'; 
							%	'Line2a', 'Line2b', 'Line2c', 'Line2d';
							%	'Line-THREE', 'Line-THREE', 'Line-THREE', 'Line-THREE' };
							%for i = 1:length(myLabels)
							%	text(i, ax.YLim(1), sprintf('%s\n%s\n%s', myLabels{:,i}), ...
							%		'horizontalalignment', 'center', 'verticalalignment', 'top');    
							%end
							%ax.XLabel.String = sprintf('\n\n\n%s', 'X-Axis Label');
                        else
                            set(gca,'XTick', custom_axes.xtick);
                        end
                    case 'xtickangle'
                        xtickangle(custom_axes.xtickangle);
                    case 'ytick'
                        if isfield(custom_axes, 'yticklabel')
                            set(gca,'YTick', custom_axes.ytick, 'YTickLabel', custom_axes.yticklabel);
                        else
                            set(gca,'YTick', custom_axes.ytick);
                        end
                    case 'legend'
                        if isfield(custom_axes, 'legloc')
                            legloc = custom_axes.legloc;
                        else
                            legloc = 'NorthEast';
                        end
                        leg = custom_axes.legend;
                        %                             leg = W.str_de_(leg);
                        %                             leg = W.str_capitalize1(leg);
                        leglist = obj.fig.object_list{axi};
                        if length(leg) == length(leglist)
                            if isfield(custom_axes, 'legord')
                                leg = leg(custom_axes.legord);
                                leglist = leglist(custom_axes.legord);
                            end
                            tpos = get(obj.fig.axes(axi), 'position');
                            legend(leglist, leg, 'Location', legloc, ...
                                'FontSize', param_plt.fontsize_leg);
                            if isfield(custom_axes, 'legboxon')
                                legend('boxon');
                            else
                                legend('boxoff');
                            end
                            set(obj.fig.axes(axi), 'position', tpos);
                        elseif length(leg) > 0
                            W.warning('W_plt.update: axes #%d legend ignored, number of legend entries != number of plots', axi);
                        end
                    case {'xticklabel', 'yticklabel','legloc','legord', 'linkaxes'}
                        % skip, these are dealt with in xtick/ytick, legend/legord
                    otherwise
                        W.warning('W_plt.update: unused param %s', fnms{fi});
                end
            end
        end
        function execute_addABCs(obj, abcString, offset_addABCs, param_plt)
            if ~exist('param_plt', 'var') || isempty(param_plt)
                param_plt = obj.param_plt;
            end
            offset_addABCs = offset_addABCs * param_plt.addABCs_offset_title;
            offset = param_plt.addABCs_offset + zeros(obj.fig.n_axes, 1);
            if exist('offset_addABCs', 'var') && ~isempty(offset_addABCs)
                offset(:,2) = offset(:,2) + offset_addABCs';
            end
            if ~exist('abcString', 'var') || isempty(abcString)
                if ~obj.plt_switch.addABCs
                    return;
                end
                abcString = ['ABCDEFGHIJKLMNOPQRSTUVWXYZ'];
            end
            ax = obj.fig.axes;
            fontsize = param_plt.fontsize_title;
            nABC = length(abcString);
            for i = 1:length(ax)
                pos(i,:) = get(ax(i), 'position');
            end
            ABCpos = [pos(:,1) pos(:,2)+pos(:,4)];
            ABCpos = ABCpos + offset;
            for i = 1:length(ax)
                tb = annotation('textbox');
                set(tb, 'fontsize', fontsize, 'fontweight', 'normal', ...
                    'margin', 0, 'horizontalAlignment', 'center', ...
                    'verticalAlignment', 'middle', 'lineStyle', 'none')
                set(tb, 'fontunits', 'pixels')
                fs = get(tb, 'fontsize');
                set(tb, 'fontunits', 'points')
                
                ii = i;
                tstr = '';
                while ii > 0
                    tres = W.mod0(ii, nABC);
                    tstr = [abcString(tres), tstr];
                    ii = (ii - tres)/nABC;
                end

                set(tb, 'string', tstr)
                rec = [ABCpos(i,1), ABCpos(i,2), fs, fs];
                set(tb, 'Units','pixels', 'position', rec)
            end
        end
    end    
end