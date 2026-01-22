function [value,isterminal,direction] = eventAPEnded(t,y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

nVariables  = numel(y);
nNoeuds     = nVariables/5;


isterminal  = 1; % stop the simulation if value pass by 0
value       = y(nNoeuds-2)-30e-3; % value to cross
direction   = 0; % detect all zero crossing
display(['value is ' num2str(value)]);

end

