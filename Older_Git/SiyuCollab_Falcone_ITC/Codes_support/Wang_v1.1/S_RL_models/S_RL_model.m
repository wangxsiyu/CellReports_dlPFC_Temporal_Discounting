classdef S_RL_model < S_model
    properties
        latentvariables
    end
    methods
        function obj = S_RL_model()
            obj.name = "RL model";
            obj.description = "RL model template";
            obj.latentvariables = struct;
        end
        %% user defined
        function LV = reset(obj, varargin)
            LV = struct;
        end
        function LV = reset_block(~, params, LV, varargin)
        end
        function LV = update(~, params, LV, varargin)
        end
        function CP = policy(~, varargin)
            CP = NaN(1,2);
        end
        %% default
        function RL_reset(obj, varargin)
            params = obj.params;
            LV = obj.reset(params, struct, varargin{:});
            obj.latentvariables = W.struct_set(obj.latentvariables, LV);
        end
        function RL_reset_block(obj, varargin)
            LV = obj.latentvariables;
            params = obj.params;
            LV = obj.reset_block(params, LV, varargin{:});
            obj.latentvariables = W.struct_set(obj.latentvariables, LV);
        end
        function RL_update(obj, varargin)
            LV = obj.latentvariables;
            params = obj.params;
            LV = obj.update(params, LV, varargin{:});
            obj.latentvariables = W.struct_set(obj.latentvariables, LV);
        end
        function [CP] = RL_policy(obj, varargin)
            LV = obj.latentvariables;
            params = obj.params;
            if W.nargout_class(obj, 'policy') == 1
                [CP] = obj.policy(params, LV, varargin{:});
            else
                [CP, LV] = obj.policy(params, LV, varargin{:});
                obj.latentvariables = W.struct_set(obj.latentvariables, LV);
                obj.latentvariables.action_dist = CP;
            end
        end
        function action = sample_actions(~, CP)
            f = @(P)find(rand<cumsum(P),1,'first');
            action = f(CP);
        end
    end
end