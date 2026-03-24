classdef S_jobs_wrapper < S_handle
    properties
        plotmode
        neuromode
        inputs_library % replace 'input#' with items in the input library
        wrapper_vars
        wrapper_func
%         wrapper_func_input
    end
    methods
        function obj = S_jobs_wrapper()
            obj.plotmode = false;
            obj.neuromode = false;
            obj.inputs_library = {};
            obj.wrapper_vars = {};
            obj.wrapper_func = [];
        end
        %% wrapper
        function job = wrap_job(obj, job)
            % wrap vars
            job = W_job.job_insertvars(job, obj.wrapper_vars{:});
            job = obj.wrapper_format_vars(job);

            % plot mode
            if obj.plotmode
                job.vars{1} = copy(job.vars{1});
                if isfield(job, 'outputnames')
                    job.vars{1}.set_savename(W.deext(job.outputnames)); % job.vars{1} = plt
                    filenames = job.vars{1}.fig_savename;
                    job.outputnames_nonsave = filenames;
                    job.is_output = false;
%                     if job.vars{1}.is_execute
%                         job.outputnames_nonsave = filenames;
%                     else
%                         job.outputnames_nonsave = W.files_is_ext(filenames, 'mat');
%                     end
                end
            end
            % wrap func
            if ~isempty(obj.wrapper_func)
                job = W_job.job_insertvars(job, job.func);
                job.func = obj.wrapper_func;
                job.inputfunc = @(args, func, varargin)[{func}, job.inputfunc(args, varargin{:})];
            end
        end
        %% for trial x cell analysis
        function neuromode_on(obj, varargin)
            obj.neuromode = true;
            obj.set_wrapper_func('SW_job_conditioner', varargin{:});
        end
        function neuromode_off(obj)
            obj.neuromode = false;
            obj.wrapper_func = [];
        end
        %% for plotting
        function plotmode_on(obj, plt)
            obj.plotmode = true;
            obj.set_wrapper_vars(plt)
            obj.set_wrapper_func('SW_wrapper_plt');
        end
        function plotmode_off(obj)
            obj.plotmode = false;
            obj.set_wrapper_vars({});
            obj.wrapper_func = [];
        end
        %% set variables
        function set_inputs_library(obj, varargin)
            obj.inputs_library = varargin;
        end
        function set_wrapper_vars(obj, varargin)
            if obj.is_power
                obj.wrapper_vars = varargin;
            end
        end
        function set_wrapper_func(obj, func, varargin)
            if obj.is_power
                obj.wrapper_func = W.string(func);
                %             obj.wrapper_func_inputs = varargin;
            end
        end
    end
    methods(Access = private)
        %% format vars
        function job = wrapper_format_vars(obj, job)
            vars = job.vars;
            x = obj.inputs_library;
            if ~isempty(vars)
                tid = cellfun(@(x)W.is_stringorchar1(x) && ...
                    length(W.encell(W.str_select(x, '!digit'))) == 1 && ...
                    W.str_select(x, '!digit')== "input", vars);
                tid = find(tid);
                for i = 1:length(tid)
                    tchar = char(vars{tid(i)});
                    inputid = W.str_select(tchar, 'digit');
                    vars{tid(i)} = x{inputid};
                end

%                 tid = cellfun(@(x)W.is_stringorchar1(x) && ...
%                     length(W.encell(W.str_select(x, '!digit'))) == 1 && ...
%                     W.str_select(x, '!digit')== "output", vars);
%                 tid = find(tid);
%                 for i = 1:length(tid)
%                     tchar = char(vars{tid(i)});
%                     inputid = W.str_select(tchar, 'digit');
%                     vars{tid(i)} = W.decell(job.outputnames(inputid));
%                 end
            end
            job.vars = vars;
        end
    end
end