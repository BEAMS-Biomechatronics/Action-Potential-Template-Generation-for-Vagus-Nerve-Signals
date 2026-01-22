function Vq = interpXYZ_1fib_R (CoordonneesXY,CoordonneesZ,current_density_T,r,z)
%--------------------------------------------------
% Interpolation 3D (x,y,z) de la densite de courant
% Permet de trouver la valeur de la densite de courant aux points demandes par
% COMSOL pour un seul type de diametre de fibre (coordonnees RADIALES)
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
R = CoordonneesXY(1,:)'; % Points où la densite de courant est connue (coordonnee radiale R du maillage et noeuds Z)
% R(3:end+1) = R(2:end); % pour donner une épaisseur à la fibre 1 de 40 µm
% R(2) = 40e-6;          % pour donner une épaisseur à la fibre 1 de 40 µm
% R: 1x nFibers
Z = CoordonneesZ;
% Z: 1x nNodes
[R_grid, Z_grid] = meshgrid(R,Z);


V = zeros(length(R), length(Z));
n_fiber_density = 13; % Density only in the nth fiber
V(n_fiber_density,:) = current_density_T; 

% Premiere interpolation : on map le nerf en 101x(nb de noeuds)
rlin = linspace(min(R), max(R), 101);
zlin = linspace(min(Z), max(Z), 398);
[r_grid,z_grid] = meshgrid(rlin, zlin);
my_Qj = griddata(R_grid, Z_grid, V', r_grid, z_grid, 'linear');

% Deuxieme interpolation
Vq = griddata(r_grid, z_grid, my_Qj, r', z', 'linear');  %Interpolation spatiale (r,z)
Vq(isnan(Vq))=0;
end