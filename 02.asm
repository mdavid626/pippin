;Program 02

;Írjon programot a kocka felületének kiszámítására. A kocka oldalát kérje be a billentyûzetrõl, az ererdményt jelentítse meg a számítógép monitorán. Az eredmény férjen bele 2 bájtba.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;EQU direktíva, a max szó jelentse azt, hogy 104, a fordító  minden max szó helyére ezt fogja tenni
max EQU 104

;változók	
text1 db 'A kocka felszinenek kiszamitasa'
      db 13,10,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$'
text2 db 13,10,'Add meg az oldalat (max. 104): $'
text3 db 13,10,'A kocka felszine: $'
text4 db 13,10,'Nyomj le barmilyen billentyut a kilepeshez...$'
hibauz db 13,10,'Max. 104!$'
eredmeny dw ? ;ide mentjük az eredményt
buffer db 4,0,4 dup(0) ;ide olvassuk be a számot

;macro string kiírására
textkiir macro text
	mov ah,9 ;9-es DOS szolgáltatás
	mov dx,offset text ;dx-be a kiírandó string offsetcíme
	int 21h
	endm ;macro vége

;proc. ASCII kódú karakterek bináris számmá való alakítására
asciibin proc near ;bemenet si - mutato buffer+1
                   ;kimenet ax - bin ertek
	mov cl,byte ptr[si] ;elmentjük cl-be a beolvasott kar. számát
	xor ax,ax ;ax-et nullázzuk
	cmp cl,0 ;volt beolvasott karakter?
	ja asciibin_go1 ;ha igen, akkor megyünk átszámolni
	ret ;ha nem visszatérünk egy nullával az ax-ben

asciibin_go1:	
	mov bx,10 ;10-el fogunk szorozni
	
asciibin_cik1:
	mul bx ;dx nullázva
	inc si ;si növelése eggyel
	mov dl,byte ptr[si] ;bevisszük a számjegyet
	sub dl,30h ;hogy szám legyen, ASCII kódú most még!
	add ax,dx ;a számunkhoz hozzáadjuk
	dec cl ;cl dekrementálása
	jnz asciibin_cik1 ;addig míg a cl 0 nem lesz

	ret ;visszatérünk a fõprogramba
asciibin endp ;proc. vége

;proc. ami kiírja az ax-ben megadott számot a képernyõre
binascii proc near ;bemenet ax
	jmp binascii_start ;átugorjuk a változót
	
flag db ? ;volt már kiírt számjegy? ezt mondja meg

binascii_start:
	mov flag,0 ;flag=0 ? még nem volt kiírt számjegy
	cmp ax,0 ;ax=0?
	jne binascii_go1 ;ha nem, akkor tovább
	mov ah,2 ;ha igen, akkor kiírunk egy nullát
	mov dl,'0'
	int 21h
	ret ;és visszatérünk

binascii_go1:	
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;osztás ? dx-et nullázni kell! lásd füzet DIV  utasítás
	
binascii_cik1:	
	div bx ;ax-et osztjuk bx-el
	mov si,dx ;maradékot dx-ben kapjuk vissza, elmentjük si-be
	cmp ax,0 ;ax=0?
	jne binascii_go2 ;ha nem akkor tovább
	cmp flag,0 ;ha igen, akkor flag=0?
	je binascii_go3 ;ha igen, akkor még nem volt kiírt  számjegy, ezért a kapott nullát nem írjuk ki

binascii_go2:	
	mov ah,2 ;ha ide eljutunk, kiírjuk a számjegyet
	mov dl,al
	add dl,30h ;elõbb hozzáadunk 30h-t, ASCII!
	int 21h
	mov flag,1 ;és flag=1, mert már van kiírt számjegy

binascii_go3:	
	mov ax,bx ;bx-et osztani kell 10-el
	mov bx,10 ;10-el
	xor dx,dx ;dx-et nullázni
	div bx ;kinullázza a dx-et
	cmp ax,1 ;ax=1?
	jb binascii_vege ;ha kisebb mint egy akkor vége
	mov bx,ax ;ha nem, akkor bx vissza osztónak
	mov ax,si ;ax-be meg az elõbbi maradék
	jmp binascii_cik1 ;és vissza a ciklus elejére

binascii_vege:
	ret ;visszatérés a fõprogramba
binascii endp ;proc. vége

start:
	mov ax,cs ;adatszegmens beállítása
	mov ds,ax
	cld ;df nullázása

	mov ax,3 ;képernyõ törlése, 80x25-ös módba való lépéssel
	int 10h
	
	textkiir text1 ;text1 kiírása
	
cik1:	
	textkiir text2 ;text2 kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bx,bx ;bx nullázása, evvel címzünk
	
cik2:
	cmp buffer[bx+2],30h ;megnézzük a beolvasott tömb minden  egyes elemét, hogy szám volt-e: 30h és 39h közötti ASCII kódú  karakternek kell lenni, ezek a számok ASCII kódjai
	jb go1 ;ha kisebb volt, hiba
	cmp buffer[bx+2],39h 
	ja go1 ;ha meg nagyobb, az is hiba
	inc bl ;az összes elemet végignézzük
	cmp bl,buffer[1] ;addig míg a bl el nem éri a beolvasott kar. számát
	jb cik2 ;jobban mondva, nagyobb vagy egyenlõ nem lesz  nála, 0-val kezdjük az indexelést!
	
	mov si,offset buffer+1 ;átalakítjuk a karaktereket számmá 
	call asciibin ;itt csináljuk
	
	cmp ax,max ;ax-ben kaptuk vissza a számot
	ja go1 ;megnézzük nem nagyobb-e mint, ami lehet
	cmp al,0 ;nulla se lehet 
	je go1 ;ekkor is hiba
	cmp buffer[1],0 ;ha meg nem ütött mást a user csak egy  ENTERT, azt is lekezeljük, mint hiba
	je go1
	jmp go2 ;tovább, mert itt akkor nincs hiba 
	
go1:
	textkiir hibauz ;hibaüzenet kiírása
	jmp cik1 ;új szám bekérése

go2:
	mov bx,ax ;bx-be ax-et
	mul bl ;ax szorzása bx-el ? ax-ben a kocka oldala ?  szorozva önmagával, ez az a2, ezt még szorozzuk 6-al, és meg  is van a felszíne

	mov bx,6 ;6-al
	mul bx ;ax és kiterjesztése a dx szorzása a bx-el
	mov eredmeny,ax ;eredmény elmentése
	
	textkiir text3 ;text3 kiírása
	
	mov ax,eredmeny ;eredmény vissza az ax-be
	call binascii ;kiírása
	
	textkiir text4 ;text4 kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy karakterre echo nélkül
	int 21h
	
	mov ah,4ch ;a vezérlés visszaadása az op.-nek
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk