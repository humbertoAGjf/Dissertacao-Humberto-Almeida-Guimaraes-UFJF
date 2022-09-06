function Imprime_Resultados(DE, PARA, Pkm, Pmk, Qkm, Qmk, Pg, Qg, V, Th, IndBar, BTipo, Xhvdc, DHVDC, Freq, DArea, GovernorControl) 
indG(BTipo==0) = false;
indG(BTipo>0) = true;

cancelPlot = 0;
if(isempty(DE))
    cancelPlot = 1;
end
Fluxo= [DE   PARA   round(100*Pkm)/100   round(100*Qkm)/100   round(100*Pmk)/100   round(100*Qmk)/100];
[Lin, Col] = size(Fluxo);
CellFluxo = cell(Lin, Col);
for i =1:Col
    AuxFluxo = Fluxo(:,i); 
%     StrFluxo = num2str(AuxFluxo);
    for j=1:Lin
%         CellFluxo(j,i) = {StrFluxo(j,:)};
        CellFluxo(j,i) = {AuxFluxo(j)};
    end
end

PeQger = [IndBar(indG)     round(10^4*Pg(indG))/100     round(10^4*Qg(indG))/100];
[Lin, Col] = size(PeQger);
CellPeQger = cell(Lin, Col);
for i =1:Col
    AuxPeQger = PeQger(:,i); 
%     StrPeQger = num2str(AuxPeQger);
    for j=1:Lin
%         CellPeQger(j,i) = {StrPeQger(j,:)};
        CellPeQger(j,i) = {AuxPeQger(j)};
    end
end

VeTh = [IndBar   round(10000*(V+0.00001))/10000  round(100*Th*360/(2*pi))/100];
[Lin, Col] = size(VeTh);
CellVeTh = cell(Lin, Col);
for i =1:Col
    AuxVeTh = VeTh(:,i); 
%     StrVeTh = num2str(AuxVeTh);
    for j=1:Lin
%         CellVeTh(j,i) = {StrVeTh(j,:)};
        CellVeTh(j,i) = {AuxVeTh(j)};
    end
end

if ~isempty(Xhvdc)
    LinhasHVDC = size(DHVDC,1);
    HVDC1 = zeros(LinhasHVDC, 10);
    HVDC2 = zeros(LinhasHVDC, 8);
    for i =1:LinhasHVDC
        Pr = Xhvdc(12*(i-1) + 1)*Xhvdc(12*(i-1) + 5);
        Qr = Xhvdc(12*(i-1) + 1)*Xhvdc(12*(i-1) + 5)*tan(Xhvdc(12*(i-1) + 3));
        Pi = Xhvdc(12*(i-1) + 2)*Xhvdc(12*(i-1) + 6);
        Qi = -Xhvdc(12*(i-1) + 2)*Xhvdc(12*(i-1) + 6)*tan(Xhvdc(12*(i-1) + 4));
        HVDC1(i,:) = [DHVDC(i,1)  DHVDC(i,2)  Xhvdc(12*(i-1) + 1)     Xhvdc(12*(i-1) + 2)     Xhvdc(12*(i-1) + 5)     Xhvdc(12*(i-1) + 6)...
            Pr*DHVDC(i,23)*100  Pi*DHVDC(i,23)*100  Qr*DHVDC(i,23)*100  Qi*DHVDC(i,23)*100 ];
        HVDC2(i,:) = [DHVDC(i,1)  DHVDC(i,2) Xhvdc(12*(i-1) + 9)*360/2/pi  Xhvdc(12*(i-1) + 10)*360/2/pi  Xhvdc(12*(i-1) + 7)*360/2/pi   Xhvdc(12*(i-1) + 8)*360/2/pi ...
            1/Xhvdc(12*(i-1) + 11)   1/Xhvdc(12*(i-1) + 12)];
    end
    
    [Lin, Col] = size(HVDC1);
    CellHVDC1 = cell(Lin, Col);
    for i =1:Col
        AuxHVDC1 = HVDC1(:,i); 
%         StrHVDC1 = num2str(AuxHVDC1);
        for j=1:Lin
%             CellHVDC1(j,i) = {StrHVDC1(j,:)};
            CellHVDC1(j,i) = {AuxHVDC1(j)};
        end
    end

    [Lin, Col] = size(HVDC2);
    CellHVDC2 = cell(Lin, Col);
    for i =1:Col
        AuxHVDC2 = HVDC2(:,i); 
%         StrHVDC2 = num2str(AuxHVDC2);
        for j=1:Lin
%             CellHVDC2(j,i) = {StrHVDC2(j,:)};
            CellHVDC2(j,i) = {AuxHVDC2(j)};
        end
    end
    
    THVDC1 = cell2table(CellHVDC1, 'VariableNames',{'DE','PARA','VRet','VInv','Ir','Ii','Pr','Pi','Qr','Qi'});
    THVDC2 = cell2table(CellHVDC2, 'VariableNames',{'DE','PARA','Alfa','Gamma','MIr','MIi','TAPr','TAPi'});
end

Narea = size(Freq,1);
CellFreq = cell(Narea,2);
for i =1:Narea 
    FreqBase = DArea((DArea(:,1)== i), 2);
    CellFreq(i,1) = {i};
    CellFreq(i,2) = {Freq(i)*FreqBase};
end
TFreq = cell2table(CellFreq, 'VariableNames',{'Area','Frequencia'});




if (cancelPlot==0)
    TFluxo = cell2table(CellFluxo, 'VariableNames',{'DE','PARA','Pkm_MW','Qkm_Mvar','Pmk_MW','Qmk_Mvar'});
    disp(' ')
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp('                                   Fluxo entre Barras                                   ')
    disp('----------------------------------------------------------------------------------------')
    %disp('DE           PARA        Pkm(MW)         Qkm(Mvar)       Pmk(MW)         Qmk(Mvar)')
    %fprintf('%d \t\t\t %d\t\t\t %+0.2f\t\t\t %+0.2f\t\t\t %+0.2f\t\t\t %+0.2f \n', Fluxo') 
    disp(TFluxo)
end

TPeQger = cell2table(CellPeQger, 'VariableNames',{'BARRA','Pk_MW','Qk_MVAR'});
disp(' ')
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
disp('                         Potência Ativa e Reativa nos geradores                         ')
disp('----------------------------------------------------------------------------------------')
%disp('BARRA                               Pk(MW)                               Qk(Mvar)       ')
%fprintf('%d \t\t\t\t\t\t\t\t\t%+0.2f \t\t\t\t\t\t\t %+0.2f \n', PeQger') 
disp(TPeQger)

TVeTh = cell2table(CellVeTh, 'VariableNames',{'BARRA','V_pu','Fase_graus'});
disp(' ')
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
disp('                                Tensão e Fase nas barras                                ')
disp('----------------------------------------------------------------------------------------')
%disp('BARRA                                V(pu)                               Fase(graus)    ')
%fprintf('%d \t\t\t\t\t\t\t\t\t %0.3f \t\t\t\t\t\t\t\t %+0.2f \n', VeTh') 
disp(TVeTh)

if (GovernorControl==1)
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp('                                 Frequência do Sistema                                  ')
    disp('----------------------------------------------------------------------------------------')
    disp(TFreq)
end

if ~isempty(Xhvdc)
    disp(' ')  
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp('                                Variáveis de Estado das Linhas HVDC                                 ')
    disp('----------------------------------------------------------------------------------------------------')
    %disp('DE    PARA    VRet     VInv     Ir        Ii        Pr           Pi           Qr           Qi ')
    %fprintf('%d\t  %d\t\t  %0.3f\t   %0.3f\t%+0.3f\t  %+0.3f\t%+0.2f\t %+0.2f\t  %+0.2f\t   %+0.2f\t\n', HVDC1') 
    disp(THVDC1)
    disp(' ') 
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp('                               Variáveis de Controle das Linhas HVDC                                ')
    disp('----------------------------------------------------------------------------------------------------')
    %disp('DE       PARA        Alfa         Gamma         µr            µi            Tapr          Tapi')
    %fprintf('%d\t\t %d\t\t     %0.2f\t      %0.2f\t\t    %0.2f\t      %0.2f\t\t    %0.3f\t\t  %0.3f\t\t \n', HVDC2') 
    disp(THVDC2)
end


% if ~isempty(Tap)
%     
% end

end

%