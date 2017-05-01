;Program 17

;�rjon programot, amely �tnevez egy �llom�nyt. Az �llom�ny r�gi �s �j nev�t k�rje be a billenty�zetr�l.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code,es:code ;hozz�rendel�s

;v�ltoz�k
oldname	db 65,0,65 dup(0) ;a r�gi n�v t�rol�s�ra
newname db 65,0,65 dup(0) ;az �j n�v t�rol�s�ra
text1 db 'Regi nev: $' ;sz�vegek
text2 db 13,10,'Uj nev: $'
text3 db 13,10,'A muvelet sikeresen elvegezve!$'
hibauz1 db 13,10,'A muvelet vegrehajtasa kozben hiba keletkezett!$'

;macro string ki�r�s�ra
kiir macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm ;macro v�ge
	
;macro sz�veg beolvas�s�ra
beolvas macro mibe
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah
	mov dx,offset mibe ;hova mentj�k
	int 21h
	endm

;a megadott string v�g�re egy 0-t tesz
vegenulla macro minek
	push bx ;elmentj�k a bx-et
	xor bh,bh ;a bh-t null�zzuk
	mov bl,minek[1] ;a m�sodik b�jtja a string hossza
	mov minek[bx+2],0 ;itt tessz�k a v�g�re a null�t
	pop bx ;visszatessz�k a bx-et
	endm ;macro v�ge

;f�program
start:
	mov ax,cs ;szegmensc�mek be�ll�t�sa
	mov ds,ax ;adatszegmens
	mov es,ax ;extraszegmens
	cld ;df null�z�sa
	
	kiir text1 ;text1 ki�r�sa
	beolvas oldname ;r�gi f�jln�v beolvas�sa
	vegenulla oldname ;a v�g�re egy nulla, l�sd ASCIIZ
	
	kiir text2 ;ugyanez csak az �j n�vvel
	beolvas newname
	vegenulla newname

	mov ah,56h ;evvel a szolg. nevezem �t
	mov dx,offset oldname[2] ;csak a 3. b�jtt�l van a f�jln�v
	mov di,offset newname[2] ;ugyan�gy
	int 21h
	jc hiba ;ha hiba akkor azt �rjuk ki hogy hiba
	
	kiir text3 ;ha nem, akkor azt, hogy sikeres
	jmp vege
	
hiba:	
	kiir hibauz1
	
vege:
	mov ah,4ch ;a vez�rl�s visszaad�sa az op.-nek
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimke a program bel�p�si pontja