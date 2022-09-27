function [mean_data NumDimcut Cov_pPCA eignValues eignVectors]=pPCA_Ordinary(Data,figures)

NumberSample=size(Data,2);
NP=(size(Data,1));
mean_data = mean(Data,2); % transpose Posev to calculate mean from all frame for x,y,z all 11 poses and then again transpose.

Data0=Data-mean_data*ones(1,NumberSample); % pose without mean
Cov_Data0 = cov(Data0');

%%%% PCA
[eignVectors,eignValues] = eig(Cov_Data0,'vector');
[eignValues,indsort] = sort(eignValues,'descend');
eignVectors = eignVectors(:,indsort);
%construct the optimal hyperplane with the error projection
for k=1:length(eignValues)
    error_project(k)=sum(eignValues(1:k))/sum(eignValues);
end

r0=find(error_project>.9); % obtain cut off eigenvector
NumDimcut=r0(1);
sigma2=(sum(eignValues(r0(1):end))/(NP-r0(1))); % averaging from remained egien vector


%%% pPCA
diagonal_vector=[eignValues(1:r0(1))',sigma2*ones(1,NP-r0(1))]; %% defining Sigma^2 
Cov_pPCA=eignVectors*(diag(diagonal_vector))*eignVectors';

%Cov_pPCA=(1/NumberSample)*eignVectors*(diag(diagonal_vector))*eignVectors';

% figure 
% pcolor(Cov_Data0-Cov_pPCA)
% colorbar
% title('Diffrence of Original and Recounstructed Robust Minimum Covariance')
if figures
figure
plot(error_project,'LineWidth',3)
xlabel('Number of eigen value')
ylabel('Information')
%ylim([0.955 1.001])
xticks(1:1:length(eignValues))
xline(r0(1),'--g','LineWidth',2)
title('Information of eigen Vectors')
end