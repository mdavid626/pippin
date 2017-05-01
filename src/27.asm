;Program 27

;�rjon programot, amely megsz�molja a Jani szavakat a sz�veges �llom�nyban, �s megjelen�ti ezt a mennyis�get a k�perny�n. Az egyes szavak SP, HT, CR �s LF karakterekkel vannak elv�lasztva. Az �llom�ny nev�t k�rje be a billenty�zetr�l, �s hiba eset�n jelen�tsen meg hiba�zenetet.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

long EQU 4 ;long konstans �rt�ke 4

;v�ltoz�k
buffer db 65,0,65 dup(0) ;buffer a f�jl nev�nek, majd pedig a f�jlb�l val� olvas�sra is
mit db 'Jani' ;Jani sz�t keress�k
;sz�vegek, amiket ki akarunk �rni
text1 db 'File: $'
text2 db 13,10,'A Jani szo $'
text3 db '-szor jelenik meg a fajlban.$'
text4 db 13,10,'Press any key...$'
hibauz1 db 13,10,'Nem talalhato az ut!$'
hibauz2 db 13,10,'Hozzaferes megtagadva!$'
hibauz3 db 13,10,'A fajl nem letezik!$'
hibauz4 db 13,10,'Ismeretlen hiba!$'
file dw ? ;FILE HANDLE elment�s�re
szemafor db 0 ;volt megnyitot f�jl?
fajlvege db 0 ;f�jlv�ge van?
szo db 1 ;szavat tal�ltunk, vagy csak az el�z� sz�nak van v�ge
t dw 0 ;sz�molunk..mennyi is van?

;macro string ki�r�s�ra
pstring macro text
	mov ah,9 ;kilences DOS szolg�ltat�s
	mov dx,offset text
	int 21h
	endm
	
;proc. bin�ris sz�m ki�r�s�ra a k�perny�re 
binascii proc near ;bemenet ax
	jmp binascii_start
	
flag db ? ;van m�r ki�rt karakter?

binascii_start:
	mov flag,0 ;m�g nincs kiirt karakter, ez�rt flag nulla
	cmp ax,0 ;ax=0?
	jne binascii_go1
	mov ah,2 ;ha igen akkor ki�runk egy null�t
	mov dl,'0'
	int 21h
	ret

binascii_go1:	
	mov bx,10000 ;ha nem nulla, akkor sz�pen ki�rjuk a sz�mot
	xor dx,dx ;el�sz�r 10ezerrel osztunk, majd sz�pen ezerrel, sz�zzal...
	
binascii_cik1:	
	div bx ;oszd el az ax-et bx-el
	mov si,dx ;marad�kot az si-be
	cmp ax,0 ;ax=0
	jne binascii_go2 ;a sz�m amit kaptunk 0? Ha igen akkor a flagt�l f�gg ki �runk-e valamit
	cmp flag,0 ;ha flag nulla akkor nem �runk ki semmit
	je binascii_go3

binascii_go2:	
	mov ah,2 ;ha minden ok akkor ki�rjuk a sz�mjegyet
	mov dl,al
	add dl,30h ;ASCII
	int 21h
	mov flag,1 ;flag m�r egyesbe

binascii_go3:	
	mov ax,bx ;elosztjuk a bx-et 10-el
	mov bx,10
	xor dx,dx
	div bx ;kinullazza a dx-et, elosztja az ax-et bx-el
	cmp ax,1 ;addig m�g ax nagyobb vagy egyenl� 1el
	jb binascii_vege
	mov bx,ax ;ax vissza bx-be
	mov ax,si ;sib�l a marad�k vissza az ax-be
	jmp binascii_cik1 ;vissza az elej�re

binascii_vege:
	ret
binascii endp

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	mov ax,3 ;k�perny� t�rl�se
	int 10h
	
	pstring text1 ;text1 ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;string beolvas�sa
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bh,bh ;bh null�z�sa, mert bx-et haszn�ljuk
	mov bl,buffer[1] ;bx-be a beolvasott kar. sz�ma
	mov buffer[bx+2],0 ;v�g�re egy nulla

	mov ah,3dh ;f�jl megnyit�sa
	xor al,al ;csak olvas�sa
	mov dx,offset buffer[2] ;buff. 3. b�jtj�t�l van a f�jln�v
	int 21h
	jnc go3
	jmp hiba
	
go3:
	mov file,ax ;FILE HANDLE elment�se
	mov szemafor,1 ;szem. egyesbe
	
;a f�jlb�l val� olvas�s, ellen�rz�s hogy Jani-e, ha igen akkor t-hez hozz�adni egyet

	xor si,si
cik1:
	mov ah,3fh ;f�jlb�l olvas�s
	mov bx,file ;FILE HANDLE � bx-be
	mov cx,1 ;egy b�jtot
	mov dx,offset buffer ;a bufferba
	add dx,si ;pontosabban si-edik b�jtj�ba
	int 21h
	jnc go8
	jmp hiba
go8:
	cmp ax,0 ;ha ax nulla akkor f�jlv�ge
	jnz go1
	mov fajlvege,1 ;ezt �lljtjuk itt be
	jmp go9

;megn�zz�k hogy amit beolvastunk: vez�rl� karakter? Vez�rl� karakter: 13,10,9,32 � 13,10 sorv�ge, 9 tabul�tor, 32 sz�k�z
go1:
	cmp buffer[si],13
	jz go9 ;ha igen, akkor elugrunk, �s lekezelj�k
	cmp buffer[si],10
	jz go9
	cmp buffer[si],9
	jz go9
	cmp buffer[si],32
	jz go9
	jmp go10
	
go9:
	cmp szo,1 ;van �j szavunk, vagy ez ami most �rt v�get m�g az el�z� r�sze? 
	mov szo,1 ;mind1, most m�r ami j�n biztos �j sz�
	jne go12 ;de ha nem volt �j szavunk nem ugrunk el
	cmp si,long ;si ben m�r van kell� mennyis�g� karakter?
	je go2 ;ha igen csak akkor ugrunk el
go12:
	cmp fajlvege,1 ;ha f�jlv�ge van akkor v�ge
	jne go11
	jmp vege
go11:
	xor si,si ;ha nem akkor si null�z�sa �s tov�bb olvassuk a szavakat
	jmp cik1
	
go10:
	cmp si,long ;ha az si m�r long hossz� akkor null�zni kell
	jb go5
	xor si,si 
	mov szo,0
	jmp cik1
go5:
	inc si ;ha viszont nem az akkor plusz egy hozz�
	jmp cik1
	
go2:
	xor di,di
cik2:
	mov al,mit[di] ;itt n�zz�k meg, hogy a keresett sz� van e a bufferban
	cmp al,buffer[di]
	jne go4 ;ha nem itt ugrunk el
	inc di
	cmp di,long
	jb cik2

	inc t ;ha igen minden rendben, akkor t++

go4:
	cmp fajlvege,1 ;f�jlv�ge van m�r?
	je go7 
	xor si,si ;ha nem akkor tov�bb keress �j sz�t
	jmp cik1
go7:
	jmp vege
	
;hib�k lekezel�se
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
	
;ki�rjuk mennyi is volt 
	mov ax,t
	call binascii ;binascii proc. l�sd el�bb
	
	pstring text3
	pstring text4
	
	mov ah,0ch ;bill. buffer t�rl�se 
	mov al,7 ;v�r�s egy bill.re echo n�lk�l
	int 21h
	
	cmp szemafor,0 ;volt megnyitot f�jl?
	jz abort

	mov ah,3eh ;ha volt bez�rjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;a vez�rl�s visszaad�sa a DOS-nak
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk

;beolvasunk egy karaktert a f�jlb�l, megn�zz�k vez�rl� karakter-e, ha igen akkor megn�zz�k az el�z� sz� r�sze, vagy k�l�n�ll� sz�. Ha k�l�n�ll�, akkor megn�zz�k Jani-e. Ha igen akkor a sz�ml�l�hoz hozz�adunk egyet. Ha a buffer betelik, akkor si-t null�zzuk, �s �jb�l elkezd�nk bele olvasni. Az si a mutat�ja, az indexe...