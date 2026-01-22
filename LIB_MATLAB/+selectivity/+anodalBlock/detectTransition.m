function [varargout] = detectTransition()
%detectTransition()
% Only 1D
    import com.comsol.model.*
    import com.comsol.model.util.*
    import selectivity.comsol.*
    import selectivity.fibreModel.fibre.*
    import selectivity.utilities.*
    import selectivity.anodalBlock.*
    
    warning off MATLAB:MKDIR:DirectoryExists
    
    
    
    % Do not use Local MPI
    distcomp.feature( 'LocalUseMpiexec', false )
    % delete the current parallel task pool if running
    delete(gcp);
    
    
    % random folder to save Data
    folderSaveData = selectivity.utilities.randomString(10);
    
    % The function can return the name of the folder where data has been
    % saved (random folder name). 
    if nargout == 1
        varargout{1} = folderSaveData;
    end
    
    %permet de forcer le recalcul des tensions par FEM, même si cela a déjà été fait. (default = 0)
    %La demande est faites par une "boite" de dialogue en début d'exécution. 
    force = 0;              
      
    
    
    %% PARAMETRES
    % Modification après avoir créer les paramètres par défaut.
    % Pour modifier un paramètre, modifer le fichier parameter.mat, avec la
    % commande suivante : save('parameters.mat', nomVariable, '-append');
    parametersParaboleAnode();
    load parameters
    nNodeShift = nNodeShift;
    
    

    % making directory if does not exist yet
    mkdir('figure');
    
    % run the parallel process
    parpool('local',nProc);  
    
    % boucle pour la taille de fibre
    for w=1:numel(fiberSize)
        
        % boucle pour le shift
        for n=1:nNodeShift
            

            %% Changement de valeur des paramètres
            fibreD  = fiberSize(w);           %m
            shift   = (n-1)/nNodeShift;
            save('parameters.mat', 'fibreD', 'shift', '-append');
            save('parameters.mat', 'current1', '-append');


            

            %% MODELE TENSION COMSOL
            %On donne un nom au fichier comsol qui va contenir les résultats de la
            %simulation. De cette façon, on n'est pas obligé de recalculer les tensions
            %pour chaque simulation. Pour forcer le recalcul de ces simulations, on
            %peut mettre à la variable 'force', la valeur true (1).

            filenameVe = sprintf('r1D_%f_r2D_%f_rD_%f_cuffL_%f_alpha_%f_sigmaExt_%f.mph',ring1D*1e3 ,ring2D*1e3 ,ringD*1e3, cuffL*1e3, alphaP, sigmaEXT);
            a=dir('.\COMSOL_VE\');
            b=struct2cell(a);
            fileNameVeDoNotExist = ~any(ismember(b(1,:),filenameVe));

            %premier cas, si on force à recalculer les tensions dans le modèle FEM du
            %nerf ou que le modèle n'a pas encore été résolu, le modèle est chargé, 
            %résolu, puis sauvegardé. 
            if fileNameVeDoNotExist
                %load model

                model   = comsolModel();
               

                %shortcut Model
                study   = model.study('std1');
                data    = model.result.dataset('dset1');

                %running model
                ModelUtil.showProgress(true);
                
                % make subfolder if does not exist and save the model
                mkdir('COMSOL_VE');
                model.save([pwd '\COMSOL_VE\' filenameVe]);
            % sinon, on charge directement le fichier COMSOL contenant déjà la solution
            % pour avoir accès aux valeurs de la tension.
            else
                model   = mphload([pwd '\COMSOL_VE\' filenameVe]);  

                %shortcut Model
                study   = model.study('std1');
                data    = model.result.dataset('dset1');

            end



            
            

            %% Extraction des tensions externes aux noeuds
            % A refaire pour chaque taille de fibre, et pour chaque shift
            % des noeuds. 
            
            % Le calcul des coordonnées des noeuds de la fibre dépend de
            % la taille de la fibre et du shift des noeuds. Il faut donc
            % appeller cette fonction à chaque fois que l'on désire changer
            % de taille de fibre ou de shift des noeuds. 
            CoordonneesFibresXYZ  = getFiberCoordinates('1D');
        
            % Extraction de la tension aux coordonnées des noeuds depuis le
            % modèle COMSOL. 
            Ve                  = getExternalVoltage(model, CoordonneesFibresXYZ);


            %% MODELE FIBRE MATLAB
        
            
            % finding number of fascicles and number of fibers by fascicles.
            sizeXYZ                 = size(CoordonneesFibresXYZ);
            
            nFibre                  = sizeXYZ(2);
            nNoeuds                 = sizeXYZ(3);
            
            % tableau pour sauvegarder le type. 
            % peut-être à faire après sur les données. 
            type                         = [];
            Vm                           = cell(1,nFibre);
            time                         = cell(1,nFibre);
            fibreSave                    = cell(1,nFibre);
            
            %boucle fibres dans fascicules
            for m = 1:1
                
                % save the type for the actual fiber
                typeTemp            = zeros(1,nFibre); 
                
                
                % making an array with waveform object for shared parallel
                % computing. (array of copy)                
                WF1Array(1:nFibre)          = WF1.copy();
                WF2Array(1:nFibre)          = WF2.copy();
                
                TCArray(1:nFibre)           = TC;
                nNoeudsArray(1:nFibre)      = nNoeuds;
                fibreDArray(1:nFibre)       = fibreD;
                current1Array(1:nFibre)     = current1;
                current2Array(1:nFibre)     = current2;
                
                
                % same for solution to save
                VmTemp                      = cell(1,nFibre);
                timeTemp                    = cell(1,nFibre);
                fibreSaveTemp               = cell(1,nFibre);
                
                % Ve(nFascicle, nFibre, nNoeuds) -> Vek(nFibre, nNoeuds)
                Vek                         = squeeze(Ve(:,:));
                
                
                indicePositionLeft          = 1;
                indicePositionRight         = nFibre;
                
                if nPointsDicho(nLevelDicho, nProc) ~= nPoints1D
                    error('selectivity:anodalBlock:detesctTransition', 'error nPoints1D must be comptued by selectivity.utilities.nPointsDicho');
                end
                
                
                type                                    = zeros(1,nFibre);
                onlyOneType                             = false;
                
                for y=1:nLevelDicho
                    
                    if ~onlyOneType % if there is only one type we should skip next lines
                        
                        % first iteration includes the exteriors
                        indicesPosition = [];
                        if y==1
                            step    = (indicePositionRight-indicePositionLeft)/(nProc-1);
                            indicesPosition = indicePositionLeft:step:indicePositionRight;
                        % next iterations does not include range limits
                        % (already computed)
                        else
                            step    = (indicePositionRight-indicePositionLeft)/(nProc+1);
                            indicesPosition = indicePositionLeft+step:step:indicePositionRight-step;
                        end

                        % writing during a parallel loop can only be adressed
                        % in the simple form : Array(k). So we need temporary
                        % variables. 
                        VmLoop              = cell(1,nProc);
                        timeLoop            = cell(1,nProc);
                        fibreLoop           = cell(1,nProc);
                        typeLoop            = cell(1,nProc);
                        recordFigArray      = zeros(1,nProc);
                        recordFigArray(:)   = recordFig;

                        
                        parfor k=1:nProc
                            
                            indPosk         = int16(indicesPosition(k));

                            fibreInstance   = fibre(fibreDArray(indPosk), nNoeudsArray(indPosk), TCArray(indPosk), WF1Array(indPosk), WF2Array(indPosk));


                            % Extraction de la tension externe dans le tableau Vek
                            VeFibre         = Vek(indPosk,:);

                            %Introduction des valeurs de Ve aux noeuds dans le
                            %modèle de la fibre. 


                            fibreInstance       = fibreInstance.setVe(VeFibre);
                            fibreInstance       = fibreInstance.setCurrent([current1Array(indPosk) current2Array(indPosk)]);

                            %Résolution du problème d'une fibre soumise à un potentiel Ve
                            %aux noeuds. 
                            fibreInstance       = fibreInstance.solve();

                            % Save some data (Vm and time)
                            VmLoop{k}           = squeeze(fibreInstance.solution(:,1:fibreInstance.n));
                            timeLoop{k}         = fibreInstance.time;
                            fibreLoop{k}        = fibreInstance;

                            %Analyse de la propagation des AP et classification de la fibre dans l'une des 4 catégories.            
                            APtracking          = AP();
                            APtracking          = APtracking.findAP(fibreInstance.solution(:,1:fibreInstance.n), fibreInstance.time, fibreInstance.Ve', fibreInstance.WF1.TPulseGlobal);

                            %Sauvegarde
                            typeLoop{k}         = APtracking.type;

                            
                            % enregistrement des figures
                            if recordFigArray(k)

                                %Mise en forme du résultat pour la fibre
                                fig                 = fibreInstance.plotBaton(15,APtracking);


                                figureFileName      = sprintf('fibreNum_%f',indPosk);
                                figureFileName      = strrep(figureFileName, '.', '_');
                                saveas(fig, ['./figure/' figureFileName '.fig']);
    
                            end
                            
                            %progression variable
                            
                            %progressionShift    = n/nNodeShift;

                            % progression display
                            
                            %display(sprintf('Progression shift (level 2) : %0.2f %%',progressionShift*100));

                            
                        end

                        display(sprintf('progression dichotomie (level 2) : %d', y));
                    
                    
                    
                    for k=1:nProc
                        indPosk                   = int16(indicesPosition(k));
                        VmTemp{indPosk}           = VmLoop{k};
                        timeTemp{indPosk}         = timeLoop{k};
                        fibreSaveTemp{indPosk}    = fibreLoop{k};
                        typeTemp(indPosk)         = typeLoop{k};
                    end
                    
                    
                    % lookin for limit types
                    positionType2           = find(typeTemp==2);
                    positionType3           = find(typeTemp==3);

                    % si pas trouvé de limite, on n'a qu'un seul typ
                    if ~isempty(positionType2) 
                        indicePositionLeft      = positionType2(end);
                    else
                        % tout est de type 3
                        onlyOneType     = true;
                        type(:)         = 3;

                    end

                    if ~isempty(positionType3) 
                        indicePositionRight      = positionType3(1);
                    else
                        onlyOneType     = true;
                        type(:)         = 2;
                    end
                
                
                
                    display('==================================')
                    % record Vm, time, and type in cell array         

                    % Dans le cas où il y a bien une limite à gauche et une à
                    % droite. 
                    if ~onlyOneType
                        type(1:indicePositionLeft)          = 2;
                    end

                    if ~onlyOneType
                        type(indicePositionRight:end)       = 3;
                    end

                    Vm(:)                                   = VmTemp;
                    time(:)                                 = timeTemp;
                    fibreSave(:)                            = fibreSaveTemp;

                    end
           
                end
            
                display(sprintf('Taille fibre progression (level 1) : %d/3',w));
           
            
            
            filename                                = ['shift_' num2str(shift) '.mat'];
            filename                                = strrep(filename, '.', '_');
            
            if recordVm
                save(filename, 'Vm', 'type', 'time', 'CoordonneesFibresXYZ', 'fibreSave');
            else
                save(filename, 'type', 'CoordonneesFibresXYZ');
            end
            saveData(folderSaveData);
            % making directory if does not exist yet
            mkdir('figure');
        end
        
    end
    
    % stop the parallel process
    
    
    end
    delete(gcp);
end
