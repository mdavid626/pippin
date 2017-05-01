;Program 22

;Írjon programot, amely szöveges állományt másol a képernyõre (a nevét a bill. adjuk meg) úgy, hogy minden Laci szót lecserél Péter-re. Az egyes szavak egymástól SP, HT, CR és LF karakterekkel vannak elválasztva.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

long EQU 4 ;long nevû konstans, értéke 4, EQU direktíva

;változók
buffer db 65,0,65 dup(0) ;egy buffer, elõször a fájl nevét (elérési útját), majd pedig a fájlból való olvasás
mit db 'Laci' ;mit akarunk lecserélni
mire db 'Peter$' ;mire akarjuk lecserélni
;szövegek, amiket ki akarunk írni
text1 db 'File: $'
text2 db 13,10,'Press any key...$'
hibauz1 db 13,10,'Cant find the path$'
hibauz2 db 13,10,'Access denied!$'
hibauz3 db 13,10,'The file doesnt exist!$'
hibauz4 db 13,10,'Unknown error$'
file dw ? ;a FILE HANDLE szám tárolására
szemafor db 0 ;volt-e megnyitva fájl
fajlvege db 0 ;a fájl végén vagyunk már, nincs több olvasnivaló karakter
szo db 1 ;ez aminek most a végén egy vezerlõ karaktert (sorvége, tabulátor, space) találtunk egy szó vagy még az elõzõ szó része? Ezt jelzi...

;macro egy karakter kiírására
putchar macro char
	mov ah,2 ;kettes DOS szolgáltatással írjuk ki
	mov dl,char ;a dl-ben lévõ karaktert
	int 21h
	endm

;macro string kiírására
pstring macro text
	mov ah,9 ;kilences DOS szolgáltatás
	mov dx,offset text
	int 21h
	endm
	
;ez egy procedúra, fontos, mindig si+1 darab karakert ír ki a buffer-bõl
buf proc near
	xor di,di ;di az index
buf_cik1:
	putchar buffer[di]
	inc di
	cmp di,si ;addig míg ki nem írunk si+1 darabot
	jbe buf_cik1
	ret
buf endp

start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása

	pstring text1 ;text1 kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása a bill.-rõl
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bh,bh ;a bh nullázása, mer mi az egész bx-et használjuk
	mov bl,buffer[1] ;és csak a bl-be teszünk értéket
	mov buffer[bx+2],0 ;a buffer végére teszünk egy nullát, azért mert ami megnyitja a fájlt, annak ASCIIZ kell

	mov ah,3dh ;megnyitjuk a fájlt
	xor al,al ;csak olvasásra
	mov dx,offset buffer[2] ;a buf. 3. bájtjától van a fájlnév
	int 21h
	jnc go3 ;ha nem történt hiba továbbugrunk
	jmp hiba
	
go3:
	mov file,ax ;a FILE HANDLE elmentése
	mov szemafor,1 ;a szemafor 1esbe
	
	mov ax,3 ;a képernyõ törlése 80x25 módba lépéssel
	int 10h

	xor si,si ;si kezdeti nullázása, a buffer indexet tartalmazza mindig
cik1:
	mov ah,3fh ;olvasás fájlból
	mov bx,file ;a megnyitott fájlból, FILE HANDLE
	mov cx,1 ;egy bájtot
	mov dx,offset buffer ;a buffer-ba
	add dx,si ;pontosabban az si-edik bájtjába
	int 21h
	jnc go8 ;ha nem történt hiba ugrunk tovább
	jmp hiba
go8:
	cmp ax,0 ;ha ax=0 akkor fájlvége
	jnz go1 ;ha nem akkor jo, tovább
	mov fajlvege,1 ;ha igen, akkor szem. egyesbe, és így ugrunk
	jmp go9

go1:
	cmp buffer[si],13 ;ha itt vagyunk akkor beolvastunk már egy karaktert a fájlból a buffer[si]-be, és nem vagyunk a fájl végén, megnézzük a beolvasott karakter vezérlõ karakter-e
	jz go9 ;ha igen, akkor kiértékeljük, mert akkor itt egy szó vége van
	cmp buffer[si],10 ;13,10 - sorvége
	jz go9
	cmp buffer[si],9 ;tabulátor
	jz go9
	cmp buffer[si],32 ;space
	jz go9
	jmp go10

go9:
	cmp szo,1 ;ha a fentiek egyike teljesült ide jutunk, na most ha a szo egyesbe volt állítva akkor oké, mert akkor ami a buffer elsõ négy bájtjába van az egy szó, ha nem egyes akkor a szó vége itt is van, csak ez a négy betû még az elõzõ szóhoz tartozik, nem különálló szó
	mov szo,1 ;mindenképp már vége a szónak új szó miatt egyesbe állítom
	jne go12 ;az elõbb a cmp-vel beállítottam a jelzõbiteket, most ugrok
	cmp si,long ;ha elõbb nem ugortam el, itt még mindig megnézem hogy meg van-e megfelelõ mennyiségû karakterem, ha igen csak akkor ugrok el megnézni hogy Laci szó van benne
	je go2
go12:
	call buf ;ha itt vagyok akkor a buf megtelt ki kell írni
	cmp fajlvege,1 ;ha fájlvége van akkor ugorni a végére
	jne go11
	jmp vege
go11:
	xor si,si ;az index nulla
	jmp cik1 ;és vissza az elejére, újra olvasn a buffer-ba
	
go10:
	cmp si,long ;ha itt vagyok, megtelt már a buffer?
	jb go5 ;ha nem 
	call buf ;buffer kiírása mert megtelt
	xor si,si ;si nulla
	mov szo,0 ;szo nulla mert ami most fog jönni még ehhez tartozik
	jmp cik1
go5:
	inc si ;akkor si növelése eggyel
	jmp cik1
	
go2:
	xor di,di ;di nulla
cik2:
	mov al,mit[di] ;átnézem az egész buf. Hogy minden betûje egyezik-e a mit betûivel
	cmp al,buffer[di]
	jne go4 ;ha nem, akkor ugrunk
	inc di
	cmp di,long
	jb cik2

;ha minden stimmelt, akkor kiírjuk hogy pavel
	pstring mire
	cmp si,long ;megnézzük ki kell-e írni a buffer utolsó karakterjét
	jb go6
	putchar buffer[long] ;ha igen kiírjuk, fájlvégénél van ennek jelentõsége
	jmp go6
	
go4:
	call buf ;amúgy ha nem Laci volt kiírjuk a buffert
  
go6:
	cmp fajlvege,1 ;ha fájlvége akkor vége
	je go7
	xor si,si ;ha nem si nulla és elölrõl
	jmp cik1
go7:
	jmp vege
	
;hiba lekezelése
hiba:
	cmp ax,3 ;ax=3?
	jz hiba1
	cmp ax,5
	jz hiba2
	cmp ax,2
	jz hiba3
	
;ha egyik se hiba ismeretlen
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
	
	mov ah,0ch ;bill buffer törlése
	mov al,7 ;várás egy bill-re echo nélkül
	int 21h
	
	cmp szemafor,0 ;volt megnyitot fájl?
	jz abort

	mov ah,3eh ;ha igen bezárjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;a vezérlés visszaadása a DOSnak
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk

;olvasunk a fájlból addig amíg vezérlõ karakterre nem bukkanunk, ha ez megtörténk akkor eldöntjük hogy ez az elõzõ szó része meg, vagy új szó (szo=1?). Ha külön szó akkor long karakterbõl áll? Ha igen akkor megnézzük hogy Laci van-e benne, ha igen kiirjuk hogy pavel, minden más esetben a buffert irjuk ki. Ha betelik akkor kiírjuk, és si nulla, újra elölrõl írunk bele...