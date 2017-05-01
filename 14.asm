;Program 14

;Írjon programot, amely szöveges állományt bõvíti egy a billentyûzetrõl beadott sorral. A fájl nevét kérje be a billentyûzetrõl. Ha nem létezik, akkor jelenítsen meg hibaüzenetet.

code segment ;code szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
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
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása

	mov ah,9 ;kiírjuk a text1-et
	lea dx,text1
	int 21h

	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;karakterek beolvasása a „buffer”-ba
	lea dx,buffer
	int 21h

	xor bh,bh ;bh nullázása
	mov bl,buffer[1] ;bl-be beolvasott karakterek száma
	mov buffer[bx+2],0 ;a végére egy nulla
	
	mov ah,3dh ;fájl megnyitása
	lea dx,buffer[2] ;az elsõ két bájtot átugorjuk
	mov al,1 ;írni akarunk a fájlba
	int 21h
	jc hiba ;ha hiba, ugrunk
	mov file,ax ;elmentjük a FILE HANDLE-t
	mov szemafor,1 ;igen, van megnyitott fájl

	mov ah,42h ;beállítjuk a fájlmutatót
	mov al,2 ;a végétõl számítva
	mov bx,file
	xor dx,dx ;nulla eltolás
	xor cx,cx ;nulla eltolás, tehát a végén áll a fájlmutató
	int 21h
	jc hiba ;ha hiba történt ugrunk

	mov ah,9 ;kiírjuk a text2-t
	lea dx,text2
	int 21h

	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;kar. beolvasása
	lea dx,buffer ;a bufferba
	int 21h

	mov ah,40h ;írunk a fájlba
	mov bx,file 
	mov cx,2 ;2 bájtot
	lea dx,newline ;új sort
	int 21h
	jc hiba ;ha nem sikerült, ugrunk

	mov ah,40h ;megint írunk
	mov bx,file
	xor ch,ch ;a ch-t nullázzuk
	mov cl,buffer[1] ;a beolvasott kar. számának megfelelõ  bájtot írunk a fájlba
	lea dx,buffer[2] ;elsõ két bájt átugorva
	int 21h
	jc hiba ;ha hiba, ugrunk
	
	mov ah,9 ;kiírjuk a text3-at
	lea dx,text3
	int 21h
	
	jmp vege ;ugrunk a végére

hiba:
	cmp ax,3 ;hibák lekezelése, megállapítjuk, mennyi volt az  ax-be
	jz hiba1 ;és aszerint ugrunk
	cmp ax,5
	jz hiba2
	cmp ax,2
	jz hiba3

	mov ah,9 ;kiírjuk, hogy ismeretlen hiba...
	lea dx,hibauz4
	int 21h
	jmp vege

hiba1:
	mov ah,9 ;itt meg kiírjuk a megfelelõ hibaüzit
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

;itt a vége, fuss el véle
vege:
	cmp szemafor,1 ;ha volt megnyitott fájl, be kell zárni
	jnz vege_v ;ha nem, hát nem
	
	mov ah,3eh ;itt zárjuk be
	mov bx,file
	int 21h

vege_v:
	mov ah,4ch ;vezérlés vissza op.-nek
	int 21h
code ends ;code szegmens vége
	end start ;start cimkénél kezdünk