% Sistema = Arquivo de Dados do Sistema
% Imprime = true or false // Para imprimir os resultados
% O que tem implementado:
% - Controle de tensão em barras remotas(Para barras do tipo PV)
% - Controle de tensão por área (varios geradores controlando uma barra)
% - Controle de tensão através de tap
% - Controle de tensão para multiplos trafos controlando a mesma barra
% - Controle Automático de geração(CAG) com a utilização de fator de participação (1 barra de ref para cada área)
% - Controle primário de frequência, GOVERNO POWER FLOW.
% - Consideração de Limite dos Geradores com Back off
% - Consideração de Limite de Tap com Back off
% - Implementação de linhas HVDC com Operação Normal, High mvar Consumption, Stab50, Controle de freq convencional e controle com Supressão de flutuação de tensões
%   - Com Controle por potencia ou corrente constante
% OBS: - Não está fazendo controle de 2 Geradores na mesma barra
%      - Faz controle de 2 trafos na mesma barra
% Fluxo_de_Potencia_Convencional(Sitema Utilizado, Incremento de carga no caso base, Imprime resultados{1=true, 0=false},{com controle = 1, Convencional=0})
function [Flag, V, Th, Freq, Xhvdc, ModoHVDC, Pg, Pge, Qg, Pkm, Pmk, Qkm, Qmk, DE, PARA, Pcal, Qcal, Tap, ModoGer, ModoTap, ConvGraph] = Fluxo_de_Potencia_Convencional(Sistema, Incremento, Imprime, FlatStart, Passo, ControleTen, ControleRes, GovernorControl) 
% Variável utilizada para Fluxo de Potência Continuado. 0 = FP convencional e 1 = FP continuado
ConvGraph = [];
FPC = 0;

if ~exist('GovernorControl','var')
    GovernorControl = 0;
end

% Parâmetro de Tolerância
TolPQ = 10^-6;
TolVGer = 10^-6;
TolQGerLim = 10^-6;
TolVTap = 10^-6;
TolTapLim = 10^-6;
TolPotRes = 10^-6;
TolFreq = 10^-6;
TolHVDC = 10^-6;

Pkm = [];
Pmk = [];
Qkm = [];
Qmk = [];

% Processamento de dados
[NBar, NLin, IndBar, BarGer, ~, BarVTh, BTipo, PgEsp, PgeEsp, QgEsp, QgMax, QgMin, Pc, Qc, Qs, Ps, VEsp, ThEsp, DE, PARA, ...
    r, x, BSh_Lin, TapEsp, TapMin, TapMax, TapPh, ~, LTipo, NGer, BarCGer, TapC, BarCTap, LadoCTap, FptTap, FptGerR, FptGerA, FptGerE, FreqEsp, Area, DArea, LoadDamping, FptHVDCE, DHVDC, LinhasHVDC, XhvdcEsp]=Dados(Sistema, GovernorControl);

% Desativa o Controle de tensão em barras remotas por geradores
if (ControleTen == 0) 
    BarCGer = BarGer;
end

% Inicializa as variáveis
NgerA = size(FptGerA,1)*ControleRes*(~GovernorControl);
NTap = length(BarCTap)*ControleTen;
NArea = length(unique(Area));
NgerE = (size(FptGerE,1) + NArea)*GovernorControl;  
Pg = PgEsp;
Xhvdc = XhvdcEsp;
Freq = FreqEsp;
if (FlatStart == 1)
    V = ones(NBar,1);
    Tap = ones(NLin,1);
    Th = zeros(NBar,1);
    Pge = zeros(NBar,1);
else
    Tap = TapEsp;
    V = VEsp;
    Th = ThEsp;
    Pge = PgeEsp;
end


% Aplica Os Limites e Back Off
[ModoGer, GerLim, ModoTap, TapLim, ModoHVDC, HVDCLim] = Limites(QgEsp, V, Xhvdc, DHVDC, VEsp, BarGer, BarCGer, QgMin, QgMax, TapC, BarCTap, Tap, LadoCTap, TapMin, TapMax, ControleTen, Area, Freq, FptHVDCE, GovernorControl);


% Cria a matriz admitância
Y = Cria_Matriz_Admitancia(NBar, NLin, IndBar, DE, PARA, BSh_Lin, Qs, Ps, r, x, Tap, TapPh, LTipo);

% Calcula As Correntes nas Barras
Vc = V.*cos(Th)+1i*V.*sin(Th);
I = Y*Vc;
S = Vc.*conj(I);
Qcal = imag(S);
Pcal = real(S);

% Atualiza Qg
Qg = QgEsp;
if (FlatStart == 1)
    Qg(BarGer)=(Qcal(BarGer)+Qc(BarGer));
    for i=1:LinhasHVDC
        if(sum(DHVDC(i,1) == BarGer))
            Qg(DHVDC(i,1)) = Qg(DHVDC(i,1)) + Xhvdc(12*(i-1) + 1)*Xhvdc(12*(i-1) + 5)*tan(Xhvdc(12*(i-1) + 3))* DHVDC(i,23);
        end
        if(sum(DHVDC(i,2) == BarGer))
            Qg(DHVDC(i,2)) = Qg(DHVDC(i,2)) - Xhvdc(12*(i-1) + 2)*Xhvdc(12*(i-1) + 6)*tan(Xhvdc(12*(i-1) + 4))* DHVDC(i,23);
        end
    end
end

% Incremento de Carga

Pc = Pc*(100+Incremento)/100;
Qc = Qc*(100+Incremento)/100;
Pg = Pg*(100+Incremento)/100;

% Calcula os Resíduos deltaIr e deltaIm
deltay = Calcula_Residuo(V, Th, Freq, Xhvdc, DHVDC, ModoHVDC, HVDCLim, Pg, Pge, Qg, Pc, Qc, BarVTh, BarGer, BarCGer, VEsp, ModoGer, GerLim, TapC, BarCTap, Tap, ModoTap, TapLim, Pcal, Qcal, ControleTen, ControleRes, GovernorControl, ThEsp, FptTap, FptGerR, FptGerA, FptGerE, Area, LoadDamping, FptHVDCE, DArea, FPC);

ite = 0;

CTolPQ = sum(abs(deltay(1:2*NBar))>TolPQ);
CTolVGer = sum(abs(deltay(2*NBar+find(ModoGer==0)))>TolVGer);
CTolQLim = sum(abs(deltay(2*NBar+find(ModoGer==1)))>TolQGerLim);
CTolVTap = sum(abs(deltay(2*NBar+NGer+ControleTen*find(ModoTap==0)))>TolVTap) ;
CTolTapLim = sum(abs(deltay(2*NBar+NGer+ControleTen*find(ModoTap==1)))>TolTapLim);
CTolPotRes = sum(abs(deltay(2*NBar+NGer+ControleTen*NTap+(1:NgerA)))>TolPotRes);
CTolFreq = sum(abs(deltay(2*NBar+NGer+ControleTen*NTap+(1:NgerE)))>TolFreq);
CTolHVDC = sum(abs(deltay(2*NBar+NGer+ControleTen*NTap+NgerE+NgerA+(1:12*LinhasHVDC)))>TolHVDC);
Tol = CTolPQ + CTolVGer + CTolQLim + CTolVTap + CTolTapLim + CTolPotRes + CTolFreq + CTolHVDC;

while (Tol~=0)
    % Cria (-) a matriz Jacobiana
    J = Cria_J(NBar, Y, V, Th, Freq, Tap, Xhvdc, DHVDC, ModoHVDC, r, x, BarVTh, BarGer, BarCGer, ModoGer, TapC, ModoTap, BarCTap, Pcal, Qcal, ControleTen, ControleRes, GovernorControl, FptTap, FptGerR, FptGerA, FptGerE, Area, LoadDamping, FptHVDCE, Pc, Qc, FPC);

    % Resolve o Sistema
    deltaX = J\deltay;
    
    % Limito a Variação a no máximo X%passo
    if (Passo(1) > 0) 
        deltaX = Passo(1)*deltaX;
    end
    % Limito a Variação a no máximo Xpasso pu (variando com o número de iterações)
    if(Passo(2) > 0)
        UB = ones(length(deltaX),1)*Passo(2)/(floor(ite/5)+1);
        LB = -UB;
        IndUB = deltaX > UB;
        IndLB = deltaX < LB;
        deltaX = deltaX.*(~(IndUB+IndLB))+UB.*IndUB+LB.*IndLB;
    end
    
    % Separa as variáveis
    deltaTh =  deltaX(1:NBar);
    deltaV = deltaX(NBar+1:2*NBar);
    deltaQg = deltaX(2*NBar+1:2*NBar+NGer);
    if(ControleTen==1)
        deltaTap = deltaX(2*NBar+NGer+1:2*NBar+NGer+NTap);
    end
    
    if (GovernorControl==1) 
        deltaPge = zeros(NgerE,1);
        NgerEsum = 0;
        for j=1:NArea
            FptGerEi = FptGerE(Area(FptGerE(:,1))==j,:);
            NgerEi = size(FptGerEi,1); 
            deltaPge(NgerEsum+1:NgerEsum+NgerEi) = deltaX(2*NBar+NGer+NTap+NgerEsum+1:2*NBar+NGer+NTap+NgerEsum+NgerEi);
            NgerEsum = NgerEsum + NgerEi;
        end
        deltaFreq = deltaX(2*NBar+NGer+NTap+NgerEsum+1:2*NBar+NGer+NTap+NgerEsum+NArea);        
    else
        if(ControleRes==1)
            deltaPge = zeros(NgerA,1);
            NgerAsum = 0;
            for j=1:NArea
                FptGerAi = FptGerA(Area(FptGerA(:,1))==j,:);
                NgerAi = size(FptGerAi,1); 
                deltaPge(NgerAsum+1:NgerAsum+NgerAi) = deltaX(2*NBar+NGer+NTap+NgerAsum+1:2*NBar+NGer+NTap+NgerAsum+NgerAi);
                NgerAsum = NgerAsum + NgerAi;
            end
        end
    end
    
    if(LinhasHVDC>0)
        deltaXhvdc = deltaX(2*NBar+NGer+NTap+NgerA+NgerE+1:2*NBar+NGer+NTap+NgerA+NgerE+12*LinhasHVDC);
    end

    % Atualiza V e Th
    V = V + deltaV;
    Th = Th + deltaTh;
    Qg(BarGer) = Qg(BarGer) + deltaQg;
    if(ControleTen==1)
        Tap(TapC(:,3)) = Tap(TapC(:,3)) + deltaTap;
    end  
    
    if (GovernorControl==1)
        NArea = length(unique(Area));
        NgerEsum = 0;
        for j=1:NArea
            FptGerEi = FptGerE(Area(FptGerE(:,1))==j,:);
            NgerEi = size(FptGerEi,1); 
            Pge(FptGerEi(:,1)) = Pge(FptGerEi(:,1)) + deltaPge(NgerEsum+1:NgerEsum+NgerEi);
            NgerEsum = NgerEsum + NgerEi;
        end
        Freq = Freq + deltaFreq;
    else
        if(ControleRes==1)
            NArea = length(unique(Area));
            NgerAsum = 0;
            for j=1:NArea
                FptGerAi = FptGerA(Area(FptGerA(:,1))==j,:);
                NgerAi = size(FptGerAi,1); 
                Pge(FptGerAi(:,1)) = Pge(FptGerAi(:,1)) + deltaPge(NgerAsum+1:NgerAsum+NgerAi);
                NgerAsum = NgerAsum + NgerAi;
            end
        end
    end
    if (LinhasHVDC>0)
        Xhvdc = Xhvdc + deltaXhvdc;
    end
    
    % Aplica Os Limites e Back Off
    [ModoGer, GerLim, ModoTap, TapLim, ModoHVDC, HVDCLim] = Limites(Qg, V, Xhvdc, DHVDC, VEsp, BarGer, BarCGer, QgMin, QgMax, TapC, BarCTap, Tap, LadoCTap, TapMin, TapMax, ControleTen, Area, Freq, FptHVDCE, GovernorControl);
    
    % Atualiza a matriz admitância
    Y = Cria_Matriz_Admitancia(NBar, NLin, IndBar, DE, PARA, BSh_Lin, Qs, Ps, r, x, Tap, TapPh, LTipo);

    % Atualiza os Resíduos
    Vc = V.*cos(Th)+1i*V.*sin(Th);
    I = Y*Vc;
    S = Vc.*conj(I);
    Qcal = imag(S);
    Pcal = real(S); 

    deltay = Calcula_Residuo(V, Th, Freq, Xhvdc, DHVDC, ModoHVDC, HVDCLim, Pg, Pge, Qg, Pc, Qc, BarVTh, BarGer, BarCGer, VEsp, ModoGer, GerLim, TapC, BarCTap, Tap, ModoTap, TapLim, Pcal, Qcal, ControleTen, ControleRes, GovernorControl, ThEsp, FptTap, FptGerR, FptGerA, FptGerE, Area, LoadDamping, FptHVDCE, DArea, FPC);    
    
    ite=ite+1;
    if(ite>100 || sum(isnan(deltay))>0)
        if (Imprime == true)
            fprintf('Divergiu \n');
            Pkm=0;
            Pmk=0;
            Qkm=0;
            Qmk=0;
        end
        Flag = 0;
        return;
    end 
   

        
    R1 = max(abs(deltay(1:NBar))); % Resíduo de Potência Ativa
    R2 = max(abs(deltay(NBar+1:2*NBar))); % Resíduo de Potência Reativa
    R3 = max(abs(deltay(2*NBar+(1:NGer)))); % Resíduo de Controle do Gerador 
    R4 = max(abs(deltay(2*NBar+NGer+ControleTen*(1:NTap)))); % Resíduo de Controle do transformador
    R5 = max(abs(deltay(2*NBar+NGer+ControleTen*NTap+(1:NgerA)))); % Resíduo de Controle de Potência de Área
    R6 = max(abs(deltay(2*NBar+NGer+ControleTen*NTap+(1:NgerE)))); % Resíduo de Controle de Frequência de Área
    R7 = max(abs(deltay(2*NBar+NGer+ControleTen*NTap+NgerE+NgerA+(1:12*LinhasHVDC)))); % Resíduo de Controle HVDC
    if(isempty(R4)), R4 = 0; end
    if(isempty(R5)), R5 = 0; end
    if(isempty(R6)), R6 = 0; end
    if(isempty(R7)), R7 = 0; end
    ConvGraph = [ConvGraph; ite R1 R2 R3 R4 R5 R6 R7];

    CTolPQ = sum(abs(deltay(1:2*NBar))>TolPQ); 
    CTolVGer = sum(abs(deltay(2*NBar+find(ModoGer==0)))>TolVGer);
    CTolQLim = sum(abs(deltay(2*NBar+find(ModoGer==1)))>TolQGerLim);
    CTolVTap = sum(abs(deltay(2*NBar+NGer+ControleTen*find(ModoTap==0)))>TolVTap) ;
    CTolTapLim = sum(abs(deltay(2*NBar+NGer+ControleTen*find(ModoTap==1)))>TolTapLim);
    CTolPotRes = sum(abs(deltay(2*NBar+NGer+ControleTen*NTap+(1:NgerA)))>TolPotRes);
    CTolFreq = sum(abs(deltay(2*NBar+NGer+ControleTen*NTap+(1:NgerE)))>TolFreq);
    CTolHVDC = sum(abs(deltay(2*NBar+NGer+ControleTen*NTap+NgerE+NgerA+(1:12*LinhasHVDC)))>TolHVDC);
    Tol = CTolPQ + CTolVGer + CTolQLim + CTolVTap + CTolTapLim + CTolPotRes + CTolFreq + CTolHVDC;
end
if (sum(V<0.6))
    % Convergiu para um ponto de operação instável
    Flag = 2;
else
    Flag = 1;
end

% Cálculo do novo Pg dos geradores que contribuíram para suprir as perdas do sistema
Pg = Pg + Pge;

% SUBSISTEMA 2 - Cálculo de P para a barra VTh
if (ControleRes == 0)
    Pg(BarVTh) = Pcal(BarVTh)+Pc(BarVTh);
    if ~isempty(DHVDC)
        LinhasHVDC = size(DHVDC,1);
        for i=1:LinhasHVDC
            DE_ret = DHVDC(i,1);
            PARA_inv = DHVDC(i,2);
            Vdr = Xhvdc(12*(i-1) + 1);
            Vdi = Xhvdc(12*(i-1) + 2);
            Ir = Xhvdc(12*(i-1) + 5);
            Ii = Xhvdc(12*(i-1) + 6);
            Scc_ca = DHVDC(i,23);
            for j=1:size(BarVTh,1)
                if (BarVTh(j) == DE_ret)
                    Pg(BarVTh(j)) = Pg(BarVTh(j)) + Vdr*Ir * Scc_ca;
                end
                if (BarVTh(j) == PARA_inv)
                    Pg(BarVTh(j)) = Pg(BarVTh(j)) - Vdi*Ii * Scc_ca;
                end
            end
        end
    end
end
% Imprime os Resultados na tela
if (Imprime == true)
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    fprintf("\n\t\t\t\t    FLUXO DE POTÊNCIA \n");
    % Cálculo de Pkm, Qkm, Pmk e Qmk
    [Pkm, Pmk, Qkm, Qmk] = Calcula_Fluxo_Entre_Linhas(DE, PARA, V, Th, r, x, Tap, TapPh, BSh_Lin, IndBar);
    
    Imprime_Resultados(DE, PARA, Pkm, Pmk, Qkm, Qmk, Pg, Qg, V, Th, IndBar, BTipo, Xhvdc, DHVDC, Freq, DArea, GovernorControl)
    
    if (sum(sum(HVDCLim ~= 0)) || sum(ModoGer) ~= 0 || sum(ModoTap ~= 0) )
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx      ALERTAS     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    end
    for i =1:size(HVDCLim,2)
        for j=1:size(HVDCLim,1)
            if HVDCLim(j,i) ~= 0
                switch i
                    case 1
                        fprintf('TAP DO RETIFICADOR na linha CC %d no LIMITE. VALOR: %.3f \n',j,1/HVDCLim(j,i));
                    case 2
                        fprintf('ÂNGULO DE DISPARO NO RETIFICADOR na linha CC %d no LIMITE. VALOR: %.3f \n',j,HVDCLim(j,i)*360/2/pi);
                    case 3
                        fprintf('CORRENTE DO ELO na linha CC %d no LIMITE. VALOR: %.3f \n',j,HVDCLim(j,i));
                    case 4
                        fprintf('TAP DO INVERSOR na linha CC %d no LIMITE. VALOR: %.3f \n',j,1/HVDCLim(j,i));
                    case 5
                        fprintf('ÂNGULO DE EXTINSÃO na linha CC %d no LIMITE. VALOR: %.3f \n',j,HVDCLim(j,i)*360/2/pi);
                end
            end
        end
    end
    for i =1:size(ModoGer,1)
        if ModoGer(i) == 1
            fprintf('GERADOR %d no LIMITE de geração reativa.\n',BarGer(i));
        end
    end
    for i =1:size(ModoTap,1)
        if ModoTap(i) == 1
            fprintf('Transformador de índice %d em DLIN com tap no LIMITE.\n',TapC(i,3));
        end
    end
    if (sum(sum(HVDCLim ~= 0)) || sum(ModoGer) ~= 0 || sum(ModoTap ~= 0) )
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    end
    if (Flag == 1)
        fprintf('Convergiu com %.f iterações  \n',ite)  
    else
        fprintf('Convergiu com %.f iterações para um ponto INSTÁVEL(V<0.6pu) \n',ite)  
    end
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
else
end


