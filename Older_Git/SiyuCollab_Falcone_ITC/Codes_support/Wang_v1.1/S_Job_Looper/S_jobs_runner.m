classdef S_jobs_runner < S_jobs_looper
    methods
        function varargout = run(obj, varargin)
            if obj.is_parfor
                if nargout == 0
                    varargout = {};
                    obj.run_parallell(varargin{:});
                else
                    varargout = obj.run_parallell(varargin{:});
                end
            else
                if nargout == 0
                    varargout = {};
                    obj.run_sequential();
                else
                    varargout = obj.run_sequential();
                end
            end
            varargout = W.encell1(varargout);
        end
        function varargout = run_sequential(obj)
            obj.sort_jobs;
            varargout = cell(1, obj.n_jobs);
            for i = 1:obj.n_jobs
                job = obj.jobs{i};
                W.print('processing job %d/%d: %s', i, obj.n_jobs, job.jobname)
                if nargout == 0
                    obj.execute_job(job);
                else
                    varargout{i} = obj.execute_job(job);
                end
            end
            varargout = W.encell1(varargout);
            W.print('complete!')
        end
        function varargout = run_parallell(obj, varargin)
            isoutput = (nargout > 0) + 0;
            W.parpool(varargin{:});
            ranks = obj.jobrank;
            ranklevels = unique(ranks, 'sorted');
            varargout = cell(1, length(ranklevels));
            for li = 1:length(ranklevels)
                W.print('job level %d/%d', li, length(ranklevels));
                jobs = obj.jobs(ranks == ranklevels(li));
                njobs = length(jobs);
                func_job = @obj.execute_job;
                clear progresses
                tout = cell(1, njobs);
                for ji = 1:njobs
                    job = jobs{ji};
                    progresses(ji) = parfeval(func_job, isoutput, job);
                end
                W.print('%d jobs added, first job name: %s', njobs, job.jobname)
                for ji = 1:njobs
                    tid = fetchNext(progresses);
                    if isoutput
                        tout{tid} = fetchOutputs(progresses(tid));
                    end
                    W.print('job #%d complete, %d/%d remaining', tid, njobs-ji, njobs)
                end
                W.print('complete - job level %d/%d', li, length(ranklevels));
                varargout{li} = tout;
            end
            varargout = W.encell1(varargout);
            W.print('complete!')
        end
        %% execute job
        function varargout = execute_job(obj, job)
            if nargout == 0
                W_job.execute_job(job, obj.is_overwrite, obj.is_test);
            else
                varargout{1} = W_job.execute_job(job, obj.is_overwrite, obj.is_test);
            end
        end
    end
end