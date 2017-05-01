;Program 26

;�rjon programot, amely elk�sz�ti k�t f�jl "�sszeg�t". A k�t forr�sf�jl ill. a c�lf�jl nev�t k�rje be a billenty�zetr�l.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
filename db 65,0,65 dup(0) ;f�jln�v elment�s�re
kar db ? ;ebbe olvasunk a f�jlb�l, ebb�l �runk f�jlba
text1 db '1. fajl: $'
text2 db 13,10,'2. fajl: $'
text3 db 13,10,'Celfajl: $'
text4 db 13,10,'A masolas kesz!$'
text5 db 13,10,'Press any key...$'
hibauz1 db 13,10,'Nem talalom az utat$' ;hiba�zenetek
hibauz2 db 13,10,'Hozzaferes megtagadva!$'
hibauz3 db 13,10,'A fajl nem letezik!$'
hibauz4 db 13,10,'Szamomra ismeretlen hiba$$'
hibauz5 db 13,10,'A celf�jl mar letezik!$'
file1 dw ? ;a FILE HANDLE  sz�mok elment�s�re
file2 dw ?
file3 dw ?
szemafor1 db 0 ;volt megnyitott f�jl? evvel jelezz�k
szemafor2 db 0
szemafor3 db 0
letezik db 0 ;hehe, ez annak az indik�l�sa, hogy van f�jl, de  ez nek�nk nem j�, teh�t ha NINCS az a j�, de akkor a hiba-ra  ugortunk m�r, megn�zz�k letezik=1, ha igen, akkor nek�nk  vissza kell menni, �s tov�bb kell folytatni a programot

;macro string ki�r�s�ra
pstring macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm
	
;f�jl lez�r�sa
lezar macro file,szemafor
local vege
	cmp szemafor,0 ;ha szemafor=1, akkor le kell z�rni
	je vege
	mov ah,3eh
	mov bx,file
	int 21h
vege:
	endm
	
;macro string beolvas�s�ra
beolvas macro buffer
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah
	mov dx,offset buffer
	int 21h
	
	xor bh,bh
	mov bl,buffer[1] ;hova is?
	mov buffer[bx+2],0 ;a v�g�re kell egy 0
	endm
	
;macro f�jl megnyit�s�ra
megnyit macro file,szemafor
local ok
	mov ah,3dh
	xor al,al ;olvas�sra
	mov dx,offset filename[2] ;a filename 3. b�jtj�t�l  kezd�dika  f�jln�v
	int 21h
	jnc ok
	jmp hiba ;ez az�rt �gy mert ide m�r near jump kell, shor  nem el�g, t�l messze van
	
ok:
	mov file,ax ;FILE HANDLE elment�se
	mov szemafor,1 ;szem. egyesbe
	endm
	
;olvas�s f�jlb�l a kar-ba
olvasfajlbol macro file
	mov ah,3fh
	mov bx,file
	mov cx,1 ;egy b�jt
	mov dx,offset kar ;a kar-ba
	int 21h
	jc hiba
	endm

;�r�s f�jlba egy kar-t
irasfajlba macro file
	mov ah,40h
	mov bx,file
	mov cx,1 ;egy b�jtot
	mov dx,offset kar
	int 21h
	jc hiba ;ha hiba ugrunk
	endm

;f�jl l�trehoz�sa, nev�t a filename adja, mint eddig is :D
letrehozas macro file,szemafor
	mov ah,3ch ;l�trehoz�s
	xor cx,cx ;normal f�jl
	mov dx,offset filename[2]
	int 21h
	jc hiba
	mov file,ax ;FILE HANDLE elment�se
	mov szemafor,1 ;bla-bla-bla, mint el�bb
	endm
	
;text ki�r, �s v�r egy karakterre
_wait macro text
	mov ah,9
	mov dx,offset text
	int 21h

	mov ah,0ch
	mov al,7
	int 21h
	endm
	
;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df=0

	pstring text1 ;text1 ki�r�sa
	beolvas filename ;f�jln�v beolvas�sa
	megnyit file1,szemafor1 ;f�jl megnyit�sa
	
	pstring text2 ;ugyanaz, csak m�sik f�jl
	beolvas filename
	megnyit file2,szemafor2
	
	pstring text3 ;c�lf�jl
	beolvas filename
	mov letezik,1 ;hehe, ha l�tezik az nek�nk nem J�, ez�rt ha  hiba lett, akkor visszaj�v�nk, ha nem akkor ki�rjuk, hogy  hiba �s v�ge
	megnyit file3,szemafor3
	
	pstring hibauz5
	jmp vege ;mondom, V�GE
	
letrehoz:
	letrehozas file3,szemafor3 ;c�lf�jl l�trehoz�sa
	
elsofajl:	
	olvasfajlbol file1 ;olvasunk els� f�jlb�l m�g v�ge nem  lesz
	cmp ax,0
	jz masikfajl
	
	irasfajlba file3 ;�s �runk a c�lf�jlba
	jmp elsofajl
	
masikfajl:
	olvasfajlbol file2 ;ugyanaz, csak a m�sik f�jlb�l olvasunk
	cmp ax,0
	jz vegeazirasnak
	
	irasfajlba file3
	jmp masikfajl

vegeazirasnak:
	pstring text4 ;ki�rjuk a v�gs� sz�veget, hogy minden ok
	jmp vege ;�tugorjuk a hiba�ziket

hiba:
	cmp letezik,1 ;ha letezik=1 akkor vissza kell menni ha  hiba lett
	je letrehoz ;teh�t VISSZA
	cmp ax,3 ;hib�k lekezel�se a hibak�d alapj�n
	je hiba1
	cmp ax,5
	je hiba2
	cmp ax,2
	je hiba3
	
	pstring hibauz4 ;ha egyik se, akkor ismeretlen
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
	_wait text5 ;v�rj
	
	lezar file1,szemafor1 ;z�rd le a f�jlokat
	lezar file2,szemafor2
	lezar file3,szemafor3
	
	mov ah,4ch ;add vissza a vez�rl�st
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk