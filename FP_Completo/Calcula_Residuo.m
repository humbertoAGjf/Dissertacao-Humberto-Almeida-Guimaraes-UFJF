function deltay = Calcula_Residuo(V, Th, Freq, Xhvdc, DHVDC, ModoHVDC, HVDCLim, Pg, Pge, Qg, Pc, Qc, BarVTh, BarGer, BarCGer, Vesp, ModoGer, GerLim, TapC, BarCTap, Tap,...
    ModoTap, TapLim, Pcal, Qcal, ControleTen, ControleRes, GovernorControl, ThEsp, FptTap, FptGerR, FptGerA, FptGerE, Area, LoadDamping, FptHVDCE, DArea, FPC, Lambda, DincCarga)
   
    % Calcula PEsp e QEsp
    if FPC == 1 % Se estiver fazendo fluxo de potencia Continuado
        PEsp = Pg + Pge - Pc.*(1+Lambda*DincCarga(:,1));
        QEsp = Qg -Qc.*(1+Lambda*DincCarga(:,2));
    else % Se estiver fazendo fluxo de potencia normal
        PEsp = Pg + Pge - Pc;
        QEsp = Qg - Qc;
    end
    % Incremento a variação da carga com a frequência
    for i =1:size(Area,1)
        PEsp(i) = PEsp(i) + Pc(i)*LoadDamping(i,1)*(1 - Freq(Area(i)));
        QEsp(i) = QEsp(i) + Qc(i)*LoadDamping(i,2)*(1 - Freq(Area(i)));
    end
    % Calcula DeltaPQ
    DeltaP = PEsp - Pcal;
    DeltaQ = QEsp - Qcal;
    DeltaPQ = [DeltaP; DeltaQ];
    
    % Calcula o resíduo de tensão controlada pelos geradores
    % Aqui a consideração de se o controle está ligado ou não ja foi feita
    %   através da transformação: BarCPV = BarPV (o código está logo abaixo da função Dados).
    %       Dessa forma, todas as tensões controlas serão as da própria barra do Gerador.
    NGer = length(BarGer);
    BarCGer = BarCGer(ModoGer == 0); % Retiro as barras que estão travadas no limite
    ii = 0;
    [~, ia, ~] = unique(BarCGer,'stable'); % Ex: Se BarCTapAtual = [2, 3, 3, 4], então ia = [1,2,4]
    Aux = 1;
    deltaV = zeros(NGer,1);
    for i=1:NGer
        if(ModoGer(i)==0)
            ii = ii + 1;
            if Aux>length(ia)
                % Para mais de 1 Gerador controlando a mesma barra (No caso de ultimo elemento do vetor "ia")
                deltaV(i) = FptGerR(i-1)*Qg(BarGer(i))-FptGerR(i)*Qg(BarGer(i-1));
            elseif ii == ia(Aux)
                % Para casos normais de controle de tensão por Gerador
                deltaV(i) = Vesp(BarCGer(ii))-V(BarCGer(ii));
                Aux = Aux + 1;
            else
                % Para mais de 1 Gerador controlando a mesma barra
                deltaV(i) = FptGerR(i-1)*Qg(BarGer(i))-FptGerR(i)*Qg(BarGer(i-1));
            end
        % Para Gerador Travado no Limite    
        else
            deltaV(i) = GerLim(i) - Qg(BarGer(i));
        end
    end

    % Calcula o resíduo de tensão controlada pelos Trafos de Tap automatico
    if (ControleTen == 1)
        NTapC = length(BarCTap);
        BarCTapAtual = BarCTap(ModoTap == 0);
        [~, ia, ~] = unique(BarCTapAtual,'stable');
        ii = 0;
        Aux = 1;
        deltaTap = zeros(NTapC,1);
        for i=1:NTapC
            if(ModoTap(i) == 0)
                ii = ii + 1;
                if Aux>length(ia)
                    % Para mais DE 1 Trafo controlando a mesma barra com alfa = 1 (No caso de ultimo elemento do vetor)
                    deltaTap(i) = FptTap(i-1)*Tap(TapC(i,3))-FptTap(i)*Tap(TapC(i-1,3));
                elseif ii == ia(Aux)
                    % Para casos normais de controle de tensão por trafo
                    deltaTap(i) = Vesp(BarCTapAtual(ii))-V(BarCTapAtual(ii));
                    Aux = Aux + 1;
                else
                    % Para mais DE 1 Trafo controlando a mesma barra com alfa = 1
                    deltaTap(i) = FptTap(i-1)*Tap(TapC(i,3))-FptTap(i)*Tap(TapC(i-1,3));
                end
            else 
                deltaTap(i) = TapLim(i) - Tap(TapC(i,3));
            end
        end
    end
    
    if (GovernorControl == 1)
        NArea = length(unique(Area));
        NgerE = size(FptGerE,1) + NArea;
        deltaRes = zeros(NgerE,1);
        NgerE = 0;
        for j=1:NArea
            FptGerEi = FptGerE(Area(FptGerE(:,1))==j,:);
            NgerEi = size(FptGerEi,1); 
            for i = 1:NgerEi
                deltaRes(NgerE+i) = Pge(FptGerEi(i,1)) - 1/FptGerEi(i,2)*(1 - Freq(j)); % Pge - (1/R)*(FreqEsp - Freq) => Pge - (1/R)*(1pu - Freq)
            end
            NgerE = NgerE + NgerEi;
        end
        for j =1:NArea
            deltaRes(NgerE+j) = ThEsp(BarVTh(j)) - Th(BarVTh(j));
        end        
    else
        if (ControleRes == 1)     
            NArea = length(unique(Area));
            NgerA = size(FptGerA,1);
            deltaRes = zeros(NgerA,1);
            NgerA = 0;
            for j=1:NArea
                FptGerAi = FptGerA(Area(FptGerA(:,1))==j,:);
                NgerAi = size(FptGerAi,1); 
                % deltaRes(NgerA+1) = DeltaP(BarVTh(j));
                deltaRes(NgerA+1) = ThEsp(BarVTh(j)) - Th(BarVTh(j)); %ThEsp - Th, ThEsp = 0;
                for i = 2:NgerAi
                    deltaRes(NgerA+i) = FptGerAi(i-1,2)*Pge(FptGerAi(i,1))-FptGerAi(i,2)*Pge(FptGerAi(i-1,1));
                end
                NgerA = NgerA + NgerAi;
            end
        else
            deltaRes = [];
        end
    end
    
    % Resíduo das linhas HVDC
    DeltaHVDC = [];
    if ~isempty(DHVDC)
        LinhasHVDC = size(DHVDC,1);
        DeltaHVDC = zeros(LinhasHVDC*12,1);
           
        for i=1:LinhasHVDC
            ModoHVDCRet = ModoHVDC(i,1);
            ModoHVDCInv = ModoHVDC(i,2);
            
            Vdr = Xhvdc(12*(i-1) + 1);
            Vdi = Xhvdc(12*(i-1) + 2);
            FIr = Xhvdc(12*(i-1) + 3);
            FIi = Xhvdc(12*(i-1) + 4);
            Ir = Xhvdc(12*(i-1) + 5);
            Ii = Xhvdc(12*(i-1) + 6);
            MIr = Xhvdc(12*(i-1) + 7);
            MIi = Xhvdc(12*(i-1) + 8);
            Alfa= Xhvdc(12*(i-1) + 9);
            Gamma= Xhvdc(12*(i-1) + 10);
            TAPr= Xhvdc(12*(i-1) + 11);
            TAPi= Xhvdc(12*(i-1) + 12);
    
            Scc_ca = DHVDC(i,23);
            DE_ret = DHVDC(i,1);
            PARA_inv = DHVDC(i,2);
            Kr = DHVDC(i,3);
            Ki = DHVDC(i,4);
            Xr = DHVDC(i,5);
            Xi = DHVDC(i,6);
            Rr = 3*Xr/pi;
            Ri = -3*Xi/pi;
            Rcc = DHVDC(i,7);        
            PontesR = DHVDC(i,29);
            PontesI = DHVDC(i,30);
            TAPrEsp = DHVDC(i,33);
            TAPiEsp = DHVDC(i,34);
            AlfaEsp = DHVDC(i,12);
            GammaEsp = DHVDC(i,15);
            Ir_or_Pcc_Esp = DHVDC(i,18);
            VdrefEsp = DHVDC(i,22);
            PConst = DHVDC(i,27);
            VdrEsp = DHVDC(i,32);
            TipoDeControle = DHVDC(i,21); 
            TAPrLim  =  HVDCLim(i,1);
            AlfaLim  =  HVDCLim(i,2);
            IrLim    =  HVDCLim(i,3);
            TAPiLim  =  HVDCLim(i,4);
            GammaLim =  HVDCLim(i,5);
            Ir_Esp = DHVDC(i,28);

            NBar = length(Pg);
            % Altera os resíduos referentes as barras adjacentes as linhas HVDC
            DeltaPQ(DE_ret) = DeltaPQ(DE_ret) - Vdr*Ir * Scc_ca;
            DeltaPQ(NBar + DE_ret) = DeltaPQ(NBar + DE_ret) - Vdr*Ir*tan(FIr) * Scc_ca;
            
            DeltaPQ(PARA_inv) = DeltaPQ(PARA_inv) - Vdi*Ii * Scc_ca;
            DeltaPQ(NBar + PARA_inv) = DeltaPQ(NBar + PARA_inv) + Vdi*Ii*tan(FIi) * Scc_ca;
    
    
            % Adiciona os residuos referentes as novas equações das variaveis Vdr, Vdi, FIr, FIi, Ir, Ii, MIr e MIi
            DeltaHVDC(1 + 12*(i-1)) = -Vdr + Kr*TAPr*V(DE_ret)*cos(Alfa) - Rr*Ir*PontesR;
            DeltaHVDC(2 + 12*(i-1)) = -Vdi + Ki*TAPi* V(PARA_inv) *cos(Gamma) - Ri*Ii*PontesI;
            DeltaHVDC(3 + 12*(i-1)) = -cos(Alfa) +cos(Alfa+MIr) + 2*PontesR*Rr*Ir/(Kr*TAPr*V(DE_ret));
            DeltaHVDC(4 + 12*(i-1)) = -cos(Gamma) +cos(Gamma+MIi) + 2*PontesI*Ri*Ii/(Ki*TAPi* V(PARA_inv));
            DeltaHVDC(5 + 12*(i-1)) = -(2*MIr +sin(2*Alfa) - sin(2*(Alfa+MIr)))/(cos(2*Alfa)-cos(2*(Alfa+MIr))) + tan(FIr);
            DeltaHVDC(6 + 12*(i-1)) = -(2*MIi +sin(2*Gamma) - sin(2*(Gamma+MIi)))/(cos(2*Gamma)-cos(2*(Gamma+MIi))) + tan(FIi);
            DeltaHVDC(7 + 12*(i-1)) = -Vdr +Vdi + Rcc*Ir;
            DeltaHVDC(8 + 12*(i-1)) = -Vdi +Vdr + Rcc*Ii;
            
            % Adiciona os residuos referentes as novas equações das variáveis alfa(angulo de disp. do ret.), gama(angulo de disp. do inv.), ar e ai
            
        %% CONTROLES PARA O RETIFICADOR        
            % CONTROLES NORMAL, HIGH MVAR CONSUMPTION, CONVENCIONAL(Tap) , STAB50(Tap) E SFT(Tap)
            DVdr = (Vdr - VdrEsp);
            DIr = FptHVDCE(i,2)*DVdr;
            if (sum(TipoDeControle == [0 1 5 6 7])) 
                DeltaHVDC(9 + 12*(i-1)) = DeltaHVDC(9 + 12*(i-1))+(ModoHVDCRet == 0)*(AlfaEsp - Alfa); % Modo 0
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(sum(TipoDeControle == [0 6 7]))*(sum(ModoHVDCRet == [0 1 2]))*(GammaEsp - Gamma); % Modos 0, 1 e 2 do controle Normal, Convencional(Tap), Stab50(Tap)
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(sum(ModoHVDCRet == [0 1]))*(PConst == 0)*(Ir_or_Pcc_Esp - Ir); % Modos 0 e 1 com corrente constante
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(sum(ModoHVDCRet == [0 1]))*(PConst == 1)*(Ir_or_Pcc_Esp - Vdr*Ir); % Modos 0 e 1 com potência constante
                DeltaHVDC(9 + 12*(i-1)) = DeltaHVDC(9 + 12*(i-1))+(sum(ModoHVDCRet == [1 2 3]))*(TAPrLim - TAPr); % Modos 1, 2 e 3
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(sum(ModoHVDCRet == [2 3]))*(AlfaLim - Alfa); % Modos 2 e 3
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(ModoHVDCRet == 3)*(IrLim - Ir); % Modo 3
                if sum(ModoHVDCRet == [0 1]) % MODOS 0 e 1
                    if (PConst == 0) % Controle Por Corrente Constante
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(TipoDeControle == 5)*GovernorControl*DIr; % controle SFT(Tap)
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(TipoDeControle == 6)*GovernorControl*FptHVDCE(i,1)*(1-Freq(Area(PARA_inv)))/VdrEsp; % Convencional
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))-(TipoDeControle == 7)*GovernorControl*(FptHVDCE(i,1)*(1-Freq(Area(DE_ret))))/VdrEsp; % Stab50
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))-(TipoDeControle == 7)*(Freq(Area(DE_ret))< 0.996)*GovernorControl*((FptHVDCE(i,2)*(0.996-Freq(Area(DE_ret))))/VdrEsp); % Stab50 abaixo de 49,8Hz
                    else % Controle Por Potência Constante
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(TipoDeControle == 5)*GovernorControl*(DIr*VdrEsp + DVdr*Ir_Esp + DVdr*DIr); % controle SFT(Tap)
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(TipoDeControle == 6)*GovernorControl*FptHVDCE(i,1)*(1-Freq(Area(PARA_inv))); % Convencional
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))-(TipoDeControle == 7)*GovernorControl*FptHVDCE(i,1)*(1-Freq(Area(DE_ret))); % Stab50
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))-(TipoDeControle == 7)*(Freq(Area(DE_ret))< 0.996)*GovernorControl*(FptHVDCE(i,2)*(0.996-Freq(Area(DE_ret)))); % Stab50 abaixo de 49,8Hz
                    end
                end
            % CONTROLES CONVENCIONAL(Tiristor) , STAB50(Tiristor) E SFT(Tiristor) 
            elseif sum(TipoDeControle == [2 3 4])
                DeltaHVDC(9 + 12*(i-1)) = DeltaHVDC(9 + 12*(i-1))+(ModoHVDCRet == 0)*(TAPrEsp - TAPr); % Modo 0
                DeltaHVDC(9 + 12*(i-1)) = DeltaHVDC(9 + 12*(i-1))+sum(ModoHVDCRet == [1 2 3])*(AlfaLim - Alfa); % Modos 1 2 e 3
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+sum(ModoHVDCRet == [2 3])*(TAPrLim - TAPr);  % Modos 2 e 3
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+sum(ModoHVDCRet == [0 1 2])*sum(TipoDeControle == [3 4])*(GammaEsp - Gamma); % Modos 0, 1 e 2 do Controle Stab50 e convencional
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(ModoHVDCRet == 3)*sum(TipoDeControle == [3 4])*(IrLim - Ir); % Modo 3 do Controle Stab50 e convencional
                if sum(ModoHVDCRet == [0 1]) % MODOS 0 e 1
                    if (PConst == 0) % Controle Por Corrente Constante
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+Ir_or_Pcc_Esp - Ir;
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(TipoDeControle == 2)*(GovernorControl*DIr); % SFT(Tiristor)
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(TipoDeControle == 3)*(GovernorControl*FptHVDCE(i,1)*(1-Freq(Area(PARA_inv)))/VdrEsp); % Convencional
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))-(TipoDeControle == 4)*(GovernorControl*(FptHVDCE(i,1)*(1-Freq(Area(DE_ret))))/VdrEsp); % Stab50
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))-(TipoDeControle == 4)*(Freq(Area(DE_ret))< 0.996)*(GovernorControl*(FptHVDCE(i,2)*(0.996-Freq(Area(DE_ret))))/VdrEsp); % Stab50 abaixo de 49,8Hz
                    else % Controle Por Potência Constante
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+Ir_or_Pcc_Esp - Vdr*Ir;
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(TipoDeControle == 2)*(GovernorControl*(DIr*VdrEsp + DVdr*Ir_Esp + DVdr*DIr)); % SFT(Tiristor)
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(TipoDeControle == 3)*(GovernorControl*FptHVDCE(i,1)*(1-Freq(Area(PARA_inv)))); % Convencional
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))-(TipoDeControle == 4)*(GovernorControl*FptHVDCE(i,1)*(1-Freq(Area(DE_ret)))); % Stab50
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))-(TipoDeControle == 4)*(Freq(Area(DE_ret))< 0.996)*(GovernorControl*FptHVDCE(i,2)*(0.996-Freq(Area(DE_ret)))); % Stab50 abaixo de 49,8Hz
                    end
                end
            end
        %% CONTROLES PARA O INVERSOR
            % CONTROLES NORMAL, STAB50 e CONVENCIONAL
            if (sum(TipoDeControle == [0 3 4 6 7])) 
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 0)*(DHVDC(i,31) == 0)*(VdrefEsp - Vdr); % Modo 0 com controle de Tensão no retificador
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 0)*(DHVDC(i,31) == 1)*(VdrefEsp - Vdi); % Modo 0 com controle de Tensão no inversor
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 1)*(TAPiLim - TAPi); % Modo 1
            % CONTROLE HIGH MVAR CONSUMPTION e SFT(Tap)
            elseif (sum(TipoDeControle == [1 5])) 
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(ModoHVDCInv == 0)*(GammaEsp - Gamma);   % Modo 0
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(sum(ModoHVDCInv == [1 2]))*(TAPiLim - TAPi);     % Modo 1 e 2
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+sum(ModoHVDCInv == [0 1])*(DHVDC(i,31) == 0)*(VdrefEsp - Vdr); % Modos 0 e 1 com controle de Tensão no retificador
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+sum(ModoHVDCInv == [0 1])*(DHVDC(i,31) == 1)*(VdrefEsp - Vdi); % Modos 0 e 1 com controle de Tensão no inversor
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 2)*(GammaLim - Gamma); % Modo 2
                if (TipoDeControle == 5 && sum(ModoHVDCInv == [0 1]))
                    Mv = FptHVDCE(i,2);
                    AreaPara = Area(PARA_inv);
                    Freqb = DArea(DArea(:,1) == AreaPara, 2);
                    dfpu = Freq(AreaPara) - 1;
                    Iref = DHVDC(i,28);
                    k = Mv/(1 - Mv*Rcc);
                    a = k*dfpu;
                    b = -k*VdrefEsp-Iref;
                    c = FptHVDCE(i,1);
                    Mf = (-b-sqrt(b^2-4*a*c))/(2*a);
                    if (abs(Mf)>FptHVDCE(i,3) || isnan(Mf) || imag(Mf) ~= 0)
                        Mf = FptHVDCE(i,3);                            
                    end
                    dV = GovernorControl*Mf*min([(1-Freq(AreaPara)) 1/Freqb]); % Calcula dV e Limita a variação com a frequência para até 1Hz.
                    DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+dV; % Modos 0 e 1
                end
            % CONTROLE SFT(Tiristor)
            elseif (TipoDeControle == 2)
                Mv = FptHVDCE(i,2);
                AreaPara = Area(PARA_inv);
                Freqb = DArea(DArea(:,1) == AreaPara, 2);
                dfpu = Freq(AreaPara) - 1;
                Iref = DHVDC(i,28);
                k = Mv/(1 - Mv*Rcc);
                a = k*dfpu;
                b = -k*VdrefEsp-Iref;
                c = FptHVDCE(i,1);
                Mf = (-b-sqrt(b^2-4*a*c))/(2*a);
                if (abs(Mf)>FptHVDCE(i,3) || isnan(Mf) || imag(Mf) ~= 0)
                    Mf = FptHVDCE(i,3);                            
                end
                AreaPara = Area(PARA_inv);
                Freqb = DArea(DArea(:,1) == AreaPara, 2);
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(ModoHVDCInv == 0)*(TAPiEsp - TAPi);   % Modo 0
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(sum(ModoHVDCInv == [1 2]))*(GammaLim - Gamma); % Modo 1 e 2
                dV = GovernorControl*Mf*min([(1-Freq(AreaPara)) 1/Freqb]); % Calcula dV e Limita a variação com a frequência para até 1Hz.
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+sum(ModoHVDCInv == [0 1])*(VdrefEsp - Vdi + dV); % Modos 0 e 1
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 2)*(TAPiLim - TAPi); % Modo 2
            end
        end
    end

    % Retiro as barras VTh's
    if (GovernorControl == 0 && ControleRes == 0)
        DeltaPQ(BarVTh)=0;
    end
    % Consideração de resíduo para o Fluxo de Potencia Continuado
    if FPC == 1 % Correção
        if (ControleTen==1)
            %deltay = [DeltaPQ; deltaVPV; deltaVTap; deltaTap; 0];
            deltay = [DeltaPQ; deltaV; deltaTap; deltaRes; DeltaHVDC; 0];
        else
            deltay = [DeltaPQ; deltaV; deltaRes; DeltaHVDC; 0];
        end
    else % FP Convencional
        if (ControleTen==1)
            deltay = [DeltaPQ; deltaV; deltaTap; deltaRes; DeltaHVDC];
        else
            deltay = [DeltaPQ; deltaV; deltaRes; DeltaHVDC];
        end
    end
end





