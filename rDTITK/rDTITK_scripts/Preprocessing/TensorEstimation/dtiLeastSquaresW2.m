function [lambdas, eigenVectors,residualImage] = dtiLeastSquaresW2(bImages, bMatrices)
%--------------------------------------------------------------------------
% [lambdas, eigenVectors, validityImage,residualImage] = dtiLeastSquaresW(b0Image,
%                                                      bImages, bMatrices);
%--------------------------------------------------------------------------
% Computes diffusion tensors for each voxel from diffusion weighted images
% using a least-squares regression.  Modified from dtiLeastSquaresW.m to
% not require any b=0 image and to estimate the amplitude of the signal directly.
%
% INPUTS:
% --bImages                    = An BxMxNxP array, where B is the total
%                                number of different b-matrices (excluding
%                                b = 0).  The (b,:,:,:) subarray is the bth
%                                diffusion-encoded image.
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
%
%--------------------------------------------------------------------------
% Justin Haldar 07/04/2006 haldar@uiuc.edu  
%--------------------------------------------------------------------------

M = size(bImages,2);
N = size(bImages,3);
P = size(bImages,4);
B = size(bImages,1);

%% Configure linear equations

diffusionWeightedImages = zeros(B,M,N,P);

bMatrix = zeros(B,7);

for bIndex = 1:B
    diffusionWeightedImages(bIndex,:,:,:) = log(abs(squeeze(bImages(bIndex,:,:,:))));
    bMatrix(bIndex,:) = -[bMatrices(1,1,bIndex) bMatrices(2,2,bIndex) bMatrices(3,3,bIndex) 2*bMatrices(2,1,bIndex) 2*bMatrices(3,1,bIndex) 2*bMatrices(3,2,bIndex) -1];
end

%% Permute diffusion tensors and calculate various meta-parameters
lambdas = zeros(3,M,N,P);
eigenVectors = zeros(3,3,M,N,P);
residualImage = zeros(M,N,P);
for mIndex = 1:M
    for nIndex = 1:N
        for pIndex = 1:P
            [Q,R] = qr(diag(abs(bImages(:,mIndex,nIndex,pIndex)))*bMatrix,0);
            dValues(:,mIndex,nIndex,pIndex) = R\Q' *(diag(abs(bImages(:,mIndex,nIndex,pIndex)))*diffusionWeightedImages(:,mIndex,nIndex,pIndex));
            [v,d] = eig([dValues(1,mIndex,nIndex,pIndex),dValues(4,mIndex,nIndex,pIndex),dValues(5,mIndex,nIndex,pIndex);dValues(4,mIndex,nIndex,pIndex),dValues(2,mIndex,nIndex,pIndex),dValues(6,mIndex,nIndex,pIndex);dValues(5,mIndex,nIndex,pIndex),dValues(6,mIndex,nIndex,pIndex),dValues(3,mIndex,nIndex,pIndex)]);
            lambdas(:,mIndex,nIndex,pIndex) = flipud(sort(diag(d)));
            [temp,index1] = sort(diag(d));
            eigenVectors(:,:,mIndex,nIndex,pIndex) = v(:,flipud(index1));
            residualImage(mIndex,nIndex,pIndex) = norm(bMatrix*dValues(:,mIndex,nIndex,pIndex) - diffusionWeightedImages(:,mIndex,nIndex,pIndex));
        end
    end
end
%1
return;
