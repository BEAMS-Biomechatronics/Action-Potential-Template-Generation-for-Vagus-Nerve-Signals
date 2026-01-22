function [C, Ceq] = nonLinConFindProgressivePoly4(x)

    b       = x(1);
    c       = x(2);
    
    
    timeSpline          = [0 0.5e-3 0.8e-3 1e-3];
    currentSplineWF     = [0 b c 1];
    currentSplineWF     = [(currentSplineWF(2)-currentSplineWF(1))/(timeSpline(2)-timeSpline(1)) currentSplineWF 0];
    Spl                 = spline(timeSpline, currentSplineWF);
    dSpl                = fnder(Spl,1);
    times               = [0:5e-5:1e-3];
    
    % Ceq    = 0
    Ceq     = 0;
    
    % C <=0
    
    %polyValues  = -ppval(dSpl, times)
    
    C           = 0;%max(polyValues);
end