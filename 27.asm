;Program 27

;Írjon programot, amely megszámolja a Jani szavakat a szöveges állományban, és megjeleníti ezt a mennyiséget a képernyõn. Az egyes szavak SP, HT, CR és LF karakterekkel vannak elválasztva. Az állomány nevét kérje be a billentyûzetrõl, és hiba esetén jelenítsen meg hibaüzenetet.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

long EQU 4 ;long konstans értéke 4

;változók
buffer db 65,0,65 dup(0) ;buffer a fájl nevének, majd pedig a fájlból való olvasásra is
mit db 'Jani' ;Jani szót keressük
;szövegek, amiket ki akarunk írni
text1 db 'File: $'
text2 db 13,10,'A Jani szo $'
text3 db '-szor jelenik meg a fajlban.$'
text4 db 13,10,'Press any key...$'
hibauz1 db 13,10,'Nem talalhato az ut!$'
hibauz2 db 13,10,'Hozzaferes megtagadva!$'
hibauz3 db 13,10,'A fajl nem letezik!$'
hibauz4 db 13,10,'Ismeretlen hiba!$'
file dw ? ;FILE HANDLE elmentésére
szemafor db 0 ;volt megnyitot fájl?
fajlvege db 0 ;fájlvége van?
szo db 1 ;szavat találtunk, vagy csak az elõzõ szónak van vége
t dw 0 ;számolunk..mennyi is van?

;macro string kiírására
pstring macro text
	mov ah,9 ;kilences DOS szolgáltatás
	mov dx,offset text
	int 21h
	endm
	
;proc. bináris szám kiírására a képernyõre 
binascii proc near ;bemenet ax
	jmp binascii_start
	
flag db ? ;van már kiírt karakter?

binascii_start:
	mov flag,0 ;még nincs kiirt karakter, ezért flag nulla
	cmp ax,0 ;ax=0?
	jne binascii_go1
	mov ah,2 ;ha igen akkor kiírunk egy nullát
	mov dl,'0'
	int 21h
	ret

binascii_go1:	
	mov bx,10000 ;ha nem nulla, akkor szépen kiírjuk a számot
	xor dx,dx ;elõször 10ezerrel osztunk, majd szépen ezerrel, százzal...
	
binascii_cik1:	
	div bx ;oszd el az ax-et bx-el
	mov si,dx ;maradékot az si-be
	cmp ax,0 ;ax=0
	jne binascii_go2 ;a szám amit kaptunk 0? Ha igen akkor a flagtõl függ ki írunk-e valamit
	cmp flag,0 ;ha flag nulla akkor nem írunk ki semmit
	je binascii_go3

binascii_go2:	
	mov ah,2 ;ha minden ok akkor kiírjuk a számjegyet
	mov dl,al
	add dl,30h ;ASCII
	int 21h
	mov flag,1 ;flag már egyesbe

binascii_go3:	
	mov ax,bx ;elosztjuk a bx-et 10-el
	mov bx,10
	xor dx,dx
	div bx ;kinullazza a dx-et, elosztja az ax-et bx-el
	cmp ax,1 ;addig míg ax nagyobb vagy egyenlõ 1el
	jb binascii_vege
	mov bx,ax ;ax vissza bx-be
	mov ax,si ;sibõl a maradék vissza az ax-be
	jmp binascii_cik1 ;vissza az elejére

binascii_vege:
	ret
binascii endp

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása
	
	mov ax,3 ;képernyõ törlése
	int 10h
	
	pstring text1 ;text1 kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bh,bh ;bh nullázása, mert bx-et használjuk
	mov bl,buffer[1] ;bx-be a beolvasott kar. száma
	mov buffer[bx+2],0 ;végére egy nulla

	mov ah,3dh ;fájl megnyitása
	xor al,al ;csak olvasása
	mov dx,offset buffer[2] ;buff. 3. bájtjától van a fájlnév
	int 21h
	jnc go3
	jmp hiba
	
go3:
	mov file,ax ;FILE HANDLE elmentése
	mov szemafor,1 ;szem. egyesbe
	
;a fájlból való olvasás, ellenõrzés hogy Jani-e, ha igen akkor t-hez hozzáadni egyet

	xor si,si
cik1:
	mov ah,3fh ;fájlból olvasás
	mov bx,file ;FILE HANDLE – bx-be
	mov cx,1 ;egy bájtot
	mov dx,offset buffer ;a bufferba
	add dx,si ;pontosabban si-edik bájtjába
	int 21h
	jnc go8
	jmp hiba
go8:
	cmp ax,0 ;ha ax nulla akkor fájlvége
	jnz go1
	mov fajlvege,1 ;ezt álljtjuk itt be
	jmp go9

;megnézzük hogy amit beolvastunk: vezérlõ karakter? Vezérlõ karakter: 13,10,9,32 – 13,10 sorvége, 9 tabulátor, 32 szóköz
go1:
	cmp buffer[si],13
	jz go9 ;ha igen, akkor elugrunk, és lekezeljük
	cmp buffer[si],10
	jz go9
	cmp buffer[si],9
	jz go9
	cmp buffer[si],32
	jz go9
	jmp go10
	
go9:
	cmp szo,1 ;van új szavunk, vagy ez ami most ért véget még az elõzõ része? 
	mov szo,1 ;mind1, most már ami jön biztos új szó
	jne go12 ;de ha nem volt új szavunk nem ugrunk el
	cmp si,long ;si ben már van kellõ mennyiségû karakter?
	je go2 ;ha igen csak akkor ugrunk el
go12:
	cmp fajlvege,1 ;ha fájlvége van akkor vége
	jne go11
	jmp vege
go11:
	xor si,si ;ha nem akkor si nullázása és tovább olvassuk a szavakat
	jmp cik1
	
go10:
	cmp si,long ;ha az si már long hosszú akkor nullázni kell
	jb go5
	xor si,si 
	mov szo,0
	jmp cik1
go5:
	inc si ;ha viszont nem az akkor plusz egy hozzá
	jmp cik1
	
go2:
	xor di,di
cik2:
	mov al,mit[di] ;itt nézzük meg, hogy a keresett szó van e a bufferban
	cmp al,buffer[di]
	jne go4 ;ha nem itt ugrunk el
	inc di
	cmp di,long
	jb cik2

	inc t ;ha igen minden rendben, akkor t++

go4:
	cmp fajlvege,1 ;fájlvége van már?
	je go7 
	xor si,si ;ha nem akkor tovább keress új szót
	jmp cik1
go7:
	jmp vege
	
;hibák lekezelése
hiba:
	cmp ax,3 ;ax=3?
	jz hiba1
	cmp ax,5
	jz hiba2
	cmp ax,2
	jz hiba3
	
;ha egyik se, akkor ismeretlen hiba
	pstring hibauz4
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
	
;kiírjuk mennyi is volt 
	mov ax,t
	call binascii ;binascii proc. lásd elõbb
	
	pstring text3
	pstring text4
	
	mov ah,0ch ;bill. buffer törlése 
	mov al,7 ;várás egy bill.re echo nélkül
	int 21h
	
	cmp szemafor,0 ;volt megnyitot fájl?
	jz abort

	mov ah,3eh ;ha volt bezárjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;a vezérlés visszaadása a DOS-nak
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk

;beolvasunk egy karaktert a fájlból, megnézzük vezérlõ karakter-e, ha igen akkor megnézzük az elõzõ szó része, vagy különálló szó. Ha különálló, akkor megnézzük Jani-e. Ha igen akkor a számlálóhoz hozzáadunk egyet. Ha a buffer betelik, akkor si-t nullázzuk, és újból elkezdünk bele olvasni. Az si a mutatója, az indexe...