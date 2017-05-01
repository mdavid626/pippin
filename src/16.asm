;Program 16

;�rjon programot, amely kinyomtat egy �llom�nyt. Az �llom�ny nev�t k�rje be a billenty�zetr�l.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
buffer db 65,0,65 dup(0) ;buffer a f�jl nev�re
kar db ? ;egy karaktert olvasunk mindig a f�jlb�l, ide mentj�k
text1 db 'Fajl: $' ;sz�vegek, amiket ki�runk a k�perny�re
text2 db 13,10,'Press any key...$'
text3 db 13,10,'A nyomtatas kesz!$'
hibauz1 db 13,10,'Nem talalom az utat$'
hibauz2 db 13,10,'Hozzaferes megtagadva!$'
hibauz3 db 13,10,'A fajl nem letezik!$'
hibauz4 db 13,10,'Szamomra ismeretlen hiba$$'
file dw ? ;FILE HANDLE elment�s�re
szemafor db 0 ;szemafor � volt-e megnyitva f�jl

;macor string ki�r�s�ra
pstring macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa

	pstring text1 ;text1 ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;string beolvas�sa
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bh,bh ;bh null�z�sa
	mov bl,buffer[1] ;mennyi karaktert olvastunk be ? bl-be
	mov buffer[bx+2],0 ;a v�g�re egy nulla

	mov ah,3dh ;f�jl megnyit�sa
	xor al,al ;csak olvas�sra
	mov dx,offset buffer[2] ;a buffer 3. b�jtj�t�l a f�jln�v
	int 21h
	jc hiba ;ha hiba, ugorj
	mov file,ax ;FILE HANDLE elment�se
	mov szemafor,1 ;szem. egyesbe
	
cik1:
	mov ah,3fh ;olvasunk
	mov bx,file ;a f�jlb�l
	mov cx,1 ;egy b�jtot
	mov dx,offset kar ;a kar-ba
	int 21h
	jc hiba ;ha nem siker�lt, hiba
	cmp ax,0 ;ha ax=0, f�jlv�ge
	jz veg

	mov ah,5 ;ki�rjuk a nyomd�ra, LPT1
	mov dl,kar ;a kar-t
	int 21h
	
	jmp cik1 ;�s vissza az elej�re, a cmp ax,0 // jz veg enged  ki

veg:
	mov ah,5 ;m�g ki�runk egy 13,10-et, hogy a buffer-ba lev�  dolgokat kinyomtassa
	mov dl,13
	int 21h
	mov dl,10
	int 21h
	
	pstring text3 ;text3 ki�r�sa
	jmp vege ;a hiba�zik �tugr�sa

hiba:
	cmp ax,3 ;ax=3?
	jz hiba1 ;ezek alapj�n kezelj�k le a hib�t
	cmp ax,5
	jz hiba2
	cmp ax,2
	jz hiba3
	
	pstring hibauz4 ;ha egyik se, ismeretlen
	jmp vege
	
hiba1:
	pstring hibauz1
	jmp vege
	
hiba2:
	pstring hibauz2
	jmp vege

hiba3:
	pstring hibauz3

vege:
	pstring text2
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy karakterre echo n�lk�l
	int 21h
	
	cmp szemafor,0 ;volt megnyitott f�jl?
	jz abort

	mov ah,3eh ;ha igen, lez�rjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;vez�rl�s vissza az op.-nek
	int 21h

code ends ;code szegmens v�ge
	end start ;start cimk�n�l kezd�nk