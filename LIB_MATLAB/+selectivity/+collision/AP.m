classdef AP
    %types :    
    %[1] No AP : numberOfAP = 0
    %[2] AP cathode
    %[3] AP bloqué par blocage anodique
    %[4] AP cathode virtuelle (AP anode)
    %
    %function solve(Vm,t)
    %
    %properties :
    %birth;             %indique le noeud où l'AP a commencé.
    %death;             %indique le noeud où l'AP s'est terminé (0 si pas encore terminé)
    %deathT;            %indique le temps correspondant à la fin de l'AP.  (0 si pas encore terminé)
    %type;              %donne le type d'AP.
    %lastLocation;      %donne la dernière position de l'AP.
    %numberOfAP;        %indique le nombre d'AP encore en vie ou déjà mort.
    
    properties
        birth;          %indique le noeud où l'AP a commencé.
        birthT;         %indique quand l'AP a commencé.
        death;          %indique le noeud où l'AP s'est terminé (0 si pas encore terminé)
        deathT;         %indique le temps correspondant à la fin de l'AP.  (0 si pas encore terminé)
        type;           %donne le type d'AP (vers la droite). 
        lastLocation;   %donne la dernière position de l'AP.
        numberOfAP;     %indique le nombre d'AP encore en vie ou déjà mort.
        typeG;          %indique le type d'AP pour les AP qui se dirige vers la gauche.

    end
    
    methods
        function o = findAP(o,Vm,t, z, ringD, L, Ve)
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Première étape, calculez le début et la fin des AP, y compris
           % si ceux-ci se scindent en deux. 
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
           nNoeuds = length(Vm(1,:));
           nPas = length(Vm(:,1));
           o.numberOfAP = 0;
           warning('off','signal:findpeaks:largeMinPeakHeight')
           for i=1:nPas
               
               [peaks, location] = findpeaks(Vm(i,:),'MinPeakHeight', 0.03);
               %On parcourt les peaks qui existent
               updated = zeros(1,o.numberOfAP);
                   
               for k=1:length(peaks)
                   %On parcourt les APs qui existent déjà
                   trouveUnAPQuiExisteDeja = 0;
                    for l=1:o.numberOfAP
                       %Si un AP est déjà mort, on le passe (vérification avec
                       %death qui doit être différent de 0). On doit aussi
                       %passer les AP qui ont déjà été attribué à un autre
                       %peak car il est possible qu'il y ait scission.
                       if o.death(l) == 0 && updated(l)==0
                           %Si un AP correspondant au peaks existe déjà et qu'il n'est pas encore
                           %mort, on le met à jour 
                           if o.lastLocation(l) == location(k) || o.lastLocation(l) == location(k)+1 || o.lastLocation(l) == location(k)-1         
                                o.lastLocation(l) = location(k);   
                                updated(l) = 1;
                                trouveUnAPQuiExisteDeja = 1;
                           end
                       end
                    end
                    
                    %Sinon, on en crée un
                    %Attention deux cas :
                    % - soit c'est un vrai nouvel AP;
                    % - soit c'est un AP qui existe déjà qui se scinde en
                    % deux. 
                    if trouveUnAPQuiExisteDeja == 0
                        if o.numberOfAP ~= 0
                            for l=1:o.numberOfAP
                                %S'il existe un autre AP tout proche (en vie), on prend son
                                %historique (scission)
                                if (o.lastLocation(l)+2 == location(k) || o.lastLocation(l)-2 == location(k)) && o.death(l)==0
                                    o.birth(o.numberOfAP+1) = o.birth(l);
                                    o.birthT(o.numberOfAP+1) = o.birthT(l);
                                    o.death(o.numberOfAP+1) = o.death(l) ;       
                                    o.deathT(o.numberOfAP+1) = 0;  
                                    o.lastLocation(o.numberOfAP+1) = location(k);   %donne la dernière position de l'AP.
                                    o.numberOfAP = o.numberOfAP +1;     %indique le nombre d'AP encore en vie ou déjà mort.
                                    updated = [updated 1];
                                else
                                    %Sinon, on en crée un nouveau.
                                    o.birth(o.numberOfAP+1) = location(k);
                                    o.birthT(o.numberOfAP+1) = t(i);
                                    o.death(o.numberOfAP+1) = 0;          
                                    o.deathT(o.numberOfAP+1) = 0;  
                                    o.lastLocation(o.numberOfAP+1) = location(k);   %donne la dernière position de l'AP.
                                    o.numberOfAP = o.numberOfAP +1;     %indique le nombre d'AP encore en vie ou déjà mort.
                                    updated = [updated 1];
                                    break;
                                end
                            end
                        else
                            %Sinon, on en crée un nouveau.
                            o.birth(o.numberOfAP+1) = location(k);
                            o.birthT(o.numberOfAP+1) = t(i);
                            o.death(o.numberOfAP+1) = 0;          
                            o.deathT(o.numberOfAP+1) = 0;  
                            o.lastLocation(o.numberOfAP+1) = location(k);   %donne la dernière position de l'AP.
                            o.numberOfAP = o.numberOfAP +1;     %indique le nombre d'AP encore en vie ou déjà mort.
                            updated = [updated 1];
                        end
                    end
                    
               end
               %Si l'un ou l'autre des APs encore en vie n'a pas été mis à
               %jour, c'est qu'il est mort. Dans ce cas, on le tue.
               for k=1:length(updated)
                   if updated(k) == 0  && o.death(k) == 0
                        o.death(k) = o.lastLocation(k);
                        o.deathT(k) = t(i);
                   end
               end
              
           end
           
           
            o.birth;        %indique le noeud où l'AP a commencé.
            o.birthT;        %indique quand l'AP a commencé.
            o.death;        %indique le noeud où l'AP s'est terminé (0 si pas encore terminé)
            o.deathT;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Seconde étape, déterminez le type de chacun des APs qui se
           % propagent vers la droite (on considère que l'anode est à
           % droite. Pour l'instant cette fonction n'est valable que pour
           % un dipole avec cathode à gauche et anode à droite. 
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %[1] No AP : numberOfAP = 0
            %[2] AP cathode -> propage vers la droite
            %[3] AP bloqué par blocage anodique
            %[4] AP cathode virtuelle (AP anode)
            
            %UPDATE
            %On checke aussi les AP qui vont vers la gauche. 
            %Le type est classé dans le tableau typeGauche.
            %[5] AP
            %[6] No AP
           
            %On calcule d'abord la position des maximas de la tension externe qui correspondent
            %à l'effet de la tension imposées par les électrodes sur les noeuds (les max sont décallés par rapport à la position des anneaux). 
            [Vmax, nAnode] = max(Ve);
            [Vmin, nCathode] = min(Ve);
           
            %Position du noeuds compris entre les deux électrodes ou si
            %plusieurs noeuds compris entre les élecrodes, le noeud le plus
            %central. Pour rappel, si le nombre de noeuds est impair c'est
            %celui du milieu qui est le noeud central, si le nombre de
            %noeud est pair, il y a un noeud de plus à gauche par rapport à
            %la droite par rapport au noeud central. 
            n0 = round((mod(nNoeuds, 2)==1)*ceil(nNoeuds/2)+(mod(nNoeuds,2)==0)*ceil(nNoeuds/2+1));
            z0 = z(n0);
            
          
           
           
           types    = zeros(1,o.numberOfAP);
           typesG   = zeros(1,o.numberOfAP);
           o.type   = 0;
           o.typeG  = 0;
           
           %On parcourt les AP
           if o.numberOfAP ~= 0
               for i=1:o.numberOfAP
                    %On ne s'intéresse qu'au AP qui se propage vers la droite (type
                    %0 si propation vers la gauche ou qui reste plus ou moins sur place.
                   if o.birth(i)<=o.death(i)+3 %Le 3 est un peu arbitraire
                        %cas AP passe vers la droite
                        if o.birth(i) <= ceil(nAnode) && o.death(i)>floor(3/4*nNoeuds)
                            types(i) = 2;
                        %cas AP bloqué par hyperpolarisation
                        elseif o.birth(i) <= ceil(nAnode) && o.death(i) >= floor(nCathode)-3 && o.death(i) <= floor(3/4*nNoeuds)
                            types(i) = 3;
                        %cas AP cathode virtuelle à droite de l'anode
                        elseif o.birth(i) >= ceil(nAnode) && o.death(i) >= ceil(nAnode)
                            types(i) = 4;
                        end
                    %cas AP part vers la gauche
                   elseif o.birth(i)>=o.death(i)+3 %Le 3 est un peu arbitraire
                       typesG(i) = 5;
                   end
                       
               end
           else
               %No AP
               o.type   = 1;
               o.typeG  = 6;
           end
           types;
           %Maintenant que l'on connait tous les types, il faut voir lequel
           %est le plus important. 
           %C'est l'AP de la catégorie la plus importante qui définit le
           %type de la classe AP qui permet de faire le mappage. 
           % pas d'AP < AP bloqué < AP Cathode < AP Cathode virtuelle
           
           nType1   = length(find(types==1));
           nType2   = length(find(types==2));
           nType3   = length(find(types==3));
           nType4   = length(find(types==4));
           nType5   = length(find(typesG==5));
           
           if nType4>0
               o.type = 4;
           elseif nType2>0
               o.type = 2;
           elseif nType3>0 || o.numberOfAP ~= 0
               o.type = 3;
           end
           
           if nType5>0
               o.typeG = 5;
           end
           
           o.type;
           
        end
    end
end
