function [ C1 M ] = calculateCovarianceFromImage( g )
   
%     [g, mx] = getpgmraw(imName);
    g = double(g);
%     subplot(1,2,1);   subimage(uint8(g));

    [height, width] = size(g);
    Img = g + 5.0*randn(size(g));

    % Extract visual features
    I = Img;
    d = [-1 0 1];
    Iy = imfilter(I,d,'symmetric','same','conv');
    Ix = imfilter(I,d','symmetric','same','conv');
    Ixx = imfilter(Ix,d','symmetric','same','conv');
    Iyy = imfilter(Iy,d,'symmetric','same','conv');
    [s2, s1] = meshgrid(1:width,1:height);

    F = zeros(height*width,7);
    F(:,1) = I(:);
    F(:,2) = abs(Ix(:));
    F(:,3) = abs(Iy(:));
    F(:,4) = abs(Ixx(:));
    F(:,5) = abs(Iyy(:));
    normIgrad=sqrt(Ix.*Ix+Iy.*Iy);
    F(:,6) = normIgrad(:);%s2(:);
    orIgrad=atan2(Iy,Ix);
    F(:,7) = orIgrad(:);%s1(:);

    C1 = cov(F);
    M = mean(C1);
%     subplot(1,2,2); imagesc(C1); axis image;
%     colormap(hsv)


end

