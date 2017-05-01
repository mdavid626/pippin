;Program 14

;�rjon programot, amely sz�veges �llom�nyt b�v�ti egy a billenty�zetr�l beadott sorral. A f�jl nev�t k�rje be a billenty�zetr�l. Ha nem l�tezik, akkor jelen�tsen meg hiba�zenetet.

code segment ;code szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
buffer db 255,0,255 dup(0)
newline db 13,10,36
text1 db 'File: $'
text2 db 13,10,'Add text: ',13,10,36
text3 db 13,10,'The operation was successful!$'
hibauz1 db 13,10,'Cant find the path!$'
hibauz2 db 13,10,'Access denied!$'
hibauz3 db 13,10,'File doesnt exist!$'
hibauz4 db 13,10,'Unknown error!$'
file dw ?
szemafor db 0

start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa

	mov ah,9 ;ki�rjuk a text1-et
	lea dx,text1
	int 21h

	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;karakterek beolvas�sa a �buffer�-ba
	lea dx,buffer
	int 21h

	xor bh,bh ;bh null�z�sa
	mov bl,buffer[1] ;bl-be beolvasott karakterek sz�ma
	mov buffer[bx+2],0 ;a v�g�re egy nulla
	
	mov ah,3dh ;f�jl megnyit�sa
	lea dx,buffer[2] ;az els� k�t b�jtot �tugorjuk
	mov al,1 ;�rni akarunk a f�jlba
	int 21h
	jc hiba ;ha hiba, ugrunk
	mov file,ax ;elmentj�k a FILE HANDLE-t
	mov szemafor,1 ;igen, van megnyitott f�jl

	mov ah,42h ;be�ll�tjuk a f�jlmutat�t
	mov al,2 ;a v�g�t�l sz�m�tva
	mov bx,file
	xor dx,dx ;nulla eltol�s
	xor cx,cx ;nulla eltol�s, teh�t a v�g�n �ll a f�jlmutat�
	int 21h
	jc hiba ;ha hiba t�rt�nt ugrunk

	mov ah,9 ;ki�rjuk a text2-t
	lea dx,text2
	int 21h

	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;kar. beolvas�sa
	lea dx,buffer ;a bufferba
	int 21h

	mov ah,40h ;�runk a f�jlba
	mov bx,file 
	mov cx,2 ;2 b�jtot
	lea dx,newline ;�j sort
	int 21h
	jc hiba ;ha nem siker�lt, ugrunk

	mov ah,40h ;megint �runk
	mov bx,file
	xor ch,ch ;a ch-t null�zzuk
	mov cl,buffer[1] ;a beolvasott kar. sz�m�nak megfelel�  b�jtot �runk a f�jlba
	lea dx,buffer[2] ;els� k�t b�jt �tugorva
	int 21h
	jc hiba ;ha hiba, ugrunk
	
	mov ah,9 ;ki�rjuk a text3-at
	lea dx,text3
	int 21h
	
	jmp vege ;ugrunk a v�g�re

hiba:
	cmp ax,3 ;hib�k lekezel�se, meg�llap�tjuk, mennyi volt az  ax-be
	jz hiba1 ;�s aszerint ugrunk
	cmp ax,5
	jz hiba2
	cmp ax,2
	jz hiba3

	mov ah,9 ;ki�rjuk, hogy ismeretlen hiba...
	lea dx,hibauz4
	int 21h
	jmp vege

hiba1:
	mov ah,9 ;itt meg ki�rjuk a megfelel� hiba�zit
	lea dx,hibauz1
	int 21h
	jmp vege

hiba2:
	mov ah,9
	lea dx,hibauz2
	int 21h
	jmp vege

hiba3:
	mov ah,9
	lea dx,hibauz3
	int 21h

;itt a v�ge, fuss el v�le
vege:
	cmp szemafor,1 ;ha volt megnyitott f�jl, be kell z�rni
	jnz vege_v ;ha nem, h�t nem
	
	mov ah,3eh ;itt z�rjuk be
	mov bx,file
	int 21h

vege_v:
	mov ah,4ch ;vez�rl�s vissza op.-nek
	int 21h
code ends ;code szegmens v�ge
	end start ;start cimk�n�l kezd�nk