classdef  FH2
    
    properties
        
       %unit
        molar;
        mA;
        mV;
        mM;
        cm;
        s;
        msec;
        mho;
        mmho;
        cm2;
        
        %constante absolue
        F;
        R;
        %variable du problème
        TC;
        
        %variable à ne pas modifier directement
        TF;
        FRT;
        FFRT;
        Q10;
        
        pnabar;
        ppbar;
        pkbar;
        nai;
        nao;
        ki;
        ko;
        gl;
        ev;
        Vrest;

    end

    methods
        function o = FH2(TC)
            
            %unit
            o.molar = 1e3;
            o.mA = 1e-3;
            o.mV = 1e-3;
            o.mM = 1;
            o.cm = 1e-2;
            o.s = 1;
            o.msec = 1e-3;
            o.mho = 1; %invert of ohm
            o.mmho = 1e-3;
            o.cm2 = 1e-4;

            %constantes absolues
            o.F = 96485.3329;
            o.R = 8.3144621;

            o.pnabar=8e-3 *o.cm/o.s;
            o.ppbar=.54e-3 *o.cm/o.s;
            o.pkbar=1.2e-3 *o.cm/o.s;
            o.nai = 13.74 * o.mM;
            o.nao = 114.5 *o.mM;
            o.ki = 120 * o.mM;
            o.ko = 2.5 * o.mM;
            o.gl = 30.3e-3 *o.mho/o.cm2;
            o.ev = 0.026 *o.mV;
            o.Vrest = -70* o.mV;
           
            %variable du problème
            o.TC = TC;

            %variable à ne pas modifier directement
            o.TF = 273.15+o.TC;
            o.FRT = o.F/o.R/o.TF;
            o.FFRT = o.F*o.F/o.R/o.TF;
            o.Q10 = 3^((o.TC - 20)/10);
           
        end
        function inf = infinite(o,c1,c2,c3,V)
            %Forme de la fonction
            % inf = c1 * 1e3 * (V - c2) * 1/(1-exp((c2-V)/c3)) 
            %Plus d'actualité : Attention, comme j'exprime tout en volt et non en mV, la
            %formule est un peu modifié (ajout de 1e3)
            %c2 et c3 doivent donc avoir des volts comme unité, ainsi que
            %V.
            %La tension utilisée dans ces calculs est la tension réduite
            inf = c1 * o.Q10 *(V - c2) * 1/(1-exp((c2-V)/c3));
        end
        function y0 = initial(o)
            %Cette fonction donne les valeurs initiales des variables
            %m,h,n,p pour le solver qui résout le problème depuis
            %l'extérieur. 
            y0 = [0.0005 0.8249 0.0268 0.0049];
        end
        function dy = dy(o, y, V)
            
            %Ordre des variables m,h,n,p
            dy = zeros(4,1);
            
            c1 = 0.36/o.msec/o.mV; c2 = 22*o.mV; c3 = 3*o.mV; %m
            c4 = -0.4/o.msec/o.mV;  c5 = 13* o.mV; c6 = -20 * o.mV;
            dy(1) = o.infinite(c1, c2, c3, V)*(1-y(1)) -o.infinite(c4,c5,c6, V)*y(1);
            
            c1 = -0.1/o.msec/o.mV; c2 = -10*o.mV; c3 = -6*o.mV; %h
            dy(2) = o.infinite(c1,c2,c3, V)*(1-y(2))-(4.5/o.msec*o.Q10/(1+exp((45*o.mV-V)/(10*o.mV))))*y(2);
            
            c1 = 0.02/o.msec/o.mV; c2 = 35*o.mV; c3 = 10*o.mV; %n
            c4 = -0.05/o.msec/o.mV;  c5 = 10* o.mV; c6 = -10 * o.mV;
            dy(3) = o.infinite(c1, c2, c3, V)*(1-y(3)) -o.infinite(c4,c5,c6, V)*y(3);
            
            c1 = 0.006/o.msec/o.mV; c2 = 40*o.mV; c3 = 10*o.mV; %p
            c4 = -0.09/o.msec/o.mV;  c5 = -25* o.mV; c6 = -20 * o.mV;
            dy(4) = o.infinite(c1, c2, c3, V)*(1-y(4)) -o.infinite(c4,c5,c6, V)*y(4);
        end
        function iTot = iTot(o, y, V)
            V = V + o.Vrest; %La tension utilisée dans ces calculs est la tension réelle. 
            %Ordre des variables m,h,n,p
            ina = o.pnabar * y(2)*y(1)^2 * o.ghk(o.nao, o.nai, V);
            ik  = o.pkbar * y(3)^2 * o.ghk(o.ko, o.ki, V);
            ip  = o.ppbar * y(4)^2 * o.ghk(o.nao, o.nai, V);
            il  = o.gl * (V-(o.Vrest+o.ev));
            iTot = ina + ik + ip + il;
        end
        function ghk = ghk(o, Co, Ci, V)
            ghk = V * o.FFRT * (Co-Ci*exp(V*o.FRT))/(1-exp(V*o.FRT));
        end
    end
end