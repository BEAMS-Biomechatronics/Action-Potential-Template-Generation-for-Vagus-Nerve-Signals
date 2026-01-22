function fig2png(folder, preFix)

if ~exist('preFix','var')
     % third parameter does not exist, so default it to something
      preFix = '';
 end

dir_data = dir([pwd '\' folder]);

% cell to store the file name
fig_file = {};
fig_index = {};

% check in the current folder which files are .fig
current_index = 1;
for k=1:length(dir_data)
    current_file = dir_data(k).name;
    if ~isempty(strfind(current_file, '.fig'))
        fig_file{current_index} = current_file;
        fig_index{current_index} = k;
        current_index = current_index +1;
    end
end

% convert the files to png
for k=1:length(fig_file)
    fig_name = fig_file{k};
    
    
    % delete . and - from the name
    fig_name = fig_name(1:end-4);
    fig_name(fig_name == '.') = '_';
    fig_name(fig_name == '-') = '_';
    
    fig_name_png = [fig_name '.png'];
    
    
    
    
    fig_name_png_complete = [pwd '\' folder '\' preFix fig_name_png];
    handle_fig = open([pwd '\' folder '\' fig_file{k}]);
    saveas(handle_fig, fig_name_png_complete);
    
    close(handle_fig);
end
end