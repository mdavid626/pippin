;Program 25

;�rjon programot, amely ki�rja a k�perny�re az �sszes �llom�nyt az aktu�lis mapp�b�l, amely megfelelnek a bill. megadott maszknak.

code segment ;code	szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
dta db 128 dup(0) 
buffer db 13,0,13 dup(0) ;8+11 + pont meg az ENTER
newline db 13,10,36 ;�jsor
text1 db 'Maszk: $' 
text2 db 13,10,'Az aktualis mappaban talalhato fajlok:$'
hibauz1 db 13,10,'Nem talalhato fajl!$'
hibauz2 db 13,10,'Nem adtal meg maszkot!',13,10,36

start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	mov ah,1ah ;dta be�ll�t�sa
	mov dx,offset dta
	int 21h

cik1:
	mov ah,9 ;ki�rjuk a text1-et
	mov dx,offset text1
	int 21h
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;karakterek beolvas�sa bill.-r�l
	mov dx,offset buffer
	int 21h
	
	cmp buffer[1],0 ;megn�zz�k a volt-e beadva karakter
;vagy csak ENTER volt le�tve
	jnz go1 ;ha nem csak ENTER megy�nk tov�bb
	
	mov ah,9 ;ha csak ENTER, hiba�zi
	mov dx,offset hibauz2
	int 21h
	jmp cik1 ;�s nyom�s vissza az elej�re
	
go1:
	xor bh,bh ;bh=0
	mov bl,buffer[1] ;bl-be bevissz�k mennyi kar. volt  beolvasva
	mov buffer[bx+2],0 ;a v�g�re dobunk egy 0-at
	
	mov ah,9 ;ki�rjuk a text2-t
	mov dx,offset text2
	int 21h
	
	mov ah,4eh ;megkeress�k az els� f�jlt
	mov dx,offset buffer[2] ;els� k�t b�jtot �t kell ugornunk
	mov cx,0 ;normal f�jlokat keres�nk
	int 21h
	jc hiba ;ha hiba t�rt�nt, ugrunk

cik2:	
	mov si,1eh ;dta-ba ett�l a c�mt�l kezd�dik a f�jln�v

	mov ah,9 ;ki�runk egy �jsort
	mov dx,offset newline
	int 21h
	
cik3: 
	mov ah,2 ;�s elkezdj�k ki�rni a f�jlnevet
	mov dl,byte ptr dta[si]
	int 21h
	inc si ;mindig a k�v. b�jtra �ll�tjuk az si-t
	cmp byte ptr dta[si],0 ;megn�zz�k nincs-e m�g v�ge
	jnz cik3 ;ha nincs akkor ki�rjuk

	mov ah,4fh ;keress�k a k�v. f�jlt
	int 21h
	jnc cik2 ;ha tal�lt f�jlt, azt ki�rjuk, sz�val vissza  cik2-re

	jmp vege ;itt ugrunk m�r a v�g�re, �tugorjuk a hiba�ziket

hiba:	
	mov ah,9 ;ki�rjuk a hiba�zit
	mov dx,offset hibauz1
	int 21h

;itt a v�ge, fuss el v�le
vege:
	mov ah,4ch ;korrekt�l befejezz�k a programot
	int 21h

code ends ;code szegmens v�ge
	end start ;start cimk�n�l kezd�nk