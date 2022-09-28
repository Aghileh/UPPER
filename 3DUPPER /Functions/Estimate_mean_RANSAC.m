function mean_sample_3D=Estimate_mean_RANSAC(X_3D,graph)
%Riccardo Suggestion for alignment (Riccardo modified the 200421 code in
%Github)

[Np,Ndim,Ns]=size(X_3D);
X=reshape(X_3D,[Np*3,Ns]);
ratioSample=.25;
Nsample=round(Ns*ratioSample);
index_Non_Nan=find(sum(isnan(X))==0);

%Tune TH value based on 25th quantile of paiwise distances
dist = []; Nrand = 30; 
Rand_ind = randsample(index_Non_Nan,Nrand);
for n = 1:Nrand
    temp = squeeze(X_3D(:,:,Rand_ind(n)));
    for m = n+1:Nrand
        temp1 = squeeze(X_3D(:,:,Rand_ind(m)));
        [~,temp1] = procrustes(temp, temp1,'Scaling',false,'Reflection',false);
        dist = [dist nanmean((temp(:)-temp1(:)).^2)];
    end
end
TH = quantile(dist,0.25);

%RANSAC
for ii=1:100
    %%% Select a random pose as estimate for mean
    %%% random nan should be in the loop  %<---- Aghileh Change
    Rand_ind_ref(ii)= randsample(index_Non_Nan,1);
    mean_sample_3D=X_3D(:,:,Rand_ind_ref(ii));
    mean_sample=reshape(mean_sample_3D,[Np*3,1]);
    %%%% Select sample
    Rand_ind_sample=randsample(Ns,Nsample);
    dataSample=X_3D(:,:,Rand_ind_sample);
    %%%% Align
    Sample_Align_3D=Alignment(dataSample,mean_sample_3D);
    Sample_Align=reshape(Sample_Align_3D,[Np*3,Nsample]);
    %%%% Squared Distance
    Diff=Sample_Align-repmat(mean_sample,1,Nsample);
    Dist2=nanmean(Diff.^2,1);
    %%% Count neighbours
    ind = find(Dist2<TH);
    NNeigh(ii) = numel(ind); 
    New_ref{ii} = nanmean(Sample_Align_3D(:,:,ind),3);
end
[~,p]=max(NNeigh);  %<---- Aghileh Change
mean_sample_3D=New_ref{p};

%%% figure
if graph
    figure
    plot(NNeigh)
    title('Scoring of mean-pose with Close Poses');
    ylabel('Close Poses');
    xlabel('Iteration');
end