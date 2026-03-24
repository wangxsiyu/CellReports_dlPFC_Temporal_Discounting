function st = function_filter0(st)
    for ci = 1:length(st.cells)
        idx = sum(st.cells{ci},2) == 0;
        if any(idx)
            st.cells{ci}(idx,:) = NaN;
        end
    end
end