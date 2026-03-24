classdef S_model < S_handle
    properties
        name
        description
        X0
        LB
        UB
        name_parameters
        params
        constants
    end
    properties(Dependent)
        n_params
    end
    methods
        function obj = S_model()
            obj.name = "model";
            obj.description = "model description";
            obj.name_parameters = {};
            obj.X0 = [];
            obj.LB = [];
            obj.UB = [];
            obj.params = [];
            obj.constants = struct;
        end
        %% user defined
        function params = set_params(obj, params)
            obj.params = obj.parse_params(params);
        end
        %% default
        function out = parse_params(obj, params, name)
            if ~exist('name', 'var') || isempty(name)
                name = obj.name_parameters;
            end
            if ~isempty(name) && length(name) == length(params)
                params = W.arrayfun(@(x)x, params, false);
                out = W.varargin2struct_namesfirst(name, params{:});
                out = W.struct_combine(out, obj.constants);
            else
                if ~W.isempty(obj.constants)
                    out = W.struct('params', params, 'constants', constants);
                else
                    out = params;
                end
            end
        end
        function value = get.n_params(obj)
            value = length(obj.LB);
        end
    end
end