% Main Eigen coverage for number of sample
clear all; close all; clc; 
%%  Data reading  and preperation should be do by the user base on her/his data
% RawData_p=load('Maindata');
% RawData_full=RawData_p.Maindata;
% 
% [ND,Ns] = size(RawData_full);
% Framedim=3;
% Np=ND/Framedim;
% 
% RawData3D_full=reshape(RawData_full,[Np,Framedim,Ns]); %reshape

load('3D_data.mat')
 RawData3D_full=concatinated;
%%%
%%
% the input is full 3D data and out put is the figure shoes how many sample
% need for eigen coverage
Eigen_Coverage(RawData3D_full,0.8,0.99,true)



