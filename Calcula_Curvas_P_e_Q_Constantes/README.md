

<h1 align="center">
  <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Logo_da_UFJF.png" alt="Ufjf logo" width="250"/>
<p>   </p>
<p> Programa Auxiliar Para a Análise do Sistema CCAT </p>
</h1>

## Introdução
Este programa possui duas funções. A primeira é plotar o gráfico com as curvas P e Q constantes, assim como apresentado na dissertação. A segunda função é permitir que o usuário varie os valores especificados para obter, iterativamente, os resultados do HVDC, permitindo uma rápida análise de seu comportamento. <strong>Atenção!</Strong> Este não é um <a href="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/tree/main/FP_Completo">fluxo de potência completo</a>, pois utiliza apenas o sistema HVDC, considerando as tensões nas barras adjacentes como 1 pu.


## Modo de Usar

Apenas o arquivo <strong>Main.mlx</strong> e o arquivo de dados <strong>Sistema_HVDC_FOZ_IBIUNA.m</strong> devem ser utilizados.

Para a análise iterativa do comportamento do elo CCAT, deve-se apenas variar os valores na seção "Dados do HVDC". <strong>Dica:</strong> para facilitar a visualização, recomenda-se desabilitar a rolagem síncrona do MATLAB.

> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem6.png" alt="Flags Main" width="90%"/>
> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem7.png" alt="Flags Main" width="90%"/>


No Main é possível gerar o gráfico das curvas P e Q contantes. Para isso a checkbox deve ser marcada e os dados do plot escolhidos. Vale destacar que os dados do HVDC utilizados na análise anterior também influênciam no plot das curvas. 

> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem4.png" alt="Flags Main" width="90%"/>
> <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem5.png" alt="Flags Main" width="90%"/>
