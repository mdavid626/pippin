;Program 08

;�rjon programot, amely a beadott �rt�kek halmaz�b�l kiv�lasztja a p�ros sz�mokat, megjelen�ti �ket, �s megjelen�ti a mennyis�g�ket is. Jelent�tse meg a beadott halmazt, amely 10 maxim�lisan k�tjegy� eg�sz sz�mokb�l tartalmaz.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;a hossz sz� jelentse azt, hogy 10
hossz=10 ;�rhattuk volna azt is, hogy hossz EQU 10

;v�ltoz�k
szoveg1 db 'A megadott szamokbol a parosak kiirasa',13,10,36
szoveg2 db 13,10,'Adj meg $'
szoveg3 db ' szamot!',13,10,36
szoveg4 db '. szam: $'
szoveg5 db 13,10,'A beadott szamsor:',13,10,36
szoveg6 db 13,10,'Ebbol a paros szamok:',13,10,36
szoveg7 db 13,10,'A paros szamok szama: $'
szoveg8 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
ujsor db 13,10,36 ;�jsor �r�s�ra 36=�$�
buffer_szamok db hossz dup(0) ;buffer a beolvasott sz�moknak
hibauz db 13,10,'Max. 99!$' ;hiba�zi
buffer db 3,0,3 dup(0) ;a beolvasott kar. t�rol�s�ra
paros dw 0 ;a p�ros sz�mok megsz�mol�s�ra 
i dw ? ;a t�mb indexel�s�re
	
;macro string ki�r�s�ra
kiir macro szoveg
	mov ah,9
	mov dx,offset szoveg
	int 21h
	endm ;macro v�ge

;macro egy karakter ki�r�s�ra
putchar macro char
	mov ah,2
	mov dl,char
	int 21h
	endm

;macro sz�m ki�r�s�ra
wnum macro param
	mov ax,param
	call binascii
	endm

;macro ASCII k�d� sz�m bin�riss� alak�t�s�ra
num macro param
	mov si,offset param
	call asciibin
	endm

;macro a sz�msor ki�r�s�ra
wszamsor macro param
	mov di,offset param
	call kiirszamsor
	endm

;macro a p�ros sz�mok ki�r�s�ra
wparos macro param
	mov di,offset param
	call kiirparos
	endm

;macro a k�perny� t�rl�s�re
clrscr macro
	mov ax,3 ;80x25-�s m�d be�ll�t�sa, ezzel a k�p. t�rl�se
	int 10h
	endm

;proc. bin�ris sz�m ASCII k�dban val� ki�r�s�ra
binascii proc near ;bemenet ax
	jmp binascii_start ;�tugorjuk a v�ltoz�t
	
flag db ?

binascii_start:
	mov flag,0
	cmp ax,0 ;ax=0?
	jne binascii_go1 ;ha nem akkor megy�nk tov�bb
	putchar '0' ;ha igen, akkor kirakunk egy null�t
	jmp binascii_vege ;�s megy�nk a v�g�re

binascii_go1:	
	mov bx,10000 ;10000-rel fogunk osztani
	xor dx,dx ;az oszt�s el�tt null�zni kell a dx-et
	
binascii_cik1:	
	div bx ;osztjuk az ax-et bx-el
	mov si,dx ;a marad�k az si-be
	cmp ax,0 ;ax=0?
	jne binascii_go2 ;ha nem akkor binascii_go2-re
	cmp flag,0 ;ha igen, akkor flag=0?
	je binascii_go3 ;ha igen, ugrunk a binascii_go3-ra

binascii_go2:	
	add al,30h ;al-hez adjunk hozz� 30h, ASCII!
	putchar al ;kitessz�k a k�perny�re
	mov flag,1 ;m�r itt biztos volt ki�rva karakter, ez�rt  szemafor egyesbe

binascii_go3:
	mov ax,bx ;az oszt�t osztani kell 10-el
	mov bx,10 ;10-el
	xor dx,dx ;dx null�z�sa, mint fent
	div bx ;kinullazza a dx-et, osztjuk az ax-et
	cmp ax,1 ;megn�zz�k ax=1?
	jb binascii_vege ;ha kisebb mint 1, akkor v�ge
	mov bx,ax ;ha nem, bx-be vissza az oszt�t
	mov ax,si ;ax-be vissza a marad�kot
	jmp binascii_cik1 ;vissza az elej�re

binascii_vege:
	ret ;visszat�r�nk a f�programba
binascii endp ;proc. v�ge

;ASCII karaktereket alak�t sz�mm�
asciibin proc near ;bemenet si - mutato buffer+1
                   ;kimenet ax - bin ertek
	mov cl,byte ptr[si] ;bevissz�k a cl-be a beolvasott  karakterek sz�m�t
	xor ax,ax ;ax-et null�zzuk
	cmp cl,0 ;megn�zz�k volt-e beolvasott karakter
	ja asciibin_go1 ;ha igen, akkor tov�bb
	jmp asciibin_vege ;ha nem akkor v�ge

asciibin_go1:	
	mov bx,10 ;10-el fogunk szorozni
	
asciibin_cik1:	
	mul bx ;dx null�zva, szorozzuk az ax-et bx-el
	inc si ;si k�v. elemre mutasson
	mov dl,byte ptr[si] ;bevissz�k dl-be a karaktert
	sub dl,30h ;levonunk bel�le 30h, l�sd ASCII!
	add ax,dx ;hozz�adjuk az ax-hez a sz�mjegyet
	dec cl ;cl-1
	jnz asciibin_cik1 ;addig m�g cl!=0 vissza az elej�re
	
asciibin_vege:
	ret ;visszat�r�s a f�programba
asciibin endp ;proc. v�ge

;proc. a sz�msor ki�r�s�ra
kiirszamsor proc near ;bemenet di - mutato a kiirando tombre, hossz a tomb hossza
	mov cl,hossz
	
kiirszamsor_cik1:
	xor ah,ah ;ah null�z�sa
	mov al,byte ptr[di] ;al-be bevissz�k a sz�mot
	wnum ax ;ki�rjuk
	putchar ',' ;ki�runk egy vessz�t is
	inc di ;k�v. i
	dec cl ;cl-1
	jnz kiirszamsor_cik1 ;addig m�g cl nem nulla
	
	putchar 8 ;eggyel vissza
	putchar 32 ;ki�r egy sz�k�zt, teh�t utols� kar. t�r�lve, mit jelent ez? mi�rt is kellett? az�rt, mert az utols� sz�m  ut�n is tett�nk vessz�t, ezt kell elt�ntetni
	ret ;visszat�r�s a f�programba
kiirszamsor endp ;proc. v�gge

;proc. a p�ros sz�mok ki�r�s�ra 
kiirparos proc near ;bemenet di - mutato a kiirando tombre, hossz a tomb hossza
	mov paros,0
	mov cl,hossz
	
kiirparos_cik1:
	xor ah,ah
	mov al,byte ptr[di]
	
	test al,1 ;ugyanaz mint el�bb, csak itt meg kell n�zni, hogy a sz�m p�ros-e vagy sem, �s aszerint ki�rni, ezt v�gzi a  test al,1, teh�t megn�zi, hogy a sz�m legals� bitje 1-es-e, ha igen akkor p�ratlan, ha nem akkor p�ros, jnz az�rt, mert  ha 1- es akkor zf=0, ekkor elugrunk..
	jnz kiirparos_go1
	wnum ax ;ki�rjuk
	putchar ','
	inc paros ;itt meg megsz�moljuk
	
kiirparos_go1:	
	inc di
	dec cl
	jnz kiirparos_cik1
	
	putchar 8
	putchar 32
	ret
kiirparos endp
	
;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	
	clrscr ;k�perny� t�rl�se
	
	kiir szoveg1 ;szoveg1 ki�r�sa
	kiir szoveg2
	wnum hossz ;ki�rja, hogy mennyi sz�mot kell beadni 
	kiir szoveg3
	
	mov i,1 ;i=1
	
cik1:
	kiir ujsor ;�j sort �r
	wnum i ;ki�rja hanyadik sz�mot adjuk �pp meg
	kiir szoveg4
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;string beolvas�sa
	mov dx,offset buffer ;ide kell menteni a beolvasott  kar.-eket 
	int 21h
	
	xor bx,bx ;bx null�z�sa, ezzel fogunk c�mezni
	
cik3:
	cmp buffer[bx+2],30h ;meg kell n�zni, hogy amit  be�rtak sz�m-e
	jb go1
	cmp buffer[bx+2],39h ;a sz�mok az ASCII-ban a 30h-39h- s tartom�nyban vannak
	ja go1
	inc bl
	cmp bl,buffer[1] ;ha nem �t�tt le semmit, az is hiba
	jb cik3
	jmp go2

go1:
	kiir hibauz ;itt �rjuk ki a hiba�zit
	jmp cik1

go2:
	num buffer+1 ;most m�r j�, �talak�tjuk sz�mm�
	
	mov si,i ;�s elmentj�k a buffer-ba
	mov buffer_szamok[si-1],al

	inc i ;ha m�g nincs el�g sz�munk, akkor olvasunk be
	cmp i,hossz
	jbe cik1
	
	clrscr ;let�r�lj�k a k�perny�t
	kiir szoveg1
	
	kiir szoveg5
	wszamsor buffer_szamok ;ki�rjuk a beolvasott sz�mokat
	
	kiir szoveg6
	wparos buffer_szamok ;most csak a p�ros sz�mokat �rjuk ki
	
	kiir szoveg7
	wnum paros ;ki�rjuk mennyi p�ros sz�m volt
	
	kiir szoveg8 ;ki�rjuk a szoveg8-at
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy karakterre echo n�lk�l
	int 21h
	
	mov ah,4ch ;vez�rl�s visszaad�sa az op.-nek
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk