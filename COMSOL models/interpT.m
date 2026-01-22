function A=interpT (D, time, t)
%--------------------------------------------------
% Interpolation temporelle de la densite de courant
%
% Input : -D : Matrice [Nbre temps x Nbre noeuds ] de densite de courant
% d'une fibre
%         -time : Tableau reprenant les temps de calcul du PA pour chaque
%         fibre
%         -t : Temps demande par COMSOL
%
% Output : -A :Vecteur [1xNbre noeuds] de densite de courant pour le temps
%  t
%--------------------------------------------------

A=zeros(1,size(D,2)); 

if t==0
    A(1,:) = D(1,:);    
 
else
    i=1;
    boucle=1;
    while i<length(time) && boucle==1  % Tant que le temps de COMSOL n'a pas depasse le temps max
        
        if t>=time(i) && t<time(i+1)   
            A(1,:)=D(i,:)+ (D(i+1,:)-D(i,:))*(t-time(i))/(time(i+1)-time(i)); %Interpolation lineaire dans [time(i) time(i+1)]
            boucle=0;            
        else
            i=i+1;             
        end
    end
end

end