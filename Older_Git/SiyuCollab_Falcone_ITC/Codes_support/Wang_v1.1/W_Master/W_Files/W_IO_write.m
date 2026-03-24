classdef W_IO_write < handle
    methods(Static)
        %% save
        function save(file, varargin)
            nvar = length(varargin);
            varlist = {};
            i = 0;
            while i+2 <= nvar
                varname = varargin{i+1};
                if W.is_stringorchar(varname)
                    varname = char(varname);
                else
                    W.error('save: expecting char for variable names');
                    return;
                end
                varval = varargin{i+2};
                eval([varname '= varval;']);
                varlist{end+1} = varname;
                i = i + 2;
            end
            W.mkdir(fileparts(file));
            file = W.enext(file, 'mat');
            if exist(file, "file")
                W.print('overwriting file %s', file);
                delete(file);
            end
            save(file, varlist{:}, '-v7.3', varargin{i+1:end});
            W.print('saved successfully: %s', file)
        end
    end
end