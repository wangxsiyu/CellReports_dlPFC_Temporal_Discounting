classdef S_plt_files < S_handle
    properties
        param_files
        fig_savename
    end
    methods
        function obj = S_plt_files()
            obj.param_files = struct('issave', false, ...
                'savedir', '', ...
                'savepfx', '', ...
                'savesfx', '', ...
                'extension', {'jpg'});          
            obj.fig_savename = [];
        end
        function set_files(obj, varargin)
            obj.param_files = W.struct_set(obj.param_files, varargin{:});
            obj.param_files.extension = W.str2cell(obj.param_files.extension); 
        end
        %% save
        function is_skip = set_savename(obj, varargin)
            if ~obj.param_files.issave
                return;
            end
            [is_skip, obj.fig_savename] = obj.exist_savename(varargin{:});
            if is_skip
                W.print_exist_files(obj.fig_savename, 'print');
                return;
            end
        end
        function [is_skip, savenames] = exist_savename(obj, savename, extension)
            if ~exist('extension', 'var')
                extension = obj.param_files.extension;
            end
            savenames = W.cellfun(@(x) obj.savename(savename, x), extension);
            is_skip = W.file_exist_all(savenames) && ~obj.is_overwrite;
        end
        function filefullpath = savename(obj, savename, extension)
            savename = W.basenames(savename);
            if ~exist('extension', 'var')
                extension = W.decell(obj.param_files.extension);
            end
            savename = W.file_prefix(savename, obj.param_files.savepfx);
            savename = W.file_suffix(savename, obj.param_files.savesfx);
%             if strcmp(extension, 'mat')
%                 savename = W.deext(W.file_prefix(savename, 'FIGUREmat'));\
%             end
            savename = W.enext(savename, extension);
            filefullpath = fullfile(obj.param_files.savedir, savename);
        end     
    end
end