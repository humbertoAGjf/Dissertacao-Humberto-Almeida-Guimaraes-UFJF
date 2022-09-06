function Imprime_Resultados(Xhvdc, DHVDC) 
    LinhasHVDC = 1;
    if ~isempty(Xhvdc)

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

end

%