function CodFinalProiect
    % iau marimea ecranului ca sa centrez fereastra
    scr = get(0, 'ScreenSize');
    
    % fereastra principala
    f = figure('Name','WLAN System-Level Simulation Explorer','NumberTitle','off',...
               'Position',[100 100 1100 750], 'Color',[0.95 0.95 0.95]);

    % grupul de taburi
    tgroup = uitabgroup(f);
    tabConfig = uitab(tgroup, 'Title', 'Configuration & Topology');
    tabGantt  = uitab(tgroup, 'Title', 'Packet Communication');
    tabPerf   = uitab(tgroup, 'Title', 'Performance Metrics');

    % tab 1 - configurare
    
    % panou pt harta
    pTop = uipanel(tabConfig,'Title','Network Topology','Position',[0.05 0.40 0.9 0.55]);
    axMap = axes(pTop, 'Position', [0.1 0.25 0.8 0.65]); grid on; hold on;
    
    % setari ap
    uicontrol(pTop,'Style','text','Position',[20 30 30 20],'String','AP:');
    hAP_X = uicontrol(pTop,'Style','edit','Position', [55 30 40 20],'String','50','Callback',@updateMap);
    hAP_Y = uicontrol(pTop,'Style','edit','Position',[100 30 40 20],'String','50','Callback',@updateMap);
    
    % setari sta 1
    uicontrol(pTop,'Style','text','Position',[160 30 40 20],'String','STA1:');
    hS1_X = uicontrol(pTop,'Style','edit','Position',[205 30 40 20],'String','15','Callback',@updateMap);
    hS1_Y = uicontrol(pTop,'Style','edit','Position',[250 30 40 20],'String','50','Callback',@updateMap);
    
    % setari sta 2
    uicontrol(pTop,'Style','text','Position',[310 30 40 20],'String','STA2:');
    hS2_X = uicontrol(pTop,'Style','edit','Position',[355 30 40 20],'String','85','Callback',@updateMap);
    hS2_Y = uicontrol(pTop,'Style','edit','Position',[400 30 40 20],'String','50','Callback',@updateMap);
    
    % panoul de jos cu setarile simularii
    pParam = uipanel(tabConfig,'Title','Simulation Settings','Position',[0.05 0.05 0.9 0.32]);
    col1 = 20; col2 = 600; yBase = 65;
    
    % durata simularii
    uicontrol(pParam,'Style','text','Position',[col1 yBase 120 20],'String','simulationTime:');
    hSimTime = uicontrol(pParam,'Style','edit','Position',[150 yBase 60 20],'String','1');
    
    % alte optiuni din meniu
    uicontrol(pParam,'Style','text','Position',[col1 yBase-30 120 20],'String','macAbstraction:');
    hMAC = uicontrol(pParam,'Style','popupmenu','Position',[150 yBase-30 100 20],'String',{'true','false'},'Value',2);
    
    uicontrol(pParam,'Style','text','Position',[col1 yBase-60 120 20],'String','phyAbstraction:');
    hPHY = uicontrol(pParam,'Style','popupmenu','Position',[150 yBase-60 180 20],'String',{'tgax-evaluation-method','none'});
    
    % checkbox-uri
    hPktViz = uicontrol(pParam,'Style','checkbox','Position',[col2 yBase 220 20],'String','enablePacketVisualization','Value',1);
    hNodePerf = uicontrol(pParam,'Style','checkbox','Position',[col2 yBase-30 220 20],'String','enableNodePerformancePlot','Value',1);
    hCapture = uicontrol(pParam,'Style','checkbox','Position',[col2 yBase-60 220 20],'String','capturePacketsFlag','Value',1);
    
    % buton de run
    uicontrol(tabConfig,'Style','pushbutton','Position',[450 10 200 35],...
              'String','RUN SIMULATION','FontWeight','bold','BackgroundColor',[0.2 0.6 0.2],'ForegroundColor','white',...
              'Callback', @runSimulation);

    % pregatesc taburile pentru rezultate
    axGantt = axes(tabGantt, 'Position', [0.05 0.35 0.9 0.6]);
    legAx = axes(tabGantt, 'Position', [0.05 0.05 0.9 0.2], 'Visible', 'off');
    
    % grafice mici din ultimul tab
    axPerf1 = subplot(3,1,1, 'Parent', tabPerf);
    axPerf2 = subplot(3,1,2, 'Parent', tabPerf);
    axPerf3 = subplot(3,1,3, 'Parent', tabPerf);

    % desenez harta initiala
    updateMap();

    % functia ce actualizeaza harta cand modific coord
    function updateMap(~,~)
        cla(axMap);
        % citesc valorile din casute
        ap = [str2double(hAP_X.String) str2double(hAP_Y.String)];
        s1 = [str2double(hS1_X.String) str2double(hS1_Y.String)];
        s2 = [str2double(hS2_X.String) str2double(hS2_Y.String)];
        
        hold(axMap, 'on');
        % pun punctele pe grafic
        plot(axMap, ap(1), ap(2), 'rs', 'MarkerSize', 12, 'LineWidth', 2, 'DisplayName', 'AP');
        plot(axMap, s1(1), s1(2), 'bo', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'STA 1');
        plot(axMap, s2(1), s2(2), 'go', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'STA 2');
        
        xlim(axMap, [0 100]); ylim(axMap, [0 100]); grid(axMap, 'on');
        legend(axMap, 'Location', 'northeastoutside');
        title(axMap, 'Network Map');
    end

    % functia principala de sim
    function runSimulation(~, ~)
        % iau datele introduse
        simTime = str2double(hSimTime.String);
        ap = [str2double(hAP_X.String) str2double(hAP_Y.String)];
        s1 = [str2double(hS1_X.String) str2double(hS1_Y.String)];
        s2 = [str2double(hS2_X.String) str2double(hS2_Y.String)];
        
        % calcul distanta statii - ap
        d1 = sqrt(sum((s1-ap).^2));
        d2 = sqrt(sum((s2-ap).^2));

        % calcul pm retea
        
        % throughput (viteza) scade cu distanta
        th1 = 10 * exp(-d1/70); 
        th2 = 10 * exp(-d2/70);
        
        % packet loss (pierderile) cresc daca e departe
        pl1 = max(0, min(1, (d1-50)/40)); 
        pl2 = max(0, min(1, (d2-50)/40));
        
        % latenta
        lat1 = 0.2 + (d1/500);
        lat2 = 0.2 + (d2/500);
        
        % calculez si pentru ap (suma si media)
        thAP = th1 + th2; 
        plAP = (pl1 + pl2) / 2;
        latAP = (lat1 + lat2) / 2;

        % desenez graficul cu pachete (gantt chart)
        cla(axGantt); hold(axGantt, 'on');
        cMap = [0.2 0.5 0; 1 1 1; 0.9 0.7 0; 0.1 0 0.7; 0.98 0.85 0.7; 0.7 0.1 0.1]; 
        
        t = 0; 
        simLim = simTime; if simLim > 0.5, simLim = 0.5; end
        
        rowLabels = {'AP', 'STA 1', 'STA 2'};
        
        while t < simLim
            dur = rand * 0.004 + 0.001;
            
            % pentru fiecare nod (ap, sta1, sta2)
            for i = 1:3
                % vad ce packet loss are nodul curent
                if i == 1 
                    currentPL = plAP;
                elseif i == 2
                    currentPL = pl1;
                else
                    currentPL = pl2;
                end
                
                % sansele sa trimita pachet sau sa dea eroare
                prob = [0.3, 0.1, 0.1, 0.3, 0.1, 0]; 
                if i == 1
                    prob(1) = 0.5; % ap-ul e mai activ
                end
                
                prob(6) = currentPL * 2; % sansa de eroare
                prob = prob / sum(prob); 
                
                state = find(rand <= cumsum(prob), 1);
                
                % desenez pachetul
                rectangle('Parent', axGantt, 'Position',[t, i-0.4, dur, 0.8], ...
                          'FaceColor', cMap(state,:), 'EdgeColor', [0.8 0.8 0.8]);
            end
            t = t + dur + rand*0.002;
        end
        
        set(axGantt, 'YTick', 1:3, 'YTickLabel', rowLabels, 'XLim', [0 simLim]);
        title(axGantt, 'Packet Communication (AP & Stations)');
        xlabel(axGantt, 'Time (s)');

        % legenda
        cla(legAx); hold(legAx, 'on');
        lbls = {'Transmission','Idle','Contention','Reception (destined to node)','Reception','Failure'};
        xPos = linspace(0.05, 0.85, 6);
        for i = 1:6
            rectangle('Parent', legAx, 'Position', [xPos(i), 0.6, 0.08, 0.3], 'FaceColor', cMap(i,:), 'EdgeColor', 'k');
            text(xPos(i)+0.04, 0.4, lbls{i}, 'FontSize', 8, 'Parent', legAx, ...
                 'FontWeight', 'bold', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
        end
        xlim(legAx, [0 1]); ylim(legAx, [0 1]); axis(legAx, 'off');

        % actualizare grafice de performanta
        labels = {'AP', 'STA 1', 'STA 2'};
        
        % throughput
        bar(axPerf1, [thAP th1 th2], 0.5, 'FaceColor', [0.2 0.45 0.75]);
        title(axPerf1, 'Throughput'); ylabel(axPerf1, 'Mbps'); grid(axPerf1, 'on');
        set(axPerf1, 'XTickLabel', labels); 
        
        % packet loss
        bar(axPerf2, [plAP pl1 pl2], 0.5, 'FaceColor', [0.7 0.2 0.2]);
        title(axPerf2, 'Packet Loss Ratio'); ylabel(axPerf2, 'Ratio (0-1)'); grid(axPerf2, 'on');
        set(axPerf2, 'XTickLabel', labels); ylim(axPerf2, [0 1.1]);
        
        % latenta
        bar(axPerf3, [latAP lat1 lat2], 0.5, 'FaceColor', [0.2 0.6 0.2]);
        title(axPerf3, 'Latency'); ylabel(axPerf3, 's'); grid(axPerf3, 'on');
        set(axPerf3, 'XTickLabel', labels); 
        
        % schimb tabul automat
        tgroup.SelectedTab = tabPerf;
    end
end
