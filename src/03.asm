;Program 03

;Írjon programot a kocka térfogatának a kiszámítására. A kocka oldalának hosszát kérje be a billentyûzetrõl, az eredményt jelenítse meg a képernyõn. Az eredmény férjen bele 2 bájtba.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés
	
;változók
text1 db 'A kocka terfogatanak kiszamitasa'
      db 13,10,'################################',13,10,36
text2 db 13,10,'Add meg az oldalat (max. 40): $'
text3 db 13,10,'A kocka terfogata: $'
text4 db 13,10,'Nyomj le barmilyen billentyut a kilepeshez...$'
hibauz db 13,10,'Max. 40!$'
eredmeny dw ?
buffer db 3,0,3 dup(0)
szemafor db ?

;macro stringek kiírására
textkiir macro text ;text az egyetlen paraméter
	mov ah,9 ;a 9-es DOS szolgáltatással írjuk ki a stringet
	mov dx,offset text
	int 21h
	endm ;macro vége

;alprogram – a beolvasott karakterek átalakítására binárissá
asciibin proc near ;bemenet si - mutato buffer+1
                   ;kimenet ax - bin ertek

	mov cl,byte ptr[si] ;bevisszük a beolvasott kar. számát a  cl-be
	xor ax,ax ;ax-t nullázzuk
	cmp cl,0 ;megnézzük volt-e beolvasva karakter
	ja gop11 ;ha volt továbbmegyünk
	ret ;ha nem vége

gop11:	
mov bx,10 ;10-el fogunk szorozni

cikp11:	
	mul bx ;itt szorzunk, ax-et bx-el, dx nullazva
	inc si ;si-t megnöveljük eggyel
	mov dl,byte ptr[si] ;bevisszünk a bufferbõl egy bájtot a  dl-be
	sub dl,30h ;levonunk belõle 30h-t
	add ax,dx ;így lesz belõle bináris szám, hozzáadjuk az ax- hez, az ax-ben van a végsõ bináris szám
	dec cl ;cl eggyel csökkentjük
	jnz cikp11 ;addig ismételjük ezt, míg cl nulla nem lesz

	ret ;vissza a fõprogramba

asciibin endp ;a procedúra vége

;ez a proc. kiírja a képernyõre az ax-ben lévõ bin. értéket
binascii proc near ; bemenet ax
	mov szemafor,0 ;szemafort nullázzuk
	cmp ax,0 ;megnézzük, hogy nem-e egy nullát kell kiírnunk
	jne gop21 ;ha nem akkor tovább
	mov ah,2 ;ha igen, hát kiírjuk
	mov dl,'0' ;azért így, mert így egyszerûbb
	int 21h ;mint késõbb törõdni vele
	ret ;vissza a fõprogramba

gop21:
	mov bx,10000 ;10000 fogunk osztani
	xor dx,dx ;a dx-et nullázni kell, lásd div utasítás

cikp22:	
	div bx ;osztjuk az ax-et és kiterjesztését a dx-et bx-el
	mov si,dx ;a maradékot kimentjük az si-be
	cmp ax,0 ;ha ax nulla megnézzük ki kell-e írni
	jne gop22 ;ha nem nulla akkor kiírjuk
	cmp szemafor,0 ;ha szemafor nulla, nem írjuk ki
	je gop23

gop22:	
	mov ah,2 ;itt írjuk ki
	mov dl,al
	add dl,30h ;elõtte hozzáadunk 30h-t, lásd ASCII
	int 21h
	mov szemafor,1 ;már volt kiírva szám, szemafor 1-esbe

gop23:
	mov ax,bx ;az osztót 10-el elosztjuk
	mov bx,10
	xor dx,dx
	div bx ;kinullazza a dx-et, fent már nem fog kelleni
	cmp ax,1
	jb vegep2 ;ha kisebb mint vége
	mov bx,ax ;vissza az osztót a bx-be
	mov ax,si ;az osztandó meg a maradék
	jmp cikp22 ;vissza az elejére

vegep2:	
ret ;visszatérünk a fõprogramba

binascii endp ;a proc. vége

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax 
	cld ;df nullázása

	mov ax,3 ;képernyõ törlése, 80x25-ös mód beállításával
	int 10h ;a 16-os BIOS szolgáltatást használjuk	
	
	textkiir text1 ;kiírjuk a text1-et
	
cik1:	
	textkiir text2
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása a bill.-rõl
	mov dx,offset buffer ;a buffer-ba olvasunk
	int 21h

	xor bx,bx ;bx nullázása
cik2:
	cmp buffer[bx+2],30h ;kisebb az aktuálisan nézett karakter  mint 30h=’0’?
	jb go1 ;ha igen, az akkor nem szám
	cmp buffer[bx+2],39h ;nagyobb az aktuálisan nézett karakter mint 39h=’9’?
	ja go1 ;akkor az nem szám
	inc bl ;bl a köv. karakterre mutassson
	cmp bl,buffer[1] ;megnézzük bl=a beolvasott karakterek  számával?
	jb cik2 ;ha kevesebb ismétlünk

;ha ide eljutunk a buffer minden egyes beolvasott karaktere  szám
	
	mov si,offset buffer+1 ;si-be buffer+1 offsetcím, lásd  asciibin proc. bemente
	call asciibin ;meghívjuk az asciiibin proc., ezzel  alakítjuk át a beolvasott karaktereket számmá
	
	cmp al,40 ;megnézzük nem nagyobb-e a beolvasott szám mint  40
	ja go1 ;ha nagyobb ugrunk
	cmp al,0 ;al=0
	je go1 ;ha igen, hiba
	cmp buffer[1],0 ;ha nem volt beolvasott karakter
	je go1 ;akkor is ugrunk
	jmp go2 ;ha egyik se teljesült, akkor megyünk tovább
	
go1:	
	textkiir hibauz ;kiírjuk a hibaüzit
	jmp cik1 ;vissza a beolvasásra

go2:
	mov bx,ax ;itt számolunk, al-t fogjuk szorozni, bl-el
	mul bl ;itt csináljuk
	mul bx ;most már ax-ben található a számunk, ezért már 16  bit széles operandussal kell szoroznunk, nem gond, bh biztos  nulla
	mov eredmeny,ax ;elmentjük az eredményt

	textkiir text3 ;kiírjuk a text3-at
	
	mov ax,eredmeny ;kiiírjuk az eredményt
	call binascii
	
	textkiir text4 ;majd kiírjuk a text4-et
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várunk egy karakterre
	int 21h
	
	mov ah,4ch ;a vezérlés visszaadása a DOS-nak
	int 21h

code ends ;code szegmens vége
	end start ;start cimkénél kezdünk