function[is_outlier] = detect_outliers(X,mu,C,Threshold_outlier)
[Nbp,Ndim] = size(X);
inlier  = find(~isnan(X(:,1)));
Ninlier = numel(inlier);
stop_search = false;
while(~stop_search)
    %generate full list of body point subsets
    list_bp = nchoosek(inlier, Ninlier);
    Nlist = size(list_bp,1);
    %initialise square mahalanobis distance
    dist = zeros(1,Nlist);
    for n = 1:Nlist
        %get subset of body points, mean and covariance
        Xsub = X(list_bp(n,:),:); 
        mean_pose_sub = mu(list_bp(n,:),:);
        indCsub = [list_bp(n,:) list_bp(n,:)+Nbp list_bp(n,:)+2*Nbp]; 
        Csub_inv = C(indCsub, indCsub)^-1;
        %re-align pose for the subset
        [~, Xsub] = procrustes(mean_pose_sub, Xsub, 'Scaling', false, 'Reflection', false);
        %calculate squared mahalanobis distance
        dist(n) = (Xsub(:)-mean_pose_sub(:))'*Csub_inv*(Xsub(:)-mean_pose_sub(:));
    end
    %find minimum distance
    [minC, indmin] = min(dist);
    %label body points associated with minC as inliers
    inlier = list_bp(indmin,:);
    %compare with threshold
    
    TH = 3*chi2inv(Threshold_outlier,Ndim*Ninlier);  %---->change it 
    if minC<TH
        stop_search = true;
    elseif Ninlier<0.5*Nbp
        inlier = [];
        stop_search = true;
    else
        Ninlier = Ninlier-1;
    end 
end
is_outlier = true(Nbp,Ndim); 
is_outlier(inlier,:) = false;

