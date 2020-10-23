% single precision, multiple patches, with out of range treatment
clear all
close all
load SLT_P
clc
tic
N=8; % NxN DCT 
K=N^2; % number of sub-bands
B=zeros(N^2); % DCT basis functions image
% H=zeros(N^2,N,N); % 64x8x8 matrix containing all basis functions
% H_trans=H; % % 64x8x8 matrix containing all transposed basis functions

M=15;
X=imread('cameraman.tif'); % Training Image
% Create Noisy Image
sigma=20;
Y=single(X)+single(randn(size(X))*sigma); % Noisy Training Image
% extract training examples
DIM=256;
YB=zeros(K,DIM+N-1,DIM+N-1); % Subband noisy images
XB=zeros(K,DIM+N-1,DIM+N-1); % Subband clean images
Y_recon=0;
L=single(zeros((DIM+2*N-2)^2,N*N*(M+1)));



T=dctmtx(N); % 1D DCT Matrix
inverse=0;
k=0;
% Build DCT Basis
% for n2=1:N
%     for n1=1:N
%         k=k+1;
%         I=zeros(N);
%         I(n1,n2)=1;
%         dct_basis_function=single(T'*I*T)/N;
%         B((n1-1)*N+1:(n1-1)*N+8,(n2-1)*N+1:(n2-1)*N+8)=dct_basis_function;
%         H(k,:,:)=dct_basis_function;
%         H_trans(k,:,:)=fliplr(flipud(dct_basis_function));
%     end
% end
% 
% 
% SLT range calculation per band

l=0;
h_e=0;
 for k=1:K
        k
        % Multiband decomposition
        tmp_conv_Y=single(conv2(single(Y),single(squeeze(H(k,:,:)))));
        

        YB(k,:,:)=tmp_conv_Y;
        YB_tmp=squeeze(YB(k,:,:));
        
        [Sy q(:,k) hy]=Sq2(YB_tmp(:),M,Range(k,1),Range(k,2));
        basis_tmp=squeeze(H_trans(k,:,:));
        for i=1:M+1
            l=l+1;
            Hi=single(conv2(single(reshape(full(Sy(:,i)),DIM+N-1,DIM+N-1)),basis_tmp));
            L(:,l)= single(Hi(:));
        end
        
        Bh=single(conv2(single(reshape(hy,DIM+N-1,DIM+N-1)),basis_tmp));
        h_e=h_e+Bh(:);
        
%         % L_Transpose_X calculation
%         XB(k,:,:)=tmp_conv_X;
%         XB_tmp=squeeze(XB(k,:,:));
%         [Sx q(:,k) hx]=Sq2(XB_tmp(:),M,Range(k,1),Range(k,2));
%         L_Trans_X((k-1)*(M+1)+1:k*(M+1)) = single(full(Sy)')*XB_tmp(:);
%         % calc out-of-range subbadn k componenet of L_Transpose
      
        
    end
    Ye=L*p+h_e;

    




