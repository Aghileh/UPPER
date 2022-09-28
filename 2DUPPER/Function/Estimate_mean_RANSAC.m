function mean_sample_3D=Estimate_mean_RANSAC(X_3D,graph)
%Riccardo Suggestion for alignment (Riccardo modified the 200421 code in
%Github)

%%% change the alignment for 2D 14 Dec  %<---- Aghileh Change
[Np,Ndim,Ns]=size(X_3D);

for j=1: Ns
    E=[];
    for i=1:Np
        Y=[X_3D(i,1,j),X_3D(i,2,j)];
        E=[E,Y];
    end
    X(:,j)=E';
end

%X=reshape(X_3D,[Np*Ndim,Ns]);%%it does not good for 2D
ratioSample=.25;
Nsample=round(Ns*ratioSample);
index_Non_Nan=find(sum(isnan(X))==0);

%Tune TH value based on 25th quantile of paiwise distances
dist = []; Nrand = 50;
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
    %%% change the alignment for 2D 14 Dec  %<---- Aghileh Change
    D=[];
    for i=1:Np
        Y=[mean_sample_3D(i,1,1),mean_sample_3D(i,2,1)];
        D=[D,Y];
    end
    mean_sample(:,1)=D';
    
    %   mean_sample=reshape(mean_sample_3D,[Np*Ndim,1]);%%it does not good for 2D
    %%%% Select sample
    Rand_ind_sample=randsample(Ns,Nsample);
    dataSample=X_3D(:,:,Rand_ind_sample);
    %%%% aligne
    Sample_Align_3D=Alignment(dataSample,mean_sample_3D);
    
    %%% change the alignment for 2D 14 Dec  %<---- Aghileh Change
    for KK=1: length(Sample_Align_3D)
        B=[];
        for i=1:Np
            Y2=[Sample_Align_3D(i,1,KK),Sample_Align_3D(i,2,KK)];
            B=[B,Y2];
        end
        Sample_Align(:,KK)=B';
    end
    
    
    %Sample_Align=reshape(Sample_Align_3D,[Np*Ndim,Nsample]);%%it does not good for 2D
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