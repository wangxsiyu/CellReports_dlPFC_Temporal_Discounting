classdef W_Tools_String < handle
    methods(Static)
        function strs = string(x)
            % turn cellstr, cellchar, char, array of numbers, into strings
%             x = W.decell(x);            
%             if isnumeric(x)
%                 strs = string(arrayfun(@(t)num2str(t), x, 'UniformOutput', false));
%             else
%                 strs = string(x);
%             end
            strs = string(x); % matlab default seems to work just fine!
        end
        %% string to cell
        function out = str2cell(str)
            % str2cell: turn arrays of strings to cell arrays of chars
            if isempty(str)
                out = {};
                return;
            end
            if W.is_stringorchar(str) % if string/char
                out = W.arrayfun(@(x)char(x), W.string(str), false);
            elseif iscell(str)
                for i = 1:length(str)
                    str{i} = W.decell(W.str2cell(str{i}));
                end
                out = str;
            else
                out = W.encell(str);
            end
% old code bug - {["a", "b"]} -> {'ab'} instead of {'a','b'}
%             elseif iscell(str) && all(W.cellfun(@(x)W.is_stringorchar(x), str), 'all')
%                 out = W.cellfun(@(x)W.decell(W.arrayfun(@(t)char(t), x)), str, false);
        end
        function out = str_parse2cell(strs, sep)
            % str_parse2cell: turn strings separated by sep = ',' into string arrays 
            if ~exist('sep', 'var') || isempty(sep)
                sep = ',';
            end
            strs = string(strs);
            out = arrayfun(@(x)strsplit(x, sep), strs, 'UniformOutput', false);
            LEN = max(W.cell_length(out));
            out = cellfun(@(x)W.extend(x, LEN), out, 'UniformOutput', false);
            out = vertcat(out{:});
        end
        %% cell en-string
        function out = cell_enstr(x)
            x = W.str2cell(x);
            out = cellfun(@(t)string(t), x, 'UniformOutput', false);
        end
        %% check single variable
        function out = is_stringorchar(x)
            out = ischar(x) || isstring(x);
        end
        function out = is_stringorchar1(x)
            out = ischar(x) || (isstring(x) && length(x) == 1);
        end
        %% string to number
        function [out, idxselect] = str_select(str, option)
            % options in isstrprop
            if ~exist('option', 'var') || isempty(option)
                option = 'digit';
            end
            option = char(option);
            if contains(option, '!')
                option = option(2:end);
                opt_rev = 1;
            else
                opt_rev = 0;
            end
            str = W.decell(str); % deal with {"str"}
            str = char(str);
            idxselect = isstrprop(str, option);
            if opt_rev == 1
                option = 'rev';
                idxselect = ~idxselect;
            end
            if ~any(idxselect, 'all')
                out = W.iif(strcmp(option, 'digit'), NaN, '');
            else
                tidxnum = find(idxselect);
                tword = [0 find(diff(tidxnum) > 1) length(tidxnum)] + 1;
                nword = length(tword) - 1;
                out = cell(1, nword);
                for i = 1:nword
                    out{i} = str(tidxnum(tword(i):tword(i+1)-1));
                end
                if strcmp(option, 'digit')
                    out = cellfun(@(x)str2double(x), out);
                end
            end
            out = W.decell(out);
        end
        function [out, idxselect] = strs_select(strs, varargin)
            strs = W.string(strs);
            out = cell(1, length(strs));
            idxselect = cell(1, length(strs));
            for i = 1:length(strs)
                [out{i}, idxselect{i}] = W.str_select(strs(i), varargin{:});
            end
            out = W.decell(out);
            if iscell(out) && all(cellfun(@(x)isnumeric(x), out)) && ...
                    length(unique(W.cell_length(out))) == 1
                out = vertcat(out{:});
            end
            idxselect = W.decell(idxselect);
        end
        %% select between patterns
        function out = str_selectbetween2patterns(str, spre, spost, npre, npost)
            if ~exist('npre','var') || isempty(npre)
                npre = 1;
            end
            if ~exist('npost','var') || isempty(npost)
                npost = 1;
            end
            if ~exist('spre','var')
                spre = [];
            end
            if ~exist('spost','var')
                spost = [];
            end
            str = char(str);
            if isempty(spre)
                n1 = 1;
            else
                spre = char(spre);
                idxpre = strfind(str, spre);
                if npre < 0 % choose according to the inverse order, -1 is the last 
                    npre = length(idxpre) + 1 + npre;
                end
                n1 = idxpre(npre) + length(spre);
            end
            if isempty(spost)
                n2 = length(str);
            else
                spost = char(spost);
                idxpost = strfind(str, spost);
                if npost < 0 % choose according to the inverse order, -1 is the last 
                    npost = length(idxpost) + 1 + npost;
                end
                n2 = idxpost(npost) - 1;
            end
            out = string(str(n1:n2));
        end
        function out = strs_selectbetween2patterns(strs, varargin)
            strs = W.string(strs);
            out = W.arrayfun(@(x)W.str_selectbetween2patterns(x, varargin{:}), strs);
        end
        %% strcat
        function str = strcat(varargin)
            varargin = W.cell_enstr(varargin);
            varargin = varargin(W.cell_length(varargin)>0);
            str = strcat(varargin{:});
        end
        function str = str_join(str, sconnector)
            if ~exist('sconnector', 'var') 
                sconnector = "_";
            end
%             str = W.cell_enstr(str);
            str = W.string(str);
            str = strjoin(str, sconnector);
        end
        function str = str_paste(varargin)
            str = W.str_join(W.decell(varargin), '');
        end
        %% format 
        % remove '.' or '_'
        function out = str_dedot(str, opt_str)
            if ~exist('opt_str', 'var') || (isempty(opt_str) && ~W.is_stringorchar(opt_str))
                opt_str = ' ';
            end
            out = replace(str, '.', opt_str);
        end
        function out = str_de_(str, opt_str)
            if ~exist('opt_str', 'var') || (isempty(opt_str) && ~W.is_stringorchar(opt_str))
                opt_str = ' ';
            end
            out = replace(str, '_', opt_str);
        end
        % capitalize first letter
        function str = str_capitalize1(str)
            str = W.str2cell(str);
            idnonempty = W.cell_length(str) > 0;
            if any(idnonempty)
                str(idnonempty) = W.cellfun(@(x)W.strcat(upper(x(1)), x(2:end)), str(idnonempty), false);
            end
            str = W.string(str);
        end
        %% extended functions
        % select which string matches certain templates/patterns
        function [id, patterns] = strs_find_matches(strs, patterns)
            strs = W.str2cell(strs);
            if ~exist('patterns', 'var') 
                patterns = unique(strs);
            end
            id = W.cellfun(@(x)W.extend(find(strcmp(x, patterns))), strs);
        end
        function [id] = strs_have_matches(varargin)
            id = W.strs_find_matches(varargin{:});
            id = ~isnan(id);
        end
    end
end