function mainpath = W_setdir(version)
    latestversion = '1.1';
    if ~exist('version', 'var') || isempty(version)
        version = latestversion;
    end
    if ~strcmp(version, latestversion)
        version = fullfile('Wang_archived_versions', sprintf('Wang_v%s', version));
    else
        version = sprintf('Wang_v%s', version);
    end
    [~,sysname] = system('hostname');
    sysname = strip(sysname);
    if ispc
        switch sysname
            case 'DESKTOP-WANG'
                mainpath = 'S:\Codes\SiyuCodes_MATLAB';
            case 'MH02217045DT'
                mainpath = 'E:\SiyuCodes_MATLAB';
            case 'MH02217195LT'
                mainpath = 'C:\wangxsiyu\Github\SiyuCodes_MATLAB';
            case "mh02030685wdi"
                mainpath = 'C:\Users\taswellc\OneDrive - National Institutes of Health\Documents\GitHub\SiyuCodes_MATLAB';
            case 'DESKTOP-QERBLIL'
                mainpath =  'E:\SiyuCodes_MATLAB';
            otherwise
                fprintf('error: need to set up Wang23_MATLAB dir for %s\n', sysname);
        end
    elseif ismac
        switch sysname
            case 'MH02183692MLI'
                mainpath = '/Users/taswellc/Documents/GitHub/SiyuCodes_MATLAB';
            case 'Yis-MacBook-Pro.local'
                mainpath = '/Users/wei/WEI/Wei/Wei_Project/SiyuCodes_MATLAB';
            otherwise
                mainpath = '~/WANG/Wang/SiyuCodes_MATLAB';
                fprintf('default - siyu''s macbook: %s\n', sysname);
        end
    end
    mainpath = fullfile(mainpath, version);
    fprintf('setting up Wang_MATLAB dir for PC %s:\n %s\n', sysname, mainpath);
    fprintf('version: %s\n', version);
    addpath(genpath(mainpath));
    clear sysname;
end
