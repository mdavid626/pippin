;Program 09

;�rjon programot, amely a beadott �rt�kek halmaz�t rendezi kisebbt�l a nagyobbig. Jelen�tse meg a beadott halmazt, amely 10 maxim�lisan k�tjegy� eg�sz sz�mokb�l �ll.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

long EQU 10 ;a long jelentse azt, hogy 10, ezzel jelezz�k a  beolvasand� sz�mok mennyis�g�t, egyben a t�rol�sukra haszn�lt  t�mb hossza

;v�ltoz�k
text1 db 'Legkisebbtol a legnagyobbig'
      db 13,10,'---------------------------$'
text11 db 13,10,'Adj meg $'
text2 db ' szamot!',13,10,36
text3 db '. szam: $'
text4 db 13,10,13,10,'A beadott szamsor:',13,10,36
text5 db 13,10,13,10,'A szamok rendezve:',13,10,36
text6 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
newline db 13,10,36 ;�j sor ir�s�hoz
hibauz1 db 13,10,'A megadhato legnagyobb szam a 99!$'
buffer_key db 3,0,3 dup(0) ;ide olvassuk be az egyes  karaktereket
buffer_sort db long dup(0) ;ide mentj�k a beolvasott sz�mokat
szemafor db ? ;binascii proced�r�nak
index dw ? ;a buffer_sort t�mb indexel�s�re

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
	endm

;macro sz�m ki�r�s�ra
wnum macro param
	mov ax,param
	call binascii
	endm

num macro param
	mov si,offset param
	call asciibin
	endm


;macro a sz�msor ki�r�s�ra
wszamsor macro param
	mov di,offset param
	call kiirszamsor
	endm

;macro a k�perny� t�rl�s�re
clrscr macro
	mov ax,3 ;80x25-�s m�d be�ll�t�sa, ezzel a k�p. t�rl�se
	int 10h
	endm

;proced�ra bin�ris sz�m ki�r�s�ra
binascii proc near ;bemenet ax
	mov szemafor,0 ;szemafor null�z�sa
	cmp ax,0 ;ax=0?
	jne gop21 ;ha nem akkor megy�nk tov�bb
	putchar '0' ;ha igen, akkor kirakunk egy null�t
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
	jbe gop52 ;L�NYEGES R�SZ! Ha kisebb akkor ugrunk, ha ezt  �t�rjuk jae gop52-re akkor a legnagyobbt�l a legkisebbig  rendez

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

;proc. a sz�msor ki�r�s�ra 
kiirszamsor proc near ;bemenet di - mutato a kiirando tombre, long a tomb hossza
	mov cl,long ;cl-be a t�mb hossz�t
	
cikp61:
	xor ah,ah ;ah null�z�sa
	mov al,byte ptr[di] ;al-be a di �ltal k�zvetlen�l  megc�mzett mem�riarekesz tartalm�t, egy b�jtot
	wnum ax ;ki�rjuk az ax-ben lev� sz�mot
	putchar ',' ;kitesz�nk egy vessz�t
	inc di ;di k�v. elemre
	dec cl ;cl-1, a cl a ciklussz�ml�l�, evvel adom meg, hogy  mennyiszer fusson le a ciklus
	jnz cikp61 ;addig m�g cl nem nulla
	
	putchar 8 ;heh, a v�g�n maradt egy f�l�sleges vessz�, ez  nek�nk nem kell, ez�rt a 8-as ASCII karakterrel visszal�p�nk  egyet
	putchar 32 ;�s ki�runk egy SPACE-t (sz�k�zt)
	ret ;visszat�r�nk a f�programba
kiirszamsor endp

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	
	clrscr ;k�perny� t�rl�se
	
;kezd�k�perny� fel�p�t�se
	kiir text1  ;text1 ki�r�sa
	kiir text11
	wnum long ;ez az�rt, hogy ha �t�rjuk fent a long-ot, akkor  az alapj�n �rja ki, hogy adj meg xxx sz�mot
	kiir text2
	
	mov index,1 ;index 1-esbe

;ez a r�sz olvassa be a sz�mokat
cik1:
	kiir newline ;�j sor
	wnum index ;hanyadik sz�mn�l vagyunk? �rjuk ki
	kiir text3 ;�s azt is, hogy . sz�m: 
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;string beolvas�sa a bill.-r�l
	mov dx,offset buffer_key ;a buffer_key-be
	int 21h ;let�s go
	
;itt v�gign�zz�k a beolvasott karaktereket, ha mindegyik  sz�mjegy volt akkor ok, �s elmentj�k, ha nem akkor hiba�zi, �s  nem ment�nk
	xor bx,bx ;bx null�z�sa
	
cik3:
	cmp buffer_key[bx+2],30h
	jb go1 ;a karakter kisebb mint 30h=�0�? Ha igen az baj
	cmp buffer_key[bx+2],39h
	ja go1 ;a karakter nagyobb mint 39h=�9� Ha igen az baj
	inc bl ;k�v. elem
	cmp bl,buffer_key[1]
	jb cik3 ;addig m�g v�gig nem n�zz�k a t�mb �sszes elem�t
	jmp go2 ;ha ide eljutuk, akkor mehet�nk tov�bb

go1:
	kiir hibauz1 ;hiba�zi ki�r�sa
	jmp cik1 ;�s vissza az elej�re

go2:
	num buffer_key+1 ;�talak�tjuk a buffer_key-ben lev�  sz�mot, hogy mi�rt buffer_key+1? L�sd a asciibin proc.! 
	
	mov si,index ;elmentj�k a sz�mot
	mov buffer_sort[si-1],al ;a t�mb�nkbe

	inc index ;index a k�v. elemre
	cmp index,long ;megn�zz�k kell-e m�g elem
	jbe cik1 ;ha igen, akkor olvasunk m�g
	
;k�sz, a sz�mokat beolvastuk
	clrscr ;k�p. t�rl�se
	kiir text1 ;text1 ki�r�sa
	
	kiir text4 ;text4 ki�r�sa
	wszamsor buffer_sort ;a beolvasott sz�mok ki�r�sa
	
	mov si,offset buffer_sort ;rendez�s
	call bubblesort
	
	kiir text5 ;a rendezett sz�msor ki�r�sa
	wszamsor buffer_sort

	kiir text6 ;a nyomj egy bill.-t a kil�p�shez ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy bill.-re echo n�lk�l
	int 21h
	
	mov ah,4ch ;vez�rl�s visszaad�sa az op.-nek
	int 21h

code ends ;code szegmens v�ge
	end start ;start cimk�n�l a program bel�p�si pontja