%%  Função para plotar os resultados do PCA aplicado ao problema de conflito de controle no Fluxo de Potência

function [PlotPC, PlotSignals, PCVariance] = Plota_Conflitos_Por_PCA(J,TipoMatrizJ_PCA,TapC,BarCTap,BarGer,BarCGer,NBar, IndBar, FptGerA, FptGerE, Area, DHVDC, Vmin, SM, SA, NPlot, ControleTen, ControleRes, GovernorControl, IsPlotOn)

IsPlotPolarOn = 1;
Colors = {'#0072BD' '#D95319' '#EDB120' '#7E2F8E' '#77AC30' '#4DBEEE' '#A2142F' 'r' 'g' 'b' 'c' 'm' 'y' 'k'};

if (TipoMatrizJ_PCA == 0)
    data = inv(J);
else
    Jac = J(1:2*NBar,1:2*NBar);
    Jsx = J(1:2*NBar,2*NBar+1:end);
    Jyu = J(2*NBar+1:end,1:2*NBar);
    Jyx = J(2*NBar+1:end,2*NBar+1:end);
    Jcs = Jyx - Jyu*(Jac^-1)*Jsx;
    data = inv(Jcs);
end
[~,N] = size(data);
mn = mean(data,2);
data = data - repmat(mn,1,N);
Y = data' / sqrt(N-1);
[~,S,PC] = svd(Y'*Y);
S = diag(S);
V = abs(S);
PCVariance = V;
signals = PC' * data;

%% Parâmetros Necessários
NumV = sum(V>Vmin);
if (GovernorControl == 1)
    NgerE = size(FptGerE,1);
    NgerA = 0;
else
    NgerE = 0;
    if (ControleRes == 1)
        NgerA = size(FptGerA,1);
    else
        NgerA = 0;
    end
end
if (ControleTen == 1)
    NTap = length(TapC(:,1));
else
    BarCGer = BarGer;
    NTap = 0;
end
NGer = length(BarCGer);
NTh = 0;
Nhvdc = size(DHVDC,1);

PlotSignals = cell(NumV,1);
PlotPC = cell(NumV,1);

%% PLOTS PARA 1PC
if(NPlot>=1)
    if V(1)>Vmin
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS VARIÁVEIS CONTROLADAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for j=1:NumV
        
            [AbsSignalsSort, ISignals] = sort(abs(signals(j,:)),'descend');
            NPontos = sum(AbsSignalsSort > SM);
            if (NPontos < 2)
                NPontos =2;
            end
            Psignals = [signals(j,ISignals(1:NPontos))'  ISignals(1:NPontos)'];
    
            ResArray = plotRes(NPontos, NgerA, NGer, NTap, NgerE, NTh, Nhvdc, FptGerA, FptGerE, Area, Psignals, TipoMatrizJ_PCA, NBar, BarCGer, BarCTap, BarGer, IndBar, IsPlotOn);
    
            PlotSignals{j} = [num2cell(ResArray) num2cell(Psignals(:,1))];
    
            if (IsPlotOn == 1)
                figure;
                catStrArray = categorical(ResArray);
                catStrArray = reordercats(catStrArray,string(catStrArray));
                bar(catStrArray,Psignals(:,1))
                if(PCVariance(j) < 5)
                    title(strcat('Variáveis Controladas Projetadas na',{' '},num2str(j),'ª CP'),'Color','red')
                else
                    title(strcat('Variáveis Controladas Projetadas na',{' '},num2str(j),'ª CP'))
                end
                ylabel(strcat(num2str(j),'ª CP'))
                grid on;
                Ymax = max(Psignals(:,1));
                Ymin = min(Psignals(:,1));
                ylim([Ymin*1.1*(Ymin<0), Ymax*1.1*(Ymax>0)]);
            end
    
        end
    
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS VARIÁVEIS DE CONTROLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for j=1:NumV    
            [AbsPCSort, IPC] = sort(abs(PC(:,j)),'descend');
            NPontos = sum(AbsPCSort > SA);
            if (NPontos < 2)
                NPontos =2;
            end
            PPC = [PC(IPC(1:NPontos),j)  IPC(1:NPontos)];

            VarArray = plotVars(NPontos, NgerA, NGer, NTap, NgerE, NTh, Nhvdc, FptGerA, FptGerE, Area, PPC, TipoMatrizJ_PCA, NBar, BarGer, IndBar, TapC, IsPlotOn);
    
            PlotPC{j} = [num2cell(VarArray) num2cell(PPC(:,1))];
    
            if (IsPlotOn == 1)
                figure;
                catStrArray = categorical(VarArray);
                catStrArray = reordercats(catStrArray,string(catStrArray));
                bar(catStrArray,PPC(:,1))
                if(PCVariance(j) < 5)
                    title(strcat('Efeito das Variáveis de Controle na',{' '},num2str(j),'ª CP'),'Color','red')
                else
                    title(strcat('Efeito das Variáveis de Controle na',{' '},num2str(j),'ª CP'))
                end
                ylabel(strcat('Efeito(',num2str(j),'ª CP)'))
                grid on;
                Ymax = max(PPC(:,1));
                Ymin = min(PPC(:,1));
                ylim([Ymin*1.1*(Ymin<0), Ymax*1.1*(Ymax>0)]);
            end
        end
    end
end


%% PLOTS Para 2 PCs
if (NPlot>=2)
    if V(2)>Vmin
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS VARIÁVEIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for iii=1:NumV-1
            for jjj=iii+1:NumV
                signals2 = signals(jjj,:).^2 + signals(iii,:).^2;
                [AbsSignalsSort, ISignals] = sort(abs(signals2),'descend');
                NPontos = sum(AbsSignalsSort > SM^2);
                if (NPontos < 2)
                    NPontos =2;
                end
                Psignals = [signals2(ISignals(1:NPontos))'  ISignals(1:NPontos)'];

                if (IsPlotOn == 1)
                    ResArray = plotRes(NPontos, NgerA, NGer, NTap, NgerE, NTh, Nhvdc, FptGerA, FptGerE, Area, Psignals, TipoMatrizJ_PCA, NBar, BarCGer, BarCTap, BarGer, IndBar, IsPlotOn);
                    figure;
                    if (IsPlotPolarOn == 1)
                        for iplot = 1:length(Psignals(:,2))
                            c = compass(signals(iii,Psignals(iplot,2)),signals(jjj,Psignals(iplot,2)));
                            c.Color = Colors{iplot};
                            text(signals(iii,Psignals(iplot,2)),signals(jjj,Psignals(iplot,2)),ResArray(iplot), 'FontSize', 16, 'color',Colors{iplot})
                            hold on;
                        end
                        
                        
                        if(PCVariance(jjj) < 5)
                            title(strcat('Vetores das variáveis Controladas - ',{' '},num2str(iii),'ª e',{' '},num2str(jjj),'ª CP'),'Color','red')
                        else
                            title(strcat('Vetores das variáveis Controladas -',{' '},num2str(iii),'ª e',{' '},num2str(jjj),'ª CP'))
                        end
                    else
                        plot(signals(iii,Psignals(:,2)),signals(jjj,Psignals(:,2)),'b.','markersize',15);
                        text(signals(iii,Psignals(:,2)),signals(jjj,Psignals(:,2)),ResArray)
                        Xmax = max(signals(iii,:));
                        Xmin = min(signals(iii,:));
                        Ymax = max(signals(jjj,:));
                        Ymin = min(signals(jjj,:));
                        XYlim = max([Xmax, Ymax, abs(Xmin), abs(Ymin)]);
                        ylim([-XYlim*1.1, XYlim*1.1]);
                        xlim([-XYlim*1.1, XYlim*1.1]);
                        grid on;
                        xlabel(strcat('CP ',num2str(iii)))
                        ylabel(strcat('CP ',num2str(jjj)))
                   end
                    if(PCVariance(jjj) < 5)
                        title(strcat('Variáveis Controladas Projetadas na',{' '},num2str(iii),'ª e',{' '},num2str(jjj),'ª CP'),'Color','red')
                    else
                        title(strcat('Variáveis Controladas Projetadas na',{' '},num2str(iii),'ª e',{' '},num2str(jjj),'ª CP'))
                    end
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS AMOSTRAS - EQUAÇÕES DE RESÍDUO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for iii=1:NumV-1
            for jjj=iii+1:NumV
                PC2 = PC(:,jjj).^2 + PC(:,iii).^2;
                [AbsPCSort, IPC] = sort(abs(PC2),'descend');
                NPontos = sum(AbsPCSort > SA^2);
                if (NPontos < 2)
                    NPontos =2;
                end
                PPC = [PC2(IPC(1:NPontos))  IPC(1:NPontos)];

                if (IsPlotOn == 1)
                    VarArray = plotVars(NPontos, NgerA, NGer, NTap, NgerE, NTh, Nhvdc, FptGerA, FptGerE, Area, PPC, TipoMatrizJ_PCA, NBar, BarGer, IndBar, TapC, IsPlotOn);
                    figure;
                    plot(PC(PPC(:,2),iii),PC(PPC(:,2),jjj),'b.','markersize',15);
                    text(PC(PPC(:,2),iii),PC(PPC(:,2),jjj),VarArray)
                    Xmax = max(PC(:,iii));
                    Xmin = min(PC(:,iii));
                    Ymax = max(PC(:,jjj));
                    Ymin = min(PC(:,jjj));
                    XYlim = max([Xmax, Ymax, abs(Xmin), abs(Ymin)]);
                    ylim([-XYlim*1.1, XYlim*1.1]);
                    xlim([-XYlim*1.1, XYlim*1.1]);
                    grid on;
                    xlabel(strcat('Efeito(CP ',num2str(iii),')'))
                    ylabel(strcat('Efeito(CP ',num2str(jjj),')'))
                    if(PCVariance(jjj) < 5)
                        title(strcat('Efeito das Vairáveis de Controle na',{' '},num2str(iii),'ª e',{' '},num2str(jjj),'ª CP'),'Color','red')
                    else
                        title(strcat('Efeito das Vairáveis de Controle na',{' '},num2str(iii),'ª e',{' '},num2str(jjj),'ª CP'))
                    end
                end
            end
        end  
    end
end

%% PLOTS Para 3 PCs
if (NPlot==3)
    if V(3)>Vmin
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS VARIÁVEIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        signals3 = signals(1,:).^2 + signals(2,:).^2 + signals(3,:).^2;
        [AbsSignalsSort, ISignals] = sort(abs(signals3),'descend');
        NPontos = sum(AbsSignalsSort > SM^2);
        if (NPontos < 2)
            NPontos =2;
        end
        Psignals = [signals3(ISignals(1:NPontos))'  ISignals(1:NPontos)'];

        if (IsPlotOn == 1)
            ResArray = plotRes(NPontos, NgerA, NGer, NTap, NgerE, NTh, Nhvdc, FptGerA, FptGerE, Area, Psignals, TipoMatrizJ_PCA, NBar, BarCGer, BarCTap, BarGer, IndBar, IsPlotOn);
            figure;
            plot3(signals(1,Psignals(:,2)),signals(2,Psignals(:,2)),signals(3,Psignals(:,2)),'b.','markersize',15);
            text(signals(1,Psignals(:,2)),signals(2,Psignals(:,2)),signals(3,Psignals(:,2)),ResArray)
            Xmax = max(signals(1,:));
            Xmin = min(signals(1,:));
            Ymax = max(signals(2,:));
            Ymin = min(signals(2,:));
            Zmax = max(signals(3,:));
            Zmin = min(signals(3,:));
            XYZlim = max([Xmax, Ymax, Zmax, abs(Xmin), abs(Ymin), abs(Zmin)]);
            ylim([-XYZlim*1.1, XYZlim*1.1]);
            xlim([-XYZlim*1.1, XYZlim*1.1]);
            zlim([-XYZlim*1.1, XYZlim*1.1]);


            grid on;
            xlabel('PC1')
            ylabel('PC2')
            zlabel('PC3')
            if(PCVariance(3) < 5)
                title('Controlled Variables Projected Onto the 3 First PCs','Color','red')
            else
                title('Controlled Variables Projected Onto the 3 First PCs')
            end      
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS AMOSTRAS - EQUAÇÕES DE RESÍDUO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        PC3 = PC(:,1).^2 + PC(:,2).^2 + PC(:,3).^2;
        [AbsPCSort, IPC] = sort(abs(PC3),'descend');
        NPontos = sum(AbsPCSort > SA^2);
        if (NPontos < 2)
            NPontos =2;
        end
        PPC = [PC3(IPC(1:NPontos))  IPC(1:NPontos)];

        if (IsPlotOn == 1)
            VarArray = plotVars(NPontos, NgerA, NGer, NTap, NgerE, NTh, Nhvdc, FptGerA, FptGerE, Area, PPC, TipoMatrizJ_PCA, NBar, BarGer, IndBar, TapC, IsPlotOn);
            figure;
            plot3(PC(PPC(:,2),1),PC(PPC(:,2),2),PC(PPC(:,2),3),'b.','markersize',15);
            text(PC(PPC(:,2),1),PC(PPC(:,2),2),PC(PPC(:,2),3),VarArray)
            Xmax = max(PC(:,1));
            Xmin = min(PC(:,1));
            Ymax = max(PC(:,2));
            Ymin = min(PC(:,2));
            Zmax = max(PC(:,3));
            Zmin = min(PC(:,3));
            xlim([Xmin*(0.9+0.2*(Xmin<0)), Xmax*(0.9+0.2*(Xmax>0))]);
            ylim([Ymin*(0.9+0.2*(Ymin<0)), Ymax*(0.9+0.2*(Ymax>0))]);
            zlim([Zmin*(0.9+0.2*(Zmin<0)), Zmax*(0.9+0.2*(Zmax>0))]);
            grid on;
            xlabel('Effeito(PC1)')
            ylabel('Effeito(PC2)')
            zlabel('Effeito(PC3)')
            if(PCVariance(3) < 5)
                title('Effect of Control Variables Onto the First 3 PCs','Color','red')
            else
                title('Effect of Control Variables Onto the First 3 PCs')
            end
            
        end
    end
end


%% Plota o Gráfico com todos os spectros.
if (IsPlotOn == 1)
    figure;
    Vaux = V;
    V(V<Vmin) = [];
    if isempty(V)
        V = Vaux;
        bar(V)
        xlabel('CP'), ylabel('Variância')
        title('Espectro dos CPs')
        ylim([0,1.2*max(V)])
    else
        bar(V)
        xlabel('CP'), ylabel('Variância')
        title(strcat('Espectro das CPs Maiores que', {' '} ,num2str(Vmin)))
        set(gca,'YScale','log')
        ylim([1,10*max(V)])
    end
end


%% FUNCTIONS
function ResArray = plotRes(NPontos, NgerA, NGer, NTap, NgerE, NTh, Nhvdc, FptGerA, FptGerE, Area, Psignals, TipoMatrizJ_PCA, NBar, BarCGer, BarCTap, BarGer, IndBar, IsPlotOn)
    DeltaChar = char(916);
    BarCGerAux = 0;
    ii = 0;
    jj = 1;
    ResArray = strings([NPontos,1]);
    if (NgerA>0)
        FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
        NgerAi = length(FptGerAi);
    end
    if (NgerE>0)
        FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
        NgerAi = length(FptGerAi);
        RefTh = unique(Area);
        NTh = size(RefTh,1);
    end
    for k=1:NPontos
        i = Psignals(k,2);
        if (TipoMatrizJ_PCA == 0)
            if i<= NBar
                ResArray(k,1) = strcat(DeltaChar,'P_{',num2str(IndBar(i)),'}');
            elseif i<=2*NBar
                ResArray(k,1) = strcat(DeltaChar,'Q_{',num2str(IndBar(i-NBar)),'}');
            elseif (i<=2*NBar+NGer)
                IndBarCGer = find (BarCGer == BarCGer(i-2*NBar));
                Aux = find(IndBarCGer == i-2*NBar);
                if (Aux == 1)
                    ResArray(k,1) = strcat(DeltaChar,'V_{',num2str(IndBar(BarCGer(i-2*NBar))),'}');
                else
                    ResArray(k,1) = strcat(DeltaChar,'Qg_{',num2str(IndBar(BarGer(IndBarCGer(Aux-1)))),'-',num2str(IndBar(BarGer(IndBarCGer(Aux)))),'}');
                end
            elseif (i<=2*NBar+NGer+NTap)
                ResArray(k,1) = strcat(DeltaChar,'V_{',num2str(IndBar(BarCTap(i-2*NBar-NGer))),'}');
            elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE)
                ii = ii + 1;
                ResArray(k,1) = strcat(DeltaChar,'PRes_{',num2str(IndBar(FptGerAi(ii))),'}');
                if (ii == NgerAi)
                    ii = 0;
                    jj = jj+1;
                    if(NgerE>0)
                        FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
                    else
                        FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
                    end
                    NgerAi = length(FptGerAi);
                end
            elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE+NTh)
                ResArray(k,1) = strcat(DeltaChar,'RefTh_{',num2str(IndBar(RefTh(i-(2*NBar+NGer+NTap+NgerA+NgerE)))),'}');
            elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE+NTh+Nhvdc*12)
                iaux = i - (2*NBar+NGer+NTap+NgerA+NgerE+NTh);
                iaux1 = floor(iaux/13)+1;
                iaux2 = mod(iaux,12);
                iaux2 = iaux2 + 12*(iaux2==0);
                switch iaux2
                    case 1
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{1,',num2str(iaux1),'}');
                    case 2
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{2,',num2str(iaux1),'}');
                    case 3
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{3,',num2str(iaux1),'}');
                    case 4
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{4,',num2str(iaux1),'}');
                    case 5
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{5,',num2str(iaux1),'}');
                    case 6
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{6,',num2str(iaux1),'}');
                    case 7
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{7,',num2str(iaux1),'}');
                    case 8
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{8,',num2str(iaux1),'}');
                    case 9
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{{9,',num2str(iaux1),'}');
                    case 10
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{10,',num2str(iaux1),'}');
                    case 11
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{11,',num2str(iaux1),'}');
                    case 12
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{12,',num2str(iaux1),'}');
                end
                ResArray(k,1) = Tstring;
            end
        else
            if i<= NGer
                IndBarCGer = find (BarCGer == BarCGer(i));
                Aux = find(IndBarCGer == i);
                if (Aux == 1)
                    ResArray(k,1) = strcat(DeltaChar,'V_{',num2str(IndBar(BarCGer(i))),'}');
                else
                    ResArray(k,1) = strcat(DeltaChar,'Qg_{',num2str(IndBar(BarGer(IndBarCGer(Aux-1)))),'-',num2str(IndBar(BarGer(IndBarCGer(Aux)))),'}');
                end
            elseif (i<=NGer+NTap)
                ResArray(k,1) = strcat(DeltaChar,'V_{',num2str(IndBar(BarCTap(i-NGer))),'}');
            elseif (i<=NGer+NTap+NgerA+NgerE)
                ii = ii + 1;
                ResArray(k,1) = strcat(DeltaChar,'PRes_{',num2str(IndBar(FptGerAi(ii))),'}');
                if (ii == NgerAi)
                    ii = 0;
                    jj = jj+1;
                    if(NgerE>0)
                        FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
                    else
                        FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
                    end
                    NgerAi = length(FptGerAi);
                end
            elseif (i<=NGer+NTap+NgerA+NgerE+NTh)
                ResArray(k,1) = strcat(DeltaChar,'RefTh_{',num2str(IndBar(RefTh(i-(NGer+NTap+NgerA+NgerE)))),'}');
            elseif (i<=NGer+NTap+NgerA+NgerE+NTh+Nhvdc*12)
                iaux = i - (NGer+NTap+NgerA+NgerE+NTh);
                iaux1 = floor(iaux/13)+1;
                iaux2 = mod(iaux,12);
                iaux2 = iaux2 + 12*(iaux2==0);
                switch iaux2
                    case 1
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{1,',num2str(iaux1),'}');
                    case 2
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{2,',num2str(iaux1),'}');
                    case 3
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{3,',num2str(iaux1),'}');
                    case 4
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{4,',num2str(iaux1),'}');
                    case 5
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{5,',num2str(iaux1),'}');
                    case 6
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{6,',num2str(iaux1),'}');
                    case 7
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{7,',num2str(iaux1),'}');
                    case 8
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{8,',num2str(iaux1),'}');
                    case 9
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{{9,',num2str(iaux1),'}');
                    case 10
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{10,',num2str(iaux1),'}');
                    case 11
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{11,',num2str(iaux1),'}');
                    case 12
                        Tstring = strcat(DeltaChar,'Y_{HVDC}_{12,',num2str(iaux1),'}');
                end
                ResArray(k,1) = Tstring;
            end
        end
    end
    if (IsPlotOn == 1)
        [~,inds,pos] = unique(ResArray);
        for n=1:length(inds)
            ipos = find(pos == inds(n));
            if (length(ipos) > 1)
                for i = 1:length(ipos)
                    ResArray(ipos(i)) = strcat( strrep(ResArray(ipos(i)),'}','')  +  '_{',num2str(i),'}}');
                end
            end
        end
    end
end




function VarArray = plotVars(NPontos, NgerA, NGer, NTap, NgerE, NTh, Nhvdc, FptGerA, FptGerE, Area, PPC, TipoMatrizJ_PCA, NBar, BarGer, IndBar, TapC, IsPlotOn)
    ii = 0;
    jj = 1;  
    DeltaChar = char(916);
    Th = char(952);
    RIGHTARROW = char(8594);
    VarArray = strings([NPontos,1]);
    if (NgerA>0)
        FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
        NgerAi = length(FptGerAi);
    end
    if (NgerE>0)
        FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
        NgerAi = length(FptGerAi);
        RefTh = unique(Area);
        NTh = size(RefTh,1);
    end
    for k=1:NPontos
        i = PPC(k,2);
        if (TipoMatrizJ_PCA == 0)
            if i<= NBar
                VarArray(k,1) = strcat(DeltaChar,Th,'_{',num2str(IndBar(i)),'}');
            elseif i<=2*NBar
                VarArray(k,1) = strcat(DeltaChar,'V_{',num2str(IndBar(i-NBar)),'}');
            elseif (i<=2*NBar+NGer)
                VarArray(k,1) = strcat(DeltaChar,'Qg_{',num2str(IndBar(BarGer(i-2*NBar))),'}');
            elseif (i<=2*NBar+NGer+NTap)
                VarArray(k,1) = strcat(DeltaChar,'a',num2str(IndBar(TapC(i-2*NBar-NGer,1))),'_',num2str(IndBar(TapC(i-2*NBar-NGer,2))));
            elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE)
                ii = ii + 1;
                VarArray(k,1) = strcat(DeltaChar,'P_{ge',num2str(IndBar(FptGerAi(ii))),'}');
                if (ii == NgerAi)
                    ii = 0;
                    jj = jj+1;
                    if(NgerE>0)
                        FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
                    else
                        FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
                    end
                    NgerAi = length(FptGerAi);
                end
            elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE+NTh)
                VarArray(k,1) = strcat('RefTh_{',num2str(IndBar(RefTh(i-(2*NBar+NGer+NTap+NgerA+NgerE)))),'}');
            elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE+NTh+Nhvdc*12)
                iaux = i - (2*NBar+NGer+NTap+NgerA+NgerE+NTh);
                iaux1 = floor(iaux/13)+1;
                iaux2 = mod(iaux,12);
                iaux2 = iaux2 + 12*(iaux2==0);
                switch iaux2
                    case 1
                        Tstring = strcat(DeltaChar,'Vd_r',num2str(iaux1));
                    case 2
                        Tstring = strcat(DeltaChar,'Vd_i',num2str(iaux1));
                    case 3
                        Tstring = strcat(DeltaChar,char(216),'_r',num2str(iaux1));
                    case 4
                        Tstring = strcat(DeltaChar,char(216),'_i',num2str(iaux1));
                    case 5
                        Tstring = strcat(DeltaChar,'I_r',num2str(iaux1));
                    case 6
                        Tstring = strcat(DeltaChar,'I_i',num2str(iaux1));
                    case 7
                        Tstring = strcat(DeltaChar,char(956), '_r',num2str(iaux1));
                    case 8
                        Tstring = strcat(DeltaChar,char(956), '_i',num2str(iaux1));
                    case 9
                        Tstring = strcat(DeltaChar,char(945),num2str(iaux1));
                    case 10
                        Tstring = strcat(DeltaChar,char(404),num2str(iaux1));
                    case 11
                        Tstring = strcat(DeltaChar,'a_r',num2str(iaux1));
                    case 12
                        Tstring = strcat(DeltaChar,'a_i',num2str(iaux1));
                end
                VarArray(k,1) = Tstring;
            end
            
        else
            if (i<=NGer)
                VarArray(k,1) = strcat(DeltaChar,'Qg_{',num2str(IndBar(BarGer(i))),'}');
            elseif (i<=NGer+NTap)
                VarArray(k,1) = strcat(DeltaChar,'a_{',num2str(IndBar(TapC(i-NGer,1))),RIGHTARROW,num2str(IndBar(TapC(i-NGer,2))),'}');
            elseif(i<=2*NBar+NGer+NTap+NgerA+NgerE)
                ii = ii + 1;
                VarArray(k,1) = strcat(DeltaChar,'P_{ge',num2str(IndBar(FptGerAi(ii))),'}');
                if (ii == NgerAi)
                    ii = 0;
                    jj = jj+1;
                    if(NgerE>0)
                        FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
                    else
                        FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
                    end
                    NgerAi = length(FptGerAi);
                end
            elseif (i<=NGer+NTap+NgerA+NgerE+NTh)
                VarArray(k,1) = strcat(DeltaChar,'RefTh_{',num2str(IndBar(RefTh(i-(NGer+NTap+NgerA+NgerE)))),'}');
            elseif (i<=NGer+NTap+NgerA+NgerE+NTh+Nhvdc*12)
                iaux = i - (NGer+NTap+NgerA+NgerE+NTh);
                iaux1 = floor(iaux/13)+1;
                iaux2 = mod(iaux,12);
                iaux2 = iaux2 + 12*(iaux2==0);
                switch iaux2
                    case 1
                        Tstring = strcat(DeltaChar,'Vd_r',num2str(iaux1));
                    case 2
                        Tstring = strcat(DeltaChar,'Vd_i',num2str(iaux1));
                    case 3
                        Tstring = strcat(DeltaChar,char(216),'_r',num2str(iaux1));
                    case 4
                        Tstring = strcat(DeltaChar,char(216),'_i',num2str(iaux1));
                    case 5
                        Tstring = strcat(DeltaChar,'I_r',num2str(iaux1));
                    case 6
                        Tstring = strcat(DeltaChar,'I_i',num2str(iaux1));
                    case 7
                        Tstring = strcat(DeltaChar,char(956), '_r',num2str(iaux1));
                    case 8
                        Tstring = strcat(DeltaChar,char(956), '_i',num2str(iaux1));
                    case 9
                        Tstring = strcat(DeltaChar,char(945),num2str(iaux1));
                    case 10
                        Tstring = strcat(DeltaChar,char(404),num2str(iaux1));
                    case 11
                        Tstring = strcat(DeltaChar,'a_r',num2str(iaux1));
                    case 12
                        Tstring = strcat(DeltaChar,'a_i',num2str(iaux1));
                end
                VarArray(k,1) = Tstring;
            end
        end
    end
    if (IsPlotOn == 1)
        [~,inds,pos] = unique(VarArray);
        for n=1:length(inds)
            ipos = find(pos == inds(n));
            if (length(ipos) > 1)
                for i = 1:length(ipos)
                    VarArray(ipos(i)) = strcat( strrep(VarArray(ipos(i)),'}','')  +  '_{',num2str(i),'}}');
                end
            end
        end
    end
end



end







