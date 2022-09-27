% Main Body code for the estimation of Stastical Shape Model(SSM)
clear all; close all; clc; 
%%
% preperation of data from 2d (Np*3, Ns) to data 3D (Np, 3,Ns)
load('Data_partial')
RawData=Data_partial;
[ND,Ns] = size(RawData);
Framedim=3;
Np=ND/Framedim;

RawData3D=reshape(RawData,[Np,Framedim,Ns]); %reshape
percent_Nan_frame=(length(find(sum(isnan(RawData))))/(Ns))*100;

%%
%%%
% Estimation_Model function eceives the 3D data and return the mean
% estimated by Ransac, Mean of pPCA, Covariance of pPCA and Eigenvalues
% and eigenpose

[Data_3D_KNN Mean_Ransac Mean_pPCA Cov_pPCA EignValues EignVectors]=Estimation_Model(RawData3D,0.8);


