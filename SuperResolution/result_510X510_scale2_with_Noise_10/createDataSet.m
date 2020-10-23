clc;
clear;
close all;

scaleFactor = 2;
sigma = 5;
trainUpsampledDirName = '.\trainUpsampledImages';
trainResidualDirName = '.\trainResidualImages';
validationUpsampledDirName = '.\validationUpsampledImages';
validationResidualDirName = '.\validationResidualImages';
if ~isfolder(trainUpsampledDirName)
    mkdir(trainUpsampledDirName);
end
if ~isfolder(trainResidualDirName)
    mkdir(trainResidualDirName);
end
if ~isfolder(validationUpsampledDirName)
    mkdir(validationUpsampledDirName);
end
if ~isfolder(validationResidualDirName)
    mkdir(validationResidualDirName);
end

dsImages = imageDatastore('C:\Users\user\Desktop\Studies\Semester 8\myProject\super resolution\training_and_testing_imageDataSets\imagesDirForTrainAndValidation510x510','FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);
numImage = length(dsImages.Files);
endIndexTrain = round(0.8*numImage);
for i=1:numImage
    [Image,info] = read(dsImages);
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
    ImageLRnoisyDouble = im2double(ImageLRnoisy);
    UpsampledImageNoisyDouble = imresize(ImageLRnoisyDouble,[DIM1,DIM2],'bicubic'); 
    ResidualImageNoisyDouble = ImageDouble - UpsampledImageNoisyDouble;
    if (i < endIndexTrain)
        save([trainUpsampledDirName filesep fileName '.mat'], 'UpsampledImageNoisyDouble');
        save([trainResidualDirName filesep fileName '.mat'], 'ResidualImageNoisyDouble'); 
    else
        save([validationUpsampledDirName filesep fileName '.mat'], 'UpsampledImageNoisyDouble');
        save([validationResidualDirName filesep fileName '.mat'], 'ResidualImageNoisyDouble'); 
    end
end