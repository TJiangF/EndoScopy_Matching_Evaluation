clear;
close all;
thres=[1,3,5,10,12];% different threshold to evaluate accuracy
allpath="cd2rtzm23r-1\LowCam\Colon-IV\";
Tra=dir(allpath);
[numTra,~] = size(Tra);
numTra = numTra - 2;
allcount=1;
for count=(1:numTra)
    Tra(count+2)
    addon=strcat(allpath,Tra(count+2).name);
%     addon="\LowCam\Small Intestine\TumorfreeTrajectory_1";
    allcount=1;
    matchestxtpath1=strcat(addon,"\modeloutput\");
    matchestxtpath2=strcat(addon,"\pretrained_modeloutput\");
    matchestxtpath3=strcat(addon,"\sequence\matches\matches_");
    matchestxtpath=[matchestxtpath1,matchestxtpath2,matchestxtpath3];
    filepath=strcat(addon,"\sequence\frame\");
    posefile=dir(strcat(addon,"\Poses\*.xlsx"));
    pose = xlsread(strcat(addon,"\Poses\",posefile.name));
    tx=pose(:,4);
    ty=pose(:,5);
    tz=pose(:,6);
    rx=pose(:,7);
    ry=pose(:,8);
    rz=pose(:,9);
    rw=pose(:,10);
    numpic= dir(filepath);
    [frames,~]=size(numpic);
    frames=frames-3;
%     frames=size(pose,1);
%     
%     cam_K=[957.411,  5.6242,  282.192;
%            0,        959.386, 170.731;
%            0,        0,       1       ];%high cam
    cam_K=[816.8598,  0.2072,  308.2864;
           0,        814.8223, 158.3971;
           0,        0,        1       ];%low cam
    
    
    % fbar = waitbar(0,'Please wait...');
    infoname = strcat(addon,"\allinfo2.txt");
    infoall = fopen(infoname,'wt');
    for threscount = (1:length(thres))
        threshold=thres(threscount);
        date="12_12_0";
        txtname1=strcat(addon,'\','Time_',date,'_',int2str(threshold),'_Model_Acc.txt');
        txtname2=strcat(addon,'\','Time_',date,'_',int2str(threshold),'_Pretrain_Acc.txt');
        txtname3=strcat(addon,'\','Time_',date,'_',int2str(threshold),'_SIFT_Acc.txt');
        txtname=[txtname1,txtname2,txtname3];
        for type=(1:3)
    %         txtname(type)
            [fid,message] = fopen(txtname(type),'wt');
    %         message
            for i=(1:frames-1)
                T1=[tx(i);ty(i);tz(i)];
                T2=[tx(i+1);ty(i+1);tz(i+1)];
            
                R2=quat2rotm([rw(i+1),rx(i+1),ry(i+1),rz(i+1)]);
                R1=quat2rotm([rw(i),rx(i),ry(i),rz(i)]);
            
                RE=R2*transpose(R1);
                TE=T2-R2*transpose(R1)*T1;
                TransformT= [0    -TE(3)  TE(2); 
                            TE(3)  0       -TE(1); 
                            -TE(2) TE(1)   0];
                E=TransformT*RE;
                num=i-1;
                thousands=floor(num/1000);
                if(thousands~=0)
                    num=num-thousands*1000;end
                hundreds=floor(num/100);
                if (hundreds~=0)
                    num=num-hundreds*100;end
                tens=floor(num/10);
                if (tens~=0)
                    num=num-tens*10;end
                units=floor(num/1);
                imgnum=strcat(num2str(thousands),num2str(hundreds),num2str(tens),num2str(units));
                img1=imread(strcat(filepath,imgnum,'.png'));
                num=i;
                thousands=floor(num/1000);
                if(thousands~=0)
                    num=num-thousands*1000;end
                hundreds=floor(num/100);
                if (hundreds~=0)
                    num=num-hundreds*100;end
                tens=floor(num/10);
                if (tens~=0)
                    num=num-tens*10;end
                units=floor(num/1);
                imgnum2=strcat(num2str(thousands),num2str(hundreds),num2str(tens),num2str(units));
                img2=imread(strcat(filepath,imgnum2,'.png'));
%                 img1=imresize(img1,[576,720],"cubic");
%                 img2=imresize(img2,[576,720],"cubic");
                img1=imresize(img1,[480,640],"cubic");
                img2=imresize(img2,[480,640],"cubic");
                if(type == 3)
                    matches=load(strcat(matchestxtpath3,imgnum,'.png_',imgnum2,'.png.txt'));
                    matches(:,1)=matches(:,1).*(640/720);
                    matches(:,2)=matches(:,2).*(480/576);
                    matches(:,3)=matches(:,3).*(640/720);
                    matches(:,4)=matches(:,4).*(480/576);
                else
                    matches=load(strcat(matchestxtpath(type),'Frame',int2str(i-1),'.txt'));
                    matches(:,1)=matches(:,1).*(640/720);
                    matches(:,2)=matches(:,2).*(480/576);
                    matches(:,3)=matches(:,3).*(640/720);
                    matches(:,4)=matches(:,4).*(480/576);
                end
            %     matches=load(strcat(matchestxtpath2,imgnum,'.png_',imgnum2,'.png.txt'));
    %             matches=load(strcat(matchestxtpath1,'Frame',int2str(i-1),'.txt'));
                
                p_frame1=transpose(matches(:,1:2));
                p_frame2=transpose(matches(:,3:4));
                
                f_frame1=transpose([matches(:,1),matches(:,2)]);
                f_frame2=transpose([matches(:,3),matches(:,4)]);
            
                E=transpose(inv(cam_K))*E*inv(cam_K);% in pixel
            
                Atmp = E(1,1).*f_frame1(1,:) + E(1,2).*f_frame1(2,:) + E(1,3);
                Btmp = E(2,1).*f_frame1(1,:) + E(2,2).*f_frame1(2,:) + E(2,3);
                Ctmp = E(3,1).*f_frame1(1,:) + E(3,2).*f_frame1(2,:) + E(3,3);
                
            
                cut_col=-Ctmp./Btmp;
                cut_row=-Ctmp./Atmp;
                slope=-Atmp./Btmp;
                %ax+by+c=0->y=-a/b x-c/b
                pair_num=size(matches,1);
            
                num_inlier=0;
                total_distance(i)=0;
                ratio=1;
                selectnum=round(ratio*pair_num);
                for j=(1:selectnum)
                    v1 = [0,cut_col(j)];
                    v2 = [cut_row(j),0];
                    pt=transpose(p_frame2(:,j));
                    a = v1 - v2;
                    b = pt - v2;
                    col(i,j,:)=v1;
                    row(i,j,:)=v2;
            
                    dis(i,j) = abs(det([a;b]))/norm(a);
                    total_distance(i)=total_distance(i)+dis(i,j);
                    if(dis(i,j)<=threshold)
                        num_inlier=num_inlier+1;
                    end
                end
            
                inlier_count(i)=num_inlier/selectnum;  %the accuracy based on threshold
                fprintf(fid,' %d',num_inlier);
                fprintf(fid,' %d',selectnum);
                fprintf(fid,' %d\n',inlier_count(i));
            %     distance_count(i)=total_distance;
            %     waitbar(i/(frames-1),fbar,'Processing data…');
                if(inlier_count(i)>1.1)% if would like to check the epipolar lines, then change > to <
                    [~, cols1] = size(img1);
                    figure, img3 = [img1, img2];  
                    colormap('gray');
                    imagesc(img3);
                    hold on;
                    x=1:1:640;
                    for k = 1 : selectnum
                        if(dis(i,k)<3)% select which type of matches to visualize
                            ystart = -(Atmp(k)+Ctmp(k))/Btmp(k);
                            yend = -(640*Atmp(k)+Ctmp(k))./Btmp(k);
                            line([640,1280],[ystart,yend]);
                            plot(p_frame2(1,k)+640,p_frame2(2,k),'wo','MarkerSize',4,'MarkerFaceColor','y');
                            text(p_frame2(1,k)+645,p_frame2(2,k),int2str(dis(i,k)),'FontSize',6,'Color','y');
                            text(p_frame2(1,k)+645,p_frame2(2,k)+10,int2str(k),'FontSize',8,'Color','r');
                            plot(p_frame1(1,k),p_frame1(2,k),'go','MarkerSize',6,'MarkerFaceColor','g');
                            text(p_frame1(1,k)+5,p_frame1(2,k)+10,int2str(k),'FontSize',8,'Color','r');                       
                        else
            %                 plot(p_frame2(1,k)+720,p_frame2(2,k),'bo','MarkerSize',6,'MarkerFaceColor','b');
            %                 text(p_frame2(1,k)+725,p_frame2(2,k),int2str(dis(i,k)),'FontSize',6,'Color','b');
                        end
                    end
                    axis image
                    hold off;
                    xlim([0,1280])
                    ylim([1,480])
                    set(gcf,'color','w');
                end
            end
            % close(fbar);
            all_count(allcount,1)=threscount;
            all_count(allcount,2)=type;
            all_count(allcount,3)=sum(total_distance(:));
            all_count(allcount,4)=sum(inlier_count(:))/(frames-1);
            all_count(allcount,5)=sum(inlier_count(:));
            all_count(allcount,6)=(frames-1);
            fprintf(fid,' %3f\n',sum(inlier_count(:))/(frames-1));
            fprintf(infoall,' %d  %d  %f  %f  %d  %d\n',all_count(allcount,:));
            fclose(fid);
            allcount=allcount+1;
        end
    end

end
fclose(infoall);



