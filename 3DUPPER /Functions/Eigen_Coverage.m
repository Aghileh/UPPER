
function Eigen_Coverage(RawData3D_full,Threshold_Eigen,Threshold_Outliers,graph)
[Np, Framedim,Ns]=size(RawData3D_full);

Ratio=125/Ns;

ch=[64,32,16,8,4,2,1];

for j=1:length(ch)
for i=1:5
%%%%%%%%%%%%%%%%%%%%%%%%%% sampling from data

Nsample=round(Ns*ch(j)*Ratio);
Rand_ind = randsample(Ns,Nsample);
RawData3D=RawData3D_full(:,:,Rand_ind );

mean_pose_3D = Estimate_mean_RANSAC(RawData3D, false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%alignment
Data_3D_align = Alignment(RawData3D, mean_pose_3D);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Filling data with KNN=5
K = 5;
Data_3D_KNN = Near_NaN_Euclidian(Data_3D_align, K, false);
Data_3D_KNN_P=Data_3D_KNN ;
Data_KNN_reshape=reshape(Data_3D_KNN, Np*Framedim,Nsample);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PPCA
[mean_pose_ppca, ~, Cov_pPCA, eignValues, eignVectors] = pPCA(Data_3D_KNN,Threshold_Eigen,false);

mean_pose_3D_ppca = reshape(mean_pose_ppca,[Np,Framedim]);

for k=1:length(eignValues)
    error_project(k)=sum(eignValues(1:k))/sum(eignValues);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect & remove outliers
is_outlier = false(Np, Framedim,Nsample);
for n = 1:Nsample
    is_outlier(:,:,n) = detect_outliers(squeeze(Data_3D_KNN(:,:,n)), mean_pose_3D, Cov_pPCA, Threshold_Outliers);  
end
Data_3D_KNN(is_outlier==1) = NaN;
Data_2D_KNN=reshape(Data_3D_KNN,Np*Framedim,Nsample);
Outlier_percent_fram=(length(find(sum(isnan(Data_2D_KNN))))/(Nsample))*100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%re-align data without outliers (very important!!!) 
Data_3D_alignment_WO = Alignment(Data_3D_KNN, mean_pose_3D);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%reconstruction
Data_3D_alignment_WO_reshape = reshape(Data_3D_alignment_WO, Np*Framedim,Nsample);
Data_reconstruct = Theoritical_Estimate_Correction(Data_3D_alignment_WO_reshape,mean_pose_ppca,Cov_pPCA);
Data_reconstruct_3D = reshape(Data_reconstruct, Np, Framedim, Nsample);

% Data_reconstruct_3D_align=Alignment(Data_reconstruct_3D, mean_pose_3D);
% 
% Data_reconstruct_2D_align=reshape(Data_reconstruct_3D_align,Np*Framedim,Nsample);
% [mean_reconstructed_ppca, NumDimcut_r, Cov_pPCA_reconstructed, eignValues_reconstructed, eignVectors_reconstructed] = pPCA_Ordinary(Data_reconstruct_2D_align,false);

mean_poses{j,i}=mean_pose_3D;
%Eigen{j,i}= eignVectors;
%eignVectors_r{j,i}=eignVectors_reconstructed;
Outlier{j,i}=Outlier_percent_fram;
Comulative_eigen{j,i}=error_project;
Data_reconst{j,i}=Data_reconstruct_3D;
Data_Raw{j,i}=RawData3D;
j
i
end
end
save('Stat_UPPEER_Eigen_Coverage')

if graph
    
%%% %eigenvalues
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

%%%%
% check the alignment of all reconstructed data to  one pose then check the
% eigen vectors.. Data_reconst

for ll=1:length(ch)
for kk=1:5
for n=1:size(Data_reconst{ll,kk},3)
    
Data_reconst_aligen{ll,kk}(:,:,n)=Alignment(Data_reconst{ll,kk}(:,:,n),mean_poses{1,1}(:,:,1));

end
end
end

%%%%
ND=Np*Framedim;
for ll=1:length(ch)
for kk=1:5
 Data_reconst_aligen_2d{ll,kk}=reshape(Data_reconst_aligen{ll,kk},[ND,size(Data_reconst{ll,kk},3)]);
end
end

%%%%%
 
for kk=1:5
[~, ~, ~, eignValues_rf1(:,:,kk), eignVectors_rf1(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{1,kk},false);
[~, ~, ~, eignValues_rf2(:,:,kk), eignVectors_rf2(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{2,kk},false);
[~, ~, ~, eignValues_rf3(:,:,kk), eignVectors_rf3(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{3,kk},false);
[~, ~, ~, eignValues_rf4(:,:,kk), eignVectors_rf4(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{4,kk},false);
[~, ~, ~, eignValues_rf5(:,:,kk), eignVectors_rf5(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{5,kk},false);
[~, ~, ~, eignValues_rf6(:,:,kk), eignVectors_rf6(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{6,kk},false);
[~, ~, ~, eignValues_rf7(:,:,kk), eignVectors_rf7(:,:,kk)] = pPCA_Ordinary(Data_reconst_aligen_2d{7,kk},false);

end

%%%%%
for l=1:5
for    m=1:5
    G1_1(l,m)=abs(eignVectors_rf1(:,1,l)'*eignVectors_rf1(:,1,m));
    G2_1(l,m)=abs(eignVectors_rf2(:,1,l)'*eignVectors_rf2(:,1,m));
    G3_1(l,m)=abs(eignVectors_rf3(:,1,l)'*eignVectors_rf3(:,1,m));
    G4_1(l,m)=abs(eignVectors_rf4(:,1,l)'*eignVectors_rf4(:,1,m));
    G5_1(l,m)=abs(eignVectors_rf5(:,1,l)'*eignVectors_rf5(:,1,m));
    G6_1(l,m)=abs(eignVectors_rf6(:,1,l)'*eignVectors_rf6(:,1,m));
    G7_1(l,m)=abs(eignVectors_rf7(:,1,l)'*eignVectors_rf7(:,1,m));
    
end
end
 Aaa=[std(G1_1(:)), std(G2_1(:)),std(G3_1(:)),std(G4_1(:)),std(G5_1(:)),std(G6_1(:)),std(G7_1(:))]
 Bbb=[mean(G1_1(:)), mean(G2_1(:)),mean(G3_1(:)),mean(G4_1(:)),mean(G5_1(:)),mean(G6_1(:)),mean(G7_1(:))]

% figure
% errorbar(Bbb,Aaa)
% xlim([-0.25,8])
% ylim([0.9,1.1])
% xticks(1:1:7)
% xticklabels({'8000','4000','2000','1000','500','250','125'})
% xlabel('Number of Sample')
% ylabel('Dot procut of first Eigenvectors')

%%%
for l=1:5
for    m=1:5
    G1_2(l,m)=abs(eignVectors_rf1(:,2,l)'*eignVectors_rf1(:,2,m));
    G2_2(l,m)=abs(eignVectors_rf2(:,2,l)'*eignVectors_rf2(:,2,m));
    G3_2(l,m)=abs(eignVectors_rf3(:,2,l)'*eignVectors_rf3(:,2,m));
    G4_2(l,m)=abs(eignVectors_rf4(:,2,l)'*eignVectors_rf4(:,2,m));
    G5_2(l,m)=abs(eignVectors_rf5(:,2,l)'*eignVectors_rf5(:,2,m));
    G6_2(l,m)=abs(eignVectors_rf6(:,2,l)'*eignVectors_rf6(:,2,m));
    G7_2(l,m)=abs(eignVectors_rf7(:,2,l)'*eignVectors_rf7(:,2,m));
    
end
end

 Aaa2=[std(G1_2(:)), std(G2_2(:)),std(G3_2(:)),std(G4_2(:)),std(G5_2(:)),std(G6_2(:)),std(G7_2(:))]
 Bbb2=[mean(G1_2(:)), mean(G2_2(:)),mean(G3_2(:)),mean(G4_2(:)),mean(G5_2(:)),mean(G6_2(:)),mean(G7_2(:))]
%%%%
% figure
% errorbar(Bbb2,Aaa2)
% xlim([-0.25,8])
% ylim([0.1,1.1])
% xticks(1:1:7)
% xticklabels({'8000','4000','2000','1000','500','250','125'})
% xlabel('Number of Sample')
% ylabel('Dot procut of Second Eigenvectors')
%%%
for l=1:5
for    m=1:5
    G1_3(l,m)=abs(eignVectors_rf1(:,3,l)'*eignVectors_rf1(:,3,m));
    G2_3(l,m)=abs(eignVectors_rf2(:,3,l)'*eignVectors_rf2(:,3,m));
    G3_3(l,m)=abs(eignVectors_rf3(:,3,l)'*eignVectors_rf3(:,3,m));
    G4_3(l,m)=abs(eignVectors_rf4(:,3,l)'*eignVectors_rf4(:,3,m));
    G5_3(l,m)=abs(eignVectors_rf5(:,3,l)'*eignVectors_rf5(:,3,m));
    G6_3(l,m)=abs(eignVectors_rf6(:,3,l)'*eignVectors_rf6(:,3,m));
    G7_3(l,m)=abs(eignVectors_rf7(:,3,l)'*eignVectors_rf7(:,3,m));
    
end
end

 Aaa3=[std(G1_3(:)), std(G2_3(:)),std(G3_3(:)),std(G4_3(:)),std(G5_3(:)),std(G6_3(:)),std(G7_3(:))]
 Bbb3=[mean(G1_3(:)), mean(G2_3(:)),mean(G3_3(:)),mean(G4_3(:)),mean(G5_3(:)),mean(G6_3(:)),mean(G7_3(:))]
% %%
% figure
% errorbar(Bbb3,Aaa3)
% xlim([-0.25,8])
% ylim([0.1,1.1])
% xticks(1:1:7)
% xticklabels({'8000','4000','2000','1000','500','250','125'})
% xlabel('Number of Sample')
% ylabel('Dot procut of Third Eigenvectors')
%%%
for l=1:5
for    m=1:5
    G1_4(l,m)=abs(eignVectors_rf1(:,4,l)'*eignVectors_rf1(:,4,m));
    G2_4(l,m)=abs(eignVectors_rf2(:,4,l)'*eignVectors_rf2(:,4,m));
    G3_4(l,m)=abs(eignVectors_rf3(:,4,l)'*eignVectors_rf3(:,4,m));
    G4_4(l,m)=abs(eignVectors_rf4(:,4,l)'*eignVectors_rf4(:,4,m));
    G5_4(l,m)=abs(eignVectors_rf5(:,4,l)'*eignVectors_rf5(:,4,m));
    G6_4(l,m)=abs(eignVectors_rf6(:,4,l)'*eignVectors_rf6(:,4,m));
    G7_4(l,m)=abs(eignVectors_rf7(:,4,l)'*eignVectors_rf7(:,4,m));
    
end
end

 Aaa4=[std(G1_4(:)), std(G2_4(:)),std(G3_4(:)),std(G4_4(:)),std(G5_4(:)),std(G6_4(:)),std(G7_4(:))]
 Bbb4=[mean(G1_4(:)), mean(G2_4(:)),mean(G3_4(:)),mean(G4_4(:)),mean(G5_4(:)),mean(G6_4(:)),mean(G7_4(:))]
%%%
% figure
% errorbar(Bbb4,Aaa4)
% xlim([-0.25,8])
% ylim([0.1,1.1])
% xticks(1:1:7)
% xticklabels({'8000','4000','2000','1000','500','250','125'})
% xlabel('Number of Sample')
% ylabel('Dot procut of fourth Eigenvectors')
%%%

for l=1:5
for    m=1:5
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
%%%
% figure
% errorbar(Bbb5,Aaa5)
% xlim([-0.25,8])
% ylim([0.1,1.1])
% xticks(1:1:7)
% xticklabels({'8000','4000','2000','1000','500','250','125'})
% xlabel('Number of Sample')
% ylabel('Dot procut of fifth Eigenvectors')

%%%
figure
errorbar(Bbb,Aaa,'Color','blue','LineWidth',1)
hold on
errorbar(Bbb2,Aaa2,'Color','red','LineWidth',1)
%hold on
errorbar(Bbb3,Aaa3,'Color','green','LineWidth',1)
hold on
%errorbar(Bbb4,Aaa4,'Color','cyan','LineWidth',1)
%hold on
%errorbar(Bbb5,Aaa5,'Color','red','LineWidth',1)
xlim([-0.25,8])
ylim([0.1,1.1])
xticks(1:1:7)
legend('Eigenvector 1','Eigenvector 2','Eigenvector 3')
xticklabels({'8000','4000','2000','1000','500','250','125'})
xlabel('Number of Sample')
ylabel('Dot procut Eigenvectors')   
end  
end


