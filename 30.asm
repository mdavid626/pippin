;Program 30

;Írjon programot, amely megállapítja az aktuális dátumot, hozzáad egy napot, és lecseréli az aktuális dátumot erre az újra. Kiírja a régi és az új dátumokat is.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés
	
;változók
text1 db 'Aktualis datum: $'
text2 db 13,10,'Uj datum: $'
text3 db 13,10,'Nyomj le barmilyen billentyut a kilepeshez...$'
hibauz1 db 13,10,'A datum megvaltoztatasa sikertelen!$'
ev dw ? ;ide mentjük az évet
ho db ? ;hónapot
nap db ? ;napot :D

;macro string kiírására
pstring macro string
	mov ah,9
	mov dx,offset string
	int 21h
	endm ;macro vége

;macro egy kar. kiírására
putchar macro kar
	mov ah,2
	mov dl,kar
	int 21h
	endm

;macro a dátum megváltoztatására
change_datum macro
	mov ah,2bh
	mov cx,ev ;az új dátum az ev, ho, nap nevû változókban
	mov dh,ho ;vannak, ezeket változtatjuk meg
	mov dl,nap
	int 21h
	endm

;macro a dátum kiírására
print_datum macro
	mov ax,ev
	call binascii ;a binascii írja ki nekünk
	putchar '.' ;teszünk egy .-ot
	xor ah,ah ;ah-t nullázzuk, mert a binascii az ax-et írja  ki, mi csak az al-be rakunk számot, az ah-t ezért nullázni  kell
	mov al,ho
	call binascii
	putchar '.'
	xor ah,ah ;ez ugyanaz mint elõbb, csak a nap-ot írjuk ki 
	mov al,nap
	call binascii
	endm
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
	
;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása
	
	mov ah,2ah ;dátum lekérésse
	int 21h
	mov ev,cx ;cx-ben az évet
	mov ho,dh ;dh-ban a hónapot 
	mov nap,dl ;dl-ben pedig a napot kapjuk vissza
	
	pstring text1 ;kiírjuk a text1-et
	print_datum ;kiírjuk a dátumot is
	
	inc nap ;nap eggyel nagyobb legyen!
	change_datum ;megpróbáljuk megváltoztatni a dátumot
	or al,al ;aktualizáljuk a jelzõbiteket
	jz oke ;ha a dátum megváltozott, akkor al=0, jz ugorni fog
	
	mov nap,1 ;ha nem jó, akkor hó végén vagyunk, ugrunk köv. hó elejére 
	inc ho
	change_datum ;megváltoztatjuk a dátumont
	or al,al ;ugyanúgy mint elõbb, ha sikerül akkor ugrunk
	jz oke
	
	mov ho,1 ;ha nem, akkor az azt jelenti, hogy év vége
	inc ev ;minden egyesbe, év eggyel növeljük
	change_datum ;megváltoztatjuk a dátumot
	or al,al
	jz oke ;ha ez sem jön be, akkor valami más hiba van, kiírjuk, hogy nem sikerült
	
	pstring hibauz1
	jmp vege ;és ugrunk a végére
	
oke:
	pstring text2 ;kiírjuk az új dátumot
	print_datum
	
	pstring text3
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy karakterre, echo nélkül
	int 21h

vege:
	mov ah,4ch ;a vezérlés visszaadása az op.-nek
	int 21h
	
code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk