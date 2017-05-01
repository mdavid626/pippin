;Program 18

;Írjon programot, amely megjeleníti a billentyûzetrõl megadott számú kiszolgáló alprogram logikai címét hexadecimálisan és dekadikusan.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
text1 db 'Alprogram logikai cime'
      db 13,10,'**********************$'
text2 db 13,10,'Add meg az alprogram szamat (0-255): $'
text3 db 13,10,13,10,'A megadott alprogram logikai cime:'
      db 13,10,'**********************************'
      db 13,10,'Decimalis    : $'
text4 db 13,10,'Hexadecimalis: $'
text5 db 13,10,'**********************************'
      db 13,10,13,10,'Nyomj le barmilyen billentyut a kilepeshez...$'
hibauz1 db 13,10,'Az alprogram szama 0-255!$'
buffer db 4,0,4 dup(0) ;buffer a szám beolvasására
szam dw ? ;ide mentjük a beolvasott számot
szegmens dw ? ;ide a kiolvasott szegmenscímet
offsetcim dw ? ;ide a kiolvasott offsetcímet

;macor egy string kiírására
kiir macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm

;macro egy karakter kiírására
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm

;procedúra egy bináris szám kiírására
binascii proc near ;bemenet ax
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;az osztás elõtt dx-et nullázni

cikp11:
	div bx ;osztjuk az ax-et bx-el
	mov si,dx ;a maradékot az si-be

	mov ah,2 ;kiírjuk az al-ben megkapott számjegyet
	mov dl,al
	add dl,30h ;ASCII karakter!, ezért kell a +30h
	int 21h

	mov ax,bx ;az osztót 10-zel osztjuk
	mov bx,10 ;10-zel
	xor dx,dx ;mint fent
	div bx ;osztjuk akkor végre
	cmp ax,1 ;megnézzük ax=1?
	jb vegep1 ;ha kisebb mint 1, akkor vége
	mov bx,ax ;az osztót a bx-be
	mov ax,si ;vissza a maradékot az ax-be
	jmp cikp11 ;vissza az elejére

vegep1:
	ret ;visszatérés a fõprogramba

binascii endp

;procedúra hexadecimális kiírásra
hexascii proc near ;bemenet ax	
	jmp startp2 ;átugorjuk a változókat

s1 db ? ;ennyivel fogjuk shiftelni az ax-et
char db ? ;ide tesszük a kapott karaktert
temp dw ? ;tároljuk az ax-et

startp2:
	mov bx,0f000h ;a bx-ben lesz a maszk, amivel mindig  kiütjuk az ax bizonyos bitjeit,mindig csak 4 fog maradni, ez  jelentve egy számjegyeet
	mov s1,16 ;elõször ennyivel shifteljük az ax-et
	mov temp,ax ;elmentjük az ax-et
	
cikp21:
	mov ax,temp ;minden ciklus elején visszatesszük az ax  eredeti tartalmát
	sub s1,4 ;az s1-bõl levonunk 4-et, mert minden egyes futás  után 4-el kevesebbszer kell shiftelni
	
	and ax,bx ;na itt ütjük ki az ax bizonyos bitjeit
	mov cl,s1
	shr ax,cl ;és shifteljük s1-el
	mov char,al ;így a 4 bit átkerül az al aljára, el tudjuk  már menteni

	mov cl,4 ;a bx-et is „arrébb” kell tenni
	shr bx,cl
	
	cmp char,9 ;megnézzük, hogy a karakter, amit kaptunk  nagyobb mint 9?
	ja gop21 ;ha igen akkor valami A,B,C,... kell kiírni, tehát elugrunk
	
	add char,30h ;ha ide eljutunk, akkor számjegyet írunk ki
	putchar char ;kiírjuk
	
	jmp gop22 ;megyünk a gop22-re 
	
gop21:
	add char,37h ;itt írjuk betûket
	putchar char ;na akkor írjuk

gop22:
	cmp s1,0 ;s1 már nulla?
	jne cikp21 ;ha nem akkor még ismétlünk
	
	putchar 'h' ;a végén kiteszünk egy h-t
	ret ;visszatérünk
hexascii endp ;a proc. vége

;proc. ascii-bináris átalakításra
;a beolvasott karakter átalakítására
asciibin proc near ; bemenet si - mutato buffer+1
                   ; kimenet ax - bin ertek

	mov cl,byte ptr[si] ;a beolvasott karakterek számát  elmentjük a cl-be 
	xor ax,ax ;ax-et nullázzuk
	cmp cl,0 ;ha nem volt beolvasott karakter, nullát adunk  vissza
	ja gop31 ;ha volt akkor, tovább
	ret ;visszatérünk

gop31:	
	mov bx,10 ;10-el fogunk szorozni
	
cikp31:	
	mul bx ;dx nullazva, szorozzuk az ax-et
	inc si ;si növelése 1-el
	mov dl,byte ptr[si] ;dl-be az aktuális karakter
	sub dl,30h ;levonunk belõle 30h-t, ASCII!
	add ax,dx ;hozzáadjuk az ax-hez
	dec cl ;cl dekrementálása
	jnz cikp31 ;addig míg cl nulla nem lesz

	ret ;visszatérés a fõprogramba

asciibin endp ;proc. vége

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása

	mov ax,3 ;képernyõ letörlése, 80x25-ös módba való lépéssel
	int 10h	
	
	kiir text1 ;kiírjuk a kezdeti dolgokat

cik1:	
	kiir text2 ;kiírjuk, hogy add meg a számot
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;karakterek beolvasása a bill.-rõl
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bx,bx ;a bx törlése
cik2:
	cmp buffer[bx+2],30h ;megnézzük itt, hogy mindegyik  beolvasott karakter szám volt-e
	jb go1 ;ha nem, ugrunk a go1-re, ahol kiírjuk, hogy hiba, és megadja újból
	cmp buffer[bx+2],39h
	ja go1
	inc bl
	cmp bl,buffer[1]
	jb cik2
		
	mov si,offset buffer+1
	call asciibin ;átalakítjuk a buffer-ban lévõ karaktereket  számmá
	
	cmp ax,00ffh ;megnézzük nem adott-e túl nagy számot, 
;255-nél nagyobbat
	ja go1 ;ha igen, hiba
	cmp buffer[1],0 ;ha nem adott meg számot, hiba
	je go1
	jmp go2
	
go1:
	kiir hibauz1 ;itt írjuk ki a hibaüzit
	jmp cik1 ;és visszaküldjük az elejére

go2:	
	mov szam,ax ;a számot elmenjtük az ax-be
	
	mov ax,0000h ;ax-be nulla
	mov es,ax ;ezt az es-be
	
	mov cl,2 ;a szam-ot megszorozzuk kettõvel
	shl szam,cl
	
	mov si,szam ;si-be a szam
	
	mov ax,word ptr es:[si] ;na itt hozzuk be az ax-be az  offsetcímet
	mov offsetcim,ax ;és elmentjük az offsetcim nevû változóba
	mov ax,word ptr es:[si+2] ;ez ugyanaz csak a  szegmenscímmel, lásd a megszakításvektor-táblázat
	mov szegmens,ax

;most már csak kiírjuk
	kiir text3 ;kiírjuk, hogy decimális
	mov ax,szegmens ;átvisszük ax-be
	call binascii ;kiírjuk
	putchar ':' ;kiírunk egy kettõspontot
	mov ax,offsetcim ;kiírjuk az offsetet is
	call binascii
	
	kiir text4 ;ugyanaz pepitába – hexába
	mov ax,szegmens
	call hexascii
	putchar ':'
	mov ax,offsetcim
	call hexascii

	kiir text5 ;kiírjuk, hogy nyomj bármilyen bill.-t
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várunk egy bill.-re
	int 21h
	
	mov ah,4ch ;vezérlés vissza az op.-nek
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk