clear all; close all; clc; 
%% %%  Data reading  and preperation should be do by the user base on her/his data
load('Maindata_3D.mat')
RawData=Maindata;
[ND,Ns] = size(RawData);
Framedim=3;
Np=ND/Framedim;
RawData3D=reshape(RawData,[Np,Framedim,Ns]); %reshape
RawData3D_full=RawData3D(:,:,1:2000);
%%
%%%
% Estimation_Model function eceives the 3D data and return the Data which all missing data filled up and  mean
% estimated by Ransac, Mean of pPCA, Covariance of pPCA and Eigenvalues
% and eigenpose
[Data_3D_KNN Mean_Ransac_3D Mean_pPCA Cov_pPCA eignValues eignVectors]=Estimation_Model( RawData3D_full,0.8);
%%
%the input is the 3D Rawdata (it is suggested use the Data_3D_KNN which has no missing values) and the output is 3D reconstructed data which
%backed to original place in the arena. 

[Recounstructed_Data_full]=Reconstruct_Data(RawData3D_full,Data_3D_KNN,0.99,Mean_Ransac_3D,Mean_pPCA,Cov_pPCA)

%%
save('Recounstructed_Data_full')


