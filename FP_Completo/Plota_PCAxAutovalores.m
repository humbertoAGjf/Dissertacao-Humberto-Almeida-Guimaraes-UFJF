function Plota_PCAxAutovalores(J,TipoMatrizJ_PCAxA,TapC,BarCTap,BarGer,BarCGer,NBar, IndBar, FptGerA, FptGerE, Area, DHVDC, NVars_PCAxA, NPlots_PCAxA, TipoPlot_PCAxA, ControleTen, ControleRes, GovernorControl)
    Vmin = 0.1;
    SM = 0.01;
    SA = 0.001;
    LambdaMaxA = 100;
    NLambdaA = 20;
    FPMinA = 0.001;
    MSMinA = 0.005;
    IsPlotOn = 0;
    Tol = 0.02;
    NPlot =1 ;

    [FPIndNomes, MSIndNomes, CellDj] = Plota_Analise_AutoValores(J, TipoMatrizJ_PCAxA, LambdaMaxA, NLambdaA, FPMinA, MSMinA, NBar, BarCGer, BarGer, TapC, BarCTap, FptGerA, FptGerE, Area, DHVDC, IndBar, ControleTen, ControleRes, GovernorControl, IsPlotOn);                                            
    [PlotPC, PlotSignals, PCVariance] = Plota_Conflitos_Por_PCA(J,TipoMatrizJ_PCAxA,TapC,BarCTap,BarGer,BarCGer,NBar, IndBar, FptGerA, FptGerE, Area, DHVDC, Vmin, SM, SA, NPlot, ControleTen, ControleRes, GovernorControl, IsPlotOn);
    
    if(isempty(CellDj))
        disp("Não houve conflito pelo método de Autovalores");
    end
    if(isempty(PCVariance))
        disp("Não houve conflito pelo método de Análise de Componentes Principais");
    end
    NPlots_PCAxA = min([NPlots_PCAxA  size(PlotSignals,1)  size(FPIndNomes,1)]);

    if (TipoPlot_PCAxA == 1 || TipoPlot_PCAxA == 3)
        for i=1:NPlots_PCAxA
            FPIndNomes{i} = FPIndNomes{i}(1:min([NVars_PCAxA + 3  size(FPIndNomes{i},1)  size(PlotSignals{i},1)]),:); % Diminuo o tamanho da matriz para não iterar muito desnecessariamente
            NVars = min([NVars_PCAxA size(FPIndNomes{i},1) size(PlotSignals{i},1)]);
            FPArray = cell(NVars,2);
            SignalsArray = cell(NVars,2);

            for k=1:NVars
                SignalsArray{k,1} = PlotSignals{i}{k,1};    
                SignalsArray{k,2} = PlotSignals{i}{k,2};  
                for j=1:NVars
                    if (FPIndNomes{i}{j,1} == PlotSignals{i}{ k,1})
                        if(abs(FPIndNomes{i}{j,2} - FPIndNomes{i}{k,2}) < Tol)
                            Aux1 = FPIndNomes{i}(j,:);
                            FPIndNomes{i}(j,:) = FPIndNomes{i}(k,:) ;
                            FPIndNomes{i}(k,:) = Aux1;
                            FPArray{j,1} = string(FPIndNomes{i}{j,1});
                            FPArray{j,2} = FPIndNomes{i}{j,2};
                            break;
                        end
                    end
                end
                FPArray{k,1} = string(FPIndNomes{i}{k,1});
                FPArray{k,2} = FPIndNomes{i}{k,2};
            end
            figure;
            yyaxis left
            VectorBar1 = zeros(NVars,2);
            VectorBar1(:,1) = [SignalsArray{:,2}]';
            b1 = bar(VectorBar1);
            Ymax = 1.4*max(abs([SignalsArray{:,2}]));
            ylim([-Ymax, Ymax]);
            xtips1 = b1(1).XEndPoints;
            ytips1 = b1(1).YEndPoints;
            labels1 =  [SignalsArray{:,1}];
            text(xtips1(ytips1 > 0),ytips1(ytips1 > 0),labels1(ytips1 > 0),'HorizontalAlignment','center','VerticalAlignment','bottom')
            text(xtips1(ytips1 < 0),ytips1(ytips1 < 0),labels1(ytips1 < 0),'HorizontalAlignment','center','VerticalAlignment','top')
            ylabel("Projeção na CP")

            hold on
            yyaxis right
            VectorBar2 = zeros(NVars,2);
            VectorBar2(:,2) = [FPArray{:,2}]';
            b2 = bar(VectorBar2);
            Ymax = 1.4*max(abs([FPArray{:,2}]));
            ylim([-Ymax, Ymax]);
            xtips2 = b2(2).XEndPoints;
            ytips2 = b2(2).YEndPoints;
            labels2 =  [FPArray{:,1}];
            text(xtips2(ytips2 > 0),ytips2(ytips2 > 0),labels2(ytips2 > 0),'HorizontalAlignment','center','VerticalAlignment','bottom')
            text(xtips2(ytips2 < 0),ytips2(ytips2 < 0),labels2(ytips2 < 0),'HorizontalAlignment','center','VerticalAlignment','top')
            ylabel("Fator de Participação")

            if(PCVariance(i) < 5 || CellDj{i,2}>0.5)
                title(sprintf("Projeção na %dªCP x Fator de Participação para \\lambda_{%d}",i,i),'Color','red');
                subtitle(sprintf('Variância: %0.2e       Autovalor: %0.2e', PCVariance(i),CellDj{i,2}),'Color','red');
            else
                title(sprintf("Projeção na %dªCP x Fator de Participação para \\lambda_{%d}",i,i));
                subtitle(sprintf('Variância: %0.2e       Autovalor: %0.2e', PCVariance(i),CellDj{i,2}));
            end



        end
    end

    if (TipoPlot_PCAxA == 2 || TipoPlot_PCAxA == 3)  
        for i=1:NPlots_PCAxA
            MSIndNomes{i} = MSIndNomes{i}(1:min([NVars_PCAxA + 3  size(MSIndNomes{i},1)  size(PlotPC{i},1)]),:); % Diminuo o tamanho da matriz para não iterar muito desnecessariamente
            NVars = min([NVars_PCAxA size(MSIndNomes{i},1) size(PlotPC{i},1)]);
            MSArray = cell(NVars,2);
            PCArray = cell(NVars,2);

            for k=1:NVars
                PCArray{k,1} = PlotPC{i}{k,1};    
                PCArray{k,2} = PlotPC{i}{k,2};  
                for j=1:NVars
                    if (MSIndNomes{i}{j,1} == PlotPC{i}{k,1})
                        if(abs(MSIndNomes{i}{j,2} - MSIndNomes{i}{k,2}) < Tol)
                            Aux1 = MSIndNomes{i}(j,:);
                            MSIndNomes{i}(j,:) = MSIndNomes{i}(k,:);
                            MSIndNomes{i}(k,:) = Aux1;
                            MSArray{j,1} = string(MSIndNomes{i}{j,1});
                            MSArray{j,2} = MSIndNomes{i}{j,2};
                            break;
                        end
                    end
                end
                MSArray{k,1} = string(MSIndNomes{i}{k,1});
                MSArray{k,2} = MSIndNomes{i}{k,2};
            end
            figure;
            yyaxis left
            VectorBar1 = zeros(NVars,2);
            VectorBar1(:,1) = [PCArray{:,2}]';
            b1 = bar(VectorBar1);
            Ymax = 1.4*max(abs([PCArray{:,2}]));
            ylim([-Ymax, Ymax]);
            xtips1 = b1(1).XEndPoints;
            ytips1 = b1(1).YEndPoints;
            labels1 =  [PCArray{:,1}];
            text(xtips1(ytips1 > 0),ytips1(ytips1 > 0),labels1(ytips1 > 0),'HorizontalAlignment','center','VerticalAlignment','bottom')
            text(xtips1(ytips1 < 0),ytips1(ytips1 < 0),labels1(ytips1 < 0),'HorizontalAlignment','center','VerticalAlignment','top')
            ylabel("Influência na CP")

            hold on
            yyaxis right
            VectorBar2 = zeros(NVars,2);
            VectorBar2(:,2) = [MSArray{:,2}]';
            b2 = bar(VectorBar2);
            Ymax = 1.4*max(abs([MSArray{:,2}]));
            ylim([-Ymax, Ymax]);
            xtips2 = b2(2).XEndPoints;
            ytips2 = b2(2).YEndPoints;
            labels2 =  [MSArray{:,1}];
            text(xtips2(ytips2 > 0),ytips2(ytips2 > 0),labels2(ytips2 > 0),'HorizontalAlignment','center','VerticalAlignment','bottom')
            text(xtips2(ytips2 < 0),ytips2(ytips2 < 0),labels2(ytips2 < 0),'HorizontalAlignment','center','VerticalAlignment','top')
            ylabel("Mode-Shape")

            
            if(PCVariance(i) < 5 || CellDj{i,2}>0.5)
                title(sprintf("Influência na %dªCP x Mode-Shape para \\lambda_{%d}",i,i),'Color','red');
                subtitle(sprintf('Variância: %0.2e       Autovalor: %0.2e', PCVariance(i),CellDj{i,2}),'Color','red');
            else
                title(sprintf("Influência na %dªCP x Mode-Shape para \\lambda_{%d}",i,i));
                subtitle(sprintf('Variância: %0.2e       Autovalor: %0.2e', PCVariance(i),CellDj{i,2}));
            end
        end
    end
end

