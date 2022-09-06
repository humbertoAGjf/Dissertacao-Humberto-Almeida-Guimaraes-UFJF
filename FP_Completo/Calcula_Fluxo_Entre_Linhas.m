function [Pkm, Pmk, Qkm, Qmk] = Calcula_Fluxo_Entre_Linhas(DE, PARA, V, Th, r, x, Tap, TapPh, BSh_Lin, IndBar)
Nlin = size(DE,1);
Pkm = zeros(Nlin,1);
Pmk = zeros(Nlin,1);
Qkm = zeros(Nlin,1);
Qmk = zeros(Nlin,1);



Ykm = 1./(r+1i*x);
Gkm = real(Ykm);
Bkm = imag(Ykm);

for i=1:Nlin
    de = find(DE(i)==IndBar);
    para  = find(PARA(i)==IndBar);
    Th_km = Th(de)-Th(para);
    Vk = V(de);
    Vm = V(para);
    gkm = Gkm(i);
    bkm = Bkm(i);
    bsh = BSh_Lin(i);
    a = Tap(i);
    FI_km = TapPh(i);
    Pkm(i) = (gkm*Vk^2*a^2-a*Vk*Vm*(gkm*cos(Th_km + FI_km) + bkm*sin(Th_km+FI_km)))*100;
    Pmk(i) = (gkm*Vm^2-a*Vm*Vk*(gkm*cos(Th_km + FI_km) - bkm*sin(Th_km+FI_km)))*100;
    Qkm(i) = (-(bkm+bsh)*Vk^2*a^2+a*Vk*Vm*(bkm*cos(Th_km+FI_km)-gkm*sin(Th_km+FI_km)))*100;
    Qmk(i) = (-(bkm+bsh)*Vm^2+a*Vm*Vk*(bkm*cos(Th_km+FI_km)+gkm*sin(Th_km+FI_km)))*100; 
end