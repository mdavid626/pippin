;Program 09

;Írjon programot, amely a beadott értékek halmazát rendezi kisebbtõl a nagyobbig. Jelenítse meg a beadott halmazt, amely 10 maximálisan kétjegyû egész számokból áll.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

long EQU 10 ;a long jelentse azt, hogy 10, ezzel jelezzük a  beolvasandó számok mennyiségét, egyben a tárolásukra használt  tömb hossza

;változók
text1 db 'Legkisebbtol a legnagyobbig'
      db 13,10,'---------------------------$'
text11 db 13,10,'Adj meg $'
text2 db ' szamot!',13,10,36
text3 db '. szam: $'
text4 db 13,10,13,10,'A beadott szamsor:',13,10,36
text5 db 13,10,13,10,'A szamok rendezve:',13,10,36
text6 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
newline db 13,10,36 ;új sor irásához
hibauz1 db 13,10,'A megadhato legnagyobb szam a 99!$'
buffer_key db 3,0,3 dup(0) ;ide olvassuk be az egyes  karaktereket
buffer_sort db long dup(0) ;ide mentjük a beolvasott számokat
szemafor db ? ;binascii procedúrának
index dw ? ;a buffer_sort tömb indexelésére

;macro string kiírására
kiir macro text
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

;macro szám kiírására
wnum macro param
	mov ax,param
	call binascii
	endm

num macro param
	mov si,offset param
	call asciibin
	endm


;macro a számsor kiírására
wszamsor macro param
	mov di,offset param
	call kiirszamsor
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
	jne gop22 ;ha nem akkor gop22-re
	cmp szemafor,0 ;ha igen, akkor szemafor=0?
	je gop23 ;ha igen, ugrunk a gop23-ra

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
bubblesort proc near ;bemenet si - mutato a rendezendo tomb  elso elemere, long a tomb hossza
	jmp startp5 ;átugorjuk a változókat

;változók
p db ? ;egy szemafor, hogy tudjuk volt csere
buf dw ? ;buffer, amibe elmentjük az si kezdeti értékét
	
startp5:
	mov buf,si ;elõbb mondtam, itt mentjük el
	mov dl,long ;dl-be azt, hogy mennyi bájtot kell rendezni
	
gop51:	
	mov p,0 ;p-t nullázzuk
	mov si,buf ;si-be a kezdeti értékét
	dec dl ;dl-be eggyel kevesebbet 
	jz vegep5 ;ha dl=0 akkor vége

	mov cl,dl ;cl-be dl-t
	
atnezes:
	mov al,byte ptr[si] ;bevisszük al-be, a buffer si-edik  bájtját
	cmp al,byte ptr[si+1] ;megnézzük hogyan viszonyul ez az  elem a következõvel
	jbe gop52 ;LÉNYEGES RÉSZ! Ha kisebb akkor ugrunk, ha ezt  átírjuk jae gop52-re akkor a legnagyobbtól a legkisebbig  rendez

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
kiirszamsor proc near ;bemenet di - mutato a kiirando tombre, long a tomb hossza
	mov cl,long ;cl-be a tömb hosszát
	
cikp61:
	xor ah,ah ;ah nullázása
	mov al,byte ptr[di] ;al-be a di által közvetlenül  megcímzett memóriarekesz tartalmát, egy bájtot
	wnum ax ;kiírjuk az ax-ben levõ számot
	putchar ',' ;kiteszünk egy vesszõt
	inc di ;di köv. elemre
	dec cl ;cl-1, a cl a ciklusszámláló, evvel adom meg, hogy  mennyiszer fusson le a ciklus
	jnz cikp61 ;addig míg cl nem nulla
	
	putchar 8 ;heh, a végén maradt egy fölösleges vesszõ, ez  nekünk nem kell, ezért a 8-as ASCII karakterrel visszalépünk  egyet
	putchar 32 ;és kiírunk egy SPACE-t (szóközt)
	ret ;visszatérünk a fõprogramba
kiirszamsor endp

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	
	clrscr ;képernyõ törlése
	
;kezdõképernyõ felépítése
	kiir text1  ;text1 kiírása
	kiir text11
	wnum long ;ez azért, hogy ha átírjuk fent a long-ot, akkor  az alapján írja ki, hogy adj meg xxx számot
	kiir text2
	
	mov index,1 ;index 1-esbe

;ez a rész olvassa be a számokat
cik1:
	kiir newline ;új sor
	wnum index ;hanyadik számnál vagyunk? írjuk ki
	kiir text3 ;és azt is, hogy . szám: 
	
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
	kiir hibauz1 ;hibaüzi kiírása
	jmp cik1 ;és vissza az elejére

go2:
	num buffer_key+1 ;átalakítjuk a buffer_key-ben levõ  számot, hogy miért buffer_key+1? Lásd a asciibin proc.! 
	
	mov si,index ;elmentjük a számot
	mov buffer_sort[si-1],al ;a tömbünkbe

	inc index ;index a köv. elemre
	cmp index,long ;megnézzük kell-e még elem
	jbe cik1 ;ha igen, akkor olvasunk még
	
;kész, a számokat beolvastuk
	clrscr ;kép. törlése
	kiir text1 ;text1 kiírása
	
	kiir text4 ;text4 kiírása
	wszamsor buffer_sort ;a beolvasott számok kiírása
	
	mov si,offset buffer_sort ;rendezés
	call bubblesort
	
	kiir text5 ;a rendezett számsor kiírása
	wszamsor buffer_sort

	kiir text6 ;a nyomj egy bill.-t a kilépéshez kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy bill.-re echo nélkül
	int 21h
	
	mov ah,4ch ;vezérlés visszaadása az op.-nek
	int 21h

code ends ;code szegmens vége
	end start ;start cimkénél a program belépési pontja