load SLT_P
figure(1)
indexes=1:8;
index=(indexes-1)*N+indexes;
p=reshape(p,M+1,K);
for i=1:8
    subplot(2,4,i)
    q_tmp=q(1:M+1,index(i));
    sym_q_tmp=[-flipud(q_tmp);q_tmp];
    p_tmp=p(1:M+1,index(i));
    sym_p_tmp=[-flipud(p_tmp);p_tmp];
    plot(sym_q_tmp,sym_q_tmp,'r',sym_q_tmp,sym_p_tmp,'b')
    %legend('No Shinkage','Unweighted','Weighted')
    t=strcat('Mapping Function (',num2str(indexes(i)),',',num2str(num2str(indexes(i))),')');
    title(t)
end
