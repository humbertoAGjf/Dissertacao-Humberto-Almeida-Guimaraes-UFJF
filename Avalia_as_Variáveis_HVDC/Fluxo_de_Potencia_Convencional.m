% Sistema = Arquivo de Dados do Sistema
% Imprime = true or false // Para imprimir os resultados
% O que tem implementado:
% - Controle de tensão em barras remotas(Para barras do tipo PV)
% - Controle de tensão por área (varios geradores controlando uma barra)
% - Controle de tensão através de tap
% - Controle de tensão para multiplos trafos controlando a mesma barra
% - Controle de resíduo(perdas de pot ativa nas linhas) por área(1 barra de ref para cada área)
% - Consideração de Limite dos Geradores com Back off
% - Consideração de Limite de Tap com Back off
% - Implementação de linhas HVDC com Operação Normal(Controle potencia ou corrente) e High mvar Consumption. O modo Vdcmin não foi implementado

% OBS: - Não está fazendo controle de 2 Geradores na mesma barra
%      - Faz controle de 2 trafos na mesma barra
% Fluxo_de_Potencia_Convencional(Sitema Utilizado, Incremento de carga no caso base, Imprime resultados{1=true, 0=false},{com controle = 1, Convencional=0})
function [Flag, Xhvdc, ModoHVDC] = Fluxo_de_Potencia_Convencional(Imprime, DHVDC, XhvdcEsp) 
% Variável utilizada para Fluxo de Potência Continuado. 0 = FP convencional e 1 = FP continuado

% Parâmetro de Tolerância
TolHVDC = 10^-6;

% Inicializa as variáveis
Xhvdc = XhvdcEsp(1:12);

% Aplica Os Limites e Back Off
[ModoHVDC, HVDCLim] = Limites_Com_Tap(Xhvdc, DHVDC);

% Calcula os Resíduos deltaIr e deltaIm
deltay = Calcula_Residuo(Xhvdc, DHVDC, ModoHVDC, HVDCLim);

ite = 0;

CTolHVDC = sum(abs(deltay(1:12))>TolHVDC);
Tol = CTolHVDC;

while (Tol~=0)
    % Cria (-) a matriz Jacobiana
    J = Cria_J(Xhvdc, DHVDC, ModoHVDC);

    % Resolve o Sistema
    deltaX = J\deltay;
       
    % Separa as variáveis
    deltaXhvdc = deltaX;

    Xhvdc = Xhvdc + deltaXhvdc;

    
    % Aplica Os Limites e Back Off
    [ModoHVDC, HVDCLim] = Limites_Com_Tap(Xhvdc, DHVDC);

    deltay = Calcula_Residuo(Xhvdc, DHVDC, ModoHVDC, HVDCLim);

    ite=ite+1;
    if(ite>100 || sum(isnan(deltay))>0)
        if (Imprime == true)
            fprintf('Divergiu \n');
        end
        Flag = 0;
        return;
    end 
   
    CTolHVDC = sum(abs(deltay(1:12))>TolHVDC);
    Tol = CTolHVDC;
end
Flag = 1;
% Imprime os Resultados na tela
if (Imprime == true)
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    fprintf("\n\t\t\t\t    FLUXO DE POTÊNCIA \n");
    % Cálculo de Pkm, Qkm, Pmk e Qmk
    
    Imprime_Resultados(Xhvdc, DHVDC)
    
    if (sum(sum(HVDCLim ~= 0)))
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
    if (sum(sum(HVDCLim ~= 0)))
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    end
    if (Flag == 1)
        fprintf('Convergiu com %.f iterações  \n',ite)  
    end
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
end

