function [NBar, NLin, IndBar, BarGer, BarEMF, BarVTh, BTipo, PgEsp, PgeEsp, QgEsp, QgMax, QgMin, Pc, Qc, Qs, Ps, VEsp, ThEsp, DE, PARA, ...
    r, x, BSh_Lin, TapEsp, TapMin, TapMax, TapPh, MvaMax, LTipo, NGer, BarCGer, TapC, BarCTap, LadoCTap, FptTap, FptGerR, FptGerA, FptGerE, FreqEsp, Area, DArea, LoadDamping, FptHVDCE, DHVDC, LinhasHVDC, XhvdcEsp, DadoInc, DincCarga, DincGerador] = Dados(arquivo, TipoGovernorHVDC)

    % Chama o arquivo com os dados
    if (arquivo(end-3:end) == '.mat')
        load(arquivo);
    else
        
        run(arquivo);

        DE = [];
        PARA = [];
        LTipo = [];
        BarCTap = [];
        IndTapC = [];
        r = [];
        x = [];
        MvaMax = [];
        BSh_Lin = [];
        TapEsp = [];
        TapMin = [];
        TapMax = [];
        TapPh = [];
        

        % Processa os dados
        NBar = length(DBAR(:,1));
        NLin = size(DLIN,1);
        BarVTh = find(DBAR(:,2)==2);
        BarGer = find(DBAR(:,2)>0);
        NGer = length(BarGer);
        BTipo = DBAR(:,2);
        IndBar = DBAR(:,1);
        if (NLin>0)
            DE = DLIN(:,1);
            PARA = DLIN(:,2);
            LTipo = DLIN(:,11);
            BarCTap = DLIN(:,12);
            IndTapC = find(DLIN(:,12)~=0);
        end
        VEsp = DBAR(:,11);
        ThEsp = DBAR(:,12)*2*pi/360;
        FreqEsp = ones(size(BarVTh,1),1);
        BarC = DBAR(:,13);
        Area = DBAR(:,14);
        if (length(BarVTh) == 1)
            Area = ones(length(Area),1);
        end
        for i = 1:length(BarC)
             BarC(i)= find(BarC(i)==IndBar);
        end
        BarCGer = BarC(BarGer);
        BarCTap = BarCTap(BarCTap~=0);
        NTapC = length(BarCTap);
        TapC = zeros(NTapC,3);
        for i = 1:NTapC
            BarCTap(i)= find(BarCTap(i)==IndBar);
            TapC(i,:) = [find(DE(IndTapC(i))==IndBar) find(PARA(IndTapC(i))==IndBar) IndTapC(i)];
        end
        LadoCTap = ones(NTapC,1);         
        for i =1:NTapC
            if BarCTap(i) == TapC(i,2)
                LadoCTap(i) = 2;
            end
        end
        % Coloca Tudo em PU
        PgEsp = DBAR(:,3)/100;
        PgeEsp = zeros(NBar,1);
        QgEsp = DBAR(:,4)/100;
        QgMax = DBAR(:,5)/100;
        QgMin = DBAR(:,6)/100;
        Pc = DBAR(:,7)/100;
        Qc = DBAR(:,8)/100;
        Qs = DBAR(:,9)/100;
        Ps = DBAR(:,10)/100;
        if (NLin>0)
            r = DLIN(:,3)/100;
            x = DLIN(:,4)/100;
            MvaMax = DLIN(:,10)/100;
            BSh_Lin = DLIN(:,5)/100;

            % Divide por 2 devido ao modelo PI da linha
            BSh_Lin = BSh_Lin/2;

            % Coloca o Tap na forma como é usado no ANAREDE
            TapEsp = 1./DLIN(:,6);%1./DLIN(:,6);
            TapMin = DLIN(:,8);
            TapMin(TapMin~=0)=1./TapMin(TapMin~=0);
            TapMax = DLIN(:,7);
            TapMax(TapMax~=0)=1./TapMax(TapMax~=0);
            TapPh = -DLIN(:,9);

        end 
            
        if (exist('DELO','var') == 1 && exist('DCNV','var') == 1 && exist('DCCV','var') == 1)
            LinhasHVDC = size(DELO,1);
            XhvdcEsp = zeros(12*LinhasHVDC,1);
            DHVDC = zeros(LinhasHVDC,30);
            for i=1:LinhasHVDC
                DHVDC(i,1) = find(DELO(i,1) == IndBar ); % Barra De (Retificadora)
                DHVDC(i,2) = find(DELO(i,2) == IndBar ); % Barra Para (Inversora)      
                IndEloi = find(DCNV(:,3) == i);     % Descubro em qual linha está os conversores do Elo i
                IndR = IndEloi(DCNV(IndEloi,4) == 0);        % Pego apenas a linha do retificador do Elo    
                IndI = IndEloi(DCNV(IndEloi,4) == 1);        % Pego apenas a linha do inversor do Elo    
                DHVDC(i,3) = (3*sqrt(2)/pi)*DCNV(IndR,5)*DCNV(IndR,8)/DELO(i,5); % Kr
                DHVDC(i,4) = (3*sqrt(2)/pi)*DCNV(IndI,5)*DCNV(IndI,8)/DELO(i,5); % Ki
                ZbElo = DELO(i,5)^2/DELO(i,6);
                ZbTrafoR = DCNV(IndR,8)^2/DCNV(IndR,9);
                DHVDC(i,5) = DCNV(IndR,7)/100*ZbTrafoR/ZbElo;      % Reatancia Xr
                ZbTrafoI = DCNV(IndI,8)^2/DCNV(IndI,9);
                DHVDC(i,6) = DCNV(IndI,7)/100*ZbTrafoI/ZbElo;      % Reatancia Xi
                DHVDC(i,7) = DELO(i,3)/ZbElo;       % Rcc em pu na base do Elo
                Tol = 10e-5; % Necessário para caso sejam dados valores iguais de Min e Max
                DHVDC(i,8) = 1./DCCV(IndR,10) - Tol;      % Tap Ret Mn
                DHVDC(i,9) = 1./DCCV(IndR,9) + Tol;       % Tap Ret Mx
                DHVDC(i,10) = 1./DCCV(IndI,10) - Tol;     % Tap Inv Mn
                DHVDC(i,11) = 1./DCCV(IndI,9)  + Tol;     % Tap Inv Mx
                DHVDC(i,12) = DCCV(IndR,6)*2*pi/360;% Ang de Disparo do Ret Esp
                DHVDC(i,13) = DCCV(IndR,7)*2*pi/360 - Tol;% Ang de Disparo do Ret Mn
                DHVDC(i,14) = DCCV(IndR,8)*2*pi/360 + Tol;% Ang de Disparo do Ret Mx
                DHVDC(i,15) = DCCV(IndI,6)*2*pi/360;% Ang de Disparo do Inv Esp
                DHVDC(i,16) = DCCV(IndI,7)*2*pi/360 - Tol;% Ang de Disparo do Inv Mn
                DHVDC(i,17) = DCCV(IndI,8)*2*pi/360 + Tol;% Ang de Disparo do Inv Mx
                IbElo = DELO(i,6)/DELO(i,5)*1000;   % Corrente base do elo.
                DHVDC(i,21) = DELO(i,7);            % Modo do Elo. SE 0 = normal, se 1 = High Mvar Consumption, se 2 = Controle do artigo
                DHVDC(i,22) = DELO(i,8)/DELO(i,5);  % Tensão Vd especificada            
                DHVDC(i,23) = DELO(i,6)/100;        % Scc_ca = Scc_base/Sca_base
                DHVDC(i,24) = DCCV(IndR,11);        % Tensão do modo VdcMin
                DHVDC(i,25) = 1./DCCV(IndR,12);     % Tap do conversor para o modo HighMvar
                DHVDC(i,26) = 1./DCCV(IndR,13);     % Tap do conversor para o modo VdcMin
                DHVDC(i,27) = DCCV(IndR,2);         % Modo de Operação: Controle de corrente ou de potência
                DHVDC(i,29) = DCNV(IndR,5);         % Nºo de pontes do ret
                DHVDC(i,30) = DCNV(IndR,5);         % Nºo de pontes do inv
                DHVDC(i,31) = DELO(i,9);            % Escolhe qual será a tensão CC de Ref a ser controlada
                DHVDC(i,32) = 0;
                if (size(DCCV,2)>13)
                    DHVDC(i,33) = 1/DCCV(IndR,14);      % Tap Ret Esp
                    DHVDC(i,34) = 1/DCCV(IndI,14);      % Tap Inv Esp
                else
                    DHVDC(i,33) = 1;
                    DHVDC(i,34) = 1;
                end


                if exist('TipoGovernorHVDC','var') == 1
                    if (TipoGovernorHVDC == 1)
                        DHVDC(i,31) = 1; % Se Tiver Dados Para controle de Freq. através de linha HVDC, então faz controle de tensão do inversor
                    end
                end
                
                % Calculo da Margem de Corrente e Corrente Esperada no Elo
                if (DHVDC(i,27)==0) % Se For Corrente Constante
                    DHVDC(i,18) = DCCV(IndR,3)/IbElo;   
                    DHVDC(i,19) = DCCV(IndR,3)*(1-DCCV(IndR,4)/100)/IbElo;     % Margem de Corrent no Elo em % (Ir min = IrEsp*(1-Margem)
                    DHVDC(i,20) = DCCV(IndR,3)*DCCV(IndR,5)/100/IbElo;         % Maxima corrente no Elo em % da nominal
                    DHVDC(i,28) = DHVDC(i,18);                                 % Chute Inicial de Corrente
                else % Se For Potencia Constante       
                    DHVDC(i,18) = DCCV(IndR,3)/DELO(i,6);   
                    DHVDC(i,19) = DCNV(i,6)*(1-DCCV(IndR,4)/100)/IbElo;     % Margem de Corrent no Elo em % (Ir min = IrEsp*(1-Margem)
                    DHVDC(i,20) = DCNV(i,6)*DCCV(IndR,5)/100/IbElo;         % Maxima corrente no Elo em % da nominal
                    if (DHVDC(i,31) == 0) % Se a tensao especificada for Vdr      
                        DHVDC(i,28) = DHVDC(i,18)/DHVDC(i,22);                  % Chute Inicial de Corrente
                    else % Se a tensao especificada for Vdi -> aplico bhaskara para encontrar a corrente.
                        DHVDC(i,28) = (-DHVDC(i,22) + sqrt(DHVDC(i,22)^2+4*DHVDC(i,7)*DHVDC(i,18)))/(2*DHVDC(i,7));
                    end
                end
                %Chute inicial das variáveis do HVDC

                PontesR = DHVDC(i,29);
                PontesI = DHVDC(i,30);
                Rr = 3/pi*DHVDC(i,5);
                Ri = -3/pi*DHVDC(i,6);
                Kr = DHVDC(i,3);
                Ki = DHVDC(i,4);
                Vr = VEsp(DHVDC(i,1));
                Vi = VEsp(DHVDC(i,2));
                Ir = DHVDC(i,28);
                Ii = -DHVDC(i,28);

                if (DHVDC(i,31) == 0)
                    Vdr = DHVDC(i,22);
                    Vdi = DHVDC(i,22)-DHVDC(i,7)*Ir;
                    DHVDC(i,32) = Vdr;
                else
                    Vdi = DHVDC(i,22);
                    Vdr = DHVDC(i,22)+DHVDC(i,7)*Ir;
                    DHVDC(i,32) = Vdr;
                end
                Alfa = DHVDC(i,12);
                Gamma = DHVDC(i,15);
                % Calculo os chutes iniciais para essa variáveis com base nas equações
                TAPr = (Vdr  + Rr*Ir*PontesR)/(Kr*Vr*cos(Alfa));
                TAPi = (Vdi  + Ri*Ii*PontesI)/(Ki*Vi*cos(Gamma));
                MIr = acos(cos(Alfa) -PontesR*2*Rr*Ir/(Kr*TAPr*Vr)) - Alfa;
                MIi = acos(cos(Gamma) -PontesI*2*Ri*Ii/(Ki*TAPi*Vi)) - Gamma;
                FIr = atan((2*MIr +sin(2*Alfa) - sin(2*(Alfa+MIr)))/(cos(2*Alfa)-cos(2*(Alfa+MIr))));
                FIi = atan((2*MIi +sin(2*Gamma) - sin(2*(Gamma+MIi)))/(cos(2*Gamma)-cos(2*(Gamma+MIi))));

                XhvdcEsp(12*(i-1) + 1) = Vdr;
                XhvdcEsp(12*(i-1) + 2) = Vdi; 
                XhvdcEsp(12*(i-1) + 3) = FIr;
                XhvdcEsp(12*(i-1) + 4) = FIi;
                XhvdcEsp(12*(i-1) + 5) = Ir; 
                XhvdcEsp(12*(i-1) + 6) = Ii;
                XhvdcEsp(12*(i-1) + 7) = MIr;
                XhvdcEsp(12*(i-1) + 8) = MIi;
                XhvdcEsp(12*(i-1) + 9) = Alfa;
                XhvdcEsp(12*(i-1) + 10) = Gamma;
                XhvdcEsp(12*(i-1) + 11) = TAPr;
                XhvdcEsp(12*(i-1) + 12) = TAPi;              
            end
            if exist('FptHVDCE','var') == 1
                AuxFptHVDCE = zeros(LinhasHVDC,3);
                [Lin,Col] = size(FptHVDCE);
                if (Col ~= 4)
                    FptHVDCE = [FptHVDCE zeros(Lin,4-Col)];
                end
                for j =1:Lin
                    Ind = FptHVDCE(j,1);
                    AuxFptHVDCE(Ind,:) = FptHVDCE(j,2:4);
                end
                FptHVDCE = AuxFptHVDCE;

            else
                FptHVDCE = zeros(LinhasHVDC,3);
            end
        else 
              XhvdcEsp = [];
              FptHVDCE = [];
              LinhasHVDC = 0;
              DHVDC = [];
        end


        if exist('FptGerE','var') == 1
            for i=1:size(FptGerE,1)
                FptGerE(i,1) = find(IndBar == FptGerE(i,1));
            end
            if size(FptGerE,2)==2
                FptGerE = [FptGerE DBAR(FptGerE(:,1),3)];
            end
            FptGerAux = zeros(length(BarVTh),3);
            % Rotina para colocar os FPTGerE relativos as barras de referência nas primeiras linhas
            for i=1:length(BarVTh)
                FptGerAux(i,:) = FptGerE(FptGerE(:,1)==BarVTh(i),:);
                FptGerE(FptGerE(:,1)==BarVTh(i),:) = [];
            end
            FptGerE = [FptGerAux;FptGerE];
            FptGerE(:,2) = (FptGerE(:,2)/100)./(FptGerE(:,3)/100); % Estatismo = (E(%)/100)/(PGMaxger/Pb)
        else
            FptGerE = [BarVTh 5*ones(length(BarVTh)) DBAR(BarVTh,3)];
            FptGerE(:,2) = (FptGerE(:,2)/100)./(FptGerE(:,3)/100);
        end
       
        if exist('DArea','var') == 0
            Narea = length(unique(Area));
            DArea = [sort(unique(Area)) 60*ones(Narea,1)];
        end
        
        if exist('FptGerA','var') == 1
            for i=1:size(FptGerA,1)
                FptGerA(i,1) = find(IndBar == FptGerA(i,1));
            end
            FptGerAux = zeros(length(BarVTh),2);
            for i=1:length(BarVTh)
                FptGerAux(i,:) = FptGerA(FptGerA(:,1)==BarVTh(i),:);
                FptGerA(FptGerA(:,1)==BarVTh(i),:) = [];
            end
            FptGerA = [FptGerAux;FptGerA];
        else
            FptGerA = BarVTh;
        end
        
        if exist('LoadDamping','var') == 1
            AuxLoadDamping = zeros(NBar,2);
            for i =1:size(LoadDamping,1)
%               Ind = find(IndBar == LoadDamping(i,1));
                Ind = (IndBar == LoadDamping(i,1));
                AuxLoadDamping(Ind,:) = LoadDamping(i,2:3);
            end
            LoadDamping = AuxLoadDamping;
            if (isempty(LoadDamping))
                LoadDamping = zeros(NBar,2);
            end
        else
            LoadDamping = zeros(NBar,2);
        end

        
        FptGerRAux = ones(NGer,1);
        if exist('FptGerR','var') == 1
            for i=1:size(FptGerR,1)
                FptGerRAux(find(IndBar==FptGerR(i,1)) == BarGer) = FptGerR(i,2);
            end
        end
        FptGerR = FptGerRAux;

        if (NLin>0)
            FptTapAux = ones(NLin,1);
            if exist('FptTap','var') == 1
                for i=1:size(FptTap,1)
                    FptTapAux(FptTap(i,1)) = FptTap(i,2);
                end
            end

            FptTap = FptTapAux(DLIN(:,12)~=0);
        else
            FptTap = [];
        end

        % Verifica a existência do dado de incremento e cria valores default
        if exist('DadoInc','var') == 0
            %Valores Default
            PASSO_INI = 0.01;
            CALC_MAX = 300;
            PASSO_MIN = 0.005;
            PASSO_TEN = 0.01;
            AUM_PASSO = 0.8;
            INC_PARA = 0.7;
            DadoInc = [PASSO_INI; CALC_MAX; PASSO_MIN; PASSO_TEN; AUM_PASSO; INC_PARA]; 
        end
        if exist('DincCarga','var') == 1    
            Aux = DincCarga;
            DincCarga = ones(length(Pc),2);
            DincCarga(Aux(:,1),:) = Aux(:,2:3);
        else
            DincCarga = ones(length(Pc),2);
        end

        if exist('DincGerador','var') == 1
            Aux = DincGerador;
            DincGerador = ones(length(Pc),1);    
            DincGerador(Aux(:,1)) = Aux(:,2);
        else
            DincGerador = ones(length(Pc),1);
        end
        
        if exist('BarEMF','var') == 1
           PARAemf = BarEMF(:,1);
           [~, indBarEMF] = sort(PARAemf,'ascend');           
           % Crio a barra DE interna no gerador
           PARAemf = PARAemf(indBarEMF);
           [~, iunique, ~] = unique(PARAemf);
           DEemf = zeros(size(PARAemf,1),1);
           IndBarAux = NBar;
           for i = 1:size(PARAemf,1)
               if (iunique == i)
                   IndBarAux = IndBarAux + 1;
               end
               DEemf(i) = IndBarAux;
           end
           BarEMF = [DEemf BarEMF(indBarEMF,:)];
           
        else
           BarEMF = BarGer; 
        end
    end
end







