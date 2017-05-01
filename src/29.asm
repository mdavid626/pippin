;Program 29

;�rjon programot, amely bek�r a bill. 3 k�tjegy� eg�sz sz�mot, �s ezeket megjelen�ti a k�perny�n a legnagyobbt�l a legkisebbig.

code segment ;code nev� szegmens l�trehoz�sa
  assume cs:code,ds:code ;hozz�rendel�s

;long sz� jelentse azt, hogy 3, ez jelzi a beolvasand� sz�mok   sz�m�t, ha itt �t�rjuk, akkor mindenhol �t�r�dik a  programban, ha mondjuk 10 sz�mot akarn�nk bek�rni, itt el�g  lenne �t�rni, �s a program automatikusan 10 sz�mot k�rne be, �s rendezne
long EQU 3

;v�ltoz�k
text1 db 'Legnagyobbtol a legkisebbig'
      db 13,10,'***************************'
      db 13,10,'Adj meg $'
text11 db ' szamot!',13,10,36
text2 db '. szam: $'
text3 db 13,10,13,10,'A szamok rendezve:',13,10,36
text4 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
hibauz1 db 13,10,'A megadhato legkisebb szam a 10, a legnagyobb a 99!$'
newline db 13,10,36 ;�j sor �r�s�hoz
buffer_key db 3,0,3 dup(0)
buffer_sort db long dup(0)
szemafor db ?
index dw ? ;a buffer_sort indexel�s�hez

;macro string ki�r�s�ra
kiir macro text
  mov ah,9
  mov dx,offset text
  int 21h
  endm ;macro v�ge

;macro egy karakter ki�r�s�ra
putchar macro char
  mov ah,2
  mov dl,char
  int 21h
  endm ;macro v�ge

;proced�ra bin�ris sz�m ki�r�s�ra
binascii proc near ;bemenet ax
  mov szemafor,0 ;szemafor null�z�sa
  cmp ax,0 ;ax=0?
  jne gop21 ;ha nem akkor megy�nk tov�bb
  putchar '0' ;ha ige, akkor kirakunk egy null�t
  jmp vegep2 ;�s megy�nk a v�g�re

gop21:
  mov bx,10000 ;10000-rel fogunk osztani
  xor dx,dx ;az oszt�s el�tt null�zni kell a dx-et

cikp21:
  div bx ;osztjuk az ax-et bx-el
  mov si,dx ;a marad�k az si-be
  cmp ax,0 ;ax=0?
  jne gop22 ;ha nem akkor gop22-re
  cmp szemafor,0 ;ha igen, akkor szemafor=0?
  je gop23 ;ha igen, ugrunk a gop23-ra

gop22:
  add al,30h ;al-hez adjunk hozz� 30h, ASCII!
  putchar al ;kitessz�k a k�perny�re
  mov szemafor,1 ;m�r itt biztos volt ki�rva karakter, ez�rt  szemafor egyesbe

gop23:
  mov ax,bx ;az oszt�t osztani kell 10-el
  mov bx,10 ;10-el
  xor dx,dx ;dx null�z�sa, mint fent
  div bx ;kinullazza a dx-et, osztjuk az ax-et
  cmp ax,1 ;megn�zz�k ax=1?
  jb vegep2 ;ha kisebb mint 1, akkor v�ge
  mov bx,ax ;ha nem, bx-be vissza az oszt�t
  mov ax,si ;ax-be vissza a marad�kot
  jmp cikp21 ;vissza az elej�re

vegep2:
  ret ;visszat�r�nk a f�programba
binascii endp ;proc. v�ge

;ASCII karaktereket alak�t sz�mm�
asciibin proc near ;bemenet si - mutato buffer+1
                   ;kimenet ax - bin ertek
  mov cl,byte ptr[si] ;bevissz�k a cl-be a beolvasott  karakterek sz�m�t
  xor ax,ax ;ax-et null�zzuk
  cmp cl,0 ;megn�zz�k volt-e beolvasott karakter
  ja gop31 ;ha igen, akkor tov�bb
  jmp vegep3 ;ha nem akkor v�ge

gop31:
  mov bx,10 ;10-el fogunk szorozni

cikp31:
  mul bx ;dx null�zva, szorozzuk az ax-et bx-el
  inc si ;si k�v. elemre mutasson
  mov dl,byte ptr[si] ;bevissz�k dl-be a karaktert
  sub dl,30h ;levonunk bel�le 30h, l�sd ASCII!
  add ax,dx ;hozz�adjuk az ax-hez a sz�mjegyet
  dec cl ;cl-1
  jnz cikp31 ;addig m�g cl!=0 vissza az elej�re

vegep3:
  ret ;visszat�r�s a f�programba
asciibin endp ;proc. v�ge

;ez a l�nyeg, a rendez� algoritmus
;bubblesort-ot haszn�ljuk, mivel kev�s az elemsz�m
bubblesort proc near ;bemenet si - mutato a rendezendo tomb  elso elemere, long a tomb hossza
  jmp startp5 ;�tugorjuk a v�ltoz�kat

;v�ltoz�k
p db ? ;egy szemafor, hogy tudjuk volt csere
buf dw ? ;buffer, amibe elmentj�k az si kezdeti �rt�k�t

startp5:
  mov buf,si ;el�bb mondtam, itt mentj�k el
  mov dl,long ;dl-be azt, hogy mennyi b�jtot kell rendezni

gop51:
  mov p,0 ;p-t null�zzuk
  mov si,buf ;si-be a kezdeti �rt�k�t
  dec dl ;dl-be eggyel kevesebbet
  jz vegep5 ;ha dl=0 akkor v�ge

  mov cl,dl ;cl-be dl-t

atnezes:
  mov al,byte ptr[si] ;bevissz�k al-be, a buffer si-edik  b�jtj�t
  cmp al,byte ptr[si+1] ;megn�zz�k hogyan viszonyul ez az  elem a k�vetkez�vel
  jae gop52 ;L�NYEGES R�SZ! Ha nagyobb vagy egyenl� akkor  ugrunk, ha ezt �t�rjuk jbe gop52-re akkor legkisebbt�l  legnagyobbig rendez

  xchg al,byte ptr[si+1] ;felcser�lj�k a k�t elemet
  mov byte ptr[si],al
  mov p,1 ;�s p-t egyesbe �ll�tjuk

gop52:
  inc si ;si k�v. elemre mutasson
  dec cl ;cl eggyel kevesebb
  jnz atnezes ;ha cl m�g nem nulla, akkor vissza az elej�re

  cmp p,1 ;megn�zz�k p=1?
  je gop51 ;ha igen, ugrunk

vegep5:
  ret ;visszat�r�s a f�programba
bubblesort endp ;proc. v�ge

;f�program
start:
  mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
  mov ds,ax

  mov ax,3 ;k�perny� t�rl�se, 80x25-�s m�dba val� v�lt�ssal
  int 10h

  kiir text1 ;ki�rjuk a text1-et
  mov ax,long ;bevissz�k azt az ax-be, hogy mennyi sz�mot  kell megadni
  call binascii ;ki�rjukl ezt a sz�mot
  kiir text11 ;itt meg a sz�veg t�bbi r�sze

  mov index,1 ;index=1, ez egyben ciklusv�ltoz� is

;itt olvassuk be a sz�mokat
cik1:
  kiir newline ;�runk egy �j sort
  mov ax,index ;ki�rjuk, hogy hanyadik sz�mot adjuk meg �pp
  call binascii
  kiir text2 ;�s ki�rjuk, hogy . sz�m:

  mov ah,0ch ;bill. buffer t�rl�se
  mov al,0ah ;string beolvas�sa
  mov dx,offset buffer_key ;a buffer_key-be
  int 21h ;csin�ld

  xor bx,bx ;bx null�z�sa

cik3:
  cmp buffer_key[bx+2],30h ;megn�zz�k, hogy a beolvasott k�t  karakter sz�m volt-e
  jb go1
  cmp buffer_key[bx+2],39h
  ja go1
  inc bl ;v�gign�zz�k a t�mb�t
  cmp bl,buffer_key[1]
  jb cik3
  jmp go2 ;ha ide eljutunk, akkor minden rendben, mehet�nk  tov�bb

go1:
  kiir hibauz1 ;ha nem volt rendben, akkor ki�rjuk, hogy  hiba
  jmp cik1 ;�s bek�rj�k m�g 1x

go2:
  mov si,offset buffer_key+1 ;si-be a buffer m�sodik  b�jtj�ra mutat� mutat�
  call asciibin ;csin�lunk bel�le sz�mot
  cmp al,10 ;az ax-be lesz ez a sz�m, megn�zz�k nagyobb mint  10?
  jb go1 ;ha kisebb, akkor baj van, megy�nk a hib�ra

  mov si,index ;si-be index
  mov buffer_sort[si-1],al ;elmentj�k a buffer_sort-ba a  sz�mot
  inc index ;index mutasson a buffer k�v. elem�re, a k�v. ment�shez
  cmp index,long ;megn�zz�k bek�rt�k m�r az �sszes sz�mot?
  jbe cik1 ;ha m�g nem, akkor k�rj�k

  mov si,offset buffer_sort ;na itt rendezz�k
  call bubblesort ;ez csin�lja

  kiir text3 ;ki�rju, hogy a t�mb rendezve
  mov index,1 ;index=1

cik2:
  kiir newline ;�jsor
  mov ax,index ;ax-be index
  call binascii ;ki�rjuk az index-et
  kiir text2 ;ki�rjuk, hogy . sz�m:

  xor ah,ah ;ah-t null�zzuk
  mov si,index ;si-be index
  mov al,buffer_sort[si-1] ;buffer megfelel� b�jtj�t al-be
  call binascii ;ki�rni

  inc index ;index k�v. elemre
  cmp index,long ;megn�zz�k ki�rtuk m�r az �sszes elemet?
  jbe cik2 ;ha m�g nem, akkor vissza a cik2-re

  kiir text4 ;ki�rjuk, hogy nyomj b�rmilyen bill.-t

  mov ah,0ch ;bill. buffer t�rl�se
  mov al,7 ;v�r�s echo n�lk�l egy bill. lenyom�s�ra
  int 21h

  mov ah,4ch ;a vez�rl�s visszaad�sa az op.-nek
  int 21h

code ends ;code szegmens v�ge
  end start ;start cimk�n�l kezd�nk