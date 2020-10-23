clc; clear; close all;

load SLT_P
sigma = 25;
data = 0;
label = 0;
normalized = zeros(K);
for k=1:K
    dsImages = imageDatastore('C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\grayImageDataSet','FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);
    dataAndLabel = cell(1,2);
    for i=1:length(dsImages.Files)
        [Image,info] = read(dsImages);
        [~,fileName,~] = fileparts(info.Filename);
        disp(fileName);   
        if (size(Image,3) == 3)
            Image = rgb2gray(Image);
        end
        [DIM1,DIM2] = size(Image);
        ImageNoisy = double(Image) + randn(DIM1,DIM2)*sigma;
        ImageNoisy(ImageNoisy<0) = 0;
        ImageNoisy(ImageNoisy>255) = 255;
        ImageNoisy = uint8(ImageNoisy);
        
        ImageNoisyAfterHk = double(conv2(ImageNoisy,double(squeeze(H(k,:,:)))));
        ImageAfterHk = double(conv2(Image,double(squeeze(H(k,:,:)))));
        dataAndLabel{1,1} = [dataAndLabel{1,1};reshape(ImageNoisyAfterHk.', [], 1)];
        dataAndLabel{1,2} = [dataAndLabel{1,2};reshape(ImageAfterHk.', [], 1)];
    end
	normalized(k) = max(max(abs([dataAndLabel{1,:}])));
    dataAndLabel = {dataAndLabel{1,1}/normalized(k), dataAndLabel{1,2}/normalized(k)};
    nameFile = int2str(k-1) + ".mat";
    save(nameFile, 'dataAndLabel');
end
save normalized normalized