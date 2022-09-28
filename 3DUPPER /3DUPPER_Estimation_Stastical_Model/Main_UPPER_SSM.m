% Main Body code for the estimation of Stastical Shape Model(SSM)
clear all; close all; clc; 

%%  Data reading  and preperation should be do by the user base on her/his data
load('Maindata_3D.mat')
RawData=Maindata;
[ND,Ns] = size(RawData);
Framedim=3;
Np=ND/Framedim;
RawData3D=reshape(RawData,[Np,Framedim,Ns]); %reshape
RawData3D_full=RawData3D(:,:,1:2000);

%%
%%%
% Estimation_Model function eceives the 3D data and return the mean
% estimated by Ransac, Mean of pPCA, Covariance of pPCA and Eigenvalues
% and eigenpose

[Data_3D_KNN Mean_Ransac Mean_pPCA Cov_pPCA EignValues EignVectors]=Estimation_Model(RawData3D_full,0.8);


