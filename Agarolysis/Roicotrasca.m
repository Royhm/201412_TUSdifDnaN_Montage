function Roicotrasca(Imgspth,Imgname,Outname,Beampth,Resizeval,Transval,BCpreset)
%% Presets
if nargin < 5;
    BCpreset = {5,0.01,'sh'};
    Resizeval = 1;
    Transval = [0,0];
end

%% Loading the images
Agarolysispth = 'C:\Users\water\Documents\GitHub\KymoCode\Agarolysis\';
backcorpth = strcat(Agarolysispth, 'Backcor\');
addpath(backcorpth)

% Load Beam

flpth = strcat(Imgspth,Imgname);
FLinfo = imfinfo(flpth);

Beamimg = im2double(imread(Beampth));
maxVAlue= max(max(Beamimg));
NewBeamImg = Beamimg./maxVAlue;

fNameToWriteIllumCorrected = strcat(Imgspth,Outname);

num_images = numel(FLinfo);

for k = 1:num_images;
    disp(['Processing image ',num2str(k),' out of ',num2str(num_images)])
    
    FLimg = im2double(imread(flpth,k,'Info',FLinfo));
    % flrb = im2double(imread(strcat(Imgpth,'CFP_R_I.tif'),k));
    imgS = size(FLimg);
    

%     %% Backcor
%     noiseall1 = [];
%     noiseall2 = [];
%     noise1=zeros(imgS);
%     halve1 = round(imgS(2)/2);
%     halve2 = (imgS(2)-halve1+1);
%     for j = 1: imgS(1);
%         noise1(j,1:halve1) = backcor(linspace(1,halve1,halve1),FLimg(j,1:halve1),BCpreset{1},BCpreset{2},BCpreset{3});
%         noise1(j,halve2:imgS(2)) = backcor(linspace(halve2,imgS(2),halve1),FLimg(j,halve2:imgS(2)),BCpreset{1},BCpreset{2},BCpreset{3});
%     end
%     FLimg = FLimg-noise1;
%     
%     FLimg(FLimg<0)=0;

    %% Illumunation Correction

    RIimg = double(imdivide(FLimg,NewBeamImg));
    
    %% Transformation
    
    RISTimg = imtranslate(imresize(RIimg,Resizeval),Transval,'FIllvalues',0);
    
    %% Write to file
    imwrite(uint16(65535*RIimg),fNameToWriteIllumCorrected,'WriteMode','append','Compression','none');

end

% figure
% hold on
% plot(FLdb(:))
% plot(flrb(:))
% plot(RIimg(:))
% plot(noise1(:))
% % plot(noise1)
% legend('Original','ImageJ','backcor','Detected noise')
% hold off
% 
% figure
% subplot(2,1,1)
% hold on
% plot(flrb(:))
% plot(RIimg(:))
% legend('ImageJ','backcor')
% hold off
% subplot(2,1,2)
% plot(flrb(:)-RIimg(:))
% legend('ImageJ - backcor')
% 
% figure
% subplot(1,3,1);imagesc(FLimg)
% subplot(1,3,2);imagesc(RIimg)
% subplot(1,3,3);imagesc(flrb)

disp('Done')
toc
end
