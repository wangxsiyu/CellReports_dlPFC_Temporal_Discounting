classdef W_Neuro_Import_nev < handle
    methods(Static)
        function event = import_nev(filename)
            W.library('NPMK')
            filename = char(filename);
            W.print('reading NEV: %s', filename);
            nev = openNEV(filename);
            event = table;
            event.eventmarkers = nev.Data.SerialDigitalIO.UnparsedData;
            event.timestamps = nev.Data.SerialDigitalIO.TimeStampSec';
        end
    end
end