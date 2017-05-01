;Program 07

;Írjon programot, amely a beadott értékek halmazából kiválasztja a páros számokat, megjeleníti õket, és megjeleníti a mennyiségüket is. Jelentítse meg a beadott halmazt, amely 10 maximálisan kétjegyû egész számokból tartalmaz.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;EQU direktíva, a long szó jelentse azt, hogy 10
long EQU 10 ;írhattuk volna azt is, hogy long=10

;változók
text1 db 'Paros szamok'
      db 13,10,'------------$'
text2 db 13,10,'Adj meg $'
text3 db ' szamot!',13,10,36
text4 db '. szam: $'
text5 db 13,10,13,10,'A beadott szamsor:',13,10,36
text6 db 13,10,13,10,'A paros szamok:',13,10,36
text7 db 13,10,13,10,'A paros szamok szama: ',13,10,36
text8 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
newline db 13,10,36 ;új sor írására
hibauz1 db 13,10,'A megadhato legnagyobb szam a 99!$'
buffer_key db 3,0,3 dup(0) ;a bill.-rõl beolvasott kar. számára buffer
buffer_sort db long dup(0) ;ebben tároljuk a beolvasott  számokat
index dw ? ;a tömb indexelésére
parosokszama dw 0 ;a páros számok számánank tárolására
	
;macro string kiírására
kiir macro text
	mov ah,9
	mov dx,offset text
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
	mov flag,1 ;már itt biztos volt kiírva karakter, ezért  flag egyesbe

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
kiirszamsor proc near ;bemenet di - mutato a kiirando tombre, long a tomb hossza
	mov cl,long
	
kiirszamsor_cik1:
	xor ah,ah ;ah nullázása
	mov al,byte ptr[di] ;al-be bevisszük a számot
	wnum ax ;kiírjuk
	putchar ',' ;kiírunk egy vesszõt is
	inc di ;köv. index
	dec cl ;cl-1
	jnz kiirszamsor_cik1 ;addig míg cl nem nulla
	
	putchar 8 ;eggyel vissza
	putchar 32 ;kiír egy szóközt, tehát utolsó kar. törölve, mit jelent ez? miért is kellett? azért, mert az utolsó szám  után is tettünk vesszõt, ezt kell eltüntetni
	ret ;visszatérés a fõprogramba
kiirszamsor endp ;proc. végge

;proc. a páros számok kiírására 
kiirparos proc near ;bemenet di - mutato a kiirando tombre, long a tomb hossza
	mov parosokszama,0
	mov cl,long
	
kiirparos_cik1:
	xor ah,ah
	mov al,byte ptr[di]
	
	test al,1 ;ugyanaz mint elõbb, csak itt meg kell nézni, hogy a szám páros-e vagy sem, és aszerint kiírni, ezt végzi a  test al,1, tehát megnézi, hogy a szám legalsó bitje 1-es-e, ha igen akkor páratlan, ha nem akkor páros, jnz azért, mert  ha 1- es akkor zf=0, ekkor elugrunk..
	jnz kiirparos_go1
	wnum ax ;kiírjuk
	putchar ','
	inc parosokszama ;itt meg megszámoljuk
	
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
	
	kiir text1 ;text1 kiírása
	kiir text2
	wnum long ;kiírja, hogy mennyi számot kell beadni 
	kiir text3
	
	mov index,1 ;index=1
	
cik1:
	kiir newline ;új sort ír
	wnum index ;kiírja hanyadik számot adjuk épp meg
	kiir text4
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása
	mov dx,offset buffer_key ;ide kell menteni a beolvasott  kar.-eket 
	int 21h
	
	xor bx,bx ;bx nullázása, ezzel fogunk címezni
	
cik3:
	cmp buffer_key[bx+2],30h ;meg kell nézni, hogy amit  beírtak szám-e
	jb go1
	cmp buffer_key[bx+2],39h ;a számok az ASCII-ban a 30h-39h- s tartományban vannak
	ja go1
	inc bl
	cmp bl,buffer_key[1] ;ha nem ütött le semmit, az is hiba
	jb cik3
	jmp go2

go1:
	kiir hibauz1 ;itt írjuk ki a hibaüzit
	jmp cik1

go2:
	num buffer_key+1 ;most már jó, átalakítjuk számmá
	
	mov si,index ;és elmentjük a buffer-ba
	mov buffer_sort[si-1],al

	inc index ;ha még nincs elég számunk, akkor olvasunk be
	cmp index,long
	jbe cik1
	
	clrscr ;letöröljük a képernyõt
	kiir text1
	
	kiir text5
	wszamsor buffer_sort ;kiírjuk a beolvasott számokat
	
	kiir text6
	wparos buffer_sort ;most csak a páros számokat írjuk ki
	
	kiir text7
	wnum parosokszama ;kiírjuk mennyi páros szám volt
	
	kiir text8 ;kiírjuk a text8-at
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy karakterre echo nélkül
	int 21h
	
	mov ah,4ch ;vezérlés visszaadása az op.-nek
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk