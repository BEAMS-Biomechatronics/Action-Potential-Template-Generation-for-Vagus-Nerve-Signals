function saveData(folderLevel1)
% saveData transfert all the files of the current directory in a new directory 
% with subDirectoryName.
    % some parameters define the folderNames, so first load them. 
    load parameters
    
    %folderLevel 1 is about the geometry
%    folderLevel1 = geometryName;
%     for m = 1:length(listMainProperties)
%         folderLevel1 = [folderLevel1 '_' listMainProperties{m} '_' num2str(eval(listMainProperties{m})) '_'];
%     end
%     
%     folderLevel1 = strrep(folderLevel1, '.', '_');
%     folderLevel1 = strrep(folderLevel1, '-', '_');
    
    
    %folderLevel2 are splitted depending on the fiber diameter
    folderLevel2 = ['fibreD' num2str(fibreD)];
    %folderLevel2 = strrep(folderLevel2, '.', '_');
    
    %folderLevel3 has just one subfolder for figures.
    folderLevel3 = 'figure';
    
    %folderLevel4 has a subfolder for each shift.
    folderLevel4 = ['shift_' num2str(shift)];
    folderLevel4 = strrep(folderLevel4, '.', '_');
    
    % create Sthe directories
    mkdir(folderLevel1);
    mkdir(['./' folderLevel1], folderLevel2);
    mkdir(['./' folderLevel1 '/' folderLevel2], folderLevel3);
    mkdir(['./' folderLevel1 '/' folderLevel2 '/' folderLevel3], folderLevel4);
    
    
	%retrieving file names
	currentFolderContent = dir;
	figureFolderContent  = dir('./figure/');
	    
  
    
    % direct Access folder path
    folderLevel1DA = [folderLevel1 '/'];
    folderLevel2DA = [folderLevel1 '/' folderLevel2 '/'];
    folderLevel3DA = [folderLevel1 '/' folderLevel2 '/' folderLevel3 '/'];
    folderLevel4DA = [folderLevel1 '/' folderLevel2 '/' folderLevel3 '/' folderLevel4];
    
	%currentFolder   = [pwd '/'];
    %currentFolder   = strrep(currentFolder, '/', '/');
    %copy parameters.mat
    copyfile('parameters.mat', folderLevel1DA)
    
    
    %copy the file of the current folder with extension .mat only
    
    
    %copy shift_xxx.mat files
	for l=1:length(currentFolderContent)
		if ~isempty(strfind(currentFolderContent(l).name,'.mat')) && ~isempty(strfind(currentFolderContent(l).name,'shift'))
			copyfile(['./' currentFolderContent(l).name], folderLevel2DA)
			delete(['./' currentFolderContent(l).name]);
		end
	end
	
	
	% Copy files of the figure folder
    copyfile('figure', folderLevel4DA, 'f');
% 	for l=1:length(figureFolderContent)
%         
% 		if ~isempty(strfind(figureFolderContent(l).name,'.fig'))
%             source          = ['./figure/' figureFolderContent(l).name]
%             destination     = [folderLevel4DA]
%             %system(['copy ' [currentFolder '/figure/' figureFolderContent(l).name] ' ' [folderLevel4DA]]);
% 			movefile(source, destination, 'f');
% 			%delete([currentFolder '/figure/' figureFolderContent(l).name]);
% 		end
% 	end
end

