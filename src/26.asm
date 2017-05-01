;Program 26

;Írjon programot, amely elkészíti két fájl "összegét". A két forrásfájl ill. a célfájl nevét kérje be a billentyûzetrõl.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
filename db 65,0,65 dup(0) ;fájlnév elmentésére
kar db ? ;ebbe olvasunk a fájlból, ebbõl írunk fájlba
text1 db '1. fajl: $'
text2 db 13,10,'2. fajl: $'
text3 db 13,10,'Celfajl: $'
text4 db 13,10,'A masolas kesz!$'
text5 db 13,10,'Press any key...$'
hibauz1 db 13,10,'Nem talalom az utat$' ;hibaüzenetek
hibauz2 db 13,10,'Hozzaferes megtagadva!$'
hibauz3 db 13,10,'A fajl nem letezik!$'
hibauz4 db 13,10,'Szamomra ismeretlen hiba$$'
hibauz5 db 13,10,'A celfájl mar letezik!$'
file1 dw ? ;a FILE HANDLE  számok elmentésére
file2 dw ?
file3 dw ?
szemafor1 db 0 ;volt megnyitott fájl? evvel jelezzük
szemafor2 db 0
szemafor3 db 0
letezik db 0 ;hehe, ez annak az indikálása, hogy van fájl, de  ez nekünk nem jó, tehát ha NINCS az a jó, de akkor a hiba-ra  ugortunk már, megnézzük letezik=1, ha igen, akkor nekünk  vissza kell menni, és tovább kell folytatni a programot

;macro string kiírására
pstring macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm
	
;fájl lezárása
lezar macro file,szemafor
local vege
	cmp szemafor,0 ;ha szemafor=1, akkor le kell zárni
	je vege
	mov ah,3eh
	mov bx,file
	int 21h
vege:
	endm
	
;macro string beolvasására
beolvas macro buffer
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah
	mov dx,offset buffer
	int 21h
	
	xor bh,bh
	mov bl,buffer[1] ;hova is?
	mov buffer[bx+2],0 ;a végére kell egy 0
	endm
	
;macro fájl megnyitására
megnyit macro file,szemafor
local ok
	mov ah,3dh
	xor al,al ;olvasásra
	mov dx,offset filename[2] ;a filename 3. bájtjától  kezdõdika  fájlnév
	int 21h
	jnc ok
	jmp hiba ;ez azért így mert ide már near jump kell, shor  nem elég, túl messze van
	
ok:
	mov file,ax ;FILE HANDLE elmentése
	mov szemafor,1 ;szem. egyesbe
	endm
	
;olvasás fájlból a kar-ba
olvasfajlbol macro file
	mov ah,3fh
	mov bx,file
	mov cx,1 ;egy bájt
	mov dx,offset kar ;a kar-ba
	int 21h
	jc hiba
	endm

;írás fájlba egy kar-t
irasfajlba macro file
	mov ah,40h
	mov bx,file
	mov cx,1 ;egy bájtot
	mov dx,offset kar
	int 21h
	jc hiba ;ha hiba ugrunk
	endm

;fájl létrehozása, nevét a filename adja, mint eddig is :D
letrehozas macro file,szemafor
	mov ah,3ch ;létrehozás
	xor cx,cx ;normal fájl
	mov dx,offset filename[2]
	int 21h
	jc hiba
	mov file,ax ;FILE HANDLE elmentése
	mov szemafor,1 ;bla-bla-bla, mint elõbb
	endm
	
;text kiír, és vár egy karakterre
_wait macro text
	mov ah,9
	mov dx,offset text
	int 21h

	mov ah,0ch
	mov al,7
	int 21h
	endm
	
;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df=0

	pstring text1 ;text1 kiírása
	beolvas filename ;fájlnév beolvasása
	megnyit file1,szemafor1 ;fájl megnyitása
	
	pstring text2 ;ugyanaz, csak másik fájl
	beolvas filename
	megnyit file2,szemafor2
	
	pstring text3 ;célfájl
	beolvas filename
	mov letezik,1 ;hehe, ha létezik az nekünk nem JÓ, ezért ha  hiba lett, akkor visszajövünk, ha nem akkor kiírjuk, hogy  hiba és vége
	megnyit file3,szemafor3
	
	pstring hibauz5
	jmp vege ;mondom, VÉGE
	
letrehoz:
	letrehozas file3,szemafor3 ;célfájl létrehozása
	
elsofajl:	
	olvasfajlbol file1 ;olvasunk elsõ fájlból míg vége nem  lesz
	cmp ax,0
	jz masikfajl
	
	irasfajlba file3 ;és írunk a célfájlba
	jmp elsofajl
	
masikfajl:
	olvasfajlbol file2 ;ugyanaz, csak a másik fájlból olvasunk
	cmp ax,0
	jz vegeazirasnak
	
	irasfajlba file3
	jmp masikfajl

vegeazirasnak:
	pstring text4 ;kiírjuk a végsõ szöveget, hogy minden ok
	jmp vege ;átugorjuk a hibaüziket

hiba:
	cmp letezik,1 ;ha letezik=1 akkor vissza kell menni ha  hiba lett
	je letrehoz ;tehát VISSZA
	cmp ax,3 ;hibák lekezelése a hibakód alapján
	je hiba1
	cmp ax,5
	je hiba2
	cmp ax,2
	je hiba3
	
	pstring hibauz4 ;ha egyik se, akkor ismeretlen
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
	_wait text5 ;várj
	
	lezar file1,szemafor1 ;zárd le a fájlokat
	lezar file2,szemafor2
	lezar file3,szemafor3
	
	mov ah,4ch ;add vissza a vezérlést
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk