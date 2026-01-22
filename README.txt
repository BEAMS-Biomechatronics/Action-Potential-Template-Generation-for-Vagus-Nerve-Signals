Action potential templates generation for Action Potential Detection Algorithm

This code is for research purposes only.

This folder contains MATLAB codes and COMSOL models to generate a compound action potential propagation in a FEM vagus nerve model (limited for rats). For running this codes, it is necessary to run COMSOL with MATLAB v6.2 or latest. The Matlab codes compute the action potential propagation in a fiber, which model is based on the work of Wesselink et al ("A model of the electrical behaviour of myelinated sensory nerve fibres based on human data." Medical & biological engineering & computing 1999). The MATLAB code is divided in 4 steps: (1) Generate the action potential in one fiber, (2) Calculate current densities at each node of Ranvier, (3) Runing the COMSOL models, (4) Get the templates and save them. The Matlab workspace has to be in the same folder as the main.m. For AP detections in in signals, take a look on Action Potential Detection Algorithm (https://github.com/BEAMS-Biomechatronics/AP-Detection-Algorithm) and change the code accordingly for AP detections.

Licence

If you use this algorithm for a publication (in a journal, in a conference, etc.), please cite the related publications: [ChavezCerda2025] license attached to this toolbox is GPL v2, see https://www.gnu.org/licenses/gpl-2.0.txt. From https://www.gnu.org/licenses/gpl-2.0.html, it implies: This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

References

Chavez Cerda J, Acedo Reina E, Luppens C, Vande Perre L, Raffoul R, Verstraeten M, Germany Morrison G, Smets H, Doguet P, Garnier J, Delbeke J, El Tahry R, Nonclercq A. "Characterization of Vagus Nerve Active Fibers during Seizure in Rats" Journal of Neural Engineering 2025 (Provisionally Accepted)