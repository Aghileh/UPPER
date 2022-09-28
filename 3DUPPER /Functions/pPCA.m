function [mean_data NumDimcut Cov_pPCA eignValues eignVectors]=pPCA(Data_3D,Threshold_Eigen,graph)
%ref
%https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.934.5867&rep=rep1&type=pdf

Ns=size(Data_3D,3);
Np=size(Data_3D,1);

Data=reshape(Data_3D,[Np*3,Ns]);

NP=size(Data,1);

mean_data = nanmean(Data,2); % transpose Posev to calculate mean from all frame for x,y,z all 11 poses and then again transpose.
mean_data_3D = reshape(mean_data,Np,3);

Data0=Data-mean_data*ones(1,Ns); % pose without mean
[Cov_Data0,~,~,outliers] = robustcov(Data0','Method','ogk','NumOGKIterations',2);%estimate of the robust Minimum Covariance Determinant (MCD)

%%%% PCA
[eignVectors,eignValues] = eig(Cov_Data0,'vector');
[eignValues,indsort] = sort(eignValues,'descend');
eignVectors = eignVectors(:,indsort);
%construct the optimal hyperplane with the error projection
for k=1:length(eignValues)
    error_project(k)=sum(eignValues(1:k))/sum(eignValues);
end

r0=find(error_project>Threshold_Eigen); % obtain cut off eigenvector
NumDimcut=r0(1);
sigma2=mean(eignValues(r0(1)+1:end)); % averaging from remaining eigenvalues


%%% pPCA
diagonal_vector=[eignValues(1:r0(1))',sigma2*ones(1,NP-r0(1))]; %% defining Sigma^2 
Cov_pPCA=eignVectors*(diag(diagonal_vector))*eignVectors';

if graph
    %
%     figure 
%     pcolor(Cov_Data0-Cov_pPCA)
%     colorbar
%     title('Cov-Original - Cov-pPCA')
    %
    figure
    plot(error_project,'LineWidth',3)
    xlabel('#Eigenvalues')
    ylabel('Variance Expl')
    ylim([0. 1.01])
    xticks(1:1:length(eignValues))
    xline(r0(1),'--g','LineWidth',2)
end