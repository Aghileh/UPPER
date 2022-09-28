function[] = make_movie_2D()

load('Result_040222_95_percent.mat')
%make a movie for change in body shape along directions of the eigenposes
lambda = eignValues(1:5);

[Np Ndim Ns]=size(Data_reconstruct_3D);


Nshape = numel(lambda);
mean_pose=mean_pose_3D; % Aghileh
mean_pose = mean_pose - repmat(mean_pose(round(Np/2),:),Np,1);

eigen2=reshape(eignVectors(:,:),Ndim,Np,Np*Ndim);
for i=1:Np*Ndim
    eigen(:,:,i)=(eigen2(:,:,i)');
end

for i=1:5
    P{i}= eigen(:,:,i);
end

do_save = true; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if do_save
    vidObj = VideoWriter('Upper_2D_train_test_OGK.avi');
    open(vidObj);
else
    vidObj = [];
end
Nmovie = 200;
fig = figure; 
set(fig,'Position',[200 200 400 400]);
h = subplot(1,1,1);

%%%%%%%%%%%%%%%%%%%%%%subtract neck coordinates%%%%%%%%%%%%%%%%%

%mean_pose = mean_pose-repmat(mean_pose(9,:),Np,1);


%%%%%%%%%%%%%%%%%%%%%%SHAPE CHANGES%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for nn = 1:Nshape 
    poses_movie = [];
    %generate shape full body movements
    b_movie = sqrt(4)*sqrt(lambda(nn))*sin(2*pi*[1:Nmovie]/(Nmovie/2));
    poses_movie = zeros(Np,2,Nmovie);
    for n = 1:Nmovie
        temp = mean_pose + P{nn}*b_movie(n);
       % poses_movie(:,:,n) = reshape(temp,Np,2);
         poses_movie(:,:,n) = temp;
    end
    %show movie
    if nn == 1
        show_movie(h,poses_movie,do_save,[{'1st eigenpose'}],vidObj,'b');
    elseif nn == 2
        show_movie(h,poses_movie,do_save,[{'2nd eigenpose'}],vidObj,'b');
    elseif nn == 3
        show_movie(h,poses_movie,do_save,[{'3rd eigenpose'}],vidObj,'b');
    elseif nn == 4
        show_movie(h,poses_movie,do_save,[{'4th eigenpose'}],vidObj,'b');
    else
        show_movie(h,poses_movie,do_save,[{'5th eigenpose'}],vidObj,'b');
    end
end


%%%%%%%%%%%%%%%%%%%%CLOSE VIDEO%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if do_save
    close(vidObj);
end

%%%%%%%%%%%%%%%%%%%%SUBFUNCS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function[] = show_movie(h,poses_movie,do_save,tt,vidObj,col)
cval = [1 0 0; 0 0 1; 0 0 0.5; 0 1 1; 0 0.5 0.5; 0.75 0 0.25; 0.25 0 0.75; 1 0 1];
[Np,~,Nmovie] = size(poses_movie);
mval = [1:8]; 
Nm = numel(mval);
for n = 1:Nmovie
    %
    subplot(h(1)); hold on;
    title(tt{1},'FontSize',16,'Color',col);
    for m = 1:Nm
        plot(poses_movie(mval(m),1,n),poses_movie(mval(m),2,n),'.','MarkerSize',18,'Color',cval(mval(m),:));
    end
    %
    land = [1 2; 1 3; 2 4; 3 4; 4 5;5 6; 6 7; 7 8];
    Nstick = size(land,1); 
    for m = 1:Nstick
        xl = [poses_movie(land(m,1),1,n) poses_movie(land(m,2),1,n)];
        yl = [poses_movie(land(m,1),2,n) poses_movie(land(m,2),2,n)];
        %zl = [poses_movie(land(m,1),3,n) poses_movie(land(m,2),3,n)];
        line(xl, yl,'LineWidth',2,'Color',0.66*ones(1,3));
    end
    xlabel('X','FontSize',16);ylabel('Y','FontSize',16);
    xlim([-100 100]); ylim([-100 100]);
    %
    pause(0.01); 
    if do_save
       currFrame = getframe(gcf);
       writeVideo(vidObj,currFrame); 
    end
    if n < Nmovie
        subplot(h); cla;
    end
    
end



