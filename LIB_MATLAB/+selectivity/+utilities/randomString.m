function ranString = randomString(lengthString)
    
%     alphabet = ['a':'z' '0':'9'];
%     lengthSET = length(alphabet);
%     ranString = alphabet(ceil(rand(1,lengthString)*lengthSET));

% Change the random String to date
x           = clock;
ranString   = [num2str(x(1)) '_' num2str(x(2)) '_' num2str(x(3)) '_h_' num2str(x(4)) '_' num2str(x(5))];

end

