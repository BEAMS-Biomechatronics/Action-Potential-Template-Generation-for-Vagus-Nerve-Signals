function [XYZFiberCoordinates] = getFiberCoordinates(varargin)
% getFiberCoordinates('1D or 2D',   [zDistance], [ciblePosition])
% Get the coordonates of the nodes of the fibers.
%
% If a second argument zDistance is sent, a mesh is generated with
% zDistance as distance between nodes.
%
% Send back XYZFiberCoordinates [xyz(1,2,3),fibreN ,nNoeuds]
% Variables are extracted from parameters.mat


    import selectivity.fibreModel.fibre.*
    import selectivity.utilities.*
    
    load parameters;
    
    
    caseDimension   = '';
    fiberCase       = 1; % default case, concern a fiber
    zDistance       = 0;
    ciblePosition   = 0; %only needed if varargin{3} is not empty
    
    % treatment of input parameters
    if nargin == 1 || nargin == 2 || nargin == 3
        caseDimension               = varargin{1};
        if nargin == 2  && ~isempty(varargin{2})% not a fiber, just some dots 
            fiberCase = 0;
            zDistance = varargin{2};
        end            
        if nargin == 3
            ciblePosition = varargin{3}; % en pourcent du rayon
            if strcmp('2D', caseDimension)
                error('selectivity:utilities:getFiberCoordinates', 'Special space is only available for 1D case !' );
            end
        end
    else
        error('wrong number of inputs');
    end

    % not indetically spaced (usefull for optimization)
    % Only for 1D case

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% cas 1D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if strcmp('1D', caseDimension)
        
        if ciblePosition == 0
            %% probe to check how many points needed on the line to respect
            % approximatively the number of points defined in 'nPoints1D'.
            sLine = linspace(0,1,30000);

            xLine = line1D(1,1)*ones(1,30000) + (line1D(2,1)-line1D(1,1))*sLine;
            yLine = line1D(1,2)*ones(1,30000) + (line1D(2,2)-line1D(1,2))*sLine;

            % To know if points of the line are inside fascile or not
            in = zeros(1,30000);

            % Make some polygon for contour of fascicles
            %contourFascicle =   cell(1,5);
            contourFascicle  = fasciclesGeometry.polyShape;
            cont = zeros(100,2);
            for k=1:numel(contourFascicle)
                %contourFascicle{k} = circle(fasciclesGeometry.centralPosition(:,k), fasciclesGeometry.diameterArray(k)/2, 100);
                cont        = contourFascicle{k};%squeeze(cell2mat(contourFascicle(1,k)));
                xCont       = cont(1,:);
                yCont       = cont(2,:);

                in = in + inpolygon(xLine, yLine, xCont ,yCont);
            end

            xLine = xLine(find(in));
            yLine = yLine(find(in));

            nOfElementInside = length(xLine);
            nOfTotalElement  = round((nPoints1D)*30000/nOfElementInside); %MODIF !


            %% final coordinates
            sLine = linspace(0,1,nOfTotalElement);
            clear xLine yLine in

            xLine                   = line1D(1,1)*ones(1,nOfTotalElement) + (line1D(2,1)-line1D(1,1))*sLine;
            yLine                   = line1D(1,2)*ones(1,nOfTotalElement) + (line1D(2,2)-line1D(1,2))*sLine;




            % To know if points of the line are inside fascile or not
            inFascicles             = zeros(numel(contourFascicle),nOfTotalElement);



            for k=1:numel(contourFascicle)

                cont                        = contourFascicle{k};%squeeze(cell2mat(contourFascicle(1,k)));
                xCont                       = cont(1,:);
                yCont                       = cont(2,:);

                inFascicles(k,:)            = inpolygon(xLine, yLine, xCont ,yCont);
            end
            in = inFascicles;





            % 
            lInternodal                 = 0;
            if fiberCase
                % calcul de la longueur internodale à partie de fiberD
                internodalLengthFiber       = fibre(fibreD,1,20);        
                lInternodal                 = internodalLengthFiber.L;
            else
                lInternodal                 = zDistance;
            end

            % nombre de noeuds sur la longueur de la fibre
            nNoeuds                     = floor((nerveL-lInternodal)/lInternodal)+1-2;
            nFibreFascicle              = sum(inFascicles,2);

            numNoeuds       = [];
            if mod(nNoeuds,2)==1
                numNoeuds   = [ceil(-nNoeuds/2):1:floor(nNoeuds/2)];
            else
                numNoeuds   = [round(-nNoeuds/2):1:round(nNoeuds/2-1)];
            end

            % final x and y vectors
            xLineInside     = xLine(find(in));
            yLineInside     = yLine(find(in));
            zLineInside     = [numNoeuds * lInternodal + shift*lInternodal*ones(1,nNoeuds)];

            xGrid           = xLineInside' * ones(1,nNoeuds);
            yGrid           = yLineInside' * ones(1,nNoeuds);
            zGrid           = ones(numel(xLineInside),1) * zLineInside;

            XYZFiberCoordinates = zeros(3, numel(xLineInside), numel(zLineInside));

            XYZFiberCoordinates(1,:,:) = xGrid;
            XYZFiberCoordinates(2,:,:) = yGrid;
            XYZFiberCoordinates(3,:,:) = zGrid;
            
        %% progressive distribution to cible
        else
            if mod(nPoints1D, 2) == 1 % ça doit être pair
                error('nPoints1D must be a multiple of 2');
            else
                %% initial and end point of the distribution
                x0              = line1D(1,1);
                y0              = line1D(1,2);
                xf              = line1D(2,1)-50e-6;
                yf              = line1D(2,2);
                
                xLine           = zeros(1,nPoints1D);      
                yLine           = zeros(1,nPoints1D);
                
                xLine(1,1)      = x0;  
                xLine(1,end)    = xf;
                yLine(1,1)      = y0;
                yLine(1,end)    = yf;
                
                xCible          = x0 + (xf-x0)*ciblePosition;
                
                
                %% computing distribution
                for i=2:nPoints1D/2
                    % convergence from x0 to cible
                    xLine(1,i)                 = (xLine(1,i-1)+xCible)/2;
                    yLine(1,i)                 = y0;
                    % convergence from xf to cible
                    xLine(1,nPoints1D-i+1)     = (xLine(1,nPoints1D-i+2)+xCible)/2;
                    yLine(1,nPoints1D-i+1)     = y0;
                end
                
                %% data arrays
                
                
                
                lInternodal                 = 0;
                if fiberCase
                    % calcul de la longueur internodale à partie de fiberD
                    internodalLengthFiber       = fibre(fibreD,1,20);        
                    lInternodal                 = internodalLengthFiber.L;
                else
                    lInternodal                 = zDistance;
                end

                % nombre de noeuds sur la longueur de la fibre
                if fiberCase
                    nNoeuds                     = floor((nerveL-lInternodal)/lInternodal)+1-2;
                else
                    nNoeuds                     = floor(1.1*cuffL/lInternodal);
                end
                
                % z coordinates
                numNoeuds       = [];
                if mod(nNoeuds,2)==1
                    numNoeuds   = [ceil(-nNoeuds/2):1:floor(nNoeuds/2)];
                else
                    numNoeuds   = [round(-nNoeuds/2):1:round(nNoeuds/2-1)];
                end
                
                zLine     = [numNoeuds * lInternodal + shift*lInternodal*ones(1,nNoeuds)];
                
                % data                 
                xGrid           = xLine' * ones(1,nNoeuds);
                yGrid           = yLine' * ones(1,nNoeuds);
                zGrid           = ones(numel(xLine),1) * zLine;

                XYZFiberCoordinates = zeros(3, numel(xLine), numel(zLine));

                XYZFiberCoordinates(1,:,:) = xGrid;
                XYZFiberCoordinates(2,:,:) = yGrid;
                XYZFiberCoordinates(3,:,:) = zGrid;
            end
                
        end
        
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% cas 2D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    elseif strcmp('2D', caseDimension)

        
        % fascicle geomtrical properties
        
%         XY0_F1              = fasciclesGeometry.centralPosition(:,1);
%         XY0_F2              = fasciclesGeometry.centralPosition(:,2);
%         XY0_F3              = fasciclesGeometry.centralPosition(:,3);
%         XY0_F4              = fasciclesGeometry.centralPosition(:,4);
%         XY0_F5              = fasciclesGeometry.centralPosition(:,5);
%         
%         fascicleDArray      = fasciclesGeometry.diameterArray;
%         

        % main properties of polygons defining contours of fasciles
        nFascicles  = fasciclesGeometry.numberOfFascicles;
        minX        = zeros(1,nFascicles);
        maxX        = zeros(1,nFascicles);
        minY        = zeros(1,nFascicles);
        maxY        = zeros(1,nFascicles);
        polygonArea = zeros(1,nFascicles);
        
        for k = 1:nFascicles
            minX(k)         = min(fasciclesGeometry.polyShape{k}(1,:));
            maxX(k)         = max(fasciclesGeometry.polyShape{k}(1,:));
            minY(k)         = min(fasciclesGeometry.polyShape{k}(2,:));
            maxY(k)         = max(fasciclesGeometry.polyShape{k}(2,:));
            polygonArea(k)  = polyarea(fasciclesGeometry.polyShape{k}(1,:)', fasciclesGeometry.polyShape{k}(2,:)');
        end

        %maillage
        LX = max(maxX) - min(minX);
        LY = max(maxY) - min(minY);
        
        % nombre de point dans le maillage englobant pour atteindre la
        % densité requise
        nTot    = LX * LY * density2D;
        
        nY      = round(sqrt(nTot*LY/LX));
        nX      = round(nTot/nY);
        
        pasX    = LX/nX;
        pasY    = LY/nY;
        
        
        % xy vectors
        xGrid   = min(minX)+pasX/2:pasX:max(maxX)-pasX/2;
        yGrid   = min(minY)+pasY/2:pasY:max(maxY)-pasY/2;
        
        %z vector
        
         % 
        lInternodal                 = 0;
        if fiberCase
            % calcul de la longueur internodale à partie de fiberD
            internodalLengthFiber       = fibre(fibreD,1,20);        
            lInternodal                 = internodalLengthFiber.L;
        else
            lInternodal                 = zDistance;
        end
        
        % nombre de noeuds sur la longueur de la fibre
        nNoeuds = floor((nerveL-lInternodal)/lInternodal)+1-2;
        
        %traitement du cas pair et impair
        numNoeuds = [];
        if mod(nNoeuds,2)==1
            numNoeuds = [ceil(-nNoeuds/2):1:floor(nNoeuds/2)];
        else
            numNoeuds = [round(-nNoeuds/2):1:round(nNoeuds/2-1)];
        end
        
        
        zGrid                   = numNoeuds * lInternodal + shift*lInternodal*ones(1,nNoeuds);
        
        
        [xMesh, yMesh, zMesh]   = meshgrid(xGrid, yGrid, zGrid);
        xMeshLine               = reshape(xMesh, [nX*nY, nNoeuds]);
        yMeshLine               = reshape(yMesh, [nX*nY, nNoeuds]);
        zMeshLine               = reshape(zMesh, [nX*nY, nNoeuds]);
        
        
        
        mask                    = zeros(size(squeeze(xMeshLine(:,1))));
        for k=1:nFascicles
            mask                = mask + inpolygon(squeeze(xMeshLine(:,1)),squeeze(yMeshLine(:,1)),fasciclesGeometry.polyShape{k}(1,:)', fasciclesGeometry.polyShape{k}(2,:)');
        end
        
        

        %calcul de la longueur internodale à partie de fiberD
        
        indicesFasciles             = find(mask);
        XYZFiberCoordinates         = zeros(3,sum(mask), numel(zGrid));
        XYZFiberCoordinates(1,:,:)  = xMeshLine(indicesFasciles, :);
        XYZFiberCoordinates(2,:,:)  = yMeshLine(indicesFasciles, :);
        XYZFiberCoordinates(3,:,:)  = zMeshLine(indicesFasciles, :);
        
     

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% cas 0D
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    elseif strcmp('0D', caseDimension)
        
           
        % length between nodes
        internodalLengthFiber = fibre(fibreD,1,20);
        lInternodal = internodalLengthFiber.L;
        
        % nombre de noeuds sur la longueur de la fibre
        nNoeuds = floor((nerveL-lInternodal)/lInternodal)+1-2;
        
        %traitement du cas pair et impair
        numNoeuds = [];
        if mod(nNoeuds,2)==1
            numNoeuds = [ceil(-nNoeuds/2):1:floor(nNoeuds/2)];
        else
            numNoeuds = [round(-nNoeuds/2):1:round(nNoeuds/2-1)];
        end
        
        
        zGrid                   = numNoeuds * lInternodal + shift*lInternodal*ones(1,nNoeuds);
        
        positionFiber0D
        XYZFiberCoordinates = zeros(3, 1, numel(zGrid));
        
        XYZFiberCoordinates(1,1,:)  = positionFiber0D(1)*ones(size(zGrid));
        XYZFiberCoordinates(2,1,:)  = positionFiber0D(2)*ones(size(zGrid));
        XYZFiberCoordinates(3,1,:)  = zGrid;
        

    % error msg
    else
        error('selectivity:utilities:getFiberCoordinates:inputParameters','Wrong number of parameters (1 for 1D, 3 for 2D)');
    end
    if strcmp('2D', caseDimension)
        display(['There is ' num2str(numel(XYZFiberCoordinates(1,:,1))) ' fibers generated with a density of ' num2str(density2D/1e6) ' [fibres/mm²].'])
    elseif strcmp('1D', caseDimension)
        display(['There is ' num2str(numel(XYZFiberCoordinates(1,:,1))) ' fibers generated (1D case).'])
    else
        display(['There is ' num2str(numel(XYZFiberCoordinates(1,:,1))) ' fibers generated (0D case).'])
    end

end