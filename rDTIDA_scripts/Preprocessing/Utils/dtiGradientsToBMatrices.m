function [bMatrices] = dtiGradientsToBMatrices(gradients,gyroMagneticRatio,epsilon,delta,bigDelta)
%--------------------------------------------------------------------------
% [bMatrices] = dtiGradientsToBMatrices(gradients,gyroMagneticRatio,
%                                       epsilon,delta,bigDelta);
%--------------------------------------------------------------------------
% Computes b-Matrices for trapezoidal gradients for the pulse sequence
% shown in basser1994 (see references section).  This is a spin-echo
% sequence with trapezoidal diffusion-encoding gradients.
%
% INPUTS:
% --gradients         = A 3xB matrix, where B is the total number of
%                       different diffusion gradients.  The vector
%                       gradients(:,b) should equal [Gx;Gy;Gz] for the bth
%                       set of diffusion gradients.
% --gyroMagneticRatio = The gyromagnetic ratio.
% --epsilon           = The rise time (see basser1994) for the diffusion
%                       encoding gradients.
% --delta             = The flat-top time plus rise time (see basser1994)
%                       for the diffusion encoding gradients.
% --bigDelta          = The time between the initial rise of the first and
%                       second diffusion encoding gradients (see
%                       basser1994).
%
% OUTPUTS:
% --bMatrices         = A 3x3xB array, where the (:,:,b) subarray is the
%                       3x3 symmetric b-matrix for the bth set of
%                       diffusion-encoding gradients.
%
% DISCUSSION:  Be careful of the units here.  If 'gradients' is in (T/m),
% 'gyroMagneticRatio' is in (rad/s/T), 'epsilon' is in (s), 'delta' is in
% (s), and 'Delta' is in (s), then the b-values will be in (s/(m^2)) and
% the calculated diffusion coefficients will be in (m^2/s).  If you're
% using other units, you'll need to work out the right conversions.
%
% REFERENCES:
% [*] P. J. Basser, J. Mattiello, D. LeBihan.  Estimation of the Effective
%     Self-Diffusion Tensor from the NMR Spin Echo.  Journal of Magnetic
%     Resonance, Series B 103, 247-254 (1994).
%
%--------------------------------------------------------------------------
% Justin Haldar 06/11/2006 haldar@uiuc.edu
%--------------------------------------------------------------------------

B = size(gradients,2);
bMatrices = zeros(3,3,B);

gradientConstant = gyroMagneticRatio^2*( delta^2*(bigDelta - delta/3) + epsilon^3/30 - delta*epsilon^2/6);
Gx = reshape(gradients(1,:),[],1);
Gy = reshape(gradients(2,:),[],1);
Gz = reshape(gradients(3,:),[],1);

bMatrices(1,1,:) = Gx.^2;
bMatrices(1,2,:) = Gx.*Gy;
bMatrices(1,3,:) = Gx.*Gz;
bMatrices(2,1,:) = bMatrices(1,2,:);
bMatrices(2,2,:) = Gy.^2;
bMatrices(2,3,:) = Gy.*Gz;
bMatrices(3,1,:) = bMatrices(1,3,:);
bMatrices(3,2,:) = bMatrices(2,3,:);
bMatrices(3,3,:) = Gz.^2;

bMatrices = gradientConstant*bMatrices;
return;