function [Bettermesh,Bacmask] = TigerCutV2(Meshdata,flimg,init,Extrabound)

    disp(sprintf('-----\nOperating TigerCut'))

    frames = size(Meshdata,2);
    cells = size(Meshdata{1},2);
    flimgsize = size(flimg);

    [maxX,minX,maxY,minY]=deal(zeros(1,frames));
    Bettermesh = cell(cells,frames);
    Cellbox = zeros(cells,frames,4);

    bacfolder = strcat(init.bacpath,init.flimgname);

    if ~exist(bacfolder,'dir')
        mkdir(bacfolder)
    end

    for celli = 1:cells;
        for frami = 1:frames;
            Bettermesh{celli,frami} = Meshdata{frami}{celli}.mesh;

            % Add translation to meshes
            
            if ~isequal(init.pcresize,1)
                Bettermesh{celli,frami} = double(init.pcresize*Bettermesh{celli,frami});
            end

            if ~isequal(init.pctrans,[0,0])
                Bettermesh{celli,frami}(:,1) = init.pctrans(1) + Bettermesh{celli,frami}(:,1);
                Bettermesh{celli,frami}(:,2) = -init.pctrans(2) + Bettermesh{celli,frami}(:,2);
                Bettermesh{celli,frami}(:,3) = init.pctrans(1) + Bettermesh{celli,frami}(:,3);
                Bettermesh{celli,frami}(:,4) = -init.pctrans(2) + Bettermesh{celli,frami}(:,4);
            end  

            % Find mesh maxima and minima
            maxmesh = max(Bettermesh{celli,frami});
            minmesh = min(Bettermesh{celli,frami});

            maxX(frami) = max(maxmesh(1),maxmesh(3));
            minX(frami) = min(minmesh(1),minmesh(3));
            maxY(frami) = max(maxmesh(2),maxmesh(4));
            minY(frami) = min(minmesh(2),minmesh(4));
        end
        Cellbox(celli,frami,1) = min(minX(:));
        Cellbox(celli,frami,2) = max(maxX(:));
        Cellbox(celli,frami,3) = min(minY(:));
        Cellbox(celli,frami,4) = max(maxY(:));
    end

    Xboundresized = Extrabound/init.pcresize;

    % Find size of bacpic and the boundary indeces for each frame
    [BCellbox, bacsize, ~] = findbound(Cellbox,cells,frames,Xboundresized);

    % Remove cells that move out of the immage
    [BCellbox,bacsize,Bettermesh] = removeoutbound(BCellbox,bacsize,Bettermesh,flimgsize,frames);

    ncells = size(Bettermesh,1);
    Bacmask = cell(ncells,frames);

    disp('Creating Bacpics')

    for celli = 1:ncells;
        bacpath=strcat(bacfolder,init.OSslash,'Cell_',num2str(celli,'%03.0f'),init.OSslash);

        if ~exist(bacpath,'dir')
            mkdir(bacpath)
        end

        for frami = 1:frames;
            
            if numel(flimgsize) == 2
                imageframe = double(flimg(:,:)); % ,frami-1));
            else
                imageframe = double(flimg(:,:,frami-1));
            end
            
            thismesh = Bettermesh{celli,frami};
            thisBbox = BCellbox(celli,frami,:);
            thisbacsize = bacsize(celli,:);
            
            % create bacpic and save mask
            nmask = createbac(init,imageframe,thismesh,thisBbox,thisbacsize,Rbacpath,frami);          
            Bacmask{celli,frami} = nmask;
        end    
    end
    
    disp(sprintf('TigerCut done \n-----'))
end

function [BCellbox, bacsize, baczero] = findbound(Cellbox,cells,frames,bound)

    [framesize, baczero] = deal(zeros(cells,frames,2));
    BCellbox = zeros(cells,frames,4);
    bacsize = zeros(cells,2);
    
    for celli = 1:cells;
        for frami = 1:frames;
            framesize(celli,frami,1) = Cellbox(celli,frami,2)-Cellbox(celli,frami,1);
            framesize(celli,frami,2) = Cellbox(celli,frami,4)-Cellbox(celli,frami,2);
        end
        
        bacsize(celli,1) = max(framesize(celli,:,1)) + 2*bound;
        bacsize(celli,2) = max(framesize(celli,:,2)) + 2*bound;
        
        for frami = 1:frames;
            baczero(celli,frami,1) = (Cellbox(celli,frami,2) + Cellbox(celli,frami,1)-bacsize(celli,1))/2;
            baczero(celli,frami,2) = (Cellbox(celli,frami,4) + Cellbox(celli,frami,3)-bacsize(celli,2))/2;
            
            BCellbox(celli,frami,1) = baczero(celli,frami,1) - bound;
            BCellbox(celli,frami,2) = baczero(celli,frami,1) + bacsize(celli,1) - bound;
            BCellbox(celli,frami,3) = baczero(celli,frami,2) - bound;
            BCellbox(celli,frami,4) = baczero(celli,frami,2) + bacsize(celli,2) - bound;        
        end 
    end
end

function [BCellbox,bacsize,Bettermesh] = removeoutbound(BCellbox,bacsize,Bettermesh,flimgsize,frames)
    
    % Find cells whose bounds are outside the FL image
    for frami = 1:frames;
        xlow = find(BCellbox(:,frami,1) < 0);
        xhigh  = find(BCellbox(:,frami,2) > flimgsize(1));
        ylow = find(BCellbox(:,frami,3) < 0);
        yhigh = find(BCellbox(:,frami,4) > flimgsize(2));
    end
    
    fcells = xlow | xhigh | ylow | yhigh;

    % Remove cells our of bounds of FL image
    for fcelli = fcells;
        BCellbox(fcelli,:,:) = [];
        Bettermesh(fcelli,:) = [];
        bacsize(fcelli,:) = [];
    end
end

function nmask = createbac(init,imageframe,thismesh,thisBbox,thisbacsize,bacpath,frami)
            
    thisRbox = round(thisBbox);
    Rbacsize = round(thisbacsize);

    % Create mask from mesh
    thismeshl = [thismesh(:,1:2);thismesh(:,3:4)];
    thiscropmesh = round([thismeshl(:,1)-thisBbox(1), thismeshl(:,2)-thisBbox(3)]/init.pcresize);
    mask = poly2mask(thiscropmesh(:,2)',thiscropmesh(:,1)',thismsize(1),thismsize(2));

    % Create bacpic from Cellbox

    croppedimg = imageframe(thisRbox(1):thisRbox(1)+Rbacsize(1),thisRbox(3):thisRbox(3)+Rbacsize(2));

    % Remove non-cell pixels by applying mask to bacpic
    cimgsize = size(croppedimg);
    nmask = double(imresize(mask,cimgsize));
    
    bacpic = uint16(nmask.*croppedimg);
    thisbacpath = strcat(num2str(frami,'%03.0f'),'.tif');
    imwrite(bacpic,strcat(bacpath,thisbacpath));
end