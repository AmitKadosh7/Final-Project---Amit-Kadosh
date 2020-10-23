function ImageRGBRepairByNet = SuperResolutionOneImageFunction(ImageRGBLR,netSuperResolution,scaleFactor) 
    if (size(ImageRGBLR,3) ~= 3)
        ImageRGBLR = cat(3,ImageRGBLR,ImageRGBLR,ImageRGBLR);                    
    end
    
    UpsampledImageRGBDouble = imresize(im2double(ImageRGBLR),scaleFactor,'bicubic');
    UpsampledImageYCbCrDouble = rgb2ycbcr(UpsampledImageRGBDouble);
    UpsampledImageYDouble = UpsampledImageYCbCrDouble(:,:,1);

    ResidualImageYDouble =  double(activations(netSuperResolution,UpsampledImageYDouble,length(netSuperResolution.Layers)));
    ImageYDoubleRepairByNet = UpsampledImageYDouble + ResidualImageYDouble;
    
    UpsampledImageCbDouble = UpsampledImageYCbCrDouble(:,:,2);
    UpsampledImageCrDouble = UpsampledImageYCbCrDouble(:,:,3);

    ImageYCbCrDoubleRepairByNet = cat(3,ImageYDoubleRepairByNet,UpsampledImageCbDouble,UpsampledImageCrDouble);
    ImageRGBDoubleRepairByNet = ycbcr2rgb(ImageYCbCrDoubleRepairByNet);
    ImageRGBRepairByNet = im2uint8(ImageRGBDoubleRepairByNet);
end