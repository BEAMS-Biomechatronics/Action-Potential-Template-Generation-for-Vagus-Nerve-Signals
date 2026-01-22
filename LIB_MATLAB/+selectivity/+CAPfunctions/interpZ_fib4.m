function Vq = interpZ_fib1 (CoordonneesXY,CoordonneesZ,current_density_T,x,y,z)
%--------------------------------------------------
% Interpolation 3D (x,y,z) de la densite de courant
% Permet de trouver la valeur de la densite de courant aux points demandes par
% COMSOL pour un seul type de diametre de fibre (coordonnees XY (plan transversal))
%
% Input : -CoordonneesFibresXY : Position (x,y) des fibres dans le maillage
%          /!\ ici, seule la position en z nous interesse car COMSOL ne
%          demande qu'au sein de la fibre centrale
%         -CoordonneesFibresZ : Position z des noeuds des fibres
%         -B : Tableau reprenant les matrices de densite de courant interpolees dans le temps pour le
%         temps demande par COMSOL
%         -x,y,z : Coordonnees demandees par COMSOL
%         -idx : numero du diametre
%         -nFibreParFascicule : Nombre de fibres par diametre
%
% Output : -Vq :Vecteur [1xNbre coordonnees x,y,z] de densite de courant
%  pour tous les points (x,y,z) au temps t
% 
%--------------------------------------------------
% On garde R pour la première partie car la densité de courant se trouve
% seulement sur la coordonnée X

Z = CoordonneesZ;
% Z: 1x nNodes
V = current_density_T; % Density only in the nth fiber

Vq = interp1(Z, V, z);

nerveD = 0.4e-3;
fiber_location = nerveD*4/14; % the center of the active fiber is at 4/7 of the nerve radius

Vq(isnan(Vq))=0;
Vq(abs(x-fiber_location)>1e-4)=0;
Vq(abs(y)>1e-4)=0; % density only in one fiber width of y
end