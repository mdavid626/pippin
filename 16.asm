;Program 16

;Írjon programot, amely kinyomtat egy állományt. Az állomány nevét kérje be a billentyûzetrõl.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
buffer db 65,0,65 dup(0) ;buffer a fájl nevére
kar db ? ;egy karaktert olvasunk mindig a fájlból, ide mentjük
text1 db 'Fajl: $' ;szövegek, amiket kiírunk a képernyõre
text2 db 13,10,'Press any key...$'
text3 db 13,10,'A nyomtatas kesz!$'
hibauz1 db 13,10,'Nem talalom az utat$'
hibauz2 db 13,10,'Hozzaferes megtagadva!$'
hibauz3 db 13,10,'A fajl nem letezik!$'
hibauz4 db 13,10,'Szamomra ismeretlen hiba$$'
file dw ? ;FILE HANDLE elmentésére
szemafor db 0 ;szemafor – volt-e megnyitva fájl

;macor string kiírására
pstring macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása

	pstring text1 ;text1 kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bh,bh ;bh nullázása
	mov bl,buffer[1] ;mennyi karaktert olvastunk be ? bl-be
	mov buffer[bx+2],0 ;a végére egy nulla

	mov ah,3dh ;fájl megnyitása
	xor al,al ;csak olvasásra
	mov dx,offset buffer[2] ;a buffer 3. bájtjától a fájlnév
	int 21h
	jc hiba ;ha hiba, ugorj
	mov file,ax ;FILE HANDLE elmentése
	mov szemafor,1 ;szem. egyesbe
	
cik1:
	mov ah,3fh ;olvasunk
	mov bx,file ;a fájlból
	mov cx,1 ;egy bájtot
	mov dx,offset kar ;a kar-ba
	int 21h
	jc hiba ;ha nem sikerült, hiba
	cmp ax,0 ;ha ax=0, fájlvége
	jz veg

	mov ah,5 ;kiírjuk a nyomdára, LPT1
	mov dl,kar ;a kar-t
	int 21h
	
	jmp cik1 ;és vissza az elejére, a cmp ax,0 // jz veg enged  ki

veg:
	mov ah,5 ;még kiírunk egy 13,10-et, hogy a buffer-ba levõ  dolgokat kinyomtassa
	mov dl,13
	int 21h
	mov dl,10
	int 21h
	
	pstring text3 ;text3 kiírása
	jmp vege ;a hibaüzik átugrása

hiba:
	cmp ax,3 ;ax=3?
	jz hiba1 ;ezek alapján kezeljük le a hibát
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
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy karakterre echo nélkül
	int 21h
	
	cmp szemafor,0 ;volt megnyitott fájl?
	jz abort

	mov ah,3eh ;ha igen, lezárjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;vezérlés vissza az op.-nek
	int 21h

code ends ;code szegmens vége
	end start ;start cimkénél kezdünk