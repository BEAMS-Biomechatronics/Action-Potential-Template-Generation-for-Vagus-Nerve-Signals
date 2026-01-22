classdef fibre2
    properties 
        %unit
        cm;
        cm2;
        um;
        uF;
        mmho;
        
        %proprietes
        %[Mcneal1976]
        D;
        n;
        rhoi;
        rhoe;
        cam;
        gm;
        l;
        
        TC; %temperature C
        
                
        %proprietes a ne pas changer directement
        %[Vuckovic2004]
        d;
        L; %longueur internodale
        Ga;
        Gm;
        Cam;
        
        %variable d'entree
        Ve;
        
        %variable d'ouverture/fermeture de chacun des noeuds
        noeuds;
        
        %resultat de la simulation
        time;
        solution;
        I_ion;
        Ic;
        
        %temps de simulation
        tEnd;
        t_;
        
        %fin du step de stimulation
        pulseTEnd
        pusleTTransition
%         %Courant d'action
        AC;

        
    end
    
    methods
        function o = fibre2(D,n,Ve,TC,pulseTEnd, pusleTTransition)
            import selectivity.Axel.*;
            %unit
            o.cm = 1e-2;
            o.cm2 = 1e-4;
            o.um = 1e-6;
            o.uF = 1e-6;
            o.mmho = 1e-6;
            %proprietes
            %[Mcneal1976]
            o.rhoi = 110*o.cm;
            o.rhoe = 300*o.cm;
            o.cam = 2*o.uF/o.cm2;
            o.gm = 30.4 *o.mmho/o.cm2; %Conductance electrique
            o.l = 2.5 *o.um;
            o.TC = TC;
        
            o.D = D;
            o.n = n;
            o.d = 0.9*o.D-1.8*1e-6; %diametre de l'axone
            o.L = 100*o.D; %longueur internodale
            o.Ga = pi*o.d^2 /(4*o.rhoi*o.L);
            o.Gm = o.gm*pi*o.d*o.l;
            o.Cam = o.cam*pi*o.d*o.l;
            o.Ve = Ve;
            
            
            %Calcul du temps de simulation
            vitesseTheorique = 5+(D-4e-6)*5/2e-6;
            longueurDemiFibre = n/2*o.L;
            tempsChuteAP = 1e-3;
            o.tEnd = pulseTEnd + tempsChuteAP + longueurDemiFibre;%/vitesseTheorique;             
            o.pulseTEnd = pulseTEnd;
            o.pusleTTransition = pusleTTransition;
            o.noeuds = FH2.empty(o.n,0);
            for i=1:o.n
                o.noeuds(i) = FH2(o.TC);
            end
           o.AC=[];
           o.t_=[0:0.5e-4:o.tEnd];
           
        end
        
        function o = solve(o)
            %options=odeset('MaxStep',1e-4);
            y0 = zeros(1,o.n);
            t=o.t_;
            for i=1:o.n
                y0 = [y0 o.noeuds(i).initial()];
            end
            [time,Ysol]=ode23(@o.differentielle,t, y0);%, options);
            o.time = time;
            o.solution = Ysol;
            o.I_ion = zeros (size(t,2),o.n);
            o.Ic = zeros (size(t,2),o.n);
            for i=1:size(t,2) % Pour tous les temps
                for j=1:o.n  % Pour chaque noeud
                    mhnp = Ysol(i,o.n+(j-1)*4+1:o.n+j*4);
                    V = Ysol(i,j); 
                    o.I_ion(i,j)=pi*o.d*o.l*o.noeuds(j).iTot(mhnp,V) ; %Courant ionique
                end 
            end
            for i=1:size(t,2)-1
                for j=1:o.n
                    V = Ysol(i,j); 
                    V_= Ysol(i+1,j);
                    dV =(V_-V)/(o.time(i+1)-o.time(i));
                    o.Ic(i,j)=o.Cam*dV; %Courant capacitif
                end
                o.Ic(end,:)=o.Ic(end-1,:); %Gerer probleme de la derivee pour le dernier temps
            end
            o.AC = (o.I_ion + o.Ic); %Courant transmembranaire en chaque noeud et chaque temps pour la fibre
        end
       
          
       function dy = differentielle(o,t,y)
%            t=o.t_;
            dy = zeros(o.n + 4*o.n, 1);
            VeTemp = o.Ve* (1-sigmf(t,[1/o.pusleTTransition o.pulseTEnd]));
            
            
            %premier set d'equation correspond aux equations de la
            %variation de tension de la membrane aux differents noeuds.
            % n noeuds
            
            
            for i=1:o.n
                V = y(i);
                mhnp = y(o.n+(i-1)*4+1:o.n+i*4);
                if i==1 
                    dy(i) = 1/o.Cam*(o.Ga*(-2*y(i)+y(i+1))-pi*o.d*o.l*o.noeuds(i).iTot(mhnp,V)); %dVn,1/dt
                elseif i==o.n
                    dy(i) = 1/o.Cam*(o.Ga*(y(i-1)-2*y(i))-pi*o.d*o.l*o.noeuds(i).iTot(mhnp,V)); %dVn,n/dt
                else 
                   dy(i) = 1/o.Cam*(o.Ga*(y(i-1)-2*y(i)+y(i+1)+VeTemp(i-1)-2*VeTemp(i)+VeTemp(i+1))-pi*o.d*o.l*o.noeuds(i).iTot(mhnp,V)); %dVn,i/dt
                end
            end
            
            %second set d'equations correspond aux equations des variables
            %d'ouverture et de fermeture des canaux
            % n * 4 equations dans le cas de FH
            for i=1:o.n
                mhnp = y(o.n+(i-1)*4+1:o.n+i*4);
                V = y(i);
                dytemp = o.noeuds(i).dy(mhnp,V);
                for m=1:4
                    dy(o.n+(i-1)*4+m) = dytemp(m);
                end
            end
        end 
             
    end
end