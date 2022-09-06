function Plota_Grafico_PCAxXvar(TipoMatrizJ_PlotPCA, GovernorControl, ControleRes, ControleTen, Xvar, NPC, PlotAutovalor, FILENAME)


[NBar, NLin, IndBar, BarGer, BarEMF, BarVTh, BTipo, PgEsp, PgeEsp, QgEsp, QgMax, QgMin, Pc, Qc, Qs, Ps, VEsp, ThEsp, DE, PARA, ...
    r, x, BSh_Lin, TapEsp, TapMin, TapMax, TapPh, MvaMax, LTipo, NGer, BarCGer, TapC, BarCTap, LadoCTap, FptTap, FptGerR, FptGerA, FptGerE,...
        FreqEsp, Area, DArea, LoadDamping, FptHVDCE, DHVDC, LinhasHVDC, XhvdcEsp, DadoInc, DincCarga, DincGerador] = Dados(FILENAME);



    FILENAME = strcat(FILENAME,'.mat');
    NXvar = length(Xvar);
    PCVariancePlot = zeros(NXvar,NPC);
    AutovalorPlot = zeros(NXvar,NPC);
    Passo = [1 0];
    CellDj = cell(6,2);
    CellDj(:,:) = {0};
    ControleTenAux = ControleTen;
    for i=1:NXvar
        x(5) = Xvar(i)/100; % Reatância em porcentagem
        save(FILENAME);
        
        FlatStart = 1;
        [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ModoTap, ModoGer] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, GovernorControl);
        % Caso não tenha convergido, rodo outro Fluxo de Potência, porém com controle desligado
        if (Flag1 ~= 1)
            ControleTen = 0;
            [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ModoTap, ModoGer] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, GovernorControl);
        end

        % Calcula a Jacobiana
        ControleTen = ControleTenAux;
        
        Y = Cria_Matriz_Admitancia(NBar, NLin, IndBar, DE, PARA, BSh_Lin, Qs, Ps, r, x, Tap, TapPh, LTipo);
        J = Cria_J(NBar, Y, V, Th, Freq, Tap, Xhvdc, DHVDC, ModoHVDC, r, x, BarVTh, BarGer, BarCGer, ModoGer, TapC, ModoTap, BarCTap, Pcal, Qcal, ControleTen, ControleRes, GovernorControl, FptTap, FptGerR, FptGerA, FptGerE, Area, LoadDamping, FptHVDCE, Pc, Qc, 0);
        
        if ControleRes == 0
            FptGerA = [];
        end
        if (GovernorControl == 0)
            FptGerE = [];
        end
        if (GovernorControl + ControleRes == 0)
            Area = [];
        end

        Vmin = 0.001;
        SM = 0.1;
        SA = 0.01;
        LambdaMaxA = 100;
        NLambdaA = 100000;
        FPMinA = 0.05;
        MSMinA = 0.05;
        IsPlotOn = 0;
        NPlot = 0;

        if (PlotAutovalor == 1)
            [~, ~, CellDj] = Plota_Analise_AutoValores(J, TipoMatrizJ_PlotPCA, LambdaMaxA, NLambdaA, FPMinA, MSMinA, NBar, BarCGer, BarGer, TapC, FptGerA, FptGerE, Area, DHVDC, IndBar, ControleTen, ControleRes, GovernorControl, IsPlotOn);                                            
        end

        [~, ~, PCVariance] = Plota_Conflitos_Por_PCA(J,TipoMatrizJ_PlotPCA,TapC,BarCTap,BarGer,BarCGer,NBar, IndBar, FptGerA, FptGerE, Area, DHVDC, Vmin, SM, SA, NPlot, ControleTen, ControleRes, GovernorControl, IsPlotOn);
        
        for j=1:NPC
            PCVariancePlot(i,j) = PCVariance(j);
            AutovalorPlot(i,j) = CellDj{j,2};
        end
    end

    
    Colors = {'#0072BD' '#D95319' '#EDB120' '#7E2F8E' '#77AC30' '#4DBEEE' '#A2142F' 'r' 'g' 'b' 'c' 'm' 'y' 'k'};
    Markers = {'o' 's' '^' 'h' 'd' '+' '*'  '_' '|' 'v' '>' '<' 'p'};
    figure
    EixoX = Xvar;
    PlotsVariance = zeros(1,NPC);
    PlotsAutovalor = zeros(1,NPC);





    for i = 1:NPC
        
        if (PlotAutovalor == 1)
            hold on;
            yyaxis left
            PlotsVariance(i) = plot(EixoX,PCVariancePlot(:,i),Markers{i},'MarkerSize',10,'MarkerFaceColor',Colors{1},'color', 'k','DisplayName', strcat(num2str(i),'ª CP'));
            hold on;
            plot(EixoX,PCVariancePlot(:,i),'-','color',Colors{1})
            hold on;
            yyaxis right
            PlotsAutovalor(i) = plot(EixoX,abs(AutovalorPlot(:,i)),Markers{i},'MarkerSize',10,'MarkerFaceColor',Colors{2},'color', 'k','DisplayName', strcat(num2str(i),'\circ Autovalor'));
            hold on;
            plot(EixoX,abs(AutovalorPlot(:,i)),'-','color',Colors{2})
        else
            hold on;
            PlotsVariance(i) = plot(EixoX,PCVariancePlot(:,i),Markers{i},'MarkerSize',10,'MarkerFaceColor',Colors{i},'color', 'k','DisplayName', strcat(num2str(i),'ª CP'));
            hold on;
            plot(EixoX,PCVariancePlot(:,i),'color',Colors{i})
        end
    end
    if (PlotAutovalor == 1)
        legend([PlotsVariance PlotsAutovalor])
        title('Influência da Reatância nas duas Metodologias')
        yyaxis right
        ylabel('AutoValor')
        yyaxis left
    else
        legend(PlotsVariance)
        title('Influência da Reatância na Variância')
    end
    PCmax = max(PCVariancePlot(:,1));
    ylim([0, 1.1*PCmax]);
    ylabel('Variância')
    set(gca,'YScale','log')
    Ordem = 0;
    while (1)
        if (floor(PCmax/(10^Ordem)) == 0)
            break;
        end
        Ordem = Ordem+1;
    end
    ytick = 10.^(0:Ordem);
    set(gca,'ytick',ytick)
    grid on;
    xlabel('Reatância Variável (%)')
    set(gca,'xtick',EixoX)
    set(gca,'XScale','log')




    
    
end