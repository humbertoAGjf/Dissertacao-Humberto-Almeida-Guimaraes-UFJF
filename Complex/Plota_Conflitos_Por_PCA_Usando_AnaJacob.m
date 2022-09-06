%%  Função para plotar os resultados do PCA aplicado ao problema de conflito de controle no Fluxo de Potência

function Plota_Conflitos_Por_PCA_Usando_AnaJacob(PC,signals,S,iaptad,idptad,NBar,nogen,nbecer,nbussca,notap,nfrom,nto,ircb,icb,noint,MatrizJcs)

%idvar = [ 'CRT '; 'CER '; 'SCA '; 'CAP '; 'CSC '; 'TAP '; 'DC1 '; 'DC2 '; 'DC3 '; 'DC4 '; 'DC5 '; 'DC6 '; 'DC7 '; 'DC8 '; 'DC9 '; 'DC10'; 'DC11'; 'DC12'; 'MI1 '; 'MI2 ' ];
idvar = [ 'Q_{G'; 'CER '; 'SCA '; 'CAP '; 'CSC '; 'a_{ '; 'DC1 '; 'DC2 '; 'DC3 '; 'DC4 '; 'DC5 '; 'DC6 '; 'DC7 '; 'DC8 '; 'DC9 '; 'DC10'; 'DC11'; 'DC12'; 'MI1 '; 'MI2 ' ];
Smin = (1/10)*sum(S)/length(S); % Valor mínimo de V que será plotado
SM = 10*sum(abs(signals(1,:)))/length(signals(1,:)); % Valor minimo de Signals que será plotado no gráfico de V
SMA = 1*sum(abs(PC(:,1)))/length(PC(:,1));   %0.001
DeltaChar = char(916);
Th = char(952);
RightArrow = char(8594);
NumV = sum(S>Smin);
%% PLOTS PARA 1PC
if S(1)>Smin
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS EQUAÇÕES DE RESÍDUO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for j=1:NumV
        figure;
        IndPsignals = find(abs(signals(j,:))>SM);
        Psignals = [signals(j,IndPsignals)' IndPsignals'];
        [~, indSort] = sort(abs(Psignals(:,1)),'descend');
        Psignals = Psignals(indSort,:);
        NPontos = length(Psignals(:,1));
        catArray = strings([NPontos,1]);
        plot(Psignals(:,1),zeros(NPontos,1),'b.','markersize',15);
        for k=1:NPontos
            i = Psignals(k,2);
            if (abs(signals(j,i))>SM)
                if (MatrizJcs == 0)
                    nvarc = rem(i,2);
                    if ( nvarc ~= 0 )
                        nvarc = ((i + 1)/2) - NBar;
                    else
                        nvarc = (i/2) - NBar;
                    end
                    if ( nvarc > 0 )
                        anacon  = iaptad(nvarc);
                        nomecon = char(idvar(idptad(nvarc),:));
                        if ( idptad(nvarc) == 1 )
                            nf = ircb(anacon);
                            nt = nogen(icb(anacon));
                            nf = noint(nf);
                            nt = noint(nt);
                            Name = strcat(DeltaChar,'V_{',num2str(nf),'}');
                            text(signals(j,i), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                            catArray(k,1) = Name;
                        elseif ( idptad(nvarc) == 2 )
                            nf = nbecer(anacon);
                            nf = noint(nf);
                            Name = strcat(DeltaChar,'V^{',num2str(nf),'}');
                            text(signals(j,i), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                            catArray(k,1) = Name;
                        elseif ( idptad(nvarc) == 3 )
                            nf = nbussca(anacon);
                            nf = noint(nf);
                            Name = strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt));
                            text(signals(j,i), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                            catArray(k,1) = Name;
                        elseif ( idptad(nvarc) == 6 )
                            nl = notap(anacon);
                            nf = nfrom(nl);
                            nt = nto(nl);
                            nf = noint(nf);
                            nt = noint(nt);
                            Name = strcat(DeltaChar,'V^{',num2str(nt),'}');
                            text(signals(j,i), -0.15,Name , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                            catArray(k,1) = Name;
                        else
                            Name = strcat(DeltaChar, nomecon,'-',nvarc);
                            text(signals(j,i), -0.15,Name , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                            catArray(k,1) = Name;
                        end
                    else
                        nvarc = rem(i,2);
                        if ( nvarc ~= 0 )
                            nvarc = ((i + 1)/2);
                            nomecon = Th;
                        else
                            nvarc = (i/2);
                            nomecon = 'V';
                        end
                        nvarc = noint(nvarc);                
                        Name = strcat(DeltaChar, nomecon,'_{',num2str(nvarc),'}');
                        text(signals(j,i), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    end  
                else

                    nvarc = rem(i,2);
                    if ( nvarc ~= 0 )
                        nvarc = ((i + 1)/2);
                    else
                        nvarc = (i/2);
                    end
                    anacon  = iaptad(nvarc);
                    nomecon = char(idvar(idptad(nvarc),:)); % 
                    if ( idptad(nvarc) == 1 ) % CRT - Gerador Controlando tensão remota
                        nf = ircb(anacon);
                        nt = nogen(icb(anacon));
                        nf = noint(nf);
                        nt = noint(nt);
                        Name = strcat(DeltaChar,'V^{',num2str(nf),'}');
                        text(signals(j,i), -0.15,Name , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    elseif ( idptad(nvarc) == 2 )
                        nf = nbecer(anacon);
                        nf = noint(nf);
                        Name = strcat(DeltaChar,'V^{',num2str(nf),'}');
                        text(signals(j,i), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    elseif ( idptad(nvarc) == 3 )
                        nf = nbussca(anacon);
                        nf = noint(nf);
                        Name = strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt));
                        text(signals(j,i), -0.15,Name , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    elseif ( idptad(nvarc) == 6 )
                        nl = notap(anacon);
                        nf = nfrom(nl);
                        nt = nto(nl);
                        nf = noint(nf);
                        nt = noint(nt);
                        Name = strcat(DeltaChar,'V^{',num2str(nt),'}');
                        text(signals(j,i), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    else
                        Name = strcat(DeltaChar, nomecon,nvarc);
                        text(signals(j,i), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    end
                end
            end            
        end

        Xmax = max(signals(j,:));
        Xmin = min(signals(j,:));
        ylim([-1, 1]);
        xlim([Xmin*(0.9+0.2*(Xmin<0)), Xmax*(0.9+0.2*(Xmax>0))]);
        grid on;
        xlabel(strcat('PC',{' '},num2str(j)))
        title(strcat('Controlled Variables Projected Onto The',{' '},num2str(j),'\circ PC'))
        xtickangle(0)
        figure;
        catStrArray = categorical(catArray,catArray);
        bar(catStrArray,Psignals(:,1),0.4)
        title(strcat('Controlled Variables Projected Onto The',{' '},num2str(j),'\circ PC'))
        xtickangle(0)
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS AMOSTRAS - VARIÁVEIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    for j=1:NumV
        figure;
        PPC = [];
        for i=1:length(PC(:,1))
            if (abs(PC(i,j))>SMA)
                PPC = [PPC; [PC(i,j) , i]];
            end
        end
        [~, indSort] = sort(abs(PPC(:,1)),'descend');
        PPC = PPC(indSort,:);
        NPontos = length(PPC(:,1));
        catArray = strings([NPontos,1]);
        plot(PPC(:,1),zeros(NPontos,1),'b.','markersize',15);
        for k=1:NPontos
            i = PPC(k,2);
            if (MatrizJcs == 0)
                nvarc = rem(i,2);
                nomecon = char(idvar(idptad(nvarc),:)); % 
                if ( nvarc ~= 0 )
                    nvarc = ((i + 1)/2) - NBar;
                else
                    nvarc = (i/2) - NBar;
                end
                if ( nvarc > 0 )
                    anacon  = iaptad(nvarc);
                    if ( idptad(nvarc) == 1 )
                        nf = ircb(anacon);
                        nt = nogen(icb(anacon));
                        nf = noint(nf);
                        nt = noint(nt);
                        Name = strcat(DeltaChar, 'Q_{G',num2str(nt),'}');
                        text(PC(i,j), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    elseif ( idptad(nvarc) == 2 )
                        nf = nbecer(anacon);
                        nf = noint(nf);
                        Name = strcat(DeltaChar, 'Q_{s',num2str(nf),'}');
                        text(PC(i,j), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    elseif ( idptad(nvarc) == 3 )
                        nf = nbussca(anacon);
                        nf = noint(nf);
                        Name = strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt));
                        text(PC(i,j), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    elseif ( idptad(nvarc) == 6 )
                        nl = notap(anacon);
                        nf = nfrom(nl);
                        nt = nto(nl);
                        nf = noint(nf);
                        nt = noint(nt);
                        Name = strcat(DeltaChar, 'a_{ ',num2str(nf),'-',num2str(nt),'}');
                        text(PC(i,j), -0.15,Name , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    else
                        Name = strcat(DeltaChar, nomecon, nvarc);
                        text(PC(i,j), -0.15,Name , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    end
                else
                    nvarc = rem(i,2);
                    if ( nvarc ~= 0 )
                        nvarc = ((i + 1)/2);
                        nomecon = Th;
                    else
                        nvarc = (i/2);
                        nomecon = 'V';
                    end
                    nvarc = noint(nvarc); 
                    Name = strcat(DeltaChar, nomecon,'_{',num2str(nvarc),'}');
                    text(PC(i,j), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                    catArray(k,1) = Name;
                end  
            else

                nvarc = rem(i,2);
                if ( nvarc ~= 0 )
                    nvarc = ((i + 1)/2);
                else
                    nvarc = (i/2);
                end
                anacon  = iaptad(nvarc);
                nomecon = char(idvar(idptad(nvarc),:)); % 
                if ( idptad(nvarc) == 1 ) % CRT - Gerador Controlando tensão remota
                    nf = ircb(anacon);
                    nt = nogen(icb(anacon));
                    nf = noint(nf);
                    nt = noint(nt);
                    Name = strcat(DeltaChar, 'Q_{G', num2str(nt),'}');
                    if(~sum(Name == catArray))
                        text(PC(i,j), -0.15,Name , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    end
                elseif ( idptad(nvarc) == 2 )
                    nf = nbecer(anacon);
                    nf = noint(nf);
                    Name = strcat(DeltaChar, 'Q_{s',num2str(nf),'}');
                    if(~sum(Name == catArray))
                        text(PC(i,j), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    end
                elseif ( idptad(nvarc) == 3 )
                    nf = nbussca(anacon);
                    nf = noint(nf);
                    Name = strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt));
                    if(~sum(Name == catArray))
                        text(PC(i,j), -0.15,Name , 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    end
                elseif ( idptad(nvarc) == 6 )
                    nl = notap(anacon);
                    nf = nfrom(nl);
                    nt = nto(nl);
                    nf = noint(nf);
                    nt = noint(nt);
                    Name = strcat(DeltaChar, 'a_{ ',num2str(nf),'-',num2str(nt),'}');
                    if(~sum(Name == catArray))
                        text(PC(i,j), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom','FontSize', 11)
                        catArray(k,1) = Name;
                    end
                else
                    Name = strcat(DeltaChar, nomecon,nvarc);
                    if(~sum(Name == catArray))
                        text(PC(i,j), -0.15, Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                        catArray(k,1) = Name;
                    end
                end
            end       
        end
        IndNull = (catArray ~= '');
        catArray = catArray(IndNull);
        Xmax = max(PPC(:,1));
        Xmin = min(PPC(:,1)); 
        ylim([-1, 1]);
        xlim([Xmin*(0.9+0.2*(Xmin<0)), Xmax*(0.9+0.2*(Xmax>0))]);
        grid on;
        xlabel(strcat('Effect on',{' '},num2str(j),'\circ PC'))
        title(strcat('Influence of The Control Variables Upon The', {' '},num2str(j),'\circ PC'))
        xtickangle(0)
        figure;
        catStrArray = categorical(catArray,catArray);
        bar(catStrArray,PPC(IndNull,1),0.4)
        title(strcat('Influence of The Control Variables Upon The', {' '},num2str(j),'\circ PC'))
        xlabel(strcat('Effect on',{' '},num2str(j),'\circ PC'))
        xtickangle(0)
        

%         close all
%         PPC = PPC(IndNull,1);
%         IndNull = (1:4);
%         PPC = PPC(IndNull);
%         %PPC(3:4) = 0
%         catArray = catArray(IndNull);
%         catStrArray = categorical(catArray,catArray);
%         EV = [  0       0       0       0   
%                 1 -0.9735  0.0243  0.0017]';
%         PPC = [PPC zeros(length(PPC),1)];    
%         figure;
%         bar(catStrArray,PPC,0.9,'k')
%         title(strcat('Control Variables Vs Mode-shape'))
%         ylabel(strcat('Effect on',{' '},num2str(j),'\circ PC'))
%         xtickangle(0)
%         yyaxis right
%         bar(EV,0.9)
%         ylabel(strcat('Mode-shape'))
    end
    
    
    
    

end

% 
% %% PLOTS Para 2 PCs
% if V(2)>Vmin
%     for iii=1:NumV-1
%         for jjj=iii+1:NumV
%             figure;
%             ii = 0;
%             for i=1:length(signals(1,:))
%                 if abs(signals(iii,i))>SM || abs(signals(jjj,i))>SM
%                     plot(signals(iii,i),signals(jjj,i),'b.','markersize',15);
%                     if (MatrizJcs == 0)
%                         nvarc = rem(i,2);
%                         if ( nvarc ~= 0 )
%                             nvarc = ((i + 1)/2) - NBar;
%                             ii = 1;
%                         else
%                             nvarc = (i/2) - NBar;
%                             ii = 2;
%                         end
%                         if ( nvarc > 0 )
%                             anacon  = iaptad(nvarc);
%                             nomecon = char(idvar(idptad(nvarc),:));
%                             if ( idptad(nvarc) == 1 )
%                                 nf = ircb(anacon);
%                                 nt = nogen(icb(anacon));
%                                 nf = noint(nf);
%                                 nt = noint(nt);
%                                 text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,RightArrow ,num2str(nt),RightArrow ,num2str(nf),'}'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                             elseif ( idptad(nvarc) == 2 )
%                                 nf = nbecer(anacon);
%                                 nf = noint(nf);
%                                 text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,num2str(nf)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                             elseif ( idptad(nvarc) == 3 )
%                                 nf = nbussca(anacon);
%                                 nf = noint(nf);
%                                 text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                             elseif ( idptad(nvarc) == 6 )
%                                 nl = notap(anacon);
%                                 nf = nfrom(nl);
%                                 nt = nto(nl);
%                                 nf = noint(nf);
%                                 nt = noint(nt);
%                                 text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt),'}'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                             else
%                                 text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,nvarc), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                             end
%                         else
%                             nvarc = rem(i,2);
%                             if ( nvarc ~= 0 )
%                                 nvarc = ((i + 1)/2);
%                                 nomecon = 'ANG ';
%                             else
%                                 nvarc = (i/2);
%                                 nomecon = 'TEN ';
%                             end
%                             nvarc = noint(nvarc);                
%                             text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,num2str(nvarc)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                         end  
%                     else
%                         nvarc = rem(i,2);
%                         if ( nvarc ~= 0 )
%                             nvarc = ((i + 1)/2);
%                             ii = 1;
%                         else
%                             nvarc = (i/2);
%                             ii = 2;
%                         end
%                         anacon  = iaptad(nvarc);
%                         nomecon = char(idvar(idptad(nvarc),:));
%                         if ( idptad(nvarc) == 1 )
%                             nf = ircb(anacon);
%                             nt = nogen(icb(anacon));
%                             nf = noint(nf);
%                             nt = noint(nt);
%                             text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,num2str(nt),RightArrow ,num2str(nf),'}'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                         elseif ( idptad(nvarc) == 2 )
%                             nf = nbecer(anacon);
%                             nf = noint(nf);
%                             text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,num2str(nf)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                         elseif ( idptad(nvarc) == 3 )
%                             nf = nbussca(anacon);
%                             nf = noint(nf);
%                             text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                         elseif ( idptad(nvarc) == 6 )
%                             nl = notap(anacon);
%                             nf = nfrom(nl);
%                             nt = nto(nl);
%                             nf = noint(nf);
%                             nt = noint(nt);
%                             text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt),'}'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                         else
%                             text(signals(iii,i),signals(jjj,i), strcat(DeltaChar, nomecon,nvarc), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
%                         end
%                     end
%                     hold on;
%                 end
%             end
%             Xmax = max(signals(iii,:));
%             Xmin = min(signals(iii,:));
%             Ymax = max(signals(jjj,:));
%             Ymin = min(signals(jjj,:));
%             ylim([Ymin*(0.9+0.2*(Ymin<0)), Ymax*(0.9+0.2*(Ymax>0))]);
%             xlim([Xmin*(0.9+0.2*(Xmin<0)), Xmax*(0.9+0.2*(Xmax>0))]);
%             grid on;
%             xlabel(strcat('PC',{' '},num2str(iii)))
%             ylabel(strcat('PC',{' '},num2str(jjj)))
%             title(strcat('Projected Control Variables Onto the',{' '},num2str(iii),'\circ and the',{' '},num2str(jjj),'\circ PC'))
%             xtickangle(0)
% 
%         end
%     end
% end


%% PLOTS Para 3 PCs
if S(3)>Smin
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOTA EM RELAÇÃO AS EQUAÇÕES DE RESÍDUO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure;
    ii = 0; 
    DSignals = signals(1,:).^2 + signals(2,:).^2 + signals(3,:).^2;
    IndPsignals = find(DSignals>SM^2);
    plot3(signals(1,IndPsignals), signals(2,IndPsignals), signals(3,IndPsignals),'b.','markersize',15);
    NPontos = length(IndPsignals);
    for k=1:NPontos
        i = IndPsignals(k);
        if (MatrizJcs == 0)
            nvarc = rem(i,2);
            if ( nvarc ~= 0 )
                nvarc = ((i + 1)/2) - NBar;
                ii = 1;
            else
                nvarc = (i/2) - NBar;
                ii = 2;
            end
            if ( nvarc > 0 )
                anacon  = iaptad(nvarc);
                nomecon = char(idvar(idptad(nvarc),:));
                if ( idptad(nvarc) == 1 )
                    nf = ircb(anacon);
                    nt = nogen(icb(anacon));
                    nf = noint(nf);
                    nt = noint(nt);
                    Name = strcat(DeltaChar,'V_{',num2str(nf),'}');
                    text(signals(1,i),signals(2,i),signals(3,i),Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                elseif ( idptad(nvarc) == 2 )
                    nf = nbecer(anacon);
                    nf = noint(nf);
                    Name = strcat(DeltaChar,'V^{',num2str(nf),'}');
                    text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                elseif ( idptad(nvarc) == 3 )
                    nf = nbussca(anacon);
                    nf = noint(nf);
                    Name = strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt));
                    text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                elseif ( idptad(nvarc) == 6 )
                    nl = notap(anacon);
                    nf = nfrom(nl);
                    nt = nto(nl);
                    nf = noint(nf);
                    nt = noint(nt);
                    Name = strcat(DeltaChar,'V^{',num2str(nt),'}');
                    text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                else
                    Name = strcat(DeltaChar, nomecon,'-',nvarc);
                    text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
                end
            else
                nvarc = rem(i,2);
                if ( nvarc ~= 0 )
                    nvarc = ((i + 1)/2);
                    nomecon = 'ANG ';
                else
                    nvarc = (i/2);
                    nomecon = 'TEN ';
                end
                nvarc = noint(nvarc);         
                Name = strcat(DeltaChar, nomecon,'_{',num2str(nvarc),'}');
                text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
            end  
        else
            nvarc = rem(i,2);
            if ( nvarc ~= 0 )
                nvarc = ((i + 1)/2);
                ii = 1;
            else
                nvarc = (i/2);
                ii = 2;
            end
            anacon  = iaptad(nvarc);
            nomecon = char(idvar(idptad(nvarc),:));
            if ( idptad(nvarc) == 1 )
                nf = ircb(anacon);
                nt = nogen(icb(anacon));
                nf = noint(nf);
                nt = noint(nt);
                Name = strcat(DeltaChar,'V^{',num2str(nf),'}');
                text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
            elseif ( idptad(nvarc) == 2 )
                nf = nbecer(anacon);
                nf = noint(nf);
                Name = strcat(DeltaChar,'V^{',num2str(nf),'}');
                text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
            elseif ( idptad(nvarc) == 3 )
                nf = nbussca(anacon);
                nf = noint(nf);
                Name = strcat(DeltaChar, nomecon,num2str(nf),RightArrow ,num2str(nt));
                text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
            elseif ( idptad(nvarc) == 6 )
                nl = notap(anacon);
                nf = nfrom(nl);
                nt = nto(nl);
                nf = noint(nf);
                nt = noint(nt);
                Name = strcat(DeltaChar,'V^{',num2str(nt),'}');
                text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
            else
                Name = strcat(DeltaChar, nomecon,nvarc);
                text(signals(1,i),signals(2,i),signals(3,i), Name, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
            end
        end
        hold on;
  
    end
    Xmax = max(signals(1,:));
    Xmin = min(signals(1,:));
    Ymax = max(signals(2,:));
    Ymin = min(signals(2,:));
    Zmax = max(signals(3,:));
    Zmin = min(signals(3,:));
    xlim([Xmin*(0.9+0.2*(Xmin<0)), Xmax*(0.9+0.2*(Xmax>0))]);
    ylim([Ymin*(0.9+0.2*(Ymin<0)), Ymax*(0.9+0.2*(Ymax>0))]);
    zlim([Zmin*(0.9+0.2*(Zmin<0)), Zmax*(0.9+0.2*(Zmax>0))]);
    grid on;
    xlabel('1\circ PC','fontweight','bold')
    ylabel('2\circ PC','fontweight','bold')
    zlabel('3\circ PC','fontweight','bold')
    title('Controlled Variables Projected Onto The First Three PCs')
    xtickangle(0)
    
    % Printo os planos no eixo 3d
    k = 1;
    xp = (Xmax-Xmin)/k;
    yp = (Ymax-Ymin)/k;
    zp = (Zmax-Zmin)/k;
    x = Xmin:xp:Xmax;
    y = Ymin:yp:Ymax;
    z = Zmin:zp:Zmax;
    X = repmat(x,k+1,1);
    Y = repmat(y',1,k+1);
    Z = 0*X;
    hold on
    surf(X,Y,Z,'FaceAlpha',0.1,'EdgeColor','none','FaceColor',[1, 0, 0]);
    Z = repmat(z',1,k+1);
    Y = 0*X;
    hold on
    surf(X,Y,Z,'FaceAlpha',0.1,'EdgeColor','none','FaceColor',[1, 0.5, 0]);
    Y = repmat(y,k+1,1);
    X = 0*Y;
    hold on
    surf(X,Y,Z,'FaceAlpha',0.1,'EdgeColor','none','FaceColor',[1, 0, 0.5]);

end

%% Plota o Gráfico com todos os spectros.
figure

Vaux = S;
S(S<Smin) = [];
if isempty(S)
    S = Vaux;
    bar(S)
    xlabel('PC''s'), ylabel('Eigenvalue')
    title('Espectro dos PCs')
    ylim([0,1.2*max(S)])
    xtickangle(0)
else
    bar(S)
    xlabel('PC''s'), ylabel('Eigenvalue')
    title(strcat('Eigenspectrum of Eigenvalues Bigger than', {' '} ,num2str(Smin)))
    set(gca,'YScale','log')
    ylim([1,10*max(S)])
    xtickangle(0)
end    





