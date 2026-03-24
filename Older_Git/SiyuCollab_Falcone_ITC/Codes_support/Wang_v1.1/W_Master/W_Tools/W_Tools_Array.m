classdef W_Tools_Array < handle
    methods(Static)
        %% vertical vs horizontal vector
        function a = vert(a)
            if size(a,1) == 1
                a = a';
            end
        end
        function a = horz(a)
            if size(a,2) == 1
                a = a';
            end
        end
        %% indexing
        function y = select(x, n, side)
            if ~exist('side', 'var')
                side = 'left';
            end
            if size(x,2) < n
                W.error('W.select: size(x,2) < n, check!');
                y = x;
                return
            end
            switch side
                case 'left'
                    y = x(:,1:n);
                case 'right'
                    y = x(:,end-n+1:end);
            end
        end
        % select column
        function out = col_select(a, id)
%             out = W.vert(W.arrayfun(@(x)W.nan_select(a(x, :), id(x)), 1:length(id)));
            id = W.horz(id);
            n = size(a, 2);
            id = dummyvar([id n]);
            id = id(1:end-1,:);
            out = sum(id .* a,2);
        end
        %% check if 1D array
        function out = is_1Darray(x)
            out = size(x,1) <= 1 || size(x,2) <= 1;
        end
        %% extend
        function y = extend(x, n, x_empty, side_extend)
            if ~exist('side_extend', 'var') || isempty(side_extend)
                side_extend = 'right';
            end
            if ~exist('n','var') || isempty(n)
                n = max(size(x,2), 1); % if x = [], n = 1
            end
            if ~exist('x_empty','var') || isempty(x_empty)
                x_empty = W.create_dtype(class(x));
            end
            if isempty(x_empty)
                W.warning('extend: unknown data type');
                y = [];
                return
            end
            if isempty(x) || size(x,1) == 0 % doesn't allow 0xN output
                x = x_empty;
            end
            switch side_extend 
                case 'right'
                    y = [x(:,1:min(size(x,2),n)) repmat(x_empty, size(x,1), n-size(x,2))];
                case 'left'
                    y = [repmat(x_empty, size(x,1), n-size(x,2)) x(:,1:min(size(x,2),n))];
            end
        end
    end
end