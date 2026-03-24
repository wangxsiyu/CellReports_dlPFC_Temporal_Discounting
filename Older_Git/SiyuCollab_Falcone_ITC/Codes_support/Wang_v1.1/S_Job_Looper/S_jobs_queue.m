classdef S_jobs_queue < S_jobs_wrapper
    properties
        jobs 
        jobrank
    end
    properties(Dependent)
        jobnames
        n_jobs
    end
    methods
        function obj = S_jobs_queue()
            obj.jobs = {};
            obj.jobrank = [];
        end
        %% add job
        function add_jobs(obj, varargin)
            obj.add_jobs_withrank(obj.get_current_jobrank() + 1, varargin{:});
        end
        function add_jobs_parallel(obj, varargin)
            obj.add_jobs_withrank(obj.get_current_jobrank(), varargin{:});
        end
        function add_jobs_withrank(obj, rank, varargin)
            if isempty(varargin)
                return;
            end
            if obj.is_power
                if W_job.is_job_struct(varargin{1}) % inputs are job structures
                    newjobs = varargin;
                    for i = 1:length(newjobs)
                        newjobs{i} = obj.wrap_job(newjobs{i});
                    end
                    obj.jobs = [obj.jobs, newjobs];
                    obj.jobrank = [obj.jobrank, ones(1, length(newjobs)) * rank];
                else % add a single new job
                    job = obj.new_job(varargin{:});
                    obj.jobs{end+1} = obj.wrap_job(job);
                    obj.jobrank(end+1) = rank;
                end
            end
        end
        %% default 
        function values = get.n_jobs(obj)
            values = length(obj.jobs);
        end
        function values = get.jobnames(obj)
            values = cellfun(@(x)W.string(x.jobname), obj.jobs);
        end
    end
    methods(Access = protected)
        function job = new_job(~, varargin)
            job = W_job.new_job(varargin{:});
        end
        function sort_jobs(obj)
            if isempty(obj.jobs)
                return;
            end
            rk = obj.jobrank;
            [~, od] = sort(rk);
            obj.jobs = obj.jobs(od);
        end
        function rank = get_current_jobrank(obj)
            if isempty(obj.jobrank)
                rank = 0;
            else
                rank = max(obj.jobrank);
            end
        end
    end
end