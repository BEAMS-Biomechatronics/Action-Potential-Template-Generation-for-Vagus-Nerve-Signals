%% Getting the Action Potential of the different fibers (Takes 1 hour approx)
clear all;
close all;
clc
fiberdiameters = [2 3 4 5 6 7 8 9 10 11]*1e-6;%diameter tested by Hugo et al
elapsed_time = [];
temperature = 31.9; %temeprature measured in the vagus nerve, in an open wound
for i = fiberdiameters
    tic
    build_ActionPotential_1fiber(i,temperature,0); %generate and save the action potential propagation, arguments : fiber Diameter, Temperature, plot_results (0: do not plot, 1 : plot)
    t = toc;
    display(['Elapsed time: ' num2str(t) ' sec'])
    elapsed_time = [elapsed_time t];
end
elapsed_time
%% Getting the current density of each node of each fiber (Takes 10 sec approx)
clear all;
close all;
clc
fiberdiameters = [2 3 4 5 6 7 8 9 10 11]*1e-6;
elapsed_time = [];
temperature = 31.9;%[25 37];
for i = fiberdiameters
    get_CurrentDensity_1fiber(i,temperature); %get current density from the AP files
    t = toc;
    elapsed_time = [elapsed_time t];
end
elapsed_time
%% Runing COMSOL models from Matlab (Maximum time 10 hours, minimum time: 1 hours approx.) If there is an error when a model is computing, try to use COMSOL directly.
clear all
clc
addpath('LIB_MATLAB');
addpath('COMSOL_VE');
addpath('COMSOL_VE\MATLAB1');
import selectivity.stimWaveForm.*;
import selectivity.comsol.*;
import selectivity.fibreModel.fibre.*;
import com.comsol.model.util.*;
import selectivity.utilities.*;
import selectivity.anodalBlock.*;
import selectivity.Axel.*;
import selectivity.CAPfunctions.*;

fiberDiameters = [2 3 4 5 6 7 8 9 10 11 13 15 17];
Temperatures = [25 37 31.9];
durationSim = [4 4 3.5 3.5 3.5 3.5 3.5 3 3 3 3 3 3;3 3 2.5 2.5 2.5 2.5 2.5 2 2 2 2 2 2;4 4 3.5 3.5 3.5 3.5 3.5 3 3 3 3 3 3]; %simulation duration
elapsed_time = [];
error = [];
curdir = pwd;

for fd = 1:10%length(fiberDiameters)% According to Hugo's paper, fibers sizes 2um - 11 um contains almost 90% of the CAP on the VENG (the first 10 fibers sizes)
    for T = 3% Since the electrodes used were cuff electrodes, we asume that the temperature of the vagus nerve is 31.9°C (for hook electrode, since the nerve is exposed, use 25°C, for a closed wound, used 37°C)
        display('Loading model...');
        if round(Temperatures(T)) == Temperatures(T) % if temperature is integer
            model_name = [curdir '\COMSOL models\Nerve_Model_Complex3-with layers and large medium ' num2str(fiberDiameters(fd)) 'um' '_' num2str(Temperatures(T)) 'C.mph'] %model name
        else % if temperature is floating number
            strTemp = num2str(Temperatures(T));
            strTemp = strsplit(strTemp,'.');
            model_name = [curdir '\COMSOL models\Nerve_Model_Complex3-with layers and large medium ' num2str(fiberDiameters(fd)) 'um' '_' strTemp{1} 'C' strTemp{2} '.mph'] %model name
        end
        model   = mphload(model_name); %load model
        ModelUtil.showProgress(true); %load a progress bar, if is not desired, comment this line

        display('Set duration of the simulation...');
        sim_duration = [num2str(round(durationSim(T,fd),1)) 'E-3[s]']; % define the simulation time

        model.param.set('durationSim',sim_duration); %set the simulation time in the model
        tic;
        display('Solving...');
        model.sol('sol1').run; % compute the model
        toc;
        elapsed_time = [elapsed_time toc]; %save the elpsed time
        s = seconds(toc);
        s.Format = 'hh:mm:ss';
        display(s) %display the elapsed time
        display('Start exportation...');
        tic
        if round(Temperatures(T)) == Temperatures(T)
            file_name = [curdir '\fiberXZ_' num2str(fiberDiameters(fd)) 'um' '_' num2str(Temperatures(T)) 'C.csv']; %set the destination csv file
        else
            strTemp = num2str(Temperatures(T));
            strTemp = strsplit(strTemp,'.');
            file_name = [curdir '\fiberXZ_' num2str(fiberDiameters(fd)) 'um' '_' strTemp{1} 'C' strTemp{2} '.csv']; %set the destination csv file
        end
        model.result.export('data2').set('filename',file_name);% set the finel name and path in the model. The plane XZ (which is called 'data2') is the one we need
        model.result.export('data2').set('innerinput','all') % use the minimum resolution in time (1E-5);
        model.result.export('data2').run %run the exportation
        s = seconds(toc);
        s.Format = 'hh:mm:ss';
        display(s) %display the elapsed time
        display('Finish exportation exportation...');
        display('Clearing memory on Matlab...')
        clearvars -except fd T durationSim Temperatures fiberDiameters elapsed_time
        display('Clearing memory on COMSOL server...')
        tic
        ModelUtil.clear(); %clear all the models to save space
        s = seconds(toc);
        s.Format = 'hh:mm:ss';
        display(s) %display the elapsed time
    end
end
elapsed_time
%% Get compound action potential from COMSOL cvs outputs
fiber_size = [2:11]*1e-6;
z_position_v = fiber_size*5000; % get the voltages from an specific z position
temperature = '31.9';
gap_mm = [1 2 3 4]*1e-3; % gap distance between the electrodes (bipolar)
radial_position = 3.105e-4; % get voltages from the surface
curdir = pwd;
for i = 1:length(fiber_size)
    %read the cvs file generated before
    try
        f = readtable([curdir '\fiberXZ_' num2str(fiber_size(i)*1e6) 'um_' temperature 'C' '.csv'], 'HeaderLines', 9);
    catch
        partsT = strsplit(temperature,'.');
        f = readtable([curdir '\fiberXZ_' num2str(fiber_size(i)*1e6) 'um_' partsT{1} 'C' partsT{2} '.csv'], 'HeaderLines', 9);
    end
    data_array = table2array(f);
    planeXZ.x = data_array(:,1);
    planeXZ.y = data_array(:,2);
    planeXZ.z = data_array(:,3);
    planeXZ.V = data_array(:,4:end);
    z_position = z_position_v(i);
    bipolar_CAP = {};
    % get the action potentials at different gap values
    for gap = gap_mm
        my_points_z = [z_position z_position+gap]; %set distance between 2 electrodes
        my_points_x = ones(1, length(my_points_z))*radial_position; %set position where the electrodes would be (in the surface of the vagus nerve)
        iCathode = find_index(my_points_x(1), my_points_z(1), planeXZ.x, planeXZ.z); %cathode voltage
        iAnode   = find_index(my_points_x(2), my_points_z(2), planeXZ.x, planeXZ.z); %anode voltage
        bipolar_AP = planeXZ.V(iCathode,:) - planeXZ.V(iAnode,:); %bipolar signal
        bipolar_CAP{end+1} = bipolar_AP;
    end
    Temp_n = str2num(temperature);
    if round(Temp_n) == Temp_n
        file_name = [curdir '\velocities_descriptors_positions_' num2str(round(fiber_size(i)*1e6)) 'um' '_' temperature 'degC.mat'];
    else
        partsT = strsplit(temperature,'.');
        file_name = [curdir '\velocities_descriptors_positions_' num2str(round(fiber_size(i)*1e6)) 'um' '_' partsT{1} 'degC' partsT{2} '.mat'];
    end
    %save the compound action potential
    save(file_name,'bipolar_CAP');
end
%% Get templates
clear all
clc
diameters = [2,3,4,5,6,7,8,9,10,11]; %fiber diameter in µm
temperature = 31.9;
gap_mm = 4; %gap index --> 4 is for 4mm
fs = 80000; %sampling frequency VENG, modify if necessary
fs_COMSOL = 100000; %sampling frequency templates
order_filt = 2; %order of the digital filter
band = [300 3000]; %filter band
same_length = true; % if false, the templates will be saved having a length of 1/2 * width + width + 1/2 * width 
length_template = 139;
curdir = pwd;
filename = [curdir '\templates.mat']; % file name for saving the templates
templates_vector = {};
width_vector = [];

if length(band)<2
    [b,a] = butter(order_filt,band/(fs/2),'high');
else
    [b,a] = butter(order_filt,band/(fs/2),'bandpass');
end

for i = 1 : length(diameters)
    values = [];
    str_temperature = num2str(temperature);
    part_str_temperature = strsplit(str_temperature,'.');
    if length(part_str_temperature)==1
        filename = [curdir '\velocities_descriptors_positions_' num2str(diameters(i)) 'um_' part_str_temperature{1} 'degC.mat'];
    else
        filename = [curdir '\velocities_descriptors_positions_' num2str(diameters(i)) 'um_' part_str_temperature{1} 'degC' part_str_temperature{2} '.mat'];
    end
    files = load(filename); %load compound action potential
    COMSOL_signal = files.bipolar_CAP{gap_mm}; %get the compound action potential with an specific gap
    COMSOL_signal = resample(COMSOL_signal(:),fs,fs_COMSOL); %resampling considering the fs of the VENG
    COMSOL_signal_len = length(COMSOL_signal); % get length
    COMSOL_signal_filtered = filtfilt(b, a, COMSOL_signal(:));% filter the resampled COMSOL signal
    [~,ind2] = findpeaks(COMSOL_signal_filtered,'SortStr','descend','NPeaks',2);% find the 2 main peaks of the CAP
    width_sec = abs(ind2(1)-ind2(2))/fs; %obtained the width of the CAP in seconds
    width_samples = abs(ind2(1)-ind2(2)); %obtained the width of the CAP in samples
    width_vector = [width_vector width_sec]; % save the width

    if same_length % if we want the same length for all the temapltes
        extra_tail = (length_template - width_samples)/2;
    else
        extra_tail = round(abs(ind2(1)-ind2(2))/2);
    end

    beg_spike = ind2(2) - ceil(extra_tail);
    if beg_spike<1
        beg_spike = 1;
    end

    end_spike = ind2(1) + floor(extra_tail); 
    if end_spike>COMSOL_signal_len
        end_spike = COMSOL_signal_len;
    end

    template = COMSOL_signal_filtered(beg_spike:end_spike-1);
    templates_vector{end+1} = template;

    if length(template)==0
        display('error');
        display([temperature gap_mm band]);
    end
end

save(filename,'templates_vector','width_vector');