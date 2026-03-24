function output = SW_wrapper_cell_trials(func, idx, varargin)
    if ~iscell(idx.idx_trials) % autofix if idx is not generated properly in the cell format
        idx.idx_trials = W.arrayfun(@(x)idx.idx_trials(:,x), 1:size(idx.idx_trials, 2), false);
        ncond = length(idx.idx_trials);
    else
        ncond = idx.ncond;
    end
    result = cell(1, ncond);
    func = W.str2func(func);
    ninput = length(varargin);
    assert(ninput >= 1);
    if ninput >= 2
        spikes = varargin{1};
        games = varargin{2};
        varargin = varargin(3:end);
    else
        spikes = varargin{1};
    end
    for ci = 1:ncond
        [v1, is1] = get_values_by_cond(ci, idx.condlabel, spikes);
        flag = false;
        if ~is1 && isstruct(spikes) 
            v1 = W.select_cells(spikes, idx.idx_cells{ci});
            flag = true;
        else
            v1 = v1{1};
        end
        if ninput == 1
            result{ci} = func(v1);
            continue;
        end
        [v2, is2] = get_values_by_cond(ci, idx.condlabel, games);
        if ~is2
            if istable(games)
                if flag
                    [v1, v2] = W.select_trials(v1, games, idx.idx_trials{ci});
                else
                    v2 = games(idx.idx_trials{ci}, :);
                end
            else
                v2 = v2{1};
            end
            if size(v2,1) == 0 % no trial
                result{ci} = [];
                continue;
            end
        else
            v2 = v2{1};
        end
        vars = get_values_by_cond(ci, idx.condlabel, varargin{:});
        result{ci} = func(v1, v2, vars{:});
    end
    if idx.convert2struct
        output = W.varargin2struct_namesfirst(idx.condlabel, result);
    else
        output.result = result;
        output.idx = idx;
    end
end
function [vars, iscondstruct] = get_values_by_cond(ci, conds, varargin)
    conds = W.vert(W.string(conds));
    nvar = length(varargin);
    vars = cell(1, nvar);
    iscondstruct = zeros(1, nvar);
    for vi = 1:nvar
        tvar = varargin{vi};
        if isstruct(tvar) && isequal(W.fieldnames(tvar), conds)
            vars{vi} = tvar.(conds(ci));
            iscondstruct(vi) = 1;
        else
            vars{vi} = tvar;
        end
    end
end