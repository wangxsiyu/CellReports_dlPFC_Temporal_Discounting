function plt = SW_plt_from_yml(yml, is_execute)
    pltyml = W.yaml_load(yml);
    if ~exist('is_execute', 'var')
        is_execute = true;
    end
    if isfield(pltyml, 'custom_vars')
        custom_vars = pltyml.custom_vars;
        pltyml = W.struct_sub(pltyml, 'custom_vars', 1);
    else
        custom_vars = [];
    end
    default = W.struct('issave', true, 'extension', {'jpg', 'svg', 'mat'});
    pltyml = W.struct_set(default, pltyml);
    pltyml.savedir = fullfile(W.foldernames(yml), pltyml.savedir);
    params = W.struct2cell(pltyml);
    plt = S_plt(params{:});
    plt.plt_switch.isexecute = is_execute;
    if ~isempty(custom_vars)
        plt.set_custom_variables(custom_vars);
    end
end