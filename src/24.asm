;Program 24

;Írjon programot, amely megszámolja az aktuális könyvtárban levõ fájlokat, az eredményt pedig kiírja a képernyõre.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
dta db 128 dup(0)
asciiz db '*.*',0
text1 db 'Az aktualis mappaban $'
text2 db ' fajl talalhato.$'
hibauz1 db 13,10,'Nem talalhato fajl!$'
szemaforbin db ?
szam dw 0 ;ide mentjük a fájlok számát

;evvel a procedúrával írjunk ki egy bináris számot a  képernyõre, ebben a programban a szam nevû változót
;ezt a procedúrát szõccsel órán vettük...

binascii proc near ;bemenet ax
	mov szemaforbin,0 ;szemafort nullába állítjuk
	cmp ax,0 ;megnézzük, hogy a kiírandó szám nem nulla e
	jne gop1 ;ha nem továbbmegyünk
	mov ah,2 ;ha igen akkor kiírunk egy nullát
	mov dl,'0'
	int 21h
	jmp vegeproc ;és a proc. végére ugrunk

gop1:
	mov bx,10000 ;10000 fogunk osztani
	xor dx,dx ;osztani fogunk, fontos a dx-et kinullázni, lást  div utasítás

cikp1:
	div bx ;itt osztjuk az ax-et és a kiterjesztését a dx-et a  bx-ben levõ számmal
	mov si,dx ;átvisszük a dx-et az si-be, a dx-ben van a  maradék
	cmp ax,0 ;megnézzük ax-ben nulla van e
	jne gop2 ;ha nem akkor kiírjuk
	cmp szemaforbin,0 ;ha igen, és a szemafor 0 akkor nem  írjuk ki
	je gop3

gop2:
	mov ah,2 ;itt írjuk ki az ax-ben osztás után megkapott  számot
	mov dl,al
	add dl,30h ;hozzáadunk 30h-t, mert ASCII karakterként  írjuk ki
	int 21h
	mov szemaforbin,1 ;már itt egy karaktert biztos kiírtunk, ezért szemafort egyesbe állítjuk

gop3:
	mov ax,bx ;az osztót el kell osztani 10-zel
	mov bx,10 
	xor dx,dx 
	div bx ;itt osztjuk
	cmp ax,1 ;megnézzük, hogy az osztó egy e már
	jb vegeproc ;ha kisebb mint egy akkor vége
	mov bx,ax ;ha nem, akkor bx-be bevisszük az osztót
	mov ax,si ;ax-be vissza az elõzõ maradékot
	jmp cikp1 ;és elölrõl az egészet

vegeproc: 
	ret

binascii endp

start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása
	
	mov ah,1ah ;dta kezdõcímének beállitása
;ez a 4eh ill. 4fh szolgáltatásoknak kell, most igazából különösebb szerepe nincs
	mov dx,offset dta
	int 21h

	mov ah,4eh ;itt lekérjük (keressük) az elsõ fájlt
	mov dx,offset asciiz ;az aktuális mappát figyeljük
	mov cx,0 ;normal fájlokat
	int 21h
	jc hiba ;ha nem találtunk fájlt, kiírjuk, hogy nincs fájl

cik1:	
	inc szam ;megnöveljük a fájlokat számláló változó értékét  eggyel, mivel ha már itt vagyunk, akkor 1 fájl biztosan van
	mov ah,4fh ;itt kezdjük lekérni a további fájlokat
	int 21h
	jnc cik1 ;addig fogjuk ezt ismételni, ameddig talál fájlt

	mov ah,9 ;oké, nincs több fájl, most kiírjuk, hogy mennyi  is volt
	mov dx,offset text1 ;elõször a szöveg elsõ fele
	int 21h

	mov ax,szam ;itt fogjuk „átcsinálni” a szam-ot ASCII-vá, azaz kiírjuk a képernyõre
	call binascii ;ez a procedúra végzi ezt, az ax-ben kapja  meg a kiírandó fájlt
	
	mov ah,9 ;itt meg kiírjuk a szöveg további részét
	mov dx,offset text2
	int 21h

	jmp vege ;átugorjuk a hibaüzenetet

hiba:	
	mov ah,9 ;itt írjuk ki, hogy nincs fájl
	mov dx,offset hibauz1
	int 21h
	
vege:
	mov ah,4ch ;visszaadjuk a vezérlést az op.-nek
	int 21h

code ends ;code nevû szegmens lezárása
	end start ;start cimkénel fogunk belépni a programba