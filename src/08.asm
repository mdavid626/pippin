;Program 08

;Írjon programot, amely a beadott értékek halmazából kiválasztja a páros számokat, megjeleníti õket, és megjeleníti a mennyiségüket is. Jelentítse meg a beadott halmazt, amely 10 maximálisan kétjegyû egész számokból tartalmaz.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;a hossz szó jelentse azt, hogy 10
hossz=10 ;írhattuk volna azt is, hogy hossz EQU 10

;változók
szoveg1 db 'A megadott szamokbol a parosak kiirasa',13,10,36
szoveg2 db 13,10,'Adj meg $'
szoveg3 db ' szamot!',13,10,36
szoveg4 db '. szam: $'
szoveg5 db 13,10,'A beadott szamsor:',13,10,36
szoveg6 db 13,10,'Ebbol a paros szamok:',13,10,36
szoveg7 db 13,10,'A paros szamok szama: $'
szoveg8 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
ujsor db 13,10,36 ;újsor írására 36=’$’
buffer_szamok db hossz dup(0) ;buffer a beolvasott számoknak
hibauz db 13,10,'Max. 99!$' ;hibaüzi
buffer db 3,0,3 dup(0) ;a beolvasott kar. tárolására
paros dw 0 ;a páros számok megszámolására 
i dw ? ;a tömb indexelésére
	
;macro string kiírására
kiir macro szoveg
	mov ah,9
	mov dx,offset szoveg
	int 21h
	endm ;macro vége

;macro egy karakter kiírására
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm

;macro szám kiírására
wnum macro param
	mov ax,param
	call binascii
	endm

;macro ASCII kódú szám binárissá alakítására
num macro param
	mov si,offset param
	call asciibin
	endm

;macro a számsor kiírására
wszamsor macro param
	mov di,offset param
	call kiirszamsor
	endm

;macro a páros számok kiírására
wparos macro param
	mov di,offset param
	call kiirparos
	endm

;macro a képernyõ törlésére
clrscr macro
	mov ax,3 ;80x25-ös mód beállítása, ezzel a kép. törlése
	int 10h
	endm

;proc. bináris szám ASCII kódban való kiírására
binascii proc near ;bemenet ax
	jmp binascii_start ;átugorjuk a változót
	
flag db ?

binascii_start:
	mov flag,0
	cmp ax,0 ;ax=0?
	jne binascii_go1 ;ha nem akkor megyünk tovább
	putchar '0' ;ha igen, akkor kirakunk egy nullát
	jmp binascii_vege ;és megyünk a végére

binascii_go1:	
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;az osztás elõtt nullázni kell a dx-et
	
binascii_cik1:	
	div bx ;osztjuk az ax-et bx-el
	mov si,dx ;a maradék az si-be
	cmp ax,0 ;ax=0?
	jne binascii_go2 ;ha nem akkor binascii_go2-re
	cmp flag,0 ;ha igen, akkor flag=0?
	je binascii_go3 ;ha igen, ugrunk a binascii_go3-ra

binascii_go2:	
	add al,30h ;al-hez adjunk hozzá 30h, ASCII!
	putchar al ;kitesszük a képernyõre
	mov flag,1 ;már itt biztos volt kiírva karakter, ezért  szemafor egyesbe

binascii_go3:
	mov ax,bx ;az osztót osztani kell 10-el
	mov bx,10 ;10-el
	xor dx,dx ;dx nullázása, mint fent
	div bx ;kinullazza a dx-et, osztjuk az ax-et
	cmp ax,1 ;megnézzük ax=1?
	jb binascii_vege ;ha kisebb mint 1, akkor vége
	mov bx,ax ;ha nem, bx-be vissza az osztót
	mov ax,si ;ax-be vissza a maradékot
	jmp binascii_cik1 ;vissza az elejére

binascii_vege:
	ret ;visszatérünk a fõprogramba
binascii endp ;proc. vége

;ASCII karaktereket alakít számmá
asciibin proc near ;bemenet si - mutato buffer+1
                   ;kimenet ax - bin ertek
	mov cl,byte ptr[si] ;bevisszük a cl-be a beolvasott  karakterek számát
	xor ax,ax ;ax-et nullázzuk
	cmp cl,0 ;megnézzük volt-e beolvasott karakter
	ja asciibin_go1 ;ha igen, akkor tovább
	jmp asciibin_vege ;ha nem akkor vége

asciibin_go1:	
	mov bx,10 ;10-el fogunk szorozni
	
asciibin_cik1:	
	mul bx ;dx nullázva, szorozzuk az ax-et bx-el
	inc si ;si köv. elemre mutasson
	mov dl,byte ptr[si] ;bevisszük dl-be a karaktert
	sub dl,30h ;levonunk belõle 30h, lásd ASCII!
	add ax,dx ;hozzáadjuk az ax-hez a számjegyet
	dec cl ;cl-1
	jnz asciibin_cik1 ;addig míg cl!=0 vissza az elejére
	
asciibin_vege:
	ret ;visszatérés a fõprogramba
asciibin endp ;proc. vége

;proc. a számsor kiírására
kiirszamsor proc near ;bemenet di - mutato a kiirando tombre, hossz a tomb hossza
	mov cl,hossz
	
kiirszamsor_cik1:
	xor ah,ah ;ah nullázása
	mov al,byte ptr[di] ;al-be bevisszük a számot
	wnum ax ;kiírjuk
	putchar ',' ;kiírunk egy vesszõt is
	inc di ;köv. i
	dec cl ;cl-1
	jnz kiirszamsor_cik1 ;addig míg cl nem nulla
	
	putchar 8 ;eggyel vissza
	putchar 32 ;kiír egy szóközt, tehát utolsó kar. törölve, mit jelent ez? miért is kellett? azért, mert az utolsó szám  után is tettünk vesszõt, ezt kell eltüntetni
	ret ;visszatérés a fõprogramba
kiirszamsor endp ;proc. végge

;proc. a páros számok kiírására 
kiirparos proc near ;bemenet di - mutato a kiirando tombre, hossz a tomb hossza
	mov paros,0
	mov cl,hossz
	
kiirparos_cik1:
	xor ah,ah
	mov al,byte ptr[di]
	
	test al,1 ;ugyanaz mint elõbb, csak itt meg kell nézni, hogy a szám páros-e vagy sem, és aszerint kiírni, ezt végzi a  test al,1, tehát megnézi, hogy a szám legalsó bitje 1-es-e, ha igen akkor páratlan, ha nem akkor páros, jnz azért, mert  ha 1- es akkor zf=0, ekkor elugrunk..
	jnz kiirparos_go1
	wnum ax ;kiírjuk
	putchar ','
	inc paros ;itt meg megszámoljuk
	
kiirparos_go1:	
	inc di
	dec cl
	jnz kiirparos_cik1
	
	putchar 8
	putchar 32
	ret
kiirparos endp
	
;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	
	clrscr ;képernyõ törlése
	
	kiir szoveg1 ;szoveg1 kiírása
	kiir szoveg2
	wnum hossz ;kiírja, hogy mennyi számot kell beadni 
	kiir szoveg3
	
	mov i,1 ;i=1
	
cik1:
	kiir ujsor ;új sort ír
	wnum i ;kiírja hanyadik számot adjuk épp meg
	kiir szoveg4
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása
	mov dx,offset buffer ;ide kell menteni a beolvasott  kar.-eket 
	int 21h
	
	xor bx,bx ;bx nullázása, ezzel fogunk címezni
	
cik3:
	cmp buffer[bx+2],30h ;meg kell nézni, hogy amit  beírtak szám-e
	jb go1
	cmp buffer[bx+2],39h ;a számok az ASCII-ban a 30h-39h- s tartományban vannak
	ja go1
	inc bl
	cmp bl,buffer[1] ;ha nem ütött le semmit, az is hiba
	jb cik3
	jmp go2

go1:
	kiir hibauz ;itt írjuk ki a hibaüzit
	jmp cik1

go2:
	num buffer+1 ;most már jó, átalakítjuk számmá
	
	mov si,i ;és elmentjük a buffer-ba
	mov buffer_szamok[si-1],al

	inc i ;ha még nincs elég számunk, akkor olvasunk be
	cmp i,hossz
	jbe cik1
	
	clrscr ;letöröljük a képernyõt
	kiir szoveg1
	
	kiir szoveg5
	wszamsor buffer_szamok ;kiírjuk a beolvasott számokat
	
	kiir szoveg6
	wparos buffer_szamok ;most csak a páros számokat írjuk ki
	
	kiir szoveg7
	wnum paros ;kiírjuk mennyi páros szám volt
	
	kiir szoveg8 ;kiírjuk a szoveg8-at
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy karakterre echo nélkül
	int 21h
	
	mov ah,4ch ;vezérlés visszaadása az op.-nek
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk