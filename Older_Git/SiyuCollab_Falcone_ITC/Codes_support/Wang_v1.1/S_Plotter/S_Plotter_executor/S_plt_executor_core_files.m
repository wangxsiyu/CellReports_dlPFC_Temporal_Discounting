classdef S_plt_executor_core_files < S_plt_base
    methods
        function execute_save(obj, filename, varargin) % varargin = extension
            if ~obj.param_files.issave 
                return;
            end
            if ~exist('filename', 'var') || isempty(filename)
                if isempty(obj.fig_savename)
                    return;
                end
                filename = obj.fig_savename;
            else
                filename = obj.savename(filename, varargin{:});
            end
            for ei = 1:length(filename)
                savename = filename(ei);
                if exist(savename, 'file')
                    W.warning('figure exists: %s', savename);
                end
                ext = W.files_get_ext(savename, 1);
                if strcmp(ext, 'mat')
                    planner = obj.planner;
                    W.save(savename, 'planner', planner);
                elseif ~isempty(obj.fig)
                    W.mkdir(W.foldernames(savename));
                    switch ext
                        case 'emf' % not sure if it works
                            if ispc
                                set(obj.fig.g, 'Color', 'white', 'Inverthardcopy', 'off');
                                print –dmeta;
                                print(obj.fig.g, savename, '-dmeta');
                            else
                                disp('unable to save .emf in mac');
                            end
                        case 'eps' % not sure if it works
                            exportgraphics(obj.fig.g, savename);
                        otherwise
                            saveas(obj.fig.g, savename, ext);
                    end
                end
            end
            obj.fig_savename = [];
        end
    end
end