;Program 15

;Írjon programot, amely megjeleníti a leütött billentyû hexadecimális és decimális kódját.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
text1 db 'A leutott billentyu kodjanak megjelenitese'
      db 13,10,'------------------------------------------'
      db 13,10,'Uss ESC-t a kilepeshez!',13,10,13,10
      db 13,10,'A leutott billentyu kodja:'
      db 13,10,'--------------------------'
      db 13,10,'Decimalis    :'
      db 13,10,'Hexadecimalis:'
      db 13,10,'--------------------------$'
newline db 13,10,36 ;újsor
spec db '0+$' ;ha speciális bill. volt leütve, ezzel jelezzük
torles db 10 dup(32) ;hehe, ez érdekes, kiírunk 10 szóközt
       db 10 dup(8),36 ;aztán meg visszalépünk 10-et, tehát  letöröltünk 10 karaktert
kar db ? ;ide mentjük a beolvasott karaktert
szemaforspec db 0 ;ezzel jelezzük, hogy speciális bill. volt  leütve

;macro string kiírására
printstring macro text
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

;macro a kurzor áthelyezésére
gotoxy macro x,y
	mov ah,2
	xor bh,bh ;0-dik lap
	mov dh,y ;dh-ba a sor koordinátája
	mov dl,x ;dl-be az oszlopé
	int 10h ;ezt egy BIOS szolgáltatás végzi
	endm

;procedura bináris szám kiírására
binascii proc near ;bemenet ax
	jmp startp1 ;átugorujuk a változókat

szemaforbin db ? ;kezdeti nullákat nem akarjuk kiírni, ezért  kell ez, hogy tudjuk, már volt kiírva szám, már lehet írni a  nullákat

startp1: ;itt kezdünk
	mov szemaforbin,0 ;nullázzuk
	cmp ax,0 ;megnézzük, nem nullát kaptunk-e
	jne gop11 ;ha nem továbbugrunk
	putchar '0' ;ha igen, kiírunk egy nullát
	jmp vegep1 ;és ugrunk a végére

gop11:
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;dx-et nullázni kell, lásd div utasítás

cikp11:
	div bx ;osztjuk az ax-et 10000-rel
	mov si,dx ;maradék si-be
	cmp ax,0 ;megnézzük ax-ben nulla van-e
	jne gop12 ;ha nem akkor kiírjuk
	cmp szemaforbin,0 ;ha volt már kiírva szám akkor kiírjuk, ha nem akkor nem írjuk ki
	je gop13

gop12:
	mov ah,2 ;kiírjuk a számjegyet
	mov dl,al
	add dl,30h ;ASCII kód! ezért kell +30h
	int 21h
	mov szemaforbin,1 ;itt már biztos volt kiírt szám, ezért a  szemafor 1-esbe

gop13:
	mov ax,bx ;az osztót osztjuk 10-el
	mov bx,10
	xor dx,dx ;mint az elõbb, nullázni kell!
	div bx ;osztunk
	cmp ax,1 ;ax=1?
	jb vegep1 ;ha kisebb akkor vége
	mov bx,ax ;vissza a bx-be az osztót
	mov ax,si ;ax-be meg az elõbbi maradékot
	jmp cikp11 ;vissz az elejére

vegep1: 
	ret ;visszatérés

binascii endp ;a proc. vége

;procedúra hexadecimális kiíráshoz
hexascii proc near ;bemenet ax	
	jmp startp2 ;átugorjuk a kezdeti változókat

;változók
szemaforhex1 db ? ;nullák indikálása
s1 db ? ;ennyivel kell majd shiftelni a számot
char db ? ;ide mentjük a számjegyet
temp dw ? ;elmentjük az elején az ax-et

startp2:
	mov szemaforhex1,0 ;beálligatjuk a szemafort
	mov bx,0f000h ;bx-ben lesz a maszk
	mov s1,16 ;16-nyit shiftelünk elõször
	mov temp,ax ;elmentjük az ax-et
	
cikp21:
	mov ax,temp ;visszahozzuk az ax-et
	sub s1,4 ;s1-4, mindig 4-el kevesebbet kell shiftelni
	
	and ax,bx ;na itt a lényeg, az ax mindig csak 4 bitjét  nézzük a többit kilõjük
	mov cl,s1 ;shifteljük az al „elejére”
	shr ax,cl ;itt
	mov char,al ;és elmentjük a char-ba

	mov cl,4 ;a maszkot is shiftelni kell
	shr bx,cl
	
	cmp char,0 ;megnézzük 0-át kaptunk-e
	jne gop21 ;ha nem akkor tovább
	cmp szemaforhex1,0 ;ha igen, megnézzük: volt már kiírva  szám?
	je gop22 ;ha nem akkor nem írjuk ki, ugrás végére

gop21:
	cmp char,9 ;megnézzük számjegy, vagy betû amit kaptunk
	ja gop23 ;ha betû, ugrunk
	
	add char,30h ;ha számjegy, akkor 30h-t kell hozzáadni
	putchar char ;és kiírni
	
	jmp gop25 ;ugrás végére
	
;ha betû
gop23:
	cmp szemaforhex1,0 ;megnézzük volt-e már kiírva számjegy
	jne gop24 ;ha nem...
	putchar '0' ;...akkor kiírunk egy nullát

gop24:
	add char,37h ;a betûhez ennyit kell hozzáadni, 
;65-10=55=37h, 65 az A betû kódja
	putchar char ;és kiírjuk

gop25:
	mov szemaforhex1,1 ;biztos volt kiírva karakter, szemafor  egyesbe

gop22:
	cmp s1,0 ;végén vagyunk már? 
	jne cikp21 ;ha s1-be nincs 0, akkor vissza az elejére
	
	putchar 'h' ;a végére egy h betût
	ret ;visszatérünk
hexascii endp ;proc. vége

;fõprogram
start:	 
	mov ax,cs ;adatszegmens beállítása
	mov ds,ax
	cld ;df nullázása
	
	mov ax,3 ;képernyõ törlése, 80x25-ös módba való lépéssel
	int 10h ;ezt egy BIOS szolgáltatás végzi

	printstring text1 ;kiírjuk a text1-et

	mov ah,1 ;eltüntetjük a kurzort
	mov ch,20h
	int 10h

cik1:	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;egy karakter beolvasása echo nélkül
	int 21h
	mov kar,al ;elmentjük a karaktert

	cmp kar,0 ;megnézzük nem spec. bill. volt leütve
	jne go1 ;ha nem, akkor tovább
	mov ah,7 ;ha igen, lekéjük a második bájtot is
	int 21h
	mov kar,al ;és elmentjük a kar-ba
	mov szemaforspec,1 ;igen, spec. karakter volt, elmentjük, hogy késõbb tudjuk

go1:
	gotoxy 15,7 ;kurzor mozgatása a 8. sor 16. oszlopára
	printstring torles ;letörölni, ami ott van
	
	cmp szemaforspec,1 ;volt spec. karakter?
	jne go3 ;ha nem, tovább
	printstring spec ;ha igen, kiírjunk egy jelet, hogy  speciális kar., itt. egy 0+ -t
	
go3:
	xor ah,ah ;ah nullázása
	mov al,kar ;al-ba bevisszük a kar-t
	call binascii ;kiírjuk

	gotoxy 15,8 ;most ugyanez, csak hexa-ban
	printstring torles

	cmp szemaforspec,1
	jne go4
	printstring spec
	mov szemaforspec,0 ;de itt már nullázni kell a spec. szemafort, hogy legközelebb is mûködjön

go4:
	xor ah,ah
	mov al,kar
	call hexascii ;csak itt hexa-ban írjuk ki

	cmp kar,27 ;addig ismételjük, míg ESC nem volt ütve
	jz go2 ;itt ez enged ki ebbõl a ciklusból
	jmp cik1

go2:
	printstring newline ;írunk egy újsort, csak, hogy szép  legyen
	
	mov ah,1 ;a kurzort azért láthatóvá tesszük
	mov cx,1f0eh
	int 10h

	mov ah,4ch ;a vezérlés vissza az op.-nek
	int 21h

code ends ;code szegmens vége
	end start ;start cimke a program belépési pontja