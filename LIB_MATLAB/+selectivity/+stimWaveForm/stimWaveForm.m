classdef (Abstract) stimWaveForm < handle
    %STIMWAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    properties (Abstract)
        TPulseGlobal;
        TTransition;
        
        
    end
    
    methods (Abstract)
        % do not forget to define the constructor in the inheritance class
        % as usual 
        o = setParameters(arg)
        o = saveParameters(arg)
        o = WF(arg)
        o = plotWaveForm(arg)
    end
    
end

