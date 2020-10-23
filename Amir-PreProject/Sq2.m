function [S q h]=Sq2(x,M,a,b)
x=double(x);
N=length(x);
h=zeros(size(x));
% Creat Uniform Grid
t=0:1/M:1; 
q=t'*(b-a)+a; 
%%%%%%%%%%%%%%%%%%%%%%%

bin_indexes_vector=bin2(x,q);
out_of_range=find(bin_indexes_vector==0);
in_range=find(bin_indexes_vector~=0);
h(out_of_range)=x(out_of_range);
R=res2(x,q,bin_indexes_vector);
NN=1:N;
S=sparse([NN(in_range) NN(in_range)],[bin_indexes_vector(in_range); bin_indexes_vector(in_range)+1],[1-R(in_range); R(in_range)],N,M+1);

function r=res2(x,q,bin_indexes_vector)
N=length(x);
M=length(q);
in_range=find(bin_indexes_vector~=0);
NN=1:N;
A=sparse(NN(in_range),bin_indexes_vector(in_range),ones(length(in_range),1),N,M);
A1=sparse(NN(in_range),bin_indexes_vector(in_range)+1,ones(length(in_range),1),N,M);
r=(x-A*q)./(A1*q-A*q);
