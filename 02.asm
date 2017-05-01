;Program 02

;�rjon programot a kocka fel�let�nek kisz�m�t�s�ra. A kocka oldal�t k�rje be a billenty�zetr�l, az ererdm�nyt jelent�tse meg a sz�m�t�g�p monitor�n. Az eredm�ny f�rjen bele 2 b�jtba.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;EQU direkt�va, a max sz� jelentse azt, hogy 104, a ford�t�  minden max sz� hely�re ezt fogja tenni
max EQU 104

;v�ltoz�k	
text1 db 'A kocka felszinenek kiszamitasa'
      db 13,10,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~$'
text2 db 13,10,'Add meg az oldalat (max. 104): $'
text3 db 13,10,'A kocka felszine: $'
text4 db 13,10,'Nyomj le barmilyen billentyut a kilepeshez...$'
hibauz db 13,10,'Max. 104!$'
eredmeny dw ? ;ide mentj�k az eredm�nyt
buffer db 4,0,4 dup(0) ;ide olvassuk be a sz�mot

;macro string ki�r�s�ra
textkiir macro text
	mov ah,9 ;9-es DOS szolg�ltat�s
	mov dx,offset text ;dx-be a ki�rand� string offsetc�me
	int 21h
	endm ;macro v�ge

;proc. ASCII k�d� karakterek bin�ris sz�mm� val� alak�t�s�ra
asciibin proc near ;bemenet si - mutato buffer+1
                   ;kimenet ax - bin ertek
	mov cl,byte ptr[si] ;elmentj�k cl-be a beolvasott kar. sz�m�t
	xor ax,ax ;ax-et null�zzuk
	cmp cl,0 ;volt beolvasott karakter?
	ja asciibin_go1 ;ha igen, akkor megy�nk �tsz�molni
	ret ;ha nem visszat�r�nk egy null�val az ax-ben

asciibin_go1:	
	mov bx,10 ;10-el fogunk szorozni
	
asciibin_cik1:
	mul bx ;dx null�zva
	inc si ;si n�vel�se eggyel
	mov dl,byte ptr[si] ;bevissz�k a sz�mjegyet
	sub dl,30h ;hogy sz�m legyen, ASCII k�d� most m�g!
	add ax,dx ;a sz�munkhoz hozz�adjuk
	dec cl ;cl dekrement�l�sa
	jnz asciibin_cik1 ;addig m�g a cl 0 nem lesz

	ret ;visszat�r�nk a f�programba
asciibin endp ;proc. v�ge

;proc. ami ki�rja az ax-ben megadott sz�mot a k�perny�re
binascii proc near ;bemenet ax
	jmp binascii_start ;�tugorjuk a v�ltoz�t
	
flag db ? ;volt m�r ki�rt sz�mjegy? ezt mondja meg

binascii_start:
	mov flag,0 ;flag=0 ? m�g nem volt ki�rt sz�mjegy
	cmp ax,0 ;ax=0?
	jne binascii_go1 ;ha nem, akkor tov�bb
	mov ah,2 ;ha igen, akkor ki�runk egy null�t
	mov dl,'0'
	int 21h
	ret ;�s visszat�r�nk

binascii_go1:	
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;oszt�s ? dx-et null�zni kell! l�sd f�zet DIV  utas�t�s
	
binascii_cik1:	
	div bx ;ax-et osztjuk bx-el
	mov si,dx ;marad�kot dx-ben kapjuk vissza, elmentj�k si-be
	cmp ax,0 ;ax=0?
	jne binascii_go2 ;ha nem akkor tov�bb
	cmp flag,0 ;ha igen, akkor flag=0?
	je binascii_go3 ;ha igen, akkor m�g nem volt ki�rt  sz�mjegy, ez�rt a kapott null�t nem �rjuk ki

binascii_go2:	
	mov ah,2 ;ha ide eljutunk, ki�rjuk a sz�mjegyet
	mov dl,al
	add dl,30h ;el�bb hozz�adunk 30h-t, ASCII!
	int 21h
	mov flag,1 ;�s flag=1, mert m�r van ki�rt sz�mjegy

binascii_go3:	
	mov ax,bx ;bx-et osztani kell 10-el
	mov bx,10 ;10-el
	xor dx,dx ;dx-et null�zni
	div bx ;kinull�zza a dx-et
	cmp ax,1 ;ax=1?
	jb binascii_vege ;ha kisebb mint egy akkor v�ge
	mov bx,ax ;ha nem, akkor bx vissza oszt�nak
	mov ax,si ;ax-be meg az el�bbi marad�k
	jmp binascii_cik1 ;�s vissza a ciklus elej�re

binascii_vege:
	ret ;visszat�r�s a f�programba
binascii endp ;proc. v�ge

start:
	mov ax,cs ;adatszegmens be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa

	mov ax,3 ;k�perny� t�rl�se, 80x25-�s m�dba val� l�p�ssel
	int 10h
	
	textkiir text1 ;text1 ki�r�sa
	
cik1:	
	textkiir text2 ;text2 ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;string beolvas�sa
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	xor bx,bx ;bx null�z�sa, evvel c�mz�nk
	
cik2:
	cmp buffer[bx+2],30h ;megn�zz�k a beolvasott t�mb minden  egyes elem�t, hogy sz�m volt-e: 30h �s 39h k�z�tti ASCII k�d�  karakternek kell lenni, ezek a sz�mok ASCII k�djai
	jb go1 ;ha kisebb volt, hiba
	cmp buffer[bx+2],39h 
	ja go1 ;ha meg nagyobb, az is hiba
	inc bl ;az �sszes elemet v�gign�zz�k
	cmp bl,buffer[1] ;addig m�g a bl el nem �ri a beolvasott kar. sz�m�t
	jb cik2 ;jobban mondva, nagyobb vagy egyenl� nem lesz  n�la, 0-val kezdj�k az indexel�st!
	
	mov si,offset buffer+1 ;�talak�tjuk a karaktereket sz�mm� 
	call asciibin ;itt csin�ljuk
	
	cmp ax,max ;ax-ben kaptuk vissza a sz�mot
	ja go1 ;megn�zz�k nem nagyobb-e mint, ami lehet
	cmp al,0 ;nulla se lehet 
	je go1 ;ekkor is hiba
	cmp buffer[1],0 ;ha meg nem �t�tt m�st a user csak egy  ENTERT, azt is lekezelj�k, mint hiba
	je go1
	jmp go2 ;tov�bb, mert itt akkor nincs hiba 
	
go1:
	textkiir hibauz ;hiba�zenet ki�r�sa
	jmp cik1 ;�j sz�m bek�r�se

go2:
	mov bx,ax ;bx-be ax-et
	mul bl ;ax szorz�sa bx-el ? ax-ben a kocka oldala ?  szorozva �nmag�val, ez az a2, ezt m�g szorozzuk 6-al, �s meg  is van a felsz�ne

	mov bx,6 ;6-al
	mul bx ;ax �s kiterjeszt�se a dx szorz�sa a bx-el
	mov eredmeny,ax ;eredm�ny elment�se
	
	textkiir text3 ;text3 ki�r�sa
	
	mov ax,eredmeny ;eredm�ny vissza az ax-be
	call binascii ;ki�r�sa
	
	textkiir text4 ;text4 ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy karakterre echo n�lk�l
	int 21h
	
	mov ah,4ch ;a vez�rl�s visszaad�sa az op.-nek
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk