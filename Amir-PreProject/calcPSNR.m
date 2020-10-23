function [PSNR,MSE] = calcPSNR(Xtrue,Xest)
    MSE=mean((double(Xtrue(:))-double(Xest(:))).^2);
    PSNR=20*log10(255/sqrt(MSE));
return;



