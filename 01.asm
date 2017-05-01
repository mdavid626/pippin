;Program 01

;�rjon programot a t�glatest t�rfogat�nak kisz�m�t�s�ra. A t�glatest oldalainak hossz�t k�rje be a billenty�zetr�l, az eredm�nyt pedig jelen�tse meg a k�perny�n. Az eredm�ny f�rjen bele 2 b�jtba.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s
	
;v�ltoz�k
text1 db 'A teglatest terfogatanak kiszamitasa.'
      db 13,10,'Add meg az oldalakat (max. 40 mindegyik):$'
text2 db '. oldal: $'
text3 db 13,10,'A teglatest terfogata: $'
text4 db 13,10,'Nyomj le barmilyen billentyut a kilepeshez...$'
hibauz1 db 13,10,'Mondom, hogy negyvenig! Ember, nem erted?$'
newline db 13,10,36 ;�j sor �r�s�ra
buffer db 3,0,3 dup(0) ;ebbe olvassuk be a sz�mot
buffer_save db 3 dup(0) ;ide pedig elmentj�k
szemafor db ? ;binascii haszn�lja
index dw ? ;indexelj�k a buffer_save-t

;macro stringek ki�r�s�ra
kiir macro text ;text az egyetlen param�ter
	mov ah,9 ;a 9-es DOS szolg�ltat�ssal �rjuk ki a stringet
	mov dx,offset text
	int 21h
	endm ;macro v�ge

;alprogram � a beolvasott karakterek �talak�t�s�ra bin�riss�
asciibin proc near ; bemenet si - mutato buffer+1
                   ; kimenet ax - bin ertek

	mov cl,byte ptr[si] ;bevissz�k a beolvasott kar. sz�m�t a  cl-be
	xor ax,ax ;ax-t null�zzuk
	cmp cl,0 ;megn�zz�k volt-e beolvasva karakter
	ja gop11 ;ha volt tov�bbmegy�nk
	ret ;ha nem v�ge

gop11:	
mov bx,10 ;10-el fogunk szorozni

cikp11:	
	mul bx ;itt szorzunk, ax-et bx-el, dx nullazva
	inc si ;si-t megn�velj�k eggyel
	mov dl,byte ptr[si] ;bevissz�nk a bufferb�l egy b�jtot a  dl-be
	sub dl,30h ;levonunk bel�le 30h-t
	add ax,dx ;�gy lesz bel�le bin�ris sz�m, hozz�adjuk az ax- hez, az ax-ben van a v�gs� bin�ris sz�m
	dec cl ;cl eggyel cs�kkentj�k
	jnz cikp11 ;addig ism�telj�k ezt, m�g cl nulla nem lesz

	ret ;vissza a f�programba

asciibin endp ;a proced�ra v�ge

;ez a proc. ki�rja a k�perny�re az ax-ben l�v� bin. �rt�ket
binascii proc near ; bemenet ax
	mov szemafor,0 ;szemafort null�zzuk
	cmp ax,0 ;megn�zz�k, hogy nem-e egy null�t kell ki�rnunk
	jne gop21 ;ha nem akkor tov�bb
	mov ah,2 ;ha igen, h�t ki�rjuk
	mov dl,'0' ;az�rt �gy, mert �gy egyszer�bb
	int 21h ;mint k�s�bb t�r�dni vele
	ret ;vissza a f�programba

gop21:
	mov bx,10000 ;10000 fogunk osztani
	xor dx,dx ;a dx-et null�zni kell, l�sd div utas�t�s

cikp22:	
	div bx ;osztjuk az ax-et �s kiterjeszt�s�t a dx-et bx-el
	mov si,dx ;a marad�kot kimentj�k az si-be
	cmp ax,0 ;ha ax nulla megn�zz�k ki kell-e �rni
	jne gop22 ;ha nem nulla akkor ki�rjuk
	cmp szemafor,0 ;ha szemafor nulla, nem �rjuk ki
	je gop23

gop22:	
	mov ah,2 ;itt �rjuk ki
	mov dl,al
	add dl,30h ;el�tte hozz�adunk 30h-t, l�sd ASCII
	int 21h
	mov szemafor,1 ;m�r volt ki�rva sz�m, szemafor 1-esbe

gop23:
	mov ax,bx ;az oszt�t 10-el elosztjuk
	mov bx,10
	xor dx,dx
	div bx ;kinullazza a dx-et, fent m�r nem fog kelleni
	cmp ax,1
	jb vegep2 ;ha kisebb mint v�ge
	mov bx,ax ;vissza az oszt�t a bx-be
	mov ax,si ;az osztand� meg a marad�k
	jmp cikp22 ;vissza az elej�re

vegep2:	
ret ;visszat�r�nk a f�programba

binascii endp ;a proc. v�ge

start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax 
	cld ;df null�z�sa

	mov ax,3 ;k�perny� t�rl�se, 80x25-�s m�d be�ll�t�s�val
	int 10h ;a 16-os BIOS szolg�ltat�st haszn�ljuk	
	
	kiir text1 ;ki�rjuk a text1-et
	mov index,1 ;index=1
	
cik1:
	kiir newline ;�runk egy �jsort
	mov ax,index ;ax-be az index
	call binascii ;hogy ki tudjuk �rni
	kiir text2 ;�s ki�rjuk, hogy .oldal: 
	
	mov ah,0ch ;bill. bufffer t�rl�se
	mov al,0ah ;string beolvas�sa
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bx,bx ;bx null�z�sa
cik2:
	cmp buffer[bx+2],30h ;kisebb az aktu�lisan n�zett karakter  mint 30h=�0�?
	jb go1 ;ha igen, az akkor nem sz�m
	cmp buffer[bx+2],39h ;nagyobb az aktu�lisan n�zett karakter mint 39h=�9�?
	ja go1 ;akkor az nem sz�m
	inc bl ;bl a k�v. karakterre mutassson
	cmp bl,buffer[1] ;megn�zz�k bl=a beolvasott karakterek  sz�m�val?
	jb cik2 ;ha kevesebb ism�tl�nk

;ha ide eljutunk a buffer minden egyes beolvasott karaktere  sz�m
	
	mov si,offset buffer+1 ;si-be buffer+1 offsetc�m, l�sd  asciibin proc. bemente
	call asciibin ;megh�vjuk az asciiibin proc., ezzel  alak�tjuk �t a beolvasott karaktereket sz�mm�
	
	cmp ax,40 ;megn�zz�k nem nagyobb-e a beolvasott sz�m mint  40
	ja go1 ;ha nagyobb ugrunk
	cmp al,0 ;nulla se lehet...
	je go1
	cmp buffer[1],0 ;ha nem volt beolvasott karakter
	je go1 ;akkor is ugrunk
	jmp go2 ;ha egyik se teljes�lt, akkor megy�nk tov�bb

go1:
	kiir hibauz1 ;ki�rjuk a hiba�zit
	jmp cik1 ;vissza a beolvas�sra

go2:
	mov si,index ;elmentj�k a sz�mot
	mov buffer_save[si-1],al ;a buffer_save-ba
	inc index ;index eggyel nagyobb
	cmp index,3 ;index=3?
	jbe cik1 ;ha kisebb vagy egyenl� mint 3, akkor ism�tl�nk

	xor bx,bx ;bx null�z�sa
	
	mov al,buffer_save[0] ;al-be az els� sz�m
	mov bl,buffer_save[1] ;bl-be a m�sik
	mul bl ;szorozzuk az al-t bl-el
	mov bl,buffer_save[2] ;a bl-be a harmadik sz�m, bh-t el�bb  null�ztuk
	mul bx ;ax-et szorozzuk bx-el
	push ax ;elmentj�k a kapott sz�mot a verembe
	
	kiir text3 ;ki�rjuk a text3-at
	
	pop ax ;visszahozzuk a sz�mot
	call binascii ;�s ki�rjuk
	
	kiir text4 ;majd ki�rjuk a text4-et
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�runk egy karakterre
	int 21h
	
	mov ah,4ch ;a vez�rl�s visszaad�sa a DOS-nak
	int 21h

code ends ;code szegmens v�ge
	end start ;start cimk�n�l kezd�nk