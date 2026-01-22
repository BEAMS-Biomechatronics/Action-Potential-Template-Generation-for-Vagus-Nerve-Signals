function fig = plot2DCOMSOL(model)
%This function plot A 2D view of the voltage
%   The model object is a comsol object and should have been already
%   solved when transmitted to this function. 

    fig = figure()
    dat = mphplot(model, <pgtag>);

end

