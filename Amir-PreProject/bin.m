function b=bin(x,q)
b=zeros(size(x));
for i=1:length(q)-1
    values_in_current_bin=find( (x<=q(i+1)) & (x>q(i)));
    b(values_in_current_bin)=i;
end

    
