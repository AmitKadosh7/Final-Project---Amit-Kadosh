clc; clear; close all;

TestImagesSetNames = {'Set5','Set14','BSDS100','Urban100','Manga109'};
Num_of_Sets_Test_Images = length(TestImagesSetNames);
PSNR = cell(3,Num_of_Sets_Test_Images+1); 
SSIM = cell(3,Num_of_Sets_Test_Images+1);
PSNR{2,1}='PSNR_Bicubic';PSNR{3,1}='PSNR_Network';
PSNR{1,2}='Set5';PSNR{1,3}='Set14';PSNR{1,4}='BSDS100';PSNR{1,5}='Urban100';PSNR{1,6}='Manga109';
SSIM{2,1}='SSIM_Bicubic';PSNR{3,1}='SSIM_Network';
SSIM{1,2}='Set5';SSIM{1,3}='Set14';SSIM{1,4}='BSDS100';SSIM{1,5}='Urban100';SSIM{1,6}='Manga109';

for numSet=1:Num_of_Sets_Test_Images
    testImages = imageDatastore("C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\training_and_testing_imageDataSets\" + TestImagesSetNames{numSet} + "\",'FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);
    net = importKerasNetwork('model.h5');
    scaleFactor = 2;
    fprintf('Results for Scale factor %d\n\n',scaleFactor);
    numImage = length(testImages.Files);
    for i=1:numImage
        [Image,info] = read(testImages);
        [~,fileName,~] = fileparts(info.Filename);
        disp(fileName);   
        if (size(Image,3) == 3)
            Image = rgb2gray(Image);
        end
        Image = imcrop(Image,[0,0,100,100]);
        sizeImage = size(Image);
        ImageDouble = im2double(Image); %for PSNR and SSIM
        UpsampledImageDouble = imresize(imresize(ImageDouble,1/scaleFactor,'bicubic'),sizeImage,'bicubic');
        ResidualImageDoubleRepairByNet =  double(activations(net,UpsampledImageDouble,length(net.Layers)));
        ImageDoubleRepairByNet = UpsampledImageDouble + ResidualImageDoubleRepairByNet;
        BicubicPSNR(i) = psnr(UpsampledImageDouble,ImageDouble);
        NetworkPSNR(i) = psnr(ImageDoubleRepairByNet,ImageDouble);
        BicubicSSIM(i) = ssim(UpsampledImageDouble,ImageDouble);
        NetworkSSIM(i) = ssim(ImageDoubleRepairByNet,ImageDouble);   
    end
    PSNR{2,numSet+1} = mean(BicubicPSNR);
    PSNR{3,numSet+1} = mean(NetworkPSNR);
    SSIM{2,numSet+1} = mean(BicubicSSIM);
    SSIM{3,numSet+1} = mean(NetworkSSIM);  
end
save PSNR PSNR
save SSIM SSIM
