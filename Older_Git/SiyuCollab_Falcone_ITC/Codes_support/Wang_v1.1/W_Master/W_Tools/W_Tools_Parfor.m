classdef W_Tools_Parfor < handle
    methods(Static)
        %% par
        function poolsize = parpool(npool)
            poolobj = gcp('nocreate'); % If no pool, do not create new one.
            if isempty(poolobj)
                poolsize = 0;
            else
                poolsize = poolobj.NumWorkers;
            end
            if poolsize == 0
                if exist('npool', 'var')
                    parpool(npool, 'IdleTimeout', Inf);
                else
                    parpool('IdleTimeout', Inf);
                end
            end
        end
        function parclose()
            poolobj = gcp('nocreate');
            delete(poolobj);
        end
    end
end