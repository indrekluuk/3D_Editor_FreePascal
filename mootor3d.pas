unit mootor3d;

interface
uses graph,crt,varia;

type
   punkt3D = record
             x,y,z:longint;
             end;

   punkt2D = record
             x,y:longint;
             end;

   p_ZBuffer3D = ^ZBuffer3D;
   ZBuffer3D = record
               kaugus:longint;
               x,y,z:array[0..3] of longint;
               varv:byte;
               end;

   nelinurk3D = packed record
                x,y,z:array[0..3] of longint;
                varv:word;
                end;

   p_olek3D = ^olek3D;
   olek3D = record
            x,y,z:longint;
            a,b,c:Single;
            ID:word;
            end;

   p_objekt3D = ^objekt3D;
   objekt3D = record
              nelinurkasid:word;
              nelinurk:^nelinurk3D;
              objektisid:word;
              objekt:^objekt3D;
              KasutatudObjektisid:word;
              ErinevaidOlekuid:word;
              AktiivneOlek:^olek3D;
              Olek:^p_olek3D;
              end;

   p_objektibuffer3D = ^objektibuffer3D;
   objektibuffer3D = record
                     objekt:^objekt3D;
                     x,y,z:longint;
                     a,b,c:Single;
                     jargmine,eelmine:^objektibuffer3D;
                     end;

   p_word=^word;

procedure loe_objekt3D(var objekt:objekt3D;fail:string);
procedure Vaheta_olek3D(var objekt:objekt3D;olek:integer);
procedure vabasta_objekt3D(var objekt:objekt3D);
procedure lisa_objekt3D(var objekt:objekt3D;x,y,z:longint;a,b,c:Single;var obuffer:p_objektibuffer3D);
procedure liiguta_objekt3D(objekt:objekt3D;x,y,z:longint;a,b,c:Single;obuffer:p_objektibuffer3D);
procedure kustuta_objekt3D(var objekt:objekt3D;var obuffer:p_objektibuffer3D);
procedure Vabasta_objektibuffer3D(var obuffer:p_objektibuffer3D);
procedure arvuta_ZBuffri_suurus3D(obuffer:p_objektibuffer3D;var ZBuffer:p_ZBuffer3D);
procedure vabasta_ZBuffer3D(var ZBuffer:p_ZBuffer3D);
procedure arvuta_pildi_suurus3D(x,y:word;var pilt:p_word);
procedure vabasta_pilt3D(var pilt:p_word);
procedure taidaZBuffer3D(obuffer:p_objektibuffer3D;var ZBuffer:p_ZBuffer3D;x,y,z:longint;a,b,c:Single);
procedure sorteeri_ZBuffer3D(var ZBuffer:p_ZBuffer3D);
procedure joonista_pilt3D(ZBuffer:p_ZBuffer3D;pilt:p_word;dx,dy,taust:integer);

implementation

var ZBuffriSuurus3D:Cardinal;


procedure loe_objekt3D(var objekt:objekt3D;fail:string);
   var f:file;
       w,i:word;
       s:string[50];
       rida:string;
 begin
 with objekt do
   begin
   assign(f, fail);
   reset(f,1);
   BlockRead(f,w,SizeOf(w));
   nelinurkasid:=w;
   GetMem(nelinurk,SizeOf(nelinurk3D)*w);
   BlockRead(f,nelinurk[0],SizeOf(nelinurk3D)*w);
   BlockRead(f,w,SizeOf(w));
   objektisid:=w;
   GetMem(objekt,SizeOf(objekt3D)*w);
   for i:=1 to w do
     begin
     BlockRead(f,s,SizeOf(s));
     rida:=fail;
     while (length(rida)>0) and (rida[length(rida)]<>'\') do dec(rida[0]);
     loe_objekt3D(objekt[i-1],rida+s);
     end;
   BlockRead(f,w,SizeOf(w));
   KasutatudObjektisid:=w;
   BlockRead(f,w,SizeOf(w));
   ErinevaidOlekuid:=w;
   GetMem(Olek,SizeOf(p_olek3D)*w);
   for i:=1 to w do
     begin
     GetMem(Olek[i-1],SizeOf(olek3D)*KasutatudObjektisid);
     BlockRead(f,Olek[i-1][0],SizeOf(olek3D)*KasutatudObjektisid);
     end;
   AktiivneOlek:=Olek[0];
   close(f);
   end;
 end;


procedure Vaheta_olek3D(var objekt:objekt3D;olek:integer);
   var olek2,i:word;
 begin
 olek2:=olek mod objekt.ErinevaidOlekuid;
 objekt.AktiivneOlek:=objekt.Olek[olek2];
 for i:=0 to objekt.objektisid-1 do
   Vaheta_olek3D(objekt.objekt[i],olek);
 end;


procedure vabasta_objekt3D(var objekt:objekt3D);
   var i,j:longint;
 begin
 FreeMem(objekt.nelinurk,SizeOf(nelinurk3D)*objekt.nelinurkasid);
 for i:=0 to objekt.objektisid-1 do
   vabasta_objekt3D(objekt.objekt[i]);
 FreeMem(objekt.objekt,SizeOf(Objekt3D)*objekt.objektisid);
 for i:=0 to objekt.ErinevaidOlekuid-1 do
   FreeMem(objekt.Olek[i],SizeOf(olek3D)*objekt.kasutatudobjektisid);
 FreeMem(objekt.Olek,SizeOf(p_olek3D)*objekt.ErinevaidOlekuid);
 end;


procedure lisa_objekt3D(var objekt:objekt3D;x,y,z:longint;a,b,c:Single;var obuffer:p_objektibuffer3D);
   var p_buffer:p_objektibuffer3D;
 begin
 getmem(p_buffer,sizeof(objektibuffer3D));
 p_buffer^.eelmine:=nil;
 p_buffer^.jargmine:=obuffer;
 if (obuffer <> nil) then obuffer^.eelmine:=p_buffer;
 obuffer:=p_buffer;
 obuffer^.objekt:=@objekt;
 obuffer^.x:=x;
 obuffer^.y:=y;
 obuffer^.z:=z;
 obuffer^.a:=a;
 obuffer^.b:=b;
 obuffer^.c:=c;
 end;

procedure liiguta_objekt3D(objekt:objekt3D;x,y,z:longint;a,b,c:Single;obuffer:p_objektibuffer3D);
   var p_buffer:^objektibuffer3D;
 begin
 p_buffer:=@obuffer;
 while (p_buffer<>nil) and (p_buffer^.objekt<>@objekt) do p_buffer:=p_buffer^.jargmine;
 if (p_buffer<>nil) then
   begin
   p_buffer^.x:=x;
   p_buffer^.y:=y;
   p_buffer^.z:=z;
   p_buffer^.a:=a;
   p_buffer^.b:=b;
   p_buffer^.c:=c;
   end;
 end;

procedure kustuta_objekt3D(var objekt:objekt3D;var obuffer:p_objektibuffer3D);
   var p_buffer:p_objektibuffer3D;
 begin
 p_buffer:=obuffer;
 while (p_buffer<>nil) and (p_buffer^.objekt<>@objekt) do p_buffer:=p_buffer^.jargmine;
 if (p_buffer<>nil) then
   if obuffer=p_buffer then
     begin
     obuffer:=p_buffer^.jargmine;
     if obuffer<>nil then obuffer^.eelmine:=nil;
     FreeMem(p_buffer,sizeof(objektibuffer3D));
     end else
     begin
     p_buffer^.eelmine^.jargmine:=p_buffer^.jargmine;
     if p_buffer^.jargmine<>nil then
       p_buffer^.jargmine^.eelmine:=p_buffer^.eelmine;
     FreeMem(p_buffer,sizeof(objektibuffer3D));
     end;
 end;

procedure Vabasta_objektibuffer3D(var obuffer:p_objektibuffer3D);
   var p_buffer:p_objektibuffer3D;
 begin
 while obuffer<>nil do
   begin
   p_buffer:=obuffer;
   obuffer:=obuffer^.jargmine;
   dispose(p_buffer);
   end;
 end;


procedure arvuta_ZBuffri_suurus3D(obuffer:p_objektibuffer3D;var ZBuffer:p_ZBuffer3D);

          function nelinurkasid_objektis(objekt:p_objekt3D) : Cardinal;
             var nelinurki:Cardinal;
                 i:word;
           begin
           nelinurki:=objekt^.nelinurkasid;
           for i:=1 to objekt^.objektisid do
             nelinurki:=nelinurki+nelinurkasid_objektis(@objekt^.objekt[i]);
           nelinurkasid_objektis:=nelinurki;
           end;

   var nelinurki:Cardinal;
 begin
 FreeMem(ZBuffer,SizeOf(ZBuffer3D)*ZBuffrisuurus3D);
 nelinurki:=0;
 while obuffer<>nil do
   begin
   nelinurki:=nelinurki+nelinurkasid_objektis(obuffer^.objekt);
   obuffer:=obuffer^.jargmine;
   end;

 ZBuffrisuurus3D:=nelinurki;
 GetMem(ZBuffer,SizeOf(ZBuffer3D)*ZBuffrisuurus3D);
 end;



procedure vabasta_ZBuffer3D(var ZBuffer:p_ZBuffer3D);
 begin
 FreeMem(ZBuffer,SizeOf(ZBuffer3D)*ZBuffrisuurus3D);
 ZBuffrisuurus3D:=0;
 ZBuffer:=nil;
 end;

procedure arvuta_pildi_suurus3D(x,y:word;var pilt:p_word);
 begin
 GetMem(pilt,12+x*y*2);
 pilt[0]:=x;
 pilt[1]:=0;
 pilt[2]:=y;
 pilt[3]:=0;
 pilt[4]:=0;
 pilt[5]:=0;
 end;

procedure vabasta_pilt3D(var pilt:p_word);
  var x,y:word;
 begin
 x:=pilt[0];
 y:=pilt[2];
 FreeMem(pilt,12+x*y*2);
 end;


procedure taidaZBuffer3D(obuffer:p_objektibuffer3D;var ZBuffer:p_ZBuffer3D;x,y,z:longint;a,b,c:Single);
   var i:Cardinal;
       xx,yy,zz:longint;
       sin_a,cos_a,sin_b,cos_b,sin_c,cos_c:single;

          procedure poora(var x,y,z:longint;xa,ya,za:longint;sin_a,sin_b,sin_c,cos_a,cos_b,cos_c:Single);
           begin
           x:=round(xa*cos_a-za*sin_a);
           z:=round(za*cos_a+xa*sin_a);
           xa:=x;
           za:=z;
           z:=round(za*cos_b-ya*sin_b);
           y:=round(ya*cos_b+za*sin_b);
           ya:=y;
           x:=round(xa*cos_c-ya*sin_c);
           y:=round(ya*cos_c+xa*sin_c);
           end;

          procedure objekt_ZBuffrisse(var objekt:objekt3D;x,y,z:longint;a,b,c:Single);
             var j:longint;
                 l:byte;
                 sin_a,cos_a,sin_b,cos_b,sin_c,cos_c:single;
                 xx,yy,zz:longint;
           begin
           sin_a:=sin(a); cos_a:=cos(a);
           sin_b:=sin(b); cos_b:=cos(b);
           sin_c:=sin(c); cos_c:=cos(c);
           for j:=0 to objekt.nelinurkasid-1 do
             begin
             ZBuffer[i].varv:=objekt.nelinurk[j].varv;

             ZBuffer[i].kaugus:=0;
             for l:=0 to 3 do
               begin
               poora(xx,yy,zz,objekt.nelinurk[j].x[l],objekt.nelinurk[j].y[l],objekt.nelinurk[j].z[l],sin_a,sin_b,sin_c,cos_a,cos_b,cos_c);
               ZBuffer[i].x[l]:=xx+x;
               ZBuffer[i].y[l]:=yy+y;
               ZBuffer[i].z[l]:=zz+z;
               ZBuffer[i].kaugus:=ZBuffer[i].kaugus+zz;
               end;

             ZBuffer[i].kaugus:=ZBuffer[i].kaugus div 4+z;

             //round(sqrt(sqr((xx[0]+xx[1]+xx[2]+xx[3])/4)+sqr((yy[0]+yy[1]+yy[2]+yy[3])/4)+sqr((zz[0]+zz[1]+zz[2]+zz[3])/4)));
             i:=i+1;
             end;

           for j:=0 to objekt.KasutatudObjektisid-1 do
             begin
             poora(xx,yy,zz,objekt.AktiivneOlek[j].x+x,objekt.AktiivneOlek[j].y-y,objekt.AktiivneOlek[j].y-z,sin_a,sin_b,sin_c,cos_a,cos_b,cos_c);
             objekt_ZBuffrisse(objekt.objekt[objekt.AktiivneOlek[j].ID],xx,yy,zz,a+objekt.AktiivneOlek[j].a,b+objekt.AktiivneOlek[j].b,c+objekt.AktiivneOlek[j].c);
             end;

           end;

 begin
 i:=0;
 sin_a:=sin(-a); cos_a:=cos(-a);
 sin_b:=sin(-b); cos_b:=cos(-b);
 sin_c:=sin(-c); cos_c:=cos(-c);
 while obuffer<>nil do
   begin
   poora(xx,yy,zz,obuffer^.x-x,obuffer^.y-y,obuffer^.z-z,sin_a,sin_b,sin_c,cos_a,cos_b,cos_c);
   objekt_ZBuffrisse(obuffer^.objekt^,xx,yy,zz,obuffer^.a-a,obuffer^.b-b,obuffer^.c-c);
   obuffer:=obuffer^.jargmine;
   end;
 end;


{
procedure sorteeri_ZBuffer3D(var ZBuffer:p_ZBuffer3D);
   var i,j,MAX:longint;
       n:ZBuffer3D;
 begin
 MAX:=ZBuffriSuurus3D;
 for i:=(MAX-2) downto 0 do
   begin
   j:=1;
   while ((2*j+i<=MAX) and (ZBuffer[2*j+i-1].kaugus<ZBuffer[i+j-1].kaugus)) or ((2*j+1+i<=MAX) and (ZBuffer[2*j+i].kaugus<ZBuffer[i+j-1].kaugus)) do
     begin
     n:=ZBuffer[i+j-1];
     if (2*j+1+i<=MAX) then
       begin
       if ZBuffer[2*j+i-1].kaugus<ZBuffer[2*j+i].kaugus then
         begin
         ZBuffer[i+j-1]:=ZBuffer[i+2*j-1];
         j:=2*j;
         end
       else
         begin
         ZBuffer[i+j-1]:=ZBuffer[i+2*j];
         j:=2*j+1;
         end;
       end
     else
       begin
       ZBuffer[i+j-1]:=ZBuffer[i+2*j-1];
       j:=2*j;
       end;
     ZBuffer[i+j-1]:=n;
     end;
   end;
 for i:=MAX-1 downto 1 do
   begin
   n:=ZBuffer[i];
   ZBuffer[i]:=ZBuffer[0];
   ZBuffer[0]:=n;
   j:=1;
   while ((2*j<=i) and (ZBuffer[2*j-1].kaugus<ZBuffer[j-1].kaugus)) or ((2*j+1<=i) and (ZBuffer[2*j].kaugus<ZBuffer[j-1].kaugus)) do
     begin
     n:=ZBuffer[j-1];
     if (2*j+1<=i) then
       begin
       if ZBuffer[2*j-1].kaugus<ZBuffer[2*j].kaugus then
         begin
         ZBuffer[j-1]:=ZBuffer[2*j-1];
         j:=2*j;
         end
       else
         begin
         ZBuffer[j-1]:=ZBuffer[2*j];
         j:=2*j+1;
         end;
       end
     else
       begin
       ZBuffer[j-1]:=ZBuffer[2*j-1];
       j:=2*j;
       end;
     ZBuffer[j-1]:=n;
     end;
   end;
 end;
}

procedure sorteeri_ZBuffer3D(var ZBuffer:p_ZBuffer3D);
  var  abi:ZBuffer3D;
    procedure sorteeri(l,r: longint);
      var
         i,j,x: longint;
      begin
         i:=l;
         j:=r;
         x:=ZBuffer[(l+r) div 2-1].kaugus;
         repeat
           while ZBuffer[i-1].kaugus<x do
            inc(i);
           while x<ZBuffer[j-1].kaugus do
            dec(j);
           if not(i>j) then
             begin
                abi:=ZBuffer[i-1];
                ZBuffer[i-1]:=ZBuffer[j-1];
                ZBuffer[j-1]:=abi;
                inc(i);
                j:=j-1;
             end;
         until i>j;
         if l<j then
           sorteeri(l,j);
         if i<r then
           sorteeri(i,r);
      end;

 begin
 if ZBuffriSuurus3D<>0 then sorteeri(1,ZBuffriSuurus3D);
 end;


procedure joonista_pilt3D(ZBuffer:p_ZBuffer3D;pilt:p_word;dx,dy,taust:integer);
   Var i:Cardinal;
       j,n,x,y:integer;
       nelinurk:array[0..5] of punkt2D;
       hnurk:array[0..5] of punkt3D;


     procedure hulknurk(n:byte;var punkt:array of punkt2D;varv:byte;x,y:integer);
        var v,p,vv,pp:byte;
            kv,kp:single;
            jarg,jargmine,i,a,l,abi:longint;
            kaugus:cardinal;
      begin

      n:=n-1;
      jarg:=punkt[0].y+1;
      p:=0;
      for i:=1 to n do if jarg>punkt[i].y+1 then begin jarg:=punkt[i].y+1;p:=i end;
      v:=p;
      repeat
        if v=0 then vv:=n else vv:=v-1;
        if p=n then pp:=0 else pp:=p+1;
        if (pp=v) and (vv=p) then exit;
        if punkt[vv].y<punkt[pp].y then
          jargmine:=punkt[vv].y+1 else jargmine:=punkt[pp].y+1;
        if (punkt[v].y=punkt[vv].y) then kv:=punkt[v].x-punkt[vv].x else kv:=(punkt[v].x-punkt[vv].x)/(punkt[v].y-punkt[vv].y);
        if (punkt[pp].y=punkt[p].y) then kp:=punkt[pp].x-punkt[p].x else kp:=(punkt[pp].x-punkt[p].x)/(punkt[pp].y-punkt[p].y);
        jarg:=jarg-1;

        while jarg<jargmine do
          begin
          if (jarg>=0) and (jarg<=y) then
            begin
            a:=round(punkt[v].x+kv*(jarg-punkt[v].y));
            l:=round(punkt[p].x+kp*(jarg-punkt[p].y));
            if a>l then begin abi:=a;a:=l;l:=abi end;
            if a<=x then
              begin
              if a<0 then a:=0;
              if l>x then l:=x;
              kaugus:=6+jarg*(x+1);

              if a<l then FillWord(pilt[kaugus+a],l-a+1,varv);
//                for i:=kaugus+a to kaugus+l do
//                  pilt[i]:=varv+random(2);

              end;
            end;
          jarg:=jarg+1;
          end;

        if punkt[vv].y<jarg then
          if v=0 then v:=n else v:=v-1;
        if punkt[pp].y<jarg then
          if p=n then p:=0 else p:=p+1;
        until pp=vv;

      end;



     function loika_nelinurk(var loigatud:array of punkt3D;algne:ZBuffer3D) : byte;
       var nurkasid,i,j:byte;
      begin
      nurkasid:=0;
      for i:=0 to 3 do
        if algne.z[i]<0 then
          begin
          if i=0 then j:=3 else j:=i-1;
          if algne.z[j]>0 then
            begin
            loigatud[nurkasid].x:=round((algne.x[i]-algne.x[j])*algne.z[j] / (algne.z[j]-algne.z[i]))+algne.x[j];
            loigatud[nurkasid].y:=round((algne.y[i]-algne.y[j])*algne.z[j] / (algne.z[j]-algne.z[i]))+algne.y[j];
            loigatud[nurkasid].z:=0;
            nurkasid:=nurkasid+1;
            end;
          if i=3 then j:=0 else j:=i+1;
          if algne.z[j]>0 then
            begin
            loigatud[nurkasid].x:=round((algne.x[i]-algne.x[j])*algne.z[j] / (algne.z[j]-algne.z[i]))+algne.x[j];
            loigatud[nurkasid].y:=round((algne.y[i]-algne.y[j])*algne.z[j] / (algne.z[j]-algne.z[i]))+algne.y[j];
            loigatud[nurkasid].z:=0;
            nurkasid:=nurkasid+1;
            end;
          end else
            begin
            loigatud[nurkasid].x:=algne.x[i];
            loigatud[nurkasid].y:=algne.y[i];
            loigatud[nurkasid].z:=algne.z[i];
            nurkasid:=nurkasid+1;
            end;
      loika_nelinurk:=nurkasid;
      end;


 begin
 x:=pilt[0];
 y:=pilt[2];
 if taust>=0 then FillWord(pilt[6],(x)*(y),taust);

 if ZBuffriSuurus3D=0 then exit;
 for i:=ZBuffriSuurus3D-1 downto 0 do
   begin
   n:=loika_nelinurk(hnurk,ZBuffer[i]);

   if n<>0 then
     begin
     for j:=0 to n-1 do
        begin
         nelinurk[j].x:=round(hnurk[j].x/(hnurk[j].z+dx)*dx)+x div 2;
         nelinurk[j].y:=round(hnurk[j].y/(hnurk[j].z+dy)*dy)*-1+y div 2;
         end;

     hulknurk(n,nelinurk,ZBuffer[i].varv,x-1,y-1);

     end;
   end;
 end;



 begin
 ZBuffrisuurus3D:=0;
 end.
