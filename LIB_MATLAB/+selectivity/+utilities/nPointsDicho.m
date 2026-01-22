function points = nPointsDicho(level, nProc)
    points = nProc; %init
        for k=2:level
            points = points + (points-1)*nProc;
        end
end
        