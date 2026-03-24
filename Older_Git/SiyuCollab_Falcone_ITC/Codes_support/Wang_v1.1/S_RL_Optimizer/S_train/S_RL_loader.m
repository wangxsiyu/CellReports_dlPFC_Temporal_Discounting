classdef S_RL_loader < handle
    properties
        data
        env
    end
    methods
        % load data
        function data = load_data(obj, data, varargin)
            i = 1;
            assert(mod(length(varargin), 2) == 0, 'number of inputs should be in pairs'); 
            while i + 1 <= length(varargin)
                data.(varargin{i}) = varargin{i+1};
                i = i + 2;
            end
            if ~any(contains(data.Properties.VariableNames, 'blockID')) % auto add blockID
                data.blockID = ones([size(data, 1), 1]);
            end
            if ~any(contains(data.Properties.VariableNames, 'conditionID')) 
                data.conditionID = ones([size(data,1), 1]);
            end
            if ~any(contains(data.Properties.VariableNames, 'resetID'))
                data.resetID = [1;zeros([size(data,1)-1, 1])];
            end
            if ~any(contains(data.Properties.VariableNames, 'reward'))
                data.reward = NaN(size(data,1),1);
            end
            data = obj.prepare_data(data);
            obj.data = data;
        end
        function data = prepare_data(obj, data)
            if obj.is_test
                W.warning('test mode on');
                cIDs = unique(data.conditionID);
                cIDs = W.extend(cIDs, 2);
                data = data(ismember(data.conditionID, cIDs([1 2])),:);
                bIDs = unique(data.blockID);
                bIDs = W.extend(bIDs, 2);
                data = data(ismember(data.blockID, bIDs([1 2])),:);
            end
        end
        function load_env(obj, env)
            obj.env = env;
        end
    end
end