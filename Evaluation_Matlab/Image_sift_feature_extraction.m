clear;
allpath="cd2rtzm23r-1\Cameras\HighCam\Colon-IV\";
% allpath="cd2rtzm23r-1\Cameras\LowCam\LowCam\Stomach-I\";
Tra=dir(allpath);
[numTra,~] = size(Tra);
numTra = numTra - 2;
for count=(1:numTra)
    count
    % filepath="cd2rtzm23r-1\UnityCam\Small Intestine\Frames\image_";
    addon=strcat(allpath,Tra(count+2).name);
    % addon = "UnityCam\Small_Intestine";
%     open allpath;
%     mkdir('\sequence')
    filepath=strcat(addon,"\Frames\");
    picpath=strcat(addon,"\Frames\*.png");
    imagepath=strcat(addon,"\sequence\frame\");
    txtpath=strcat(addon,"\sequence\matches\");
    patch=64;
    pics = dir(picpath);
    [filenum,~] = size(pics);
    picnum=filenum-2;
%     fbar = waitbar(0,'Please wait...');
    for i=(0:picnum)
        filenum=i;
        if(i<10)
            imgfilename1=strcat('000',string(filenum),'.png');
            img1=imread(strcat(filepath,'000',string(filenum),'.png'));
        elseif(i<100)
            imgfilename1=strcat('00',string(filenum),'.png');
            img1=imread(strcat(filepath,'00',string(filenum),'.png'));
        elseif(i<1000)
            imgfilename1=strcat('0',string(filenum),'.png');
            img1=imread(strcat(filepath,'0',string(filenum),'.png'));
        else
            imgfilename1=strcat(string(filenum),'.png');
            img1=imread(strcat(filepath,string(filenum),'.png'));
        end
        img1=imresize(img1,[576,720],"cubic");
        if(i==0)
            imagename=strcat(imagepath,imgfilename1);
            imwrite(img1,imagename);
        end
        filenum=i+1;
        if(i<9)
            imgfilename2=strcat('000',string(filenum),'.png');
            img2=imread(strcat(filepath,'000',string(filenum),'.png'));
        elseif(i<99)
            imgfilename2=strcat('00',string(filenum),'.png');
            img2=imread(strcat(filepath,'00',string(filenum),'.png'));
        elseif(i<999)
            imgfilename2=strcat('0',string(filenum),'.png');
            img2=imread(strcat(filepath,'0',string(filenum),'.png'));
        else
            imgfilename2=strcat(string(filenum),'.png');
            img2=imread(strcat(filepath,string(filenum),'.png'));
        end
    
        img2=imresize(img2,[576,720],"cubic");
        imagename=strcat(imagepath,imgfilename2);
        imwrite(img2,imagename);
    
        img1_color=img1;
        img2_color=img2;
        
        img1=single(im2gray(img1));
        img2=single(im2gray(img2));
        [height,width]=size(img1);
        
    %     peakthresh=2;
    %     edge_thresh=20;
        
        [f1, d1] = vl_sift(img1); 
        [f2, d2] = vl_sift(img2); 
        
        [matches, scores] = vl_ubcmatch(d1, d2);
        [dump,scoreindex]=sort(scores,'ascend');
        lowesratio=1;
        pair_num=fix(lowesratio*size(matches,2));
    
        txtname=strcat(txtpath,'matches_',imgfilename1,'_',imgfilename2,'.txt');
        fid = fopen(txtname,'wt');
        f1(1,find(f1(1,:)<patch+1)) = -1;
        f1(1,find(f1(1,:)>(width-patch-1))) = -1;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
    
        f1(2,find(f1(2,:)<patch+1))=-1;
        f1(2,find(f1(2,:)>(height-patch-1)))=-1;
        
        f2(1,find(f2(1,:)<patch+1)) = -1;
        f2(1,find(f2(1,:)>(width-patch-1))) = -1;
    
        f2(2,find(f2(2,:)<patch+1))=-1;
        f2(2,find(f2(2,:)>(height-patch-1)))=-1;
        
    
        for k= (1:pair_num) 
            idx = scoreindex(k);
    %         p(:,k)=[f1(1,matches(1,idx)); f1(2,matches(1,idx))];
    %         p_corr(:,k)=[f2(1,matches(2,idx)); f2(2,matches(2,idx))];
            
            
            if(round(f1(1,matches(1,idx)))~=-1 && round(f1(2,matches(1,idx)))~=-1 && round(f2(1,matches(2,idx)))~=-1 && round(f2(2,matches(2,idx)))~=-1)
                fprintf(fid,' %d',round(f1(1,matches(1,idx))));
                fprintf(fid,' %d',round(f1(2,matches(1,idx))));
                fprintf(fid,' %d',round(f2(1,matches(2,idx))));
                fprintf(fid,' %d\n',round(f2(2,matches(2,idx))));
            end
            
        end
        
        fclose(fid);
%         waitbar(i/picnum,fbar,'Processing data…');
    end
%     close(fbar);
end