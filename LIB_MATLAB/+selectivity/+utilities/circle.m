function [x, y] = circle(centerXY, R, nPoints)
% send back xy coordinates of a circle of centerXY and radius R
    ang = linspace(0, 2*pi, nPoints);
    x = [centerXY(1)+R*cos(ang)]';
    y = [centerXY(2)+R*sin(ang)]';
    %xy = [x y];
end