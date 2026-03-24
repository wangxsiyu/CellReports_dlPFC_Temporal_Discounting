classdef W_Neuro_1D_LinearDynamics < handle
    methods(Static)
        function [result] = fit_1Ddynamics(model, X, npool, nstep, varargin)
            x1D = X.x1D;
            ntime = size(x1D, 2);
            time_at = X.time_at;
            time_md = [];
            opt = S_optimizer;
            opt.set_loss_mode('L2');
            params = [];
            for bi = 1:(ntime-npool+1-nstep)
                W.print('time bin %d', bi);
                tx = x1D(:, bi:(bi+npool-1));
                ty = x1D(:,(bi+nstep):(bi+nstep+npool-1));
                x = reshape(tx,[],1);
                y = reshape(ty,[],1);
                tvars = W.cellfun(@(x)repmat(x, npool, 1), varargin, false);
                tparam = opt.optimize_model([], model, y, x, tvars{:});
                params = vertcat(params, tparam.params);
                time_md(bi) = mean([time_at(bi:(bi+npool-1)), ...
                    time_at((bi:(bi+npool-1)) + nstep)]);
            end
            params = model.format_params(params);
            result = W.struct('params', params, 'time_md', time_md, 'nstep', nstep, 'npool', npool);
        end
    end
end