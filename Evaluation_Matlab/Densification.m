function [denseMatchImg1, denseMatchImg2, denseInlierIndx] = Densification(E, K, matchImg1, matchImg2, inlierIndx, img1_raw, distthreshold)

%> Code Description: 
%     Given an essential matrix, intrinsic matrix, feature matches in
%     pixels, indices for inliers, and the first image, returned a list of
%     dense correspondences and indices for the inliers.
%
%> Inputs: 
%     E:          Essential matrix returned by the RANSAC algorithm.
%     K:          Intrinsic matrix. 
%     matchImg1:  Feature correspondences in pixels from the first image. 
%                 If there are N correspondences, the size of matchImg1 can 
%                 be either 2xN or 3xN if homogenous coordinate is used.
%     matchImg2:  Feature correspondences in pixels from the first image 
%                 with the same size of matchImg1.
%     inlierIndx: A vector storing indices of inlier correspondences.
%     img1_raw:   The first image returned by the imread function.
%
%> Outputs:
%     denseMatchImg1:  A list of dense correspondences in pixels from the 
%                      first image in homogenous coordinates. If there are 
%                      M dense correspondences, the size of denseMatchImg1 
%                      is Mx3.
%     denseMatchImg2:  A list of dense correspondences in pixels from the 
%                      second image in homogenous coordinates. The size is
%                      the same as denseMatchImg1.
%     denseInlierIndx: Inlier indices of the dense correspondences.
%
%
%> (c) LEMS, Brown University
%> Chiang-Heng Chien (chiang-heng_chien@brown.edu)
%> Oct. 20th, 2020


    warning('off', 'all');
    [rows1, cols1, ~] = size(img1_raw);
    
    %> Interpolate correspondences from image 1 to image 2
    fprintf('Interpolating correspondences from image 1 to 2 ...\n');
    interpMatch_img1to2 = zeros(rows1, cols1, 2);
    [mx, my] = meshgrid(1:cols1, 1:rows1);
    interpMatch_img1to2(:,:,1) = griddata(double(matchImg1(1,inlierIndx)), double(matchImg1(2,inlierIndx)), ...
                                          double(matchImg2(1, inlierIndx)), double(mx), double(my));
    interpMatch_img1to2(:,:,2) = griddata(double(matchImg1(1,inlierIndx)), double(matchImg1(2,inlierIndx)), ...
                                          double(matchImg2(2, inlierIndx)), double(mx), double(my));

    %> Reverse correspondences interpolation from image 2 to image 1
    interpMatch_img2to1 = zeros(rows1, cols1, 2);
    interpMatch_img2to1(:,:,1) = griddata(double(matchImg2(1,inlierIndx)), double(matchImg2(2,inlierIndx)), ...
                                          double(matchImg1(1, inlierIndx)), double(mx), double(my));
    interpMatch_img2to1(:,:,2) = griddata(double(matchImg2(1,inlierIndx)), double(matchImg2(2,inlierIndx)), ...
                                          double(matchImg1(2, inlierIndx)), double(mx), double(my));
    
    %> Check bidirectional interpolation consistency
    biDirConsistIndx_img1x = [];
    biDirConsistIndx_img1y = [];
    biDirConsistIndx_img2x = [];
    biDirConsistIndx_img2y = [];
    dist = zeros(2, 1);
    for i = 1 : cols1
        for j = 1 : rows1
            if (isnan(interpMatch_img1to2(j, i, 1)) || isnan(interpMatch_img1to2(j, i, 2)))
                continue;
            end
            biDirX_img2pix = round(interpMatch_img1to2(j, i, 1));
            biDirY_img2pix = round(interpMatch_img1to2(j, i, 2));
            dist(1) = abs(interpMatch_img2to1(biDirY_img2pix, biDirX_img2pix, 1) - i);
            dist(2) = abs(interpMatch_img2to1(biDirY_img2pix, biDirX_img2pix, 2) - j);
            
            %> Store consistent dense matches
            if (norm(dist) < 2)
                %> consistent pix coordinate on image 1
                biDirConsistIndx_img1x = [biDirConsistIndx_img1x, i];
                biDirConsistIndx_img1y = [biDirConsistIndx_img1y, j];
                
                %> consistent pix coordinate on image 2
                biDirConsistIndx_img2x = [biDirConsistIndx_img2x, biDirX_img2pix];
                biDirConsistIndx_img2y = [biDirConsistIndx_img2y, biDirY_img2pix];
            end
        end
    end
    %fprintf("Found %d bidirectional consistency points\n", length(biDirConsistIndx_img1x));
    
    %> Check valid bidirectional consistency via reprojection error
    %  and reform the dense matches in homogenous manner
    inlierNumMax = 0;
    denseMatchImg1 = [biDirConsistIndx_img1x; biDirConsistIndx_img1y; ones(1, length(biDirConsistIndx_img1x))];
    denseMatchImg2 = [biDirConsistIndx_img2x; biDirConsistIndx_img2y; ones(1, length(biDirConsistIndx_img2x))];
    
    %> Compute coefficients of a line equation
    A = zeros(1, length(denseMatchImg1));
    B = zeros(1, length(denseMatchImg1));
    C = zeros(1, length(denseMatchImg1));
    K_inv = inv(K);
    calE = K_inv' * E * K_inv;
    A(1, :) = calE(1, :) * denseMatchImg1;
    B(1, :) = calE(2, :) * denseMatchImg1;
    C(1, :) = calE(3, :) * denseMatchImg1;
        
    %> Compute the distance from a point to a line for all bi-directional consistent matches
    dist = zeros(1, length(denseMatchImg1));
    denomOfDist = zeros(1, length(denseMatchImg1));
    numerOfDist = zeros(1, length(denseMatchImg1));
    A_ep = zeros(1, length(denseMatchImg1));
    B_it = zeros(1, length(denseMatchImg1));
    for k = 1 : length(denseMatchImg1)
        A_ep(:,k) = A(:,k).*denseMatchImg2(1, k);
        B_it(:,k) = B(:,k).*denseMatchImg2(2, k);
    end
    numerOfDist = abs(A_ep + B_it + C);
    denomOfDist = A.^2 + B.^2;
    denomOfDist = sqrt(denomOfDist);
    dist = numerOfDist./denomOfDist;
    
    %> Find those consistent dense matches that meet the reprojection error
    %  criteria
    denseInlierIndx = find(dist(1,:) < distthreshold);
    
    %fprintf("Remained %d matches left that meet the reprojection error criteria\n", length(denseInlierIndx));
end