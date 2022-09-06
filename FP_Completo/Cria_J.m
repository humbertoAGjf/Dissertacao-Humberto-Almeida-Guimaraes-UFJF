function J = Cria_J(Nbar, Y, V, Th, Freq, Tap, Xhvdc, DHVDC, ModoHVDC, r, x, BarVTh, BarGer, BarCGer, ModoGer, TapC, ModoTap, BarCTap, Pcal, Qcal, ControleTen, ControleRes, GovernorControl, FptTap, FptGerR, FptGerA, FptGerE, Area, LoadDamping, FptHVDCE, Pc, Qc, FPC, TipoFPC)

    G = real(Y);
    B = imag(Y);
        
    % Cria as submatrizes de J
    H=zeros(Nbar);    
    N=zeros(Nbar); 
    M=zeros(Nbar); 
    L=zeros(Nbar); 
    
    for i=1:Nbar
        for m=1:Nbar   
            if (i==m)
                H(m,m) = -Qcal(m)-V(m)^2*B(m,m);
                N(m,m) = Pcal(m)/V(m)+V(m)*G(m,m);
                M(m,m) = Pcal(m)-V(m)^2*G(m,m);
                L(m,m) = Qcal(m)/V(m)-V(m)*B(m,m);
            else
                Th_im = Th(i)-Th(m);
                H(i,m) = V(i)*V(m)*(G(i,m)*sin(Th_im)-B(i,m)*cos(Th_im));
                N(i,m) = V(i)*(G(i,m)*cos(Th_im)+B(i,m)*sin(Th_im));
                M(i,m) = -V(i)*V(m)*(G(i,m)*cos(Th_im)+B(i,m)*sin(Th_im));
                L(i,m) = V(i)*(G(i,m)*sin(Th_im)-B(i,m)*cos(Th_im));
            end
        end
    end
    
    % Monta a Matriz J
    J=[H N; M L];
     
    % Adiciona Controle de tensão dos geradores
    NGer = length(BarGer);
    J = [J zeros(2*Nbar,NGer);zeros(NGer,2*Nbar+NGer)]; 
    BarCGer = BarCGer(ModoGer == 0); % Retiro as barras que estão travadas no limite
    ii = 0;
    [~, ia, ~] = unique(BarCGer,'stable'); % Ex: Se BarCTapAtual = [2, 3, 3, 4], então ia = [1,2,4]
    Aux = 1;
    for i=1:NGer
        J(Nbar+BarGer(i),2*Nbar+i) = -1; % dQi/dQgi, Qgi = geração reativa do gerador controlador
        if (ModoGer(i) == 0)
            ii = ii + 1;
            % Derivada de deltaV em relação a todas as variáveis.
            % Controle ON
            if Aux>length(ia)
                % Para controle coordenado de tensão, caso 2 Geradores controlem a mesma barra(evita a singularidade na matriz)
                % Essa condição é utilizada para caso o Gerador de controle esteja na ultima posição do vetor ia
                J(2*Nbar+i,2*Nbar+i-1) = FptGerR(i);
                J(2*Nbar+i,2*Nbar+i) = -FptGerR(i-1); % neste caso alfa = 1 (Logo o controle é feito de forma igualitária, 50% pra cada Gerador)
            elseif ii == ia(Aux)  % Para Controle de tap normal
                J(2*Nbar+i,Nbar+BarCGer(ii)) = 1; % dVi/dVi, Vi = tensão na barra controlada
                Aux = Aux+1;
            else
                % Para controle coordenado de tensão, caso 2 Geradores controlem a mesma barra(evita a singularidade na matriz)
                % Essa condição é utilizada para abrangir todos os outros caso q a condiçao "Aux>length(ia)" não abrange
                J(2*Nbar+i,2*Nbar+i-1) = FptGerR(i);
                J(2*Nbar+i,2*Nbar+i) = -FptGerR(i-1); % neste caso alfa = 1 (Logo o controle é feito de forma igualitária, 50% pra cada trafo)
            end
            % Controle OFF(Travado no limite)
        else
            J(2*Nbar+i,2*Nbar+i) = 1; % dQgi/dQgi, Qgi = Geração de reativo do gerador
        end
    end

    
    % Adiciona Controle de tensão por Tap de Trafo
    NTap = length(BarCTap)*ControleTen;
    if (ControleTen==1)
        Ykm = 1./(r+1i*x);
        Gkm = real(Ykm);
        Bkm = imag(Ykm);
        if ~isempty(BarCTap)
            BarCTap = BarCTap(ModoTap == 0); % Retiro as barras que estão travadas no limite
            ii = 0;
            [~, ia, ~] = unique(BarCTap,'stable'); % Ex: Se BarCTapAtual = [2, 3, 3, 4], então ia = [1,2,4]
            Aux = 1;
            J = [J zeros(2*Nbar+NGer, NTap);zeros(NTap,2*Nbar+NGer+NTap)];
            for i=1:NTap
                de = TapC(i,1);
                para = TapC(i,2);
                LinI = TapC(i,3);
                Th_km = Th(de)-Th(para);
                % Derivadas d'Pk'/d'akm' e d'Pm'/d'akm'
                J(de,2*Nbar+NGer+i) = 2*Tap(LinI)*V(de)^2*Gkm(LinI)-V(de)*V(para)*Gkm(LinI)*cos(Th_km)-V(de)*V(para)*Bkm(LinI)*sin(Th_km);
                J(para,2*Nbar+NGer+i) = -V(de)*V(para)*Gkm(LinI)*cos(Th_km)+V(de)*V(para)*Bkm(LinI)*sin(Th_km);
                % Derivadas d'Qk'/d'akm' e d'Qm'/d'akm'
                J(Nbar+de,2*Nbar+NGer+i) = -2*Tap(LinI)*V(de)^2*Bkm(LinI)+V(de)*V(para)*Bkm(LinI)*cos(Th_km)-V(de)*V(para)*Gkm(LinI)*sin(Th_km);
                J(Nbar+para,2*Nbar+NGer+i) = V(de)*V(para)*Bkm(LinI)*cos(Th_km)+V(de)*V(para)*Gkm(LinI)*sin(Th_km);
                % CASO O TAP ESTEJA 1:a em vez de a:1
                % Derivadas d'Pk'/d'akm' e d'Pm'/d'akm'
%                 J(de,2*Nbar+NGerPV+i) = -V(de)*V(para)*Gkm(LinI)*cos(Th_km)-V(de)*V(para)*Bkm(LinI)*sin(Th_km);
%                 J(para,2*Nbar+NGerPV+i) = 2*Tap(LinI)*V(para)^2*Gkm(LinI)-V(de)*V(para)*Gkm(LinI)*cos(Th_km)+V(de)*V(para)*Bkm(LinI)*sin(Th_km);
%                 % Derivadas d'Qk'/d'akm' e d'Qm'/d'akm'
%                 J(Nbar+de,2*Nbar+NGerPV+i) = +V(de)*V(para)*Bkm(LinI)*cos(Th_km)-V(de)*V(para)*Gkm(LinI)*sin(Th_km);
%                 J(Nbar+para,2*Nbar+NGerPV+i) = -2*Tap(LinI)*V(para)^2*Bkm(LinI)+V(de)*V(para)*Bkm(LinI)*cos(Th_km)+V(de)*V(para)*Gkm(LinI)*sin(Th_km);
                
                if (ModoTap(i) == 0)
                    ii = ii + 1;
                % Derivada de deltaV em relação a todas as variáveis.
                % Controle ON
                    if Aux>length(ia)  
                        % Para controle coordenado de tensão, caso 2 trafos controlem a mesma barra(evita a singularidade na matriz)
                        % Essa condição é utilizada para caso o trafo de controle esteja na ultima posição do vetor ia
                        J(2*Nbar+NGer+i,2*Nbar+NGer+i-1) = FptTap(i);
                        J(2*Nbar+NGer+i,2*Nbar+NGer+i) = -FptTap(i-1); % Por Padrão o valor é 1, mas pode ser alterado no arquivo do sistema pela Var FptTAp
                    elseif ii == ia(Aux)  % Para Controle de tap normal
                        J(2*Nbar+NGer+i,Nbar+BarCTap(ii)) = 1;
                        Aux = Aux+1;
                    else
                        % Para controle coordenado de tensão, caso 2 trafos controlem a mesma barra(evita a singularidade na matriz)
                        % Essa condição é utilizada para abrangir todos os outros caso q a condiçao "Aux>length(ia)" não abrange
                        J(2*Nbar+NGer+i,2*Nbar+NGer+i-1) = FptTap(i);
                        J(2*Nbar+NGer+i,2*Nbar+NGer+i) = -FptTap(i-1); % Por Padrão o valor é 1, mas pode ser alterado no arquivo do sistema pela Var FptTAp
                    end
                % Derivada de deltaTap em relação a todas as variáveis
                % Controle OFF(Travado no limite)
                else
                    J(2*Nbar+NGer+i,2*Nbar+NGer+i) = 1;
                end
            end
        end
    end
    

    NgerETotal =0;
    if (GovernorControl == 1)
        NArea = length(unique(Area));
        NgerETotal = size(FptGerE,1);
        J = [J zeros(2*Nbar+NGer+NTap, NgerETotal+NArea); zeros(NgerETotal+NArea,2*Nbar+NGer+NTap+NgerETotal+NArea)];
        NgerE = 0;
        for j=1:NArea
            FptGerEi = FptGerE(Area(FptGerE(:,1))==j,:);
            NgerEi = size(FptGerEi,1); 
            for i=1:NgerEi
                J(FptGerEi(i,1),2*Nbar+NGer+NTap+NgerE+i) = -1;
                J(2*Nbar+NGer+NTap+NgerE+i,2*Nbar+NGer+NTap+NgerE+i) = -1;
                J(2*Nbar+NGer+NTap+NgerE+i,2*Nbar+NGer+NTap+NgerETotal+j) = -1/FptGerEi(i,2);
            end
            NgerE = NgerE + NgerEi;
        end
        % Deriva da equação dTh_i_Esp - dTh_i
        for j = 1:NArea
            J(2*Nbar+NGer+NTap+NgerETotal+j,BarVTh(j)) = 1;
        end
        for i = 1:size(Area,1)
            J(i,2*Nbar+NGer+NTap+NgerETotal+Area(i)) = LoadDamping(i,1)*Pc(i);
            J(Nbar+i,2*Nbar+NGer+NTap+NgerETotal+Area(i)) = LoadDamping(i,2)*Qc(i);
        end
    else
        % Adiciona o Controle do Resíduo de perdas de potência ativa
        if (ControleRes == 1)
            NArea = length(unique(Area));
            NgerATotal = size(FptGerA,1);
            J = [J zeros(2*Nbar+NGer+NTap, NgerATotal); zeros(NgerATotal,2*Nbar+NGer+NTap+NgerATotal)];
            NgerA = 0;
            for j=1:NArea
                FptGerAi = FptGerA(Area(FptGerA(:,1))==j,:);
                NgerAi = size(FptGerAi,1); 
                for i=1:NgerAi
                    if (i == 1)
                        %J(2*Nbar+NGer+NTap+NgerA+i,:) = [H(BarVTh(j),:) N(BarVTh(j),:) zeros(1,NGer+NTap+NgerA) -1 zeros(1,NgerATotal-NgerA-1)];
                        J(FptGerAi(i,1),2*Nbar+NGer+NTap+NgerA+i) = -1;
                        J(2*Nbar+NGer+NTap+NgerA+i,BarVTh(j)) = 1;
                    else
                        J(FptGerAi(i,1),2*Nbar+NGer+NTap+NgerA+i) = -1;
                        J(2*Nbar+NGer+NTap+NgerA+i,2*Nbar+NGer+NTap+NgerA+i-1) = FptGerAi(i,2);
                        J(2*Nbar+NGer+NTap+NgerA+i,2*Nbar+NGer+NTap+NgerA+i) = -FptGerAi(i-1,2);
                    end
                end
                NgerA = NgerA + NgerAi;
            end
        end 
    end

    if ~isempty(DHVDC)
        LinhasHVDC = size(DHVDC,1);
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

            SizeJ = length(J);
            CA_CC = zeros(SizeJ,12);
            CC_CA = zeros(12, SizeJ);
            CC_CC = zeros(12);
            Scc_ca = DHVDC(i,23);
            DE_ret = DHVDC(i,1);
            PARA_inv = DHVDC(i,2);
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
            Ir_or_Pcc_Esp = DHVDC(i,18);
            VdrEsp = DHVDC(i,32);
            VdrefEsp = DHVDC(i,22);

            % inclui as variaveis 1 a 8 na Submatriz CA_CC

            CA_CC(DE_ret,1) = Ir*Scc_ca;
            CA_CC(DE_ret,5) = Vdr*Scc_ca; 
            CA_CC(Nbar + DE_ret, 1) = Ir*tan(FIr)*Scc_ca;
            CA_CC(Nbar + DE_ret, 5) = Vdr*tan(FIr)*Scc_ca; 
            CA_CC(Nbar + DE_ret, 3) = Vdr*Ir*sec(FIr)^2*Scc_ca;
                

            CA_CC(PARA_inv, 2) = Ii*Scc_ca; 
            CA_CC(PARA_inv, 6) = Vdi*Scc_ca; 
            CA_CC(Nbar + PARA_inv, 2) = -Ii*tan(FIi)*Scc_ca; 
            CA_CC(Nbar + PARA_inv, 6) = -Vdi*tan(FIi)*Scc_ca; 
            CA_CC(Nbar + PARA_inv, 4) = -Vdi*Ii*sec(FIi)^2*Scc_ca; 

            % inclui as variaveis 1 a 8 na Submatriz CC_CA
            CC_CA(1, Nbar + DE_ret) = -Kr*TAPr*cos(Alfa);
            CC_CA(2, Nbar + PARA_inv) = -Ki*TAPi*cos(Gamma);
            CC_CA(3, Nbar + DE_ret) = PontesR*2*Rr*Ir/(Kr*TAPr*V(DE_ret)^2);
            CC_CA(4, Nbar + PARA_inv) = PontesI*2*Ri*Ii/(Ki*TAPi*V(PARA_inv)^2);

            % inclui as variaveis 1 a 8 na Submatriz CC_CC
            CC_CC(1,1) = 1;
            CC_CC(1,5) = Rr*PontesR;
            CC_CC(1,9) = Kr*TAPr*V(DE_ret)*sin(Alfa);
            CC_CC(1,11) = -Kr*V(DE_ret)*cos(Alfa);
            CC_CC(2,2) = 1;
            CC_CC(2,6) = Ri*PontesI;
            CC_CC(2,10) = Ki*TAPi*V(PARA_inv)*sin(Gamma);
            CC_CC(2,12) = -Ki*V(PARA_inv)*cos(Gamma);
            CC_CC(3,5) = -2*PontesR*Rr/(Kr*TAPr*V(DE_ret));
            CC_CC(3,7) = sin(Alfa+MIr);
            CC_CC(3,9) = -sin(Alfa)+sin(Alfa+MIr);
            CC_CC(3,11) = 2*PontesR*Rr*Ir/(Kr*TAPr^2*V(DE_ret));
            CC_CC(4,6) = -2*PontesI*Ri/(Ki*TAPi*V(PARA_inv));
            CC_CC(4,8) = sin(Gamma+MIi);
            CC_CC(4,10) = -sin(Gamma)+sin(Gamma+MIi);
            CC_CC(4,12) = 2*PontesI*Ri*Ii/(Ki*TAPi^2*V(PARA_inv));
            CC_CC(5,3) = -1/cos(FIr)^2;
            % Derivado no Wolfram:
            CC_CC(5,7) = -(2*(-sin(2*(MIr+Alfa)) +2*MIr +sin(2*Alfa))*sin(2*(MIr+Alfa)) -2*(cos(2*(MIr+Alfa)) - 1)*(cos(2*(MIr+Alfa)) -cos(2*Alfa)))/(cos(2*Alfa) -cos(2*(MIr+Alfa)))^2;
            CC_CC(5,9) = -((2*cos(2*(MIr + Alfa)) - 2*cos(2*Alfa))/(cos(2*Alfa) - cos(2*(MIr + Alfa))) - ((sin(2*(MIr + Alfa)) - 2*MIr - sin(2*Alfa))*(2*sin(2*(MIr + Alfa)) - 2*sin(2*Alfa)))/(cos(2*Alfa) - cos(2*(MIr + Alfa)))^2);
            CC_CC(6,8) = -(2*(-sin(2*(MIi+Gamma)) +2*MIi +sin(2*Gamma))*sin(2*(MIi+Gamma)) -2*(cos(2*(MIi+Gamma)) - 1)*(cos(2*(MIi+Gamma)) -cos(2*Gamma)))/(cos(2*Gamma) -cos(2*(MIi+Gamma)))^2;
            CC_CC(6,10) = -((2*cos(2*(MIi + Gamma)) - 2*cos(2*Gamma))/(cos(2*Gamma) - cos(2*(MIi + Gamma))) - ((sin(2*(MIi + Gamma)) - 2*MIi - sin(2*Gamma))*(2*sin(2*(MIi + Gamma)) - 2*sin(2*Gamma)))/(cos(2*Gamma) - cos(2*(MIi + Gamma)))^2);
            %
            CC_CC(6,4) = -1/cos(FIi)^2;
            CC_CC(7,1) = 1;
            CC_CC(7,2) = -1;
            CC_CC(7,5) =  -Rcc;
            CC_CC(8,1) = -1;
            CC_CC(8,2) = 1;
            CC_CC(8,6) = -Rcc;
                
            % Matriz referente as variáveis alfa(angulo de disp. do ret.), gama(angulo de disp. do inv.), ar e ai
            %% DERIVADAS PARA O CONTROLE NO RETIFICADOR
            Ir_Esp = Ir_or_Pcc_Esp/VdrEsp;
            DVdr = (Vdr - VdrEsp);
            Mv = FptHVDCE(i,2);
            Mf = FptHVDCE(i,1);
            % CONTROLES NORMAL, HIGH MVAR CONSUMPTION, CONVENCIONAL(Tap), STAB50(Tap) E SFT(Tap)
            if (sum(TipoDeControle == [0 1 5 6 7])) 
                CC_CC(9,9) = CC_CC(9,9)+(ModoHVDCRet == 0)*1; % Modo 0
                CC_CC(10,5) = CC_CC(10,5)+(PConst == 0)*(sum(ModoHVDCRet == [0 1]))*1;   % Modos 0 e 1 com Corrente constante
                CC_CC(10,1) = CC_CC(10,1)+(PConst == 1)*(sum(ModoHVDCRet == [0 1]))*Ir;  % Modos 0 e 1 com Potência constante
                CC_CC(10,5) = CC_CC(10,5)+(PConst == 1)*(sum(ModoHVDCRet == [0 1]))*Vdr; % Modos 0 e 1 com Potência constante
                CC_CC(11,10) = CC_CC(11,10)+(sum(TipoDeControle == [0 6 7]))*(sum(ModoHVDCRet == [0 1 2]))*1; % Modos 0, 1 e 2 com controle Normal, Convencional(Tap), Stab50(Tap)
                CC_CC(9,11) = CC_CC(9,11)+(sum(ModoHVDCRet == [1 2 3]))*1; % Modos 1,2 e 3
                CC_CC(10,9) = CC_CC(10,9)+(sum(ModoHVDCRet == [2 3]))*1; % Modos 2 e 3
                CC_CC(11,5) = CC_CC(11,5)+(ModoHVDCRet == 3)*1; % Modo 3
            % CONTROLES CONVENCIONAL, STAB50 E SFT(Tiristor)
            elseif sum(TipoDeControle == [2 3 4])
                CC_CC(9,11) = CC_CC(9,11)+(ModoHVDCRet == 0)*1; % Modo 0
                CC_CC(9,9) = CC_CC(9,9)+sum(ModoHVDCRet == [1 2 3])*1; % Modos 1 2 e 3
                CC_CC(10,11) = CC_CC(10,11)+sum(ModoHVDCRet == [2 3])*1; % Modos 2 e 3
                CC_CC(11,10) = CC_CC(11,10)+sum(ModoHVDCRet == [0 1 2])*sum(TipoDeControle == [3 4])*1; % Modos 0, 1 e 2 do Controle Stab50 e convencional
                CC_CC(11,5) = CC_CC(11,5)+(ModoHVDCRet == 3)*sum(TipoDeControle == [3 4])*1; % Modo 3 do Controle Stab50 e convencional
                CC_CC(10,5) = CC_CC(10,5)+sum(ModoHVDCRet == [0 1])*(PConst == 0)*1; % Para todos os casos
                CC_CC(10,1) = CC_CC(10,1)+sum(ModoHVDCRet == [0 1])*(PConst == 1)*Ir; % Para todos os casos
                CC_CC(10,5) = CC_CC(10,5)+sum(ModoHVDCRet == [0 1])*(PConst == 1)*Vdr; % Para todos os casos
            end
            % DERIVADAS DOS CONTROLES DE FREQUÊNCIA (y_10)
            if sum(TipoDeControle == [2 3 4 5 6 7])
                if sum(ModoHVDCRet == [0 1]) % MODOS 0 e 1
                    indp = 2*Nbar+NGer+NTap+NgerETotal+GovernorControl*Area(PARA_inv);
                    indr =2*Nbar+NGer+NTap+NgerETotal+GovernorControl*Area(DE_ret);
                    if (PConst == 0) % Controle Por Corrente Constante
                        CC_CC(10,1) = CC_CC(10,1)+(sum(TipoDeControle == [2 5]))*GovernorControl*(-Mv); % Controle do Artigo
                        CC_CA(10,indp) = CC_CA(10,indp)+(sum(TipoDeControle == [3 6]))*GovernorControl*(Mf/VdrEsp); % Controle Convencional
                        CC_CA(10,indr) = CC_CA(10,indr)+(sum(TipoDeControle == [4 7]))*GovernorControl*(-FptHVDCE(i,1)/VdrEsp); % Stab50
                        CC_CA(10,indr) = CC_CA(10,indr)+(sum(TipoDeControle == [4 7]))*GovernorControl*(Freq(Area(DE_ret))< 0.996)*(-FptHVDCE(i,2)/VdrEsp); % Stab50 abaixo de 49,8Hz
                    else % Controle Por Potência Constante
                        CC_CC(10,1) = CC_CC(10,1)+(sum(TipoDeControle == [2 5]))*GovernorControl*(- Mv*VdrEsp - Ir_Esp -2*Mv*DVdr); % Controle do Artigo
                        CC_CA(10,indp) = CC_CA(10,indp)+(sum(TipoDeControle == [3 6]))*GovernorControl*(Mf); % Controle Convencional
                        CC_CA(10,indr) = CC_CA(10,indr)+(sum(TipoDeControle == [4 7]))*GovernorControl*(-FptHVDCE(i,1)); % Stab50
                        CC_CA(10,indr) = CC_CA(10,indr)+(sum(TipoDeControle == [4 7]))*GovernorControl*(Freq(Area(DE_ret))< 0.996)*(-FptHVDCE(i,2)); % Stab50 abaixo de 49,8Hz
                    end
                end
            end
        %% DERIVADAS PARA O CONTROLE NO INVERSOR    
            Mf = FptHVDCE(i,1);
            DArea =[
            1    50
            2    60];
            indp = 2*Nbar+NGer+NTap+NgerETotal+GovernorControl*Area(PARA_inv);
            % CONTROLES NORMAL, STAB50 e CONVENCIONAL
            if (sum(TipoDeControle == [0 3 4 6 7])) 
                CC_CC(12,1) = CC_CC(12,1)+(ModoHVDCInv == 0)*(DHVDC(i,31) == 0)*1; % Modo 0 com controle de Tensão no retificador
                CC_CC(12,2) = CC_CC(12,2)+(ModoHVDCInv == 0)*(DHVDC(i,31) == 1)*1; % Modo 0 com controle de Tensão no inversor
                CC_CC(12,12) = CC_CC(12,12)+(ModoHVDCInv == 1)*1; % Modo 1
            % CONTROLE HIGH MVAR CONSUMPTION E SFT POR TAP
            elseif (sum(TipoDeControle == [1 5]))
                CC_CC(11,10) = CC_CC(11,10)+(ModoHVDCInv == 0)*1; % Modo 0
                CC_CC(11,12) = CC_CC(11,12)+(sum(ModoHVDCInv == [1 2]))*1; % Modo 1
                CC_CC(12,1) = CC_CC(12,1)+sum(ModoHVDCInv == [0 1])*(DHVDC(i,31) == 0)*1; % Modos 0 e 1 com controle de Tensão no retificador
                CC_CC(12,2) = CC_CC(12,2)+sum(ModoHVDCInv == [0 1])*(DHVDC(i,31) == 1)*1; % Modos 0 e 1 com controle de Tensão no inversor
                CC_CC(12,10) = CC_CC(12,10)+(ModoHVDCInv == 2)*1; % Modo 2
                if (TipoDeControle == 5 && sum(ModoHVDCInv == [0 1])) % Modos 0 e 1 Para o SFT por TAP
                    Mv = FptHVDCE(i,2);
                    dfpu = Freq(Area(PARA_inv)) - 1;
                    Iref = DHVDC(i,28);
                    k = Mv/(1 - Mv*Rcc);
                    a = k*dfpu;
                    b = -k*VdrefEsp-Iref;
                    c = FptHVDCE(i,1);
                    Mf = (-b-sqrt(b^2-4*a*c))/(2*a);
                    if (abs(Mf)>FptHVDCE(i,3) || isnan(Mf) || imag(Mf) ~= 0)
                        Mf = FptHVDCE(i,3);                            
                    end
                    CC_CA(12,indp) = CC_CA(12,indp) + GovernorControl*Mf; 
                end
            % CONTROLE SFT POR TIRISTOR
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
                CC_CC(11,12) = CC_CC(11,12)+(ModoHVDCInv == 0)*1; % Modo 0
                CC_CC(11,10) = CC_CC(11,10)+(sum(ModoHVDCInv == [1 2]))*1; % Modo 1
                CC_CC(12,2) = CC_CC(12,2)+sum(ModoHVDCInv == [0 1])*1; % Modos 0 e 1
                CC_CC(12,12) = CC_CC(12,12)+(ModoHVDCInv == 2)*1; % Modo 2
                CC_CA(12,indp) = CC_CA(12,indp)+sum(ModoHVDCInv == [0 1])*GovernorControl*Mf; % Modos 0 e 1
            end

            % Adiciona as alterações a matriz J
            J = [J CA_CC; CC_CA CC_CC];
            
        end
    end
    
     % Retira a barra VTH da matriz - NÃO APLICA BIG NUMBER
     if (ControleRes == 0 && GovernorControl == 0)
         for i=1:length(BarVTh)
            J(BarVTh(i),:) = 0;
            J(:,BarVTh(i)) = 0;
            J(BarVTh(i),BarVTh(i)) = 1;
         end
     end
    
    % Adiciona elementos para aplicar o fluxo de potência continuado
    if FPC == 1
        [LinJ, ColJ] = size(J);
        dLambda = zeros(LinJ,1);
        dPdLambda = Pc;
        dQdLambda = +Qc;
        dLambda(1:Nbar) = dPdLambda;
        dLambda(Nbar+1:2*Nbar) = dQdLambda;
        e = zeros(1,ColJ+1);
        if TipoFPC == 0
            e(end)=1;
        else
            e(Nbar+TipoFPC)=1;
        end
        J = [J     dLambda    ; e];
    end
end








