classdef W_IO_exist < handle
    methods(Static)
        function is_exist_all = file_exist_all(files, is_print)
            is_exist_all = all(W.file_exists(files));
            if exist('is_print', 'var') && is_print && is_exist_all
                W.print_exist_files(files, 'existall')
            end
        end
        function is_exists = file_exists(files)
            files = W.string(files);
            is_exists = arrayfun(@(x)W.exist(x, 'file') > 0, files);
        end
        function out = exist(filename, varargin)
            if ~exist('filename', 'var') || isempty(filename)
                out = false;
                return;
            end
            if any(contains(varargin, 'file'))
                text = W.files_get_ext(filename);
                if text == ""
                    filename = W.enext(filename, 'mat');
                end
            end
            out = exist(filename, varargin{:});
        end
        %% display message about existing files
        function print_exist_files(files, option)
            is_exists = W.file_exists(files);
            switch option
                case 'overwrite'
                    files = files(is_exists);
                    if ~isempty(files)
                        W.warning('[overwrite-on]');
                        W.print_ellipsis(files, 'warning');
                    end
                case 'existall'
                    if W.file_exist_all(files)
                        W.print('file(s) exist');
                        W.print_ellipsis(files);
                    end
            end
        end
    end
end