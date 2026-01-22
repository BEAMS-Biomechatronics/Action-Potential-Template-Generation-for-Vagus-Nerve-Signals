function WF = WFSlopeGenerator(pentes, intervalle, firstTime, TPulseGlobal, TTransition)
%WFSLOPEGENERATOR This function generates a WF instance based on the
%slopes. 
%   (pentes, intervalle, firstTime, lastTime, decreaseRange)
% * pentes : vecteur contenant l'ensemble des pentes
% * intervalle : intervalle entre chaque point
% * firstTime : Début de la première montée
% * lastTime : Début de la décroissance de la sigmoid.
% * decreaseRange : second paramètres de la sigmoid

    times           = [0 firstTime:intervalle:TPulseGlobal];
    amplitudes      = zeros(1,numel(times));
    
    %numel counts the number of elements in an array

    % first point is (0,0), second is (firstTime,0).
    for k=3:numel(times)
        if k-2 < numel(pentes)
            amplitudes(k)   = amplitudes(k-1) + pentes(k-2) * intervalle;
        else
            amplitudes(k)   = amplitudes(k-1) + pentes(end) * intervalle;
        end
    end
    
    amplitudes(find(amplitudes>1)) = 1;
    WFtemp  = selectivity.stimWaveForm.stimWaveFormLinesByPieces(TPulseGlobal, TTransition, [times 5e-3; amplitudes amplitudes(end)], 'notNormed');
    WF      = WFtemp.copy();

end

