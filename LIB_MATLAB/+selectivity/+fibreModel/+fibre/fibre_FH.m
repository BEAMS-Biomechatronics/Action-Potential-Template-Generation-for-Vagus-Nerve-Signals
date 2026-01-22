classdef fibre < handle
    
    properties
                cm;
        cm2;
        um;
        uF;
        mmho;
        F;
        m2;
        
        %propriétés
        %[Mcneal1976]
        D;
        n;
        rhoi;
        rhoe;
        cam;
        gm;
        l;
        mV;
        
        TC; %température C
        
                
        %propriétés à ne pas changer directement
        %[Vuckovic2004]
        d;
        L; %longueur internodale
        Ga;
        Gm;
        Cam;
        V_rest; % ajout Hugo
        
        %variable d'entrée
        % Deux cas possible :
        % - Une source de courant : size(Ve) = ()
        Ve;
        current;
        
        %variable d'ouverture/fermeture de chacun des noeuds
        noeuds;
        
        %resultat de la simulation
        time;
        solution;
        
%         %unit
%         cm;
%         cm2;
%         um;
%         uF;
%         mmho;
%         
%         %propriétés
%         %[Mcneal1976]
%         D;
%         n;
%         rhoi;
%         rhoe;
%         cam;
%         gm;
%         l;
%         
%         TC; %température C
%         
%                 
%         %propriétés à ne pas changer directement
%         %[Vuckovic2004]
%         d;
%         L; %longueur internodale
%         Ga;
%         Gm;
%         Cam;
%         
%         %variable d'entrée
%         % Deux cas possible :
%         % - Une source de courant : size(Ve) = ()
%         Ve;
%         current;
%         
%         %variable d'ouverture/fermeture de chacun des noeuds
%         noeuds;
%         
%         %resultat de la simulation
%         time;
%         solution;
        
        %temps de simulation
        tEnd;
        
        % WaveForm object
        WF1;
        WF2;
        stim;
        
        %fin du step de stimulation
%         pulseTEnd
%         pusleTTransition
    end
    
    methods
        function o = fibre(D,n,TC,varargin) 
            % fibre(D,n,TC,[WF1, WF2]) 
            % D = diamètre fibre, n = nombre de noeuds, TC = Temperature en
            % celsius, WF = waveFormObject.
            % WF1 and WF2 must be introduced together. However if current2
            % == 0; WF2 will have no effect. 
            
            % Import WS class and stimWaveForm
            import selectivity.fibreModel.WS.*  
            import selectivity.fibreModel.stimWaveForm.*
            import selectivity.fibreModel.fibre.*                     
			
%             %unit
%             o.cm            = 1e-2;
%             o.cm2           = 1e-4;
%             o.um            = 1e-6;
%             o.uF            = 1e-6;
%             o.mmho          = 1e-6;
% 
%             %propriétés
%             %[Mcneal1976]
%             o.rhoi          = 110*o.cm;
%             o.rhoe          = 300*o.cm;
%             o.cam           = 2*o.uF/o.cm2;
%             o.gm            = 30.4 *o.mmho/o.cm2;
%             o.l             = 2.5 *o.um;
%             o.TC            = TC;
%         
%             o.D             = D;
%             o.n             = n;
%             o.d             = 0.7*o.D;%0.8*o.D-1.8*1e-6; %diamètre de l'axone
%             o.L             = 100*o.D;%7.9*1e-4*log(o.D/(3.4*1e-6)); %longueur internodale
%             o.Ga            = pi*o.d^2 /(4*o.rhoi*o.L);
%             o.Gm            = o.gm*pi*o.d*o.l;
%             o.Cam           = o.cam*pi*o.d*o.l;
            
            
            
            %unit
            o.cm            = 1e-2;
            o.cm2           = 1e-4;
            o.um            = 1e-6;
            o.uF            = 1e-6;
            o.mmho          = 1e-6;
            o.F             = 1;
            o.m2            = 1;
            o.mV = 1e-3;

            %propriétés
            %[Mcneal1976]
            o.rhoi          = 110*o.cm;
            o.rhoe          = 300*o.cm;
            o.cam           = 0.028*o.F/o.m2;
            o.gm            = 30.4 *o.mmho/o.cm2;
            o.l             = 1.5 *o.um; % Ranvier node width
            o.TC            = TC;
        
            o.D             = D;
            o.n             = n;
            o.d             = 0.7*o.D;%0.76*o.D-1.81*1e-6; %diamètre de l'axone
            o.L             = 100*o.D;%7.87*1e-6*log(o.D/(3.44*1e-6)); %longueur internodale
            o.Ga            = pi*o.d^2 /(4*o.rhoi*o.L);
            o.Gm            = o.gm*pi*o.d*o.l;
            o.Cam           = o.cam*pi*o.d*o.l;
            
            o.V_rest = -84*o.mV;
            
            
            
            
            
            % Call the function setVe and setCourant -unitary current by default- before running the simulation
            o.Ve            = zeros(2,n);
            o.current       = ones(2,1);
            
            % The waveForm object contains all the data and functions to be
            % able to emulate the waveForm you want. 
            if nargin == 5
                o.WF1 = varargin{1};
                o.WF2 = varargin{2};
            elseif nargin ~= 3
                error('wrong number of input parameters');
            end

            %Calcul du temps de simulation
            vitesseTheorique = 5+(D-4e-6)*5/2e-6;
            longueurDemiFibre = n/2*o.L;
            tempsChuteAP = 1e-3;
            
%             if nargin == 5
%                 o.tEnd = o.WF1.TPulseGlobal + tempsChuteAP + longueurDemiFibre/vitesseTheorique;
%                 % MODIF 
%                 if o.tEnd > 5e-3
%                     o.tEnd = 5e-3;
%                 end                    
%             end
            if o.TC <= 25
                o.tEnd = 5e-3;
            else
                o.tEnd = 3e-3;
            end
            

            o.noeuds = WS.empty(o.n,0);
            for i=1:o.n
                o.noeuds(i) = WS(o.TC);
            end
        end

        % set the current, depending of the number of electrodes, current
        % can be a scalar or a (1,2) array. 
        function o = setCurrent(o,current)
            if numel(current) == 1
                o.current = [current; 0];
            elseif numel(current) == 2
                o.current = current';
            else 
                error('cuurent should be a (1,2) or a scalar variable');
            end
        end

        %%
        % SOLVING THE PROBLEM
        function o = solve(o,varargin)
            % solve(['detectEvent'])
            
            y0          = zeros(1,o.n);
            for i=1:o.n
                y0      = [y0 o.noeuds(i).initial()];
            end
            
            tspan       = [0:0.5e-5:o.tEnd];
            time        = [];
            Ysol        = [];
            
            % you can add event function to stop simulation if no information is
            % expected after the event is passed. 
            if nargin == 2
                if strcmp(varargin{1}, 'detectEvent')
                    options = odeset('Event', @selectivity.fibreModel.fibre.eventAPEnded);
                    [time,Ysol] = ode23(@o.differentielle,tspan, y0 , options);
                end
            else
               
                [time,Ysol] = ode23(@o.differentielle,tspan, y0);%, options);
            end
                
            o.time      = time;
            o.solution  = Ysol;
            
        end

        %% 
        % This function is the one passed as argument to the solver. 
        function dy = differentielle(o,t,y)
            dy = zeros(o.n + 3*o.n, 1);
            
            % VeTemp =  [ Ve,elec1,n1 Ve,elec2,n1 ] * [[WF1] .* [courant,elec1] ]
            %           [ Ve,elec1,n2 Ve,elec2,n2 ]   [[WF2]    [courant,elec2] ]
            %           [ Ve,elec1,n3 Ve,elec2,n3 ] 
            %           [ ........... ........... ] 
            
            VeTemp = (o.Ve')*(o.WF1.WF(t).*o.current(1)) + (o.Ve')*(o.WF2.WF(t).*o.current(2));
            
            %premier set d'équation correspond aux équations de la
            %variation de tension de la membrane aux différents noeuds.
            % n noeuds
            for i=1:o.n
                V = y(i);
                mhnp = y(o.n+(i-1)*3+1:o.n+i*3);
                if i==1 
                    dy(i) = 1/o.Cam*(o.Ga*(-2*y(i)+y(i+1))-pi*o.d*o.l*o.noeuds(i).iTot(mhnp,V));
                elseif i==o.n
                    dy(i) = 1/o.Cam*(o.Ga*(y(i-1)-2*y(i))-pi*o.d*o.l*o.noeuds(i).iTot(mhnp,V));
                else 
                   dy(i) = 1/o.Cam*(o.Ga*(y(i-1)-2*y(i)+y(i+1)+VeTemp(i-1)-2*VeTemp(i)+VeTemp(i+1))-pi*o.d*o.l*o.noeuds(i).iTot(mhnp,V));
                end
            end
            
            %second set d'équations correspond aux équations des variables
            %d'ouverture et de fermeture des canaux
            % n * 3 équations dans le cas de WS
            for i=1:o.n
                mhnp = y(o.n+(i-1)*3+1:o.n+i*3);
                V = y(i);
                dytemp = o.noeuds(i).dy(mhnp,V);
                for m=1:3
                    dy(o.n+(i-1)*3+m) = dytemp(m);
                end
            end
        end
        
        
        
        
        
        
        
        % Use this function to initiate the Ve values at the nodes. 
        function o = setVe(o, varargin)
            % The Ve is given if you have a system with one pair of
            % electrodes as a (1xn) vector. 
            % If Ve is given for 2 pair of electrodes with independent
            % current, you should pass it as (2,n) array;
            
            o.Ve = zeros(2,o.n);
            
            if nargin == 3
                o.Ve(1,:) = varargin{1};
                o.Ve(2,:) = varargin{2};
            elseif nargin == 2
                o.Ve(1,:) = varargin{1};    
                
            else
                error('selectivity:fibreModel:fibre:fibre','You should enter a two (1,n) or (1,n) array');
            end
        end
   
        %% 
        % This function computes the speed of the action potential after
        % the problem has been solved. 
        function speed = speed(o)
            %On cherche la position temporelle + indice du max de l'AP.
            M = zeros(1,o.n);
            I = zeros(1,o.n);
            timeAP = zeros(1,o.n);
            for i=1:o.n
                [M(i),I(i)] = max(o.solution(:,i));
                timeAP(i) = o.time(I(i));
            end


            %On détecte le noeud où l'AP a été déclenché. 
            [m nInit] = min(timeAP);

            %On cherche la partie de fibre la plus longue à partir de l'endroit où
            %                     *
            %| | | | | | | | | |  |  |  |  |
            %1 2 3 4 5 6 7 8 9 10 nI 12 13 a.n
            %l'AP a été déclenché -> variable boolénne (Gpluslong) la partie gauche est la plus
            %longue.
            Gpluslong = o.n-nInit < nInit-1;    


            %Si c'est la partie gauche, on calcule la vitesse avec la différence de temps et position sur le noeud
            %immédiatement à gauche du noeud où il a été déclencé et le noeud 2.
            if Gpluslong
                speed = o.L*(nInit-1-2)/(timeAP(2)-timeAP(nInit-1));
            else
            %Si c'est la partie droite, on calcule la vitesse avec la différence de temps et position sur le noeud
            %immédiatement à droite du noeud où il a été déclencé et le noeud a.n-1.
                speed = o.L*(o.n-1-(nInit+1))/(timeAP(o.n-1)-timeAP(nInit+1));
            end
        end
        
        
        
        %%
        % plot directly the action potential of all the nodes as a function
        % of time. 
        function plot(o)
            figure()
            for i=1:o.n
                plot(o.time,o.solution(:,i),'r')
                hold on
            end
        end
      
        %%
        % Function to set the waveform we want WITHOUT using WF (WF takes
        % as input coordinates, TPulseGloba & TTransition. stim uses only
        % coordinates to match exactly the user input)
        function o = setStim(o, stim)
            o.stim = stim;
        end
        %%
        % Function to plot the propagation of the action potential after
        % the problem has been solved.
        function fig = plotBaton(o,timeDivision, varargin)
            % plotBaton(timeDivision, [(int)typeDetecte])
            % AP is optional. If not passed as argument, the type has not
            % been detected. If you want to use AP detection, first create
            % an AP instance, then run it on the current fiber, then pass
            % it as an argument to this function. 
            if nargin == 3
                typeDetecte = varargin{1};
            end
            
            % The figure on which results are gonna be plotted. 
            fig = figure();
            
            
            % The intervalle of time is being cut into x timeDivision. 
            stepTime = o.tEnd/(timeDivision-1);
            times = [0:stepTime:o.tEnd];
            VMem = [];
            
            % save the external tension at the node i for the desired times
            % chosen by selection of 'times'
            for i=1:o.n
                VMem(i,:) = interp1(o.time, o.solution(:,i), times);
            end
            
            % plot the external voltage and the voltage membrane at the
            % nodes. 
            AxisSubPlot = [];
            diff = length(o.stim(2,:)')/timeDivision;
            for i=1:timeDivision
                
                
                
                %AP
                subplot(timeDivision,1,i);
                bar(VMem(:,i), 0.3);
                
                %Indication des données de la figure
                if(i==1) && nargin == 1
                    stringTypeDetecte = char('Type détecté : erreur', 'Type détecté : No AP', 'Type détecté : AP Cathode', 'Type détecté : blocage anodique', 'Type détecté : AP Cathode virtuelle (après l anode)');
                    title(stringTypeDetecte(typeDetecte,:));
                end
                
                set(gca,'XLim',[0 o.n+1])
                ylabel(sprintf('%0.6f [s]',times(i)));
                if i < timeDivision
                    set(gca,'XTick',[]);
                end   
                set(gca, 'YLim', [-0.15 0.15])
                set(get(gca,'YLabel'),'Rotation',0)

                
                %VE 
                VeTemp = (o.Ve'); %(nNoeuds, 2)
                %WFTemp = o.WF1.WF(times(i));
                                    
                VeTemp = (VeTemp(:,1)-ones(length(VeTemp(:,1)),1)*mean(VeTemp(:,1)))/max(abs(VeTemp(:,1)))*0.1; %Ve - sa moyenne <- à changer peut(être ?
                %VeTemp = VeTemp * (1-sigmf(times(i),[1/o.pusleTTransition  o.pulseTEnd]))/max([max(VeTemp) -min(VeTemp)])*0.15; %Ve normalisé pour rentrer
                if round(diff*i)==0
                    a=1;
                else
                    a=round(diff*i);
                end
                VeTemp = VeTemp*(o.stim(2,a));
                hold on
                b2 = bar(VeTemp, 0.8, 'r');
                set(gca,'XLim',[0 o.n+1])
                set(get(b2,'Children'),'FaceAlpha',0.3)
                if i==1
                    AxisSubPlot = get(gca,'position');
                end
                if i==timeDivision
                    AxisSubPlot = [AxisSubPlot; get(gca,'position')];
                end
            end
        end
         
        function tau = getTauRC(o)
            tau = (1/o.Ga)*o.Cam/2;
        end
        
        
         function new = copy(this)
            % Instantiate new object of the same class.
            new = fibre(this.D, this.n, this.TC);

            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                new.(p{i}) = this.(p{i});
            end
        end
    end
end