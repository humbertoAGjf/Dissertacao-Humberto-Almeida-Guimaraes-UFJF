

<h1 align="center">
  <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Logo_da_UFJF.png" alt="Ufjf logo" width="250"/>
<p>   </p>
<p> Entrada de Dados </p>
</h1>

## Introdução

Este documento tem a finalidade de explicar o arquivo entrada de dados, permitindo que o usuário possa alterá-lo conforme sua necessidade.

## Modo de usar

> Dados da matriz <strong>DBAR</strong>:
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
> - BarC: índice da barra que é controlada pelo gerador desta barra (Válido apenas para barras com geradores).
> - Area: índice da área à qual a barra pertence.
> - Vbase: tensão base da barra.
<img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem8.png" alt="Flags Main" width="90%"/>
