function parametersDot()
%PARAMETERSDOT generateDefaultParameters
%   Those are default parameters for dot configuration
%   If you want to change one of those parameters, first run this file, then
%   update parametersChange with new values. 

dotsNRevolve            = 5;
dotsNLongitudinal       = 10;
dotsWidth               = 0.1e-3;
dotsLength              = 0.1e-3;
dotsDepth               = 50e-6;
dotsOffCenter           = 0.65e-3;
dotsZFirst              = -5e-3;
dotsZLast               = 5e-3;


if exist('parameters.mat', 'file') == 2
    load('parameters.mat');
end

if exist('parametersChange.mat', 'file') == 2
    load('parametersChange.mat');
end
    
save('parametersDot.mat');
save('parameters.mat');



end

