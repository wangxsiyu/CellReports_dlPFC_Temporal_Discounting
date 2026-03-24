classdef S_plt_planner_core_aesthetics < S_plt_executor
    methods
        %% update
        function update(obj, varargin)
            obj.execute('update', obj.planner);
            obj.save(varargin{:});
        end
        function addABCs(obj, ABCstring)
            obj.planner.fig.custom_fig.ABClabels = ABCstring;
        end
        %% set fig
        function setfig_ax(obj, varargin)
            % optional input: axi
            % optional input: 'overwrite' (by default, use "ignore")
            % varargin can be pairs of (name, value), or a structure
            i = 1;
            if isnumeric(varargin{i})
                axi = varargin{i};
                i = i + 1;
            else
                axi = obj.axi;
            end
            if length(obj.planner.axes) < axi
                W.error('W_plt_planner.setfig_ax: axes length < axi');
                return;
            end
            if W.is_stringorchar(varargin{i}) && strcmp(varargin{i}, 'overwrite')
                i = i + 1;
                custom_axes = W.struct_set(obj.planner.axes{axi}.custom_axes, varargin{i:end}, 'option_merge', 'overwrite');
            else
                custom_axes = W.struct_set(obj.planner.axes{axi}.custom_axes, varargin{i:end}, 'option_merge', 'ignore');
            end
            obj.planner.axes{axi}.custom_axes = obj.update_preprocess_axes(custom_axes);
        end
        function setfig(obj, varargin)
            i = 1;
            if isnumeric(varargin{1}) 
                id = varargin{1};
                i = i + 1;
            else
                id = 1:obj.planner.fig.n_axes;
            end
            option = struct(varargin{i:end});
            for i = 1:length(id)
                obj.setfig_ax(id(i), option(i));
            end
        end
        function setfig_all(obj, varargin)
            i = 1;
            if isnumeric(varargin{1}) 
                id = varargin{1};
                i = i + 1;
            else
                id = 1:obj.planner.fig.n_axes;
            end
            option = W.struct(varargin{i:end});
            for i = 1:length(id)
                obj.setfig_ax(id(i), option);
            end
        end
        function unify_lims(obj, x, y)
            if ~exist('x', 'var') || isempty(x)
                x = [NaN NaN];
            end
            if ~exist('y', 'var') || isempty(y)
                y = [NaN NaN];
            end
            obj.setfig_all('xlim', x, 'ylim', y);
        end
    end
    methods(Access = protected)
        %% update preprocess
        function custom_axes = update_preprocess_axes(obj, custom_axes)
            if isfield(custom_axes, 'legend')
                leg = custom_axes.legend;
                leg = W.string(leg); % used to be cell_enchar
                leg = W.str_de_(leg);
                custom_axes.legend = leg;
            end
            if isfield(custom_axes, 'legloc')
                legloc = custom_axes.legloc;
                if strcmp(legloc, 'none')
                    custom_axes.legend = [];
                    custom_axes.legloc = [];
                else
                    legloc = replace(legloc, {'North','South','West','East', 'Outside'}, ...
                        {'N','S','W','E', 'O'});
                    legloc = replace(legloc, {'N','S','W','E', 'O'}, ...
                        {'North','South','West','East', 'Outside'});
                    custom_axes.legloc = legloc;
                end
            end
            if isfield(custom_axes, 'legord')
                legord = custom_axes.legord;
                if W.is_stringorchar(legord) && strcmp(legord, 'reverse')
                    legord = length(obj.fig.object_list{axi}):-1:1;
                end
                custom_axes.legord = legord;
            end
            if isfield(custom_axes, 'xticklabel')
                xtklb = W.horz(W.str2cell(custom_axes.xticklabel));
                if size(xtklb,1) > 1
                    xtklb = strtrim(sprintf('%s\\newline%s\n', xtklb{:}));
                end
                custom_axes.xticklabel = xtklb;
            end
        end
    end
end