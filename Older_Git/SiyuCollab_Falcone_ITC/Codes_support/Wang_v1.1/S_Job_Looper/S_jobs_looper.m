classdef S_jobs_looper < S_jobs_queue
    properties
        loopers
        loopernames
        n_looper

%         job_loopers
%         job_looperinputs
%         job_isunpacked
    end
    methods
        function obj = S_jobs_looper()
        end
        function set_loopers(obj, names, varargin)
            obj.loopers = varargin;
            obj.n_looper = length(obj.loopers);
            if ~exist('names', 'var') || isempty(names)
                names = W.arrayfun(@(x)sprintf("looper%d", x), 1:obj.n_looper);
            end
            obj.loopernames = W.string(names);
%             obj.job_loopers = {};
%             obj.job_looperinputs = {};
%             obj.job_isunpacked = [];
        end
        %% add job from looper
        function add_jobs_with_looper(obj, loopernames, looperinputs, varargin)
            if obj.is_power
                loopernames = W.string(loopernames);
                if ~exist('looperinputs', 'var') || isempty(looperinputs)
                    looperinputs = cell(1, length(loopernames));
                else
                    looperinputs = W.encell(looperinputs);
                end
                assert(length(loopernames) == length(looperinputs));
                newjob = obj.new_job(varargin{:});
                jobs = obj.looper_unpack(newjob, loopernames, looperinputs);
                obj.add_jobs(jobs{:});
            end
        end
        %% unpack jobs
        function jobnew = looper_unpack(obj, jobs, loopernames, looperinputs)
            looperidx = arrayfun(@(x)find(x == obj.loopernames), loopernames);
            lps = arrayfun(@(x)obj.loopers{x}, looperidx);
            % create jobs
            jobnew = W.encell(jobs);
            for i = 1:length(lps)
                jobold = jobnew;
                tvar = W.empty2cell(looperinputs{i});
                jobnew = [];
                for ii = 1:length(jobold)
                    tjob = lps{i}.unpack_job(jobold{ii}, tvar{:});
                    jobnew = [jobnew, tjob];
                end
            end
        end
        %% shortcut functions
        function add_jobs_with_looper_folder(obj, inputs, varargin)
            if ~exist('inputs', 'var') || isempty(inputs)
                inputs = {'folder', 'folder'};
            end
            obj.add_jobs_with_looper('folder', W.encell1(inputs), varargin{:});
        end
    end
end