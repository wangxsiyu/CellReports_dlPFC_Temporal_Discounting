classdef S_RL_train < S_optimizer
    properties
        RLwkdir
    end
    methods
        function obj = S_RL_train()
            obj.RLwkdir = [];
            obj.set_loss_mode('NLL_RL');
        end
        function paramfit = train(obj, model, data, varargin)
            if ~exist('data', 'var') || isempty(data)
                data = obj.data;
            end
            paramfit = obj.optimize_model([], model, data, varargin{:});
        end
        function [paramfits] = train_lists(obj, model, data, lists_train, lists_name, varargin)
            W.print('training model: %s', model.name);
%             if ~exist('lists_train', 'var') || isempty(lists_train)
%                 lists_train = {1:size(data,1)};
%                 lists_name = 'all';
%             end
            nlist = length(lists_train);
            alldata = W.cellfun(@(x)data(x,:), lists_train, false);
            savedir = obj.RLwkdir;
            jobs = S_jobs();
            for i = 1:nlist
                tsavename = fullfile(savedir, model.name, sprintf('train_part%d', i));
                jobs.add_jobs_withrank(1, @obj.train, ...
                    {}, {model, alldata{i}}, tsavename, ...
                    'is_output', ~isempty(savedir));
            end
            jobs.copy_handle_settings(obj);
            paramfits = jobs.run(); % need test
            % paramfits = W.load(fullfile(savedir,model.name));
            paramfits = W.cellofstruct2table(paramfits, 1);
            paramfits.fitID = lists_name;
        end
        function set_RLwkdir(obj, wkdir)
            if ~exist('wkdir', 'var') || isempty(wkdir)
                wkdir = './Temp';
                W.warning('S_RL working directory not set, use %s', wkdir);
            else
                W.print('set S_RL working directory: %s', wkdir);
            end
            obj.RLwkdir = wkdir;
        end
    end
end