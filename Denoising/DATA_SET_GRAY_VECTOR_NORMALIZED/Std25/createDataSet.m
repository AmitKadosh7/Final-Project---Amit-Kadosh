clc; clear; close all;

load SLT_P
sigma = 25;
num_patch_images = 5;
dataAndLabel = cell(K,2);
dsImages = imageDatastore('C:\Users\user\Desktop\Studies\Semester 8\myProject\de-noise\grayImageDataSet','FileExtensions',{'.jpg','.bmp','.png'},'IncludeSubfolders', true);
num_image = length(dsImages.Files);
normalized = zeros(K,1);
j=0;
while 1
    dataAndLabel = cell(K,2);
    if hasdata(dsImages) == 0
        break
    end
    for i=1:num_patch_images
        if hasdata(dsImages) == 0
            break
        end
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
        for k=1:K 
            ImageNoisyAfterHk = double(conv2(ImageNoisy,double(squeeze(H(k,:,:)))));
            ImageAfterHk = double(conv2(Image,double(squeeze(H(k,:,:)))));
            dataAndLabel{k,1} = [dataAndLabel{k,1};reshape(ImageNoisyAfterHk.', [], 1)];
            dataAndLabel{k,2} = [dataAndLabel{k,2};reshape(ImageAfterHk.', [], 1)];
            normalized(k,1) = max(normalized(k,1),max(max(abs([dataAndLabel{k,:}]))));
        end
    end
    newDataAndLabel = cell(length(dataAndLabel{k,1}),2);
    for m = 1:length(dataAndLabel{k,1})
        for k = 1:K
            newDataAndLabel{m,1} = [newDataAndLabel{m,1}; dataAndLabel{k,1}(m)];
            newDataAndLabel{m,2} = [newDataAndLabel{m,2}; dataAndLabel{k,2}(m)];
        end
    end
    disp(int2str(j));
    save(int2str(j),'newDataAndLabel');
    disp(int2str(j));
    j=j+1; 
end

save normalized normalized
for numFile=0:(j-1)
    load(num2str(numFile) + ".mat");
    for m = 1:length(newDataAndLabel)
        newDataAndLabel{m,1} = newDataAndLabel{m,1}./normalized;
        newDataAndLabel{m,2} = newDataAndLabel{m,2}./normalized;
    end
    save(int2str(numFile),'newDataAndLabel');
end