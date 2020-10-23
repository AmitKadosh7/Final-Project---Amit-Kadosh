% single precision, multiple patches
% reconstruction code
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
M=15; % bins
load SLT_P
% Build DCT Basis
% for n2=1:N
%     for n1=1:N
%         k=k+1;
%         I=zeros(N);
%         I(n1,n2)=1;
%         dct_basis_function=single(T'*I*T)/N;
%         B((n1-1)*N+1:(n1-1)*N+8,(n2-1)*N+1:(n2-1)*N+8)=dct_basis_function;
%         H(k,:,:)=dct_basis_function;
%     end
% end

DIM=360;
Y=imread('im3_s.jpg');
Y=Y(1:DIM,1:DIM);

YB=(zeros(K,DIM+N-1,DIM+N-1));


L_Trans_X=zeros(K*(M+1),1);
%Synthesis
Ye=0;
q=zeros(M+1,K);
%L=single(zeros((DIM)^2,N*N*(M+1)));
L=single(zeros((DIM+2*N-2)^2,N*N*(M+1)));
l=0;
for k=1:N^2
    % Multiband decomposition
    tmp_conv_Y=single(conv2(single(Y),single(squeeze(H(k,:,:)))));
    Ye=Ye+single(conv2(tmp_conv_Y,single(squeeze(H_trans(k,:,:)))));
   
    % L_Transpose_X calculation
end

Ye=uint8(Ye(N:end-N+1,N:end-N+1)); % Reconstructed Image
%
sum(sum(abs(Y-Ye)))

