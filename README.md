# Action-Potential-Template-Generation-for-Vagus-Nerve-Signals
This repository provides the MATLAB and COMSOL Multiphysics models used to generate action potential (AP) templates for fiber-specific detection in vagus nerve electroneurogram (VENG) recordings. These templates are a core component of the pipeline used to characterize active vagal fibers during epileptic seizures in rats.

⚠️ Research Use Only
This code is provided strictly for academic and non-clinical research purposes.

📌 Overview
The objective of this toolbox is to:
•	Simulate biophysically realistic action potential propagation in myelinated fibers
•	Inject these APs into a 3D finite-element model (FEM) of the vagus nerve
•	Extract fiber-diameter–specific extracellular templates
•	Provide these templates for template-matching–based AP detection in recorded VENG signals
This approach enables fiber-group–specific electrophysiological analysis of vagus nerve activity.

🧠 Scientific Background
Action potential propagation is simulated in MATLAB using a mammalian adaptation of the classical Hodgkin–Huxley and cable-theory framework:
Wesselink & Schwarz (1999), A model of the electrical behaviour of myelinated sensory nerve fibres based on human data, Medical & Biological Engineering & Computing.
This 1D fiber model is coupled to a 3D COMSOL Multiphysics FEM vagus nerve model, incorporating:
•	Endoneurium, perineurium, epineurium, and surrounding medium
•	A centrally positioned myelinated axon
•	Dynamic current injection at each node of Ranvier
The resulting surface potentials are used to derive bipolar extracellular AP templates.
________________________________________
💻 Software Requirements
To run the complete pipeline, you need:
•	MATLAB R2024 or later
•	COMSOL Multiphysics v6.2 or later
•	LiveLink™ for MATLAB (mandatory for MATLAB–COMSOL coupling)
✅ MATLAB and COMSOL must be correctly linked before running main.m.
________________________________________
⚙️ Processing Pipeline
The workflow is divided into four main steps:
1️⃣ Action Potential Generation (MATLAB)
•	Simulation of AP propagation in myelinated fibers
•	Fiber diameters: 2–11 μm (1 μm steps)
•	Based on mammalian Wesselink–Schwarz equations
2️⃣ Current Density Computation (MATLAB)
•	Transmembrane currents extracted at each node of Ranvier
•	Converted to volumetric current densities (A/m³)
3️⃣ 3D FEM Simulation (COMSOL)
•	Dynamic current injection into the 3D vagus nerve model
•	Computation of spatiotemporal extracellular voltage patterns
•	Bipolar electrode configuration extracted virtually
4️⃣ Template Extraction (MATLAB)
•	Bandpass filtering: 300–3000 Hz
•	Peak alignment and time-window normalization
•	Final template length: 139 samples
•	Fiber groups used for detection: 2µm to 11 µm
________________________________________
▶️ How to Run
1.	Open MATLAB
2.	Set the working directory to the repository root
3.	Ensure main.m is in the active path
4.	Start COMSOL with LiveLink enabled
5.	Run:
main
⚠️ The MATLAB workspace must be in the same folder as main.m.
________________________________________
🔍 Action Potential Detection (Companion Repository)
This repository only generates templates. For AP detection in recorded VENG signals, use:
🔗 Action Potential Detection Algorithm
https://github.com/BEAMS-Biomechatronics/AP-Detection-Algorithm
That toolbox performs:
•	Template matching via normalized cross-correlation
•	Conflict resolution between overlapping templates
•	Fiber-group assignment
You may need to adapt it to your own acquisition system.
________________________________________
📝 Citation
If you use this code in any scientific publication, you must cite:
Chávez Cerda J., Acedo Reina E., Luppens C., Vande Perre L., Raffoul R., Verstraeten M., Germany Morrison E., Smets H., Doguet P., Garnier J., Delbeke J., El Tahry R., and Nonclercq A.
Characterization of Vagus Nerve Active Fibers during Seizure in Rats, Journal of Neural Engineering, 2026. DOI 10.1088/1741-2552/ae30aa
________________________________________
📜 License
This project is distributed under the GNU General Public License v2.0 (GPL-2.0).
You are free to:
•	Use
•	Modify
•	Redistribute
provided that all derivative works remain open-source under the same license.
Full license text: https://www.gnu.org/licenses/gpl-2.0.html
________________________________________
⚠️ Disclaimer
This software is intended for research and educational use only. It is not certified for clinical use and must not be used for diagnostic or therapeutic purposes in humans.

