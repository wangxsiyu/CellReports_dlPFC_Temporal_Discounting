classdef S_plt_planner_core_figure < S_plt_executor
    methods
        %% figure
        function figure(obj, nx, ny, varargin)
            obj.reset_planner();
            % optional parameters
            % matrix_hole: allow "off"/hidden axes, matrix of "on" axes 
            % matrix_title: matrix of "on" titles
            % is_title: '1' - only first row, 'all' - all axes
            % matrix_xlabel: matrix of "on" xlabels (>1 means multiple label lines)
            % is_xlabel: '1' - only last row
            % matrix_ylabel: matrix of "on" ylabels (>1 means multiple label lines)        
            % is_ylabel: '1' - only first column
            if ~exist('nx', 'var') || isempty(nx) || nx < 1
                nx = 1;
            end
            if ~exist('ny', 'var') || isempty(ny) || ny < 1
                ny = 1;
            end
            % set figure parameters
            [defaultsetting_fig] = obj.setparameters_default_figure(nx, ny);
            [setting_fig, vars] = W.struct_set(defaultsetting_fig, varargin{:}, 'option_merge', 'set');
            [setting_plt, vars] = W.struct_set(obj.param_plt, vars{:}, 'option_merge', 'set');
            [setting_fig] = obj.setparameters_shortcut_figure(setting_fig, vars{:});
            obj.planner.fig.param_plt = setting_plt;
            % create figure
            obj.planner.fig.setting_fig = setting_fig;
            obj.planner.fig.n_axes = sum(setting_fig.matrix_hole, 'all');
            obj.planner.axes = repmat({W.struct('plots', {}, 'custom_axes', [])}, 1, obj.planner.fig.n_axes);
            % set optional figure param: params_matrix
            xy = cumsum(reshape(setting_fig.matrix_hole', 1,[]));
            xy(find(diff(xy) == 0) + 1) = NaN;
            xy = reshape(xy,ny,nx)';
            obj.planner.fig.custom_fig.addABCs_offset_title = setting_fig.matrix_title | any(setting_fig.matrix_title, 2);
            obj.planner.fig.nx = nx;
            obj.planner.fig.ny = ny;
            obj.planner.fig.xy = xy;
%             obj.fig = []; % reset fig
            obj.execute('figure', obj.planner.fig);
            obj.axi = 1;
            obj.ax(obj.axi);
        end
        %% axes
        function axi = ax(obj, varargin)
            switch length(varargin)
                case 1
                    axi = varargin{1};
                case 2
                    x1 = varargin{1};
                    x2 = varargin{2};
                    axi = obj.planner.fig.xy(x1, x2);
                otherwise
                    W.error('W_plt.ax: wrong number of inputs');
            end
            obj.axi = axi;
            obj.execute('ax', axi);
        end
        function axi = new(obj)
            axi = obj.axi;
            axi = axi + 1;
            if axi > obj.planner.fig.n_axes
                return;
            end
            obj.axi = axi;
            obj.execute('ax', axi);
        end
    end
    methods(Access = private)
        % figure - initialize parameters
        function [defaultsetting_fig] = setparameters_default_figure(~, nx, ny)
            matrix_hole = ones(nx, ny);
            matrix_title = zeros(nx, ny);
            matrix_xlabel = ones(nx, ny);
            matrix_ylabel = ones(nx, ny);
            gapH_custom = zeros(1,nx+1);
            gapW_custom = zeros(1,ny+1);
            defaultsetting_fig = struct('matrix_hole', matrix_hole, ...
                'matrix_title', matrix_title, ...
                'matrix_xlabel', matrix_xlabel, 'matrix_ylabel', matrix_ylabel, ...
                'gapH_custom', gapH_custom, 'gapW_custom', gapW_custom); 
        end
        % figure - shortcut parameters
        function [paramstruct] = setparameters_shortcut_figure(~, paramstruct, varargin)
            options = W.varargin2struct(varargin{:});
            % vars is a structure
            if isfield(options, 'is_title') 
                switch options.is_title
                    case {'1', 1}
                        paramstruct.matrix_title(1,:) = 1;
                    case 'all'
                        paramstruct.matrix_title = ones(size(paramstruct.matrix_title));
                end
            end
            if isfield(options, 'is_xlabel')
                switch options.is_xlabel
                    case {'1', 1}
                        paramstruct.matrix_xlabel(1:end-1,:) = 0;
                end
            end
            if isfield(options, 'is_ylabel')
                switch options.is_ylabel
                    case {'1', 1}
                        paramstruct.matrix_ylabel(:,2:end) = 0;
                end
            end
        end
    end
end