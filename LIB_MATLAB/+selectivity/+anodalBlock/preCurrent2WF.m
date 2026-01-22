selectivity.comsol.parametersParaboleAnode()

import selectivity.stimWaveForm.*

% parameters
load parameters;
 
   
%changing parameters
nerveD                      = 1.35e-3;              %anciennement 1.9e-3
sigmaEXT                    = sigmaConjonctive;
current1                    = 0;
nNodeShift                  = 1;
ringCuffD                   = 1.9e-3*2;

save('parametersChange.mat', 'current1', 'nNodeShift', 'ringCuffD');
    
load frogSciatic; % frogSciatic, humanSciatic
    
fasciclesGeometry   = selectivity.comsol.fascicles(nerveD, polyShape, numberOfFascicles, 1);    
epFascicleLayer     = 50e-6; %epaisseur layer fascicle (90µm pour grosse, 50µm petite; ou 5% diamètre fascicule)
    
save('parametersChange.mat', 'fasciclesGeometry', 'epFascicleLayer','nerveD','sigmaEXT', '-append');

WF2                 	 = selectivity.stimWaveForm.stimWaveFormLinesByPieces(200e-6,    5e-6,   [[0 5e-3]; [1 1]]);
save('parametersChange.mat', 'WF2', '-append');

modelC      = comsolModel();

maxCurrent = 0;
for k=1:10
    current = selectivity.fibreModel.fibre.findCurrent(5e-6, [0 0], modelC, '12', k/10, 'alreadySolved');
    if current > maxCurrent 
        maxCurrent = current;
    end
    display(['Current : ' num2str(current)]);
end
save('parameters.mat', 'maxCurrent', '-append');
display(['Max current value to activate all fibers is : ' num2str(maxCurrent)]);










    
    
    
   
    