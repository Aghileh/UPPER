function Dataout=Near_NaN_Euclidian(Data0,Number_K_near,graph)
% To test it:
% a = randn(4,3);
% b = repmat(a,1,1,10)+0.1*randn(4,3,10);
% b(1,:,10) = NaN; b(2,:,9) = NaN; b(1,:,1) = NaN; b(2,:,3) = NaN;

N=size(Data0,3);
Ndim=size(Data0,2);
Np=size(Data0,1);


Dataout=[];
for j=1:N
    D=[];
    for i=1:Np
        Y=[Data0(i,1,j),Data0(i,2,j)];
        D=[D,Y];
    end
    Data(:,j)=D';
end
    
Dataout= Data;
indexNaN=find(sum(isnan(Data))>0); % return nan index of data
for ii=1:length(indexNaN)
    Y=Data(:,indexNaN(ii));
    indexNaN_Y=find(isnan(Y)); % return the nan index of vector sample 
    
    indx_noNaN=find(sum(isnan(Data(indexNaN_Y,:)),1)==0);
    Data_reduced=Data(:,indx_noNaN);
    
    N_reduced=size(Data_reduced,2);
    Y0=Y*ones(1,N_reduced);

    dif2=(Data_reduced-Y0).^2;
    mean_dif20=nanmean(dif2);
    [mean_dif2,indsort] = sort(mean_dif20,'ascend');
    indsort_asc_KNN =indsort(1:Number_K_near);
    X=Data_reduced(:,indsort_asc_KNN);
    T=nanmean(X,2);

    Y(indexNaN_Y)=T(indexNaN_Y);
    Dataout(:,indexNaN(ii))=Y;
    %ii
    
end
% Dataout_3D=reshape(Dataout,Np,3,N); % the reshape does not work on 2D
% data

if graph
    figure
    subplot(1,2,1)
    imagesc(isnan(Data))
    %xlim([1 1000])
    title('Original Data')
    ylabel('3D-Poses')
    xlabel('Number of Sample')
    %
    subplot(1,2,2)
    imagesc(isnan(Dataout))
    %xlim([1 1000])
    title('Recounstructed Data Base on KNN')
    ylabel('3D-Poses')
    xlabel('Number of Sample')
end
