for k = 2:3
    fibreDSeuil     = 2.5e-6+k*2.5e-6;
    save('parametersChange.mat', 'fibreDSeuil');
    selectivity.anodalBlock.detectActivationWithShift('1D', 1); %second argument is used to bypass prompter
end
