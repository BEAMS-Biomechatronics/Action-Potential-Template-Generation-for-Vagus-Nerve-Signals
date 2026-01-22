files = dir;
voltageFig = figure();
VzzFig     = figure();
legendString = [];
%colors = ['k',
for i=1:length(files)
    file = files(i).name;
    if ~isempty(strfind(file,'sauvegarde'))
        load(file)
        figure(voltageFig);
        plot(pulseTEnd, VSauvegarde);
        hold all;
        Vzz = -2*VSauvegarde;
        figure(VzzFig);
        plot(pulseTEnd, Vzz);
        hold all;
        legendString = [legendString sprintf('%2.1f µm;',fiberD*1e6)];
    end
end

legendString = strsplit(legendString, ';');
figure(voltageFig)
legend(legendString);
xlabel('Pulse Time [s]');
ylabel('Voltage of the non-zero node');
figure(VzzFig)
legend(legendString);
xlabel('Pulse Time [s]');
ylabel('VzzNJ');




