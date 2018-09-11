unit Varia;

interface

uses wincrt,graph;

procedure kirjuta_num(x,y,pikkus:integer;var arv:longint);
procedure kirjuta(x,y,pikkus:integer;var tekst:string);
procedure ring(var a:word;max,l:integer);
function sona(a:longint):string;

implementation

procedure kirjuta_num(x,y,pikkus:integer;var arv:longint);
   var number:string;
       nupp:char;
       koht:integer;
 begin
 str(arv,number);
 koht:=length(number)+1;
 repeat
   bar(x,y,x+8*length(number)+16,y+8);
   outtextxy(x,y,number);
   line(x+8*(koht-1),y+8,x+8*koht-2,y+8);
   nupp:=readkey;
   if nupp=#0 then
     begin
       nupp:=readkey;
       if (nupp=#75) and (koht>1) then dec(koht);
       if (nupp=#77) and (koht<=length(number)) then inc(koht);
       if (nupp=#83) and (koht<length(number)+1) then
         begin delete(number,koht,1);end;
     end else
     begin
       if (nupp=#8) and (koht<>1) then
         begin delete(number,koht-1,1);dec(koht); end;
       if (length(number)<pikkus) and (nupp='-') and (koht=1) and ((number[1]<>'-') or (length(number)=0)) then
         begin insert(nupp,number,1);inc(koht); end;
       if (nupp in ['0'..'9']) and (length(number)<pikkus) and not((koht=1) and (number[1]='-') and (length(number)>0)) then
         begin insert(nupp,number,koht);inc(koht); end;
     end;
 until (nupp=#27) or (nupp=#13);
 bar(x,y,x+8*length(number)+16,y+8);
 if nupp=#13 then
   begin
     val(number,arv,koht);
     if koht<>0 then arv:=0;
   end;
 str(arv,number);
 outtextxy(x,y,number);
 end;

procedure kirjuta(x,y,pikkus:integer;var tekst:string);
   const margid=['0'..'9','a'..'z','A'..'Z','ä','„','”','','å','Ž','™','š'
                ,',',' '];
   var sona:string;
       nupp:char;
       koht:integer;
 begin
 sona:=tekst;
 koht:=length(sona)+1;
 repeat
   bar(x,y,x+8*length(sona)+16,y+8);
   outtextxy(x,y,sona);
   line(x+8*(koht-1),y+8,x+8*koht-2,y+8);
   nupp:=readkey;
   if nupp=#0 then
     begin
       nupp:=readkey;
       if (nupp=#75) and (koht>1) then dec(koht);
       if (nupp=#77) and (koht<=length(sona)) then inc(koht);
       if (nupp=#83) and (koht<length(sona)+1) then
         begin delete(sona,koht,1);end;
     end else
     begin
       if (nupp=#8) and (koht<>1) then
         begin delete(sona,koht-1,1);dec(koht); end;
       if (nupp in margid) and (length(sona)<pikkus) then
         begin insert(nupp,sona,koht);inc(koht); end;
     end;
 until (nupp=#27) or (nupp=#13);
 bar(x,y,x+8*length(sona)+16,y+8);
 if nupp=#13 then tekst:=sona;
 sona:=tekst;
 outtextxy(x,y,sona);
 end;


procedure ring(var a:word;max,l:integer);
 begin
 if a+l<0 then a:=max+a+l+1 else
   if a+l>max then a:=a+l-max-1 else
     a:=a+l;
 end;

function sona(a:longint):string;
   var abi:string;
 begin
 str(a,abi);
 sona:=abi;
 end;

end.

