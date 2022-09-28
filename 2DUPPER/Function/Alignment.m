function [RawData2D]=Alignment(RawData2D,Ref_Pose2D)
[Np, Ndim, Num_samples]=size(RawData2D);
for n = 1:Num_samples
    Y_sample = squeeze(RawData2D(:,:,n));
    indnum = find(~isnan(Y_sample(:,1)));
    if numel(indnum) > max(0.5*Np, Ndim)
        [~, ~, Trans] = procrustes(Ref_Pose2D(indnum,:), Y_sample(indnum,:), 'Scaling', false,'Reflection',false);
        Y_sample = Trans.b*Y_sample*Trans.T + repmat(Trans.c(1,:),Np,1);
        RawData2D(:,:,n) = Y_sample;
    else
        RawData2D(:,:,n) = NaN;
    end
end
