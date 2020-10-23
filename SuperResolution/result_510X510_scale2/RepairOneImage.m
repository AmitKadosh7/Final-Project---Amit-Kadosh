clc; clear; close;
net = importKerasNetwork('.\buildTheNetwork-adam,4layers,256-256-256-256,relu\model.h5');
scaleFactor = 2;
Image = imread('C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\grayImageDataSet\image08DataSet.png');
if (size(Image,3) == 3)
    Image = rgb2gray(Image);
end
Image = imcrop(Image,[0,0,510,510]);
sizeImage = size(Image);
ImageDouble = im2double(Image);
ImageLR = imresize(ImageDouble,1/scaleFactor,'bicubic');
UpsampledImageDouble = imresize(ImageLR,sizeImage,'bicubic');
ResidualImageDoubleRepairByNet = double(activations(net,UpsampledImageDouble,length(net.Layers)));
ImageDoubleRepairByNet = UpsampledImageDouble + ResidualImageDoubleRepairByNet;
BicubicPSNR = psnr(UpsampledImageDouble,ImageDouble);
NetworkPSNR = psnr(ImageDoubleRepairByNet,ImageDouble);
BicubicSSIM = ssim(UpsampledImageDouble,ImageDouble);
NetworkSSIM = ssim(ImageDoubleRepairByNet,ImageDouble);

image1 = subplot(1,3,1);
imshow(ImageLR);
title({'Image Low','Resolution'});
image2 = subplot(1,3,2);
imshow(im2uint8(UpsampledImageDouble));
title({'Bicubic:',[' psnr = ',num2str(BicubicPSNR)],[' ssim = ',num2str(BicubicSSIM)]});
image3 = subplot(1,3,3);
imshow(im2uint8(ImageDoubleRepairByNet));
title({'Network:',[' psnr = ',num2str(NetworkPSNR)],[' ssim = ',num2str(NetworkSSIM)]});
linkaxes([image1,image2,image3])
