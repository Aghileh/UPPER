% Main Eigen coverage for number of sample
clear all; close all; clc; 
%%  Data reading  and preperation should be do by the user base on her/his data
load('Maindata_3D.mat')
RawData=Maindata;
[ND,Ns] = size(RawData);
Framedim=3;
Np=ND/Framedim;
RawData3D=reshape(RawData,[Np,Framedim,Ns]); %reshape
RawData3D_full=RawData3D;
%%
% the input is full 3D data and out put is the figure shoes how many sample
% need for eigen coverage
Eigen_Coverage(RawData3D_full,0.8,0.99,true)



