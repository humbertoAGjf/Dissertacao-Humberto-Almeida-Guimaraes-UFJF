function deltay = Calcula_Residuo(Xhvdc, DHVDC, ModoHVDC, HVDCLim)
    %function [deltay] = Calcula_Residuo(V, Pg, Qg, Pc, Qc, BarVTh, Vesp, BarCPVAtual, BarCTapAtual, Pcal, Qcal, Controle, FPC, Lambda, DincCarga, DincGerador)

     
    % Resíduo das linhas HVDC
    DeltaHVDC = [];
    if ~isempty(DHVDC)
        LinhasHVDC = 1;
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
            TipoDeControle = DHVDC(i,21); 
            TAPrLim  =  HVDCLim(i,1);
            AlfaLim  =  HVDCLim(i,2);
            IrLim    =  HVDCLim(i,3);
            TAPiLim  =  HVDCLim(i,4);
            GammaLim =  HVDCLim(i,5);

            % Adiciona os residuos referentes as novas equações das variaveis Vdr, Vdi, FIr, FIi, Ir, Ii, MIr e MIi
            DeltaHVDC(1 + 12*(i-1)) = -Vdr + Kr*TAPr*cos(Alfa) - Rr*Ir*PontesR;
            DeltaHVDC(2 + 12*(i-1)) = -Vdi + Ki*TAPi* cos(Gamma) - Ri*Ii*PontesI;
            DeltaHVDC(3 + 12*(i-1)) = -cos(Alfa) +cos(Alfa+MIr) + 2*PontesR*Rr*Ir/(Kr*TAPr);
            DeltaHVDC(4 + 12*(i-1)) = -cos(Gamma) +cos(Gamma+MIi) + 2*PontesI*Ri*Ii/(Ki*TAPi);
            DeltaHVDC(5 + 12*(i-1)) = -(2*MIr +sin(2*Alfa) - sin(2*(Alfa+MIr)))/(cos(2*Alfa)-cos(2*(Alfa+MIr))) + tan(FIr);
            DeltaHVDC(6 + 12*(i-1)) = -(2*MIi +sin(2*Gamma) - sin(2*(Gamma+MIi)))/(cos(2*Gamma)-cos(2*(Gamma+MIi))) + tan(FIi);
            DeltaHVDC(7 + 12*(i-1)) = -Vdr +Vdi + Rcc*Ir;
            DeltaHVDC(8 + 12*(i-1)) = -Vdi + Vdr + Rcc*Ii;
            
            % Adiciona os residuos referentes as novas equações das variáveis alfa(angulo de disp. do ret.), gama(angulo de disp. do inv.), ar e ai
            
        %% CONTROLES PARA O RETIFICADOR        
            % CONTROLES NORMAL E HIGH MVAR CONSUMPTION
            if (sum(TipoDeControle == [0 1])) 
                DeltaHVDC(9 + 12*(i-1)) = DeltaHVDC(9 + 12*(i-1))+(ModoHVDCRet == 0)*(AlfaEsp - Alfa); % Modo 0
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(TipoDeControle == 0)*(sum(ModoHVDCRet == [0 1 2]))*(GammaEsp - Gamma); % Modos 0, 1 e 2 do controle Normal(0)
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(sum(ModoHVDCRet == [0 1]))*(PConst == 0)*(Ir_or_Pcc_Esp - Ir); % Modos 0 e 1 com corrente constante
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(sum(ModoHVDCRet == [0 1]))*(PConst == 1)*(Ir_or_Pcc_Esp - Vdr*Ir); % Modos 0 e 1 com potência constante
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(sum(ModoHVDCRet == [0 1]))*(PConst == 2)*(Ir_or_Pcc_Esp + Vdi*Ii*tan(FIi)); % Modos 0 e 1 com potência constante
                DeltaHVDC(9 + 12*(i-1)) = DeltaHVDC(9 + 12*(i-1))+(sum(ModoHVDCRet == [1 2 3]))*(TAPrLim - TAPr); % Modos 1, 2 e 3
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(sum(ModoHVDCRet == [2 3]))*(AlfaLim - Alfa); % Modos 2 e 3
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(ModoHVDCRet == 3)*(IrLim - Ir); % Modo 3
            % CONTROLES CONVENCIONAL, STAB50 E ARTIGO
            elseif sum(TipoDeControle == [2 3 4])
                DeltaHVDC(9 + 12*(i-1)) = DeltaHVDC(9 + 12*(i-1))+(ModoHVDCRet == 0)*(TAPrEsp - TAPr); % Modo 0
                DeltaHVDC(9 + 12*(i-1)) = DeltaHVDC(9 + 12*(i-1))+sum(ModoHVDCRet == [1 2 3])*(AlfaLim - Alfa); % Modos 1 2 e 3
                DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+sum(ModoHVDCRet == [2 3])*(TAPrLim - TAPr);  % Modos 2 e 3
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+sum(ModoHVDCRet == [0 1 2])*sum(TipoDeControle == [3 4])*(GammaEsp - Gamma); % Modos 0, 1 e 2 do Controle Stab50 e convencional
                DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(ModoHVDCRet == 3)*sum(TipoDeControle == [3 4])*(IrLim - Ir); % Modo 3 do Controle Stab50 e convencional
                if sum(ModoHVDCRet == [0 1]) % MODOS 0 e 1
                    if (PConst == 0) % Controle Por Corrente Constante
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(Ir_or_Pcc_Esp - Ir); 
                    elseif (PConst == 1)% Controle Por Potência Constante
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(Ir_or_Pcc_Esp - Vdr*Ir);
                    else% Controle Por Potência Reativa Constante
                        DeltaHVDC(10 + 12*(i-1)) = DeltaHVDC(10 + 12*(i-1))+(Ir_or_Pcc_Esp + Vdi*Ii*tan(FIi));
                    end
                end
            end
        %% CONTROLES PARA O INVERSOR
            % CONTROLES NORMAL, STAB50 e CONVENCIONAL
            if (sum(TipoDeControle == [0 3 4])) 
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 0)*(DHVDC(i,31) == 0)*(VdrefEsp - Vdr); % Modo 0 com controle de Tensão no retificador
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 0)*(DHVDC(i,31) == 1)*(VdrefEsp - Vdi); % Modo 0 com controle de Tensão no inversor
                DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 1)*(TAPiLim - TAPi); % Modo 1
            % CONTROLE HIGH MVAR CONSUMPTION
            elseif (TipoDeControle == 1) 
                if sum(ModoHVDCInv == [0 1])
                    DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(ModoHVDCInv == 0)*(GammaEsp - Gamma);   % Modo 0
                    DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(sum(ModoHVDCInv == [1 2]))*(TAPiLim - TAPi);     % Modo 1 e 2
                    DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+sum(ModoHVDCInv == [0 1])*(DHVDC(i,31) == 0)*(VdrefEsp - Vdr); % Modos 0 e 1 com controle de Tensão no retificador
                    DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+sum(ModoHVDCInv == [0 1])*(DHVDC(i,31) == 1)*(VdrefEsp - Vdi); % Modos 0 e 1 com controle de Tensão no inversor
                    DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 2)*(GammaLim - Gamma); % Modo 2
                end
            % CONTROLE SFT
            elseif (TipoDeControle == 2)
                    DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(ModoHVDCInv == 0)*(TAPiEsp - TAPi);   % Modo 0
                    DeltaHVDC(11 + 12*(i-1)) = DeltaHVDC(11 + 12*(i-1))+(sum(ModoHVDCInv == [1 2]))*(GammaLim - Gamma); % Modo 1 e 2
                    DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+sum(ModoHVDCInv == [0 1])*(VdrefEsp - Vdi); % Modos 0 e 1
                    DeltaHVDC(12 + 12*(i-1)) = DeltaHVDC(12 + 12*(i-1))+(ModoHVDCInv == 2)*(TAPiLim - TAPi); % Modo 2
            end
        end
    end
    deltay = DeltaHVDC;


