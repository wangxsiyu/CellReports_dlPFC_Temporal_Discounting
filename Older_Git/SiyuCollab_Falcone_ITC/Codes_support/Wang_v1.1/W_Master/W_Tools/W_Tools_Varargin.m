classdef W_Tools_Varargin < handle
    methods(Static)
        %% get options as pairs at the end of varargin
        function [X, vars] = varargin_get_endoptions(options, varargin)
            vars = varargin;
            X = struct;
            options = W.string(options);
            while length(vars) >= 2
                if W.is_stringorchar(vars{end-1}) && any(ismember(vars{end-1}, options))
                    X.(vars{end-1}) = vars{end};
                    vars = vars(1:end-2);
                else
                    break;
                end
            end
        end
        function [vars, data] = varargin_get_celloptions(options, varargin)
            options = W.string(options);
            vars = W.varargin2struct_namesfirst(options, repmat({[]}, 1, length(options)));
            num = [];
            for i = 1:length(options)
                tid = W.cellfun(@(x)W.is_stringorchar1(x) && strcmp(x, options(i)), varargin);
                if any(tid)
                    num = [num, find(tid)];
                end
            end
            if isempty(num)
                data = varargin;
            else
                data = varargin(1:(num(1)-1));
                num = [num, length(varargin)+1];
                for i = 1:(length(num) - 1)
                    fn = varargin{num(i)};
                    vars.(fn) = varargin((num(i)+1):(num(i+1)-1));
                end
            end
        end
        %% varargin to struct
        function X = varargin2struct(varargin)
            vars = W.encell(varargin);
            X = cell2struct(vars(2:2:end), W.string(vars(1:2:end)),2);
        end
        function X = varargin2struct_namesfirst(names, varargin)
            vars = W.encell_1layer(varargin);
            names = W.str2cell(names);
            X = cell2struct(vars, W.horz(names), 2);
        end
        %% varargin with default
        function vars = varargin_withdefault(varname_default, varnames_all, varargin)
            % varname_default - default keys
            % varnames_all - all valid keys
            if any(contains(varnames_all, 'help'))
                W.print_bullet(varname_default);
            end
            varname_default = W.encell(varname_default);
            vars = {};
            i = 1;
            while i <= length(varname_default) && i <= length(varargin)
                if W.is_stringorchar(varargin{i}) && ...
                        (isempty(varnames_all) || any(strcmp(varargin{i}, varnames_all)))
                    break;
                else
                    vars{end+1} = varname_default{i};
                    vars{end+1} = varargin{i};
                    i = i + 1;
                end
            end
            vars = [vars varargin(i:end)];
        end
    end
end