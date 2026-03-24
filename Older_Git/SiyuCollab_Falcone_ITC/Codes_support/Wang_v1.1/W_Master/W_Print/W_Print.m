classdef W_Print < handle
    methods(Static)
        %% basic
        function print(varargin)
            W.W_Print_master('print', varargin{:});
        end
        function warning(varargin)
            W.W_Print_master('warning', varargin{:});
        end
        function error(varargin)
            W.W_Print_master('error', varargin{:});
        end
        function disp(strs, option, varargin)
            if ~exist('option', 'var') || isempty(option)
                option = 'print';
            end
            strs = W.string(strs);
            if length(varargin) >= 1
                pfx = W.string(varargin{1});
            else
                pfx = "";
            end
            if length(varargin) >= 2
                sfx = W.string(varargin{2});
            else
                sfx = "";
            end
            for i = 1:length(strs)
                W.W_Print_master(option, '%s%s%s', pfx, strs(i), sfx);
            end
        end
        %% extended
        % print ......
        function print_ellipsis(files, varargin)
            W.disp(files, W.decell(varargin), '...... ');
        end
        % print bullet points with -
        function print_bullet(strs, varargin)
            W.disp(strs, W.decell(varargin), '      -');
        end
        %% base functions
        function W_Print_execute(option, str, varargin)
            if ~exist('str', 'var')
                str = '';
            end
            switch option
                case 'print'
                    fprintf(strcat(str,'\n'), varargin{:});
                case 'warning'
                    cprintf('_Magenta', ['[W-Warning] ' char(str) '\n'], varargin{:});
                case 'error'
                    cprintf('Red', ['[W-Error] ' char(str) '\n'], varargin{:});
            end
        end
    end
    methods(Static, Access = protected)
        function W_Print_master(varargin)
            global Options_W_Print
            if ~isempty(Options_W_Print) && strcmp(Options_W_Print, 'mute')
                return;
            end
            W.W_Print_execute(varargin{:});
        end
    end
end