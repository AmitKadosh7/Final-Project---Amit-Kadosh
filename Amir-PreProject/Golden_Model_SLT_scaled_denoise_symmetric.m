%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Golden Model for Un-weighted shrinkage,  modified 27/8/2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SLT Denoise, produce the set of all test images
% with SSIM and scaling for various STD levels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
load SLT_P % load stored variables from training phase
clc
test_sigma=25;
s=test_sigma/sigma;
P=reshape(p,M+1,K);
Test_Image={'barbara.png','boat.png','fingerprint.png','house.png','lena.png','peppers256.png'};
Num_of_Test_Images=length(Test_Image);
Noise_Realizations=1;
PSNR=zeros(Num_of_Test_Images,Noise_Realizations);
SSIM=PSNR;
for i=1:Num_of_Test_Images % test images counter
    Curent_Image=Test_Image{i};
    X=imread(Curent_Image); % Training Image
    
   
    [DIM1,DIM2]=size(X);

    for n=1:Noise_Realizations % Noise realization counter
        
        % Create Noisy Image
        Y=double(X)+double(randn(DIM1,DIM2)*test_sigma); % Noisy Training Image
        Xe=0;

        for k=1:K % subband counter
            i,k,n
            % Multiband decomposition
            Y_k=single(conv2(Y,double(squeeze(H(k,:,:)))));
            [Sq q hy]=Sq3(Y_k(:)/s,M,Range(k,1),Range(k,2));
            % Apply Shrinkage
            p_k=double(P(:,k));
            Map_Y_k=s*Sq*p_k+hy;

            Map_Y_k=reshape(Map_Y_k,DIM1+N-1,DIM2+N-1);
            %%%%%%%%%%%
            % Reconstruction
            Xe=Xe+single(conv2(Map_Y_k,double(squeeze(H_trans(k,:,:)))));
        end
        Xe=uint8(Xe(N:end-N+1,N:end-N+1)); % Reconstructed Image
        PSNR(i,n) = calcPSNR(X,Xe);
        SSIM(i,n)=ssim_index(X,Xe);
     

    end
    figure(i)
    subplot(1,3,1)
    imshow(X)
    title('Original')
    subplot(1,3,2)
    imshow(Y,[])
    title('Noisy')
    subplot(1,3,3)
    imshow(Xe)
    title('Denoised')

end

save PSNR PSNR SSIM


