;Program 17

;Írjon programot, amely átnevez egy állományt. Az állomány régi és új nevét kérje be a billentyûzetrõl.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code,es:code ;hozzárendelés

;változók
oldname	db 65,0,65 dup(0) ;a régi név tárolására
newname db 65,0,65 dup(0) ;az új név tárolására
text1 db 'Regi nev: $' ;szövegek
text2 db 13,10,'Uj nev: $'
text3 db 13,10,'A muvelet sikeresen elvegezve!$'
hibauz1 db 13,10,'A muvelet vegrehajtasa kozben hiba keletkezett!$'

;macro string kiírására
kiir macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm ;macro vége
	
;macro szöveg beolvasására
beolvas macro mibe
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah
	mov dx,offset mibe ;hova mentjük
	int 21h
	endm

;a megadott string végére egy 0-t tesz
vegenulla macro minek
	push bx ;elmentjük a bx-et
	xor bh,bh ;a bh-t nullázzuk
	mov bl,minek[1] ;a második bájtja a string hossza
	mov minek[bx+2],0 ;itt tesszük a végére a nullát
	pop bx ;visszatesszük a bx-et
	endm ;macro vége

;fõprogram
start:
	mov ax,cs ;szegmenscímek beállítása
	mov ds,ax ;adatszegmens
	mov es,ax ;extraszegmens
	cld ;df nullázása
	
	kiir text1 ;text1 kiírása
	beolvas oldname ;régi fájlnév beolvasása
	vegenulla oldname ;a végére egy nulla, lásd ASCIIZ
	
	kiir text2 ;ugyanez csak az új névvel
	beolvas newname
	vegenulla newname

	mov ah,56h ;evvel a szolg. nevezem át
	mov dx,offset oldname[2] ;csak a 3. bájttól van a fájlnév
	mov di,offset newname[2] ;ugyanúgy
	int 21h
	jc hiba ;ha hiba akkor azt írjuk ki hogy hiba
	
	kiir text3 ;ha nem, akkor azt, hogy sikeres
	jmp vege
	
hiba:	
	kiir hibauz1
	
vege:
	mov ah,4ch ;a vezérlés visszaadása az op.-nek
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimke a program belépési pontja