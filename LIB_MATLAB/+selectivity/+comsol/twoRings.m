function out = twoRings(varargin)
% The function generates a Comsol model with two rings. Input parameters
% can be passed to the function or by arguments, or by generating default
% parameters with the 
% 
%
% Model exported on Sep 30 2016, 10:03 
import com.comsol.model.*
import com.comsol.model.util.*

if nargin == 16
    ring1D              = varargin{1};
    ring2D              = varargin{2};
    ringD               = varargin{3};
    nerveD              = varargin{4};
    fascicleD          = varargin{5};
    fasciculeLayer      = varargin{6};
    sigmaSaline         = varargin{7};
    sigmaEpineurium     = varargin{8};
    sigmaPerineurium    = varargin{9};
    sigmaFasciculexy    = varargin{10};
    sigmaFasciculez     = varargin{11};
    sigmaEXT            = varargin{12};
    nerveL              = varargin{13};
    ringTorusD          = varargin{14};
    courant             = varargin{15};
    cuffL               = varargin{16};
elseif nargin == 0
    load parameters.mat
else
    error('You did not enter the right number of input parameters');
    
end
    

model = ModelUtil.create('Model');

model.modelPath('E:\Documents\Dropbox\papier_nerf\simulation\selectivity\FH\Final_script\STATION\parallel_centered_overall\COMSOL_VE');

model.label('r1D_1.950000_r2D_2.600000_rD_0.400000.mph');

model.comments(['R1D 1.950000 r2D 2.600000 rD 0.400000\n\nUntitled\n\nR1D 1.950000 r2D 2.600000 rD 2.000000\n\nR1D 1.100000 r2D 1.100000 rD 1.000000\n\nUntitled\n\n']);

model.param.set('nerveD', '0.00190[m]');
model.param.set('fasciculeD', '0.00040000[m]');
model.param.set('fasciculeLayer', '0.00005000[m]');
model.param.set('sigmaSaline', '2.0000000000[S/m]');
model.param.set('sigmaEpineurium', '0.0080000000[S/m]');
model.param.set('sigmaPerineurium', '0.0033600000[S/m]');
model.param.set('sigmaFasciculexy', '0.0800000000[S/m]');
model.param.set('sigmaFasciculez', '0.5000000000[S/m]');
model.param.set('sigmaEXT', '0.1600000000[m]');
model.param.set('ring1D', '0.001950[m]');
model.param.set('ring2D', '0.002600[m]');
model.param.set('ringD', '0.000400[m]');
model.param.set('nerveL', '0.040000[m]');
model.param.set('ringTorusD', '0.000030[m]');
model.param.set('ringCuffD', 'nerveD*1.5');
model.param.set('courant', '1.00000[A]');
model.param.set('LayerBC', '50[mm]');
model.param.set('cuffL', '5[mm]');

model.param.set('nerveD', sprintf('%0.5f[m]',nerveD));
model.param.set('fasciculeD', sprintf('%0.8f[m]',fascicleD));
model.param.set('fasciculeLayer', sprintf('%0.8f[m]',fasciculeLayer));
model.param.set('sigmaSaline',sprintf('%0.10f[S/m]',sigmaSaline));
model.param.set('sigmaEpineurium',sprintf('%0.10f[S/m]',sigmaEpineurium));
model.param.set('sigmaPerineurium',sprintf('%0.10f[S/m]',sigmaPerineurium));
model.param.set('sigmaFasciculexy',sprintf('%0.10f[S/m]',sigmaFasciculexy));
model.param.set('sigmaFasciculez',sprintf('%0.10f[S/m]',sigmaFasciculez));
model.param.set('sigmaEXT',sprintf('%0.10f[m]',sigmaEXT));
model.param.set('ring1D', sprintf('%0.6f[m]',ring1D));
model.param.set('ring2D', sprintf('%0.6f[m]',ring2D));
model.param.set('ringD', sprintf('%0.6f[m]',ringD));
model.param.set('nerveL',sprintf('%0.6f[m]',nerveL));
model.param.set('ringTorusD', sprintf('%0.6f[m]',ringTorusD));
model.param.set('ringCuffD', 'nerveD*1.5');
model.param.set('courant', sprintf('%0.5f[A]',courant));
model.param.set('cuffL', sprintf('%0.6f[m]',cuffL));
model.param.set('LayerBC', '50[mm]');

model.modelNode.create('comp1');

model.geom.create('geom1', 3);

model.mesh.create('mesh1', 'geom1');

model.geom('geom1').selection.create('csel1', 'CumulativeSelection');
model.geom('geom1').selection('csel1').label('ring1Boundary');
model.geom('geom1').selection.create('csel2', 'CumulativeSelection');
model.geom('geom1').selection('csel2').label('ring2Boundary');
model.geom('geom1').selection.create('csel3', 'CumulativeSelection');
model.geom('geom1').selection('csel3').label('extBC');
model.geom('geom1').selection.create('csel4', 'CumulativeSelection');
model.geom('geom1').selection('csel4').label('fascicleB');
model.geom('geom1').selection.create('csel5', 'CumulativeSelection');
model.geom('geom1').selection('csel5').label('nerveB');
model.geom('geom1').create('cyl1', 'Cylinder');
model.geom('geom1').feature('cyl1').label('nerf');
model.geom('geom1').feature('cyl1').set('r', 'nerveD/2');
model.geom('geom1').feature('cyl1').set('contributeto', 'csel5');
model.geom('geom1').feature('cyl1').set('pos', {'0' '0' '-nerveL/2'});
model.geom('geom1').feature('cyl1').set('selresult', 'on');
model.geom('geom1').feature('cyl1').set('h', 'nerveL');
model.geom('geom1').create('cyl2', 'Cylinder');
model.geom('geom1').feature('cyl2').label('milieu');
model.geom('geom1').feature('cyl2').set('r', 'nerveD*2');
model.geom('geom1').feature('cyl2').set('layername', {'' '' '' '' ''});
model.geom('geom1').feature('cyl2').set('contributeto', 'csel3');
model.geom('geom1').feature('cyl2').set('layertop', true);
model.geom('geom1').feature('cyl2').set('selresultshow', 'bnd');
model.geom('geom1').feature('cyl2').set('pos', {'0' '0' '-nerveL'});
model.geom('geom1').feature('cyl2').set('selresult', 'on');
model.geom('geom1').feature('cyl2').set('h', 'nerveL*2');
model.geom('geom1').feature('cyl2').set('layerbottom', true);
model.geom('geom1').create('tor1', 'Torus');
model.geom('geom1').feature('tor1').label('ring1');
model.geom('geom1').feature('tor1').set('rmaj', 'ring1D/2');
model.geom('geom1').feature('tor1').set('contributeto', 'csel1');
model.geom('geom1').feature('tor1').set('rmin', 'ringTorusD/2');
model.geom('geom1').feature('tor1').set('pos', {'0' '0' 'ringD/2'});
model.geom('geom1').create('tor2', 'Torus');
model.geom('geom1').feature('tor2').label('ring2');
model.geom('geom1').feature('tor2').set('rmaj', 'ring2D/2');
model.geom('geom1').feature('tor2').set('contributeto', 'csel2');
model.geom('geom1').feature('tor2').set('rmin', 'ringTorusD/2');
model.geom('geom1').feature('tor2').set('pos', {'0' '0' '-ringD/2'});
model.geom('geom1').create('cyl3', 'Cylinder');
model.geom('geom1').feature('cyl3').label('cuff');
model.geom('geom1').feature('cyl3').set('r', 'ringCuffD/2');
model.geom('geom1').feature('cyl3').set('pos', {'0' '0' '-cuffL/2'});
model.geom('geom1').feature('cyl3').set('h', 'cuffL');
model.geom('geom1').create('cyl4', 'Cylinder');
model.geom('geom1').feature('cyl4').label('fascicule1');
model.geom('geom1').feature('cyl4').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl4').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl4').set('selresultshow', 'all');
model.geom('geom1').feature('cyl4').set('pos', {'0' '0' '-nerveL/2'});
model.geom('geom1').feature('cyl4').set('selresult', 'on');
model.geom('geom1').feature('cyl4').set('h', 'nerveL');
model.geom('geom1').create('cyl5', 'Cylinder');
model.geom('geom1').feature('cyl5').label('fascicule2');
model.geom('geom1').feature('cyl5').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl5').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl5').set('selresultshow', 'all');
model.geom('geom1').feature('cyl5').set('pos', {'nerveD/4' '0' '-nerveL/2'});
model.geom('geom1').feature('cyl5').set('selresult', 'on');
model.geom('geom1').feature('cyl5').set('h', 'nerveL');
model.geom('geom1').create('cyl6', 'Cylinder');
model.geom('geom1').feature('cyl6').label('fascicule3');
model.geom('geom1').feature('cyl6').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl6').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl6').set('selresultshow', 'all');
model.geom('geom1').feature('cyl6').set('pos', {'-nerveD/4' '0' '-nerveL/2'});
model.geom('geom1').feature('cyl6').set('selresult', 'on');
model.geom('geom1').feature('cyl6').set('h', 'nerveL');
model.geom('geom1').create('cyl7', 'Cylinder');
model.geom('geom1').feature('cyl7').label('fascicule4');
model.geom('geom1').feature('cyl7').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl7').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl7').set('selresultshow', 'all');
model.geom('geom1').feature('cyl7').set('pos', {'0' 'nerveD/4' '-nerveL/2'});
model.geom('geom1').feature('cyl7').set('selresult', 'on');
model.geom('geom1').feature('cyl7').set('h', 'nerveL');
model.geom('geom1').create('cyl8', 'Cylinder');
model.geom('geom1').feature('cyl8').label('fascicule5');
model.geom('geom1').feature('cyl8').set('r', 'fasciculeD/2');
model.geom('geom1').feature('cyl8').set('contributeto', 'csel4');
model.geom('geom1').feature('cyl8').set('selresultshow', 'all');
model.geom('geom1').feature('cyl8').set('pos', {'0' '-nerveD/4' '-nerveL/2'});
model.geom('geom1').feature('cyl8').set('selresult', 'on');
model.geom('geom1').feature('cyl8').set('h', 'nerveL');
model.geom('geom1').run('fin');
model.geom('geom1').create('intsel1', 'IntersectionSelection');
model.geom('geom1').feature('intsel1').set('entitydim', '2');
model.geom('geom1').feature('intsel1').label('NerveFascicleIntersection');
model.geom('geom1').feature('intsel1').set('input', {'csel5' 'csel4'});
model.geom('geom1').create('difsel1', 'DifferenceSelection');
model.geom('geom1').feature('difsel1').set('entitydim', '2');
model.geom('geom1').feature('difsel1').label('fasciclePeripheralB');
model.geom('geom1').feature('difsel1').set('add', {'csel4'});
model.geom('geom1').feature('difsel1').set('subtract', {'intsel1'});
model.geom('geom1').create('unisel1', 'UnionSelection');
model.geom('geom1').feature('unisel1').label('FascicleD');
model.geom('geom1').feature('unisel1').set('input', {'cyl8' 'cyl7' 'cyl6' 'cyl5' 'cyl4'});
model.geom('geom1').run;
model.geom('geom1').run('cyl8');

model.view.create('view3', 2);
model.view.create('view4', 2);

model.material.create('mat1', 'Common', 'comp1');
model.material.create('mat2', 'Common', 'comp1');
model.material.create('mat3', 'Common', 'comp1');
model.material.create('mat4', 'Common', 'comp1');
model.material.create('mat5', 'Common', 'comp1');
model.material('mat1').selection.set([5 6 7]);
model.material('mat2').selection.named('geom1_csel4_dom');
model.material('mat3').selection.set([1 2]);
model.material('mat4').selection.set([1]);
model.material('mat5').selection.named('geom1_difsel1');

model.physics.create('ec', 'ConductiveMedia', 'geom1');
model.physics('ec').selection.set([1 2 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22]);
model.physics('ec').create('ein2', 'ElectricInsulation', 2);
model.physics('ec').feature('ein2').selection.set([5 6 82 123]);
model.physics('ec').create('ci1', 'ContactImpedance', 2);
model.physics('ec').feature('ci1').selection.named('geom1_difsel1');
model.physics('ec').create('dimp1', 'DistributedImpedance', 2);
model.physics('ec').feature('dimp1').selection.named('geom1_csel3_bnd');
model.physics('ec').create('term1', 'Terminal', 2);
model.physics('ec').feature('term1').selection.named('geom1_csel2_bnd');
model.physics('ec').create('term2', 'Terminal', 2);
model.physics('ec').feature('term2').selection.named('geom1_csel1_bnd');
model.physics.create('cir', 'Circuit', 'geom1');
model.physics('cir').create('I1', 'CurrentSourceCircuit', -1);
model.physics('cir').create('IvsU1', 'ModelDeviceIV', -1);
model.physics('cir').create('I2', 'CurrentSourceCircuit', -1);
model.physics('cir').create('IvsU2', 'ModelDeviceIV', -1);

model.mesh('mesh1').autoMeshSize(2);

model.result.table.create('evl3', 'Table');

model.view('view3').axis.set('xmax', '1.0677165985107422');
model.view('view3').axis.set('xmin', '-1.0677165985107422');
model.view('view4').axis.set('xmax', '1.1818181276321411');
model.view('view4').axis.set('xmin', '-1.1818181276321411');

model.material('mat1').label('epineurium');
model.material('mat1').propertyGroup('def').set('electricconductivity', {'sigmaEpineurium' '0' '0' '0' 'sigmaEpineurium' '0' '0' '0' 'sigmaEpineurium'});
model.material('mat1').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat2').label('fascicle');
model.material('mat2').propertyGroup('def').set('electricconductivity', {'sigmaFasciculexy' '0' '0' '0' 'sigmaFasciculexy' '0' '0' '0' 'sigmaFasciculez'});
model.material('mat2').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat3').label('conjonctiveTissue');
model.material('mat3').propertyGroup('def').set('electricconductivity', {'sigmaEXT' '0' '0' '0' 'sigmaEXT' '0' '0' '0' 'sigmaEXT'});
model.material('mat3').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat4').propertyGroup('def').set('electricconductivity', {'sigmaSaline' '0' '0' '0' 'sigmaSaline' '0' '0' '0' 'sigmaSaline'});
model.material('mat4').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});
model.material('mat5').label('perineurium');
model.material('mat5').propertyGroup('def').set('electricconductivity', {'sigmaPerineurium' '0' '0' '0' 'sigmaPerineurium' '0' '0' '0' 'sigmaPerineurium'});
model.material('mat5').propertyGroup('def').set('relpermittivity', {'1' '0' '0' '0' '1' '0' '0' '0' '1'});

model.physics('ec').feature('ci1').set('ds', '0.05*fasciculeD');
model.physics('ec').feature('dimp1').set('ds', 'LayerBC');
model.physics('ec').feature('dimp1').set('sigmabnd_mat', 'userdef');
model.physics('ec').feature('dimp1').set('sigmabnd', 'sigmaSaline');
model.physics('ec').feature('dimp1').set('epsilonrbnd_mat', 'userdef');
model.physics('ec').feature('term1').set('TerminalType', 'Circuit');
model.physics('ec').feature('term2').set('TerminalName', '0');
model.physics('ec').feature('term2').set('TerminalType', 'Circuit');
model.physics('cir').prop('CircuitSettings').set('CreateNodes', '0');
model.physics('cir').feature('I1').set('Connections', {'1'; '0'});
model.physics('cir').feature('I1').set('value', 'courant');
model.physics('cir').feature('IvsU1').set('V_src', 'root.comp1.ec.V0_1');
model.physics('cir').feature('IvsU1').set('Connections', {'1'; '0'});
model.physics('cir').feature('I2').set('Connections', {'2'; '0'});
model.physics('cir').feature('I2').set('value', '-courant');
model.physics('cir').feature('IvsU2').set('V_src', 'root.comp1.ec.V0_0');
model.physics('cir').feature('IvsU2').set('Connections', {'2'; '0'});

model.mesh('mesh1').run;

model.result.table('evl3').label('Evaluation 3D');
model.result.table('evl3').comments('Interactive 3D values');

model.study.create('std1');
model.study('std1').create('stat', 'Stationary');

model.sol.create('sol1');
model.sol('sol1').study('std1');
model.sol('sol1').attach('std1');
model.sol('sol1').create('st1', 'StudyStep');
model.sol('sol1').create('v1', 'Variables');
model.sol('sol1').create('s1', 'Stationary');
model.sol('sol1').feature('s1').create('fc1', 'FullyCoupled');
model.sol('sol1').feature('s1').create('i1', 'Iterative');
model.sol('sol1').feature('s1').feature('i1').create('mg1', 'Multigrid');
model.sol('sol1').feature('s1').feature.remove('fcDef');

model.result.dataset.create('cpl1', 'CutPlane');
model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').create('mslc1', 'Multislice');
model.result('pg1').create('con1', 'Contour');
model.result('pg1').create('con2', 'Contour');
model.result('pg1').feature('mslc1').create('filt1', 'Filter');
model.result('pg1').feature('mslc1').create('def1', 'Deform');
model.result('pg1').feature('con1').create('filt1', 'Filter');
model.result('pg1').feature('con2').create('filt1', 'Filter');

model.sol('sol1').attach('std1');
model.sol('sol1').feature('s1').feature('i1').set('linsolver', 'cg');
model.sol('sol1').feature('s1').feature('i1').feature('mg1').set('prefun', 'amg');
model.sol('sol1').runAll;

model.result('pg1').label('Electric Potential (ec)');
model.result('pg1').set('frametype', 'spatial');
model.result('pg1').feature('mslc1').set('znumber', '0');
model.result('pg1').feature('mslc1').set('expr', 'Vz');
model.result('pg1').feature('mslc1').set('rangecoloractive', 'on');
model.result('pg1').feature('mslc1').set('rangecolormax', '35000');
model.result('pg1').feature('mslc1').set('descr', 'Gradient of V, z component');
model.result('pg1').feature('mslc1').set('rangecolormin', '15000');
model.result('pg1').feature('mslc1').set('unit', 'V/m');
model.result('pg1').feature('mslc1').set('colorlegend', false);
model.result('pg1').feature('mslc1').set('ynumber', '0');
model.result('pg1').feature('con1').set('data', 'cpl1');
model.result('pg1').feature('con1').set('unit', 'V/m');
model.result('pg1').feature('con1').set('inheritdeformscale', false);
model.result('pg1').feature('con1').set('expr', 'Vz');
model.result('pg1').feature('con1').set('includeoutside', false);
model.result('pg1').feature('con1').set('inheritcolor', false);
model.result('pg1').feature('con1').set('inherittubescale', false);
model.result('pg1').feature('con1').set('descr', 'Gradient of V, z component');
model.result('pg1').feature('con1').set('levels', 'range(15000,20000/39,35000)');
model.result('pg1').feature('con1').set('contourtype', 'filled');
model.result('pg1').feature('con1').set('levelmethod', 'levels');
model.result('pg1').feature('con1').feature('filt1').active(false);
model.result('pg1').feature('con1').feature('filt1').set('expr', 'x==0');
model.result('pg1').feature('con2').set('data', 'cpl1');
model.result('pg1').feature('con2').set('unit', 'V/m');
model.result('pg1').feature('con2').set('coloring', 'uniform');
model.result('pg1').feature('con2').set('labelprec', '5');
model.result('pg1').feature('con2').set('inheritdeformscale', false);
model.result('pg1').feature('con2').set('expr', 'Vz');
model.result('pg1').feature('con2').set('inheritcolor', false);
model.result('pg1').feature('con2').set('inherittubescale', false);
model.result('pg1').feature('con2').set('descr', 'Gradient of V, z component');
model.result('pg1').feature('con2').set('labelcolor', 'gray');
model.result('pg1').feature('con2').set('contourlabels', true);
model.result('pg1').feature('con2').set('levels', 'range(15000,20000/39,35000)');
model.result('pg1').feature('con2').set('colorlegend', false);
model.result('pg1').feature('con2').set('levelmethod', 'levels');
model.result('pg1').feature('con2').feature('filt1').active(false);
model.result('pg1').feature('con2').feature('filt1').set('expr', 'x==0');

out = model;
