clc
clear all

%%
fprintf('Select Data Folder');
init.datapath = uigetdir(pwd,'Select Data Folder');
init.OSslash = '/';

fprintf('\nSelect Stack Folder');
init.stackpath = uigetdir(init.datapath,'Select Stack Folder');

Listing=dir(init.stackpath);
init.flimg=Listing(3).name;

fprintf('\nSelect Oufti Mesh');
[init.meshname,init.meshpath] = uigetfile(init.datapath,'Select Oufti Mesh');

init.pcresize = 1;
init.pctrans = [0,0];

init.Extrabound = 10;
init.strelval = 6;
init.Writebac = 0;
init.TigerCutSR = 1;

%%
init.bacpath = init.datapath;
init.flimgname = {'CroppedStack.tif'};

javaaddpath('mij.jar')
javaaddpath('ij.jar')

MIJ.start
MIJ.run('Image Sequence...',strcat('open=[',init.stackpath,']'))
MIJ.run('Tiff...',strcat('path=[',init.datapath,init.flimg,']'))
MIJ.closeAllWindows
MIJ.exit

%%
flimg = readtimeseries(strcat(init.stackpath,init.OSslash,init.flimg));

Ouftiout = load(strcat(init.meshpath,init.meshname),'cellList');
Meshdata = Ouftiout.cellList.meshData;
chan = 1;

%%

[Bettermesh,BCellbox,Bacsize,Bacmask,CBacmask,Bacpics,NMBacpics,nflimg] = TigerCut(init,chan,Meshdata,flimg);

%%

frames = size(nflimg,3);
nimgpath = strcat(init.datapath,'/TigerCut_',init.flimg);

fprintf('\nWriting frame ')

for frami = 1:frames;
    imwrite(nflimg(:,:,frami),nimgpath, 'writemode', 'append');
    
    if frami>1
        for j=0:log10(frami-1)
            fprintf('\b'); % delete previous counter display
        end
    end
    fprintf('%d', frami);
end