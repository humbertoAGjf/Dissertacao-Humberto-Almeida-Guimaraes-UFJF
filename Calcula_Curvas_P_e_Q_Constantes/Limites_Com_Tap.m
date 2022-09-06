function [ModoHVDC, HVDCLim]= Limites_Com_Tap(Xhvdc, DHVDC)


    
%% Controle das Linhas HVDC
    LinhasHVDC = 1;
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
        ModoControle = DHVDC(i,21);   %Normal = 0, HighMvar = 1, artigo = 2, convencional = 3; Stab50 = 4;
        VdrEsp = DHVDC(i,32);
        
    %% LIMITES NO RETIFICADOR
        %% MODOS NORMAL E HIGH MVAR CONSUMPTION
        ModoHVDC(i,1) = 0;
        if (sum(ModoControle == [0 1])) 
            % Tap do retificador no Max
            if TAPr > TAPrMx
                % Verifico Back Off
                if Alfa <= AlfaEsp
                    ModoHVDC(i,1) = 1;
                    HVDCLim(i, 1) = TAPrMx + 1E-5;
                    % ângulo de disparo do ret no min
                    if Alfa < AlfaMin
                        % Verifico Back Off
                        if Ir <= IrEsp
                            ModoHVDC(i,1) = 2;
                            HVDCLim(i, 2) = AlfaMin - 1E-5;
                            if (ModoControle == 0) % Apenas no Modo Normal
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
                        if Ir >= IrEsp
                            ModoHVDC(i,1) = 2;
                            HVDCLim(i, 2) = AlfaMax + 1E-5;
                            if (ModoControle == 0) % Apenas no Modo Normal
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

        %% MODOS CONVENCIONAL, STAB50 E ARTIGO
        elseif sum(ModoControle == [2 3 4])
            if Alfa > AlfaMax
                % Verifico Back Off
                if TAPr <= TAPrEsp
                    ModoHVDC(i,1) = 1;
                    HVDCLim(i, 2) = AlfaMax + 1E-5;
                    % Tap no min
                    if TAPr < TAPrMin
                        % Verifico Back Off
                        IrEspC = IrEsp;
                        if Ir >= IrEspC
                            ModoHVDC(i,1) = 2;
                            HVDCLim(i, 1) = TAPrMin - 1E-5;
                            if sum(ModoControle == [3 4]) % Apenas no Stab50 e Convencional
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
                        IrEspC = IrEsp;
                        if Ir <= IrEspC
                            ModoHVDC(i,1) = 2;
                            HVDCLim(i, 1) = TAPrMx + 1E-5;
                            if sum(ModoControle == [3 4]) % Apenas no Stab50 e Convencional
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
        if (sum(ModoControle == [0 3])) 
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
        %% MODO HIGH MVAR CONSUMPTION
        elseif (ModoControle == 1) 
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
		%% MODO DO ARTIGO
        elseif (ModoControle == 2) 
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
