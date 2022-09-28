function Mah_Distance_pPCA=MahDistance(Data,mean_data,Cov_pPCA)

%%%Mahalanobis distance function
maha =@ (x,mean,Cov) sqrt((x-mean)'*(Cov^-1)*(x-mean));


for k=1:size(Data,2)
x= Data(:,k);   
Mah_Distance_pPCA(k)=maha(x,mean_data,Cov_pPCA);
end

end