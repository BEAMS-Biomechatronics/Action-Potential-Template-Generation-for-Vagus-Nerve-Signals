function [] = mySaveData(fibreD, shift, Vm, time, CoordonneesFibresXYZ, fibreSave) % on a enleve type de l'AP
filename = ['shift_' num2str(shift) '.mat'];
preFolderSaveData = ['fibreD' num2str(fibreD)];
my_clk = clock;
clockStr = [num2str(my_clk(1)) '_' num2str(my_clk(2)) '_' num2str(my_clk(3)) '_h_' num2str(my_clk(4)) '_' num2str(my_clk(5))];
mkdir(preFolderSaveData);
mkdir(preFolderSaveData, clockStr); % folderSaveData
folderSaveData = [preFolderSaveData '/' clockStr];
mkdir(folderSaveData, ['shift_' num2str(shift)]); % folderSaveFig
% folderSaveFig = [folderSaveData '/shift_' num2str(shift)];
save([folderSaveData '/' filename], 'Vm', 'time', 'CoordonneesFibresXYZ', 'fibreSave');
copyfile('parameters.mat', folderSaveData);
% copyfile('figure', folderSaveFig, 'f');
mkdir('figure');
rmdir('figure', 's');
mkdir('figure');
end