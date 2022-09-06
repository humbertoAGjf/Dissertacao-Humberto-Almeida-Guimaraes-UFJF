% Sistema_Conflito_de_Controle_Entre_2_Areas                                                       
                                                                                                    
DBAR =[                                                                                             
%Num BarType Pgerad Qgerad Qmax Qmin Pcarg Qcar QShunt Pshunt Tensao Th BarC Area                                 
   1       2  30.00   8.97   26  -10     0    0      0      0 1.022  0   30    1   
   2       1     90  17.04   78  -30     0    0      0      0 1.022  0   30    1                              
  10       0      0      0    0    0     0    0      0      0 1.006  0   10    1                              
  20       0      0      0    0    0     0    0      0      0 1.012  0   20    1                              
  30       0      0      0    0    0   120    0      0      0 1.000  0   30    1                              
 101       1  25.00  6.275   26  -10     0    0      0      0 1.015  0  130    1   
 102       1     75  11.92   78  -30     0    0      0      0 1.015  0  130    1                              
 110       0      0      0    0    0     0    0      0      0 1.004  0  110    1                              
 120       0      0      0    0    0     0    0      0      0 1.008  0  120    1                              
 130       0      0      0    0    0   100    0      0      0 1.000  0  130    1];                              
                                                                                                    
% Colocar tap=1 para linhas                                                                         
% Lintype: Linha=1;Trafo=2;Trafo defasador=3;                                                       
DLIN = [                                                                                            
% De Para ( R% ) ( X% ) (Mvar) (Tap) (Tmn) (Tmx) (TapPhs) (MVAmax) (Lintype) (BarC)                 
   1   10      0    20.     0      1     0     0        0        0         1      0                 
   2   20      0     7.     0      1     0     0        0        0         1      0                 
  10   20      0     7.     0      1     0     0        0        0         1      0                 
  10   30      0     9.     0      1     0     0        0        0         1      0                 
  30  130      0   0.01     0      1     0     0        0        0         1      0                 
 101  110      0     20     0      1     0     0        0        0         1      0                 
 102  120      0     7.     0      1     0     0        0        0         1      0                 
 110  120      0     7.     0      1     0     0        0        0         1      0                 
 110  130      0     9.     0      1     0     0        0        0         1      0    ];           

% Fator de Participação para Controle do resíduo de potência através de gerador                            
FptGerA = [
%BarGer  FPart 
      1      1  
      2      3
    101      1
    102      3
    ];

% Fator de Participação para Controle conjunto de tensão em barra remota através de gerador
FptGerR = [  
%BarGer  FPart      
      1      1      
      2      3     
    101      1
    102      3
];

DArea = [
%Area %Freq 
    1    60
    2    60
];

% Fator de Participação para Controle Primário de frequência (Estatismo)
FptGerE = [
%BarGer  Estatismo    Pmaq
      1          5      30
      2          5      30
    101          5      25
    102          5      25
];

% Fator de Participação para Controle conjunto de barra remota através de gerador
FptTap = [  
%IndDLINdoTrafo  FPart
];




DadoInc = [  0.01 %PASSO_INI                                                                        
              1E5 %CALC_MAX                                                                         
            0.001 %PASSO_MIN                                                                        
            0.001 %PASSO_TEN                                                                        
              0.7 %AUM_PASSO                                                                        
                0 %INC_PARA                                                                         
];                                                                                                  
% % Fator de participação no aumento de carga para cada barra, Default = 1;                         
%              %Barra  (%P)  (%Q)                                                                   
% DincCarga = [     2     1     1                                                                   
% ];                                                                                                
% % Fator de participação dos Geradores, Default = 1;                                               
%                %Barra  (%P)                                                                       
% DincGerador = [     1     1                                                                       
%                     2     1                                                                       
% ];                                                                                           
                                                                                                    
                                                                                                    