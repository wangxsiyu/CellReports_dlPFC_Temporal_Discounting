classdef W_Tools_Commands < handle
    methods(Static)
        %% unique
        function [out] = unique(x, varargin)
            if isnumeric(x)
                if ~isempty(varargin) && isnumeric(varargin{1})
                    [out] = W.unique_nan(x, varargin{1}, varargin{2:end});
                else
                    % by default, includes 1 NaN
                    [out] = W.unique_nan(x, [], varargin{:}); 
                end
            elseif iscell(x)
                [out] = unique(x, varargin{:});
            elseif W.is_stringorchar(x) % change char to string
                x = string(x);
                out = unique(x, varargin{:});
            else
%                 W.print('neither cell nor numeric: use regular unique');
                [out] = unique(x, varargin{:});
            end
        end
%         function [out] = unique_cell(x, varargin)
%             % this is the normal unique, but only includes cells that have
%             % strings in them
%             x = W.select_cellofstringorchar(x);
%             x = W.cell_enstr(x);
%             lenx = W.cell_length(x);
%             if ~(all(lenx == 1, 'all'))
%                 W.warning('unique_cell: some cells are character/string arrays, ignored');
%                 x = x(lenx == 1);
%             end
%             if iscell(x) % 'rows' option is not available for cells
%                 varargin = setdiff(varargin,'rows');
%             end
%             x = W.cell_enchar(x);
%             [out] = unique(x, varargin{:});
%         end
        function [out] = unique_nan(x, optionNaN, varargin)
            if ~any(isnan(x), 'all')
                out = unique(x, varargin{:});
                return;
            end
            if ~exist('optionNaN', 'var') || isempty(optionNaN)
                optionNaN = 1; 
                % 1 - includes a single NaN
                % 0 - excludes NaNs
            end
            ma = max(x(~isinf(x)), [],'all') + 1;
            if isnan(ma)
                ma = 0;
            end
            x = W.changem(x, ma);
            [x] = unique(x, varargin{:});
            x = W.changem(x, NaN, ma);
            if optionNaN == 0
                if W.is_1Darray(x)
                    x = x(~isnan(x));
                else
                    x = x(~all(isnan(x),2),:);
                end
            end
            out = x;
            if isempty(out) % never return []
                out = NaN(1, size(x,2));
            end
        end       
    end
end