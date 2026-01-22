classdef fascicles < handle
% fasciclesnerveD [m], [polyShape = cell (1 x nFas), numberOfFascicles, fitToNerve = true,{false}]
    % - fasciclesnerveD is the diameter of the nerve needed to fill it with
    %   fascicles. Position of the nerve is supposed to be centered in (0,0).
    % - polyShape is the points of polygon defining facicles 
    %   diameters is an array with diameter of the different fascicles
    % - numberOfFascicles is obvious
    % - fitToNerve is a boolean which enable or not the matching of
    %   fascicles inside the nerve (normalization + centering). 
    % If the optional parameters are not used as inputs, the default
    % parameters will apply (400 µm Diameters, with stellar disposition).

    properties
        
        polyShape;
        numberOfFascicles;        
        nerveD;
        fitToNerve;
                
    end
    
    methods
        function o = fascicles(varargin)
        % fascicles(nerveD [m], [polyShape = cell (1 x nFas), numberOfFascicles, fitToNerve = true,{false}])
            
            import selectivity.utilities.*
        
            % v1.0
            if nargin == 3 || nargin == 4
                o.nerveD                = varargin{1};
                o.polyShape             = varargin{2}; %cell 1 x nFas [x1 x2 x3... ; y1 y2 y3 ...]
                o.numberOfFascicles     = varargin{3};
                if nargin == 4
                    o.fitToNerve        = varargin{4};
                else
                    o.fitToNerve        = 0;
                end
            % default
            elseif nargin == 1
                o.nerveD                = varargin{1};
                o.polyShape             = cell(1,5);
                o.polyShape{1}          = circle([0 0], 200e-6, 15)';
                o.polyShape{2}          = circle([o.nerveD/4 0] , 200e-6, 15)';
                o.polyShape{3}          = circle([0 o.nerveD/4] , 200e-6, 15)';
                o.polyShape{4}          = circle([-o.nerveD/4 0], 200e-6, 15)';
                o.polyShape{5}          = circle([0 -o.nerveD/4], 200e-6, 15)';
                o.numberOfFascicles     = 5;
                o.fitToNerve            = 0;
                                
            else
                
                error('selectivity:comsol:fascicles','error : input number of arguments is incorrect.');
            end
                   
            % homothétie to have all contour inside the nerve (v1.0)
            if o.fitToNerve
                
                
                % main properties of polygons defining contours of fasciles
                minX        = zeros(1,o.numberOfFascicles);
                maxX        = zeros(1,o.numberOfFascicles);
                minY        = zeros(1,o.numberOfFascicles);
                maxY        = zeros(1,o.numberOfFascicles);
                polygonArea = zeros(1,o.numberOfFascicles);
                
                % saving points
                xSave = [];
                ySave = [];

                for k = 1:o.numberOfFascicles
                    minX(k)         = min(o.polyShape{k}(1,:));
                    maxX(k)         = max(o.polyShape{k}(1,:));
                    minY(k)         = min(o.polyShape{k}(2,:));
                    maxY(k)         = max(o.polyShape{k}(2,:));
                    polygonArea(k)  = polyarea(o.polyShape{k}(1,:)', o.polyShape{k}(2,:)');
                    
                    xSave = [xSave o.polyShape{k}(1,:)];
                    ySave = [ySave o.polyShape{k}(2,:)];
                end

                % XY coordinates in the right shape
                XY = [xSave; ySave]';
                
                % finding the minimum radius circle 
                [minimumRadius,centerCircle,~]= selectivity.utilities.circles.ExactMinBoundCircle(XY);
                
                %maillage
%                 LX = max(maxX) - min(minX);
%                 LY = max(maxY) - min(minY);
%                 
                % center
%                 centerX         = (max(maxX)+min(minX))/2;
%                 centerY         = (max(maxY)+min(minY))/2;
%                 
                % set center to zero
                for k=1:o.numberOfFascicles 
                    o.polyShape{k} = o.polyShape{k} - centerCircle' * ones(size(o.polyShape{k}(1,:)));
                end
                
                
%                 maxDistanceFromCenter = 0;
%                 for k=1:o.numberOfFascicles
%                     contourPoly         = o.polyShape{k};
%                     distanceFromCenter = max(sqrt(contourPoly(1,:).^2+contourPoly(2,:).^2));
%                     if distanceFromCenter > maxDistanceFromCenter
%                         maxDistanceFromCenter = distanceFromCenter;
%                     end                
%                 end
                for k=1:o.numberOfFascicles 
                    o.polyShape{k} = (0.95*o.nerveD/2) * o.polyShape{k} / minimumRadius;
                end
            end
        end
        
        function comsolGeom(o, model)
            
            
            % working plan to drawn polygon (extrusion after)
            model.geom('geom1').feature.create('wp1', 'WorkPlane');
            model.geom('geom1').feature('wp1').set('unite', true);
            model.geom('geom1').feature('wp1').set('quickz', 'nerveLComsol/2');
            model.geom('geom1').runPre('fin');
                
            for k = 1:o.numberOfFascicles
                polyStringName          = sprintf('pol%d', k);

                XPoly                   = num2str(o.polyShape{k}(1,:));
                YPoly                   = num2str(o.polyShape{k}(2,:));

               
                model.geom('geom1').feature('wp1').geom.create(polyStringName, 'Polygon');
                model.geom('geom1').feature('wp1').geom.feature(polyStringName).set('x', XPoly);
                model.geom('geom1').feature('wp1').geom.feature(polyStringName).set('y', YPoly);
                model.geom('geom1').feature('wp1').geom.run(polyStringName);
                model.geom('geom1').run('wp1');

                
            end
            
            % extrusion
            model.geom('geom1').feature.create('ext1', 'Extrude');
            model.geom('geom1').run('ext1');
            model.geom('geom1').feature('ext1').setIndex('distance', 'nerveLComsol', 0);

            model.geom('geom1').feature('ext1').set('reverse', 'on');

            model.geom('geom1').feature('ext1').set('contributeto', 'csel4');

            model.geom('geom1').feature('ext1').set('selresult', 'on');
            model.geom('geom1').feature('ext1').set('selresultshow', 'all');

        end
    end
end

