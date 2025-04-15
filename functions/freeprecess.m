function [Afp,Bfp]=freeprecess(t,T1,T2,df)
%	Function simulates free precession and decay
%	over a time interval T, given relaxation times T1 and T2
%	and off-resonance df.  Times in s, off-resonance in Hz.
    phi = 2*pi*df*t/1000;	% Resonant precession, radians.
    E1 = exp(-t/T1);
    E2 = exp(-t/T2);
    
    Afp = zrot(phi)*[E2 0 0;0 E2 0;0 0 E1];
    Bfp = [0 0 1-E1]';
end