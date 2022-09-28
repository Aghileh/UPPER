%Evaluation of the 2D data
clear all; close all 
%%
Reconst_method=load('Result_040222_95_percent')

mean_pose_all=Reconst_method.mean_pose_3D;
Data_r=Reconst_method.Data_r;

%%
Ns=size(Data_r,2);
NN=2;
NPP=size(Data_r,1)/NN;
RawData2D_2=reshape(Data_r,[NN,NPP,Ns]); %reshape in other way and transpose it
RawData2D_i=[];
for i=1:Ns
  RawData2D_i(:,:,i)= RawData2D_2(:,:,i)' ;
end
RawData2D_full=RawData2D_i;
[Np Dim Nss]=size(RawData2D_full);


RawData2D_primary=RawData2D_i;
RawData2D_i(9:11,:,:)=[];
%plot2D_pose(RawData2D(:,:,2),false)
[ Np Dim Ns]=size(RawData2D_i);
%%

ch=[0.133333,0.066666,0.033333,0.01666,0.008333,0.004167,0.002084];
for K=1:length(ch)  
for L=1:10
%%%%%%%%%%%%%%%%%%%%%%%%%% sampling from data
Nsample=round(Nss*ch(K));
Rand_ind = randsample(Nss,Nsample);
RawData2D=RawData2D_i(:,:,Rand_ind );
%RawData3D=RawData3D_full;
[Np Dim Ns]=size(RawData2D);
%%%trian set
%random selection of the train data and estimation of model on train data
%%%%%%%%%%%
Ratio=0.7;
N=Ratio*Ns;
Rand_train=randsample(Ns, N);
D_train=RawData2D(:,:,Rand_train);
%%%%%%%%%%%
mean_pose_3D = Estimate_mean_RANSAC(D_train, false);
%%%%%%%%%%%
Data_aligne=Alignment(D_train,mean_pose_3D);
%%%%%%%%%%%
J = 5;
Data_KNN_2D = Near_NaN_Euclidian(Data_aligne, J,false);
Data_KNN_P=Data_KNN_2D;
%%%%%%%%%%%
[mean_pose_ppca, ~, Cov_pPCA, eignValues, eignVectors] = pPCA(Data_KNN_2D,false);
mean_pose_2D_ppca = reshape(mean_pose_ppca,[Dim,Np,1])';

for f=1:length(eignValues)
    error_project(f)=sum(eignValues(1:f))/sum(eignValues);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%test set
%detect & remove outliers in all data ----> all data not KNN
Data_test=RawData2D;
is_outlier = false(Np,Dim,Ns);
for n = 1:Ns
    is_outlier(:,:,n) = detect_outliers(squeeze(Data_test(:,:,n)), mean_pose_2D_ppca, Cov_pPCA); 
end
Data_test(is_outlier==1) = NaN;
Outlier_percent_fram=(length(find(sum(sum(isnan(Data_test)))))/(Ns))*100;

%re-align data without outliers (very important!!!) 
Data_3D_alignment_WO = Alignment(Data_test, mean_pose_3D);
Data_alignment_WO_2D=[];  %reshape
for j=1: length(Data_3D_alignment_WO)
    D=[];
    for i=1:Np
        Y=[Data_3D_alignment_WO(i,1,j),Data_3D_alignment_WO(i,2,j)];
        D=[D,Y];
    end
    Data_alignment_WO_2D(:,j)=D';
end
Data_reconstruct = Theoritical_Estimate_Correction(Data_alignment_WO_2D,mean_pose_ppca,Cov_pPCA);
%%%
Data_reconstruct_2=reshape(Data_reconstruct,[Dim,Np,length(Data_reconstruct)]); %reshape in other way and transpose it
Data_reconstruct_3D=[];
for v=1:length(Data_reconstruct_2)
  Data_reconstruct_3D(:,:,v)= Data_reconstruct_2(:,:,v)' ;
end
%---->ahould aligne to its mean pose or all ali=ligne to one mean pose
%Data_reconstruct_3D_align=Alignment(Data_reconstruct_3D, mean_pose_3D);
Data_reconstruct_3D_align=Alignment(Data_reconstruct_3D, mean_pose_all);

Data_reconstruct_2D_align=[];
for m=1:length(Data_reconstruct_2)
    F=[];
    for i=1:Np
        Y=[Data_reconstruct_3D_align(i,1,m),Data_reconstruct_3D_align(i,2,m)];
        F=[F,Y];
    end
    Data_reconstruct_2D_align(:,m)=F';
end

[mean_reconstructed_ppca, NumDimcut_r, Cov_pPCA_reconstructed, eignValues_reconstructed, eignVectors_reconstructed] = pPCA_Ordinary(Data_reconstruct_2D_align,false);

mean_poses{K,L}=mean_pose_3D;
Eigen{K,L}= eignVectors;
eignVectors_r{K,L}=eignVectors_reconstructed;
Outlier{K,L}=Outlier_percent_fram;
Comulative_eigen{K,L}=error_project;
Data_reconst{K,L}=Data_reconstruct_3D;
Data_Raw{K,L}=RawData2D;
Data_train{K,L}=D_train;
K
L

end
end

%%
figure 
for i=1:35
    hold(subplot(7,5,i), 'on');
for ll=1:length(ch)
for kk=1:5
    subplot(7,5,i)
    plot(Comulative_eigen{ll,kk}(:,:))
    
    
end
end
end

for ll=1:length(ch)
for kk=1:10
for n=1:size(Data_reconst{ll,kk},3)
    
Data_reconst_aligen{ll,kk}(:,:,n)=Alignment(Data_reconst{ll,kk}(:,:,n),mean_poses{1,1}(:,:,1));

end
end
end

for ll=1:length(ch)
for kk=1:10
Data_reconst_aligen_2d{ll,kk}=[];  

for g=1:size(Data_reconst{ll,kk},3)
    R=[];
    for i=1:Np
        Y=[Data_reconst_aligen{ll,kk}(i,1,g),Data_reconst_aligen{ll,kk}(i,2,g)];
        R=[R,Y];
    end
    Data_reconst_aligen_2d{ll,kk}(:,g)=R';
end    
end
end

for kk=1:10
[~, ~, ~, eignValues_rf1(:,:,kk), eignVectors_rf1(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{1,kk},false);
[~, ~, ~, eignValues_rf2(:,:,kk), eignVectors_rf2(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{2,kk},false);
[~, ~, ~, eignValues_rf3(:,:,kk), eignVectors_rf3(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{3,kk},false);
[~, ~, ~, eignValues_rf4(:,:,kk), eignVectors_rf4(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{4,kk},false);
[~, ~, ~, eignValues_rf5(:,:,kk), eignVectors_rf5(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{5,kk},false);
[~, ~, ~, eignValues_rf6(:,:,kk), eignVectors_rf6(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{6,kk},false);
[~, ~, ~, eignValues_rf7(:,:,kk), eignVectors_rf7(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{7,kk},false);

end

for l=1:10
for    m=1:10
    G1_1(l,m)=abs(eignVectors_rf1(:,1,l)'*eignVectors_rf1(:,1,m));
    G2_1(l,m)=abs(eignVectors_rf2(:,1,l)'*eignVectors_rf2(:,1,m));
    G3_1(l,m)=abs(eignVectors_rf3(:,1,l)'*eignVectors_rf3(:,1,m));
    G4_1(l,m)=abs(eignVectors_rf4(:,1,l)'*eignVectors_rf4(:,1,m));
    G5_1(l,m)=abs(eignVectors_rf5(:,1,l)'*eignVectors_rf5(:,1,m));
    G6_1(l,m)=abs(eignVectors_rf6(:,1,l)'*eignVectors_rf6(:,1,m));
    G7_1(l,m)=abs(eignVectors_rf7(:,1,l)'*eignVectors_rf7(:,1,m));
    
end
end
 Aaa=[std(G1_1(:)), std(G2_1(:)),std(G3_1(:)),std(G4_1(:)),std(G5_1(:)),std(G6_1(:)),std(G7_1(:))];
 Bbb=[mean(G1_1(:)), mean(G2_1(:)),mean(G3_1(:)),mean(G4_1(:)),mean(G5_1(:)),mean(G6_1(:)),mean(G7_1(:))];

for l=1:10
for    m=1:10
    G1_2(l,m)=abs(eignVectors_rf1(:,2,l)'*eignVectors_rf1(:,2,m));
    G2_2(l,m)=abs(eignVectors_rf2(:,2,l)'*eignVectors_rf2(:,2,m));
    G3_2(l,m)=abs(eignVectors_rf3(:,2,l)'*eignVectors_rf3(:,2,m));
    G4_2(l,m)=abs(eignVectors_rf4(:,2,l)'*eignVectors_rf4(:,2,m));
    G5_2(l,m)=abs(eignVectors_rf5(:,2,l)'*eignVectors_rf5(:,2,m));
    G6_2(l,m)=abs(eignVectors_rf6(:,2,l)'*eignVectors_rf6(:,2,m));
    G7_2(l,m)=abs(eignVectors_rf7(:,2,l)'*eignVectors_rf7(:,2,m));
    
end
end

 Aaa2=[std(G1_2(:)), std(G2_2(:)),std(G3_2(:)),std(G4_2(:)),std(G5_2(:)),std(G6_2(:)),std(G7_2(:))];
 Bbb2=[mean(G1_2(:)), mean(G2_2(:)),mean(G3_2(:)),mean(G4_2(:)),mean(G5_2(:)),mean(G6_2(:)),mean(G7_2(:))];

for l=1:10
for    m=1:10
    G1_3(l,m)=abs(eignVectors_rf1(:,3,l)'*eignVectors_rf1(:,3,m));
    G2_3(l,m)=abs(eignVectors_rf2(:,3,l)'*eignVectors_rf2(:,3,m));
    G3_3(l,m)=abs(eignVectors_rf3(:,3,l)'*eignVectors_rf3(:,3,m));
    G4_3(l,m)=abs(eignVectors_rf4(:,3,l)'*eignVectors_rf4(:,3,m));
    G5_3(l,m)=abs(eignVectors_rf5(:,3,l)'*eignVectors_rf5(:,3,m));
    G6_3(l,m)=abs(eignVectors_rf6(:,3,l)'*eignVectors_rf6(:,3,m));
    G7_3(l,m)=abs(eignVectors_rf7(:,3,l)'*eignVectors_rf7(:,3,m));
    
end
end

 Aaa3=[std(G1_3(:)), std(G2_3(:)),std(G3_3(:)),std(G4_3(:)),std(G5_3(:)),std(G6_3(:)),std(G7_3(:))];
 Bbb3=[mean(G1_3(:)), mean(G2_3(:)),mean(G3_3(:)),mean(G4_3(:)),mean(G5_3(:)),mean(G6_3(:)),mean(G7_3(:))];

for l=1:10
for    m=1:10
    G1_4(l,m)=abs(eignVectors_rf1(:,4,l)'*eignVectors_rf1(:,4,m));
    G2_4(l,m)=abs(eignVectors_rf2(:,4,l)'*eignVectors_rf2(:,4,m));
    G3_4(l,m)=abs(eignVectors_rf3(:,4,l)'*eignVectors_rf3(:,4,m));
    G4_4(l,m)=abs(eignVectors_rf4(:,4,l)'*eignVectors_rf4(:,4,m));
    G5_4(l,m)=abs(eignVectors_rf5(:,4,l)'*eignVectors_rf5(:,4,m));
    G6_4(l,m)=abs(eignVectors_rf6(:,4,l)'*eignVectors_rf6(:,4,m));
    G7_4(l,m)=abs(eignVectors_rf7(:,4,l)'*eignVectors_rf7(:,4,m));
    
end
end

 Aaa4=[std(G1_4(:)), std(G2_4(:)),std(G3_4(:)),std(G4_4(:)),std(G5_4(:)),std(G6_4(:)),std(G7_4(:))];
 Bbb4=[mean(G1_4(:)), mean(G2_4(:)),mean(G3_4(:)),mean(G4_4(:)),mean(G5_4(:)),mean(G6_4(:)),mean(G7_4(:))];

for l=1:10
for    m=1:10
    G1_5(l,m)=abs(eignVectors_rf1(:,5,l)'*eignVectors_rf1(:,5,m));
    G2_5(l,m)=abs(eignVectors_rf2(:,5,l)'*eignVectors_rf2(:,5,m));
    G3_5(l,m)=abs(eignVectors_rf3(:,5,l)'*eignVectors_rf3(:,5,m));
    G4_5(l,m)=abs(eignVectors_rf4(:,5,l)'*eignVectors_rf4(:,5,m));
    G5_5(l,m)=abs(eignVectors_rf5(:,5,l)'*eignVectors_rf5(:,5,m));
    G6_5(l,m)=abs(eignVectors_rf6(:,5,l)'*eignVectors_rf6(:,5,m));
    G7_5(l,m)=abs(eignVectors_rf7(:,5,l)'*eignVectors_rf7(:,5,m));
    
end
end

 Aaa5=[std(G1_5(:)), std(G2_5(:)),std(G3_5(:)),std(G4_5(:)),std(G5_5(:)),std(G6_5(:)),std(G7_5(:))]
 Bbb5=[mean(G1_5(:)), mean(G2_5(:)),mean(G3_5(:)),mean(G4_5(:)),mean(G5_5(:)),mean(G6_5(:)),mean(G7_5(:))]

%%%%%%
figure
errorbar(Bbb,Aaa,'Color', [102, 0, 102]/255,'LineWidth',1)
hold on
errorbar(Bbb2,Aaa2,'Color',[255, 0, 102]/255,'LineWidth',1)
%hold on
errorbar(Bbb3,Aaa3,'Color',[46, 184, 184]/255,'LineWidth',1)
hold on
errorbar(Bbb4,Aaa4,'Color',[0, 128, 43]/255,'LineWidth',1)
hold on
errorbar(Bbb5,Aaa5,'Color',[255, 170, 0]/255,'LineWidth',1)
xlim([-0.25,8])
ylim([0.1,1.1])
xticks(1:1:7)
legend('Eigenvector 1','Eigenvector 2','Eigenvector 3','Eigenvector 4','Eigenvector 5')
xticklabels({'8000','4000','2000','1000','500','250','125'})
xlabel('Number of Sample')
ylabel('Dot procut Eigenvectors')
%%
save('Stat_sampl_2D_Runing010322')

