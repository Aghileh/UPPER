function mouse_plotting(poses,do_save)
colours = 'rbbggcmkk';
figure

for i = 1:numel(poses(1,1,:))
    for n = 1:numel(poses(:,1,1))
        plot3(poses(n,1,i),poses(n,2,i),poses(n,3,i),'.','Color',colours(n),'MarkerSize',20)
        hold on
    end
    %lines
    line([poses(1,1,i), poses(2,1,i)],[poses(1,2,i), poses(2,2,i)],[poses(1,3,i), poses(2,3,i)],'Color','k','LineWidth',0.1); %Link snout with left ear
    line([poses(1,1,i), poses(3,1,i)],[poses(1,2,i), poses(3,2,i)],[poses(1,3,i), poses(3,3,i)],'Color','k','LineWidth',0.1); %Link snout with right ear
    line([poses(7,1,i), poses(3,1,i)],[poses(7,2,i), poses(3,2,i)],[poses(7,3,i), poses(3,3,i)],'Color','k','LineWidth',0.1); %Link neck base with right ear    
    line([poses(7,1,i), poses(2,1,i)],[poses(7,2,i), poses(2,2,i)],[poses(7,3,i), poses(2,3,i)],'Color','k','LineWidth',0.1); %Link neck base with right ear
    line([poses(5,1,i), poses(3,1,i)],[poses(5,2,i), poses(3,2,i)],[poses(5,3,i), poses(3,3,i)],'Color','k','LineWidth',0.1); %Link mplant base with right ear   
    line([poses(4,1,i), poses(2,1,i)],[poses(4,2,i), poses(2,2,i)],[poses(4,3,i), poses(2,3,i)],'Color','k','LineWidth',0.1); %Link implant base with left ear
    line([poses(4,1,i), poses(6,1,i)],[poses(4,2,i), poses(6,2,i)],[poses(4,3,i), poses(6,3,i)],'Color','k','LineWidth',0.1); %Link implant base with left ear
    line([poses(5,1,i), poses(6,1,i)],[poses(5,2,i), poses(6,2,i)],[poses(5,3,i), poses(6,3,i)],'Color','k','LineWidth',0.1); %Link implant base with cable
    line([poses(4,1,i), poses(6,1,i)],[poses(4,2,i), poses(6,2,i)],[poses(4,3,i), poses(6,3,i)],'Color','k','LineWidth',0.1); %Link implant base with cable
    line([poses(7,1,i), poses(8,1,i)],[poses(7,2,i), poses(8,2,i)],[poses(7,3,i), poses(8,3,i)],'Color','k','LineWidth',0.1); %Link implant base with left ear
    line([poses(8,1,i), poses(9,1,i)],[poses(8,2,i), poses(9,2,i)],[poses(8,3,i), poses(9,3,i)],'Color','k','LineWidth',0.1); %Link implant base with left ear
    
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    %limits
    xlim([-15 15]);
    ylim([-15 15]);
    zlim([-10 10]);
    view([60 30])
    pause(0.03)    
    %video
    if do_save
        F(i) = getframe(gcf) ;
        drawnow
    end
    clf
end

%video

if do_save
    writerObj = VideoWriter('Upper_2D_train_test_OGK.avi');
    open(writerObj);
    %writerObj = VideoWriter([vid_path name]);
    %writerObj.FrameRate = 15;
    % set the seconds per image
    % open the video writer
    open(writerObj);
    % write the frames to the video
    for i=1:length(F)
        % convert the image to a frame
        frame = F(i) ;
        writeVideo(writerObj, frame);
    end
    % close the writer object
    close(writerObj);
end
end