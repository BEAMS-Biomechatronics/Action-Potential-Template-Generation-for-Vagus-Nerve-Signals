%% Dans CAP_build_1fib_Hugo.m, après avoir calcule action_current
% action_current = (currentFiber.ion_current + currentFiber.conductance_current + currentFiber.injected_current);

% % On vient de calculer la somme des courants dans les NR. Pour la suite,
% on veut supprimer les courants de la partie gauche du nerf; on veut
% garder seulement dans un sens

%             nerve_second_part = 1.98; % to keep the positive part of the nerve (in the z axis) and avoid the center of the nerve
%             zero_potential_value = -7.7e-5; % action current is closed to this value (almost 0)
%             first_time_to_start = 1; % initialize action current to 0 before this time (to avoid high potential induced by electrodes)
%             ix = []; iy = []; ixx = [];
% %             if fibreD == 8e-6 && TC == 37
%             action_current(:,1:round(nNodes/nerve_second_part)) = zeros(size(action_current,1), round(nNodes/nerve_second_part));
%             [ix,iy] = find(action_current<zero_potential_value); % il y a une première partie plus petite que 0 -> je veux m'en débarasser
%             ixx = find(ix<first_time_to_start); % cela ne concerne que les x premiers instants
%             action_current(ix(ixx), iy(ixx)) = zero_potential_value;
%             ix = []; iy = []; ixx = [];
%             [ix,iy] = find(action_current>0); % il y a une première partie plus grande que 0 -> je veux m'en débarasser
%             ixx = find(ix<first_time_to_start); % cela ne concerne que les x premiers instants
%             action_current(ix(ixx), iy(ixx)) = zero_potential_value;
% %             end

%% Dans CAP_build_1fib_Hugo.m, au tout début 
%% Set parameters in COMSOL 
load parameters;
fiberDiam = 8e-6;
load(['parameters_AP_' num2str(fiberDiam*1e6) 'um_37degC']);
%Le "mphload" ne permet pas de modifier le modèle COMSOL directement, il
%charge une version locale du modèle, mais le modèle en soi n'est pas
%modifié

%On va donc ici charger une version locale, lui assigner les paramètres de
%l'étude précédente et ensuite écraser le modèle avec la version locale. De
%cette manière, le modèle est bien modifié (le modèle ne doit pas être
%ouvert dans COMSOL quand on veut sauvegarder la version locale)
absolute_path = 'C:\Users\Hugo\Documents\Model FEAPP';
relative_path = '\COMSOL_VE\MATLAB2\Nerve_Model_Matlab2.mph';
path_model2 = [pwd relative_path];

model=mphload(path_model2);

%On set les paramètres utilisés dans l'étude précédente
% nerveD = 0.001;
model.param.set('nerveD',sprintf('%0.5f[m]',nerveD));
model.param.set('sigmaSaline',sprintf('%0.10f[S/m]',sigmaSaline));
model.param.set('sigmaPerineurium',sprintf('%0.10f[S/m]',sigmaPerineurium));
model.param.set('sigmaFasciculexy',sprintf('%0.10f[S/m]',sigmaFasciculexy));
model.param.set('sigmaFasciculez',sprintf('%0.10f[S/m]',sigmaFasciculez));
model.param.set('sigmaEXT',sprintf('%0.10f[m]',sigmaEXT));
model.param.set('ring1D',sprintf('%0.6f[m]',ring1D));
model.param.set('ring2D',sprintf('%0.6f[m]',ring2D));
model.param.set('ringD',sprintf('%0.6f[m]',ringD));
model.param.set('nerveL',sprintf('%0.6f[m]',nerveL));
model.param.set('ringTorusD',sprintf('%0.6f[m]',ringTorusD));
model.param.set('ringCuffD','nerveD*1.5');
model.param.set('courant',sprintf('%0.5f[A]',courant));
model.param.set('LayerBC','0.05[m]');
model.param.set('cuffL',sprintf('%0.6f[m]',cuffL));

model.save(path_model2);