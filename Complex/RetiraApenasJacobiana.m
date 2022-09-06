%
% Programa para extrair a matrix jacobiana de um arquivo .BIN do Anarede
% Autor: Joao Alberto Passos Filho
% Matriz Inteira

tic
close all;
clear all;
clc;
format short e

INT32 = 0;
MatrizJcs = 1;

nome_jac = 'JACOBI_001.BIN';


if(INT32 == 1)
    fid       = fopen(nome_jac,'r');
    param     = fread(fid, 4, 'int32');
    NBar      = param(1);
    nlin      = param(2);
    nbus_tot  = param(3);
    nlin_tot  = param(4);
    ncont     = fread(fid, 1, 'long');
    ntrf      = fread(fid, 1, 'int32');
    nsca      = fread(fid, 1, 'int32');
    ncer      = fread(fid, 1, 'int32');
    nrct      = fread(fid, 1, 'int32');
    ngen      = fread(fid, 1, 'int32');

    % Declaracao de variaveis
    %
    n      = 2*NBar;
    nt     = 2*nbus_tot;
    nc     = nbus_tot - NBar;
    nct    = 2*nc;
    jacob  = sparse(nt , nt);
    iaptad = zeros(nc,1);
    idptad = zeros(nc,1);

    % Criaçao da Identificaçao
    %
    idvar = [ 'CRT '; 'CER '; 'SCA '; 'CAP '; 'CSC '; 'TAP '; 'DC1 '; 'DC2 '; 'DC3 '; 'DC4 '; 'DC5 '; 'DC6 '; 'DC7 '; 'DC8 '; 'DC9 '; 'DC10'; 'DC11'; 'DC12'; 'MI1 '; 'MI2 ' ];
    %
    iaptad  = fread(fid, nc  , 'int32');
    idptad  = fread(fid, nc  , 'int32');
    norderi = fread(fid, nbus_tot, 'int32');
    noint   = fread(fid, NBar, 'int32');    % Numero de indentificação das barras
    nfrom   = fread(fid, nlin, 'int32');    % Ind das barras DE
    nto     = fread(fid, nlin, 'int32');    % Ind das barras PARA
    notap   = fread(fid, ntrf, 'int32');    % Ind das barras Tap?
    nbussca = fread(fid, nsca, 'int32');
    nbecer  = fread(fid, ncer, 'int32');
    ircb    = fread(fid, nrct, 'int32');    % Barra controlada na ordem
    icb     = fread(fid, nrct, 'int32');    % Ind dos Geradore que controlam a barra na mesma ordem que o ircb
    nogen   = fread(fid, ngen, 'int32');    % Ind das barras dos geradores
    %

    %
    for i = 1 : ncont
        mat = fread(fid, 2, 'int32');
        val = fread(fid, 1, 'double');
        if ( abs(val) < 1.0e-5 )
            val = 0.0d0;
        elseif ( abs(val) > 1.0e14 )
            val = 1.0d8;
        end
        jacob(mat(1), mat(2)) = val;
    end
%
else
    fid       = fopen(nome_jac,'r');
    param     = fread(fid, 4, 'int16');
    NBar      = param(1);
    nlin      = param(2);
    nbus_tot  = param(3);
    nlin_tot  = param(4);
    ncont     = fread(fid, 1, 'long');
    ntrf      = fread(fid, 1, 'int16');
    nsca      = fread(fid, 1, 'int16');
    ncer      = fread(fid, 1, 'int16');
    nrct      = fread(fid, 1, 'int16');
    ngen      = fread(fid, 1, 'int16');
    
    % Declaracao de variaveis
    %
    n      = 2*NBar;
    nt     = 2*nbus_tot;
    nc     = nbus_tot - NBar;
    nct    = 2*nc;
    jacob  = sparse(nt , nt);
    iaptad = zeros(nc);
    idptad = zeros(nc);
    
    iaptad  = fread(fid, nc      , 'int16');
    idptad  = fread(fid, nc      , 'int16');
    norderi = fread(fid, nbus_tot, 'int16');
    noint   = fread(fid, NBar    , 'int16');
    nfrom   = fread(fid, nlin    , 'int16');
    nto     = fread(fid, nlin    , 'int16');
    notap   = fread(fid, ntrf    , 'int16');
    nbussca = fread(fid, nsca    , 'int16');
    nbecer  = fread(fid, ncer    , 'int16');
    ircb    = fread(fid, nrct    , 'int16');
    icb     = fread(fid, nrct    , 'int16'); 
    nogen   = fread(fid, ngen    , 'int16');
    %
    for i = 1 : ncont
        mat = fread(fid, 2, 'int16');
        val = fread(fid, 1, 'double');
        if ( abs(val) < 1.0e-5 )
            val = 0.0d0;
        end
        if ( jacob(mat(1), mat(2)) == 0 ) 
            jacob(mat(1), mat(2)) = val;
        else
            jacob(mat(1), mat(2)) = jacob(mat(1), mat(2)) + val;     
        end
    end
    
end

for i = 1 : nt
    if ( jacob(i,i) >= 1.0d8 )
        jacob(:,i) = 0.0d0;
        jacob(i,:) = 0.0d0;
        jacob(i,i) = 1.0d0;
    end
end
%
st = fclose('all');


% Monta a Jacob
%
J            = full(jacob);
[n, n]          = size(jacob);
clear jacob;
indifp = 1:n;

%% Analise USANDO PCA

MatrizData = 0;
if (MatrizJcs == 0)
    data = inv(J);
else
    Jac = J(1:2*NBar,1:2*NBar);         
    Jsx = J(1:2*NBar,2*NBar+1:end);     
    Jyu = J(2*NBar+1:end,1:2*NBar);     
    Jyx = J(2*NBar+1:end,2*NBar+1:end); 
    clear J;
    Jcs = Jyx - Jyu*(Jac\Jsx);
    data = inv(Jcs);
    clear Jcs;
end

[M,N] = size(data);
mn = mean(data,2);
data = data - repmat(mn,1,N);
Y = data' / sqrt(N-1);
T = data*data';
T = diag(T);
T = sort(T,'descend');
[u,S,PC] = svd(Y'*Y);
S = diag(S);
signals = PC' * data;

% PPC = PC(:,2);
% mPPC = PPC/norm(PPC, inf);
% nPPC = abs(mPPC);
% [~, indice2] = sort(nPPC,'descend');
% mPPC = mPPC(indice2);
% mPPC(1:5)
Plota_Conflitos_Por_PCA_Usando_AnaJacob(PC,signals,S,iaptad,idptad,NBar,nogen,nbecer,nbussca,notap,nfrom,nto,ircb,icb,noint,MatrizJcs)

t1 = toc
