;Program 18

;�rjon programot, amely megjelen�ti a billenty�zetr�l megadott sz�m� kiszolg�l� alprogram logikai c�m�t hexadecim�lisan �s dekadikusan.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
text1 db 'Alprogram logikai cime'
      db 13,10,'**********************$'
text2 db 13,10,'Add meg az alprogram szamat (0-255): $'
text3 db 13,10,13,10,'A megadott alprogram logikai cime:'
      db 13,10,'**********************************'
      db 13,10,'Decimalis    : $'
text4 db 13,10,'Hexadecimalis: $'
text5 db 13,10,'**********************************'
      db 13,10,13,10,'Nyomj le barmilyen billentyut a kilepeshez...$'
hibauz1 db 13,10,'Az alprogram szama 0-255!$'
buffer db 4,0,4 dup(0) ;buffer a sz�m beolvas�s�ra
szam dw ? ;ide mentj�k a beolvasott sz�mot
szegmens dw ? ;ide a kiolvasott szegmensc�met
offsetcim dw ? ;ide a kiolvasott offsetc�met

;macor egy string ki�r�s�ra
kiir macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm

;macro egy karakter ki�r�s�ra
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm

;proced�ra egy bin�ris sz�m ki�r�s�ra
binascii proc near ;bemenet ax
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;az oszt�s el�tt dx-et null�zni

cikp11:
	div bx ;osztjuk az ax-et bx-el
	mov si,dx ;a marad�kot az si-be

	mov ah,2 ;ki�rjuk az al-ben megkapott sz�mjegyet
	mov dl,al
	add dl,30h ;ASCII karakter!, ez�rt kell a +30h
	int 21h

	mov ax,bx ;az oszt�t 10-zel osztjuk
	mov bx,10 ;10-zel
	xor dx,dx ;mint fent
	div bx ;osztjuk akkor v�gre
	cmp ax,1 ;megn�zz�k ax=1?
	jb vegep1 ;ha kisebb mint 1, akkor v�ge
	mov bx,ax ;az oszt�t a bx-be
	mov ax,si ;vissza a marad�kot az ax-be
	jmp cikp11 ;vissza az elej�re

vegep1:
	ret ;visszat�r�s a f�programba

binascii endp

;proced�ra hexadecim�lis ki�r�sra
hexascii proc near ;bemenet ax	
	jmp startp2 ;�tugorjuk a v�ltoz�kat

s1 db ? ;ennyivel fogjuk shiftelni az ax-et
char db ? ;ide tessz�k a kapott karaktert
temp dw ? ;t�roljuk az ax-et

startp2:
	mov bx,0f000h ;a bx-ben lesz a maszk, amivel mindig  ki�tjuk az ax bizonyos bitjeit,mindig csak 4 fog maradni, ez  jelentve egy sz�mjegyeet
	mov s1,16 ;el�sz�r ennyivel shiftelj�k az ax-et
	mov temp,ax ;elmentj�k az ax-et
	
cikp21:
	mov ax,temp ;minden ciklus elej�n visszatessz�k az ax  eredeti tartalm�t
	sub s1,4 ;az s1-b�l levonunk 4-et, mert minden egyes fut�s  ut�n 4-el kevesebbszer kell shiftelni
	
	and ax,bx ;na itt �tj�k ki az ax bizonyos bitjeit
	mov cl,s1
	shr ax,cl ;�s shiftelj�k s1-el
	mov char,al ;�gy a 4 bit �tker�l az al alj�ra, el tudjuk  m�r menteni

	mov cl,4 ;a bx-et is �arr�bb� kell tenni
	shr bx,cl
	
	cmp char,9 ;megn�zz�k, hogy a karakter, amit kaptunk  nagyobb mint 9?
	ja gop21 ;ha igen akkor valami A,B,C,... kell ki�rni, teh�t elugrunk
	
	add char,30h ;ha ide eljutunk, akkor sz�mjegyet �runk ki
	putchar char ;ki�rjuk
	
	jmp gop22 ;megy�nk a gop22-re 
	
gop21:
	add char,37h ;itt �rjuk bet�ket
	putchar char ;na akkor �rjuk

gop22:
	cmp s1,0 ;s1 m�r nulla?
	jne cikp21 ;ha nem akkor m�g ism�tl�nk
	
	putchar 'h' ;a v�g�n kitesz�nk egy h-t
	ret ;visszat�r�nk
hexascii endp ;a proc. v�ge

;proc. ascii-bin�ris �talak�t�sra
;a beolvasott karakter �talak�t�s�ra
asciibin proc near ; bemenet si - mutato buffer+1
                   ; kimenet ax - bin ertek

	mov cl,byte ptr[si] ;a beolvasott karakterek sz�m�t  elmentj�k a cl-be 
	xor ax,ax ;ax-et null�zzuk
	cmp cl,0 ;ha nem volt beolvasott karakter, null�t adunk  vissza
	ja gop31 ;ha volt akkor, tov�bb
	ret ;visszat�r�nk

gop31:	
	mov bx,10 ;10-el fogunk szorozni
	
cikp31:	
	mul bx ;dx nullazva, szorozzuk az ax-et
	inc si ;si n�vel�se 1-el
	mov dl,byte ptr[si] ;dl-be az aktu�lis karakter
	sub dl,30h ;levonunk bel�le 30h-t, ASCII!
	add ax,dx ;hozz�adjuk az ax-hez
	dec cl ;cl dekrement�l�sa
	jnz cikp31 ;addig m�g cl nulla nem lesz

	ret ;visszat�r�s a f�programba

asciibin endp ;proc. v�ge

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa

	mov ax,3 ;k�perny� let�rl�se, 80x25-�s m�dba val� l�p�ssel
	int 10h	
	
	kiir text1 ;ki�rjuk a kezdeti dolgokat

cik1:	
	kiir text2 ;ki�rjuk, hogy add meg a sz�mot
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;karakterek beolvas�sa a bill.-r�l
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bx,bx ;a bx t�rl�se
cik2:
	cmp buffer[bx+2],30h ;megn�zz�k itt, hogy mindegyik  beolvasott karakter sz�m volt-e
	jb go1 ;ha nem, ugrunk a go1-re, ahol ki�rjuk, hogy hiba, �s megadja �jb�l
	cmp buffer[bx+2],39h
	ja go1
	inc bl
	cmp bl,buffer[1]
	jb cik2
		
	mov si,offset buffer+1
	call asciibin ;�talak�tjuk a buffer-ban l�v� karaktereket  sz�mm�
	
	cmp ax,00ffh ;megn�zz�k nem adott-e t�l nagy sz�mot, 
;255-n�l nagyobbat
	ja go1 ;ha igen, hiba
	cmp buffer[1],0 ;ha nem adott meg sz�mot, hiba
	je go1
	jmp go2
	
go1:
	kiir hibauz1 ;itt �rjuk ki a hiba�zit
	jmp cik1 ;�s visszak�ldj�k az elej�re

go2:	
	mov szam,ax ;a sz�mot elmenjt�k az ax-be
	
	mov ax,0000h ;ax-be nulla
	mov es,ax ;ezt az es-be
	
	mov cl,2 ;a szam-ot megszorozzuk kett�vel
	shl szam,cl
	
	mov si,szam ;si-be a szam
	
	mov ax,word ptr es:[si] ;na itt hozzuk be az ax-be az  offsetc�met
	mov offsetcim,ax ;�s elmentj�k az offsetcim nev� v�ltoz�ba
	mov ax,word ptr es:[si+2] ;ez ugyanaz csak a  szegmensc�mmel, l�sd a megszak�t�svektor-t�bl�zat
	mov szegmens,ax

;most m�r csak ki�rjuk
	kiir text3 ;ki�rjuk, hogy decim�lis
	mov ax,szegmens ;�tvissz�k ax-be
	call binascii ;ki�rjuk
	putchar ':' ;ki�runk egy kett�spontot
	mov ax,offsetcim ;ki�rjuk az offsetet is
	call binascii
	
	kiir text4 ;ugyanaz pepit�ba � hex�ba
	mov ax,szegmens
	call hexascii
	putchar ':'
	mov ax,offsetcim
	call hexascii

	kiir text5 ;ki�rjuk, hogy nyomj b�rmilyen bill.-t
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�runk egy bill.-re
	int 21h
	
	mov ah,4ch ;vez�rl�s vissza az op.-nek
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk