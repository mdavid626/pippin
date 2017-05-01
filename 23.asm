;Program 23

;�rjon programot, amely a k�perny�re m�solja a sz�veges �llom�nyt, melynek nev�t a bil. adjuk meg, �gy, hogy minden Laci szavat �l�h�z. Az egyes szavak SP, HT, CR �s LF karakterekkel vannak elv�lasztva.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendelem a code nev� szegmenshez a k�dszegmenst, �s az adatszegmenst

long EQU 4 ;long konstans, �rt�ke 4

;v�ltoz�k
buffer db 65,0,65 dup(0) ;buffer a f�jln�v, majd a beolvasott karakterek t�rol�s�ra
mit db 'Laci' ;mit akarunk al�h�zni
alahuzas db '����' ;mivel legyen al�h�zva
;sz�vegek
text1 db 'File: $'
text2 db 13,10,10,'Press any key...$'
hibauz1 db 13,10,'Cant find the path$'
hibauz2 db 13,10,'Access denied!$'
hibauz3 db 13,10,'The file doesnt exist!$'
hibauz4 db 13,10,'Unknown error$'
file dw ? ;FILE HANDLE elt�rol�s�ra
szemafor db 0 ;volt megnyitott f�jl?
fajlvege db 0 ;f�jl v�g�n vagyunk m�r?
szo db 1 ;�j szavunk van, vagy az el�z� �rt v�get?
x db ? ;poz�ci�k elment�s�re
y db ?
x1 db ? ;ugyan�gy, k�s�bb kider�l mire is kell
y1 db ?

;a kurzor �thelyez�se
gotoxy macro x0,y0
	mov ah,02h
	mov bh,0 ;nulladik lap
	mov dl,x0
	mov dh,y0
	int 10h
	endm
	
;a kurzorpoz�ci� lek�rdez�se
getxy macro x0,y0
	mov ah,03h
	mov bh,0 ;nulladik lap, hisz t�bb nincs :D
	int 10h
	mov x0,dl
	mov y0,dh
	endm

;egy karakter ki�r�sa
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm
;string ki�r�sa
pstring macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm
	
;proc. fontos, ki�rja a megadott stringet, si+1 darabot, de �gy hogy ha a monitoron a sor v�g�n vagyunk �s tov�bb kell �rni, egy �res sort �t pluszba, �gy a sz�veg minden m�sodik sorba lesz, �s a kimaradt sorokba mehet az al�h�z�s
buf proc near ;bx - mit irjunk ki, si - mennyit
	jmp buf_start
x2 db ?
y2 db ?
tab db '   ' ;ha tabul�tor (9) kell �rni, akkor � helyette 3 spacet �r, hogy mi�rt? Hehehehe :D mert ez �gy egyszer�bb... az �rdekess�g az hogy a proc. saj�t mag�t h�vja meg ennek a ki�r�s�ra

buf_start:
	xor di,di ;di az indexel�shez
buf_cik1:
	cmp byte ptr [bx+di],9 ;megn�zz�k nem tabul�tort kell v�letlen�l ki�rni, ha nem akkor elugrunk innen
	jnz buf_go3
	mov byte ptr[bx+di],32 ;a tab helyett tesz�nk sz�k�zt
	push si bx di ;elment�nk mindent
	mov si,2 ;3 drb kar. kell ki�rni
	mov bx,offset tab ;a tab-ot
	call buf ;�s itt h�vjuk megint a buf-ot, hogy �rjon ki nek�nk 3 sz�k�zt a tab helyett
	pop di bx si ;amikor v�gzett, vissza mindent �s tov�bb
buf_go3:
	putchar [bx+di] ;ki�rjuk a karaktert
	
	getxy x2,y2 ;lek�rj�k a kurzorpoz�ci�t
	cmp x2,0 ;megn�zz�k nem sor elej�n vagyunk-e
	jnz buf_go2 ;ha nem akkor tov�bb
	cmp byte ptr [bx+di],13 ;ha igen akkor �s nem sor v�g�t �rtunk ki akkor egy sorral lejjebb megy�nk
	jz buf_go2
	inc y2
	gotoxy x2,y2 ;itt ugrunk lejjebb
	
buf_go2:
	inc di ;k�v. bet�re l�ptetj�k az indexet
	cmp di,si ;megn�zz�k nem �rtuk ki m�g az �sszeset
	jbe buf_cik1 ;ha nem akkor m�g �rjuk
	ret
buf endp
;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa

	pstring text1 ;text1 ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;string beolvas�sa a bill.-r�l
	mov dx,offset buffer
	int 21h
	
	xor bh,bh ;bh null�z�sa
	mov bl,buffer[1] ;bl-be a beolvasott kar. sz�ma
	mov buffer[bx+2],0 ;a string v�g�re egy nulla karaktert

	mov ah,3dh ;f�jl megnyit�sa
	xor al,al ;csak olvas�sra
	mov dx,offset buffer[2] ;a 3. b�jtt�l kezd�dik a f�jln�v
	int 21h
	jnc go3 ;ha nem t�rt�nt hiba akkor ugrunk
	jmp hiba
	
go3:
	mov file,ax ;FILE HANDLE elment�se
	mov szemafor,1 ;szem. egyesbe
	
	mov ax,3 ;k�perny� t�rl�se 80x25 m�dba l�p�ssel
	int 10h

	xor si,si ;si kezdeti null�z�sa, si az index
cik1:
	mov ah,3fh ;olvas�s f�jlb�l
	mov bx,file ;az el�bb megnyitott f�jlb�l akarunk olvasni 
	mov cx,1 ;egy b�jtot fogunk olvasni
	mov dx,offset buffer ;a buffer-ba
	add dx,si ;si-edik helyre
	int 21h
	jnc go8 ;ha nincs hiba akkor tov�bb
	jmp hiba
go8:
	cmp ax,0 ;f�jlv�ge?
	jnz go1 ;ha nem tov�bb
	mov fajlvege,1 ;ha igen, akkor flag egyesbe �s v�ge
	jmp go9
	
;itt most megn�zz�k a beolvasott kar. vez�rl� kar.-e, 13,10 sorv�ge, 9 tabul�tor, 32 space

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
	cmp szo,1 ;ha egy �j szavunk van akkor ugrunk, ha nem akkor mindenk�pp a szo flaget egyesbe kell �ll�tani mert m�r biztos �j sz� lesz legk�zelebb
	mov szo,1
	jne go12 ;�s el kell ugorni ha a szo egyes volt megn�zni nem Laci van-e
	cmp si,long ;jaj, de csak akkor ugrunk el, ha van kell� mennyis�g� karakter, ha nincs minek ugorjunk el?
	je go2
go12:
	mov bx,offset buffer ;ha itt vagyunk akkor a long+1 kar. beolvas�sa ut�n j�tt vez�rl� karakter, teh�t m�g mindig egy sz�t olvasunk be, de a szo flag null�ba volt, ez�rt nem ment�nk megn�zni mi van benne.. szal ki�rjuk azt si null�z�sa �s �jra olvas�s
	call buf ;ki�rjuk
	cmp fajlvege,1 ;ha ez a flag egyes akkor v�ge van...
	jne go11
	jmp vege ;ugrunk a v�g�re
go11:
	xor si,si	
	jmp cik1
	
go10:
	cmp si,long ;itt megn�zz�k buffer-ba el�g kar. van-e
	jb go5 ;ha m�g kev�s olvasunk
	mov bx,offset buffer ;ha betelt ki�rju
	call buf
	xor si,si ;si nulla �s szo nulla, mert m�g nem �rt v�get a sz�
	mov szo,0
	jmp cik1 ;�s �jra olvas�s
go5:
	inc si ;ha itt vagyunk a buffer m�g nincs tele, nincs benne el�g kar, ez�rt inc si--index, �s olvasunk m�g bele
	jmp cik1
	
go2:
	xor di,di ;di nulla

;�sszehasonl�tjuk a mit-et �s a buffer-t ha minden stimmel akkor van Laci
cik2:
	mov al,mit[di]
	cmp al,buffer[di]
	jne go4 ;ha m�r egy nem stimmel akkor nem Laci van
	inc di
	cmp di,long
	jb cik2
	
;ha ide eljutunk Laci van 
	getxy x,y ;elmentj�k az aktu�lis kurzor poz�ci�t
	mov bx,offset buffer ;ki�rjuk a Laci-t
	call buf
	getxy x1,y1 ;elmentj�k a mostanit is, figyeled hogy hova? x1, 1 
	
	inc y ;egy sorral fogunk lejjebb menni, de mihez k�pest? n�zd y!!! 
	gotoxy x,y ;na menj�nk
	mov si,3 ;si-be 3, �gy �r ki 4 kar-t
	mov bx,offset alahuzas ;ki�rja az al�h�z�st
	call buf
	gotoxy x1,y1 ;�s visszamegy oda ahol a Laci sz� v�get�rt, �s m�r al� is van h�zva... :o
	jmp go6
	
go4:
	mov bx,offset buffer ;ha nem Laci volt, akkor meg csak sim�n ki�rjuk a buffert
	call buf
	
go6:
	cmp fajlvege,1 ;ez meg m�r a v�ge, ha nem Laci volt vagy ha az is, itt k�t�nk ki, ha fajlvege flag egyesbe van akkor v�ge, ha nem akkor si-t null�zzuk, �s �jra olvasunk... :P
	je go7
	xor si,si
	jmp cik1
go7:
	jmp vege
	
;itt lekezelj�k a hiba�ziket
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
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy bill.-re echo n�lk�l
	int 21h
	
	cmp szemafor,0 ;volt megnyitott f�jl? 
	jz abort

	mov ah,3eh ;ha volt h�t z�rd be
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;vez�rl�s visszaad�sa a DOS-nak
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk

;Algoritmusa:
;olvasunk a f�jlb�l egy b�jtot, megn�zz�k ez mi: vez�rl� karakter, vagy csak sima karakter, ha vez�rl� akkor valamit kell csin�lni, ha nem az, akkor megn�zz�k betelt m�r a buffer van el�g kar. benne, ha igen akkor ki�rjuk a buffert, indexet null�ra �ll�tjuk a szo flaget szint�n null�ba �s �jra olvasunk, ha nem volt benne el�g akkor indexet eggyel tov�bb teszem �s �jra olvasok. Mit jelent az hogy van benne el�g? Azt hogy van benne long+1 drb, teh�t a Laci sz�nak meg a vez�rl� karaktertnek, teh�t hogy tudjuk v�ge van a sz�nak. A m�sik ami t�rt�nhet hogy vez�rl� karakterbe botlunk, ekkor ha szo egyes volt akkor ok� mehet�nk megn�zni hogy a keresett sz� van-e benne, ja �s m�g el�tt hogy van-e egy�ltal�n benne annyi, ha igen akkor ugrunk oda ahol ezt lekezelj�k. Ha a szo nulla, akkor az azt jelenti hogy nincs k�l�n sz�, az el�z� �rt v�get, most m�r a szo biztos egyes, ez�rt egyesbe �ll�tom, �s ki�rom a buffert azt�n vissza �jra olvasni. Mindig n�zem hogy nincs-e v�letlen�l f�jlv�ge, ha az van, akkor ki kell l�pni, erre figyelni kell... Az ami ki�rja az nagyon fontos, fentebb m�r �rtam, dupla sork�zzel �rja, hogy legyen hely az al�h�z�snak!!!
;Ha oda ker�l hogy megtal�lta a Laci sz�t, akkor el�sz�r megn�zi hol van a kurzor, elmenti, majd ki�rja a Laci-t. Megint elmenti a poz�ci�t, azt�n visszamegy a Laci sz� elej�re, eggyel lejjebb teszi a kurzort, egy sorral, ez ugyeb�r biztos �res, ide ki�rja az al�h�z�st, �s visszamegy oda ahol a Laci v�get�rt. �gy van egy Laconk ki�rva plusz az al�h�z�s, de nem gond a kurzor a Laci ut�n villog. Mehet sz�pen tov�bb, al� van h�zva ahogy kell... :D
;Ha ez nem j�tt �ssze nem Laci volt, k�nny� kital�lni: ki�rja a buffer-t �s olvas tov�bb.. persze si�index null�zza..

;nagyj�b�l ennyi...
;Enjoy! 