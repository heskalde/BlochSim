# BlochSim
Simulating MRI sequences using bloch equations. Focus on the MOLLI sequence with different off-resonance frequencies to correct for inhomogeneity artifacts.

## Script overview
### B0vT1
Runs MOLLI_sim_freq and plots the results with curvefitting of off-resonance T1 estimations.
### BlochBlockSim
Alternative simulation method using "block" sections instead of going step-wise.
### HeartFixTest
Showcase of how the bloch simulation can be used on a heart with off-resonance due to a pacemaker.
### MOLLI_params
Creating a struct containing MR parameters for a MOLLI sequence.
### MOLLI_sim
Base simulation of the MOLLI sequence.
### MOLLI_sim_test
Simulation of the MOLLI sequence including off-resonance effects.
### T1correct
Prospective pipeline for loading T1 maps with corresponding off-resonance maps (B1 maps), simulating the effect and adjusting the T1 values accordingly.
