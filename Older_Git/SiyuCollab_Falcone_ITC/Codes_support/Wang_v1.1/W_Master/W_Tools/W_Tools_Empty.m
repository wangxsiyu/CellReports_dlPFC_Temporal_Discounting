classdef W_Tools_Empty < handle
    methods(Static)
        function out = isempty(a)
            a = W.decell(a);
            switch class(a)
                case 'struct'
                    out = isempty(a) || isequal(a, struct);
                case 'string'
                    out = isempty(a) || isequal(a, "");
                otherwise
                    out = isempty(a);
            end
        end
        function a = empty2cell(a)
            if W.isempty(a)
                a = {};
            else
                a = W.encell(a);
            end
        end
        %% create_dtype
        function out = create_dtype(dtype, sz)
            if ~exist('sz', 'var') || isempty(sz)
                sz = 1;
            end
            switch dtype
                case 'cell'
                    out = cell(sz);
                case {'double','logical','numeric'}
                    out = nan(sz);
                case 'char'
                    out = repmat(' ', sz); % this may only create an empty char array
                case 'string'
                    out = repmat("", sz);
                case 'datetime'
                    out = NaT(sz);
                case 'duration'
                    out = repmat(duration, sz);
                case 'table'
                    assert(sz == 0);
                    out = table;
                case 'struct'
                    assert(sz <= 1);
                    out = struct;
                otherwise
                    out = [];
                    W.warning('empty_create: dtype not recognized: %s', dtype);
            end
        end
    end
end