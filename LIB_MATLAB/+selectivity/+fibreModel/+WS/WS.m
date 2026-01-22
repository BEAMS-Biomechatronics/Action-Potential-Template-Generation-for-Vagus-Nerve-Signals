classdef  WS
    
    properties
        
       %unit
        molar;
        mA;
        mV;
        mM;
        cm;
        s;
        m2;
        msec;
        mho;
        mmho;
        cm2;
        mmol;
        
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
        
        pnabar; % permeability
        ppbar;
        pkbar;
        nai;    % in/out membrane concentration
        nao;
        ki;
        ko;
        gk;     % potassium conductance
        gl;     % leakage conductance
        ek;     % potassium equilibrium potential
        el;     % leakage current equilibrium potential
        Vrest;  % rest potential

    end

    methods
        function o = WS(TC)
            
            %unit
            o.molar = 1;
            o.mA = 1e-3;
            o.mV = 1e-3;
            o.mM = 1; % mmol / l = mol / m3
            o.cm = 1e-2;
            o.s = 1;
            o.m2 = 1;
            o.msec = 1e-3;
            o.mho = 1; %invert of ohm
            o.mmho = 1e-3;
            o.cm2 = 1e-4;

            %constantes absolues
            o.F = 96485.3329;
            o.R = 8.3144621;
            % Constants
            % Constants are given for T = 37°C
            o.pnabar=7.04e-3 *o.cm/o.s;
            o.ppbar=.54e-3 *o.cm/o.s; % non-specific permeability
            o.pkbar=1.2e-3 *o.cm/o.s;
            o.nai = 30 * o.mM; % in/out membrane concentration
            o.nao = 154 *o.mM;
            o.ki = 120 * o.mM;
            o.ko = 2.5 * o.mM;
            o.gl = 600 *o.mho/o.m2; % leakage conductance
            o.gk = 300 *o.mho/o.m2;
            o.ek = -84 * o.mV; % potassium equilibrium potential
            o.el = -84.14 *o.mV; % leakage current equilibrium potential
            o.Vrest = -84* o.mV;
           
            %variable du problème
            o.TC = TC;

            %variable à ne pas modifier directement
            o.TF = 273.15+o.TC;
            o.FRT = o.F/o.R/o.TF;
            o.FFRT = o.F*o.F/o.R/o.TF;
%             o.Q10 = 3^((o.TC - 20)/10);
            Q37 = 3^((37-20)/10);
            o.Q10 = 3^((o.TC - 20)/10)/Q37; % arrangement Q10 autour de 37°C. Fit avec [Wesselink 1999]
           
        end

        function y0 = initial(o)
            %Cette fonction donne les valeurs initiales des variables
            %m,h,n pour le solver qui résout le problème depuis
            %l'extérieur. 
            y0 = [0.0382 0.6986 0.2563];
        end
        function dy = dy(o, y, V)
            %%% Differential equations of gating variables
            %%% Given in [Wesselink 1999]
            %%% Major difference with FH is that V is the absolute potential
            %%%    and not relative to the resting potential
%             V = V + o.Vrest;
            m = y(1);
            h = y(2);
            n = y(3);
            
            alpha_m = o.Q10*4.6/o.msec*(V/o.mV+18.4)/(1-exp((-18.4-V/o.mV)/(10.3)));
            beta_m = o.Q10*0.33/o.msec*(-22.7-V/o.mV)/(1-exp((V/o.mV+22.7)/(9.16)));
            alpha_h = o.Q10*0.21/o.msec*(-111-V/o.mV)/(1-exp((V/o.mV+111)/(11)));
            beta_h = o.Q10*14.1/o.msec/(1+exp((-28.8-V/o.mV)/(13.4)));
            alpha_n = o.Q10*0.0517/o.msec*(V/o.mV+93.2)/(1-exp((-93.2-V/o.mV)/(1.1)));
            beta_n = o.Q10*0.092/o.msec*(-76-V/o.mV)/(1-exp((V/o.mV+76)/(10.5)));
            
            dy(1) = (alpha_m*(1-m)-beta_m*m);
            dy(2) = (alpha_h*(1-h)-beta_h*h);
            dy(3) = (alpha_n*(1-n)-beta_n*n);
        end
        function iTot = iTot(o, y, V)
%             V = V + o.Vrest; %La tension utilisée dans ces calculs est la tension réelle. 
            %Ordre des variables m,h,n,p
            ina = y(1)^3 * y(2) * o.pnabar * o.FFRT * V * (o.nao - o.nai*exp(V*o.FRT))/(1-exp(V*o.FRT));
            ik = y(3)^4 * o.gk * (V - (o.ek));
            il = o.gl * (V-(o.el));

            iTot = ina + ik + il;
        end
        function ghk = ghk(o, Co, Ci, V)
            ghk = V * o.FFRT * (Co-Ci*exp(V*o.FRT))/(1-exp(V*o.FRT));
        end
        
        function tauMhnp = tau(o,V)
            %Ordre des variables m,h,n,p
            tauMhnp = zeros(4,1);
            
            c1 = 0.36/o.msec/o.mV; c2 = 22*o.mV; c3 = 3*o.mV; %m
            c4 = -0.4/o.msec/o.mV;  c5 = 13* o.mV; c6 = -20 * o.mV;
            tauMhnp(1) = 1/(o.infinite(c1, c2, c3, V) + o.infinite(c4,c5,c6, V));
            
            c1 = -0.1/o.msec/o.mV; c2 = -10*o.mV; c3 = -6*o.mV; %h
            tauMhnp(2) = 1/(o.infinite(c1,c2,c3, V) + (4.5/o.msec*o.Q10/(1+exp((45*o.mV-V)/(10*o.mV)))));
            
            c1 = 0.02/o.msec/o.mV; c2 = 35*o.mV; c3 = 10*o.mV; %n
            c4 = -0.05/o.msec/o.mV;  c5 = 10* o.mV; c6 = -10 * o.mV;
            tauMhnp(3) = 1/(o.infinite(c1, c2, c3, V) + o.infinite(c4,c5,c6, V));
            
            c1 = 0.006/o.msec/o.mV; c2 = 40*o.mV; c3 = 10*o.mV; %p
            c4 = -0.09/o.msec/o.mV;  c5 = -25* o.mV; c6 = -20 * o.mV;
            tauMhnp(4) = 1/(o.infinite(c1, c2, c3, V) + o.infinite(c4,c5,c6, V));
        end
        
        function [fig, minMhnp, maxMhnp] = plotTauMhnp(o,Vm)
            % plotTauMhnp(Vm), where Vm is a vector with the value of tau
            % you want to get
            
            % empty vector
            tauMhnp = zeros(4,length(Vm));
            for k=1:length(Vm)
                tauMhnp(:,k) = o.tau(Vm(k));
            end
            fig = figure();
            plot(Vm*1e3, tauMhnp(1,:)*1e3, 'k');
            hold on
            plot(Vm*1e3, tauMhnp(2,:)*1e3, 'r');
            plot(Vm*1e3, tauMhnp(3,:)*1e3, 'g');
            plot(Vm*1e3, tauMhnp(4,:)*1e3, 'b');
            
            minMhnp = min(tauMhnp, [], 2);
            maxMhnp = max(tauMhnp, [], 2);
            
            xlabel('V_m [mV]');
            ylabel('\tau [ms]');
            
            legend('\tau_m', '\tau_h', '\tau_n', '\tau_p');
        end
        
        function [fig, mInf, hInf, nInf, pInf, iIionic] = plotMhnpInf(o,Vm)
            % plotMhnpInf(Vm), where Vm is a vector with the value of tau
            % you want to get
            
            
            % empty vectors
            mInf            = zeros(1,length(Vm));
            hInf            = zeros(1,length(Vm));
            nInf            = zeros(1,length(Vm));
            pInf            = zeros(1,length(Vm));
            iIionic         = zeros(1,length(Vm));
            
            % compute infinite value
            for k=1:length(Vm)
                c1 = 0.36/o.msec/o.mV; c2 = 22*o.mV; c3 = 3*o.mV; %m
                c4 = -0.4/o.msec/o.mV;  c5 = 13* o.mV; c6 = -20 * o.mV;
                mInf(k) = o.infinite(c1, c2, c3, Vm(k)) / (o.infinite(c1, c2, c3, Vm(k)) + o.infinite(c4,c5,c6, Vm(k)));

                c1 = -0.1/o.msec/o.mV; c2 = -10*o.mV; c3 = -6*o.mV; %h
                hInf(k) = o.infinite(c1, c2, c3, Vm(k)) / (o.infinite(c1, c2, c3, Vm(k)) + (4.5/o.msec*o.Q10/(1+exp((45*o.mV-Vm(k))/(10*o.mV)))));

                c1 = 0.02/o.msec/o.mV; c2 = 35*o.mV; c3 = 10*o.mV; %n
                c4 = -0.05/o.msec/o.mV;  c5 = 10* o.mV; c6 = -10 * o.mV;
                nInf(k) = o.infinite(c1, c2, c3, Vm(k)) / (o.infinite(c1, c2, c3, Vm(k)) + o.infinite(c4,c5,c6, Vm(k)));

                c1 = 0.006/o.msec/o.mV; c2 = 40*o.mV; c3 = 10*o.mV; %p
                c4 = -0.09/o.msec/o.mV;  c5 = -25* o.mV; c6 = -20 * o.mV;
                pInf(k) = o.infinite(c1, c2, c3, Vm(k)) / (o.infinite(c1, c2, c3, Vm(k)) + o.infinite(c4,c5,c6, Vm(k)));

                iIionic(k) = iTot(o, [mInf(k) hInf(k) nInf(k) pInf(k)], Vm(k))
            end
            
            % plot ionic current
            fig = figure();
            
            VmmV = Vm*1e3;
            plotyy(VmmV',iIionic',[VmmV', VmmV', VmmV', VmmV'],[mInf', hInf', nInf', pInf']);            
            xlabel('V_m [mV]');
            %ylabel('\tau [ms]');
            
            legend('V_m', 'm_\infty', 'h_\infty', 'n_\infty', 'p_\infty');
        end
        
    end
end