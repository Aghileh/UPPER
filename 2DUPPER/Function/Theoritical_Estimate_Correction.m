function Data_Estimate_L=Theoritical_Estimate_Correction(Data,mean_data,Cov_pPCA)
Data_Estimate_L=Data;
for ii=1:size(Data,2)
    Y_sample=Data(:,ii);
    if sum(isnan(Y_sample))>0
        Index_nan=find(isnan(Y_sample)==1);
        Index_non_nan=find(isnan(Y_sample)==0);
        Y_sample_E2=Y_sample;
        Y_sample_E2(Index_nan)=[];
        mean_E2=mean_data;
        mean_E1=mean_data(Index_nan,:);
        mean_E2(Index_nan)=[];
        %
        Cov_pPCA_E22=Cov_pPCA;
        Cov_pPCA_E22(Index_nan,:)=[];
        Cov_pPCA_E22(:,Index_nan)=[];
        %
        Cov_pPCA_E12=Cov_pPCA(Index_nan,Index_non_nan);
        Mu_Estimate= mean_E1+Cov_pPCA_E12*pinv(Cov_pPCA_E22)*(Y_sample_E2-mean_E2);
        Y_sample(Index_nan,:)=Mu_Estimate;
        Data_Estimate_L(:,ii)=Y_sample;
    end
end   