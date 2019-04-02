function [tf, vid] = register_vid_chronos(vid)

    [optimizer, metric] = imregconfig('monomodal');
    % optimizer.InitialRadius = 1e-3;
    optimizer.MaximumIterations = 150;
    optimizer.MaximumStepLength = 0.03;
    optimizer.MinimumStepLength = 0.0002;

    vid = fliplr(squeeze(vid)); % In case it's 4D
    dim = size(vid); % Used often

    v = vid(:,:,1);
    v2 = medfilt2(imopen(v,strel('disk',15)),[7 7]);
    v3 = im2bw(v2,graythresh(v2));
    L = regionprops(v3,'Orientation');
    refangle = L.Orientation;

    tf = cell(1,dim(3));

    fixed = double(squeeze(vid(:,:,1)));
    % mfile = VideoWriter('registeredtest.avi', 'Motion JPEG AVI'); % open video writer to generate movie
    % mfile.FrameRate = 160;
    % open(mfile);

    sz = imref2d(size(fixed));
    % bar = waitbar(0, 'Registering video...');
    for i = 1:dim(3)
        fprintf([int2str(i) '\n']);
        z = double(vid(:,:,i)); % take one frame
        if i==1
            tf{i} = imregtform(z,fixed,'rigid',optimizer,metric);
        else
            for j = i-1:-1:1
                if(isRigid(tf{j}))
                    break;
                end
            end
            tf{i} = imregtform(z,fixed,'rigid',optimizer,metric,'InitialTransformation',tf{j});
        end
        reg = imwarp(z,tf{i},'OutputView',sz);
        vid(:,:,i) = imrotate(reg,90-refangle,'crop');
        fixed = (fixed*i + reg)/(i+1);

        % if(i==1) % if first time show the image
        % h = imagesc(vid(:,:,i)); truesize, axis off; colormap gray;
        % str = text(20,25,sprintf('%04d',i),'color',[1 1 1],'FontSize',12);
        % else % replace Cdata to save time
        % h.CData = vid(:,:,i);
        % str.String = sprintf('%04d',i);
        % end

        % f = getframe; % get the RGB frame corresponding to the figure
        % writeVideo(mfile,f.cdata); % write that image to the movie file
        % waitbar(i/dim(3), bar);
    end
    % delete(bar);
    % close(mfile)
end