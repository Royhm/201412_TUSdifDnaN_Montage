function [lionval] = LionDefine(exp)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% Define your experiment

% if ~exist('Cell')
%     Cell=1;
% end

if ~exist('exp')
    exp = 'Mark';
end

switch exp
    
%     case 'Old',
%         
%         %GaussFit
%         Bac=num2str(Cell);
%         BacStr='Fluo0Chan01Bac0003';
%         Mainfolder=strcat(initval.basepath,'Stacks/Tus/');
%         Stackpth=strcat(Mainfolder,BacStr);
%         d1{1}=readtimeseries(strcat(Stackpth,'/',BacStr,'Im'),'tif'); %read zstack
%         
%         %GaussCalcs
%         MainPathTus=strcat(initval.basepath,'Stacks/Tus/DataMULTI/');
%         MainPathdif=strcat(initval.basepath,'Stacks/dif/DataMULTI/');
        
    case 'Mark',
        
        %GaussFit
        
        lionval.channr=1;
        lionval.viewchan='RFP';
        lionval.viewbac=1; 
        
        lionval.difchan='CFP';
        lionval.bacfolder='C:\Users\water\Documents\GitHub\Data\141230_dnaN_dif_tus\Figures\BacPics\';
        lionval.OSslash='\';
        
        % This should be outside of the case as every string introduced are
        % defined in Kymocode
        
        lionval.chanfolder=strcat(lionval.bacfolder,'Channel_0',num2str(lionval.channr),lionval.OSslash);
        lionval.Mainfolder=strcat(lionval.chanfolder,lionval.viewchan,lionval.OSslash);
        lionval.diffolder=strcat(lionval.chanfolder,lionval.difchan,lionval.OSslash);
        % lionval.Stackpth=strcat('Fluo0Chan0',num2str(lionval.channr),'Bac00',num2str(Cell,'%02.0f'));
        
        %GaussCalc
        MainPathTus='D:\Users\water\OneDrive\Documents\BEP\Data\141230_dnaN_dif_tus\Figures\BacPics\';
        MainPathdif='D:\Users\water\OneDrive\Documents\BEP\Data\141230_dnaN_dif_tus\Figures\BacPics\';
    
    case 'RoySim'
        
        %GaussFit
        lionval.Mainfolder='/Users/rleeuw/Work/DataAnalysis/BlurLab/DiffusionTests/';
        lionval.Stackpth=strcat(num2str(Cell),'/');
        lionval.Channel=num2str(Cell);
        
        %GaussCalcs
        MainPathTus='/Users/rleeuw/Work/DataAnalysis/BlurLab/DiffusionTests/Results/';
        MainPathdif='/Users/rleeuw/Work/DataAnalysis/BlurLab/DiffusionTests/Results/';
end


end
