function [x_mesh,y_mesh] = create_mesh(nerveD,nFibreParFascicule)
%--------------------------------------------------
% Cree le maillage en prenant en compte l'axisymetrie.
% Fibres situees sur un rayon du nerf.
%
% Input : -nerveD : Diametre du nerf 
%         -nFibreParFascicule : Nombre de fibres dans le maillage 
%
% Output : -x_mesh [1xnFibreParFascicule] Coordonnees x des fibres du maillage
%          -y_mesh [1xnFibreParFascicule] Coordonnees y des fibres du maillage
%--------------------------------------------------

% ang=0:0.01:2*pi;
% xp=(nerveD/2)*cos(ang);
% yp=(nerveD/2)*sin(ang);
% figure; plot(xp,yp,'LineWidth',2); hold on

% R=round((nerveD/2)-(nerveD/50),5);
distance_intermesh = round(nerveD/2/nFibreParFascicule,8);
x_mesh = 0:distance_intermesh:(nFibreParFascicule-1)*distance_intermesh;
y_mesh = zeros (1, length(x_mesh));

% plot (x_mesh,y_mesh,'k.','MarkerSize',5);

end




