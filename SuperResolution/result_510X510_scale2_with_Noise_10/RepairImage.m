clc; clear; close all;
TestImagesSetNames = {'DIV2K_valid_HR','Urban100','Manga109','Flickr1024/Test'};
Num_of_Sets_Test_Images = length(TestImagesSetNames);
PSNR = cell(4,Num_of_Sets_Test_Images+1); 
SSIM = cell(4,Num_of_Sets_Test_Images+1);
PSNR{2,1}='Algorithem1PSNR';PSNR{3,1}='Algorithem2PSNR';PSNR{4,1}='Algorithem3PSNR';
PSNR{1,2}='DIV2K_valid_HR';PSNR{1,3}='Urban100';PSNR{1,4}='Manga109';PSNR{1,5}='Flickr1024/Test';
SSIM{2,1}='Algorithem1SSIM';PSNR{3,1}='Algorithem2SSIM';
SSIM{1,2}='DIV2K_valid_HR';SSIM{1,3}='Urban100';SSIM{1,4}='Manga109';SSIM{1,5}='Flickr1024/Test';

sigma=10;
scaleFactor = 2;
load("SLT_P.mat","H","H_trans","K","N")
load("C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\DATA_SET_GRAY_VECTOR_NORMALIZED\Std"+int2str(sigma)+"\normalized.mat")
netDeNoise = importKerasNetwork("C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\vector-std"+int2str(sigma)+"\Normalized,adam,4layers,256-256-256-256,sigmoid\model.h5");
netSuperResolution = importKerasNetwork("C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\Super Resolution - Python\result_510X510_scale"+int2str(scaleFactor)+"\buildTheNetwork-adam,4layers,256-256-256-256,relu\model.h5");
netDeNoiseAndSuperResolution = importKerasNetwork("model.h5");

for numSet=1:Num_of_Sets_Test_Images
    testImages = imageDatastore("C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\training_and_testing_imageDataSets\" + TestImagesSetNames{numSet} + "\",'FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true); 
    scaleFactor = 2;
    numImage = length(testImages.Files);
    for i=1:numImage
        [Image,info] = read(testImages);
        [~,fileName,~] = fileparts(info.Filename);
        disp(fileName);   
        if (size(Image,3) == 3)
            Image = rgb2gray(Image);
        end
        Image = imcrop(Image,[0,0,510,510]);
        [DIM1,DIM2] = size(Image);
        ImageDouble = im2double(Image); 
        ImageLR = imresize(Image, 1/scaleFactor, 'bicubic');
        [DIM1_ImageLR,DIM2_ImageLR] = size(ImageLR);  
        ImageLRnoisy = double(ImageLR) + randn(DIM1_ImageLR,DIM2_ImageLR)*sigma;
        ImageLRnoisy(ImageLRnoisy<0) = 0;
        ImageLRnoisy(ImageLRnoisy>255) = 255;
        ImageLRnoisy = uint8(ImageLRnoisy);

        %Algorithem1
        ImageLRnoisyDoubleAfterDeNoise = im2double(DeNoiseOneImageFunction(ImageLRnoisy,netDeNoise,normalized,H,H_trans,K,N));
        ImageDoubleRepairByAlgorithem1 = imresize(ImageLRnoisyDoubleAfterDeNoise,[DIM1,DIM2],'bicubic');

        %Algorithem2
        UpsampledImageAfterDeNoiseDouble = imresize(ImageLRnoisyDoubleAfterDeNoise,[DIM1,DIM2],'bicubic');
        ImageDoubleRepairByAlgorithem2 = im2double(SuperResolutionOneImageFunction(im2uint8(UpsampledImageAfterDeNoiseDouble),netSuperResolution));

        %Algorithem3
        ImageLRnoisyDouble = im2double(ImageLRnoisy);
        UpsampledImageNoisyDouble = imresize(ImageLRnoisyDouble,[DIM1,DIM2],'bicubic'); 
        ResidualImageNoisyDoubleRepairByAlgorithem3 =  double(activations(netDeNoiseAndSuperResolution,UpsampledImageNoisyDouble,length(netDeNoiseAndSuperResolution.Layers)));
        ImageDoubleRepairByAlgorithem3 = UpsampledImageNoisyDouble + ResidualImageNoisyDoubleRepairByAlgorithem3;

        Algorithem1PSNR(i) = psnr(ImageDoubleRepairByAlgorithem1,ImageDouble);
        Algorithem2PSNR(i) = psnr(ImageDoubleRepairByAlgorithem2,ImageDouble);
        Algorithem3PSNR(i) = psnr(ImageDoubleRepairByAlgorithem3,ImageDouble);
        Algorithem1SSIM(i) = ssim(ImageDoubleRepairByAlgorithem1,ImageDouble);
        Algorithem2SSIM(i) = ssim(ImageDoubleRepairByAlgorithem2,ImageDouble);
        Algorithem3SSIM(i) = ssim(ImageDoubleRepairByAlgorithem3,ImageDouble);
    end
    PSNR{2,numSet+1} = mean(Algorithem1PSNR);
    PSNR{3,numSet+1} = mean(Algorithem2PSNR);
    PSNR{4,numSet+1} = mean(Algorithem3PSNR);
    SSIM{2,numSet+1} = mean(Algorithem1SSIM);
    SSIM{3,numSet+1} = mean(Algorithem2SSIM);
    SSIM{4,numSet+1} = mean(Algorithem3SSIM);
end
save PSNR PSNR
save SSIM SSIM
