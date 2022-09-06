function [FPIndNomes, MSIndNomes, CellDj] = Plota_Analise_AutoValores(J, TipoMatrizJ_A, LambdaMaxA, NLambdaA, FPMinA, MSMinA, NBar, BarCGer, BarGer, TapC, BarCTap, FptGerA, FptGerE, Area, DHVDC, IndBar, ControleTen, ControleRes, GovernorControl, IsPlotOn)

    if (GovernorControl == 1)
        NgerE = size(FptGerE,1);
        NgerA = 0;
    else
        NgerE = 0;
        if (ControleRes == 1)
            NgerA = size(FptGerA,1);
        else
            NgerA = 0;
        end
    end
    if (ControleTen == 1)
        NTap = length(TapC(:,1));
    else
        BarCGer = BarGer;
        NTap = 0;
    end
    NGer = length(BarCGer);
    NTh = 0;
    Nhvdc = size(DHVDC,1);
    CharLambda = char(955);

    % Crio a Matriz de Sensibilidade de Controles
	% Jcs = Jyx - Jyu*(Jax^-1)*Jsx
	% J = [ Jac     Jsx
	%       Jyu     Jyx ]
    if (TipoMatrizJ_A == 1)
        Jac = J(1:2*NBar,1:2*NBar);         
        Jsx = J(1:2*NBar,2*NBar+1:end);     
        Jyu = J(2*NBar+1:end,1:2*NBar);     
        Jyx = J(2*NBar+1:end,2*NBar+1:end); 
        J = Jyx - Jyu/Jac*Jsx;
    end
    

    %% Analise Decomposição em Autovalores e Autovetores

    % Decomposição em autovalores e autovetores
    % V = autovetor a direita, D = Matriz de autovalores, W = autovetores a esquerda
    % Encontro o menor autovalor Para  J
    [Vj,Dj] = eig(J);
    Wj  = inv(Vj);
    Dj = diag(Dj);
    [AbsDjsort, IDj] = sort(abs(Dj));

    NLambda = sum(AbsDjsort < LambdaMaxA);
    FPIndNomes = cell(NLambda,1);
    MSIndNomes = cell(NLambda,1);
    CellDj = cell(NLambda,2);
    % Plota os Auto Valores encontrados dentro da tolerância
    if (IsPlotOn == 1)
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        fprintf("\n\t\t\t\t ANÁLISE POR AUTO VALORES\n\n");
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        disp('x-------------------------------------x')
        fprintf("          Menores Autovalores\n\n");
    end
    if (NLambda>0)
        AuxDj = Dj(IDj(1:NLambda));
        for j=1:NLambda
            CellDj(j,1) = {IDj(j)};
            CellDj(j,2) = {AuxDj(j)};
        end
        TDj = cell2table(CellDj, 'VariableNames',{'Indice','Lambda'});
        if (IsPlotOn == 1)
            disp(TDj);
        end
    else
        if (IsPlotOn == 1)
            disp("Não foram encontrados Auto Valores menores que a Tolerância")
        end
    end
    if (NLambdaA > NLambda)
        NLambdaA = NLambda;
    end
    if (IsPlotOn == 1)
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
        fprintf("                                  Fator de Participação\n")
    end
    for j = 1:NLambdaA
        if (IsPlotOn == 1)
            disp('x-------------------------------------x')
            fprintf("              FP para %s%d\n\n",CharLambda,IDj(j))
        end
        % Calula o Fator de participação   
        FP = real(Vj(:,IDj(j)).*Wj(IDj(j),:)');
        [AbsFPSort, IFP] = sort(abs(FP),'descend');
        NFP = sum(AbsFPSort > FPMinA);

        FPIndNome = PlotResiduos(NFP, IFP, FP, TipoMatrizJ_A, NBar, NGer, NTap, NTh, Nhvdc, NgerA, NgerE, BarCGer, BarGer, BarCTap, IndBar, FptGerA, FptGerE, Area);
        FPIndNomes{j} = FPIndNome;
        
        % Plota os valores de Fator de Participação para um determinado Auto Valor
        TFPIndNome = cell2table(FPIndNome, 'VariableNames',{'Indice','Fator de Participação'});
        if (IsPlotOn == 1)
            disp(TFPIndNome);
        end
    end
    if (IsPlotOn == 1)
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    end
        
    %% Mode-Shape
    if (IsPlotOn == 1)
        fprintf("                                        Mode Shape\n")
    end
    for j = 1:NLambdaA
        if (IsPlotOn == 1)
            disp('x-------------------------------------x')
            fprintf("        MS para %s%d\n\n",CharLambda,IDj(j)) 
        end
        % Calula o Mode Shape
        MS =  Vj(:, IDj(j));
        MS = real(MS./norm(MS, inf));
        [AbsMSSort, IMS] = sort(abs(MS),'descend');
        NMS = sum(AbsMSSort > MSMinA);

        MSIndNome = PlotVars (NMS, IMS, MS, TipoMatrizJ_A, NBar, NGer, NTap, NTh, Nhvdc, NgerA, NgerE, BarGer, IndBar, FptGerA, FptGerE, Area, TapC);
        MSIndNomes{j} = MSIndNome;

        % Plota os valores de Fator de Participação para um determinado Auto Valor
        TMSIndNome = cell2table(MSIndNome, 'VariableNames',{'Indice','Mode-Shape'});
        if (IsPlotOn == 1)
            disp(TMSIndNome);
        end
    end
    if (IsPlotOn == 1)
        disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    end



    %% PlotVars
    function SIndNome = PlotVars(NS, IS, S, TipoMatrizJ_A, NBar, NGer, NTap, NTh, Nhvdc, NgerA, NgerE, BarGer, IndBar, FptGerA, FptGerE, Area, TapC)
        ii = 0;
        jj = 1;
        DeltaChar = char(916);
        RIGHTARROW = char(8594);
        Th = char(952);
        if (NS< 2)
            NS = 2;
        end
        if (NgerA>0)
            FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
            NgerAi = length(FptGerAi);
        end
        if (NgerE>0)
            FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
            NgerAi = length(FptGerAi);
            RefTh = unique(Area);
            NTh = size(RefTh,1);
        end
        SIndNome = cell(NS,2);
        for k=1:NS
            i = IS(k);
            SIndNome(k,2) = {S(i)};
            if (TipoMatrizJ_A == 0)
                if i<= NBar
                    SIndNome(k,1) = {strcat(DeltaChar,Th,'_{',num2str(IndBar(i)),'}')};
                elseif i<=2*NBar
                    SIndNome(k,1) = {strcat(DeltaChar,'V_{',num2str(IndBar(i-NBar)),'}')};
                elseif (i<=2*NBar+NGer)
                    SIndNome(k,1) = {strcat(DeltaChar,'Qg_{',num2str(IndBar(BarGer(i-2*NBar))),'}')};
                elseif (i<=2*NBar+NGer+NTap)
                    SIndNome(k,1) = {strcat(DeltaChar,'a',num2str(IndBar(TapC(i-2*NBar-NGer,1))),'_',num2str(IndBar(TapC(i-2*NBar-NGer,2))))};
                elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE)
                    ii = ii + 1;
                    SIndNome(k,1) = {strcat(DeltaChar,'P_{ge',num2str(IndBar(FptGerAi(ii))),'}')};
                    if (ii == NgerAi)
                        ii = 0;
                        jj = jj+1;
                        if(NgerE>0)
                            FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
                        else
                            FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
                        end
                        NgerAi = length(FptGerAi);
                    end
                elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE+NTh)
                    SIndNome(k,1) = {strcat('RefTh_{',num2str(IndBar(RefTh(i-(2*NBar+NGer+NTap+NgerA+NgerE)))),'}')};
                elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE+NTh+Nhvdc*12)
                    iaux = i - (2*NBar+NGer+NTap+NgerA+NgerE+NTh);
                    iaux1 = floor(iaux/13)+1;
                    iaux2 = mod(iaux,12);
                    iaux2 = iaux2 + 12*(iaux2==0);
                    switch iaux2
                        case 1
                            Tstring = strcat(DeltaChar,'Vd_r',num2str(iaux1));
                        case 2
                            Tstring = strcat(DeltaChar,'Vd_i',num2str(iaux1));
                        case 3
                            Tstring = strcat(DeltaChar,char(216),'_r',num2str(iaux1));
                        case 4
                            Tstring = strcat(DeltaChar,char(216),'_i',num2str(iaux1));
                        case 5
                            Tstring = strcat(DeltaChar,'I_r',num2str(iaux1));
                        case 6
                            Tstring = strcat(DeltaChar,'I_i',num2str(iaux1));
                        case 7
                            Tstring = strcat(DeltaChar,char(956), '_r',num2str(iaux1));
                        case 8
                            Tstring = strcat(DeltaChar,char(956), '_i',num2str(iaux1));
                        case 9
                            Tstring = strcat(DeltaChar,char(945),num2str(iaux1));
                        case 10
                            Tstring = strcat(DeltaChar,char(404),num2str(iaux1));
                        case 11
                            Tstring = strcat(DeltaChar,'a_r',num2str(iaux1));
                        case 12
                            Tstring = strcat(DeltaChar,'a_i',num2str(iaux1));
                    end
                    SIndNome(k,1) = {Tstring};
                end
                
            else
                if (i<=NGer)
                    SIndNome(k,1) = {strcat(DeltaChar,'Qg_{',num2str(IndBar(BarGer(i))),'}')};
                elseif (i<=NGer+NTap)
                    SIndNome(k,1) = {strcat(DeltaChar,'a_{',num2str(IndBar(TapC(i-NGer,1))),RIGHTARROW,num2str(IndBar(TapC(i-NGer,2))),'}')};
                elseif(i<=2*NBar+NGer+NTap+NgerA+NgerE)
                    ii = ii + 1;
                    SIndNome(k,1) = {strcat(DeltaChar,'P_{ge',num2str(IndBar(FptGerAi(ii))),'}')};
                    if (ii == NgerAi)
                        ii = 0;
                        jj = jj+1;
                        if(NgerE>0)
                            FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
                        else
                            FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
                        end
                        NgerAi = length(FptGerAi);
                    end
                elseif (i<=NGer+NTap+NgerA+NgerE+NTh)
                    SIndNome(k,1) = {strcat(DeltaChar,'RefTh_{',num2str(IndBar(RefTh(i-(NGer+NTap+NgerA+NgerE)))),'}')};
                elseif (i<=NGer+NTap+NgerA+NgerE+NTh+Nhvdc*12)
                    iaux = i - (NGer+NTap+NgerA+NgerE+NTh);
                    iaux1 = floor(iaux/13)+1;
                    iaux2 = mod(iaux,12);
                    iaux2 = iaux2 + 12*(iaux2==0);
                    switch iaux2
                        case 1
                            Tstring = strcat(DeltaChar,'Vd_r',num2str(iaux1));
                        case 2
                            Tstring = strcat(DeltaChar,'Vd_i',num2str(iaux1));
                        case 3
                            Tstring = strcat(DeltaChar,char(216),'_r',num2str(iaux1));
                        case 4
                            Tstring = strcat(DeltaChar,char(216),'_i',num2str(iaux1));
                        case 5
                            Tstring = strcat(DeltaChar,'I_r',num2str(iaux1));
                        case 6
                            Tstring = strcat(DeltaChar,'I_i',num2str(iaux1));
                        case 7
                            Tstring = strcat(DeltaChar,char(956), '_r',num2str(iaux1));
                        case 8
                            Tstring = strcat(DeltaChar,char(956), '_i',num2str(iaux1));
                        case 9
                            Tstring = strcat(DeltaChar,char(945),num2str(iaux1));
                        case 10
                            Tstring = strcat(DeltaChar,char(404),num2str(iaux1));
                        case 11
                            Tstring = strcat(DeltaChar,'a_r',num2str(iaux1));
                        case 12
                            Tstring = strcat(DeltaChar,'a_i',num2str(iaux1));
                    end
                    SIndNome(k,1) = {Tstring};
                end
            end
        end
    end




    %% PlotResiduos
    function SIndNome = PlotResiduos (NS, IS, S, TipoMatrizJ_A, NBar, NGer, NTap, NTh, Nhvdc, NgerA, NgerE, BarCGer, BarGer, BarCTap, IndBar, FptGerA, FptGerE, Area)
        ii = 0;
        jj = 1;
        DeltaChar = char(916);
        BarCGerAux = 0;
        if (NS< 2)
            NS = 2;
        end
        if (NgerA>0)
            FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
            NgerAi = length(FptGerAi);
        end
        if (NgerE>0)
            FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
            NgerAi = length(FptGerAi);
            RefTh = unique(Area);
            NTh = size(RefTh,1);
        end
        SIndNome = cell(NS,2);
        for k = 1:NS
            i = IS(k);
            SIndNome(k,2) = {S(i)};
            if (TipoMatrizJ_A == 0)
                if i<= NBar
                    SIndNome(k,1) = {strcat(DeltaChar,'P_{',num2str(IndBar(i)),'}')};
                elseif i<=2*NBar
                    SIndNome(k,1) = {strcat(DeltaChar,'Q_{',num2str(IndBar(i-NBar)),'}')};
                elseif (i<=2*NBar+NGer)
                    if (BarCGerAux ~= BarCGer(i-2*NBar))
                        BarCGerAux = BarCGer(i-2*NBar);
                        SIndNome(k,1) = {strcat(DeltaChar,'V_{',num2str(IndBar(BarCGer(i-2*NBar))),'}')};
                        ContAuxBarGer = 1;
                    else
                        Aux = find (BarCGerAux == BarCGer);
                        SIndNome(k,1) = {strcat(DeltaChar,'Qg_{',num2str(IndBar(BarGer(Aux(ContAuxBarGer)))),'-',num2str(IndBar(BarGer(Aux(ContAuxBarGer+1)))),'}')};
                        ContAuxBarGer = ContAuxBarGer + 1;
                    end
                elseif (i<=2*NBar+NGer+NTap)
                    SIndNome(k,1) = {strcat(DeltaChar,'V_{',num2str(IndBar(BarCTap(i-2*NBar-NGer))),'}')};
                elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE)
                    ii = ii + 1;
                    SIndNome(k,1) = {strcat(DeltaChar,'PRes_{',num2str(IndBar(FptGerAi(ii))),'}')};
                    if (ii == NgerAi)
                        ii = 0;
                        jj = jj+1;
                        if(NgerE>0)
                            FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
                        else
                            FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
                        end
                        NgerAi = length(FptGerAi);
                    end
                elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE+NTh)
                    SIndNome(k,1) = {strcat(DeltaChar,'RefTh_{',num2str(IndBar(RefTh(i-(2*NBar+NGer+NTap+NgerA+NgerE)))),'}')};
                elseif (i<=2*NBar+NGer+NTap+NgerA+NgerE+NTh+Nhvdc*12)
                    iaux = i - (2*NBar+NGer+NTap+NgerA+NgerE+NTh);
                    iaux1 = floor(iaux/13)+1;
                    iaux2 = mod(iaux,12);
                    iaux2 = iaux2 + 12*(iaux2==0);
                    switch iaux2
                        case 1
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{1,',num2str(iaux1),'}');
                        case 2
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{2,',num2str(iaux1),'}');
                        case 3
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{3,',num2str(iaux1),'}');
                        case 4
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{4,',num2str(iaux1),'}');
                        case 5
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{5,',num2str(iaux1),'}');
                        case 6
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{6,',num2str(iaux1),'}');
                        case 7
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{7,',num2str(iaux1),'}');
                        case 8
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{8,',num2str(iaux1),'}');
                        case 9
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{{9,',num2str(iaux1),'}');
                        case 10
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{10,',num2str(iaux1),'}');
                        case 11
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{11,',num2str(iaux1),'}');
                        case 12
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{12,',num2str(iaux1),'}');
                    end
                    SIndNome(k,1) = {Tstring};
                end
            else
                if i<= NGer
                    if (BarCGerAux ~= BarCGer(i))
                        BarCGerAux = BarCGer(i);
                        SIndNome(k,1) = {strcat(DeltaChar,'V_{',num2str(IndBar(BarCGer(i))),'}')};
                        ContAuxBarGer = 1;
                    else
                        Aux = find (BarCGerAux == BarCGer);
                        SIndNome(k,1) = {strcat(DeltaChar,'Qg_{',num2str(IndBar(BarGer(Aux(ContAuxBarGer)))),'-',num2str(IndBar(BarGer(Aux(ContAuxBarGer+1)))),'}')};
                        ContAuxBarGer = ContAuxBarGer + 1;
                    end
                elseif (i<=NGer+NTap)
                    SIndNome(k,1) = {strcat(DeltaChar,'V_{',num2str(IndBar(BarCTap(i-NGer))),'}')};
                elseif (i<=NGer+NTap+NgerA+NgerE)
                    ii = ii + 1;
                    SIndNome(k,1) = {strcat(DeltaChar,'PRes_{',num2str(IndBar(FptGerAi(ii))),'}')};
                    if (ii == NgerAi)
                        ii = 0;
                        jj = jj+1;
                        if(NgerE>0)
                            FptGerAi = FptGerE(Area(FptGerE(:,1))==jj,1);
                        else
                            FptGerAi = FptGerA(Area(FptGerA(:,1))==jj,1);
                        end
                        NgerAi = length(FptGerAi);
                    end
                elseif (i<=NGer+NTap+NgerA+NgerE+NTh)
                    SIndNome(k,1) = {strcat(DeltaChar,'RefTh_{',num2str(IndBar(RefTh(i-(NGer+NTap+NgerA+NgerE)))),'}')};
                elseif (i<=NGer+NTap+NgerA+NgerE+NTh+Nhvdc*12)
                    iaux = i - (NGer+NTap+NgerA+NgerE+NTh);
                    iaux1 = floor(iaux/13)+1;
                    iaux2 = mod(iaux,12);
                    iaux2 = iaux2 + 12*(iaux2==0);
                    switch iaux2
                        case 1
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{1,',num2str(iaux1),'}');
                        case 2
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{2,',num2str(iaux1),'}');
                        case 3
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{3,',num2str(iaux1),'}');
                        case 4
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{4,',num2str(iaux1),'}');
                        case 5
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{5,',num2str(iaux1),'}');
                        case 6
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{6,',num2str(iaux1),'}');
                        case 7
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{7,',num2str(iaux1),'}');
                        case 8
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{8,',num2str(iaux1),'}');
                        case 9
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{{9,',num2str(iaux1),'}');
                        case 10
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{10,',num2str(iaux1),'}');
                        case 11
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{11,',num2str(iaux1),'}');
                        case 12
                            Tstring = strcat(DeltaChar,'Y_{HVDC}_{12,',num2str(iaux1),'}');
                    end
                    SIndNome(k,1) = {Tstring};
                end
            end
        end
    end
end