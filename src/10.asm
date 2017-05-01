;Program 10

;�rjon programot, amely beadott �rt�kek halmaz�t rendezi nagyobbt�l a kisebbig, �s megjelen�ti �ket a k�perny�n. Jelen�tse meg a beadott halmazt is, amely 10 maxim�lisan k�tjegy� eg�sz sz�mot tartalmaz.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

hossz EQU 10 ;a hossz jelentse azt, hogy 10, ezzel jelezz�k a  beolvasand� sz�mok mennyis�g�t, egyben a t�rol�sukra haszn�lt  t�mb hossza

;v�ltoz�k
szoveg1 db 'Legkisebbtol a legnagyobbig',13,10,36
szoveg11 db 13,10,'Adj meg $'
szoveg2 db ' szamot!',13,10,36
szoveg3 db '. szam: $'
szoveg4 db 13,10,13,10,'A beadott szamsor:',13,10,36
szoveg5 db 13,10,13,10,'A szamok rendezve:',13,10,36
szoveg6 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
newline db 13,10,36 ;�j sor ir�s�hoz
hibauz1 db 13,10,'Min 0, max 99!$'
buffer_key db 3,0,3 dup(0) ;ide olvassuk be az egyes  karaktereket
buffer_sort db hossz dup(0) ;ide mentj�k a beolvasott sz�mokat
szemafor db ? ;binascii proced�r�nak
i dw ? ;a buffer_sort t�mb indexel�s�re

;macro string ki�r�s�ra
pstring macro szoveg
	mov ah,9
	mov dx,offset szoveg
	int 21h
	endm ;macro v�ge

;macro egy karakter ki�r�s�ra
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm

;macro sz�m ki�r�s�ra
writenumber macro param
	mov ax,param
	call binascii
	endm

number macro param
	mov si,offset param
	call asciibin
	endm


;macro a sz�msor ki�r�s�ra
writeszamsor macro param
	mov di,offset param
	call pstringszamsor
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
	jne gop22 ;ha nem akkor binascii_go2-re
	cmp szemafor,0 ;ha igen, akkor szemafor=0?
	je gop23 ;ha igen, ugrunk a binascii_go3-ra

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
bubblesort proc near ;bemenet si - mutato a rendezendo tomb  elso elemere, hossz a tomb hossza
	jmp startp5 ;�tugorjuk a v�ltoz�kat

;v�ltoz�k
p db ? ;egy szemafor, hogy tudjuk volt csere
buf dw ? ;buffer, amibe elmentj�k az si kezdeti �rt�k�t
	
startp5:
	mov buf,si ;el�bb mondtam, itt mentj�k el
	mov dl,hossz ;dl-be azt, hogy mennyi b�jtot kell rendezni
	
gop51:	
	mov p,0 ;p-t null�zzuk
	mov si,buf ;si-be a kezdeti �rt�k�t
	dec dl ;dl-be eggyel kevesebbet 
	jz vegep5 ;ha dl=0 akkor v�ge

	mov cl,dl ;cl-be dl-t
	
atnezes:
	mov al,byte ptr[si] ;bevissz�k al-be, a buffer si-edik  b�jtj�t
	cmp al,byte ptr[si+1] ;megn�zz�k hogyan viszonyul ez az  elem a k�vetkez�vel
	jae gop52 ;L�NYEGES R�SZ! Ha kisebb akkor ugrunk, ha ezt  �t�rjuk jbe gop52-re akkor a legkisebbt�l a legnagyobbig  rendez

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
pstringszamsor proc near ;bemenet di - mutato a pstringando tombre, hossz a tomb hossza
	mov cl,hossz ;cl-be a t�mb hossz�t
	
cikp61:
	xor ah,ah ;ah null�z�sa
	mov al,byte ptr[di] ;al-be a di �ltal k�zvetlen�l  megc�mzett mem�riarekesz tartalm�t, egy b�jtot
	writenumber ax ;ki�rjuk az ax-ben lev� sz�mot
	putchar ',' ;kitesz�nk egy vessz�t
	inc di ;di k�v. elemre
	dec cl ;cl-1, a cl a ciklussz�ml�l�, evvel adom meg, hogy  mennyiszer fusson le a ciklus
	jnz cikp61 ;addig m�g cl nem nulla
	
	putchar 8 ;heh, a v�g�n maradt egy f�l�sleges vessz�, ez  nek�nk nem kell, ez�rt a 8-as ASCII karakterrel visszal�p�nk  egyet
	putchar 32 ;�s ki�runk egy SPACE-t (sz�k�zt)
	ret ;visszat�r�nk a f�programba
pstringszamsor endp

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	
	clrscr ;k�perny� t�rl�se
	
;kezd�k�perny� fel�p�t�se
	pstring szoveg1  ;szoveg1 ki�r�sa
	pstring szoveg11
	writenumber hossz ;ez az�rt, hogy ha �t�rjuk fent a hossz-ot, akkor  az alapj�n �rja ki, hogy adj meg xxx sz�mot
	pstring szoveg2
	
	mov i,1 ;i 1-esbe

;ez a r�sz olvassa be a sz�mokat
cik1:
	pstring newline ;�j sor
	writenumber i ;hanyadik sz�mn�l vagyunk? �rjuk ki
	pstring szoveg3 ;�s azt is, hogy . sz�m: 
	
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
	pstring hibauz1 ;hiba�zi ki�r�sa
	jmp cik1 ;�s vissza az elej�re

go2:
	number buffer_key+1 ;�talak�tjuk a buffer_key-ben lev�  sz�mot, hogy mi�rt buffer_key+1? L�sd a asciibin proc.! 
	
	mov si,i ;elmentj�k a sz�mot
	mov buffer_sort[si-1],al ;a t�mb�nkbe

	inc i ;i a k�v. elemre
	cmp i,hossz ;megn�zz�k kell-e m�g elem
	jbe cik1 ;ha igen, akkor olvasunk m�g
	
;k�sz, a sz�mokat beolvastuk
	clrscr ;k�p. t�rl�se
	pstring szoveg1 ;szoveg1 ki�r�sa
	
	pstring szoveg4 ;szoveg4 ki�r�sa
	writeszamsor buffer_sort ;a beolvasott sz�mok ki�r�sa
	
	mov si,offset buffer_sort ;rendez�s
	call bubblesort
	
	pstring szoveg5 ;a rendezett sz�msor ki�r�sa
	writeszamsor buffer_sort

	pstring szoveg6 ;a nyomj egy bill.-t a kil�p�shez ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy bill.-re echo n�lk�l
	int 21h
	
	mov ah,4ch ;vez�rl�s visszaad�sa az op.-nek
	int 21h

code ends ;code szegmens v�ge
	end start ;start cimk�n�l a program bel�p�si pontja