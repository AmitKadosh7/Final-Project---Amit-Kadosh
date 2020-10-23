% single precision, multiple patches
clear all
close all
clc
tic
N=8; % NxN DCT 
K=N^2; % number of sub-bands
B=zeros(N^2); % DCT basis functions image
H=zeros(N^2,N,N); % 64x8x8 matrix containing all basis functions
T=dctmtx(N); % 1D DCT Matrix
inverse=0;
k=0;
% Build DCT Basis
for n2=1:N
    for n1=1:N
        k=k+1;
        I=zeros(N);
        I(n1,n2)=1;
        dct_basis_function=single(T'*I*T);
        B((n1-1)*N+1:(n1-1)*N+8,(n2-1)*N+1:(n2-1)*N+8)=dct_basis_function;
        H(k,:,:)=dct_basis_function;
    end
end
figure(1)
imshow(B,[]) % DCT basis functions


%Synthesis
Ye=0;
for k=1:N^2
    % Multiband reconstruction
    tmp_conv=conv2(squeeze(H(k,:,:)),fliplr(flipud(squeeze(H(k,:,:)))))/N^2
    Ye=Ye+tmp_conv(N/2:end-N/2+1,N/2:end-N/2+1);
end
%Ye=uint8(Ye(N:end-N+1,N:end-N+1)); % Reconstructed Image
%
Ye=uint8(Ye);
I=imread('cameraman.tif');
R=conv2(single(I),single(Ye));
R=uint8(R(N/2+1:end-N/2,N/2+1:end-N/2)); % Reconstructed Image
imshow(uint8(R))
sum(sum(abs(R-I)))