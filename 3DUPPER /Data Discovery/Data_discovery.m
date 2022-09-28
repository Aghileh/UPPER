clc
clear all

%%  Data reading  and preperation should be do by the user base on her/his data
load('Maindata_3D.mat')
RawData=Maindata;
[ND,Ns] = size(RawData);
Framedim=3;
Np=ND/Framedim;
RawData3D=reshape(RawData,[Np,Framedim,Ns]); %reshape
concatinated=RawData3D(:,:,1:2000);
%concatinated=Data_3D  %% data should add to this part by user
Data_label={'bp1','bp2','bp3','bp4','bp5','pb6','pb7','bp8','bp9','bp10','bp11'} %% body points should  add to this part by user
%%
Np=size(concatinated,1);
Dim=size(concatinated,2);
Ns=size(concatinated,3);
raw_data_2D=reshape(concatinated,[Np*Dim, Ns]);
%%%check the number of Nan
%%%report of element:
Percent_element=[]
for j=1:size(concatinated,1);
column_indices(j,:) = [j,j+9,j+18]
end
for i=1:size(concatinated,1)
    percent_Missing_elem=length(find(sum(isnan(raw_data_2D(column_indices(i,:),:)))))/size(concatinated,3)*100;
    Percent_element(:,i)=percent_Missing_elem;
end
figure
fig=bar(Percent_element)
set(gca,'XTickLabel',Data_label)
ylim([0,100]);
saveas(gca,'MyFigure.png')

%%%
percent_Missing_all_fram=length(find(sum(isnan(raw_data_2D))))/size(concatinated,3)*100
% Z = ['The persenatge of missing values in poses is: %',num2str(percent_Missing_all_fram)]
% disp(Z)
formatSpec = "The persenatge of missing values in poses is: %f !";
Messags=sprintf(formatSpec,percent_Missing_all_fram)
f = msgbox(sprintf(Messags),'Missing Values')

%%
answer = questdlg('Do you want to delet any body points?', 'Yes','No');
% Handle response
Reduced_Raw_3D =[];
switch answer
    case 'Yes'
      delet_frame = input('Enter the number of body points: ','s')
      Body_point_problem=[str2num( delet_frame )]
      
      n=length(Body_point_problem);
      v=zeros(n,1);
      for k=1:n
          v(k)=Body_point_problem(k);
      end
      
      concatinated(Body_point_problem,:,:)=[];
      Reduced_Raw_3D=concatinated;
      save('Reduced_Raw_3D')
    case 'No'
     
      disp([' Finished'])
    
end
%%
