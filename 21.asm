;Program 21

;�rjon programot, amely a billenty�zetr�l karaktereket olvas be, �s megjelen�ti �ket a k�perny�n. A program az end sz� be�r�s�val �r v�get, de ez a sz� m�r nem jelenik meg a k�perny�n.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

long EQU 3 ;long sz� jelentse azt, hogy 3, a ford�t� minden  long sz� hely�re 3-at fog �rni, az kil�p� sz� hossz�t jel�li

;v�ltoz�k
escape db 'end' ;erre a karakterl�ncra fogunk kil�pni
text db 'Karakterek elolvasasa a bill.-rol az end szo beirasaig.',13,10,36 ;36 = �$�
kar db ?
torleskar db 8,32,8,36
newline db 13,10,36

;egy macro a k�perny�n l�v� karakterek t�rl�s�re
;a hanyszor jel�li, hogy h�ny karaktert fog let�r�lni
;ez az egyetlen param�tere
torles macro hanyszor
local cikm1 ;lok�lis cimke

	push cx ;elmentj�k a cx-et
	mov cx,hanyszor ;a cx lesz a ciklusv�ltoz�nk
	
cikm1:	
	mov ah,9 ;ki�rjuk a torleskar-t, ezzel t�rl�nk egy  karaktert, l�sd torleskar fel�p�t�se, 8-as ASCII karakter
	mov dx,offset torleskar
	int 21h
	loop cikm1 ;addig ism�telj�k, ameddig a cx nulla nem lesz
;azaz annyiszor amennyit a hanyszor-ban megadtunk
	
	pop cx ;visszatessz�k a cx tartalm�t
	endm ;v�ge a macro-nak

start:
	mov ax,cs ;be�ll�tjuk az adatszegmenst
	mov ds,ax
	mov ax,0b800h ;az es-t be�ll�tjuk a videomem�ria  kezd�c�m�re
	mov es,ax
	cld ;df=0
	
	mov ax,3 ;let�r�lj�k a k�perny�t, 80x25-�s m�dba l�p�ssel
	int 10h ;BIOS szolg�ltat�s
	
	mov ah,9 ;ki�rjuk a text1-et
	mov dx,offset text
	int 21h

;a cik1 ciklust fogjuk ism�telgetni
cik1:	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;egy karakter beolvas�sa echo n�lk�l
	int 21h 
	mov kar,al ;elmentj�k a beolvasott karaktert a kar  v�ltoz�ba

;itt megn�zz�k mi volt az elolvasott karakter
	cmp kar,13 ;ha 13 volt akkor az ENTER volt le�tve
	je go1 ;teh�t egy �j sor kell, h�t ugrunk oda, ahol ezt  tessz�k
	cmp kar,8 ;ha 8-as, akkor a BACKSPACE volt le�tve
	je go1 ;ekkor t�rl�nk egy karaktert
	cmp kar,32 ;ez 32-127 k�z�tti karakterek azok, amiket  ki�runk, a t�bbi vez�rl�karakter, ezekkel nem foglalkozunk 
	jb cik1
	cmp kar,127
	jae cik1

	mov ah,2 ;ha ide eljutunk, akkor ki�rjuk a kar-t
	mov dl,kar
	int 21h
	
	mov ah,3 ;lek�rj�k az aktu�lis kurzorpoz�ci�t
	mov bh,0 ;nulladik lapon vagyunk, ez nem olyan fontos
int 10h ;egy BIOS szolg�ltat�ssal k�rj�k le
	
;na a helyzet az, hogy mi k�zvetlen�l a videomem�ri�t fogjuk  vizsg�lni, nincs e a k�perny�n az end sz�
;ehhez viszont az aktu�lis lek�rt kurzorpoz�ci�kat �t kell  kicsit alak�tani

	shl dl,1 ;az oszlopokat meg kell szorozni kett�vel
	mov al,dh ;a sorokat meg 160-al
	mov bl,160
	mul bl ;itt csin�ljuk ezt

	mov si,ax ;az si-vel c�mezz�k a videomem�ri�t
	mov al,dl 
	xor ah,ah
	add si,ax
	
;itt m�r az si az aktu�lis poz�ci�ra mutat a videomem-ben
;azt a b�jtot c�mzi, ahol �pp villog a kurzor

	mov di,long ;egy ciklus, �sszehasonl�tjuk az utols� 3  karaktert az end sz�val
cik2:
	sub si,2 ;a videomem-ben kett�vel kell l�pkedn�nk
	dec di ;a end sz�ban eggyel
	mov al,byte ptr es:[si]
	cmp al,escape[di] ;itt hasonl�tunk egy karaktert
	jne cik1 ;ha nem egyezik vissza az elej�re
	cmp di,0 ;ha m�r di 0 akkor v�gign�zt�k az eg�szet
	jnz cik2
	
	jmp vege ;ha ide eljutunk v�ge a proginak, end volt be�rva
	
go1:
	cmp kar,13 ;ide ugrunk ha ENTER vagy BACKSPACE volt le�tve
	je go2 ;ha ENTER akkor ugrunk

	torles 1 ;ha BAKCSPACE akkor t�rl�nk egy karaktert
	jmp cik1 ;ugrunk vissza a cik1-re, hisz nincs m�g v�ge
	
go2:
	mov ah,9 ;ENTER, teh�t �j sor
	mov dx,offset newline
	int 21h
	jmp cik1 ;ugrunk vissza a cik1-re, hisz nincs m�g v�ge

vege:
	torles long ;let�rl�nk az end sz� hossz�s�g�nak megfelel�  karaktert

	mov ah,4ch ;visszaadjuk a vez�rl�st az op.-nek
	int 21h

code ends ;code szegmens v�ge
	end start ;start cimk�n�l kezd�nk