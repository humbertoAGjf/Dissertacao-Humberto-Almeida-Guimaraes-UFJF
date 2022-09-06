% Sistema_HVDC_FOZ_IBIUNA

DBAR =[                                                                              
%Num BarType     Pgerad  Qgerad  Qmax  Qmin   Pcarg Qcar QShunt Pshunt   Tensao     Th BarC Area Vbase  
   1       0          0       0     0     0    63.0    0 1365.0      0   1.0000   -9.1    1    1   500  
   2       0          0       0     0     0    52.0    0 1838.0      0   1.0000  23.24    2    2   500  
   3       1          0  494.63  9999 -9999       0    0      0      0   1.1002  23.24    2    2   500  
  10       2    6327.09  3099.4  9999 -9999       0    0      0      0   1.0628      0    1    1   500  
  20       2   4988.014  3817.2  9999 -9999 10914.0    0      0      0   1.1730      0   20    2   500  
   ];       

% DBAR(4,7) = DBAR(4,7) + 700;
DBAR(5,7) = DBAR(5,7) + 0;
% Colocar tap=1 para linhas                                                                         
% Lintype: Linha=1;Trafo=2;Trafo defasador=3;                                                       
DLIN = [                                                                                            
% De Para ( R% ) ( X% ) (Mvar) (Tap) (Tmn) (Tmx) (TapPhs) (MVAmax) (Lintype) (BarC)                 
   1   10      0  0.255      0     1     0     0        0        0         1      0                 
   2   20      0  0.781      0     1     0     0        0        0         1      0   
   2    3      0  0.938      0     1     0     0        0        0         1      0   
]; 


DArea = [
%Area %Freq 
    1    50 
    2    60 
];

LoadDamping = [
%Barra   Dp Dq    
%     10    1  1
];

% % Fator de Participacao para Controle Primario de frequencia (Estatismo)
% FptGerE = [
% %BarGer  Estatismo(%)   MVaMaq1     MVaMaq2
%      10             5    8944.5   % 524.9895         % Para Variação de potência
%      20             5    8000.0   % 524.9895         % de até 737 MW e acima
% ];

% Fator de Participacao para Controle Primario de frequencia (Estatismo)
FptGerE = [
%BarGer  Estatismo(%)   MVaMaq1     MVaMaq2
     10          5.00    40000.0   % 524.9895         % Para Variação de potência
     20          5.00    4000.0   % 524.9895         % de até 737 MW e acima
];

FptHVDCE = [
% STF(Tiristor) (M0 = 400MW/Hz)  /// Tapi = 0,96 e V3 = 1,1002
% IndElo        #Mf             #Mv   MfMax     
       1   15.32567        1.073720         12             
       2   15.32567        1.073720         12
       3   15.32567        1.073720         12
       4   15.32567        1.073720         12


% % STF(Tiristor) (M0 = 400MW/Hz)
% % IndElo        #Mf             #Mv   MfMax     
%        1   15.32567        1.500581         12             
%        2   15.32567        1.500581         12
%        3   15.32567        1.500581         12
%        4   15.32567        1.500581         12


% FptHVDCE = [
% % STF(Tiristor) (M0 = 400MW/Hz)
% % IndElo        #Mf             #Mv   MfMax     
%        1   15.32567        1.500581         12             
%        2   15.32567        1.500581         12
%        3   15.32567        1.500581         12
%        4   15.32567        1.500581         12


% % STF(Tiristor) (M0 = 100MW/Hz)
% % IndElo        #Mf             #Mv       
%        1   1.509955        1.500581               
%        2   1.509955        1.500581
%        3   1.509955        1.500581
%        4   1.509955        1.500581

% % STF(Tap) (M0 = 400MW/Hz)
% % IndElo        #M0             #Mv       MfMax
%        1   15.32567       -0.723029          12        
%        2   15.32567       -0.723029          12
%        3   15.32567       -0.723029          12
%        4   15.32567       -0.723029          12

% % STF(Tap) (M0 = 400MW/Hz) Com mf = mfMax e mv = mvMin
% % IndElo        #M0             #Mv       MfMax
%        1   15.32567        0.286597          12        
%        2   15.32567        0.286597          12
%        3   15.32567        0.286597          12
%        4   15.32567        0.286597          12

% % STF(Tap) (M0 = 80MW/Hz)
% % IndElo        #M0             #Mv       MfMax
%        1     3.065134       -0.723029          12        
%        2     3.065134       -0.723029          12
%        3     3.065134       -0.723029          12
%        4     3.065134       -0.723029          12

% % STAB 50 
%        % IndElo       #K1         #K2
%        1       0.5108556832694  86.206896551724        % (Ki/(Sbcc/Fhz))/2 = (Ki/(PbElo/50))/2
%        2       0.5108556832694  86.206896551724        % (Ki/(Sbcc/Fhz))/2 = (Ki/(PbElo/50))/2
%        3       0.5108556832694  86.206896551724        % (Ki/(Sbcc/Fhz))/2 = (Ki/(PbElo/50))/2
%        4       0.5108556832694  86.206896551724        % (Ki/(Sbcc/Fhz))/2 = (Ki/(PbElo/50))/2

% % CONTROLE CONVENCIONAL (M0 = 100MW/Hz)
% % IndElo        #Mf  
%        1     3.8314    
%        2     3.8314    
%        3     3.8314    
%        4     3.8314    

% % CONTROLE CONVENCIONAL (M0 = 400MW/Hz)
% % IndElo        #Mf  
%        1     15.32567
%        2     15.32567  
%        3     15.32567   
%        4     15.32567  

% % SEM CONTROLE DE FREQUENCIA
% % IndElo        #Mf  
%        1          0    
%        2          0    
%        3          0    
%        4          0  
];


% OBS: CASO UMA DAS BARRAS QUE IRA RECEBER A LINHA HVDC SEJA DE REF.,
% DEVE-SE LIGAR A FUNCAO CONTROLA RESIDUO
DELO = [    
%     (**) - > Normal=0, HighMvarConsumption=1, SFT(Tiristor)=2 , Convencional(Tiristor)=3 , Stab50(Tiristor)=4, SFT(Tap)=5, Convencional(Tap)=6, Stab50(Tap)=7
%                                                (**) \/    dado do DCBA \/ 0=Vdr,1=Vdi      
 %De   %Para   %RccOhms  Lcc_mH    VbElo   PbElo  ModoElo      Vesp     VdRef
   1       2       10.5  1231.9      600    1566        2   572.604         1
   1       2       10.5  1231.9      600    1566        2   572.604         1
   1       2       10.5  1231.9      600    1566        2   572.604         1
   1       2       10.5  1231.9      600    1566        2   572.604         1
];

% Dados dos conversores
DCNV = [
%              Ind   0 = ret                                       Ñ uso
%Ind  BarraCa EloCC RetOuInv Pontes   Inom    Xc     Vfs  SBtrafo  Freq
   1        1     1        0      4   2610  17.8   127.4    471.0    50
   2        2     1        1      4   2610  17.2   122.0    450.0    60
   3        1     2        0      4   2610  17.8   127.4    471.0    50
   4        2     2        1      4   2610  17.2   122.0    450.0    60
   5        1     3        0      4   2610  17.8   127.4    471.0    50
   6        2     3        1      4   2610  17.2   122.0    450.0    60
   7        1     4        0      4   2610  17.8   127.4    471.0    50
   8        2     4        1      4   2610  17.2   122.0    450.0    60
];

% DCCV = [
% %DCNV Modo  MwouA  em %  em %   gammaEsp GammaMn GammaMx          ModoVdcmin             ModoVdcmin   
% % Ind CouP   Vesp  Marg  IMax  ouAlfaEsp  AlfaMn  AlfaMx TapMn TapMx Vmn TapdoHighMvar        Tap    TapEsp
%     1    0  2610.    10  9999       15.0    12.5    17.0  .925 1.250 0.9         1.250          1         1.0054565
%     2    0  2610.    10  9999       17.0    17.0    17.0  .925 1.305 0.9         1.305          1         1.0014274
%     1    0  2610.    10  9999       15.0    12.5    17.0  .925 1.250 0.9         1.250          1         1.0054565
%     2    0  2610.    10  9999       17.0    17.0    17.0  .925 1.305 0.9         1.305          1         1.0014274
%     1    0  2610.    10  9999       15.0    12.5    17.0  .925 1.250 0.9         1.250          1         1.0054565
%     2    0  2610.    10  9999       17.0    17.0    17.0  .925 1.305 0.9         1.305          1         1.0014274
%     1    0  2610.    10  9999       15.0    12.5    17.0  .925 1.250 0.9         1.250          1         1.0054565
%     2    0  2610.    10  9999       17.0    17.0    17.0  .925 1.305 0.9         1.305          1         1.0014274];

DCCV = [                                                                                                             
%DCNV Modo  MwouA  em %  em %   gammaEsp GammaMn GammaMx          ModoVdcmin             ModoVdcmin                  
% Ind CouP   Vesp  Marg  IMax  ouAlfaEsp  AlfaMn  AlfaMx TapMn TapMx Vmn TapdoHighMvar        Tap    TapEsp          
    1    0  2610.    10  9999       15.0      5.   84.99  .925 1.250 0.9         1.250          1         1.0054565  
    2    0  2610.    10  9999       17.0     17.   72.74  .925 1.305 0.9         1.305          1         0.96  
    1    0  2610.    10  9999       15.0      5.   84.99  .925 1.250 0.9         1.250          1         1.0054565  
    2    0  2610.    10  9999       17.0     17.   72.74  .925 1.305 0.9         1.305          1         0.96   
    1    0  2610.    10  9999       15.0      5.   84.99  .925 1.250 0.9         1.250          1         1.0054565  
    2    0  2610.    10  9999       17.0     17.   72.74  .925 1.305 0.9         1.305          1         0.96  
    1    0  2610.    10  9999       15.0      5.   84.99  .925 1.250 0.9         1.250          1         1.0054565  
    2    0  2610.    10  9999       17.0     17.   72.74  .925 1.305 0.9         1.305          1         0.96];

DadoInc = [  0.01 %PASSO_INI                                                                        
              1E5 %CALC_MAX                                                                         
            0.001 %PASSO_MIN                                                                        
            0.001 %PASSO_TEN                                                                        
              0.7 %AUM_PASSO                                                                        
                0 %INC_PARA                                                                         
];                                                                                                  
% % Fator de participaÃ§Ã£o no aumento de carga para cada barra, Default = 1;                         
%              %Barra  (%P)  (%Q)                                                                   
% DincCarga = [     2     1     1                                                                   
% ];                                                                                                
% % Fator de participaÃ§Ã£o dos Geradores, Default = 1;                                               
%                %Barra  (%P)                                                                       
% DincGerador = [     1     1                                                                       
%                     2     1                                                                       
% ];    




