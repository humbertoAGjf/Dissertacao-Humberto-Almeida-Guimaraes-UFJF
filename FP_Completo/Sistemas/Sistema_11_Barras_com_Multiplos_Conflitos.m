% Sistema_teste_3_geradores_E_2_trafos_em_conflito

DBAR =[                                                                                      
%Num BarType Pgerad Qgerad Qmax Qmin Pcarg Qcar QShunt  Pshunt Tensao Th  BarC Area          
   1       2    120      0  999 -999     0    0      0       0      1  0     3    1          
   2       0      0      0    0    0     0    0      0       0      1  0     2    1          
   3       0      0      0    0    0   120    0      0       0  0.998  0     3    1          
   4       0      0      0    0    0   100    0      0       0  1.000  0     4    1          
   5       0      0      0    0    0     0    0      0       0      1  0     5    1          
   6       1     70      0  999 -999     0    0      0       0  1.000  0     6    1          
   7       0      0      0    0    0   100    0      0       0  0.998  0     7    1          
   8       0      0      0    0    0     0    0      0       0      1  0     8    1          
   9       1    100      0  999 -999     0    0      0       0      1  0     7    1          
  10       0      0      0    0    0     0    0      0       0  0.999  0    10    1          
  11       1     30      0  999 -999     0    0      0       0  1.000  0    11    1];        
% Colocar tap=1 para linhas
% Lintype: Linha=1;Trafo=2;Trafo defasador=3;
DLIN = [
% De Para ( R% ) ( X% ) (Mvar) (Tap) (Tmn) (Tmx) (TapPhs) (MVAmax) (Lintype) (BarC)
   1    2      0     10     0      1     0     0        0        0         1      0
   2    3      0     10     0      1     0     0        0        0         1      0
   3    4      0    0.5     0      1     0     0        0        0         1      0
   3    7      0    0.4     0      1     0     0        0        0         1      0
   4    5      0    0.1     0      1  .955 1.167        0        0         2      4
   4    7      0    0.5     0      1     0     0        0        0         1      0
   5    6      0      1     0      1     0     0        0        0         1      0
   5   10      0    0.1     0      1  .955 1.167        0        0         2     10
   7    8      0     10     0      1     0     0        0        0         1      0
   8    9      0     12     0      1     0     0        0        0         1      0
  10   11      0     0.7    0      1     0     0        0        0         1      0   ]; 
                                                                              
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

