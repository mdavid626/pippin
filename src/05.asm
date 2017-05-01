;Program 05

;�jon programot, amely megjelen�t a k�perny� monitor�n egy n�gyjegy� dekadikus sz�ml�l�t, amely 0-t�l 9999-ig sz�mol. Az ESC lenyom�s�ra a program v�get�r.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s
	
;v�ltoz�k
szam dw 0

;proc. bin�ris sz�m ASCII k�dban val� ki�r�s�ra
binascii proc near ;bemenet ax
	jmp binascii_start ;�tugorjuk a flag v�ltoz�t
	
flag db ?
	
binascii_start:
	mov flag,0 ;ez nek�nk az�rt kell, hogy csak max 4  sz�mjegyet �rjunk ki, ne �t�t, szal az els�t egyszer�en nem  �rjuk ki... :D lehetne m�sk�pp is, �gy egyszer�bb
	mov bx,10000 ;10000 osztunk
	xor dx,dx ;null�zni kell az oszt�s el�tt
	
binascii_cik1:	
	div bx ;ax oszt�sa bx-el
	mov si,dx ;marad�k si-be

	cmp flag,0 ;flag=0?
	je binascii_go1 ;ha igen akkor ugrunk
	
	mov ah,2 ;ha nem ki�runk
	mov dl,al ;egy sz�mjegyet
	add dl,30h ;el�tt hozz� kell adni 30h, ASCII!
	int 21h
	
binascii_go1:
	mov flag,1 ;most m�r flag egyesbe
	mov ax,bx ;bx-et 10-zel elosztjuk
	mov bx,10
	xor dx,dx
	div bx ;az oszt�s kinull�zza a dx-et, nincs marad�k
	cmp ax,1 ;ax=1?
	jb binascii_vege ;ha kisebb, akkor v�ge
	mov bx,ax ;ha nem, akkor az oszt� vissza a bx-be
	mov ax,si ;si-b�l meg az ax-be vissza a marad�k
	jmp binascii_cik1

binascii_vege:
	ret
binascii endp

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	mov ax,3 ;k�perny� t�rl�se, 80x25-�s m�dba val� l�p�ssel
	int 10h
	
	mov ah,1 ;kurzor elt�ntet�se
	mov ch,20h
	int 10h
	
cik1:
	mov ah,2 ;kurzor a 0,0-�s poz�ci�ra
	xor bh,bh
	xor dx,dx
	int 10h
	
	mov ax,szam ;ki�rjuk a szam-ot
	call binascii
	
	mov ah,86h ;v�runk 500 ms-t
mov cx,7
mov dx,0a120h
int 15h
	
	mov ah,6 ;valaki le�t�tt egy bill.-t
	mov dl,0ffh
	int 21h
	cmp al,27 ;az ESC volt az?
	jz vege ;ha igen, kil�p�nk
	
	inc szam ;szam-ot megn�velj�k
	cmp szam,10000	;megn�zz�k nem vagyunk-e m�g a v�g�n
	jb cik1

	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy bill.-re
	int 21h
	
vege:
	mov ah,1 ;kurzor unhide
	mov cx,1f0eh
	int 10h
	
	mov ah,4ch ;vez�rl�s visszaad�sa az op.-nek
	int 21h
	
code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk