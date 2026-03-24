classdef S_RL_data_splitter < S_handle
    methods
        function [lists_train, lists_test, names] = split_train_test(~, option, data)
            if isempty(option)
                lists_train = {1:size(data,1)};
                lists_test = lists_train;
                names = 1;
            else
                option = W.string(option);
                switch option
                    case 'cond'
                        cIDs = unique(data.conditionID);
                        lists_train = W.arrayfun(@(x)find(data.conditionID == x), cIDs, false);
                        lists_test = lists_train;
                        names = cIDs;
                end
            end
        end
    end
end