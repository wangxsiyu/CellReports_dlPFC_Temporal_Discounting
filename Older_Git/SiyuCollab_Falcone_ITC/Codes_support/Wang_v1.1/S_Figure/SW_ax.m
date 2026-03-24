function varargout = SW_ax(plt, funcname, varargin)
    if nargout > 0
        varargout{1} = plt;
    end
    options_plt = {'xlim', 'ylim', 'xlabel', 'ylabel', 'zlabel', 'title', ...
        'xtick', 'xticklabel', 'xtickangle', 'ytick', 'yticklabel', 'ytickangle', ...
        'legend', 'legord', 'legloc'};
    [options, vars] = W.varargin_get_endoptions(options_plt, varargin{:});
    plt = S_fig.(funcname)(plt, vars{:});
    options = W.struct2cell(options);
    if ~isempty(options)
        plt.setfig_ax('overwrite', options{:});
    end
end