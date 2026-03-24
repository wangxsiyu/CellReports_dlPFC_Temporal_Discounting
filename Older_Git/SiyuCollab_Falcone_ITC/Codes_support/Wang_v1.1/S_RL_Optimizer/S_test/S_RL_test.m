classdef S_RL_test < S_RL_evaluator
    methods
        function output = test(obj, paramfits, model, data)
            if ~exist('data', 'var') || isempty(data)
                data = obj.data;
            end
            output = obj.evaluate_model_on_data(paramfits, model, data, 0);
        end
        function [output] = test_lists(obj, paramfits, model, data, lists_test, lists_name)
            W.print('testing model: %s', model.name);
            nlist = length(lists_test);
            testings = cell(1, nlist);
            alldata = W.cellfun(@(x)data(x,:), lists_test, false);

            for i = 1:nlist
                W.print('test part %d/%d', i, nlist);
                if isfield(paramfits, 'fitID')
                    fid = paramfits.fitID == lists_name(i);
                    tparams = paramfits(fid,:);
                else
                    tparams = paramfits;
                end
                testings{i} = obj.test(tparams, model, alldata{i});
%                 testings{i}.rowid_data = lists_test{i};
            end
            % testings{} could be table, or cells
            if all(cellfun(@(x)istable(x), testings))
                testings = W.arrayfun(@(x)W.tab_fill(testings{x}, 'fitID', lists_name(x)), 1:nlist, false);
                output = W.tab_vertcat(testings{:});
            else
                output = W.decell(testings);
            end
        end
    end
end