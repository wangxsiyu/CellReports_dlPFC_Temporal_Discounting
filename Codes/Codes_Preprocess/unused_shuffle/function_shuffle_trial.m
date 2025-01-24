function st = function_shuffle_trial(st)
    for ci = 1:length(st.cells)
        cl = st.cells{ci};
        ntrial = st.info_session.nMaxTrial;
        cl.trialID = W.changem(cl.trialID, W.shuffle(1:ntrial), 1:ntrial);
        cl = sortrows(cl, 'trialID');
        st.cells{ci} = cl;
    end
end