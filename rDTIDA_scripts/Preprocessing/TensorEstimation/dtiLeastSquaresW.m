function [lambdas, eigenVectors,residualImage] = dtiLeastSquaresW(b0Image, bImages, bMatrices)
%--------------------------------------------------------------------------
% [lambdas, eigenVectors, validityImage,residualImage] = dtiLeastSquaresW(b0Image,
%                                                      bImages, bMatrices);
%--------------------------------------------------------------------------
% Computes diffusion tensors for each voxel from diffusion weighted images
% using a least-squares regression.  Modified from dtiLeastSquares2.m to
% have weighting based on SNR.
%
% INPUTS:
% --b0Image                    = The MxNxP image taken with no diffusion
%                                weighting, where M is the number of voxels
%                                in the first dimension, N is the number of
%                                voxels in the second dimension, and P is
%                                the number of voxels in the third
%                                dimension.  For the least-squares fit,
%                                this can be a complex image or a
%                                magnitude image.
% --bImages                    = An BxMxNxP array, where B is the total
%                                number of different b-matrices (excluding
%                                b = 0).  The (b,:,:,:) subarray is the bth
%                                diffusion-encoded image.  Remember,
%                                exclude b = 0.
% --bMatrices                    = A 3x3xB array, where the (:,:,b) subarray
%                                is the 3x3 symmetric b-matrix for the
%                                bth image.  To compute these for
%                                trapezoidal gradients in a spin-echo
%                                sequence, see function
%                                dtiGradientsToBMatrices().
%
% OUTPUTS:
% --lambdas                    = A 3xMxNxP matrix of the eigenvalues.
%                                Largest eigenvalue is listed first.
% --eigenVectors               = A 3x3xMxNxP matrix of the eigenvectors
%                                corresponding to the eigenvalues.
% --validityImage              = An MxNxP binary indicator array that is
%                                1 where the diffusion tensor fit was
%                                valid and 0 elsewhere.  See the
%                                discussion below.
% --residualImage              = An MxNxP matrix showing the residuals of
%                                the least-squares fit
%
% DISCUSSION:  This reconstruction is very basic, and has a number of
% notable shortcomings:
% 1) Least-squares is not optimal from the standpoint of the noise
% distribution.  A maximum-likelihood estimator would be more appropriate,
% though more computationally intensive.  A maximum a priori estimator
% (like the one by Larry Bretthorst) can generate even better results than
% maximum-likelihood.  However, maximum a priori estimation requires the
% user to include prior information in the reconstruction, and the
% reconstruction accuracy in this case will be critically dependent on the
% accuracy of the prior information.
% 2) Diffusion tensors matrices are required to be positive definite, but
% this fit won't necessarily be positive definite given the effects of
% noise and model mismatch.  Thus, not all voxels will have valid
% associated diffusion tensors.  The voxels with valid tensors will be
% marked in the output variable 'validityImage'.
%
% The algorithm isn't sensitive to the dimensionality of the input images.
% Feel free to input 1 or 2 dimensional images.
%
% REFERENCES:
% [*] D. Le Bihan, J.-F. Mangin, C. Poupon, C. A. Clark, S. Pappata, N.
%     Molko, H. Chabriate.  Diffusion Tensor Imaging: Concepts and
%     Applications.  Journal of Magnetic Resonance Imaging 13:534-546
%     (2001).
%
% [*] P. J. Basser, J. Mattiello, D. Le Bihan.  Estimation of the Effective
%     Self-Diffusion Tensor from the NMR Spin Echo.  Journal of Magnetic
%     Resonance, Series B 103, 247-254 (1994).
%
%--------------------------------------------------------------------------
% Justin Haldar 06/24/2006 haldar@uiuc.edu
%--------------------------------------------------------------------------

M = size(b0Image,1);
N = size(b0Image,2);
P = size(b0Image,3);
B = size(bImages,1);

%% Configure linear equations

diffusionWeightedImages = zeros(B,M,N,P);

bMatrix = zeros(B,6);

for bIndex = 1:B
    diffusionWeightedImages(bIndex,:,:,:) = log(abs(squeeze(bImages(bIndex,:,:,:))./b0Image));
    bMatrix(bIndex,:) = -[bMatrices(1,1,bIndex) bMatrices(2,2,bIndex) bMatrices(3,3,bIndex) 2*bMatrices(2,1,bIndex) 2*bMatrices(3,1,bIndex) 2*bMatrices(3,2,bIndex)];
end

%% Permute diffusion tensors and calculate various meta-parameters
lambdas = zeros(3,M,N,P);
eigenVectors = zeros(3,3,M,N,P);
residualImage = zeros(M,N,P);
for mIndex = 1:M
    for nIndex = 1:N
        for pIndex = 1:P
            [Q,R] = qr(diag(sqrt(1./(1./abs(bImages(:,mIndex,nIndex,pIndex)).^2+1./abs(b0Image(mIndex,nIndex,pIndex)).^2)))*bMatrix,0);
            dValues(:,mIndex,nIndex,pIndex) = R\Q' *(sqrt(1./(1./abs(bImages(:,mIndex,nIndex,pIndex)).^2+1./abs(b0Image(mIndex,nIndex,pIndex)).^2)).*diffusionWeightedImages(:,mIndex,nIndex,pIndex));
            [v,d] = eig([dValues(1,mIndex,nIndex,pIndex),dValues(4,mIndex,nIndex,pIndex),dValues(5,mIndex,nIndex,pIndex);dValues(4,mIndex,nIndex,pIndex),dValues(2,mIndex,nIndex,pIndex),dValues(6,mIndex,nIndex,pIndex);dValues(5,mIndex,nIndex,pIndex),dValues(6,mIndex,nIndex,pIndex),dValues(3,mIndex,nIndex,pIndex)]);
            lambdas(:,mIndex,nIndex,pIndex) = flipud(sort(diag(d)));
            [temp,index1] = sort(diag(d));
            eigenVectors(:,:,mIndex,nIndex,pIndex) = v(:,flipud(index1));
            residualImage(mIndex,nIndex,pIndex) = norm(bMatrix*dValues(:,mIndex,nIndex,pIndex) - diffusionWeightedImages(:,mIndex,nIndex,pIndex));
        end
    end
end
