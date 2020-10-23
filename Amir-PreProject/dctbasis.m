clear all
close all
clc
tic
N=8; % NxN DCT 
K=N^2; % number of sub-bands
B=zeros(N^2); % DCT basis functions image
H=zeros(N^2,N,N); % 64x8x8 matrix containing all basis functions

Y=imread('im3_s.jpg'); % Input Image
Y=Y(1:120,1:120); % crop smaller image
DIM=120;
% Create Noisy Image
sigma=0;
X=double(Y)+randn(size(Y))*sigma;
%%%%%%%%%%%%%%%%%%%%
%XB=zeros(N^2,DIM+N-1,DIM+N-1); % Subband images
XB=zeros(N^2,DIM,DIM); % Subband images
T=dctmtx(N); % 1D DCT Matrix
inverse=0;
k=0;
% Build DCT Basis
for n2=1:N
    for n1=1:N
        k=k+1;
        I=zeros(N);
        I(n1,n2)=1;
        dct_basis_function=T'*I*T;
        B((n1-1)*N+1:(n1-1)*N+8,(n2-1)*N+1:(n2-1)*N+8)=dct_basis_function;
        H(k,:,:)=dct_basis_function;
%       XB(k,:,:)=conv2(double(X),dct_basis_function);
%       inverse=inverse+conv2(dct_basis_function,fliplr(flipud(dct_basis_function)))/N^2;
    end
end
figure(1)
imshow(B,[]) % DCT basis functions

% Analysis 
for k=1:N^2
        XB(k,:,:)=conv2(double(X),squeeze(H(k,:,:)),'same');
end

% Synthesis
Ye=0;
for k=1:N^2
    % Multiband reconstruction
    Ye=Ye+conv2(squeeze(XB(k,:,:)),fliplr(flipud(squeeze(H(k,:,:)))))/N^2;
end
Ye=uint8(Ye(N:end-N+1,N:end-N+1)); % Reconstructed Image
%Ye=uint8(Ye(N/2:end-N/2+1,N/2:end-N/2+1)); % Reconstructed Image
% figure(2)
% subplot(2,4,1)
% imshow(squeeze(XB(1,:,:)),[]);
% subplot(2,4,2)
% imshow(squeeze(XB(9,:,:)),[]);
% subplot(2,4,3)
% imshow(squeeze(XB(17,:,:)),[]);
% subplot(2,4,4)
% imshow(squeeze(XB(25,:,:)),[]);
% subplot(2,4,5)
% imshow(squeeze(XB(33,:,:)),[]);
% subplot(2,4,6)
% imshow(squeeze(XB(41,:,:)),[]);
% subplot(2,4,7)
% imshow(squeeze(XB(49,:,:)),[]);
% subplot(2,4,8)
% imshow(squeeze(XB(64,:,:)),[]);
figure(3)
imshow(Ye)

%%%%%%%%%%%

% Build L Matrix

l=0; % column counter of L
hi_total=0; % out of range component
M=15; % Number of bins
L=zeros((DIM)^2,N*N*(M+1));
%L=zeros((DIM+N-1)^2,N*N*(M+1));
for k=1:N^2
    % Build Hk
    XB_tmp=squeeze(XB(k,:,:));
    [S q h]=Sq2(XB_tmp(:),M,-250,250);
    basis_tmp=fliplr(flipud(squeeze(H(k,:,:))));
    for i=1:M+1
        l=l+1;
%         Hi=conv2(reshape(full(S(:,i)),DIM+N-1,DIM+N-1),basis_tmp,'same');
       Hi=conv2(reshape(full(S(:,i)),DIM,DIM),basis_tmp,'same');
        
        L(:,l)= Hi(:);
       % hi=conv2(reshape(h,DIM+N-1,DIM+N-1),basis_tmp,'same');
        hi=conv2(reshape(h,DIM,DIM),basis_tmp,'same');
        
        hi_total=hi_total+hi;
    end
end
lamda=(0.005*DIM*DIM/M)^2;
Q=repmat(q,K,1);
p=inv(L'*L+lamda*eye(N*N*(M+1)))*(L'*(double(Y(:))-hi_total(:))+lamda*Q);
toc
figure(4)
plot(p)

