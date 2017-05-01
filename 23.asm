;Program 23

;Írjon programot, amely a képernyõre másolja a szöveges állományt, melynek nevét a bil. adjuk meg, úgy, hogy minden Laci szavat áláhúz. Az egyes szavak SP, HT, CR és LF karakterekkel vannak elválasztva.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelem a code nevû szegmenshez a kódszegmenst, és az adatszegmenst

long EQU 4 ;long konstans, értéke 4

;változók
buffer db 65,0,65 dup(0) ;buffer a fájlnév, majd a beolvasott karakterek tárolására
mit db 'Laci' ;mit akarunk aláhúzni
alahuzas db 'ßßßß' ;mivel legyen aláhúzva
;szövegek
text1 db 'File: $'
text2 db 13,10,10,'Press any key...$'
hibauz1 db 13,10,'Cant find the path$'
hibauz2 db 13,10,'Access denied!$'
hibauz3 db 13,10,'The file doesnt exist!$'
hibauz4 db 13,10,'Unknown error$'
file dw ? ;FILE HANDLE eltárolására
szemafor db 0 ;volt megnyitott fájl?
fajlvege db 0 ;fájl végén vagyunk már?
szo db 1 ;új szavunk van, vagy az elõzõ ért véget?
x db ? ;pozíciók elmentésére
y db ?
x1 db ? ;ugyanúgy, késõbb kiderül mire is kell
y1 db ?

;a kurzor áthelyezése
gotoxy macro x0,y0
	mov ah,02h
	mov bh,0 ;nulladik lap
	mov dl,x0
	mov dh,y0
	int 10h
	endm
	
;a kurzorpozíció lekérdezése
getxy macro x0,y0
	mov ah,03h
	mov bh,0 ;nulladik lap, hisz több nincs :D
	int 10h
	mov x0,dl
	mov y0,dh
	endm

;egy karakter kiírása
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm
;string kiírása
pstring macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm
	
;proc. fontos, kiírja a megadott stringet, si+1 darabot, de úgy hogy ha a monitoron a sor végén vagyunk és tovább kell írni, egy üres sort üt pluszba, így a szöveg minden második sorba lesz, és a kimaradt sorokba mehet az aláhúzás
buf proc near ;bx - mit irjunk ki, si - mennyit
	jmp buf_start
x2 db ?
y2 db ?
tab db '   ' ;ha tabulátor (9) kell írni, akkor õ helyette 3 spacet ír, hogy miért? Hehehehe :D mert ez így egyszerûbb... az érdekesség az hogy a proc. saját magát hívja meg ennek a kiírására

buf_start:
	xor di,di ;di az indexeléshez
buf_cik1:
	cmp byte ptr [bx+di],9 ;megnézzük nem tabulátort kell véletlenül kiírni, ha nem akkor elugrunk innen
	jnz buf_go3
	mov byte ptr[bx+di],32 ;a tab helyett teszünk szóközt
	push si bx di ;elmentünk mindent
	mov si,2 ;3 drb kar. kell kiírni
	mov bx,offset tab ;a tab-ot
	call buf ;és itt hívjuk megint a buf-ot, hogy írjon ki nekünk 3 szóközt a tab helyett
	pop di bx si ;amikor végzett, vissza mindent és tovább
buf_go3:
	putchar [bx+di] ;kiírjuk a karaktert
	
	getxy x2,y2 ;lekérjük a kurzorpozíciót
	cmp x2,0 ;megnézzük nem sor elején vagyunk-e
	jnz buf_go2 ;ha nem akkor tovább
	cmp byte ptr [bx+di],13 ;ha igen akkor és nem sor végét írtunk ki akkor egy sorral lejjebb megyünk
	jz buf_go2
	inc y2
	gotoxy x2,y2 ;itt ugrunk lejjebb
	
buf_go2:
	inc di ;köv. betûre léptetjük az indexet
	cmp di,si ;megnézzük nem írtuk ki még az összeset
	jbe buf_cik1 ;ha nem akkor még írjuk
	ret
buf endp
;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása

	pstring text1 ;text1 kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása a bill.-rõl
	mov dx,offset buffer
	int 21h
	
	xor bh,bh ;bh nullázása
	mov bl,buffer[1] ;bl-be a beolvasott kar. száma
	mov buffer[bx+2],0 ;a string végére egy nulla karaktert

	mov ah,3dh ;fájl megnyitása
	xor al,al ;csak olvasásra
	mov dx,offset buffer[2] ;a 3. bájttól kezdõdik a fájlnév
	int 21h
	jnc go3 ;ha nem történt hiba akkor ugrunk
	jmp hiba
	
go3:
	mov file,ax ;FILE HANDLE elmentése
	mov szemafor,1 ;szem. egyesbe
	
	mov ax,3 ;képernyõ törlése 80x25 módba lépéssel
	int 10h

	xor si,si ;si kezdeti nullázása, si az index
cik1:
	mov ah,3fh ;olvasás fájlból
	mov bx,file ;az elõbb megnyitott fájlból akarunk olvasni 
	mov cx,1 ;egy bájtot fogunk olvasni
	mov dx,offset buffer ;a buffer-ba
	add dx,si ;si-edik helyre
	int 21h
	jnc go8 ;ha nincs hiba akkor tovább
	jmp hiba
go8:
	cmp ax,0 ;fájlvége?
	jnz go1 ;ha nem tovább
	mov fajlvege,1 ;ha igen, akkor flag egyesbe és vége
	jmp go9
	
;itt most megnézzük a beolvasott kar. vezérlõ kar.-e, 13,10 sorvége, 9 tabulátor, 32 space

go1:
	cmp buffer[si],13
	jz go9 ;ha valamelyik stimmel elugrunk innen
	cmp buffer[si],10
	jz go9
	cmp buffer[si],9
	jz go9
	cmp buffer[si],32
	jz go9
	jmp go10 ;ha egyik se stimmelt, akkor ugrunk a go10-re

go9:
	cmp szo,1 ;ha egy új szavunk van akkor ugrunk, ha nem akkor mindenképp a szo flaget egyesbe kell állítani mert már biztos új szó lesz legközelebb
	mov szo,1
	jne go12 ;és el kell ugorni ha a szo egyes volt megnézni nem Laci van-e
	cmp si,long ;jaj, de csak akkor ugrunk el, ha van kellõ mennyiségû karakter, ha nincs minek ugorjunk el?
	je go2
go12:
	mov bx,offset buffer ;ha itt vagyunk akkor a long+1 kar. beolvasása után jött vezérlõ karakter, tehát még mindig egy szót olvasunk be, de a szo flag nullába volt, ezért nem mentünk megnézni mi van benne.. szal kiírjuk azt si nullázása és újra olvasás
	call buf ;kiírjuk
	cmp fajlvege,1 ;ha ez a flag egyes akkor vége van...
	jne go11
	jmp vege ;ugrunk a végére
go11:
	xor si,si	
	jmp cik1
	
go10:
	cmp si,long ;itt megnézzük buffer-ba elég kar. van-e
	jb go5 ;ha még kevés olvasunk
	mov bx,offset buffer ;ha betelt kiírju
	call buf
	xor si,si ;si nulla és szo nulla, mert még nem ért véget a szó
	mov szo,0
	jmp cik1 ;és újra olvasás
go5:
	inc si ;ha itt vagyunk a buffer még nincs tele, nincs benne elég kar, ezért inc si--index, és olvasunk még bele
	jmp cik1
	
go2:
	xor di,di ;di nulla

;összehasonlítjuk a mit-et és a buffer-t ha minden stimmel akkor van Laci
cik2:
	mov al,mit[di]
	cmp al,buffer[di]
	jne go4 ;ha már egy nem stimmel akkor nem Laci van
	inc di
	cmp di,long
	jb cik2
	
;ha ide eljutunk Laci van 
	getxy x,y ;elmentjük az aktuális kurzor pozíciót
	mov bx,offset buffer ;kiírjuk a Laci-t
	call buf
	getxy x1,y1 ;elmentjük a mostanit is, figyeled hogy hova? x1, 1 
	
	inc y ;egy sorral fogunk lejjebb menni, de mihez képest? nézd y!!! 
	gotoxy x,y ;na menjünk
	mov si,3 ;si-be 3, így ír ki 4 kar-t
	mov bx,offset alahuzas ;kiírja az aláhúzást
	call buf
	gotoxy x1,y1 ;és visszamegy oda ahol a Laci szó végetért, és már alá is van húzva... :o
	jmp go6
	
go4:
	mov bx,offset buffer ;ha nem Laci volt, akkor meg csak simán kiírjuk a buffert
	call buf
	
go6:
	cmp fajlvege,1 ;ez meg már a vége, ha nem Laci volt vagy ha az is, itt kötünk ki, ha fajlvege flag egyesbe van akkor vége, ha nem akkor si-t nullázzuk, és újra olvasunk... :P
	je go7
	xor si,si
	jmp cik1
go7:
	jmp vege
	
;itt lekezeljük a hibaüziket
hiba:
	cmp ax,3 ;ax=3?
	jz hiba1
	cmp ax,5
	jz hiba2
	cmp ax,2
	jz hiba3
;ha egyik se akkor a hiba ismeretlen
	
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
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy bill.-re echo nélkül
	int 21h
	
	cmp szemafor,0 ;volt megnyitott fájl? 
	jz abort

	mov ah,3eh ;ha volt hát zárd be
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;vezérlés visszaadása a DOS-nak
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk

;Algoritmusa:
;olvasunk a fájlból egy bájtot, megnézzük ez mi: vezérlõ karakter, vagy csak sima karakter, ha vezérlõ akkor valamit kell csinálni, ha nem az, akkor megnézzük betelt már a buffer van elég kar. benne, ha igen akkor kiírjuk a buffert, indexet nullára állítjuk a szo flaget szintén nullába és újra olvasunk, ha nem volt benne elég akkor indexet eggyel tovább teszem és újra olvasok. Mit jelent az hogy van benne elég? Azt hogy van benne long+1 drb, tehát a Laci szónak meg a vezérlõ karaktertnek, tehát hogy tudjuk vége van a szónak. A másik ami történhet hogy vezérlõ karakterbe botlunk, ekkor ha szo egyes volt akkor oké mehetünk megnézni hogy a keresett szó van-e benne, ja és még elõtt hogy van-e egyáltalán benne annyi, ha igen akkor ugrunk oda ahol ezt lekezeljük. Ha a szo nulla, akkor az azt jelenti hogy nincs külön szó, az elõzõ ért véget, most már a szo biztos egyes, ezért egyesbe állítom, és kiírom a buffert aztán vissza újra olvasni. Mindig nézem hogy nincs-e véletlenül fájlvége, ha az van, akkor ki kell lépni, erre figyelni kell... Az ami kiírja az nagyon fontos, fentebb már írtam, dupla sorközzel írja, hogy legyen hely az aláhúzásnak!!!
;Ha oda kerül hogy megtalálta a Laci szót, akkor elõször megnézi hol van a kurzor, elmenti, majd kiírja a Laci-t. Megint elmenti a pozíciót, aztán visszamegy a Laci szó elejére, eggyel lejjebb teszi a kurzort, egy sorral, ez ugyebár biztos üres, ide kiírja az aláhúzást, és visszamegy oda ahol a Laci végetért. Így van egy Laconk kiírva plusz az aláhúzás, de nem gond a kurzor a Laci után villog. Mehet szépen tovább, alá van húzva ahogy kell... :D
;Ha ez nem jött össze nem Laci volt, könnyû kitalálni: kiírja a buffer-t és olvas tovább.. persze si—index nullázza..

;nagyjából ennyi...
;Enjoy! 