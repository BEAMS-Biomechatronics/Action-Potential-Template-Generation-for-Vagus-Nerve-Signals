function Qj = current_source2 (x,y,z,t,fiberDiam,Temperature) 
%--------------------------------------------------
% densite de courant [A/m³] pour chaque temps et toutes les positions dans le nerf
% demandees par COMSOL. Prend en compte tous les diametres de fibres.
% Fonction appelee par COMSOL jusqu'a convergence de la solution.
% Utilisation d'une communication TCP/IP avec un serveur Matlab local (code server.m) afin de ne pas
% recharger les donnees a chaque appel de la fonction par Comsol.
%
% Input : -x,y,z : Coordonnees demandees par COMSOL
%         -t : Temps demande par COMSOL 
%
% Output : -Qj : Vecteur [1xNbre coordonnees x,y,z] de densite de courant
% pour tous les points (x,y,z) au temps t 
% 
%--------------------------------------------------
%% READ DATA
nerveD = 0.4e-3; % Do not change
%COMSOL GIVES ARRAYS, SHULD USE INDEXATION (1) EVEN FOR CONSTANT VALUES
fiberDiam = fiberDiam(1);
Temperature = Temperature(1);
t=t(1);  % Temps demande par Comsol
Qj=0;    % Densite de courant
internodeLength = 100*fiberDiam; % Do not change
currentDir = pwd;
parentDir = fileparts(currentDir);
if round(Temperature) == Temperature
    load([currentDir '\current_density_' num2str(round(fiberDiam*1e6)) 'um_' num2str(round(Temperature)) 'degC_mod3.mat']);
    load([parentDir '\parameters_AP_' num2str(round(fiberDiam*1e6)) 'um_' num2str(round(Temperature)) 'degC_mod3']);
    load([parentDir '\fiber_AP_build_' num2str(round(fiberDiam*1e6)) 'um_' num2str(round(Temperature)) 'degC_mod3']);
else
    strTemp = num2str(Temperature);
    strTemp = strsplit(strTemp,'.');
    load([currentDir '\current_density_' num2str(round(fiberDiam*1e6)) 'um_' strTemp{1} 'degC' strTemp{2} '_mod3.mat']);
    load([parentDir '\parameters_AP_' num2str(round(fiberDiam*1e6)) 'um_' strTemp{1} 'degC' strTemp{2} '_mod3']);
    load([parentDir '\fiber_AP_build_' num2str(round(fiberDiam*1e6)) 'um_' strTemp{1} 'degC' strTemp{2} '_mod3']);
end

%Qj = 0; % Current density
nFibers = 12;
[x_mesh, y_mesh] = create_mesh(nerveD, nFibers);

CoordonneesXY = [x_mesh; y_mesh]; % coordinates XY of the fibers
CoordonneesZ = [floor(-nNodes/2):1:floor(nNodes/2-1)] * internodeLength; % Z coordinates of the fibers at each Ranvier node
iFib = 1;
iDiam = 1;
my_current_density = current_density{iDiam, iFib};
current_density_T{iDiam, iFib} = interpT(my_current_density, time{iDiam, iFib}, t);   % Temporal interpolation
current_density_XYZT = interpZ_fib1(CoordonneesXY, CoordonneesZ, current_density_T{1, 1}, x, y, z); % Spatial interpolation
Qj = current_density_XYZT';
Qj = Qj * 1e9;   % Current density in A/m³
end

