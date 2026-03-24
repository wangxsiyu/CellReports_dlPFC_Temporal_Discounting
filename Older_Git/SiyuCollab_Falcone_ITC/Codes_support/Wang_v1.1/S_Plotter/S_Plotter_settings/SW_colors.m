function S_colors = SW_colors()
    % standard colors
    S_colors.blue = [0,0,1];
    S_colors.red = [1,0,0];
    S_colors.green	= [0,1,0];
    S_colors.yellow = [1,1,0];
    S_colors.cyan = [0,1,1];
    S_colors.magenta = [1,0,1];
    S_colors.black = [0 0 0];
    S_colors.white = [1 1 1];
    S_colors.gray = [0.5 0.5 0.5];
    % Laopo Colors
    S_colors.LPred = [128,0,0];
    S_colors.LPyellow = [255, 69, 0];
    S_colors.LPgreen = [128, 128, 0];
    S_colors.LPblue = [0, 0, 139];
    S_colors.LPpurple = [128, 0, 128];
    S_colors.LPpink = [255, 105, 180];
    S_colors.LPbrown = [139, 69, 19];
    S_colors.LPgray = [112, 128, 144];
    % Randy Spalding Wall colors
    S_colors.RSred = [195, 75, 55];
    S_colors.RSyellow = [220, 150, 15];
    S_colors.RSpink = [210, 120, 80];
    S_colors.RSgreen = [55, 95, 80];
    S_colors.RSblue = [120, 145, 155];
    % UA colors
    % https://marcom.arizona.edu/brand-guidelines/colors
    S_colors.AZred = [171, 5, 32];
    S_colors.AZblue = [12, 35, 75];
    S_colors.AZwarmgray = [244, 237, 229];
    S_colors.AZcoolgray = [226, 233, 235];
    S_colors.AZmidnight = [0, 28, 72];
    S_colors.AZazurite = [30, 82, 136];
    S_colors.AZoasis = [55, 141, 189];
    S_colors.AZchili = [139, 0, 21];
    S_colors.AZbloom = [239, 64, 86];
    S_colors.AZcactus = [92, 135, 39];
    S_colors.AZsky = [129, 211, 235];
    S_colors.AZleaf = [112, 184, 101];
    S_colors.AZriver = [0, 125, 132];
    S_colors.AZmesa = [169, 92, 66];
    S_colors.AZsand = [241, 158, 31];
    S_colors.AZbrick = [74, 48, 39];  
    % adhoc colors 
    % WW - what/where
    S_colors.blue_WW = [85,86,165];
    S_colors.purple_WW = [180,80,158];
    S_colors.red_WW = [241,95,89];
    S_colors.green_WW = [102,188,71];
    %% format colors
    S_colors = W.structfun(@(x)W.iif(max(x)>1, x./256, x), S_colors);
end
