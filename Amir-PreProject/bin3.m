function b=bin3(x,q)
% Symmetric MF bin allocation
b=zeros(size(x));
abs_x=abs(x);
for i=1:length(q)-1
    values_in_current_bin=find( (abs_x>=q(i)) & (abs_x<q(i+1)));
    b(values_in_current_bin)=i;
end

    
