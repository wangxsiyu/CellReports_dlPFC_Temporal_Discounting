classdef W_Tools_Function < handle
    methods(Static)
        %% inline ifelse
        function out = iif(istrue, a, b)
            if istrue
                out = a;
            else
                out = b;
            end
        end
        %%
        function out = iif_eval(istrue, stra, strb)
            if istrue
                out = evalin('caller', stra);
            else
                out = evalin('caller', strb);
            end
        end
        %% string to func
        function [fcn, functype] = str2func(fcn)
            functype = 'func';
            if W.is_stringorchar(fcn)
                if contains(fcn, 'obj.')
                    fn = W.str_selectbetween2patterns(fcn, 'obj.', []);
                    fcn = @(obj, varargin)obj.(fn)(varargin{:});
                    functype = 'obj.func';
%                 elseif contains(fcn, 'S_fig.')
% %                     fn = W.str_selectbetween2patterns(fcn, 'S_fig.', []);
% %                     fcn = @(obj, varargin)S_fig.(fn)(varargin{:});
%                     fcn = str2func(fcn);
%                     functype = 'S_fig.func';
                else
                    fcn = str2func(fcn);
                    functype = 'func';
                end
            end
            if isobject(fcn)
                fcn = @fcn; % if object, run object initialization
                functype = 'obj';
            end
        end
        %% cellfun/arrayfun
        function [out] = cellfun(func, a, uniformoutput)
            % doesn't work for multiple outputs from cellfun
            if ~exist('uniformoutput','var') || W.isempty(uniformoutput)
                uniformoutput = true;
            end
            assert(iscell(a));
%             a = W.encell(a);
            try
                [out] = cellfun(func, a, 'UniformOutput', uniformoutput);
            catch
                [out] = cellfun(func, a, 'UniformOutput', false);
            end
        end
        function out = arrayfun(func, a, uniformoutput)
            if ~exist('uniformoutput','var') || W.isempty(uniformoutput)
                uniformoutput = true;
            end
            assert(ismatrix(a));
%             a = W.decell(a);
            try
                out = arrayfun(func, a, 'UniformOutput', uniformoutput);
            catch
                out = arrayfun(func, a, 'UniformOutput', false);
            end
        end
        function [out] = structfun(func, a, uniformoutput)
            % doesn't work for multiple outputs from cellfun
            if ~exist('uniformoutput','var') || W.isempty(uniformoutput)
                uniformoutput = true;
            end
            assert(isstruct(a));
            try
                [out] = structfun(func, a, 'UniformOutput', uniformoutput);
            catch
                [out] = structfun(func, a, 'UniformOutput', false);
            end
        end
        % extension - auto vert/horz cat
        function a = arrayfun_vertcat(varargin)
            te = W.arrayfun(varargin{:});
            a = vertcat(te{:});
        end
        function a = arrayfun_horzcat(varargin)
            te = W.arrayfun(varargin{:});
            a = horzcat(te{:});
        end
        function a = cellfun_vertcat(varargin)
            te = W.cellfun(varargin{:});
            a = vertcat(te{:});
        end
        function a = cellfun_horzcat(varargin)
            te = W.cellfun(varargin{:});
            a = horzcat(te{:});
        end
        %% assign
        function outcells = cellfun_assign_to_cellofstruct(outcells, structname, varargin)
            out = W.cellfun(varargin{:}, false);
            for i = 1:length(out)
                outcells{i}.(structname) = out{i};
            end
        end
        function outcells = arrayfun_assign_to_cellofstruct(outcells, structname, varargin)
            out = W.arrayfun(varargin{:}, false);
            for i = 1:length(out)
                outcells{i}.(structname) = out{i};
            end
        end
        %% function select N-th output
        function out = func(fcn, n, varargin)
            if ~exist('n', 'var')
                n = [];
            end
            fcn = W.str2func(fcn);
%             if W.is_stringorchar(fcn)
            nOut = nargout(fcn);
%             else
%                 nOut = max(n);
%             end
            if isempty(n)
                n = 1:nOut;
            end
            X = cell(1,nOut);
            [X{:}] = fcn(varargin{:});
            out = W.decell(X(n));
        end
        %% catch all output in a cell
        function out = catch_all_output(f, varargin)
            n = W.nargout(f);
            f = W.str2func(f);
            if n == 0
                f(varargin{:});
                out = {};
            else
                out = cell(1, n);
                [out{:}] = f(varargin{:});
            end
        end
        %% nargout
        function n = nargout(f)
            if ~W.is_stringorchar(f)
                f = func2str(f);
            end
            if contains(f, '@') % function handle
                n = 1;
            elseif contains(f, '.') % object
                f = strsplit(f,'.');
                n = W.nargout_class(f{1}, f{2});
            else
                n = nargout(f);
            end
        end
        function n = nargout_class(C,M)
            % this function is extension of nargout for class
            % It can find nargout of inherited methods

            % input
            % C : name of the class (char) or Object

            % M : name of the method (char) or method handle (function_handle)

            % output
            % n : number of output argument of method M (double)

            % conver C into char
            if ~ischar(C)
                C = class(C);
            end

            % convert M into char
            if isa(M,'function_handle')
                M = func2str(M);
            end

            % get possible classes which contains M
            classList = superclasses(C);
            classList = [{C}; classList];

            for s = classList(:)'
                s = s{1};
                try
                    % workaround (https://kr.mathworks.com/matlabcentral/answers/96617-how-can-i-use-nargin-nargout-to-determine-the-number-of-input-output-arguments-of-an-object-method)
                    n = nargout([s '>' s '.' M]);
                    return
                end
            end

            % if not returned until here, it means there is no methods are matched
            error('There is no method ''%s'' in the class %s.',M,C);
        end
    end
end