classdef W_IO_commands < handle
    methods(Static)
        function out = ls(dirs, varargin) % list all files in directories
            dirs = W.string(dirs);
            out = W.arrayfun(@(x)W.dir(x, varargin{:}).fullpath, dirs);
            out = W.decell(out);
        end
        function [outtab, out] = dir(str, option) % get all files in a directory
            % by default, output table
            arguments
                str char;
                option char = 'all';
                % all - both
                % file - files only
                % folder/dir - folders only
                % .ext - select certain file extentions
            end
            % exclude . ..
            out = dir(str);
            out = out(arrayfun(@(x)~any(strcmp({'.','..'}, x.name)), out));
            % exclude hidden files
            out = out(arrayfun(@(x)~strcmp(x.name(1), '.'), out));
            % select files or directory
            switch option
                case 'file'
                    out = out([out.isdir] == 0);
                case {'folder', 'dir'}
                    out = out([out.isdir] == 1);
                otherwise
                    if option(1) == '.'
                        tid = W.files_is_ext({out.name}, option);
                        out = out(tid);
                    end
            end
            filename = string({out.name})';
            filepath = string({out.folder})';
            fullpath = fullfile(filepath, filename);
            outtab = table(filename, filepath, fullpath);
        end
        %% extended commands
        function out = ls_if_dir(str, varargin)
            str = W.string(str);
            if length(str) == 1 && exist(str, 'dir')
                W.print('unfolding folder: %s', str);
                out = W.ls(str, varargin{:});
            else
                out = str;
            end
        end
        %% copy files
        function copy_files(fd1, fd2, filenames, filenames_new)
            filenames = W.string(filenames);
            if ~exist('filenames_new', 'var') || isempty(filenames_new)
                filenames_new = filenames;
            end
            filenames_new = W.string(filenames_new);
            for fi = 1:length(filenames)
                fn = filenames(fi);
                fn1 = filenames_new(fi);
                fn = W.files_noext2mat(fn);
                fn1 = W.files_noext2mat(fn1);
                if strcmp(fn, fn1)
                    W.print('copying file %s', fn);
                else
                    W.print('copying file %s -> %s', fn, fn1);
                end
                for i = 1:length(fd1)
                    f1 = fullfile(fd1(i), fn);
                    f2 = fullfile(W.mkdir(fd2(i)), fn1);
                    W.print('copying %s to %s', f1, f2);
                    copyfile(f1, f2);
                end
            end
            W.print('copy complete', fn);
        end
        %% delete files
        function files_delete(varargin)
            files = W.string(varargin);
            files = W.files_noext2mat(files);
            for fi = 1:length(files)
                W.print('deleting file: %s', files(fi));
                if exist(files(fi), 'file')
                    delete(files(fi));
                else
                    W.warning('file does not exist: %s', files(fi));
                end
            end
        end
    end
end