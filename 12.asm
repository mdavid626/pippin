;Program 12

;Írjon programot a szöveges állományok megjelenítésére a képernyõn. Az állomány nevét kérje be a billentyûzetrõl. Ha a megadott állomány nem létezik, jelenítsen meg hibaüzenetet: "A megadott állomány nem létezik!". A képernyõ betelésekor az utolsó sorban jelenítse meg: "Üss le egy billentyût a folytatáshoz...". 

code segment ;code szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
buffer_file db ?
buffer_key db 65,0,65 dup(0)
text1 db 'File: $'
text2 db 13,10,'Press any key to continue or q to terminate... $'
text3 db 13,10,'Press any key to terminate... $'
hibauz1 db 13,10,'Cant find the path$'
hibauz2 db 13,10,'Access denied!$'
hibauz3 db 13,10,'The file doesnt exist!$'
hibauz4 db 13,10,'Unknown error$'
file dw ?
szemafor db 0

;egy egyszerû procedúra, kiírja a képernyõre a dx-be megadott stringet, majd pedig vár egy bill. leütésére
waitproc proc near ; bemenet: dx, kimenet: con, al
	mov ah,9 ;kiírjuk
	int 21h
	
	mov ah,0ch ;töröljük a buffert
	mov al,07h ;várunk egy bill.-re
	int 21h
	ret ;visszatérünk
waitproc endp
	
start:
	mov ax,cs ;adatszegmens beállítása
	mov ds,ax
	cld ;df nullázása, string kiírás miatt

	mov ah,9 ;kiírjuk a kezdõszöveget
	lea dx,text1 ;bevisszük a dx-be a text1 offsetcímét
	int 21h
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;fájlnév beolvasása
	lea dx,buffer_key 
	int 21h
	
	xor bh,bh ;bh törlése
	mov bl,buffer_key[1] ;bevisszük bl-be hány karaktert olvastunk be
	mov buffer_key[bx+2],0 ;a buffer végére teszünk egy 0-at

	mov ah,3dh ;megnyitjuk a fájlt
	xor al,al ;normal fájl
	lea dx,buffer_key 
	add dx,2 ;az elsõ két bájtot átugorjuk
	int 21h
	jc hiba ;ugrunk, ha hiba van
	mov file,ax ;elmentjuk a FILE HANDLE-t
	mov szemafor,1 ;szemafor egyesbe, mert van megnyitott fájl
	
	mov ax,3 ;töröljük a képernyõt, 80x25 módba váltással
	int 10h
	
cik1:
	mov ah,3fh ;olvasunk a fájlból
	mov bx,file ;FILE HANDLE bevitele bx-be
	mov cx,1 ;1 bájtot fogunk olvasni
	lea dx,buffer_file ;ide fogunk olvasni
	int 21h
	jc hiba ;hiba - ugrunk
	cmp ax,0 ;ha ax = 0 és nem volt hiba, EOF – vége a fájlnak
	jz vege ;tehát befejezzük a programot
	
	mov ah,3 ;megnézzük a képernyõ hányadik sorába vagyunk
	mov bh,0 ;nulladik „lapon” vagyunk
	int 10h
	cmp dh,23 ;ha a 24. sorba vagyunk „figyelünk”
	jz felt1 ;megnézzük, hogy mi teljesül még
	jmp ird ;ha nem a 24. sorba kiírjuk a beolvasott bájtot
	
felt1:
	cmp dl,79 ;vizsgálódunk tovább, 80. oszlopba vagyunk
	jz varj ;ha igen, ez azt jelenti: 24. sor 80. oszlop > kiírjuk a „Press any key to continue”-t
	cmp buffer_file,10 ;az is fontos, hogy ha nem is vagyunk a 80. oszlopba, ha a fájlban új sort kezdünk, már akkor is ki kell írni a szöveget
	jz varj
	
ird:	
	mov ah,2 ;kiírjuk a beolvasott bájtot
	mov dl,buffer_file
	int 21h
	jmp cik1 ;újra elõre és olvasunk

varj:
	lea dx,text2 ;megadjuk, hogy mit akarunk kiírni
	call waitproc ;kiírjuk és várunk
	cmp al,'q' ;megnézzük, mit nyomtunk le
	jz abort ;ha q-t kilépünk
	
	mov ax,3 ;töröljük a képernyõt, 80x25-s módba való lépéssel
	int 10h
	
	cmp buffer_file,10 ;ha új sort kezdtünk a fájlba, ezt nem írjuk ki az új képernyõre
	jnz ird
	jmp cik1 ;újra elõre és olvasunk
	
hiba:
	cmp ax,3 ;megnézzük milyen hiba keletkezett
	jz hiba1 ;és aszerint ugrunk
	cmp ax,5
	jz hiba2
	cmp ax,2
	jz hiba3
	
	mov ah,9 ;ha egyik se, kiírjuk, hogy ismeretlen
	lea dx,hibauz4
	int 21h
	jmp vege
	
hiba1:
	mov ah,9
	lea dx,hibauz1
	int 21h
	jmp vege
	
hiba2:
	mov ah,9
	lea dx, hibauz2
	int 21h
	jmp vege

hiba3:
	mov ah,9
	lea dx,hibauz3
	int 21h
		
vege:
	lea dx,text3 ;kiírjuk a text3-at és várunk egy bill.-re
	call waitproc
	
	cmp szemafor,0 ;megnézzük volt-e megnyitva fájl
	jz abort ;ha nem kilépünk

	mov ah,3eh ;ha igen, bezárjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;a vezérlés visszaadása az op-nek
	int 21h

code ends ;code szegmens lezárása
	end start ;start cimkénél lépünk be a programba]