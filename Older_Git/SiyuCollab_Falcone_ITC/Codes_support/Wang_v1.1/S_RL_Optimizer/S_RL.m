classdef S_RL < S_RL_train & ...
        S_RL_test & ...
        S_RL_data_splitter & ...
        S_RL_loader
    methods
        function obj = S_RL()
        end
        function output = train_auto(obj, model, data, option_split, varargin)
            if ~exist('data', 'var') || isempty(data)
                data = obj.data;
            end
            if ~exist('option_split', 'var') || isempty(option_split)
                option_split = [];
            end
            [lists_train, ~, lists_name] = obj.split_train_test(option_split, data);
            output = obj.train_lists(model, data, lists_train, lists_name, varargin{:});
        end
        function output = test_auto(obj, params, model, data, option_split, varargin)
            if ~exist('data', 'var') || isempty(data)
                data = obj.data;
            end
            data = obj.prepare_data(data);
            if ~exist('option_split', 'var') || isempty(option_split)
                option_split = [];
            end
            [~, lists_test, lists_name] = obj.split_train_test(option_split, data);
            output = obj.test_lists(params, model, data, lists_test, lists_name);
        end
    end
end
    