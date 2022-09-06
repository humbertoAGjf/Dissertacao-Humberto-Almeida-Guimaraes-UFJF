

<h1 align="center">
  <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Logo_da_UFJF.png" alt="Ufjf logo" width="250"/>
<p>   </p>
<p> Entrada de Dados </p>
</h1>

## Introdução

Este documento tem a finalidade de explicar o arquivo entrada de dados, permitindo que o usuário possa alterá-lo conforme sua necessidade.

## Modo de usar

<strong>Dados da matriz DBAR</strong>:
> - Num: índice da barra.
> - BarType: 0 = barra PQ; 1 = barra PV; 2 = Barra de referência (é necessário 1 barra de referência para cada área do sistema).
> - Pgerad: potência no gerador especificada.
> - Qgerad: potência reativa no gerador esperada (chute inicial, para FlatStart = 0).
> - Qmax: límite máximo de potência reativa do gerador.
> - Qmin: límite mínimo de potência reativa do gerador.
> - Pcarg: potência ativa da carga na barra.
> - Qcarg: potência reativa da carga na barra.
> - Qshunt: carga reativa shunt devido aos bancos de capacitores.
> - Pshunt: carga ativa shunt devido às perdas em banco de capacitores (Modelada por impedância constante).
> - Tensao: tensão especificada/esperada na barra.
> - Th: ângulo especificado/esperado na barra.
> - BarC: índice da barra controlada pelo gerador (Válido apenas para barras com geradores).
> - Area: índice da área à qual a barra pertence.
> - Vbase: tensão base da barra.
> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem8.png" alt="Matriz DBar" width="90%"/>

<strong>Dados da matriz DLIN</strong>:
> - De: índice da barra DE da linha.
> - Para: índice da barra PARA da linha.
> - ( R% ): valor da resistência da linha em %.
> - ( X% ): valor da reatância da linha em %.
> - (Mvar): valor de susceptância shunt do circuito, em Mvar.
> - (Tap): valor de tap especificado/esperado do transformador (usar 1 para linhas).
> - (Tmn): limite mínimo de tap do transformador.
> - (Tmx): limite máximo de tap do transformador.
> - (TapPhs): ângulo de phase do transformador (usar 0 para linhas e transformadores normais).
> - (MVAmax): não utilizado. 
> - (Lintype): 1 = Linha; 2 = transformador; 3 = transformador defasador
> - (BarC): índice da barra controlada pelo transformador (Válido apenas para barras com transformadores normais).
> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem9.png" alt="Matriz DLin" width="90%"/>

<strong>Dados da matriz DArea</strong>:
> - Area: índice da área.
> - Freq: frequência nominal da área.
> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem10.png" alt="Matriz DArea" width="90%"/>

<strong>Dados da matriz LoadDamping</strong>:
> - Barra: índice da barra que terá consirado a queda da potência com frequência.
> - Dp: queda da potência ativa com a frequência $\Delta P_c^{pu} = Dp.\Delta f^{pu}$
> - Dq: queda da potência reativa com a frequência $\Delta Q_c^{pu} = Dq.\Delta f^{pu}$
> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem11.png" alt="Matriz LoadDamping" width="90%"/>

<strong>Dados da matriz FptGerE</strong>:
> - BarGer: índice da barra do gerador considerado.
> - Estatismo(%): valor do estatismo em porcento da potência base da máquina
> - MvaMaq: valor em MVa da potência base do gerador (Caso esta coluna seja omitida, o valor utilizado será a potência ativa especificada em DBAR).
> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem12.png" alt="Matriz FptGerE" width="90%"/>

<strong>Dados da matriz FptHVDCE</strong>:
> - IndElo: índice do elo em que será feito o controle de frequência primário.
> - Mf: Stab50 → $m_f = K_1$; Caso convencional ou STF sem controle dinâmico → $m_f = m_0$; Caso STF com $m_f$ fixo → $m_f = m_f^{calculado}; Caso sem controle → $m_f = 0$$.
> - Mv: Stab50 → $m_f = K_2$; Caso convencional → remover a coluna; Caso STF → valor de $m_v = m_v^{calculado}$.
> - MfMax: Stab50 → $m_f = K_2$; Casos com $m_f$ dinâmico → usar o valor de $m_f^{max}$ calculado; Demais casos → remover a coluna.
> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem13.png" alt="Matriz FptGerE" width="90%"/>
