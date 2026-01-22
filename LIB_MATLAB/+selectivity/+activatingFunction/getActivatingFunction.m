function Vzz = getActivatingFunction(Ve)
%getActivatingFunction 
%   Send just the voltage for the different nodes of one fiber, and the
%   activating function is sent back.

    if ~isvector(Ve)
        error('selectivity:utilities:getActivatingFunction', 'You must enter a vector corresponding to the external voltage nodes');
    end

    Ve1 = Ve(1:end-2);
    Ve2 = Ve(2:end-1);
    Ve3 = Ve(3:end);

    Vzz = Ve3+Ve1-2*Ve2;




end

