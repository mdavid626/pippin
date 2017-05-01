;Program 22

;�rjon programot, amely sz�veges �llom�nyt m�sol a k�perny�re (a nev�t a bill. adjuk meg) �gy, hogy minden Laci sz�t lecser�l P�ter-re. Az egyes szavak egym�st�l SP, HT, CR �s LF karakterekkel vannak elv�lasztva.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

long EQU 4 ;long nev� konstans, �rt�ke 4, EQU direkt�va

;v�ltoz�k
buffer db 65,0,65 dup(0) ;egy buffer, el�sz�r a f�jl nev�t (el�r�si �tj�t), majd pedig a f�jlb�l val� olvas�s
mit db 'Laci' ;mit akarunk lecser�lni
mire db 'Peter$' ;mire akarjuk lecser�lni
;sz�vegek, amiket ki akarunk �rni
text1 db 'File: $'
text2 db 13,10,'Press any key...$'
hibauz1 db 13,10,'Cant find the path$'
hibauz2 db 13,10,'Access denied!$'
hibauz3 db 13,10,'The file doesnt exist!$'
hibauz4 db 13,10,'Unknown error$'
file dw ? ;a FILE HANDLE sz�m t�rol�s�ra
szemafor db 0 ;volt-e megnyitva f�jl
fajlvege db 0 ;a f�jl v�g�n vagyunk m�r, nincs t�bb olvasnival� karakter
szo db 1 ;ez aminek most a v�g�n egy vezerl� karaktert (sorv�ge, tabul�tor, space) tal�ltunk egy sz� vagy m�g az el�z� sz� r�sze? Ezt jelzi...

;macro egy karakter ki�r�s�ra
putchar macro char
	mov ah,2 ;kettes DOS szolg�ltat�ssal �rjuk ki
	mov dl,char ;a dl-ben l�v� karaktert
	int 21h
	endm

;macro string ki�r�s�ra
pstring macro text
	mov ah,9 ;kilences DOS szolg�ltat�s
	mov dx,offset text
	int 21h
	endm
	
;ez egy proced�ra, fontos, mindig si+1 darab karakert �r ki a buffer-b�l
buf proc near
	xor di,di ;di az index
buf_cik1:
	putchar buffer[di]
	inc di
	cmp di,si ;addig m�g ki nem �runk si+1 darabot
	jbe buf_cik1
	ret
buf endp

start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa

	pstring text1 ;text1 ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;string beolvas�sa a bill.-r�l
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bh,bh ;a bh null�z�sa, mer mi az eg�sz bx-et haszn�ljuk
	mov bl,buffer[1] ;�s csak a bl-be tesz�nk �rt�ket
	mov buffer[bx+2],0 ;a buffer v�g�re tesz�nk egy null�t, az�rt mert ami megnyitja a f�jlt, annak ASCIIZ kell

	mov ah,3dh ;megnyitjuk a f�jlt
	xor al,al ;csak olvas�sra
	mov dx,offset buffer[2] ;a buf. 3. b�jtj�t�l van a f�jln�v
	int 21h
	jnc go3 ;ha nem t�rt�nt hiba tov�bbugrunk
	jmp hiba
	
go3:
	mov file,ax ;a FILE HANDLE elment�se
	mov szemafor,1 ;a szemafor 1esbe
	
	mov ax,3 ;a k�perny� t�rl�se 80x25 m�dba l�p�ssel
	int 10h

	xor si,si ;si kezdeti null�z�sa, a buffer indexet tartalmazza mindig
cik1:
	mov ah,3fh ;olvas�s f�jlb�l
	mov bx,file ;a megnyitott f�jlb�l, FILE HANDLE
	mov cx,1 ;egy b�jtot
	mov dx,offset buffer ;a buffer-ba
	add dx,si ;pontosabban az si-edik b�jtj�ba
	int 21h
	jnc go8 ;ha nem t�rt�nt hiba ugrunk tov�bb
	jmp hiba
go8:
	cmp ax,0 ;ha ax=0 akkor f�jlv�ge
	jnz go1 ;ha nem akkor jo, tov�bb
	mov fajlvege,1 ;ha igen, akkor szem. egyesbe, �s �gy ugrunk
	jmp go9

go1:
	cmp buffer[si],13 ;ha itt vagyunk akkor beolvastunk m�r egy karaktert a f�jlb�l a buffer[si]-be, �s nem vagyunk a f�jl v�g�n, megn�zz�k a beolvasott karakter vez�rl� karakter-e
	jz go9 ;ha igen, akkor ki�rt�kelj�k, mert akkor itt egy sz� v�ge van
	cmp buffer[si],10 ;13,10 - sorv�ge
	jz go9
	cmp buffer[si],9 ;tabul�tor
	jz go9
	cmp buffer[si],32 ;space
	jz go9
	jmp go10

go9:
	cmp szo,1 ;ha a fentiek egyike teljes�lt ide jutunk, na most ha a szo egyesbe volt �ll�tva akkor ok�, mert akkor ami a buffer els� n�gy b�jtj�ba van az egy sz�, ha nem egyes akkor a sz� v�ge itt is van, csak ez a n�gy bet� m�g az el�z� sz�hoz tartozik, nem k�l�n�ll� sz�
	mov szo,1 ;mindenk�pp m�r v�ge a sz�nak �j sz� miatt egyesbe �ll�tom
	jne go12 ;az el�bb a cmp-vel be�ll�tottam a jelz�biteket, most ugrok
	cmp si,long ;ha el�bb nem ugortam el, itt m�g mindig megn�zem hogy meg van-e megfelel� mennyis�g� karakterem, ha igen csak akkor ugrok el megn�zni hogy Laci sz� van benne
	je go2
go12:
	call buf ;ha itt vagyok akkor a buf megtelt ki kell �rni
	cmp fajlvege,1 ;ha f�jlv�ge van akkor ugorni a v�g�re
	jne go11
	jmp vege
go11:
	xor si,si ;az index nulla
	jmp cik1 ;�s vissza az elej�re, �jra olvasn a buffer-ba
	
go10:
	cmp si,long ;ha itt vagyok, megtelt m�r a buffer?
	jb go5 ;ha nem 
	call buf ;buffer ki�r�sa mert megtelt
	xor si,si ;si nulla
	mov szo,0 ;szo nulla mert ami most fog j�nni m�g ehhez tartozik
	jmp cik1
go5:
	inc si ;akkor si n�vel�se eggyel
	jmp cik1
	
go2:
	xor di,di ;di nulla
cik2:
	mov al,mit[di] ;�tn�zem az eg�sz buf. Hogy minden bet�je egyezik-e a mit bet�ivel
	cmp al,buffer[di]
	jne go4 ;ha nem, akkor ugrunk
	inc di
	cmp di,long
	jb cik2

;ha minden stimmelt, akkor ki�rjuk hogy pavel
	pstring mire
	cmp si,long ;megn�zz�k ki kell-e �rni a buffer utols� karakterj�t
	jb go6
	putchar buffer[long] ;ha igen ki�rjuk, f�jlv�g�n�l van ennek jelent�s�ge
	jmp go6
	
go4:
	call buf ;am�gy ha nem Laci volt ki�rjuk a buffert
  
go6:
	cmp fajlvege,1 ;ha f�jlv�ge akkor v�ge
	je go7
	xor si,si ;ha nem si nulla �s el�lr�l
	jmp cik1
go7:
	jmp vege
	
;hiba lekezel�se
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
	
	mov ah,0ch ;bill buffer t�rl�se
	mov al,7 ;v�r�s egy bill-re echo n�lk�l
	int 21h
	
	cmp szemafor,0 ;volt megnyitot f�jl?
	jz abort

	mov ah,3eh ;ha igen bez�rjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;a vez�rl�s visszaad�sa a DOSnak
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk

;olvasunk a f�jlb�l addig am�g vez�rl� karakterre nem bukkanunk, ha ez megt�rt�nk akkor eld�ntj�k hogy ez az el�z� sz� r�sze meg, vagy �j sz� (szo=1?). Ha k�l�n sz� akkor long karakterb�l �ll? Ha igen akkor megn�zz�k hogy Laci van-e benne, ha igen kiirjuk hogy pavel, minden m�s esetben a buffert irjuk ki. Ha betelik akkor ki�rjuk, �s si nulla, �jra el�lr�l �runk bele...