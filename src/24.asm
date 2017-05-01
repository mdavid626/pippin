;Program 24

;�rjon programot, amely megsz�molja az aktu�lis k�nyvt�rban lev� f�jlokat, az eredm�nyt pedig ki�rja a k�perny�re.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
dta db 128 dup(0)
asciiz db '*.*',0
text1 db 'Az aktualis mappaban $'
text2 db ' fajl talalhato.$'
hibauz1 db 13,10,'Nem talalhato fajl!$'
szemaforbin db ?
szam dw 0 ;ide mentj�k a f�jlok sz�m�t

;evvel a proced�r�val �rjunk ki egy bin�ris sz�mot a  k�perny�re, ebben a programban a szam nev� v�ltoz�t
;ezt a proced�r�t sz�ccsel �r�n vett�k...

binascii proc near ;bemenet ax
	mov szemaforbin,0 ;szemafort null�ba �ll�tjuk
	cmp ax,0 ;megn�zz�k, hogy a ki�rand� sz�m nem nulla e
	jne gop1 ;ha nem tov�bbmegy�nk
	mov ah,2 ;ha igen akkor ki�runk egy null�t
	mov dl,'0'
	int 21h
	jmp vegeproc ;�s a proc. v�g�re ugrunk

gop1:
	mov bx,10000 ;10000 fogunk osztani
	xor dx,dx ;osztani fogunk, fontos a dx-et kinull�zni, l�st  div utas�t�s

cikp1:
	div bx ;itt osztjuk az ax-et �s a kiterjeszt�s�t a dx-et a  bx-ben lev� sz�mmal
	mov si,dx ;�tvissz�k a dx-et az si-be, a dx-ben van a  marad�k
	cmp ax,0 ;megn�zz�k ax-ben nulla van e
	jne gop2 ;ha nem akkor ki�rjuk
	cmp szemaforbin,0 ;ha igen, �s a szemafor 0 akkor nem  �rjuk ki
	je gop3

gop2:
	mov ah,2 ;itt �rjuk ki az ax-ben oszt�s ut�n megkapott  sz�mot
	mov dl,al
	add dl,30h ;hozz�adunk 30h-t, mert ASCII karakterk�nt  �rjuk ki
	int 21h
	mov szemaforbin,1 ;m�r itt egy karaktert biztos ki�rtunk, ez�rt szemafort egyesbe �ll�tjuk

gop3:
	mov ax,bx ;az oszt�t el kell osztani 10-zel
	mov bx,10 
	xor dx,dx 
	div bx ;itt osztjuk
	cmp ax,1 ;megn�zz�k, hogy az oszt� egy e m�r
	jb vegeproc ;ha kisebb mint egy akkor v�ge
	mov bx,ax ;ha nem, akkor bx-be bevissz�k az oszt�t
	mov ax,si ;ax-be vissza az el�z� marad�kot
	jmp cikp1 ;�s el�lr�l az eg�szet

vegeproc: 
	ret

binascii endp

start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	mov ah,1ah ;dta kezd�c�m�nek be�llit�sa
;ez a 4eh ill. 4fh szolg�ltat�soknak kell, most igaz�b�l k�l�n�sebb szerepe nincs
	mov dx,offset dta
	int 21h

	mov ah,4eh ;itt lek�rj�k (keress�k) az els� f�jlt
	mov dx,offset asciiz ;az aktu�lis mapp�t figyelj�k
	mov cx,0 ;normal f�jlokat
	int 21h
	jc hiba ;ha nem tal�ltunk f�jlt, ki�rjuk, hogy nincs f�jl

cik1:	
	inc szam ;megn�velj�k a f�jlokat sz�ml�l� v�ltoz� �rt�k�t  eggyel, mivel ha m�r itt vagyunk, akkor 1 f�jl biztosan van
	mov ah,4fh ;itt kezdj�k lek�rni a tov�bbi f�jlokat
	int 21h
	jnc cik1 ;addig fogjuk ezt ism�telni, ameddig tal�l f�jlt

	mov ah,9 ;ok�, nincs t�bb f�jl, most ki�rjuk, hogy mennyi  is volt
	mov dx,offset text1 ;el�sz�r a sz�veg els� fele
	int 21h

	mov ax,szam ;itt fogjuk ��tcsin�lni� a szam-ot ASCII-v�, azaz ki�rjuk a k�perny�re
	call binascii ;ez a proced�ra v�gzi ezt, az ax-ben kapja  meg a ki�rand� f�jlt
	
	mov ah,9 ;itt meg ki�rjuk a sz�veg tov�bbi r�sz�t
	mov dx,offset text2
	int 21h

	jmp vege ;�tugorjuk a hiba�zenetet

hiba:	
	mov ah,9 ;itt �rjuk ki, hogy nincs f�jl
	mov dx,offset hibauz1
	int 21h
	
vege:
	mov ah,4ch ;visszaadjuk a vez�rl�st az op.-nek
	int 21h

code ends ;code nev� szegmens lez�r�sa
	end start ;start cimk�nel fogunk bel�pni a programba