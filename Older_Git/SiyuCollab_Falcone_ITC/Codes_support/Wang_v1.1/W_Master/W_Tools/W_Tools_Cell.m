classdef W_Tools_Cell < handle
    methods(Static)
        %% encell/decell
        function a = decell(a)
            while iscell(a) && length(a) == 1
                a = a{1};
            end
        end
        function a = decell_once(a)
            if iscell(a) && length(a) == 1
                a = a{1};
            end
        end
        function a = encell(a)
            if ~iscell(a)
                a = {a};
            end
        end        
        function a = encell1(a) % {a}
            if ~iscell(a) || length(a) > 1
                a = {a};
            end
        end
        function a = encell_1layer(a)
            a = W.encell(W.decell(a));
        end
        %% cell size
        function out = cell_length(a)
            if ~iscell(a)
                W.error('cellsize: input not cell')
                return
            end
            out = cellfun(@(x)length(x), a);
        end
        function out = cell_size(a, dim)
            if ~iscell(a)
                W.error('cellsize: input not cell')
                return
            end
            out = cellfun(@(x)size(x,dim), a);
        end
        %% cell format
        function [a, tid] = cell_squeeze(a)
            tid = cellfun(@(x)~W.isempty(x), a);
            tid = find(tid);
            a = a(tid);
        end
        %% cell of struct to table
        function out = cellofstruct2table(cellofstruct, isforce)
            if ~exist('isforce', 'var') 
                isforce = false;
            end
            cellofstruct = W.encell(cellofstruct);
            % change format to a table
            sz = unique(W.fieldsize(cellofstruct{1},[],1));
            if length(sz) == 1 || isforce
                if length(sz) == 1
                    sz1 = sz;
                else
                    sz1 = 1;
                end
                varnames = W.fieldnames(cellofstruct{1});
                for vi = 1:length(varnames)
                    nm = varnames{vi};
                    szvar = unique(W.cellfun(@(x)size(W.decell(x.(nm)), 1), cellofstruct));
                    if length(szvar) ~= 1 || any(szvar ~= sz1)
                        cellofstruct = W.cellfun_assign_to_cellofstruct(cellofstruct, nm, @(x)W.encell(x.(nm)), cellofstruct);
                    else
                        cellofstruct = W.cellfun_assign_to_cellofstruct(cellofstruct, nm, @(x)W.decell(x.(nm)), cellofstruct);
                    end
                end
            end
            if length(unique(W.fieldsize(cellofstruct{1},[],1))) == 1 
                varnames = W.fieldnames(cellofstruct{1});
                out = table;
                for vi = 1:length(varnames)
                    nm = varnames{vi};
                    tlv = W.cellfun_vertcat(@(x)x.(nm), cellofstruct, false);
                    out.(nm) = tlv; %W.vert(tlv);
                end
            else
                out = cellofstruct;
            end
        end
        %% special - NMK 2 KMN
        function out = cell_NxMK2KxMN(x)
            N = length(x);
            [M, K] = size(x{1});
            % N cell{M x K} -> K cell{M x N}
            out = cell(1, K);
            for ki = 1:K
                out{ki} = NaN(M, N);
                for ni = 1:N
                    out{ki}(:,ni) = x{ni}(:, ki);
                end
            end
        end
        
    end
end