classdef stimWaveFormLinesByPieces < selectivity.stimWaveForm.stimWaveForm & handle
    % This function acts as an input of the solver contained in the fiber
    % class. It generates a parametrized pulse which depends of a set of
    % polynomial coefficient, a pulse length, and maximum current pulse. 
    
    properties
        % Those properties are inherited from the abstract class. They are
        % common to all the waveForm classes. 
        TPulseGlobal;
        TTransition;
        
        % This property contains the coordinates of the curve in the plane
        % current/time. Datas are given in order to use the 'interp1(x,v,xq)'
        % function.
        % The data are given with an array [t; I] (first line are the
        % times, second line is the current. 
        pointsCoordinates;
    end
    
    
    methods
        function o = stimWaveFormLinesByPieces(varargin)
            % stimWaveFormLinesByPieces([TPulseGlobal, ...
            % TTransition, pointsCoordinates [x1 x2 x3 ... xn; y1 y2 y3 ... yn]])
            % default constructot loading a default waveForm (classical square
            % pulse). 
            % * [normalize mode] :
            %       => 'withSigmoid' (default)
            %       => 'noSigmoid'
            %       => 'notNormed'
            
            if nargin == 0
                %o.TPulseGlobal              = 1e-3;                                                         % 1 ms
                %o.TTransition               = 1e-5;                                                         % 10 µs   
                                                                                                            %
                                                                                                            % 0ms      1ms        2ms
                %[x1 x2 x3 ... xn; y1 y2 y3 ... yn]                                                         % 1_________
                %o.pointsCoordinates         = [0 100e-3 100e-3+1e-5 1000e-3; 1e-3 1e-3 0 0];                %           |________ 0
                % The maximum value must include the sigmoid function
                %normalizedValue             = max(o.pointsCoordinates(2,:).*(1-sigmf(o.pointsCoordinates(1,:),[1/o.TTransition o.TPulseGlobal])));
                % noramlize
                %o.pointsCoordinates(2,:)    = o.pointsCoordinates(2,:)/normalizedValue;
            elseif nargin == 3 || nargin == 4
                o.TPulseGlobal              = varargin{1};                                          
                o.TTransition               = varargin{2};                   
                o.pointsCoordinates         = varargin{3};     
                
                
                
                % normalize
                % mode 
                NormMode                    = 'notNormed'; %(default
                if nargin == 4 && strcmp(varargin{4}, 'noSigmoid')
                    NormMode                = 'noSigmoid';
                elseif nargin == 4 && strcmp(varargin{4}, 'notNormed')
                    NormMode                = 'notNormed';
                end
                
                % time value for interpolation
                timeInter                   = linspace(0,o.pointsCoordinates(1,end),1000); %1000 values
            
                ampInter                    = [];
                if strcmp('withSigmoid', NormMode)
                    ampInter                = ((ones(size(timeInter))-sigmf(timeInter,[1/o.TTransition o.TPulseGlobal])) .* interp1(o.pointsCoordinates(1,:),o.pointsCoordinates(2,:), timeInter));
                elseif strcmp('noSigmoid', NormMode)
                    ampInter                = interp1(o.pointsCoordinates(1,:),o.pointsCoordinates(2,:), timeInter);
                elseif strcmp('notNormed', NormMode)
                    ampInter                = 1;
                else
                    error('selectivity:stimWaveForm:stimWaveFormLinesByPieces:badInput', 'Error in stimWaveFormLinesByPieces, input argument 4 is not valid');
                end
                
                normalizedValue             = max(ampInter);
                o.pointsCoordinates(2,:)    = o.pointsCoordinates(2,:)/normalizedValue;
            end
        end
        
        
        
        
        
        %%
        
        function setParameters(o, TPulseGlobal, TTransition, pointsCoordinates)
            % setParameters(TPulseGlobal, TTransition, pointsCoordinates).
            % Set the parameters and normalize the polynome to have maximum
            % value of it, in the range [0 TPulseGlobal] = to maxPulse
            
            % attribution 
            o.TPulseGlobal          = TPulseGlobal;
            o.TTransition           = TTransition;
            o.pointsCoordinates     = pointsCoordinates;
            
        end
        
        
        
        
        %%
        % Save the parameters in a file stimWaveFormParameters.mat
        function saveParameters(o)
            % Set to normal variable name
            TPulseGlobal              = o.TPulseGlobal;            % 
            TTransition               = o.TTransition;             % 
            pointsCoordinates         = o.pointsCoordinates;       % 
                
            % Then save it to a file  
            save('stimWaveFormParameters.mat',  'TPulseGlobal', 'TTransition', 'pointsCoordinates');
        end
        
        
        
        
        
        %%
        function WF = WF(o,t)
            % Calcul de la forme d'onde pour une pulse polygonale
            % Mettre o.Ve'*WF dans la fonction differentielle de la classe
            % fibre. 
            WF          = ((1-sigmf(t,[1/o.TTransition o.TPulseGlobal])) .* interp1(o.pointsCoordinates(1,:),o.pointsCoordinates(2,:), t));
            
        end
        
        function WF = WFWithNoCut(o,t)
            % Calcul de la forme d'onde pour une pulse polygonale
            % Mettre o.Ve'*WF dans la fonction differentielle de la classe
            % fibre. 
            WF          = interp1(o.pointsCoordinates(1,:),o.pointsCoordinates(2,:), t);
            
        end
        
        %this function creates a rectangular signal
        function WF = WFRectangular(o,t)
                WF = rectangularPulse(-o.TPulseGlobal,o.TPulseGlobal,t);% + 0.5*rectangularPulse(3*o.TPulseGlobal, 5*o.TPulseGlobal,t);
                %WF = rectangularPulse(0,o.TPulseGlobal,t);
        end
        
        % plotWaveForm(intervalle) plot the waveForm of the current
        % WaveForm object. second parameter can be used to choose the
        % amplitude of current, also you can ask to display points related
        % to optimization procedure.
        function fig = plotWaveForm(o,intervalle, varargin)
            % Input 1 : intervalle de plot
            % Imput 2 : amplitude du courant si on veut ploter la forme
            % non-normalisée
            % Input 3 : Ploter aussi les points d'input de création de la
            % WF. 
            fig = figure();
            data = o.WFRectangular(intervalle);
            data2 = o.WF(intervalle);
            
            %filtrage 
             fs = 15e4
             [b,a] = butter(4,0.6,'low');
             [b, a] = butter(2, 10000/(fs/2), 'low');
             f_stim = filtfilt(b, a, data);
           
            
            if nargin == 2
                plot(intervalle*1e3, data);
                ylabel('Forme d\primeonde normalisée [1]');
            elseif nargin == 3
                plot(intervalle*1e3, data*varargin{1}*1e3);
                ylabel('courant [mA]');
            elseif nargin == 4 && varargin{2}
                %plot(intervalle*1e3, data*varargin{1}*1e3);
                plot(intervalle*1e3, f_stim*varargin{1}*1e3);
                hold on;
                plot(intervalle*1e3, data2*varargin{1}*1e3);
                ylabel('courant [mA]');
                hold on;
                plot(o.pointsCoordinates(1,:)*1e3, o.pointsCoordinates(2,:)*varargin{1}*1e3, 'o');
                legend('Forme d\primeonde','Points de l\primeoptimisation')
                %ylabel('Points de la paramétrisation');
            else
                plot(intervalle*1e3, data*varargin{1}*1e3);
                ylabel('current [mA]');
            end
            
            xlabel('time [ms]');            
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
        
        function [fig,fitobject] = interp(o,intervalleData, intervalleExtrapolation, varargin)
            %varargin{2} = 'poly1', 'power1', etc (voir fit function)
            fig = figure();
            data = o.WF(intervalleData);
            
            if nargin ~= 5
                error('wrong input arguments, you must provide a current')
            elseif nargin == 5
                plot(intervalleData, data*varargin{1});
                ylabel('current [A]');
            end
            
            xlabel('time [s]');            
            legend('Wave form [A]');
            
            fitobject = fit(intervalleData',data'*varargin{1},varargin{2}) 
            hold on
            plot(intervalleExtrapolation, fitobject(intervalleExtrapolation));
        end
        
        function Q = integrationOfWF(o,current1, value)
            % cette fonction renvoit la charge délivrée lors de
            % l'impulsion [C] ('Q') ou [C/m²] ['Q/A'] 
            % value = 'Q', 'Q/A'
            
            % integration de la courbe normalisée
            integration = 0;
            % parcours des coordonnées
            for k=1:length(o.pointsCoordinates(1,:))-1
                % si on est encore avant la fin de la transition de fin de
                % pulse
                if o.pointsCoordinates(1,k+1) <= o.TPulseGlobal
                    integration = integration + (o.pointsCoordinates(2,k)+o.pointsCoordinates(2,k+1))/2*(o.pointsCoordinates(1,k+1)-o.pointsCoordinates(1,k));
                % si cet intervalle correspond à la fin de pulse,
                % il ne faut intégrer que la partie qui nous intéresse. 
                else
                    if o.pointsCoordinates(1,k) < o.TPulseGlobal
                        % intervalle de temps pour cette partie
                        intervalleT = o.TPulseGlobal-o.pointsCoordinates(1,k);
                        % pente de cette partie
                        slope = (o.pointsCoordinates(2,k+1)-o.pointsCoordinates(2,k))/(o.pointsCoordinates(1,k+1)-o.pointsCoordinates(1,k));
                        integration = integration + (slope*intervalleT+2*o.pointsCoordinates(2,k))/2*intervalleT;
                    end
                end            
            end                
            display(['intégration normalisée : ' num2str(integration)]);
            
            % computing charge (WF * current amplitude)
            load parameters
            if strcmp(value, 'Q')
                Q = integration * current1;
            elseif strcmp(value, 'Q/A')
                Q = integration * current1/pi^2/ringTorusD/ring2D;
                display(['charge par impulsion : ' num2str(Q/10) '[mC/cm²]']);
            end
        end
    end
end

