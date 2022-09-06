function [ModoGer, GerLim, ModoTap, TapLim, ModoHVDC, HVDCLim]= Limites(Qg, V, Xhvdc, DHVDC, Vesp, BarGer, BarCGer, QgMin, QgMax, TapC, BarCTap, Tap, LadoCTap, TapMin, TapMax, ControleTen, Area, Freq, FptHVDCE,GovernorControl)


%% PARA BARRAS DE GERAÇÃO
    NGer = length(BarGer);
    ModoGer = zeros(NGer,1);
    GerLim = zeros(NGer, 1);
    for i=1:NGer
        ModoGer(i) = 0;
        % Tap do retificador no Max
        if Qg(BarGer(i)) > QgMax(BarGer(i))
            % Verifico Back Off
            if V(BarCGer(i)) <= Vesp(BarCGer(i))
                ModoGer(i) = 1;
                GerLim(i) = QgMax(BarGer(i)) + 1E-5;
            end
        elseif Qg(BarGer(i)) < QgMin(BarGer(i))
            % Verifico Back Off
            if V(BarCGer(i)) >= Vesp(BarCGer(i))
                ModoGer(i) = 1;
                GerLim(i) = QgMin(BarGer(i)) - 1E-5;
            end
        end
    end



%% PARA TAP DOS TRANSFORMADORES
    NtapCont = length(BarCTap);
    ModoTap = zeros(NtapCont,1);
    TapLim = zeros(NtapCont, 1);
    if (ControleTen == 1)
        for i=1:NtapCont
            ModoTap(i) = 0;
            % Tap do retificador no Max
            if Tap(TapC(i,3)) > TapMax(TapC(i,3))
                % Verifico Back Off
                if (LadoCTap(i) == 1) % Controla a Barra DE
                    if V(BarCTap(i)) >= Vesp(BarCTap(i))
                        ModoTap(i) = 1;
                        TapLim(i) = TapMax(TapC(i,3)) + 1E-5;
                    end
                else % Controla a Barra PARA
                    if V(BarCTap(i)) <= Vesp(BarCTap(i))
                        ModoTap(i) = 1;
                        TapLim(i) = TapMax(TapC(i,3)) + 1E-5;
                    end
                end

            elseif Tap(TapC(i,3)) < TapMin(TapC(i,3))
                % Verifico Back Off
                if (LadoCTap(i) == 1) % Controla a Barra DE
                    if V(BarCTap(i)) <= Vesp(BarCTap(i))
                        ModoTap(i) = 1;
                        TapLim(i) = TapMin(TapC(i,3)) - 1E-5;
                    end
                else
                    if V(BarCTap(i)) >= Vesp(BarCTap(i))
                        ModoTap(i) = 1;
                        TapLim(i) = TapMin(TapC(i,3)) - 1E-5;
                    end
                end
            end
        end
    end
    
%% Controle das Linhas HVDC
    LinhasHVDC = size(DHVDC,1);
    ModoHVDC = zeros(LinhasHVDC,2);
    HVDCLim = zeros(LinhasHVDC, 5);
    
    for i=1:LinhasHVDC
        
        Vdr = Xhvdc(12*(i-1) + 1);
        Ir = Xhvdc(12*(i-1) + 5);
        Alfa= Xhvdc(12*(i-1) + 9);
        Gamma= Xhvdc(12*(i-1) + 10);
        TAPr= Xhvdc(12*(i-1) + 11);
        TAPi= Xhvdc(12*(i-1) + 12);
        
        TAPrEsp = DHVDC(i,33);
        TAPiEsp = DHVDC(i,34);
        TAPrMin = DHVDC(i,8);
        TAPrMx = DHVDC(i,9);
        TAPiMin = DHVDC(i,10);
        TAPiMx = DHVDC(i,11);
        AlfaEsp = DHVDC(i,12);
        AlfaMin = DHVDC(i,13);  
        AlfaMax = DHVDC(i,14);
        GammaEsp = DHVDC(i,15);
        GammaMin = DHVDC(i,16);
        GammaMax = DHVDC(i,17);
        IrEsp = DHVDC(i,18);
        IrMin = DHVDC(i,19);
        IrMx = DHVDC(i,20); 
        DE_ret = DHVDC(i,1);
        PARA_inv = DHVDC(i,2);
        VdrEsp = DHVDC(i,32);
        PConst = DHVDC(i,27);
        TipoDeControle = DHVDC(i,21); %Normal = 0, HighMvar = 1, artigo = 2, convencional = 3; Stab50 = 4;
        Ir_Esp = DHVDC(i,28);
        
    %% LIMITES NO RETIFICADOR
        %% MODOS NORMAL, HIGH MVAR CONSUMPTION, CONVENCIONAL(Tap), STAB50(Tap) E SFT(Tap)
        ModoHVDC(i,1) = 0;
        if (sum(TipoDeControle == [0 1 5 6 7])) 
            % Tap do retificador no Max
            if TAPr > TAPrMx
                % Verifico Back Off
                if Alfa <= AlfaEsp
                    ModoHVDC(i,1) = 1;
                    HVDCLim(i, 1) = TAPrMx + 1E-5;
                    % ângulo de disparo do ret no min
                    if Alfa < AlfaMin
                        % Verifico Back Off
                        DVdr = (Vdr - VdrEsp);
                        DIr = FptHVDCE(i,2)*DVdr;
                        IrEspC = IrEsp;
                        IrEspC = IrEspC + (TipoDeControle == 5)*GovernorControl*(PConst==0)*FptHVDCE(i,2)*(DIr); % STF POR TAP ICONST
                        IrEspC = IrEspC + (TipoDeControle == 5)*GovernorControl*(PConst==1)*FptHVDCE(i,2)*(DIr*VdrEsp + DVdr*Ir_Esp + DVdr*DIr)/Vdr; % STF POR TAP PCONST
                        if Ir <= IrEspC
                            ModoHVDC(i,1) = 2;
                            HVDCLim(i, 2) = AlfaMin - 1E-5;
                            if (sum(TipoDeControle == [0 6 7])) % Apenas no Modo Normal, Convencional(Tap) e Stab50(Tap)
                                % Corrente do Elo no mínimo
                                if Ir < IrMin
                                    % Verifico Back Off
                                    if Gamma >= GammaEsp
                                        ModoHVDC(i,1) = 3;
                                        HVDCLim(i, 3) = IrMin - 1E-5;
                                    end
                                end
                            end
                        end

                    end

                end
            elseif TAPr < TAPrMin
                % Verifico Back Off
                if Alfa >= AlfaEsp
                    ModoHVDC(i,1) = 1;
                    HVDCLim(i, 1) = TAPrMin - 1E-5;
                    % ângulo de disparo do ret no max
                    if Alfa > AlfaMax
                        % Verifico Back Off
                        DVdr = (Vdr - VdrEsp);
                        DIr = FptHVDCE(i,2)*DVdr;
                        IrEspC = IrEsp;
                        IrEspC = IrEspC + (TipoDeControle == 5)*GovernorControl*(PConst==0)*FptHVDCE(i,2)*(DIr); % STF POR TAP ICONST
                        IrEspC = IrEspC + (TipoDeControle == 5)*GovernorControl*(PConst==1)*FptHVDCE(i,2)*(DIr*VdrEsp + DVdr*Ir_Esp + DVdr*DIr)/Vdr; % STF POR TAP PCONST
                        if Ir >= IrEspC
                            ModoHVDC(i,1) = 2;
                            HVDCLim(i, 2) = AlfaMax + 1E-5;
                            if (sum(TipoDeControle == [0 6 7])) % Apenas no Modo Normal, Convencional(Tap) e Stab50(Tap)
                                % Corrente do Elo no mínimo
                                if Ir > IrMx
                                    % Verifico Back Off
                                    if Gamma <= GammaEsp
                                        ModoHVDC(i,1) = 3;
                                        HVDCLim(i, 3) = IrMx + 1E-5;
                                    end
                                end
                            end
                        end
                    end
                end
            end  

        %% MODOS CONVENCIONAL(Tiristor), STAB50(Tiristor) E SFT(Tiristor)
        elseif sum(TipoDeControle == [2 3 4])
            if Alfa > AlfaMax
                % Verifico Back Off
                if TAPr <= TAPrEsp
                    ModoHVDC(i,1) = 1;
                    HVDCLim(i, 2) = AlfaMax + 1E-5;
                    % Tap no min
                    if TAPr < TAPrMin
                        % Verifico Back Off
                        DVdr = (Vdr - VdrEsp);
                        DIr = FptHVDCE(i,2)*DVdr;
                        IrEspC = IrEsp;
                        IrEspC = IrEspC + (TipoDeControle == 2)*GovernorControl*(PConst==0)*FptHVDCE(i,2)*(DIr); % STF POR TIRISTOR ICONST
                        IrEspC = IrEspC + (TipoDeControle == 3)*GovernorControl*(PConst==0)*FptHVDCE(i,1)*(1-Freq(Area(PARA_inv))); % CONVENCIONAL ICONST
                        IrEspC = IrEspC + (TipoDeControle == 4)*GovernorControl*(PConst==0)*(-FptHVDCE(i,1)*(1-Freq(Area(DE_ret))))/VdrEsp; % STAB50 ICONST
                        IrEspC = IrEspC + (TipoDeControle == 4)*GovernorControl*(PConst==0)*(-FptHVDCE(i,2)*(0.996-Freq(Area(DE_ret))))/VdrEsp; % STAB50 ICONST
                        IrEspC = IrEspC + (TipoDeControle == 2)*GovernorControl*(PConst==1)*FptHVDCE(i,2)*(DIr*VdrEsp + DVdr*Ir_Esp + DVdr*DIr)/Vdr; % STF POR TIRISTOR PCONST
                        IrEspC = IrEspC + (TipoDeControle == 3)*GovernorControl*(PConst==1)*VdrEsp*FptHVDCE(i,1)*(1-Freq(Area(PARA_inv)))/Vdr; % CONVENCIONAL PCONST
                        IrEspC = IrEspC + (TipoDeControle == 4)*GovernorControl*(PConst==1)*(-FptHVDCE(i,1)*(1-Freq(Area(DE_ret))))/Vdr; % STAB50 PCONST
                        IrEspC = IrEspC + (TipoDeControle == 4)*GovernorControl*(PConst==1)*(-GovernorControl*FptHVDCE(i,2)*(0.996-Freq(Area(DE_ret))))/Vdr; % STAB50 PCONST
                        if Ir >= IrEspC
                            ModoHVDC(i,1) = 2;
                            HVDCLim(i, 1) = TAPrMin - 1E-5;
                            if sum(TipoDeControle == [3 4]) % Apenas no Stab50 e Convencional
                                % Corrente do Elo no mínimo
                                if Ir > IrMx
                                    % Verifico Back Off
                                    if Gamma <= GammaEsp
                                        ModoHVDC(i,1) = 3;
                                        HVDCLim(i, 3) = IrMx + 1E-5;
                                    end
                                end
                            end
                        end
                    end
                end

            elseif Alfa < AlfaMin
                if TAPr >= TAPrEsp
                    ModoHVDC(i,1) = 1;
                    HVDCLim(i, 2) = AlfaMin - 1E-5;
                    % Tap no min
                    if TAPr > TAPrMx
                        % Verifico Back Off
                        DVdr = (Vdr - VdrEsp);
                        DIr = FptHVDCE(i,2)*DVdr;
                        IrEspC = IrEsp;
                        IrEspC = IrEspC + (TipoDeControle == 2)*GovernorControl*(PConst==0)*FptHVDCE(i,2)*(DIr);
                        IrEspC = IrEspC + (TipoDeControle == 3)*GovernorControl*(PConst==0)*FptHVDCE(i,1)*(1-Freq(Area(PARA_inv)));
                        IrEspC = IrEspC + (TipoDeControle == 4)*GovernorControl*(PConst==0)*(-FptHVDCE(i,1)*(1-Freq(Area(DE_ret))))/VdrEsp;
                        IrEspC = IrEspC + (TipoDeControle == 4)*GovernorControl*(PConst==0)*(-FptHVDCE(i,2)*(0.996-Freq(Area(DE_ret))))/VdrEsp;
                        IrEspC = IrEspC + (TipoDeControle == 2)*GovernorControl*(PConst==1)*FptHVDCE(i,2)*(DIr*VdrEsp + DVdr*Ir_Esp + DVdr*DIr)/Vdr;
                        IrEspC = IrEspC + (TipoDeControle == 3)*GovernorControl*(PConst==1)*VdrEsp*FptHVDCE(i,1)*(1-Freq(Area(PARA_inv)))/Vdr;
                        IrEspC = IrEspC + (TipoDeControle == 4)*GovernorControl*(PConst==1)*(-FptHVDCE(i,1)*(1-Freq(Area(DE_ret))))/Vdr;
                        IrEspC = IrEspC + (TipoDeControle == 4)*GovernorControl*(PConst==1)*(-GovernorControl*FptHVDCE(i,2)*(0.996-Freq(Area(DE_ret))))/Vdr;
                        if Ir <= IrEspC
                            ModoHVDC(i,1) = 2;
                            HVDCLim(i, 1) = TAPrMx + 1E-5;
                            if sum(TipoDeControle == [3 4]) % Apenas no Stab50 e Convencional
                                % Corrente do Elo no mínimo
                                if Ir < IrMin
                                    % Verifico Back Off
                                    if Gamma >= GammaEsp
                                        ModoHVDC(i,1) = 3;
                                        HVDCLim(i, 3) = IrMin - 1E-5;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    %% LIMITES NO INVERSOR
        ModoHVDC(i,2) = 0;
        %% MODOS NORMAL, CONVENCIONAL E STAB50
        if (sum(TipoDeControle == [0 3 6 7])) 
            % Tap do inversor no Max
            if TAPi > TAPiMx
                % Verifico Back Off
                if Vdr <= VdrEsp
                    ModoHVDC(i,2) = 1;
                    HVDCLim(i, 4) = TAPiMx + 1E-5;
                end
                
            elseif TAPi < TAPiMin
                % Verifico Back Off
                if Vdr >= VdrEsp
                    ModoHVDC(i,2) = 1;
                    HVDCLim(i, 4) = TAPiMin - 1E-5;
                end
            end
        %% MODO HIGH MVAR CONSUMPTION E SFT POR TAP
        elseif (sum(TipoDeControle == [1 5])) 
            % Tap do retificador no Max
            if TAPi > TAPiMx
                % Verifico Back Off
                if Gamma <= GammaEsp
                    ModoHVDC(i,2) = 1;
                    HVDCLim(i, 4) = TAPiMx + 1E-5;
                    if Gamma < GammaMin
                        % Verifico Back Off
                        if Vdr <= VdrEsp
                            ModoHVDC(i,2) = 2;
                            HVDCLim(i, 5) = GammaMin - 1E-5;
                        end
                    end
                end
            elseif TAPi < TAPiMin
                % Verifico Back Off
                if Gamma >= GammaEsp
                    ModoHVDC(i,2) = 1;
                    HVDCLim(i, 4) = TAPiMin - 1E-5;
                    if Gamma > GammaMax
                        % Verifico Back Off
                        if Vdr >= VdrEsp
                            ModoHVDC(i,2) = 2;
                            HVDCLim(i, 5) = GammaMax + 1E-5;
                        end
                    end
                end
            end
		%% MODO SFT POR TIRISTOR
        elseif (TipoDeControle == 2) 
            % GAMMA INVERSOR no Max
            if Gamma > GammaMax
                % Verifico Back Off
                if TAPi <= TAPiEsp 
                    ModoHVDC(i,2) = 1;
                    HVDCLim(i, 5) = GammaMax + 1E-5;
                    if (TAPi < TAPiMin)
                        % Verifico Back Off
                        if Vdr >= VdrEsp
                            ModoHVDC(i,2) = 2;
                            HVDCLim(i, 4) = TAPiMin - 1E-5;
                        end
                    end
                end
            elseif Gamma < GammaMin
                % Verifico Back Off
                if TAPi >= TAPiEsp
                    ModoHVDC(i,2) = 1;
                    HVDCLim(i, 5) = GammaMin - 1E-5;
                    if (TAPi > TAPiMx)
                        % Verifico Back Off
                        if Vdr <= VdrEsp
                            ModoHVDC(i,2) = 2;
                            HVDCLim(i, 4) = TAPiMx + 1E-5;
                        end
                    end
                end
            end
        end
    end
end
