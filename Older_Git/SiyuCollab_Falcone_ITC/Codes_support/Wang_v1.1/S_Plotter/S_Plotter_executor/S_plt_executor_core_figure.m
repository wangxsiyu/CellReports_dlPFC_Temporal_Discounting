classdef S_plt_executor_core_figure < S_plt_base
    methods
        function obj = S_plt_executor_core_figure()
            obj.fig = [];
        end
    end
    methods(Access = protected)
        %% create figure
        function execute_figure(obj, cache_fig)
            obj.fig.restore_param_plt = obj.param_plt;
            obj.param_plt = cache_fig.param_plt;
            % calculate rect_axes
            [rect, rect_axes] = obj.get_fig_ax_sizes(cache_fig.nx, cache_fig.ny, cache_fig.setting_fig);
            % rect - position of the figure
            % rect_axes - position of the axes

            obj.fig.g = figure('visible', W.iif(obj.plt_switch.isshow, 'on', 'off'));
            set(obj.fig.g, 'Units','pixels','position',rect);
            rect_axes = W.encell(rect_axes);
            obj.fig.n_axes = length(rect_axes);
            obj.fig.axes = [];
            for i = 1:obj.fig.n_axes
                axes('Units', 'pixels', 'position', rect_axes{i});
                obj.fig.axes(i) = gca;
                set(gca, 'tickdir', 'out');
            end
            obj.fig.object_list =  repmat({[]}, 1, obj.fig.n_axes); 
            % plot objects, for legend generation
            obj.fig.cache = struct;
        end
        %% set axes
        function execute_ax(obj, axi)
            set(obj.fig.g, 'CurrentAxes', obj.fig.axes(axi));
        end
    end
    methods(Access = private)
        % figure - calculate rect_axes
        function [rect, rect_axes] = get_fig_ax_sizes(obj, nx, ny, setting_fig)
            [ax_h, ax_w, gap_h, gap_w, figH, figW] = obj.axes_calculate_pos(nx, ny, setting_fig);
            sz = obj.get_screensize();
            rr = max(figH/(sz(4)*0.80), figW/(sz(3)*0.90)); 
            % if doesn't exceed screen size, return 1
            if rr > 1
                obj.param_scale(1/rr);
                [ax_h, ax_w, gap_h, gap_w] = obj.axes_calculate_pos(nx, ny, setting_fig);
            end
            offset = sz(4) * 0.05;
            [rect_axes, rect] = obj.axes_pos2rect(ax_h, ax_w, gap_h, gap_w, setting_fig.matrix_hole, offset);
            % calculate rect
        end
        function [ax_h, ax_w, gap_h, gap_w, figH, figW] = axes_calculate_pos(obj, nx, ny, setting_fig)
            setting_plt = obj.param_plt;
            is_xlab = W.horz(any(setting_fig.matrix_xlabel, 2));
            is_ylab = W.horz(any(setting_fig.matrix_ylabel, 1));
            is_title = W.horz(any(setting_fig.matrix_title, 2));
            ax_h = repmat(setting_plt.pixel_h, 1, nx);
            ax_w = repmat(setting_plt.pixel_w, 1, ny);
            gap_h = [setting_plt.pixel_margin(3), ones(1,nx-1)*setting_plt.pixel_gap_h, setting_plt.pixel_margin(1)] + ...
                [0, is_xlab * setting_plt.pixel_xlab] + ...
                [is_title * setting_plt.pixel_title, 0] + ...
                setting_fig.gapH_custom * setting_plt.pixel_gap_h;
            gap_w = [setting_plt.pixel_margin(2), ones(1,ny-1)*setting_plt.pixel_gap_w, setting_plt.pixel_margin(4)] + ...
                [is_ylab * setting_plt.pixel_ylab, 0] + ...
                setting_fig.gapW_custom * setting_plt.pixel_gap_w;
            figH = sum(ax_h) + sum(gap_h);
            figW = sum(ax_w) + sum(gap_w);
        end
        function [rect_axes, rect] = axes_pos2rect(~, ax_h, ax_w, gap_h, gap_w, matrix_hole, offset)
            % ax_h/gap_h, up to down
            % ax_w/gap_w, left to right
            % calculate relative rect_axes
            % [0(bottom) 0(left) 1(up) 1(right)]
            if ~exist('offset', 'var')
                offset = [0 0];
            end
            % normalize ax_h, ax_w, gap_h, gap_w
            figH = sum(ax_h) + sum(gap_h);
            figW = sum(ax_w) + sum(gap_w);
            % compute axes_rect
            nw = length(ax_w);
            nh = length(ax_h);
            rect_axes = {};
            count = 0;
            for xi = 1:nh 
                for yi = 1:nw
                    if matrix_hole(xi, yi) == 1
                        bx(1) = sum(gap_w(1:yi)) + sum(ax_w(1:yi-1));
                        bx(2) = sum(gap_h(xi+1:end)) + sum(ax_h(xi+1:end));
                        bx(3) = ax_w(yi);
                        bx(4) = ax_h(xi);
                        count = count + 1;
                        rect_axes{count} = bx;
                    end
                end
            end
            rect = [[0, 0] + offset, figW, figH];
        end
        function sz = get_screensize(~, screenID)
            if ~exist('screenID', 'var') 
                screenID = 0;
            end
            set(screenID,'units','pixels');
            sz = get(screenID,'screensize');
        end
    end
end