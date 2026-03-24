function plt = SW_fig(plt, varargin)
    [var, data] = W.varargin_get_celloptions({'axes', 'data_axes', 'varargin_axes', 'ABC_axes', 'nx', 'ny'}, ...
        varargin{:});
    nax = length(var.axes);
    if isempty(var.nx)
        var.nx = 1;
    end
    if isempty(var.ny)
        var.ny = nax/var.nx;
    end
    plt.figure(var.nx, var.ny);
    for i = 1:nax
        plt.ax(i);
        td = data(var.data_axes{i});
        tvar = W.encell(var.varargin_axes{i});
        plt = SW_ax(plt, var.axes{i}, td{:}, tvar{:});
    end
    plt.addABCs(var.ABC_axes{1});
    plt.update;
end