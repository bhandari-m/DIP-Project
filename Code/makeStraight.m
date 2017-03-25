function [img, orgImg] = makeStraight(I, orgI)
%     I = imread('bill20.jpg');
%     orgI = I;
    tmp = I;
    I = imrotate(I, 5, 'bilinear');
    orgI = imrotate(orgI, 5, 'bilinear');
    colorI = I;
    if size(I, 3) ~= 1
        I = rgb2gray(I);
    end

    I = edge(I, 'canny', 0.5);
    %imshow(I, []);

    [H,T,R] = hough(I);
    P = houghpeaks(H, 5);

    theta = T(P(:,2));
    rho = R(P(:,1));

    max_angle = -180;
    % deviation = 0;
    % count = 0;

    angle_idx = 0;

    for i=1:length(theta)
       angle = abs(theta(i));
       if abs(angle-90) < 25 && abs(angle-90) >=5
    %        deviation = deviation + abs(angle-90);
    %        count = count+1;
           if (abs(angle-90) > max_angle)
               angle_idx = i;
               max_angle = abs(angle-90);
           end
       elseif angle < 25 && angle >= 5
    %        deviation = deviation + abs(angle);
    %        count = count+1;
           if (angle > max_angle)
               angle_idx = i;
               max_angle = angle;
           end
       end
    end


    % if count > 0
    %     rot_angle = deviation/count;r
    % end

    rot_angle = 0;
    if angle_idx > 0
        rot_angle = max_angle;
        if (theta(angle_idx)) > 0
            rot_angle = -rot_angle;
        end
    end
    lines = houghlines(I, T, R, P);

    figure, imshow(colorI);
    hold on;
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];

        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');

        plot(xy(1,1), xy(1,2), 'x', 'LineWidth', 2, 'Color', 'green');
        plot(xy(2,1), xy(2,2), 'x', 'LineWidth', 2, 'Color', 'green');
    end

    img = imrotate(colorI, rot_angle, 'bilinear', 'crop');
    orgImg = imrotate(orgI, rot_angle, 'bilinear', 'crop');
    %imshow(I);
    %imwrite(I, 'processed.jpg');
%end
