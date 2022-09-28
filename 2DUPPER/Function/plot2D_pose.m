function[] = plot2D_pose(X,draw_sticks)
C = {[1 1 1],[0 0 0],[1 0.8  1],[0 1 0],[1 1 0],[1 0 1],[.5 .6 .7],[.8 .2 .6],[0.4 1 1],[0 0.2 0.4],[.2, .4 0],[.8 0 1]};
Np = size(X,1);
%N = size(X,3);
%for n = 1:N
    %landmarks
    for m = 1:Np
        plot(X(m,1), X(m,2),'o','MarkerFaceColor',C{m})
        hold on
        %plot(X(m,1), X(m,2),'MarkerFaceColor',C{m},'o'); 
    end
    %sticks
    if draw_sticks
        land = [1 2; 1 3; 2 4; 3 4; 4 5;5 6; 6 7; 7 8;8 9 ;9 10; 10 11];
        %land = [1 2; 1 3; 2 4; 3 4; 4 5;5 6; 6 7; 7 8;8 9 ;9 10];
        Nstick = size(land,1); 
        for m = 1:Nstick
            xl = [X(land(m,1),1) X(land(m,2),1)];
            yl = [X(land(m,1),2) X(land(m,2),2)];
            
            line(xl, yl,'LineWidth',2,'Color',0.66*ones(1,3));
        end
    end
    xm = nanmean(X(:,1,1)); ym = nanmean(X(:,2,1));
    dxm = 300; dym = 300;
    xlim([xm-dxm xm+dxm]); ylim([ym-dym ym+dym]);
% xlim([1500 1500]); ylim([1500 1500])
%end