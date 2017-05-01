;Program 15

;�rjon programot, amely megjelen�ti a le�t�tt billenty� hexadecim�lis �s decim�lis k�dj�t.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
text1 db 'A leutott billentyu kodjanak megjelenitese'
      db 13,10,'------------------------------------------'
      db 13,10,'Uss ESC-t a kilepeshez!',13,10,13,10
      db 13,10,'A leutott billentyu kodja:'
      db 13,10,'--------------------------'
      db 13,10,'Decimalis    :'
      db 13,10,'Hexadecimalis:'
      db 13,10,'--------------------------$'
newline db 13,10,36 ;�jsor
spec db '0+$' ;ha speci�lis bill. volt le�tve, ezzel jelezz�k
torles db 10 dup(32) ;hehe, ez �rdekes, ki�runk 10 sz�k�zt
       db 10 dup(8),36 ;azt�n meg visszal�p�nk 10-et, teh�t  let�r�lt�nk 10 karaktert
kar db ? ;ide mentj�k a beolvasott karaktert
szemaforspec db 0 ;ezzel jelezz�k, hogy speci�lis bill. volt  le�tve

;macro string ki�r�s�ra
printstring macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm ;macro v�ge

;macro egy karakter ki�r�s�ra
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm

;macro a kurzor �thelyez�s�re
gotoxy macro x,y
	mov ah,2
	xor bh,bh ;0-dik lap
	mov dh,y ;dh-ba a sor koordin�t�ja
	mov dl,x ;dl-be az oszlop�
	int 10h ;ezt egy BIOS szolg�ltat�s v�gzi
	endm

;procedura bin�ris sz�m ki�r�s�ra
binascii proc near ;bemenet ax
	jmp startp1 ;�tugorujuk a v�ltoz�kat

szemaforbin db ? ;kezdeti null�kat nem akarjuk ki�rni, ez�rt  kell ez, hogy tudjuk, m�r volt ki�rva sz�m, m�r lehet �rni a  null�kat

startp1: ;itt kezd�nk
	mov szemaforbin,0 ;null�zzuk
	cmp ax,0 ;megn�zz�k, nem null�t kaptunk-e
	jne gop11 ;ha nem tov�bbugrunk
	putchar '0' ;ha igen, ki�runk egy null�t
	jmp vegep1 ;�s ugrunk a v�g�re

gop11:
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;dx-et null�zni kell, l�sd div utas�t�s

cikp11:
	div bx ;osztjuk az ax-et 10000-rel
	mov si,dx ;marad�k si-be
	cmp ax,0 ;megn�zz�k ax-ben nulla van-e
	jne gop12 ;ha nem akkor ki�rjuk
	cmp szemaforbin,0 ;ha volt m�r ki�rva sz�m akkor ki�rjuk, ha nem akkor nem �rjuk ki
	je gop13

gop12:
	mov ah,2 ;ki�rjuk a sz�mjegyet
	mov dl,al
	add dl,30h ;ASCII k�d! ez�rt kell +30h
	int 21h
	mov szemaforbin,1 ;itt m�r biztos volt ki�rt sz�m, ez�rt a  szemafor 1-esbe

gop13:
	mov ax,bx ;az oszt�t osztjuk 10-el
	mov bx,10
	xor dx,dx ;mint az el�bb, null�zni kell!
	div bx ;osztunk
	cmp ax,1 ;ax=1?
	jb vegep1 ;ha kisebb akkor v�ge
	mov bx,ax ;vissza a bx-be az oszt�t
	mov ax,si ;ax-be meg az el�bbi marad�kot
	jmp cikp11 ;vissz az elej�re

vegep1: 
	ret ;visszat�r�s

binascii endp ;a proc. v�ge

;proced�ra hexadecim�lis ki�r�shoz
hexascii proc near ;bemenet ax	
	jmp startp2 ;�tugorjuk a kezdeti v�ltoz�kat

;v�ltoz�k
szemaforhex1 db ? ;null�k indik�l�sa
s1 db ? ;ennyivel kell majd shiftelni a sz�mot
char db ? ;ide mentj�k a sz�mjegyet
temp dw ? ;elmentj�k az elej�n az ax-et

startp2:
	mov szemaforhex1,0 ;be�lligatjuk a szemafort
	mov bx,0f000h ;bx-ben lesz a maszk
	mov s1,16 ;16-nyit shiftel�nk el�sz�r
	mov temp,ax ;elmentj�k az ax-et
	
cikp21:
	mov ax,temp ;visszahozzuk az ax-et
	sub s1,4 ;s1-4, mindig 4-el kevesebbet kell shiftelni
	
	and ax,bx ;na itt a l�nyeg, az ax mindig csak 4 bitj�t  n�zz�k a t�bbit kil�j�k
	mov cl,s1 ;shiftelj�k az al �elej�re�
	shr ax,cl ;itt
	mov char,al ;�s elmentj�k a char-ba

	mov cl,4 ;a maszkot is shiftelni kell
	shr bx,cl
	
	cmp char,0 ;megn�zz�k 0-�t kaptunk-e
	jne gop21 ;ha nem akkor tov�bb
	cmp szemaforhex1,0 ;ha igen, megn�zz�k: volt m�r ki�rva  sz�m?
	je gop22 ;ha nem akkor nem �rjuk ki, ugr�s v�g�re

gop21:
	cmp char,9 ;megn�zz�k sz�mjegy, vagy bet� amit kaptunk
	ja gop23 ;ha bet�, ugrunk
	
	add char,30h ;ha sz�mjegy, akkor 30h-t kell hozz�adni
	putchar char ;�s ki�rni
	
	jmp gop25 ;ugr�s v�g�re
	
;ha bet�
gop23:
	cmp szemaforhex1,0 ;megn�zz�k volt-e m�r ki�rva sz�mjegy
	jne gop24 ;ha nem...
	putchar '0' ;...akkor ki�runk egy null�t

gop24:
	add char,37h ;a bet�hez ennyit kell hozz�adni, 
;65-10=55=37h, 65 az A bet� k�dja
	putchar char ;�s ki�rjuk

gop25:
	mov szemaforhex1,1 ;biztos volt ki�rva karakter, szemafor  egyesbe

gop22:
	cmp s1,0 ;v�g�n vagyunk m�r? 
	jne cikp21 ;ha s1-be nincs 0, akkor vissza az elej�re
	
	putchar 'h' ;a v�g�re egy h bet�t
	ret ;visszat�r�nk
hexascii endp ;proc. v�ge

;f�program
start:	 
	mov ax,cs ;adatszegmens be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	mov ax,3 ;k�perny� t�rl�se, 80x25-�s m�dba val� l�p�ssel
	int 10h ;ezt egy BIOS szolg�ltat�s v�gzi

	printstring text1 ;ki�rjuk a text1-et

	mov ah,1 ;elt�ntetj�k a kurzort
	mov ch,20h
	int 10h

cik1:	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;egy karakter beolvas�sa echo n�lk�l
	int 21h
	mov kar,al ;elmentj�k a karaktert

	cmp kar,0 ;megn�zz�k nem spec. bill. volt le�tve
	jne go1 ;ha nem, akkor tov�bb
	mov ah,7 ;ha igen, lek�j�k a m�sodik b�jtot is
	int 21h
	mov kar,al ;�s elmentj�k a kar-ba
	mov szemaforspec,1 ;igen, spec. karakter volt, elmentj�k, hogy k�s�bb tudjuk

go1:
	gotoxy 15,7 ;kurzor mozgat�sa a 8. sor 16. oszlop�ra
	printstring torles ;let�r�lni, ami ott van
	
	cmp szemaforspec,1 ;volt spec. karakter?
	jne go3 ;ha nem, tov�bb
	printstring spec ;ha igen, ki�rjunk egy jelet, hogy  speci�lis kar., itt. egy 0+ -t
	
go3:
	xor ah,ah ;ah null�z�sa
	mov al,kar ;al-ba bevissz�k a kar-t
	call binascii ;ki�rjuk

	gotoxy 15,8 ;most ugyanez, csak hexa-ban
	printstring torles

	cmp szemaforspec,1
	jne go4
	printstring spec
	mov szemaforspec,0 ;de itt m�r null�zni kell a spec. szemafort, hogy legk�zelebb is m�k�dj�n

go4:
	xor ah,ah
	mov al,kar
	call hexascii ;csak itt hexa-ban �rjuk ki

	cmp kar,27 ;addig ism�telj�k, m�g ESC nem volt �tve
	jz go2 ;itt ez enged ki ebb�l a ciklusb�l
	jmp cik1

go2:
	printstring newline ;�runk egy �jsort, csak, hogy sz�p  legyen
	
	mov ah,1 ;a kurzort az�rt l�that�v� tessz�k
	mov cx,1f0eh
	int 10h

	mov ah,4ch ;a vez�rl�s vissza az op.-nek
	int 21h

code ends ;code szegmens v�ge
	end start ;start cimke a program bel�p�si pontja