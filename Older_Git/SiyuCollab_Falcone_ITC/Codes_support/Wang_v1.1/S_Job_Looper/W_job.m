classdef W_job < handle
    % structure: 
        % func
        % files
        % vars
        % inputorder_vars
        % inputorder_files
        % outputnames
        % outputnames_nonsave (check if all exist, for overwrite check)
        % func_read
        % inputfunc
        % inputfunc_arguments
        % outputfunc
        % outputfunc_arguments
        % is_output
        % catchalloutput
        % jobname
    methods(Static)
        %% execute job
        function varargout = execute_job(job, is_overwrite, is_test)
            job = W_job.job_format_vars(job);
            if ~exist('is_overwrite', 'var') || isempty(is_overwrite)
                is_overwrite = false;
            end
            if ~exist('is_test', 'var') || isempty(is_test)
                is_test = false;
            end
            files = job.files;
            outfiles = W.string(job.outputnames);
            if is_test
                outfiles = W.file_prefix(outfiles, 'Test/', '');
                files = W.file_prefix(files, 'Test/', '');
            end
            if ~job.is_output
                outputnames_save = [];
            else
                outputnames_save = outfiles;
            end
            outputnames_all = [outputnames_save, W.string(job.outputnames_nonsave)];
            if ~isempty(outputnames_all)
                if is_overwrite
                    W.print_exist_files(outputnames_all, 'overwrite');
                else
                    isexistfile = W.file_exist_all(outputnames_all, 1);
                    if isexistfile
                        if nargout > 0
                            varargout{1} = W.load(outputnames_all);
                        end
                        return;
                    end
                end
            end
            if ~W.isempty(files)
                inputs_files = W.encell(job.func_read(files));
            else
                inputs_files = {};
            end
            inputs = [inputs_files job.vars];
            ninput = length(inputs);
            od_files = job.inputorder_files;
            od_vars = job.inputorder_vars;
            od = [od_files, od_vars];
            assert(length(od) == ninput);
            od(od < 0) = od(od < 0) + ninput + 1;
            assert(length(unique(od)) == ninput);
            od_nan = setdiff(1:ninput, W.unique(od, 0));
            od(isnan(od)) = od_nan;
            [~, od] = sort(od);
            inputs = inputs(od);
            func_input = W.str2func(job.inputfunc);
            inputs = func_input(job.inputfunc_arguments, inputs{:});
            func = W.str2func(job.func);
            func_output = W.str2func(job.outputfunc);
            if job.catchalloutput
                output = W.catch_all_output(func, inputs{:});
            else
                output = func(inputs{:});
                output = W.encell_1layer(output);
            end
            output = func_output(job.outputfunc_arguments, output{:});
            output = W.encell(output);
            if ~W.isempty(outputnames_save)
                for oi = 1:length(outputnames_save)
                    W.save(outputnames_save(oi), 'data', output{oi});
                end
            end
            varargout = output;
        end
        %% create job
        function job = empty_job()
            job = W.struct('func', [], ...
                 'files', {}, ...
                 'vars', {}, ...
                 'inputorder_vars', [], ...
                 'inputorder_files', [], ...
                 'outputnames', {}, ...
                 'outputnames_nonsave', {}, ...
                 'func_read', @W.load, ...
                 'inputfunc', @(arg, varargin)varargin, ...
                 'inputfunc_arguments', {}, ...
                 'outputfunc', @(arg, varargin)varargin, ...
                 'outputfunc_arguments', {}, ...
                 'is_output', true, ...
                 'catchalloutput', true, ...
                 'jobname', 'job');
        end
        function job = update_job(job, varargin)
            job = W.struct_set_withdefault(job, ...
                {'func','files','vars','outputnames','jobname'}, ...
                varargin{:});
            job = W_job.auto_format_job(job);
        end
        function job = auto_format_job(job)
            job.files = W.string(job.files);
            job.outputnames = W.string(job.outputnames);
            job.vars = W.encell(job.vars);
            if isempty(job.inputorder_files)
                job.inputorder_files = NaN(1, length(job.files));
            end
            if isempty(job.inputorder_vars)
                job.inputorder_vars = NaN(1, length(job.vars));
            end
%             if isempty(job.inputorder)
%                 job.inputorder = 1:(length(job.vars) + length(job.files));
%             end
            if strcmp(job.jobname, 'job') && W.is_stringorchar(job.func)
                job.jobname = job.func;
            end
        end
        function job = new_job(varargin)
            if length(varargin) >= 1 && isstruct(varargin{1}) % 1st inputs is a job structure
                job = varargin{1};
                varargin = varargin(2:end);
            else
                job = W_job.empty_job();
            end
            job = W_job.update_job(job, varargin{:});
        end
        function out = is_job_struct(job)
            out = false;
            if ~isstruct(job)
                return;
            end
            f1 = W.fieldnames(W_job.empty_job());
            f2 = W.fieldnames(job);
            if length(intersect(f1, f2)) == length(f1)
                out = true;
            end
        end
        function job = job_insertvars(job, varargin)
            vars = varargin;
            nvars = length(vars);
            if nvars > 0
                job.vars = [vars job.vars];
                % change input order
                tid = job.inputorder_vars > 0;
                job.inputorder_vars(tid) = job.inputorder_vars(tid) + nvars;
                job.inputorder_vars = [1:nvars, job.inputorder_vars];
                tid = job.inputorder_files > 0;
                job.inputorder_files(tid) = job.inputorder_files(tid) + nvars;
            end
        end
        function job = job_format_vars(job)
            idstr = find(cellfun(@(x)W.is_stringorchar1(x), job.vars));
            if length(idstr) > 0
                vars = job.vars(idstr);
                for j = 1:length(vars)
                    if W.is_stringorchar(vars{j})
                        if length(char(vars{j})) >= 9 && strcmp(extractBefore(vars{j},10), 'inputname')
                            te = W.str_select(vars{j});
                            vars{j} = job.files(te);
                        end
                        if length(char(vars{j})) >= 10 && strcmp(extractBefore(vars{j},11), 'outputname')
                            te = W.str_select(vars{j});
                            vars{j} = job.outputnames(te);
                        end
                    end
                end
                job.vars(idstr) = vars;
            end
        end
    end
end