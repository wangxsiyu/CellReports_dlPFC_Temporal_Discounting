function param_plt = SW_plot_parameters()
    % version - Wang default
    param.pixel_gap_h = 20;
    param.pixel_gap_w = 30;
    param.pixel_margin = [20, 20, 30, 20];
    param.pixel_xlab = 50;
    param.pixel_ylab = 60;
    param.pixel_title = 25;
    param.pixel_h = 300;
    param.pixel_w = 300;

    param.fontsize_axes = 12;
    param.fontsize_label = 15;
    param.fontsize_title = 18;
    param.fontsize_leg = 9;

    param.addABCs_offset = [-60 5];
    param.addABCs_offset_title = 20;

    param.linewidth = 2;
    param.markersize = 7;
    param.dotsize = 9;
    param.capsize_errorbar = 6;

    param_plt.default = param;
end
