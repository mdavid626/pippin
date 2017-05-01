;Program 05

;Íjon programot, amely megjelenít a képernyõ monitorán egy négyjegyû dekadikus számlálót, amely 0-tól 9999-ig számol. Az ESC lenyomására a program végetér.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés
	
;változók
szam dw 0

;proc. bináris szám ASCII kódban való kiírására
binascii proc near ;bemenet ax
	jmp binascii_start ;átugorjuk a flag változót
	
flag db ?
	
binascii_start:
	mov flag,0 ;ez nekünk azért kell, hogy csak max 4  számjegyet írjunk ki, ne ötöt, szal az elsõt egyszerûen nem  írjuk ki... :D lehetne másképp is, így egyszerûbb
	mov bx,10000 ;10000 osztunk
	xor dx,dx ;nullázni kell az osztás elõtt
	
binascii_cik1:	
	div bx ;ax osztása bx-el
	mov si,dx ;maradék si-be

	cmp flag,0 ;flag=0?
	je binascii_go1 ;ha igen akkor ugrunk
	
	mov ah,2 ;ha nem kiírunk
	mov dl,al ;egy számjegyet
	add dl,30h ;elõtt hozzá kell adni 30h, ASCII!
	int 21h
	
binascii_go1:
	mov flag,1 ;most már flag egyesbe
	mov ax,bx ;bx-et 10-zel elosztjuk
	mov bx,10
	xor dx,dx
	div bx ;az osztás kinullázza a dx-et, nincs maradék
	cmp ax,1 ;ax=1?
	jb binascii_vege ;ha kisebb, akkor vége
	mov bx,ax ;ha nem, akkor az osztó vissza a bx-be
	mov ax,si ;si-bõl meg az ax-be vissza a maradék
	jmp binascii_cik1

binascii_vege:
	ret
binascii endp

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása
	
	mov ax,3 ;képernyõ törlése, 80x25-ös módba való lépéssel
	int 10h
	
	mov ah,1 ;kurzor eltüntetése
	mov ch,20h
	int 10h
	
cik1:
	mov ah,2 ;kurzor a 0,0-ás pozícióra
	xor bh,bh
	xor dx,dx
	int 10h
	
	mov ax,szam ;kiírjuk a szam-ot
	call binascii
	
	mov ah,86h ;várunk 500 ms-t
mov cx,7
mov dx,0a120h
int 15h
	
	mov ah,6 ;valaki leütött egy bill.-t
	mov dl,0ffh
	int 21h
	cmp al,27 ;az ESC volt az?
	jz vege ;ha igen, kilépünk
	
	inc szam ;szam-ot megnöveljük
	cmp szam,10000	;megnézzük nem vagyunk-e még a végén
	jb cik1

	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy bill.-re
	int 21h
	
vege:
	mov ah,1 ;kurzor unhide
	mov cx,1f0eh
	int 10h
	
	mov ah,4ch ;vezérlés visszaadása az op.-nek
	int 21h
	
code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk