clc; clear all, close all;
%%

%%% data preperation after DLC, it check low Liklihoods and put Nan instead
load('Maindata_2D.mat');
Data_p=Maindata;  
lik=[];
for i=1:11
li=Data_p(3*i,:);
lik=[lik,li];
end
index=find(lik(1,:)<0.8);
ratio_nan=length(index)/size(Data_p,2)
for ii=1:11
    NN2(ii)=3*ii ;  
end
Data_r=Data_p;
for jj=1:length(NN2)    
Ind= find(Data_r(NN2(jj),:)<0.8);
Data_r(NN2(jj)-1,Ind)=NaN;
Data_r(NN2(jj)-2,Ind)=NaN;
end 
Data_r(NN2,:)=[]; % final data clean from Likelihood and with Nan
Ns=size(Data_r,2);
NN=2;
NPP=size(Data_r,1)/NN;
RawData2D_2=reshape(Data_r,[NN,NPP,Ns]); 
RawData2D=[];
for i=1:Ns
      RawData2D(:,:,i)= RawData2D_2(:,:,i)' ;
end

RawData2D_primary=RawData2D;
RawData2D(9:11,:,:)=[];

[ Np Dim Ns]=size(RawData2D);
 %% 
%%%%%%
%%%trian set
%random selection of the train data and estimation of model on train data
Ratio=0.7;
N=Ratio*Ns;
Rand_train=randsample(Ns, N);
D_train=RawData2D(:,:,Rand_train); %% the data shuffled 
%%%
mean_pose_3D = Estimate_mean_RANSAC(D_train, false);
%%%
Data_aligne=Alignment(D_train,mean_pose_3D);
%%%
K = 5;
Data_KNN_2D = Near_NaN_Euclidian(Data_aligne, K, false);
Data_KNN_P=Data_KNN_2D;
%%%
[mean_pose_ppca, ~, Cov_pPCA, eignValues, eignVectors] = pPCA(Data_KNN_2D,true);
mean_pose_2D_ppca = reshape(mean_pose_ppca,[Dim,Np,1])';

%%
%test set
%detect & remove outliers in all data ----> all data not KNN
Data_test=RawData2D;
is_outlier = false(Np,Dim,Ns);
for n = 1:Ns
    is_outlier(:,:,n) = detect_outliers(squeeze(Data_test(:,:,n)), mean_pose_2D_ppca, Cov_pPCA); 
end
Data_test(is_outlier==1) = NaN;
Outlier_percent_fram=(length(find(sum(sum(isnan(Data_test)))))/(Ns))*100;

Data_3D_alignment_WO = Alignment(Data_test, mean_pose_3D);
Data_alignment_WO_2D=[];  %reshape
for j=1: Ns
    D=[];
    for i=1:Np
        Y=[Data_3D_alignment_WO(i,1,j),Data_3D_alignment_WO(i,2,j)];
        D=[D,Y];
    end
    Data_alignment_WO_2D(:,j)=D';
end
Data_reconstruct = Theoritical_Estimate_Correction(Data_alignment_WO_2D,mean_pose_ppca,Cov_pPCA);
%%%
%reshape in other way and transpose it
Data_reconstruct_2=reshape(Data_reconstruct,[Dim,Np,Ns]); 
for i=1:Ns
  Data_reconstruct_3D(:,:,i)= Data_reconstruct_2(:,:,i)' ;
end
%%
%%% back to original place
Data_reconstruct_3D_align=Alignment(Data_reconstruct_3D, mean_pose_3D);
for j=1:length(Data_reconstruct_3D)
    kk=find ((sum(isnan(RawData2D(:,:,j)),2))>1);
    Data_reconstruct=Data_reconstruct_3D_align(:,:,j);
    Dra_Raw=RawData2D(:,:,j);
    if isempty(kk) ==1;
        [~, ~, Trans1] = procrustes(Dra_Raw, Data_reconstruct, 'Scaling', false,'Reflection',false);
        Y_sample2 = Trans1.b*Data_reconstruct_3D_align(:,:,j)*Trans1.T + repmat(Trans1.c(1,:),Np,1);
        Reconstructed_data_final(:,:,j) = Y_sample2;
        

    else
        Data_reconstruct(kk,:,:)=[];
        Dra_Raw(kk,:,:)=[]; 
        [~, ~, Trans] = procrustes(Dra_Raw, Data_reconstruct, 'Scaling', false,'Reflection',false);
        Y_sample = Trans.b*Data_reconstruct_3D_align(:,:,j)*Trans.T + repmat(Trans.c(1,:),Np,1);
        Reconstructed_data_final(:,:,j) = Y_sample;
    end
    j
end
%%
save('Result_040222_95_percent')
