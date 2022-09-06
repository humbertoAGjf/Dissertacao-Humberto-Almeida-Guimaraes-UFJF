

<h1 align="center">
  <img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Logo_da_UFJF.png" alt="Ufjf logo" width="250"/>
<p>   </p>
<p> TITULO GIGANTESCO </p>
</h1>

## Introdução
Neste repositório serão disponilizados todos os arquivos e orientações necessários para reproduzir a dissertação desenvolvida por <strong>Humberto Almeida Guimarães</strong> e orientada por João Alberto Passos Filho. Em caso de dúvidas, contatar o email humberto.guimaraes@engenharia.ufjf.br.

## Descritivo dos arquivos

- **Dissertação em formato pdf**
- **Arquivos em formato MATLAB desenvolvidos por Humberto Almeida Guimarães**
- **Arquivos em formato Anatem (CEPEL) disponibilizados pelo ONS**
- **Arquivos em formato Anarede (CEPEL) disponibilizados pelo ONS**
- **Imagens utilizadas neste repositório**

## Como gerar os resultados em MATLAB

Existem 2 pastas com programas: "Calcula_Curvas_P_e_Q_Constantes", a qual é utilizada apenas para gerar as curvas P e Q constantes; "FP_Completo", a qual é utilizada para gerar o restante dos resultados.

- **FP_Completo**

Apenas o arquivo <strong>Main.mlx</strong> e os arquivo de dados de sistemas presentes na pasta Sistema devem ser utilizados.

> No arquivo <strong>Main.mlx</strong> deve-se ligar as funções de acordo com o seu objetivo. Para isto, basta alterar o seguinte trecho do programa:
<img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem1.png" alt="Flags Main" width="90%"/>

> Para cada função ativada, pode ser necessário alterar alguns de seus parâmetros. Abaixo é apresentado um exemplo para o fluxo de potência, no qual pode ser escolhido se será ou não considerado o controle de tensão, flatstart, controle secundário de frequência (CAG) e controle primário de frequência (Governor). Além disso, ainda podem ser feitas alterações nos passos de convergência do FP.
<img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem2.png" alt="Flags Main" width="90%"/>

> Para selecionar o arquivo de sistema que será utilizado, basta trocar o seu nome na aba "Sistema Utilizado nas Análises":
<img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem3.png" alt="Flags Main" width="90%"/>

- **Calcula_Curvas_P_e_Q_Constantes**

Apenas o arquivo <strong>Main.mlx</strong> e o arquivo de dados <strong>Sistema_HVDC_FOZ_IBIUNA.m</strong> devem ser utilizados.

>  No Main é possível gerar o gráfico das curvas P e Q contantes. Para isso a checkbox deve ser marcada e os dados do plot escolhidos.
<img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem4.png" alt="Flags Main" width="90%"/>
<img src="https://github.com/humbertoAGjf/Dissertacao-Humberto-Ufjf/blob/main/Imagens/Imagem5.png" alt="Flags Main" width="90%"/>

## Entenda os Arquivos de Entrada de Dados dos Sistema

