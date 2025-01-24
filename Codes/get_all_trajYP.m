function alltraj = get_all_trajYP(d, option)
    ncell = length(d.cells);
    traj = cell(1, ncell);
    for i = 1:ncell
        tcell = d.cells{i};
        tg = d.games{d.info_cells.gameID(i)};
        switch option
            case "YP"
                traj{i} = W.arrayfun_vertcat(@(x)W.avse(tcell(tg.condition == x & tg.cue1 == "yellow", :)) - ...
                    W.avse(tcell(tg.condition == x & tg.cue1 == "purple", :)), 1:9);
            case "release"
                 traj{i} = W.arrayfun_vertcat(@(x)W.avse(tcell(tg.condition == x & tg.release1 == 1, :)) - ...
                    W.avse(tcell(tg.condition == x & tg.release1 == 0, :)), 1:9);
            case "accept"
                traj{i} = W.arrayfun_vertcat(@(x)W.avse(tcell(tg.condition == x & tg.choice == 1, :)) - ...
                    W.avse(tcell(tg.condition == x & tg.choice == 0, :)), 1:9);
            case "hold"
                traj{i} = W.arrayfun_vertcat(@(x)W.avse(tcell(tg.condition == x & tg.cue1 == "yellow" & tg.release1 == 0, :)) - ...
                    W.avse(tcell(tg.condition == x & tg.cue1 == "purple" & tg.release1 == 0, :)), 1:9);

            case "unhold"
                traj{i} = W.arrayfun_vertcat(@(x)W.avse(tcell(tg.condition == x & tg.cue1 == "yellow" & tg.release1 == 1, :)) - ...
                    W.avse(tcell(tg.condition == x & tg.cue1 == "purple" & tg.release1 == 1, :)), 1:9);
        end
    end
    alltraj = W.cell_NxMK2KxMN(W.cellfun(@(x)x',traj));
end