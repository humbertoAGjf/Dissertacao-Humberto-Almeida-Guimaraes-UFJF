function CalculoFptHVDC(TipoFpt, FILENAME, FlatStart, Passo, ControleTen, ControleRes, Mo, Gg, Bg, Gf, Bf, Vg, ds, Mfmax)

    

    switch TipoFpt

%% % Regulacao Primaria Tradicional
        case 0 
            Nfpt = length(Mo);
            run(FILENAME);
            Nelo = size(DELO,1);
            if (Nfpt < Nelo)
                Mo = repmat(Mo(1),[1,Nelo]);
            end
            MfConvPu = zeros(1,Nelo);
            for i =1:Nelo
                PbElo = DELO(i,6);
                BarraPara = DELO(i,2);
                AreaPara = DBAR(DBAR(:,1) == BarraPara,14);
                Freqb = DArea(DArea(:,1) == AreaPara, 2);
                MfConvPu(i) = Mo(i)/(PbElo/Freqb);
            end
            % Printa Resultados
            fprintf("Método Convencional - Fator de participação em Pu\n");
            fprintf("Elo \t\t M_f\n");
            for i = 1:Nelo
                fprintf("%d \t\t %f\n", i, MfConvPu(i));
            end

%% % Regulacao Primaria do artigo - Calculada Analiticamente
        case 1 
            Nfpt = length(Mo);
            run(FILENAME);
            Nelo = size(DELO,1);
            if (Nfpt < Nelo)
                Mo = repmat(Mo(1),[1,Nelo]);
            end
            MoAux = Mo;
            MvPu = zeros(1,Nelo);
            MfPu = zeros(1,Nelo);
            [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ~, ~] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, 0, 1);
            % Caso não tenha convergido, rodo outro Fluxo de Potência, porém com controle desligado
            if (Flag1 ~= 1)
                ControleTen = 0;
                [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ~, ~] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, 0, 1);
            end
            for i =1:Nelo
                IndEloi = find(DCNV(:,3) == i);              % Descubro em qual linha está os conversores do Elo i
                IndI = IndEloi(DCNV(IndEloi,4) == 1);        % Pego apenas a linha do inversor do Elo   
                if(DCCV(IndI,2) == 1)
                    fprintf("ERROR! É PRECISO MUDAR PARA CONTROLE CONSTANTE NO ELO\n");
                    return;
                end

                PbElo = DELO(i,6);              % Pot. base do elo C.C.
                VbElo = DELO(i,5);              % Tensao base do elo C.C.
                IbElo = PbElo/VbElo;            % Corrente base do elo C.C.
                IdcRef = DCCV(IndI,3)/1000;     % Corrente Especificada no elo C.C.    
                VdciRef = DELO(i,8);            % Tensao Especificada no elo C.C.
                B = DCNV(DCNV(:,3) == i,5); 
                B = B(1);                     % Num. de Pontes da conversora
                BarraPara = DELO(i,2);        % Indice da barra C.A. de interface no lado do inversor
                Vs = DBAR(BarraPara,15);      % Tensao Base do lado C.A.       
                Rdc = DELO(i,3);
                Mo= MoAux(i);
                P = abs(Xhvdc(12*(i-1) + 2)*Xhvdc(12*(i-1) + 6) * PbElo);
                Q = abs(-Xhvdc(12*(i-1) + 2)*Xhvdc(12*(i-1) + 6)*tan(Xhvdc(12*(i-1) + 4)) * PbElo);
                BarraPara = DELO(i,2);
                AreaPara = DBAR(DBAR(:,1) == BarraPara,14);
                Freqb = DArea(DArea(:,1) == AreaPara, 2);

                % Calculo T para essa determinada configuracao do sistema utilizando a
                % equacao 19 do artigo
                T = sqrt((pi*Q/IdcRef)^2 + (pi*VdciRef)^2)/(3*sqrt(2)*B*Vs);
                
                % Calculo C1,C2 e C3 utilizados para calcular Vs = sqrt((-C2+sqrt(C2^2-4*C1*C3))/(2*C1))
                C1 = (Gg + Gf)^2 + (Bg + Bf)^2;
                C2 = -2*Q*(Bg + Bf) - 2*P*(Gg + Gf) - (Gg^2 + Bg^2)*Vg^2;
                C3 = P^2 + Q^2;
                
                % Calculo as derivadas fornecidas pelo artigo:
                dVsP = (Gg+Gf)/sqrt(C2^2 - 4*C1 * C3)*Vs - P/sqrt(C2^2 - 4*C1*C3)/Vs;
                dVsQ = (Bg+Bf)/sqrt(C2^2 - 4*C1 * C3)*Vs - Q/sqrt(C2^2 - 4*C1 * C3)/Vs;
                dQVdci = - pi*P/sqrt(18*B^2*T^2*Vs^2 - pi^2*VdciRef^2);
                dQIdc = 1/pi*sqrt(18*B^2*T^2*Vs^2 - pi^2*VdciRef^2);
                                
                % Calculo as derivadas finais
                dVsIdc = VdciRef * dVsP + dVsQ * dQIdc;
                dVsVdci = IdcRef * dVsP + dVsQ * dQVdci;
                
                % Calculo Mv e Mf para a metodologia proposta no artigo
                Mv = dVsVdci*(Rdc*dVsVdci - dVsIdc)^-1;
                Mf = (1 - Mv*Rdc)/(Mv*VdciRef + IdcRef*(1-Mv*Rdc))*Mo;
                
                % Calcula os Valores de Mv, Mf em pu para poderem ser utilizado no FP
                MvPu(i) = Mv/IbElo*VbElo;
                MfPu(i) = Mf/VbElo*Freqb;
            end
            % Printa Resultados
            fprintf("Método do Artigo - Calculado Analiticamente\n");
            fprintf("Elo \t\t M_v \t\t M_f\n");
            for i = 1:Nelo
                fprintf("%d \t\t %f \t\t %f\n", i, MvPu(i), MfPu(i));
            end


%% % Regulacao Primaria do artigo - Calculada Numericamente
        case 2 
            if (ControleTen == 1)
                fprintf("ATENÇÃO!!! O ELO DEVE ESTAR COM O CONTROLE DE TENSÃO DESATIVADO PARA CALCULAR O VALOR DE mf E mv!");
                return;
            end
            [NBar, NLin, IndBar, BarGer, BarEMF, BarVTh, BTipo, PgEsp, PgeEsp, QgEsp, QgMax, QgMin, Pc, Qc, Qs, Ps, VEsp, ThEsp, DE, PARA, ...
                r, x, BSh_Lin, TapEsp, TapMin, TapMax, TapPh, MvaMax, LTipo, NGer, BarCGer, TapC, BarCTap, LadoCTap, FptTap, FptGerR, FptGerA, FptGerE,...
                    FreqEsp, Area, DArea, LoadDamping, FptHVDCE, DHVDC, LinhasHVDC, XhvdcEsp, DadoInc, DincCarga, DincGerador] = Dados(FILENAME, 1);

            FILENAME1 = FILENAME;
            FILENAME = strcat(FILENAME,'.mat');
            save(FILENAME);
            run(FILENAME1);

%  Caso Base:
            [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ~, ~] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, 0);
            % Caso não tenha convergido, rodo outro Fluxo de Potência, porém com controle desligado
            if (Flag1 ~= 1)
                ControleTen = 0;
                [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ~, ~] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, 0);
            end
            VsCasoBase = V;

%  Variação da Corrente Específicada:
            load(FILENAME);
            DHVDC(:,18) = DHVDC(:,18) + ds;
            DHVDC(:,28) = DHVDC(:,18); 
            save(FILENAME);
            [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ~, ~] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, 0);
            % Caso não tenha convergido, rodo outro Fluxo de Potência, porém com controle desligado
            if (Flag1 ~= 1)
                ControleTen = 0;
                [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ~, ~] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, 0);
            end
            VsVarCorrente = V;

%  Variação da Tensão Específicada:
            load(FILENAME);
            DHVDC(:,18) = DHVDC(:,18) - ds;
            DHVDC(:,28) = DHVDC(:,18); 
            DHVDC(:,22) = DHVDC(:,22) + ds;
            save(FILENAME);
            [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ~, ~] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, 0);
            % Caso não tenha convergido, rodo outro Fluxo de Potência, porém com controle desligado
            if (Flag1 ~= 1)
                ControleTen = 0;
                [Flag1, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ~, ~] = Fluxo_de_Potencia_Convencional(FILENAME, 0, 0, FlatStart, Passo, ControleTen, ControleRes, 0);
            end
            VsVarTensao = V;

% Calculo da Derivada Numérica:
            Nfpt = length(Mo);
            Nfpt2 = length(Mfmax);
            Nelo = size(DELO,1);
            FlagPrint = 0;
            if (Nfpt < Nelo)
                Mo = repmat(Mo(1),[1,Nelo]);
            end
            MoAux = Mo;
            if (Nfpt2 < Nelo)
                Mfmax = repmat(Mfmax(1),[1,Nelo]);
            end           
            MvPu = zeros(1,Nelo);
            MfPu = zeros(1,Nelo);
            MoPu = zeros(1,Nelo);
            for i =1:Nelo
                IndEloi = find(DCNV(:,3) == i);              % Descubro em qual linha está os conversores do Elo i
                IndI = IndEloi(DCNV(IndEloi,4) == 1);        % Pego apenas a linha do inversor do Elo   
                if(DCCV(IndI,2) == 1)
                    fprintf("ERROR! É PRECISO MUDAR PARA CONTROLE DE CORRENTE CONSTANTE NO ELO\n");
                    return;
                end
                if(DELO(i,9) == 0)
                    fprintf("ERROR! É PRECISO MUDAR PARA CONTROLE DE TENSAO NO LADO DO INVERSOR NO ELO\n");
                    return;
                end

                PbElo = DELO(i,6);                  % Pot. base do elo C.C.
                VbElo = DELO(i,5);                  % Tensao base do elo C.C.
                IbElo = PbElo/VbElo;                % Corrente base do elo C.C. em kA
                IdcRef = DCCV(IndI,3)/1000/IbElo;   % Corrente Especificada do elo C.C. em pu    
                VdciRef = DELO(i,8)/VbElo;          % Tensao Especificada do elo C.C. em pu
                Rdc = DELO(i,3)/(VbElo/IbElo);      % Impedância do do elo C.C. em pu
                BarraPara = DELO(i,2);
                AreaPara = DBAR(DBAR(:,1) == BarraPara,14);
                Freqb = DArea(DArea(:,1) == AreaPara, 2);
                Mo = MoAux(i)/(PbElo/Freqb);        % Droop desejado em pu 
                Vs0 = VsCasoBase(BarraPara);
                Vsi = VsVarCorrente(BarraPara);
                Vsv = VsVarTensao(BarraPara);

                dVsVdci = (Vsv - Vs0)/ds;    % Derivada NumÃ©rica calculada atravÃ©s de simulaÃ§Ãµes do sistema
                dVsIdc = (Vsi - Vs0)/ds;
              
                % Calculo Mv e Mf:
                MvPu(i) = dVsVdci*(Rdc*dVsVdci - dVsIdc)^-1;
                MfPu(i) = (1 - MvPu(i)*Rdc)/(MvPu(i)*VdciRef + IdcRef*(1-MvPu(i)*Rdc))*Mo;
                MfPuSalvo = MfPu(i);
                MvSalvo = MvPu(i);
                if (MfPu(i) > Mfmax(i))
                    MfPu(i) = Mfmax(i);
                    MvPu(i) = (Mo-MfPu(i)*IdcRef)/(MfPu(i)*(VdciRef-Rdc*IdcRef)+Mo*Rdc);
                    FlagPrint = 1;
                end

                % Calculo considerandos o a segunda ordem na expansão de taylor para a tensão
                fmed = 59.99999999999999;
                fpu = fmed/Freqb;
                dfpu = fpu-1;
                k = MvSalvo/(1 - MvSalvo*Rdc);
                a = k*dfpu;
                b = -k*VdciRef-IdcRef;
                c = Mo;
                MoPu(i) = Mo;
                MfPu1 = -c/b;
                MfPu2Mais = (-b+sqrt(b^2-4*a*c))/(2*a);
                MfPu2Menos = (-b-sqrt(b^2-4*a*c))/(2*a);

            end

            % Printa Resultados
            fprintf("Método do Artigo - Calculado Por Derivada Numérica\n");
            if(FlagPrint) 
                fprintf("Mf MÁXIMO ATINGIDO!\n");
                MfPu1
                MfPu2Menos
                MfPuSalvo
                MvSalvo
            end
            fprintf("Elo \t\t M_v \t\t M_f \t\t M_0\n");
            for i = 1:Nelo
                fprintf("%d \t   %f \t   %f \t    %f\n", i, MvPu(i), MfPu(i), MoPu(i));
            end

            % Printa o Gráfico de Mf
            k = MvSalvo/(1 - MvSalvo*Rdc);
            b = -k*VdciRef-IdcRef;
            c = Mo;
            dfPlot = -0.1:0.00001:0.1;
            mfPlot = (-b - sqrt(b^2-4*k.*dfPlot*c))./(2*k.*dfPlot);
            dfPlot = dfPlot(imag(mfPlot) == 0);
            mfPlot = mfPlot(imag(mfPlot) == 0);
            figure;
            plot(dfPlot,mfPlot,'LineWidth',2);
            x = [0 0];
            y = [-0.3*min(mfPlot) 2*max(mfPlot)];
            hold on;
            plot(x, y,'Color','k');
            x = [2*min(dfPlot) 1.1*max(dfPlot)];
            y = [0 0];
            hold on;
            plot(x, y,'Color','k');
            ylim([-0.3*min(mfPlot), 2*max(mfPlot)]);
            xlim([1.1*min(dfPlot), 1.1*max(dfPlot)]);
            xlabel('Desvio de Frequência (p.u.),','FontSize',13,'FontWeight','bold')
            ylabel('M_f (p.u.)','FontSize',13,'FontWeight','bold')


    end
end


%             

