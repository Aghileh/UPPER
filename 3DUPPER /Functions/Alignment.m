function [RawData3D]=Alignment(RawData3D,Ref_Pose3D)
[Np, Ndim, Num_samples]=size(RawData3D);
for n = 1:Num_samples
    Y_sample = squeeze(RawData3D(:,:,n));
    indnum = find(~isnan(Y_sample(:,1)));
    if numel(indnum) > max(0.5*Np, Ndim)
        [~, ~, Trans] = procrustes(Ref_Pose3D(indnum,:), Y_sample(indnum,:), 'Scaling', false,'Reflection',false);
        Y_sample = Trans.b*Y_sample*Trans.T + repmat(Trans.c(1,:),Np,1);
        RawData3D(:,:,n) = Y_sample;
    else
        RawData3D(:,:,n) = NaN;
    end
end
