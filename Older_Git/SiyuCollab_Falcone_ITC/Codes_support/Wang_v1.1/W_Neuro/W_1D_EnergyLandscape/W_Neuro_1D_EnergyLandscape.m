classdef W_Neuro_1D_EnergyLandscape < handle
    methods(Static)
%         function out = EL1D_by_condnames(x1D, games, time_at, name_choice, name_cond, varargin)
%             c = games.(name_choice);
%             cond = games.(name_cond);
%             out.ELchoice = W.EL1D_by_cond(x1D, time_at, c, varargin{:});
%             out.ELcue = W.EL1D_by_cond(x1D, time_at, cond, varargin{:});
%             % wait to implement choice by cue
% %             out.ELchoiceXcue = 
%         end
        function out = EL1D_bycond(x1D, time_at, condID, varargin)
            if ~exist('condID', 'var') || isempty(condID)
                condID = ones(1,size(x1D,1));
            end
            conds = W.unique(condID, 0);
            for ci = 1:length(conds)
                idx = condID == conds(ci);
                tout = W.EL1D_by_time(x1D(idx,:), time_at, varargin{:});
                if ci == 1
                    out = tout;
                    out.EL = W.encell(out.EL);
                    out.grad = W.encell(out.grad);
                    out.ste_grad = W.encell(out.ste_grad);
                else
                    out.EL{end+1} = tout.EL;
                    out.grad{end+1} = tout.grad;
                    out.ste_grad{end+1} = tout.ste_grad;
                end
            end
            out.conds = conds;
        end
        function out = EL1D_by_time(x1D, time_at, npool, nstep, varargin)
            if ~exist('time_at', 'var') || isempty(time_at)
                time_at = 1:size(x1D,2);
            end
            if ~exist('npool', 'var') || isempty(npool)
                npool = 1;
            end
            if ~exist('nstep', 'var') || isempty(nstep)
                nstep = 1;
            end
            ntime = length(time_at);
            if isinf(npool)
                nstep = 1;
                npool = ntime - 1;
            end
            out.nstep = nstep;
            out.npool = npool;
            EL = [];
            grad = [];
            ste_grad = [];
            tm_EL = [];
            for bi = 1:(ntime-npool+1-nstep)
                tx2 = x1D(:,(bi+nstep):(bi+npool-1+nstep));
                tx1 = x1D(:, bi:(bi+npool-1));
                tdx = tx2 - tx1;
                x = reshape(tx1,[],1);
                dx = reshape(tdx,[],1);
                [EL(bi,:), grad(bi,:), ste_grad(bi, :), x_at] = ...
                    W.EL1D(x, dx, varargin{:});
                tm_EL(bi) = mean([time_at(bi:(bi+npool-1)), ...
                    time_at((bi:(bi+npool-1)) + nstep)]);
            end
            out.x_at = x_at;
            out.EL = EL;
            out.grad = grad;
            out.ste_grad = ste_grad;
            out.time_at = tm_EL;
        end
        function [EL, grad, ste_grad, x_EL] = EL1D(x, dx, xbins, varargin)
            if ~exist('xbins', 'var') || isempty(xbins)
                xbins = linspace(min(x),max(x), 100);
            end
            x_EL = W.bin_middle(xbins);
            [grad, ste_grad] = W.bin_avY_byX(dx, x, xbins);
            [EL, grad] = W.EL1D_integral(grad, x_EL, varargin{:});
        end
        function [EL, grad] = EL1D_integral(grad, x_EL, varargin)
            grad = W.horz(grad);
            EL = [];
            for rowi = 1:size(grad,1)
                if ~isnan(grad(rowi,1))
                    bound1 = 0;
                else
                    bound1 = find(diff(isnan(grad(rowi,:))) == -1, 1);
                end
                if ~isnan(grad(rowi,end))
                    bound2 = length(grad(rowi,:))+1;
                else
                    bound2 = find(diff(isnan(grad(rowi,:))) == 1, 1, 'last') + 1;
                end
                idx_outbound = [1:bound1, bound2:length(grad(rowi,:))];
                grad(rowi,isnan(grad(rowi,:))) = 0;
                EL(rowi,:) = -cumsum(grad(rowi,:));
                EL(rowi,idx_outbound) = NaN;
                grad(rowi,idx_outbound) = NaN;
            end
            EL = W.EL1D_reference(EL, x_EL, varargin{:});
        end
        function EL = EL1D_reference(EL, x_EL, reference0)
            if ~exist('reference0', 'var') || isempty(reference0)
                reference0 = mean(x_EL);
            end
            idx0 = arrayfun(@(x)dsearchn(W.vert(x_EL), x), reference0);
            for rowi = 1:size(EL,1)
                EL0 = mean(EL(rowi,idx0));
                EL(rowi,:) = EL(rowi,:) - EL0;
            end
        end
    end
end