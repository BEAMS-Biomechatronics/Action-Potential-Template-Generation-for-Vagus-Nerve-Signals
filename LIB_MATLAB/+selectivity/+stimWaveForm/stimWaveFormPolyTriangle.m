classdef stimWaveFormPolyTriangle < selectivity.stimWaveForm.stimWaveForm & handle
    % This function acts as an input of the solver contained in the fiber
    % class. It generates a parametrized pulse which depends of a set of
    % polynomial coefficient, a pulse length, and maximum current pulse. 
    
    properties
        % Those properties are inherited from the abstract class. They are
        % common to all the waveForm classes. 
        TPulseGlobal;
        TTransition;
        
        % This property contains the coefficient of the polynome. 
        polyCoefficent;
        
        % The polynome is normalized by this value which is the maximum of
        % the polynome on the intervale t € [0; TPulseGlobal]
    end
   
    
    methods
        function o = stimWaveFormPolyTriangle()
                % default parameter
                o.TPulseGlobal              = 1e-3;                         % 1 ms
                o.TTransition               = 1e-6;                         % 1 µs
                
                o.polyCoefficent            = [0 1];                        % poly = 1 (square pulse)
                % Normalized wave Form
                o.polyCoefficent            = o.polyCoefficent*o.maxPulse;    % polyMax = maxPulse
        end
        
        
        
        
        
        %%
        
        function setParameters(o, TPulseGlobal, TTransition, maxPulse, polyCoefficient)
            % setParameters(TPulseGlobal, TTransition, maxPulse,
            % polyCoefficient).
            % Set the parameters and normalize the polynome to have maximum
            % value of it, in the range [0 TPulseGlobal] = to maxPulse
            
            % attribution 
            o.TPulseGlobal          = TPulseGlobal;
            o.TTransition           = TTransition;
            
            % computing max value of the polynome for the range [0 ; TpulseGlobal]
            maximumWaveForm         = max(polyval(polyCoefficient, linspace(0, TPulseGlobal, 200)));
            
            % Normalized the polynome to have a maximum in the range [0;
            % TPulseGlobal] = to MaxPulse
            o.polyCoefficent        = polyCoefficient/maximumWaveForm;
            
        end
        
        
        
        
        %%
        % Save the parameters in a file stimWaveFormParameters.mat
        function saveParameters(o)
            % Set to normal variable name
            TPulseGlobal              = o.TPulseGlobal;            % 1 ms
            TTransition               = o.TTransition;             % 1 µs
         
            polyCoefficent            = o.polyCoefficent;          % poly = 1 (square pulse)
                
            % Then save it to a file  
            save('stimWaveFormParameters.mat',  'TPulseGlobal', 'TTransition', 'polyCoefficent');
        end
        
        
        
        
        
        %%
        function WF = WF(o,t)
            % Calcul de la forme d'onde pour une pulse polygonale
            % Mettre o.Ve'*WF dans la fonction differentielle de la classe
            % fibre. 
            WF          = ((1-sigmf(t,[1/o.TTransition o.TPulseGlobal])) .* polyval(o.polyCoefficent, t)) ;
            
        end

        % plotWaveForm(intervalle) plot the waveForm of the current
        % WaveForm object.
        function  plotWaveForm(o,intervalle)
            figure();
            data = o.WF(intervalle);
            plot(intervalle*1e3, data*1e3);
            xlabel('time [ms]');
            ylabel('pulse Wave Form [mA]');
            legend('Wave Form');
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

