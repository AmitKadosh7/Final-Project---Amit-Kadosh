clc;
clear;
net = importKerasNetwork('model.h5');
scaleFactor = 2;
Image = imread('C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\training_and_testing_imageDataSets\Set5\bird.png');
if (size(Image,3) == 3)
    Image = rgb2gray(Image);
end
Image = imcrop(Image,[0,0,100,100]);
sizeImage = size(Image);
ImageDouble = im2double(Image); %for PSNR and SSIM
UpsampledImageDouble = imresize(imresize(ImageDouble,1/scaleFactor,'bicubic'),sizeImage,'bicubic');
ResidualImageDoubleRepairByNet =  double(activations(net,UpsampledImageDouble,length(net.Layers)));
ImageDoubleRepairByNet = UpsampledImageDouble + ResidualImageDoubleRepairByNet;
BicubicPSNR = psnr(UpsampledImageDouble,ImageDouble);
NetworkPSNR = psnr(ImageDoubleRepairByNet,ImageDouble);
BicubicSSIM = ssim(UpsampledImageDouble,ImageDouble);
NetworkSSIM = ssim(ImageDoubleRepairByNet,ImageDouble);
montage({im2uint8(UpsampledImageDouble),im2uint8(ImageDoubleRepairByNet)});
title(['Bicubic (left): psnr = ',num2str(BicubicPSNR),' ssim = ',num2str(BicubicSSIM), ...
    '                            Network (right): psnr = ',num2str(NetworkPSNR),' ssim = ',num2str(NetworkSSIM)]);