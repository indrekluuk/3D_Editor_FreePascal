uses mootor3d,wincrt,graph,winmouse,varia;


const
   koordinaadid:array[1..12] of integer = (11,31,51,
                                           89,109,129,
                                           167,187,207,
                                           245,265,285);

   varv:array[1..5] of byte=(15,16,23,12,3);
   kaust='';
   objektikaust=kaust + 'objektid\';

type
   check = record
           nimi:string[50];
           on:byte;
           end;

   var gd,gm,i,j:integer;
       obuffer:p_objektibuffer3D;
       ZBuffer:p_ZBuffer3D;
       kujund,teljed:objekt3D;
       ekraan:pointer;
       nupp:char;
       Valitud_nelinurk:integer;
       Valitud_koordinaat:integer;
       valikud:array[1..2] of check;
       hx,hy,hx_prev,hy_prev,state,state_prev,x,y,z:longint;
       a,b,c:single;

procedure kirjuta_koordinaadid;
   var num:string;
 begin
 setfillstyle(1,varv[2]);
 for i:=1 to 12 do
   bar(550,koordinaadid[i],620,koordinaadid[i]+15);
 if kujund.nelinurkasid=0 then exit;
 setfillstyle(1,varv[5]);
 setcolor(varv[1]);
 for i:=1 to 12 do
   begin
   if valitud_koordinaat=i then bar(550,koordinaadid[i],620,koordinaadid[i]+15);
   if (i+2) mod 3 = 0 then
     begin
       str(kujund.nelinurk[Valitud_nelinurk-1].x[(i-1) div 3],num);
       outtextxy(555,koordinaadid[i]+5,num);
     end;
   if (i+1) mod 3 = 0 then
     begin
       str(kujund.nelinurk[Valitud_nelinurk-1].y[(i-1) div 3],num);
       outtextxy(555,koordinaadid[i]+5,num);
     end;
   if (i) mod 3 = 0 then
     begin
       str(kujund.nelinurk[Valitud_nelinurk-1].z[(i-1) div 3],num);
       outtextxy(555,koordinaadid[i]+5,num);
     end;
   end;
 end;

procedure nelinurkade_nimekiri;
   const ulemine:integer=0;
   var nahtaval,max_nahtaval:integer;
       num:string;
 begin
 setfillstyle(1,varv[2]);
 bar(430,10,510,260);
 if kujund.nelinurkasid=0 then exit;
 max_nahtaval:=25;
 if Valitud_nelinurk<=ulemine then ulemine:=Valitud_nelinurk-1;
 if Valitud_nelinurk>ulemine+max_nahtaval then ulemine:=Valitud_nelinurk-max_nahtaval;

 if kujund.nelinurkasid-ulemine>max_nahtaval then nahtaval:=max_nahtaval
   else nahtaval:=kujund.nelinurkasid-ulemine;
 for i:=1 to nahtaval do
   begin
   if Valitud_nelinurk=ulemine+i then setcolor(varv[4]) else setcolor(varv[1]);
   str(ulemine+i,num);
   outtextxy(440,2+10*i,num);
   end;
 end;

procedure varvijoon;
   var i,j:integer;
       num:string;
 begin
 setfillstyle(1,varv[2]);
 if kujund.nelinurkasid=0 then
   begin
     bar(430,285,510,300);
     bar(519,9,531,301);
     setcolor(varv[2]);
     rectangle(518,149,532,161);
     exit;
   end;
 bar(430,285,510,300);
 setcolor(varv[1]);
 str(kujund.nelinurk[valitud_nelinurk-1].varv,num);
 outtextxy(480,290,num);
 for i:=1 to 29 do
   begin
     j:=kujund.nelinurk[valitud_nelinurk-1].varv-15+i;
     if j<0 then j:=j+256;
     if j>255 then j:=j-256;
     setfillstyle(1,j);
     bar(520,i*10,530,(i+1)*10);
   end;
 setcolor(varv[1]);
 rectangle(519,150,531,160);
 setcolor(varv[2]);
 rectangle(518,149,532,161);
 end;

procedure Lisa_nelinurk;
   var p_nelinurk:^nelinurk3D;
       i:integer;
 begin
   p_nelinurk:=kujund.nelinurk;
   inc(kujund.nelinurkasid);
   GetMem(kujund.nelinurk,sizeof(nelinurk3D)*kujund.nelinurkasid);
   for i:=0 to kujund.nelinurkasid-2 do
     kujund.nelinurk[i]:=p_nelinurk[i];
   if kujund.nelinurkasid>1 then kujund.nelinurk[kujund.nelinurkasid-1]:=kujund.nelinurk[valitud_nelinurk-1] else
     begin
     for i:=0 to 3 do
       begin
         kujund.nelinurk[kujund.nelinurkasid-1].x[i]:=0;
         kujund.nelinurk[kujund.nelinurkasid-1].y[i]:=0;
         kujund.nelinurk[kujund.nelinurkasid-1].z[i]:=0;
       end;
     kujund.nelinurk[kujund.nelinurkasid-1].varv:=50;
     end;
   FreeMem(p_nelinurk,SizeOf(nelinurk3D)*(kujund.nelinurkasid-1));
   Valitud_nelinurk:=kujund.nelinurkasid;
   Nelinurkade_nimekiri;
   kirjuta_koordinaadid;
   varvijoon;
   arvuta_ZBuffri_suurus3D(obuffer,ZBuffer);
 end;

procedure Eemalda_nelinurk;
   var p_nelinurk:^nelinurk3D;
       i,j:integer;
 begin
   if kujund.nelinurkasid=0 then exit;
   p_nelinurk:=kujund.nelinurk;
   dec(kujund.nelinurkasid);
   GetMem(kujund.nelinurk,sizeof(nelinurk3D)*kujund.nelinurkasid);
   j:=0;
   for i:=0 to kujund.nelinurkasid-1 do
     begin
       if Valitud_nelinurk-1=i then j:=1;
       kujund.nelinurk[i]:=p_nelinurk[i+j];
     end;
   FreeMem(p_nelinurk,SizeOf(nelinurk3D)*(kujund.nelinurkasid+1));
   if Valitud_nelinurk>kujund.nelinurkasid then Valitud_nelinurk:=kujund.nelinurkasid;
   Nelinurkade_nimekiri;
   kirjuta_koordinaadid;
   varvijoon;
   arvuta_ZBuffri_suurus3D(obuffer,ZBuffer);
 end;

procedure koordinaadi_muutmine;
 begin
 if kujund.nelinurkasid=0 then exit;
 setfillstyle(1,varv[5]);
 setcolor(varv[1]);
 case (valitud_koordinaat-1) mod 3 of
   0:Kirjuta_num(555,koordinaadid[valitud_koordinaat]+5,6,kujund.nelinurk[valitud_nelinurk-1].x[(valitud_koordinaat-1)div 3]);
   1:Kirjuta_num(555,koordinaadid[valitud_koordinaat]+5,6,kujund.nelinurk[valitud_nelinurk-1].y[(valitud_koordinaat-1)div 3]);
   2:Kirjuta_num(555,koordinaadid[valitud_koordinaat]+5,6,kujund.nelinurk[valitud_nelinurk-1].z[(valitud_koordinaat-1)div 3]);
   end;
 end;

procedure liida(s:integer);
   var arv:^longint;
       num:string;
 begin
 if kujund.nelinurkasid=0 then exit;
 case (valitud_koordinaat-1) mod 3 of
   0:arv:=@(kujund.nelinurk[valitud_nelinurk-1].x[(valitud_koordinaat-1)div 3]);
   1:arv:=@(kujund.nelinurk[valitud_nelinurk-1].y[(valitud_koordinaat-1)div 3]);
   2:arv:=@(kujund.nelinurk[valitud_nelinurk-1].z[(valitud_koordinaat-1)div 3]);
   end;
 if (s<0) and (arv^<=-99999) then exit;
 if (s>0) and (arv^>=999999) then exit;
 inc(arv^,s);
 kirjuta_koordinaadid;
 end;

procedure algvaartusta;
 begin
 obuffer:=nil;
 ekraan:=nil;
 ZBuffer:=nil;
 kujund.nelinurkasid:=0;
 kujund.nelinurk:=nil;
 kujund.objektisid:=0;
 kujund.objekt:=nil;
 kujund.KasutatudObjektisid:=0;
 kujund.ErinevaidOlekuid:=0;
 kujund.AktiivneOlek:=nil;
 kujund.Olek:=nil;
 Valitud_nelinurk:=1;
 Valitud_koordinaat:=1;
 valikud[1].nimi:='(o)bjekti vaatamine';
 valikud[1].on:=1;
 valikud[2].nimi:='(k)oordinaat teljed';
 valikud[2].on:=0;
 x:=0;
 y:=0;
 z:=0;
 a:=0;
 b:=0;
 c:=0;
 end;

procedure vaartusta_teljed;
   const uhikuid=25;
   var i,j,k,pikkus:integer;
       p_nelinurk:^nelinurk3D;
 begin
 pikkus:=2*uhikuid;
 Loe_objekt3D(teljed,kaust + 'telg.o3d');
 p_nelinurk:=teljed.nelinurk;
 getmem(teljed.nelinurk,sizeof(nelinurk3D)*pikkus*6);
 teljed.nelinurkasid:=pikkus*6;
 for j:=0 to 1 do
   for i:=0 to pikkus-1 do
     begin
     teljed.nelinurk[i+j*pikkus]:=p_nelinurk[j+(i+uhikuid mod 2) mod 2 * 6];
     teljed.nelinurk[i+j*pikkus+pikkus*2]:=p_nelinurk[j+2+(i+uhikuid mod 2) mod 2 * 6];
     teljed.nelinurk[i+j*pikkus+pikkus*4]:=p_nelinurk[j+4+(i+uhikuid mod 2) mod 2 * 6];
     for k:=0 to 3 do
       begin
       inc(teljed.nelinurk[i+j*pikkus].x[k],(i-uhikuid)*100-(i+uhikuid mod 2) mod 2 * 100);
       inc(teljed.nelinurk[i+j*pikkus+pikkus*2].y[k],(i-uhikuid)*100-(i+uhikuid mod 2) mod 2 * 100);
       inc(teljed.nelinurk[i+j*pikkus+pikkus*4].z[k],(i-uhikuid)*100-(i+uhikuid mod 2) mod 2 * 100);
       end;
     end;
 freemem(p_nelinurk,sizeof(nelinurk3D)*12);
 end;


procedure kirjuta_valikud;
   const algus_x=470;algus_y=310;
   var i:integer;
 begin
 setfillstyle(1,varv[2]);
 setcolor(varv[1]);
 for i:=1 to 2 do
   begin
   bar(algus_x,algus_y+(i-1)*20,algus_x+10,algus_y+10+(i-1)*20);
   if valikud[i].on=1 then circle(algus_x+5,algus_y+5+(i-1)*20,3);
   outtextxy(algus_x+15,algus_y+2+(i-1)*20,valikud[i].nimi);
   end;
 end;

procedure Telgedemuutmine;
 begin
 if valikud[2].on=1 then
   begin
   valikud[2].on:=0;
   kustuta_objekt3D(teljed,obuffer);
   arvuta_ZBuffri_suurus3D(obuffer,ZBuffer);
   end else
   begin
   valikud[2].on:=1;
   Lisa_objekt3D(teljed,0,0,0,0,0,0,obuffer);
   arvuta_ZBuffri_suurus3D(obuffer,ZBuffer);
   end;
 kirjuta_valikud;
 end;

procedure Pilt_ekraanile;
 begin
 taidaZBuffer3D(obuffer,ZBuffer,x,y,z,a,b,c);
 sorteeri_ZBuffer3D(ZBuffer);
 joonista_pilt3D(ZBuffer,ekraan,1000,1000,varv[2]);
 putimage(1,1,ekraan^,normalput);
 end;

procedure Enda_koordinaadid;
 begin
 setfillstyle(1,varv[2]);
 bar(20,310,100,325);
 bar(120,310,200,325);
 bar(220,310,300,325);
 bar(320,310,350,325);
 bar(370,310,400,325);
 setcolor(varv[1]);
 outtextxy(10,314,'X');
 outtextxy(110,314,'Y');
 outtextxy(210,314,'Z');
 outtextxy(310,314,'a');
 outtextxy(360,314,'b');
 outtextxy(24,314,sona(x));
 outtextxy(124,314,sona(y));
 outtextxy(224,314,sona(z));
 outtextxy(324,314,sona(round(a/(2*Pi)*360)));
 outtextxy(374,314,sona(round(b/(2*Pi)*360)));
 end;

procedure Salvesta;
   var fnimi:string;
       f:file;
       i,j:longint;
 begin
 fnimi:='';
 setfillstyle(1,varv[3]);
 setcolor(varv[1]);
 bar(100,100,340,150);
 outtextxy(110,110,'Faili nimi kuhu salvestada.');
 setfillstyle(1,varv[2]);
 bar(110,125,330,140);
 kirjuta(114,129,25,fnimi);
 fnimi:=fnimi+'.o3d';
 assign(f,objektikaust+fnimi);
 rewrite(f,1);
 BlockWrite(f,kujund.Nelinurkasid,SizeOf(kujund.Nelinurkasid));
 for i:=1 to kujund.Nelinurkasid do
   begin
   for j:=0 to 3 do BlockWrite(f,kujund.Nelinurk[i-1].x[j],SizeOf(kujund.Nelinurk[i-1].x[j]));
   for j:=0 to 3 do BlockWrite(f,kujund.Nelinurk[i-1].y[j],SizeOf(kujund.Nelinurk[i-1].y[j]));
   for j:=0 to 3 do BlockWrite(f,kujund.Nelinurk[i-1].z[j],SizeOf(kujund.Nelinurk[i-1].z[j]));
   BlockWrite(f,kujund.Nelinurk[i-1].varv,SizeOf(kujund.Nelinurk[i-1].varv));
   end;
 i:=0;
 BlockWrite(f,i,2);
 BlockWrite(f,i,2);
 BlockWrite(f,i,2);
 close(f);
 end;

procedure Laadi;
   var fnimi:string;
       f:file;
 begin
 fnimi:='';
 setfillstyle(1,varv[3]);
 setcolor(varv[1]);
 bar(100,100,340,150);
 outtextxy(110,110,'Faili nimi kust lugeda.');
 setfillstyle(1,varv[2]);
 bar(110,125,330,140);
 kirjuta(114,129,25,fnimi);
 if fnimi='' then exit;
 fnimi:=fnimi+'.o3d';
 assign(f,objektikaust+fnimi);
 {$i-}
 reset(f,1);
 {$i+}
 if IOresult<>0 then
   begin
   setfillstyle(1,varv[3]);
   bar(100,100,340,150);
   outtextxy(110,120,'Sellist faili ei eksisteeri!');
   if readkey=#0 then readkey;
   exit;
   end;
 close(f);
 Vabasta_Objekt3D(kujund);
 Loe_Objekt3D(kujund,objektikaust+fnimi);
 if kujund.nelinurkasid>0 then valitud_nelinurk:=1 else valitud_nelinurk:=0;
 arvuta_ZBuffri_suurus3D(obuffer,ZBuffer);
 varvijoon;
 kirjuta_koordinaadid;
 nelinurkade_nimekiri;
 end;


 begin
 gd:=d8bit;
 gm:=m640x480;
 InitGraph(gd,gm,'');
 Initmouse;

 setfillstyle(1,varv[3]);
 bar(0,0,639,479);
 setfillstyle(1,varv[2]);
 bar(1,1,400,300);
 bar(430,10,510,260);
 bar(430,285,510,300);
 setcolor(varv[1]);
 outtextxy(430,275,'V„rvi nr.');
 for i:=1 to 12 do
   begin
   if (i+2) mod 3 = 0 then outtextxy(540,koordinaadid[i]+5,'X');
   if (i+1) mod 3 = 0 then outtextxy(540,koordinaadid[i]+5,'Y');
   if (i) mod 3 = 0 then outtextxy(540,koordinaadid[i]+5,'Z');
   bar(550,koordinaadid[i],620,koordinaadid[i]+15);
   end;
 varvijoon;

 algvaartusta;

 vaartusta_teljed;
 Telgedemuutmine;

 Lisa_objekt3D(kujund,0,0,0,0,0,0,obuffer);
 arvuta_ZBuffri_suurus3D(obuffer,ZBuffer);
 arvuta_pildi_suurus3D(400,300,ekraan);

 Enda_koordinaadid;
 //SetMouseWindow(0,0,200,200);
 //SetMousePos(100,100);
 GetMouseState(hx_prev,hy_prev,state_prev);
 repeat
   Pilt_ekraanile;

   while (not keypressed) and (valikud[1].on=1) do
     begin
     GetMouseState(hx,hy,state);
     if (hx<>hx_prev) or (hy<>hy_prev) then
       begin
       if (state = state_prev) and ((state and RButton)=RButton) then
         begin
         z:=round(z-cos(a)*(hy-hy_prev)*25);
         x:=round(x+sin(a)*(hy-hy_prev)*25);
         z:=round(z+sin(a)*(hx-hx_prev)*25);
         x:=round(x+cos(a)*(hx-hx_prev)*25);
         end
       else if (state = state_prev) and ((state and MButton)=MButton) then
         begin
         y:=y-(hy-hy_prev)*25;
         end
       else if (state = state_prev) and ((state and LButton)=LButton) then
         begin
         a:=a-(hx-hx_prev)/100;
         if a>Pi*2 then a:=a-Pi*2;
         if a<0 then a:=a+Pi*2;
         b:=b-(hy-hy_prev)/100;
         if b>Pi*2 then b:=b-Pi*2;
         if b<0 then b:=b+Pi*2;
         end;
       //SetMousePos(100,100);
       GetMouseState(hx_prev,hy_prev,state_prev);
       Pilt_ekraanile;
       Enda_koordinaadid;
       end;
     end;

   nupp:=readkey;
   if nupp=#0 then
     begin
       nupp:=readkey;
       case nupp of
         #82:Lisa_nelinurk;
         #83:Eemalda_nelinurk;
         #73:if Valitud_nelinurk>1 then begin dec(Valitud_nelinurk);Nelinurkade_nimekiri;kirjuta_koordinaadid;varvijoon;end;
         #81:if Valitud_nelinurk<kujund.nelinurkasid then begin inc(Valitud_nelinurk);Nelinurkade_nimekiri;kirjuta_koordinaadid;varvijoon;end;
         #72:if Valitud_koordinaat>1 then begin dec(Valitud_koordinaat);kirjuta_koordinaadid;end;
         #80:if Valitud_koordinaat<12 then begin inc(Valitud_koordinaat);kirjuta_koordinaadid;end;
         #75:liida(-1);
         #77:liida(1);
         end;
     end else
     begin
     case nupp of
       #13:Koordinaadi_muutmine;
       #43:if kujund.nelinurkasid>0 then begin ring(kujund.nelinurk[valitud_nelinurk-1].varv,255,1);varvijoon;end;
       #45:if kujund.nelinurkasid>0 then begin ring(kujund.nelinurk[valitud_nelinurk-1].varv,255,-1);varvijoon;end;
       'k','K': Telgedemuutmine;
       'o','O': begin valikud[1].on:=valikud[1].on xor 1;kirjuta_valikud;{SetMousePos(100,100);}end;
       's','S': Salvesta;
       'l','L': Laadi;
       end;
     end;

 until nupp=#27;
 Salvesta;
 CloseGraph;

 vabasta_objekt3D(kujund);
 vabasta_objekt3D(teljed);
 vabasta_ZBuffer3D(ZBuffer);
 vabasta_objektibuffer3D(oBuffer);
 vabasta_pilt3D(ekraan);

 end.
