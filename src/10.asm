;Program 10

;Írjon programot, amely beadott értékek halmazát rendezi nagyobbtól a kisebbig, és megjeleníti õket a képernyõn. Jelenítse meg a beadott halmazt is, amely 10 maximálisan kétjegyû egész számot tartalmaz.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

hossz EQU 10 ;a hossz jelentse azt, hogy 10, ezzel jelezzük a  beolvasandó számok mennyiségét, egyben a tárolásukra használt  tömb hossza

;változók
szoveg1 db 'Legkisebbtol a legnagyobbig',13,10,36
szoveg11 db 13,10,'Adj meg $'
szoveg2 db ' szamot!',13,10,36
szoveg3 db '. szam: $'
szoveg4 db 13,10,13,10,'A beadott szamsor:',13,10,36
szoveg5 db 13,10,13,10,'A szamok rendezve:',13,10,36
szoveg6 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
newline db 13,10,36 ;új sor irásához
hibauz1 db 13,10,'Min 0, max 99!$'
buffer_key db 3,0,3 dup(0) ;ide olvassuk be az egyes  karaktereket
buffer_sort db hossz dup(0) ;ide mentjük a beolvasott számokat
szemafor db ? ;binascii procedúrának
i dw ? ;a buffer_sort tömb indexelésére

;macro string kiírására
pstring macro szoveg
	mov ah,9
	mov dx,offset szoveg
	int 21h
	endm ;macro vége

;macro egy karakter kiírására
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm

;macro szám kiírására
writenumber macro param
	mov ax,param
	call binascii
	endm

number macro param
	mov si,offset param
	call asciibin
	endm


;macro a számsor kiírására
writeszamsor macro param
	mov di,offset param
	call pstringszamsor
	endm

;macro a képernyõ törlésére
clrscr macro
	mov ax,3 ;80x25-ös mód beállítása, ezzel a kép. törlése
	int 10h
	endm

;procedúra bináris szám kiírására
binascii proc near ;bemenet ax
	mov szemafor,0 ;szemafor nullázása
	cmp ax,0 ;ax=0?
	jne gop21 ;ha nem akkor megyünk tovább
	putchar '0' ;ha igen, akkor kirakunk egy nullát
	jmp vegep2 ;és megyünk a végére

gop21:	
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;az osztás elõtt nullázni kell a dx-et
	
cikp21:	
	div bx ;osztjuk az ax-et bx-el
	mov si,dx ;a maradék az si-be
	cmp ax,0 ;ax=0?
	jne gop22 ;ha nem akkor binascii_go2-re
	cmp szemafor,0 ;ha igen, akkor szemafor=0?
	je gop23 ;ha igen, ugrunk a binascii_go3-ra

gop22:	
	add al,30h ;al-hez adjunk hozzá 30h, ASCII!
	putchar al ;kitesszük a képernyõre
	mov szemafor,1 ;már itt biztos volt kiírva karakter, ezért  szemafor egyesbe

gop23:
	mov ax,bx ;az osztót osztani kell 10-el
	mov bx,10 ;10-el
	xor dx,dx ;dx nullázása, mint fent
	div bx ;kinullazza a dx-et, osztjuk az ax-et
	cmp ax,1 ;megnézzük ax=1?
	jb vegep2 ;ha kisebb mint 1, akkor vége
	mov bx,ax ;ha nem, bx-be vissza az osztót
	mov ax,si ;ax-be vissza a maradékot
	jmp cikp21 ;vissza az elejére

vegep2:
	ret ;visszatérünk a fõprogramba
binascii endp ;proc. vége

;ASCII karaktereket alakít számmá
asciibin proc near ;bemenet si - mutato buffer+1
                   ;kimenet ax - bin ertek
	mov cl,byte ptr[si] ;bevisszük a cl-be a beolvasott  karakterek számát
	xor ax,ax ;ax-et nullázzuk
	cmp cl,0 ;megnézzük volt-e beolvasott karakter
	ja gop31 ;ha igen, akkor tovább
	jmp vegep3 ;ha nem akkor vége

gop31:	
	mov bx,10 ;10-el fogunk szorozni
	
cikp31:	
	mul bx ;dx nullázva, szorozzuk az ax-et bx-el
	inc si ;si köv. elemre mutasson
	mov dl,byte ptr[si] ;bevisszük dl-be a karaktert
	sub dl,30h ;levonunk belõle 30h, lásd ASCII!
	add ax,dx ;hozzáadjuk az ax-hez a számjegyet
	dec cl ;cl-1
	jnz cikp31 ;addig míg cl!=0 vissza az elejére
	
vegep3:
	ret ;visszatérés a fõprogramba
asciibin endp ;proc. vége

;ez a lényeg, a rendezõ algoritmus
;bubblesort-ot használjuk, mivel kevés az elemszám
bubblesort proc near ;bemenet si - mutato a rendezendo tomb  elso elemere, hossz a tomb hossza
	jmp startp5 ;átugorjuk a változókat

;változók
p db ? ;egy szemafor, hogy tudjuk volt csere
buf dw ? ;buffer, amibe elmentjük az si kezdeti értékét
	
startp5:
	mov buf,si ;elõbb mondtam, itt mentjük el
	mov dl,hossz ;dl-be azt, hogy mennyi bájtot kell rendezni
	
gop51:	
	mov p,0 ;p-t nullázzuk
	mov si,buf ;si-be a kezdeti értékét
	dec dl ;dl-be eggyel kevesebbet 
	jz vegep5 ;ha dl=0 akkor vége

	mov cl,dl ;cl-be dl-t
	
atnezes:
	mov al,byte ptr[si] ;bevisszük al-be, a buffer si-edik  bájtját
	cmp al,byte ptr[si+1] ;megnézzük hogyan viszonyul ez az  elem a következõvel
	jae gop52 ;LÉNYEGES RÉSZ! Ha kisebb akkor ugrunk, ha ezt  átírjuk jbe gop52-re akkor a legkisebbtõl a legnagyobbig  rendez

	xchg al,byte ptr[si+1] ;felcseréljük a két elemet
	mov byte ptr[si],al
	mov p,1 ;és p-t egyesbe állítjuk
	
gop52:	
	inc si ;si köv. elemre mutasson
	dec cl ;cl eggyel kevesebb
	jnz atnezes ;ha cl még nem nulla, akkor vissza az elejére
	
	cmp p,1 ;megnézzük p=1?
	je gop51 ;ha igen, ugrunk

vegep5:
	ret ;visszatérés a fõprogramba
bubblesort endp ;proc. vége

;proc. a számsor kiírására 
pstringszamsor proc near ;bemenet di - mutato a pstringando tombre, hossz a tomb hossza
	mov cl,hossz ;cl-be a tömb hosszát
	
cikp61:
	xor ah,ah ;ah nullázása
	mov al,byte ptr[di] ;al-be a di által közvetlenül  megcímzett memóriarekesz tartalmát, egy bájtot
	writenumber ax ;kiírjuk az ax-ben levõ számot
	putchar ',' ;kiteszünk egy vesszõt
	inc di ;di köv. elemre
	dec cl ;cl-1, a cl a ciklusszámláló, evvel adom meg, hogy  mennyiszer fusson le a ciklus
	jnz cikp61 ;addig míg cl nem nulla
	
	putchar 8 ;heh, a végén maradt egy fölösleges vesszõ, ez  nekünk nem kell, ezért a 8-as ASCII karakterrel visszalépünk  egyet
	putchar 32 ;és kiírunk egy SPACE-t (szóközt)
	ret ;visszatérünk a fõprogramba
pstringszamsor endp

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	
	clrscr ;képernyõ törlése
	
;kezdõképernyõ felépítése
	pstring szoveg1  ;szoveg1 kiírása
	pstring szoveg11
	writenumber hossz ;ez azért, hogy ha átírjuk fent a hossz-ot, akkor  az alapján írja ki, hogy adj meg xxx számot
	pstring szoveg2
	
	mov i,1 ;i 1-esbe

;ez a rész olvassa be a számokat
cik1:
	pstring newline ;új sor
	writenumber i ;hanyadik számnál vagyunk? írjuk ki
	pstring szoveg3 ;és azt is, hogy . szám: 
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása a bill.-rõl
	mov dx,offset buffer_key ;a buffer_key-be
	int 21h ;let’s go
	
;itt végignézzük a beolvasott karaktereket, ha mindegyik  számjegy volt akkor ok, és elmentjük, ha nem akkor hibaüzi, és  nem mentünk
	xor bx,bx ;bx nullázása
	
cik3:
	cmp buffer_key[bx+2],30h
	jb go1 ;a karakter kisebb mint 30h=’0’? Ha igen az baj
	cmp buffer_key[bx+2],39h
	ja go1 ;a karakter nagyobb mint 39h=’9’ Ha igen az baj
	inc bl ;köv. elem
	cmp bl,buffer_key[1]
	jb cik3 ;addig míg végig nem nézzük a tömb összes elemét
	jmp go2 ;ha ide eljutuk, akkor mehetünk tovább

go1:
	pstring hibauz1 ;hibaüzi kiírása
	jmp cik1 ;és vissza az elejére

go2:
	number buffer_key+1 ;átalakítjuk a buffer_key-ben levõ  számot, hogy miért buffer_key+1? Lásd a asciibin proc.! 
	
	mov si,i ;elmentjük a számot
	mov buffer_sort[si-1],al ;a tömbünkbe

	inc i ;i a köv. elemre
	cmp i,hossz ;megnézzük kell-e még elem
	jbe cik1 ;ha igen, akkor olvasunk még
	
;kész, a számokat beolvastuk
	clrscr ;kép. törlése
	pstring szoveg1 ;szoveg1 kiírása
	
	pstring szoveg4 ;szoveg4 kiírása
	writeszamsor buffer_sort ;a beolvasott számok kiírása
	
	mov si,offset buffer_sort ;rendezés
	call bubblesort
	
	pstring szoveg5 ;a rendezett számsor kiírása
	writeszamsor buffer_sort

	pstring szoveg6 ;a nyomj egy bill.-t a kilépéshez kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy bill.-re echo nélkül
	int 21h
	
	mov ah,4ch ;vezérlés visszaadása az op.-nek
	int 21h

code ends ;code szegmens vége
	end start ;start cimkénél a program belépési pontja