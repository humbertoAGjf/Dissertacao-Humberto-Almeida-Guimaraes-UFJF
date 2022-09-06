% PROGRAMA PARA CRIAR A MATRIZ YBARRA
function Y = Cria_Matriz_Admitancia(Nbar, Nlin, IndBar, DE, PARA, BSh_Lin, Qs, Ps, r, x, Tap, TapPh, LTipo)

    Y = zeros(Nbar);   
    bkm = BSh_Lin*1i;
    ysh = Qs*1i+Ps;
    ykm = 1./(r+1i*x);

    % Soma parâmetros das linhas, trafos com tap e trafos defasadores
    for i=1:Nlin
        if (LTipo(i)==1)
           a = 1; 
           ph = 0;
        elseif (LTipo(i)==2)
           a = Tap(i);
           ph = 0;
        else
            a = 1;
            ph = TapPh(i);
        end
        p = find(DE(i)==IndBar);
        q = find(PARA(i)==IndBar);
        y = ykm(i);
        b = bkm(i);
        Y(p,p) = Y(p,p) + a^2*y + b;
        Y(q,q) = Y(q,q) + y + b;
        Y(p,q) = Y(p,q) - a*y*exp(-1i*ph);
        Y(q,p) = Y(q,p) - a*y*exp(1i*ph);
    end

    % Soma parâmetros de reatores e Capacitores shunt
    for i=1:Nbar
        p = i;
        b = ysh(i);
        Y(p,p) = Y(p,p) + b;
    end
end


