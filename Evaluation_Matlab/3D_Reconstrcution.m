clear;

Intri_mat=[816.8598,  0.2072,  308.2864;
           0,        814.8223, 158.3971;
           0,        0,        1       ];%low cam
% filepath="data/";
% img1_raw=imread(strcat(filepath,"1.jpg"));
% img1=img1_raw;
% img2=imread(strcat(filepath,"2.jpg"));

allpath="cd2rtzm23r-1\LowCam\Small Intestine\";
Tra=dir(allpath);
[numTra,~] = size(Tra);
numTra = numTra - 2;
for count=(1:numTra)
    
    addon=strcat(allpath,Tra(count+2).name);
%     addon="\LowCam\Small Intestine\TumorfreeTrajectory_1";
    
    matchestxtpath1=strcat("C:\Brown_MS_ECE\2022_Fall\Courses\Image Understandng\Final_Project\dataset\",addon,"\modeloutput\");
    matchestxtpath2=strcat("C:\Brown_MS_ECE\2022_Fall\Courses\Image Understandng\Final_Project\dataset\",addon,"\pretrained_modeloutput\");
    matchestxtpath3=strcat("C:\Brown_MS_ECE\2022_Fall\Courses\Image Understandng\Final_Project\dataset\",addon,"\sequence\matches\matches_");
    matchestxtpath=[matchestxtpath1,matchestxtpath2,matchestxtpath3];
    filepath=strcat("C:\Brown_MS_ECE\2022_Fall\Courses\Image Understandng\Final_Project\dataset\",addon,"\sequence\frame\");

    posefile=dir(strcat("C:\Brown_MS_ECE\2022_Fall\Courses\Image Understandng\Final_Project\dataset\",addon,"\Poses\*.xlsx"));
    pose = xlsread(strcat("C:\Brown_MS_ECE\2022_Fall\Courses\Image Understandng\Final_Project\dataset\",addon,"\Poses\",posefile.name));
    tx=pose(:,4);
    ty=pose(:,5);
    tz=pose(:,6);
    rx=pose(:,7);
    ry=pose(:,8);
    rz=pose(:,9);
    rw=pose(:,10);

    for type=(1:3)
        framefile = dir(filepath);
        [framenum,~] = size(framefile);
        framenum = framenum - 2;
        for framecount = (1:framenum) 
            imgnum = num2str((framecount-1),'%04d');
            imgnum2 = num2str(framecount,'%04d');
            if(type == 3)
                matches=load(strcat(matchestxtpath3,imgnum,'.png_',imgnum2,'.png.txt'));
            else
                matches=load(strcat(matchestxtpath(type),'Frame',int2str(framecount-1),'.txt'));
            end
            img1=imread(strcat(filepath,imgnum,'.png'));
            img2=imread(strcat(filepath,imgnum2,'.png'));

%             img1=imresize(img1, 0.25,'bicubic');
%             img2=imresize(img2, 0.25,'bicubic');

            img1_color=img1;
            img2_color=img2;
            
            [height,width]=size(img1);
            
            lowesratio=0.5;
            pair_num=fix(lowesratio*size(matches,1));
            
            for i= (1:pair_num)  
                p(:,i)=[matches(i,1); matches(i,2)];
                p_corr(:,i)=[matches(i,3); matches(i,4)];
            end
            [E,inlierIndx]=Ransac4Essential(p,p_corr,Intri_mat);%E is in meters

%             T1=[tx(framecount);ty(framecount);tz(framecount)];
%             T2=[tx(framecount+1);ty(framecount+1);tz(framecount+1)];
%             
%             R2=quat2rotm([rw(framecount+1),rx(framecount+1),ry(framecount+1),rz(framecount+1)]);
%             R1=quat2rotm([rw(framecount),rx(framecount),ry(framecount),rz(framecount)]);
%             
%             RE=R2*transpose(R1);
%             TE=T2-R2*transpose(R1)*T1;
%             TransformT= [0    -TE(3)  TE(2); 
%                     TE(3)  0       -TE(1); 
%                     -TE(2) TE(1)   0];
%             E=TransformT*RE;

%             plotnum=20;
%             for i=(1:plotnum)
%                 matchesInPixel(i,:,1) = [p(:,inlierIndx(i));1];
%                 matchesInPixel(i,:,2) = [p_corr(:,inlierIndx(i));1];
%             end
%             Ep=transpose(inv(Intri_mat))*E*inv(Intri_mat);
%             Atmp(:)=Ep(1,1).*matchesInPixel(:,1,1)+Ep(1,2).*matchesInPixel(:,2,1)+Ep(1,3);
%             Btmp(:)=Ep(2,1).*matchesInPixel(:,1,1)+Ep(2,2).*matchesInPixel(:,2,1)+Ep(2,3);
%             Ctmp(:)=Ep(3,1).*matchesInPixel(:,1,1)+Ep(3,2).*matchesInPixel(:,2,1)+Ep(3,3);
%             
%             slope=-Atmp./Btmp;
%             cut=-Ctmp./Btmp;
%             [~, cols1] = size(img1);
%             
%             figure, img3 = [img1, img2];  
%             
%             colormap('gray');
%             imagesc(img3);
%             
%             hold on;
%             x=1:1:768;
%             for i = 1 : plotnum
%                 plot(matchesInPixel(i,1,2)+768,matchesInPixel(i,2,2),'bo','MarkerSize',6,'MarkerFaceColor','b');
%                 plot(matchesInPixel(i,1,1),matchesInPixel(i,2,1),'go','MarkerSize',6,'MarkerFaceColor','g');
%                     ytmp=slope(i)*x+cut(i);
%                     y=ytmp(find(ytmp>=1));
%                     xtmp=x(find(ytmp>=1));
%                     y=y(find(y<=512));
%                     xtmp=xtmp(find(y<=512));
%                     plot(xtmp+768,y,'r');
%             end
%             axis image
%             hold off;
%             set(gcf,'color','w');
%             T=clock;
            
%             name=strcat('ES_',num2str(T(4)),'_',num2str(T(5)),'_',num2str(T(6)),'.jpg');
%             saveas(gcf, name);
            if(framecount == 1)
                distthreshold = 0.3;
            else
                distthreshold = 0.3;
            end
            [denseMatchImg1, denseMatchImg2, denseInlierIndx] = Densification(E, Intri_mat, p, p_corr, inlierIndx, img1, distthreshold);
            [U,S,V]=svd(E);
            W=[0 -1 0;1 0 0 ;0 0 1];
            R(:,:,1)=U*W*transpose(V);
            R(:,:,2)=U*transpose(W)*transpose(V);
            T1=U(:,end);
            T2=-U(:,end);
            gammatmp=inv(Intri_mat)*denseMatchImg1(:,10);%pixel->meter
            gammahattmp=inv(Intri_mat)*denseMatchImg2(:,10);
            for i=(1:2)
                for j=(1:2)
                    if(j==1)
                        Ttmp=T1;
                    else
                        Ttmp=T2;
                    end
                    tmp1=[-R(:,:,i)*gammatmp,gammahattmp];
                    tmp1_inv=pinv(tmp1);
                    rho_matrix=tmp1_inv*Ttmp;
                    if(rho_matrix(:)>0)
                        R_valid=R(:,:,i);
                        T_valid=Ttmp;
                        
                    end
                end
            end
            
            num_dense_matches=size(denseInlierIndx,2)
            for i=(1:num_dense_matches)
                matchtmp=inv(Intri_mat)*denseMatchImg1(:,denseInlierIndx(i));
                matchhattmp=inv(Intri_mat)*denseMatchImg2(:,denseInlierIndx(i));
                rho=pinv([-R_valid*matchtmp,matchhattmp])*T_valid;
                Gamma=rho(1)*matchtmp;
                Gammahat=rho(2)*matchhattmp;
                
                if(framecount == 1)
                    avgGamma(:,i)=(Gamma+Gammahat)./2;
                    Gammacolor(:,i)=double(img1(denseMatchImg1(2,denseInlierIndx(i)),denseMatchImg1(1,denseInlierIndx(i)),:));
                else
%                     tmp = (Gamma+Gammahat)./2;
%                     if(size(find(tmp == avgGamma(:,:)),1) == 0)
%                         avgGamma=[avgGamma,tmp];
%                     end
                      avgGamma=[avgGamma,(Gamma+Gammahat)./2];
%                       squeeze(double(img1(denseMatchImg1(2,denseInlierIndx(i)),denseMatchImg1(1,denseInlierIndx(i)),:)))
                      Gammacolor=[Gammacolor,squeeze(double(img1(denseMatchImg1(2,denseInlierIndx(i)),denseMatchImg1(1,denseInlierIndx(i)),:)))];
                      if(mod(i,10000)==0)
                          i
                      end
                end

            %     transpose(denseMatchImg1(1:2,i))
%                 matchcolor1(1:3)=double(img1(denseMatchImg1(2,denseInlierIndx(i)),denseMatchImg1(1,denseInlierIndx(i)),:));
%                 matchcolor2(1:3)=double(img2r(denseMatchImg2(2,denseInlierIndx(i)),denseMatchImg2(1,denseInlierIndx(i)),:));
%                 Gammacolor(:,i)=(matchcolor1(:)+matchcolor2(:))./2;
            end
            
            px=avgGamma(1,:);
            py=avgGamma(2,:);
            pz=avgGamma(3,:);
            scatter3(px,py,pz,2,transpose(Gammacolor(1:3,:)./255));

            % plot3(px,py,pz,'r');
        end
        
    end
end









