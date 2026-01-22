function Vq = interpXYZ_1fib (CoordonneesFibresXY,CoordonneesFibresZ,B,r,z,idx,nFibreParFascicule)
%--------------------------------------------------
% Interpolation 3D (x,y,z) de la densite de courant
% Permet de trouver la valeur de la densite de courant aux points demandes par
% COMSOL pour un seul type de diametre de fibre
%
% Input : -CoordonneesFibresXY : Position (x,y) des fibres dans le maillage 
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

nnoeuds = length(CoordonneesFibresZ);

R = kron(CoordonneesFibresXY (1,:),ones(1,nnoeuds)); % Points où la densite de courant est connue (coordonnee radiale R du maillage et noeuds Z)
Z = repmat(CoordonneesFibresZ',nFibreParFascicule,1)';

V = []; % Matrice regroupant les tensions en des points connus
V_ = zeros(1,nnoeuds);

for i=1  % for fiber 1
    V_(1,:) = B{idx,i}(1,:);
    V(1,end+1:end+nnoeuds)= V_;
end
for i = 2:nFibreParFascicule
    V(1, end+1:end+nnoeuds) = zeros(1, nnoeuds);
end


% for i = 1:nFibreParFascicule-1 % for fiber 12
%     V(1, end+1:end+nnoeuds) = zeros(1, nnoeuds);
% end
% for i=nFibreParFascicule
%     V_(1,:) = B{idx,i}(1,:);
%     V(1,end+1:end+nnoeuds)= V_;
% end

Vq = griddata(R,Z,V,r',z');  %Interpolation spatiale (r,z)

Vq(isnan(Vq))=0;   % On met a zero pour les points en dehors du domaine

end