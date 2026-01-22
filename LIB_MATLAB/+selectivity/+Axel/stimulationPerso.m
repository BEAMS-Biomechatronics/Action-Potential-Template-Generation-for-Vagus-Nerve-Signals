function stim=stimulationPerso()
a=0;
stim=[0;0];
figure;
while a==0
coordx=input('Donnez les coordonnées "x" d un nouveau point (écrivez "n" pour arrêter la boucle) : \n','s')
if (coordx=='n')
    a=1; 
else
    coordy=input('Donnez les coordonnées "y" du point précédent : \n')
end
coordx=str2double(coordx);
stim=[stim,[coordx;coordy]];
stim(1,:)=sort(stim(1,:));
hold on;
plot(stim(1,:),stim(2,:))
end
stim(:,end)=[];
stim(1,:)=sort(stim(1,:));
figure;plot(stim(1,:),stim(2,:))
end