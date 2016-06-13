function [skip,fault,previous] = ViewbacUI2(f,Bacpics,Bacmesh,X,BX,celli,Title)

frames = size(Bacmesh{1},2);
[chans, cells] = size(X);
skip = 0;
fault = 0;
previous = 0;

currentbac = ['Bacpic ',num2str(celli),'/',num2str(cells)];

%% Create push buttons
Skip = uicontrol('Style', 'pushbutton', 'String', 'Skip all',...
    'Position', [10 10 50 30],...
    'Callback',@Skipall);    

bac = uicontrol('Style','text',...
    'Position',[150 15 120 15],...
    'String',currentbac);

Prev = uicontrol('Style', 'pushbutton', 'String', 'Previous Cell',...
    'Position', [280 10 100 30],...
    'Callback', @GoPrev);

Disr = uicontrol('Style', 'pushbutton', 'String', 'Disregard Cell',...
    'Position', [400 10 100 30],'BackgroundColor',[1 0.6 0.6],...
    'Callback', @Savefault);

Next = uicontrol('Style', 'pushbutton', 'String', 'Next Cell',...
    'Position', [520 10 100 30],...
    'Callback',@Closefigure);

%% Plot first frame
for chan = 1:chans;
    ax(chans) = subplot(1,chans,chan);
    set(gca,'tag',num2str(chan))

    title(Title{chan})

    x = X{chan,celli};
    bx = BX{chan,celli};

    hold on
    imagesc(Bacpics{chan}{celli,1});
    plot(Bacmesh{chan}{celli,1}(:,1),Bacmesh{chan}{celli,1}(:,2),'w',...
        Bacmesh{chan}{celli,1}(:,3),Bacmesh{chan}{celli,1}(:,4),'w','LineWidth',2)
    for spoti = 1:length(x)
        plot(x{spoti}(1,2),x{spoti}(1,4),'rx','LineWidth',2)
    end
    for spoti = 1:length(bx)
        plot(bx{spoti}(1,2),bx{spoti}(1,4),'kx','LineWidth',2)
    end
    axis off
    hold off
    clear x bx
end



%% Add slider if theres more than 1 frame        
if frames > 1
    sld = uicontrol('Style', 'slider',...
        'Min',1,'Max',frames,'Value',1,...
        'Position', [640 12 250 18],...
        'Callback', @selectframe); 

    txt = uicontrol('Style','text',...
        'Position',[680 30 120 15],...
        'String','Frame');
end

%%
Rspots = [];

set(f,'HitTest','off')
set(f,'WindowButtonDownFcn',@clicky)





uiwait(f) % Wait for button click

%% functions for the buttons and sliders

    function selectframe(source,callbackdata)
        frami = round(source.Value);
        currentframe = ['Frame ',num2str(frami),'/',num2str(frames)];
        
        frm = uicontrol('Style','text',...
            'Position',[900 15 50 15],...
            'String',currentframe);

        for chan = 1:chans;
            ax(chans)=subplot(1,chans,chan);
            title(Title{chan})
            
            x = X{chan,celli};
            bx = BX{chan,celli};
            
            hold on
            imagesc(Bacpics{chan}{celli,frami})
            plot(Bacmesh{chan}{celli,frami}(:,1),Bacmesh{chan}{celli,frami}(:,2),'w',...
                Bacmesh{chan}{celli,frami}(:,3),Bacmesh{chan}{celli,frami}(:,4),'w','LineWidth',2)
            for spoti = 1:length(x)
                plot(x{spoti}(frami,2),x{spoti}(frami,4),'rx','LineWidth',2)
            end
            for spoti = 1:length(bx)
                plot(bx{spoti}(frami,2),bx{spoti}(frami,4),'kx','LineWidth',2)
            end
            axis off
            hold off
            clear x bx
        end
    end

    function Closefigure(hObject, eventdata, handles)
        uiresume(f)
        clf(f)
    end

    function Skipall(hObject, eventdata, handles)
        skip = 1;
        uiresume(f)
        clf(f)
    end

    function Savefault(hObject, eventdata, handles)
        fault = 1;
        uiresume(f)
        clf(f)
    end

    function GoPrev(hObject, eventdata, handles)
        previous = 1;
        uiresume(f);
        clf(f)
    end

    function clicky(gcbo,eventdata,handles)
        clickXY = get(gca,'CurrentPoint');
        clickxy = [clickXY(1,1),clickXY(1,2)];
        clickchan = str2double((get(gca,'tag')));
        
        if frames > 1
            frame = round(sld.Value);
        else
            frame = 1;
        end
        
        thisx = X{clickchan,celli};
        spots = size(thisx,2);
        
        spotx = zeros(spots,2);
        for spotn = 1:spots
            spotx(spotn,1) = thisx{spotn}(frame,2);
            spotx(spotn,2) = thisx{spotn}(frame,4);
        end
        
        [minval,minidx] = min(sqrt(sum(bsxfun(@minus,clickxy,spotx).^2,2)));
        if minval < 0.5
            removespot = [clickchan,minidx]
        else
            removespot = []
        end

    end
end