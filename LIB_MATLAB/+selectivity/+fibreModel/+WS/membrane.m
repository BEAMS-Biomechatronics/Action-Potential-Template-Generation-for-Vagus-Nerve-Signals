classdef membrane
    properties
        
        % Warning obsolete function
        
        
        %unit
        cm;
        cm2;
        um;
        uF;
        mmho;
        
        %propriétés
        %[Mcneal1976]
        D;
        n;
        rhoi;
        rhoe;
        cam;
        gm;
        l;
        
                
        %propriétés à ne pas changer directement
        %[Vuckovic2004]
        d;
        L; %longueur internodale
        Ga;
        Gm;
        Cam;
        
        %variable d'entrée
        Ve;
        
        %variable d'ouverture/fermeture de chacun des noeuds
        noeuds;
        
        %resultat de la simulation
        t;
        Y;
        I;
        
    end
    
    methods
        function o = membrane(D,I)
            %unit
            o.cm = 1e-2;
            o.cm2 = 1e-4;
            o.um = 1e-6;
            o.uF = 1e-6;
            o.mmho = 1e-6;

            %propriétés
            %[Mcneal1976]
            o.rhoi = 110*o.cm;
            o.rhoe = 300*o.cm;
            o.cam = 2.8*o.uF/o.cm2; % membrane capacity [Wesselink 1999]
            o.gm = 30.4 *o.mmho/o.cm2; % membrane conductance (not given in Wesselink)
            o.l = 1.5 *o.um; % nodal width [Wesselink 1999]
        
            o.D = D;
            
            o.d = 0.76*o.D-1.81*1e-6; %diamètre de l'axone [Wesselink 1999]
%             o.d = 0.9*o.D-1.8*1e-6; %diamètre de l'axone
%             o.L = 7.87*1e-6*log(o.D/1.81*1e-6); %longueur internodale [Wesselink 1999]
%             o.L = 7.9*1e-4*log(o.D/3.4*1e-6); %longueur internodale
            o.L = o.D*(7.87e-4*log(o.D)+9.9e-3); %% MODIF
            o.Ga = pi*o.d^2 /(4*o.rhoi*o.L);
            o.Gm = o.gm*pi*o.d*o.l;
            o.Cam = o.cam*pi*o.d*o.l;
            o.I = I;
            
            o.t = [];
            o.Y = [];
            
            o.noeuds = selectivity.fibreModel.WS.WS(0);
            for i=1:o.n
                o.noeuds(i) = WS(20);
            end
        end
        function solve(o)
            options=odeset('MaxStep',1e-6);
            y0 = [zeros(1,o.n)];
            for i=1:o.n
                y0 = [y0 o.noeuds(i).initial()];
            end
            [time,Ysol]=ode45(@o.differentielle,[0:1e-5:3e-3], y0, options);
            o.t = time;
            o.Y = Ysol;
            figure()
            plot(time,Ysol(:,1),'r')    
            
            figure()
            plot(time,Ysol(:,2),'k')   %m
            hold on;
            plot(time,Ysol(:,3),'y')   %h
            plot(time,Ysol(:,4),'r')   %n
            plot(time,Ysol(:,5),'b')   %p
        end
        function dy = differentielle(o,t,y) 
            dy = zeros(5, 1);
            
            %premier set d'équation correspond aux équations de la
            %variation de tension de la membrane aux différents noeuds.
            % n noeuds

            mhnp = y(2:5);
            dy(1) = 1/o.Cam*(-pi*o.d*o.l*o.noeuds(1).iTot(mhnp,y(1))+o.I*1e-3/o.cm2*pi*o.d*o.l*(1-sigmf(t,[1/1e-5 0.12e-3])));
     
     
            
            %second set d'équations correspond aux équations des variables
            %d'ouverture et de fermeture des canaux
            % n * 4 équations dans le cas de WS
            
            
            dytemp = o.noeuds(1).dy(mhnp,y(1));
            for m=1:4
                dy(1+m) = dytemp(m);
            end
        end
    end
     
end