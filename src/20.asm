;Program 20

;Írjon programot, amely az aktuális könyvtárban létrehoz egy állományt a könyvtárban levõ állományok nevével. 

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
dta db 128 dup(0)
asciiz1 db 'FILELIST.TXT',0
asciiz2 db '*.*',0
newline db 13,10,36
text1 db 'A lista sikeresen letrehozva a FILELIST.TXT allomanyba!$'
hibauz1 db 'Nem talalom az utat!$'
hibauz2 db 'Nincs engedelyezve a hozzaferes!$'
hibauz3 db 'Nem talalhato fajl!$'
hibauz4 db 'Ismeretlen hiba!$'
hibauz5 db 'Nem tudom letrehozni a fajlt! (Lehet, hogy mar letezik?)$'
file dw ?
szemaforfile db 0
szemaforelso db 0

start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása
	
	mov ah,1ah ;dta beállítása
	mov dx,offset dta
	int 21h

	mov ah,4eh ;fájl keresése az adott mappában
	mov dx,offset asciiz2
	mov cx,0 ;normal fájlokat keresünk
	int 21h
	jc hiba ;ha hiba keletkezett, ugrunk

	mov ah,3dh ;megpróbáljuk megnyitni a FILELIST.TXT fájlt
;ha megnyitja, akkor létezik, ha nem akkor létrehozzuk
	xor al,al ;csak olvasásra nyitjuk meg
	mov dx,offset asciiz1 ;a fájlnév címét a dx-be
	int 21h
	jc go1 ;ha nem létezik akkor továbbmegyünk 
	
	mov ah,9 ;ha igen, hibaüzenet
	mov dx,offset hibauz5
	int 21h
	jmp abort ;és kilépünk
	
go1:
	mov ah,3ch ;létrehozzuk a fájlt
	xor cx,cx ;normal fájl
	mov dx,offset asciiz1 ;átadjuk a nevét
	int 21h
	jc hiba ;ha nem sikerült létrehozni, ugrunk a hibára
	mov file,ax ;elmentjük a FILE HANDLE-t
	mov szemaforfile,1 ;beállítjuk a szemaforfile-t 1-re, hogy 
;a végén tudjuk, hogy volt megnyitott fájl
	
cik1:	
	cmp szemaforelso,0 ;elõször nem kell új sor
	jz go2 ;tehát átugorjuk

	mov ah,40h ;itt írjuk az új sort a fájlba
	mov bx,file ;bxbe tesszük, hogy melyik fájlba akarunk írni
	mov cx,2 ;két bájtot írunk
	mov dx,offset newline ;ezt írjuk
	int 21h
	jc hiba ;ha hiba ugrunk

go2:	
	mov szemaforelso,1 ;többször már nem kell átugorni
	mov di,1eh ;innen nézzük végig a dta-t
	
cik2:	
	cmp dta[di],0 ;meg kell számolni mennyi bájtot kell kiírni
	lea di,[di+1] ;ezt nem vettük, de így szinte tökéletes:D
	jnz cik2
	
	mov cx,di ;cx-be kell a kiírni kívánt bájtok száma
	sub cx,1fh ;de a di-be pont 1fh-val több van

	mov ah,40h ;beírjuk a fájlba
	mov bx,file ;melyikbe?
	mov dx,offset dta[1eh] ;mit?
	int 21h
	
	mov ah,4fh ;keressük tovább a további fájlokat
	int 21h
	jnc cik1 ;ha van akkor kiírjuk, ha nincs akkor kész
	
	mov ah,9 ;kiírunk egy üzit, hogy kész
	mov dx,offset text1
	int 21h

	jmp vege ;és ugrunk a végére

;hibák kezelése
hiba:
	cmp ax,3 ;megnézzük mi volt az ax-be, aszerint ugrunk
	jz hiba1
	cmp ax,5
	jz hiba2
	cmp ax,12h
	jz hiba3

	mov ah,9
	mov dx,offset hibauz4
	int 21h
	jmp vege

hiba1:
	mov ah,9 ;ezekkel kiírjuk a hibaüziket
	mov dx,offset hibauz1
	int 21h
	jmp vege
	
hiba2:
	mov ah,9
	mov dx,offset hibauz2
	int 21h
	jmp vege

hiba3:
	mov ah,9
	mov dx,offset hibauz3
	int 21h
	jmp vege

;itt a vége, fuss el véle... :D
vege:
	cmp szemaforfile,1 ;ha volt megnyitva fájl akkor a  szemafor 1-es, és be kell zárni
	jnz abort ;ha nem akkor vége

	mov ah,3eh
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;korrektül bezárjuk a programot 
	int 21h

code ends ;code szegmens vége
	end start ;start cimkén kezdünk