function varargout = SW_wrapper_plt(func, plt, varargin)
%     [func, functype] = W.str2func(sprintf('FIGURE_%s', func));
    [func, functype] = W.str2func(func);
%     if strcmp(functype, 'S_fig.func')
%         plt.figure;
%         plt = func(plt, varargin{:});
%         plt.update;
%     else
    if nargout > 0
    	varargout{1} = func(plt, varargin{:});
    else
        func(plt, varargin{:});
    end
end