;Program 30

;�rjon programot, amely meg�llap�tja az aktu�lis d�tumot, hozz�ad egy napot, �s lecser�li az aktu�lis d�tumot erre az �jra. Ki�rja a r�gi �s az �j d�tumokat is.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s
	
;v�ltoz�k
text1 db 'Aktualis datum: $'
text2 db 13,10,'Uj datum: $'
text3 db 13,10,'Nyomj le barmilyen billentyut a kilepeshez...$'
hibauz1 db 13,10,'A datum megvaltoztatasa sikertelen!$'
ev dw ? ;ide mentj�k az �vet
ho db ? ;h�napot
nap db ? ;napot :D

;macro string ki�r�s�ra
pstring macro string
	mov ah,9
	mov dx,offset string
	int 21h
	endm ;macro v�ge

;macro egy kar. ki�r�s�ra
putchar macro kar
	mov ah,2
	mov dl,kar
	int 21h
	endm

;macro a d�tum megv�ltoztat�s�ra
change_datum macro
	mov ah,2bh
	mov cx,ev ;az �j d�tum az ev, ho, nap nev� v�ltoz�kban
	mov dh,ho ;vannak, ezeket v�ltoztatjuk meg
	mov dl,nap
	int 21h
	endm

;macro a d�tum ki�r�s�ra
print_datum macro
	mov ax,ev
	call binascii ;a binascii �rja ki nek�nk
	putchar '.' ;tesz�nk egy .-ot
	xor ah,ah ;ah-t null�zzuk, mert a binascii az ax-et �rja  ki, mi csak az al-be rakunk sz�mot, az ah-t ez�rt null�zni  kell
	mov al,ho
	call binascii
	putchar '.'
	xor ah,ah ;ez ugyanaz mint el�bb, csak a nap-ot �rjuk ki 
	mov al,nap
	call binascii
	endm
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
	
;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	mov ah,2ah ;d�tum lek�r�sse
	int 21h
	mov ev,cx ;cx-ben az �vet
	mov ho,dh ;dh-ban a h�napot 
	mov nap,dl ;dl-ben pedig a napot kapjuk vissza
	
	pstring text1 ;ki�rjuk a text1-et
	print_datum ;ki�rjuk a d�tumot is
	
	inc nap ;nap eggyel nagyobb legyen!
	change_datum ;megpr�b�ljuk megv�ltoztatni a d�tumot
	or al,al ;aktualiz�ljuk a jelz�biteket
	jz oke ;ha a d�tum megv�ltozott, akkor al=0, jz ugorni fog
	
	mov nap,1 ;ha nem j�, akkor h� v�g�n vagyunk, ugrunk k�v. h� elej�re 
	inc ho
	change_datum ;megv�ltoztatjuk a d�tumont
	or al,al ;ugyan�gy mint el�bb, ha siker�l akkor ugrunk
	jz oke
	
	mov ho,1 ;ha nem, akkor az azt jelenti, hogy �v v�ge
	inc ev ;minden egyesbe, �v eggyel n�velj�k
	change_datum ;megv�ltoztatjuk a d�tumot
	or al,al
	jz oke ;ha ez sem j�n be, akkor valami m�s hiba van, ki�rjuk, hogy nem siker�lt
	
	pstring hibauz1
	jmp vege ;�s ugrunk a v�g�re
	
oke:
	pstring text2 ;ki�rjuk az �j d�tumot
	print_datum
	
	pstring text3
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy karakterre, echo n�lk�l
	int 21h

vege:
	mov ah,4ch ;a vez�rl�s visszaad�sa az op.-nek
	int 21h
	
code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk