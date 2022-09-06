function J = Cria_J(Xhvdc, DHVDC, ModoHVDC)


    LinhasHVDC = 1;
    for i = 1:LinhasHVDC
        % Matriz referente as variáveis Vdr, Vdi, FIr, FIi, Ir, Ii, MIr e MIi
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
        TipoDeControle = DHVDC(i,21);

        CC_CC = zeros(12);
        Kr = DHVDC(i,3);
        Ki = DHVDC(i,4);
        Xr = DHVDC(i,5);
        Xi = DHVDC(i,6);
        PontesR = DHVDC(i,29);
        PontesI = DHVDC(i,30);
        Rr = 3*Xr/pi;
        Ri = -3*Xi/pi;
        Rcc = DHVDC(i,7);
        PConst = DHVDC(i,27);
        ModoHVDCRet = ModoHVDC(i,1);
        ModoHVDCInv = ModoHVDC(i,2);


        % inclui as variaveis 1 a 8 na Submatriz CC_CC
        CC_CC(1,1) = 1;
        CC_CC(1,5) = Rr*PontesR;
        CC_CC(1,9) = Kr*TAPr*sin(Alfa);
        CC_CC(1,11) = -Kr*cos(Alfa);
        CC_CC(2,2) = 1;
        CC_CC(2,6) = Ri*PontesI;
        CC_CC(2,10) = Ki*TAPi*sin(Gamma);
        CC_CC(2,12) = -Ki*cos(Gamma);
        CC_CC(3,5) = -2*PontesR*Rr/(Kr*TAPr);
        CC_CC(3,7) = sin(Alfa+MIr);
        CC_CC(3,9) = -sin(Alfa)+sin(Alfa+MIr);
        CC_CC(3,11) = 2*PontesR*Rr*Ir/(Kr*TAPr^2);
        CC_CC(4,6) = -2*PontesI*Ri/(Ki*TAPi);
        CC_CC(4,8) = sin(Gamma+MIi);
        CC_CC(4,10) = -sin(Gamma)+sin(Gamma+MIi);
        CC_CC(4,12) = 2*PontesI*Ri*Ii/(Ki*TAPi^2);
        CC_CC(5,3) = -1/cos(FIr)^2;
        
        %Da dissertação do joão
        %CC_CC(5,7) = (4 * cos(2*MIr) -4*MIr*sin(2*Alfa) +4*MIr*sin(2*(Alfa+MIr)) -4) / (cos(2*(Alfa+MIr)) - cos(2*Alfa))^2;
        % Derivado no Wolfram
        CC_CC(5,7) = -(2*(-sin(2*(MIr+Alfa)) +2*MIr +sin(2*Alfa))*sin(2*(MIr+Alfa)) -2*(cos(2*(MIr+Alfa)) - 1)*(cos(2*(MIr+Alfa)) -cos(2*Alfa)))/(cos(2*Alfa) -cos(2*(MIr+Alfa)))^2;
        % Alguma derivada que fiz?
        %CC_CC(5,7) = ((2-2*cos(2*(MIr+Alfa)))*(cos(2*Alfa)-cos(2*(Alfa+MIr))) - 2*sin(2*(Alfa+MIr))*(2*MIr+sin(2*Alfa)-sin(2*(Alfa+MIr))))/(cos(2*Alfa)-cos(2*(Alfa+MIr)))^2 + sec(acos((cos(Alfa)+cos(Alfa+MIr))/2))^2*(-sin(Alfa+MIr))/sqrt(4-cos(Alfa)^2-2*cos(Alfa)*cos(Alfa+MIr)-cos(Alfa+MIr)^2);

        % Da dissertação do joão
        %CC_CC(5,9) = (-2 +2*(cos(2*MIr) +cos(2*(Alfa+MIr)) -cos(2*Alfa) +2*MIr*sin(2*(Alfa+MIr))))/(cos(2*(Alfa+MIr)) - cos(2*Alfa))^2;
        % De algum lugar
        %CC_CC(5,9) = (cos(2*Alfa)*2-cos(2*(Alfa+MIr))*2*(cos(2*Alfa)-cos(2*(Alfa+MIr)))-(-2*sin(2*Alfa)+2*sin(2*(Alfa+MIr)))*(2*MIr+sin(2*Alfa)-sin(2*(Alfa+MIr))))/(cos(2*Alfa)-cos(2*(Alfa+MIr)))^2;
        %Do Wolfram
        CC_CC(5,9) = -((2*cos(2*(MIr + Alfa)) - 2*cos(2*Alfa))/(cos(2*Alfa) - cos(2*(MIr + Alfa))) - ((sin(2*(MIr + Alfa)) - 2*MIr - sin(2*Alfa))*(2*sin(2*(MIr + Alfa)) - 2*sin(2*Alfa)))/(cos(2*Alfa) - cos(2*(MIr + Alfa)))^2);
        
        CC_CC(6,4) = -1/cos(FIi)^2;
        
        % Da dissertação do joão
        %CC_CC(6,8) = (4*cos(2*MIi) -4*MIi*sin(2*Gamma) +4*MIi*sin(2*(Gamma+MIi)) - 4) / (cos(2*(Gamma+MIi)) - cos(2*Gamma))^2;
        % Derivado no Wolfram
        CC_CC(6,8) = -(2*(-sin(2*(MIi+Gamma)) +2*MIi +sin(2*Gamma))*sin(2*(MIi+Gamma)) -2*(cos(2*(MIi+Gamma)) - 1)*(cos(2*(MIi+Gamma)) -cos(2*Gamma)))/(cos(2*Gamma) -cos(2*(MIi+Gamma)))^2;
        % Alguma derivada que fiz?    
        %CC_CC(6,8) = ((2-2*cos(2*(MIi+Gamma)))*(cos(2*Gamma)-cos(2*(Gamma+MIi))) - 2*sin(2*(Gamma+MIi))*(2*MIi+sin(2*Gamma)-sin(2*(Gamma+MIi))))/(cos(2*Gamma)-cos(2*(Gamma+MIi)))^2 + sec(acos((cos(Gamma)+cos(Gamma+MIi))/2))^2*(-sin(Gamma+MIi))/sqrt(4-cos(Gamma)^2-2*cos(Gamma)*cos(Gamma+MIi)-cos(Gamma+MIi)^2);
        
        % Da dissertação do João
        %CC_CC(6,10) = (-2 +2*(cos(2*MIi) +cos(2*(Gamma+MIi)) -cos(2*Gamma) +2*MIi*sin(2*(Gamma+MIi))))/(cos(2*(Gamma+MIi)) - cos(2*Gamma))^2;
        % De algum lugar
        %CC_CC(6,10) = (cos(2*Gamma)*2-cos(2*(Gamma+MIi))*2*(cos(2*Gamma)-cos(2*(Gamma+MIi)))-(-2*sin(2*Gamma)+2*sin(2*(Gamma+MIi)))*(2*MIi+sin(2*Gamma)-sin(2*(Gamma+MIi))))/(cos(2*Gamma)-cos(2*(Gamma+MIi)))^2;
        % Do Wolfram
        CC_CC(6,10) = -((2*cos(2*(MIi + Gamma)) - 2*cos(2*Gamma))/(cos(2*Gamma) - cos(2*(MIi + Gamma))) - ((sin(2*(MIi + Gamma)) - 2*MIi - sin(2*Gamma))*(2*sin(2*(MIi + Gamma)) - 2*sin(2*Gamma)))/(cos(2*Gamma) - cos(2*(MIi + Gamma)))^2);
        
        CC_CC(7,1) = 1;
        CC_CC(7,2) = -1;
        CC_CC(7,5) =  -Rcc;
        CC_CC(8,1) = -1;
        CC_CC(8,2) = 1;
        CC_CC(8,6) = -Rcc;
            
        %-((2*cos(2*(Alfa + MIr))- 2)/(cos(2*Alfa) - cos(2*(Alfa + MIr))) - (2*sin(2*(Alfa + MIr))*(sin(2*(Alfa + MIr)) - sin(2*Alfa) - 2*MIr))/(cos(2*Alfa) - cos(2*(Alfa + MIr)))^2);
        
        % Matriz referente as variáveis alfa(angulo de disp. do ret.), gama(angulo de disp. do inv.), ar e ai
    %% DERIVADAS PARA O CONTROLE NO RETIFICADOR
        % CONTROLES NORMAL E HIGH MVAR CONSUMPTION
        if (sum(TipoDeControle == [0 1])) 
            CC_CC(9,9) = CC_CC(9,9)+(ModoHVDCRet == 0)*1; % Modo 0
            CC_CC(10,5) = CC_CC(10,5)+(PConst == 0)*(sum(ModoHVDCRet == [0 1]))*1;   % Modos 0 e 1 com Corrente constante
            CC_CC(10,1) = CC_CC(10,1)+(PConst == 1)*(sum(ModoHVDCRet == [0 1]))*Ir;  % Modos 0 e 1 com Potência constante
            CC_CC(10,5) = CC_CC(10,5)+(PConst == 1)*(sum(ModoHVDCRet == [0 1]))*Vdr; % Modos 0 e 1 com Potência constante
            CC_CC(10,2) = CC_CC(10,2)+(PConst == 2)*(sum(ModoHVDCRet == [0 1]))*(-Ii*tan(FIi));  % Modos 0 e 1 com Potência constante
            CC_CC(10,6) = CC_CC(10,6)+(PConst == 2)*(sum(ModoHVDCRet == [0 1]))*(-Vdi*tan(FIi)); % Modos 0 e 1 com Potência constante
            CC_CC(10,4) = CC_CC(10,4)+(PConst == 2)*(sum(ModoHVDCRet == [0 1]))*(-Vdi*Ii*sec(FIi)^2); % Modos 0 e 1 com Potência constante
            CC_CC(11,10) = CC_CC(11,10)+(TipoDeControle == 0)*(sum(ModoHVDCRet == [0 1 2]))*1; % Modos 0, 1 e 2 com controle Normal(0)
            CC_CC(9,11) = CC_CC(9,11)+(sum(ModoHVDCRet == [1 2 3]))*1; % Modos 1,2 e 3
            CC_CC(10,9) = CC_CC(10,9)+(sum(ModoHVDCRet == [2 3]))*1; % Modos 2 e 3
            CC_CC(11,5) = CC_CC(11,5)+(ModoHVDCRet == 3)*1; % Modo 3
        % CONTROLES CONVENCIONAL, STAB50 E ARTIGO
        elseif sum(TipoDeControle == [2 3 4])
            CC_CC(9,11) = CC_CC(9,11)+(ModoHVDCRet == 0)*1; % Modo 0
            CC_CC(9,9) = CC_CC(9,9)+sum(ModoHVDCRet == [1 2 3])*1; % Modos 1 2 e 3
            CC_CC(10,11) = CC_CC(10,11)+sum(ModoHVDCRet == [2 3])*1; % Modos 2 e 3
            CC_CC(11,10) = CC_CC(11,10)+sum(ModoHVDCRet == [0 1 2])*sum(TipoDeControle == [3 4])*1; % Modos 0, 1 e 2 do Controle Stab50 e convencional
            CC_CC(11,5) = CC_CC(11,5)+(ModoHVDCRet == 3)*sum(TipoDeControle == [3 4])*1; % Modo 3 do Controle Stab50 e convencional
            if sum(ModoHVDCRet == [0 1]) % MODOS 0 e 1
                if (PConst == 0) % Controle Por Corrente Constante
                    CC_CC(10,5) = CC_CC(10,5)+1; % Para todos os casos
                elseif (PConst == 1) % Controle Por Potência Constante
                    CC_CC(10,1) = CC_CC(10,1)+Ir; % Para todos os casos
                    CC_CC(10,5) = CC_CC(10,5)+Vdr; % Para todos os casos
                else
                    CC_CC(10,2) = CC_CC(10,2)-Ii*tan(FIi); % Para todos os casos
                    CC_CC(10,6) = CC_CC(10,6)-Vdi*tan(FIi); % Para todos os casos
                    CC_CC(10,4) = CC_CC(10,4)-Vdi*Ii*sec(FIi)^2; % Para todos os casos
                end
            end
        end
    %% DERIVADAS PARA O CONTROLE NO INVERSOR    
        % CONTROLES NORMAL, STAB50 e CONVENCIONAL
        if (sum(TipoDeControle == [0 3 4])) 
            CC_CC(12,1) = CC_CC(12,1)+(ModoHVDCInv == 0)*(DHVDC(i,31) == 0)*1; % Modo 0 com controle de Tensão no retificador
            CC_CC(12,2) = CC_CC(12,2)+(ModoHVDCInv == 0)*(DHVDC(i,31) == 1)*1; % Modo 0 com controle de Tensão no inversor
            CC_CC(12,12) = CC_CC(12,12)+(ModoHVDCInv == 1)*1; % Modo 1
        % CONTROLE HIGH MVAR CONSUMPTION
        elseif (TipoDeControle == 1)
            CC_CC(11,10) = CC_CC(11,10)+(ModoHVDCInv == 0)*1; % Modo 0
            CC_CC(11,12) = CC_CC(11,12)+(sum(ModoHVDCInv == [1 2]))*1; % Modo 1
            CC_CC(12,1) = CC_CC(12,1)+sum(ModoHVDCInv == [0 1])*(DHVDC(i,31) == 0)*1; % Modos 0 e 1 com controle de Tensão no retificador
            CC_CC(12,2) = CC_CC(12,2)+sum(ModoHVDCInv == [0 1])*(DHVDC(i,31) == 1)*1; % Modos 0 e 1 com controle de Tensão no inversor
            CC_CC(12,10) = CC_CC(12,10)+(ModoHVDCInv == 2)*1; % Modo 2
        % CONTROLE SFT
        elseif (TipoDeControle == 2)
            CC_CC(11,12) = CC_CC(11,12)+(ModoHVDCInv == 0)*1; % Modo 0
            CC_CC(11,10) = CC_CC(11,10)+(sum(ModoHVDCInv == [1 2]))*1; % Modo 1
            CC_CC(12,2) = CC_CC(12,2)+sum(ModoHVDCInv == [0 1])*1; % Modos 0 e 1
            CC_CC(12,12) = CC_CC(12,12)+(ModoHVDCInv == 2)*1; % Modo 2
        end
        % Adiciona as alterações a matriz J  
    end
    J = CC_CC;
end








