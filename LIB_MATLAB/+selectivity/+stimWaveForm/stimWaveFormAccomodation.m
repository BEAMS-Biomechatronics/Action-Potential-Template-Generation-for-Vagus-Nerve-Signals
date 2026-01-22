classdef stimWaveFormAccomodation < selectivity.stimWaveForm.stimWaveForm
    %STIMWAVEFORM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TPulseGlobal;
        TPulsePrepulse;
        TPulseSurounding;
        StartPulseGlobal;
        StartPulsePrepulse;
        StartPulseSurounding;
        TTransition;
        AmpPulseGlobal;
        AmpPulsePrepulse;
        AmpPulseSurounding;
    end
    
    methods
        function o = stimWaveForm(stimWaveFormParametersFileName)
            if  nargin == 0
                o.TPulseGlobal            = 0.0001;
                o.TPulsePrepulse          = 0.0001;
                o.TPulseSurounding        = 0.0001;
                o.StartPulseGlobal        = 0.0001; 
                o.StartPulsePrepulse      = 0.0001;
                o.StartPulseSurounding    = 0.0001;
                o.TTransition             = 1e-6;
                o.AmpPulseGlobal          = 1;
                o.AmpPulsePrepulse        = 1;
                o.AmpPulseSurounding      = 1;
            else
                load(stimWaveFormParametersFileName);
                o.TPulseGlobal            = TPulseGlobal;
                o.TPulsePrepulse          = TPulsePrepulse;
                o.TPulseSurounding        = TPulseSurounding;
                o.StartPulseGlobal        = StartPulseGlobal; 
                o.StartPulsePrepulse      = StartPulsePrepulse;
                o.StartPulseSurounding    = StartPulseSurounding;
                o.TTransition             = TTransition;
                o.AmpPulseGlobal          = AmpPulseGlobal;
                o.AmpPulsePrepulse        = AmpPulsePrepulse;
                o.AmpPulseSurounding      = AmpPulseSurounding;
            end
        end
        
        function setParameters(o, TPulseGlobal, TPulsePrepulse, TPulseSurounding, StartPulseGlobal, StartPulsePrepulse, StartPulseSurounding, TTransition, AmpPulseGlobal, AmpPulsePrepulse, AmpPulseSurounding)
            o.TPulseGlobal          = TPulseGlobal;
            o.TPulsePrepulse        = TPulsePrepulse;
            o.TPulseSurounding      = TPulseSurounding;
            o.StartPulseGlobal      = StartPulseGlobal;
            o.StartPulsePrepulse    = StartPulsePrepulse;
            o.StartPulseSurounding  = StartPulseSurounding;
            o.TTransition           = TTransition;
            o.AmpPulseGlobal        = AmpPulseGlobal;
            o.AmpPulsePrepulse      = AmpPulsePrepulse;
            o.AmpPulseSurounding    = AmpPulseSurounding;
        end
        
        function saveParameters(o)
            TPulseGlobal            = o.TPulseGlobal;
            TPulsePrepulse          = o.TPulsePrepulse;
            TPulseSurounding        = o.TPulseSurounding;
            StartPulseGlobal        = o.StartPulseGlobal;
            StartPulsePrepulse      = o.StartPulsePrepulse;
            StartPulseSurounding    = o.StartPulseSurounding;
            TTransition             = o.TTransition;
            AmpPulseGlobal          = o.AmpPulseGlobal;
            AmpPulsePrepulse        = o.AmpPulsePrepulse;
            AmpPulseSurounding      = o.AmpPulseSurounding;
            save(sprintf('stimWaveFormParameters.mat'),  'TPulseGlobal', 'TPulsePrepulse', 'TPulseSurounding', 'StartPulseGlobal', 'StartPulsePrepulse', 'StartPulseSurounding', 'TTransition', 'AmpPulseGlobal', 'AmpPulsePrepulse', 'AmpPulseSurounding');
        end
        
        function [WFBlock, WFPush] = WF(o,t)
            %   Calcul de la forme d'onde pour les électrodes blocantes
            %   (Electrodes Surounding)
            %   Deux parties :
            %       - PrePulse polarisante pour conditionner le nerf
            %       - Pulse qui va déclencher des AP sur le pourtour pour bloquer
            %         les APs générés par les électrodes "push". 
            
            
            %display('t');
            %t
            % Electrode 'surounding'
            WFPrepulse          = o.AmpPulsePrepulse    * (1-sigmf(t,[1/o.TTransition o.TPulsePrepulse+o.StartPulsePrepulse])) * sigmf(t,[1/o.TTransition o.StartPulsePrepulse]);
            WFSurounding        = o.AmpPulseSurounding  * ( (1-sigmf(t,[1/o.TTransition o.TPulseSurounding+o.StartPulseSurounding])) * (sigmf(t,[1/o.TTransition o.StartPulseSurounding]))) ;
            
            WFBlock             = WFPrepulse + WFSurounding;
            % Electrode 'Push' doivent permettre de balancer un AP dans
            % toute la section du nerf pour toutes les tailles de fibre. 
            
            WFPush              = o.AmpPulseGlobal      * (1-sigmf(t,[1/o.TTransition o.TPulseGlobal+o.StartPulseGlobal])) * sigmf(t,[1/o.TTransition o.StartPulseGlobal]);
        end
        
        % plotWaveForm(intervalle) plot the waveForm of the current
        % WaveForm object.
        function  plotWaveForm(o,intervalle)
            figure();
            data            = o.WF(intervalle);
            WFBlock         = data(1,:);
            WFPush          = data(2,:);
            
            plot(intervalle*1e3, WFBlock*1e3);
            
            xlabel('time [ms]');
            ylabel('pulse Wave Form [mA]');
            legend('WFBlock');
            
            hold on;
            
            plot(intervalle*1e3, WFPush*1e3);
            
        end
        
         % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = feval(class(this));

            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                new.(p{i}) = this.(p{i});
            end
        end
        
    end
    
   

    
end

