function Vq = interpXYZ_1fib_XY (CoordonneesXY,CoordonneesZ,current_density_T,x,y,z)
%--------------------------------------------------
% Interpolation 3D (x,y,z) de la densite de courant
% Permet de trouver la valeur de la densite de courant aux points demandes par
% COMSOL pour un seul type de diametre de fibre (coordonnees XY (plan transversal))
%
% Input : -CoordonneesFibresXY : Position (x,y) des fibres dans le maillage 
%         -CoordonneesFibresZ : Position z des noeuds des fibres
%         -B : Tableau reprenant les matrices de densite de courant interpolees dans le temps pour le
%         temps demande par COMSOL
%         -r,z : Coordonnees demandees par COMSOL
%         -idx : numero du diametre
%         -nFibreParFascicule : Nombre de fibres par diametre
%
% Output : -Vq :Vecteur [1xNbre coordonnees x,y,z] de densite de courant
%  pour tous les points (x,y,z) au temps t
% 
%--------------------------------------------------
% On garde R pour la première partie car la densité de courant se trouve
% seulement sur la coordonnée X

X = CoordonneesXY(1,:)'; % Points où la densite de courant est connue (coordonnee radiale X du maillage et noeuds Z)

% X: 1x nFibers
Z = CoordonneesZ;
% Z: 1x nNodes
[X_grid, Z_grid] = meshgrid(X,Z);

V = zeros(length(X), length(Z));
n_fiber_density = 1; % Density only in the nth fiber
V(n_fiber_density,:) = current_density_T; % Density only in the nth fiber

% Premiere interpolation : on map le nerf en 101x(nb de noeuds)
xlin = linspace(min(X), max(X), 101);
% ylin = linspace(min(Y), max(Y), 101);
zlin = linspace(min(Z), max(Z), 398);
[x_grid,z_grid] = meshgrid(xlin, zlin);
my_Qj = griddata(X_grid, Z_grid, V', x_grid, z_grid, 'linear');

% Deuxieme interpolation
Vq = griddata(x_grid, z_grid, my_Qj, x', z', 'linear');  %Interpolation spatiale (r,z)

Vq(isnan(Vq))=0;
Vq(abs(y)>20e-6)=0; % density only in one fiber width of y
end