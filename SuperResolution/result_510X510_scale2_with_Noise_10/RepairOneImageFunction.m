function ImageRepair = RepairOneImageFunction(ImageNoisy,netDeNoise,normalized,H,H_trans,K,N)    
    ImageRepair = 0;
    ImageNoisyAfterHk = double(conv2(ImageNoisy,double(squeeze(H(1,:,:)))));
    [DIM1ImageNoisyAfterHk,DIM2ImageNoisyAfterHk] = size(ImageNoisyAfterHk); 
    inputMatrix = zeros(K,DIM1ImageNoisyAfterHk*DIM2ImageNoisyAfterHk);
    for k=1:K
        ImageNoisyAfterHk = double(conv2(ImageNoisy,double(squeeze(H(k,:,:)))));
        [DIM1ImageNoisyAfterHk,DIM2ImageNoisyAfterHk] = size(ImageNoisyAfterHk);
        inputMatrix(k,:) = ImageNoisyAfterHk(:).';
    end
    inputMatrix = inputMatrix./normalized;
    inputMatrix = (netDeNoise.Layers(2).Weights)*inputMatrix + repmat((netDeNoise.Layers(2).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (netDeNoise.Layers(4).Weights)*inputMatrix + repmat((netDeNoise.Layers(4).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (netDeNoise.Layers(6).Weights)*inputMatrix + repmat((netDeNoise.Layers(6).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (netDeNoise.Layers(8).Weights)*inputMatrix + repmat((netDeNoise.Layers(8).Bias), 1, length(inputMatrix));
    inputMatrix = (1./(1+exp(-inputMatrix)));
    inputMatrix = (netDeNoise.Layers(10).Weights)*inputMatrix + repmat((netDeNoise.Layers(10).Bias), 1, length(inputMatrix));
    inputMatrix = inputMatrix.*normalized;		
    for k=1:K
        ImageNoisyAfterHkAfterNet = inputMatrix(k,:);
        ImageNoisyAfterHkAfterNet = reshape(ImageNoisyAfterHkAfterNet,DIM1ImageNoisyAfterHk,DIM2ImageNoisyAfterHk);
        ImageRepair = ImageRepair + double(conv2(ImageNoisyAfterHkAfterNet,double(squeeze(H_trans(k,:,:)))));
    end
    ImageRepair = uint8(ImageRepair(N:end-N+1,N:end-N+1));
end

