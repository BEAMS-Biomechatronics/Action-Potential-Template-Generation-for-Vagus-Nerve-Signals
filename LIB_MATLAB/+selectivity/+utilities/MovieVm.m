function MovieVm(fibre)
% (c) Jason Pettiaux
% Utilisation :
% Il faut charger un fichier shift contenant les variables Vm et time
%ensuite simplement copier le nom de la fonctin et changer fiberNbr par le
%numero de la fibre dont on veut observer le potentiel.

    % Make a movie of the potential
    %movie(Ftot)
    Ftot=[];
    Vm    = fibre.solution(:,1:end/5);
    time  = fibre.time;
    
    VmMin=min(min(Vm));
    VmMax=max(max(Vm));
    nNodes=size(Vm,2);
    Time= round(time*1e3,2); 
    filename=sprintf('movieVmFiberNbr_%d.avi',1);
    v = VideoWriter(filename);
    open(v);
    
    for i=1:size(Vm,1)
        fig=plot(1:nNodes,Vm(i,:));
        hold off
        InstantTime=Time(i);
        title({sprintf('AP propagation fibre n°%d',1) ; sprintf(' instant %0.5f ms',InstantTime)});
        xlabel('Position (n°of Nodes)') % x-axis label
        ylabel('Membrane Potential (V)') % y-axis label
        axis([0 nNodes VmMin VmMax])
        ax = gca;
        ax.Units = 'pixels';
        pos = ax.Position;
        marg = 30;
        rect = [-marg, -marg, pos(3)+2*marg, pos(4)+2*marg];
        F = getframe(gcf);%rect
        writeVideo(v,F)
        %Ftot=[Ftot F];
    end
    
    close(v);
    
    %class(filename)
    %save(filename,'Ftot')
end