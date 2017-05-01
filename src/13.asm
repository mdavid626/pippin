;Program 13

;�rjon programot, ami kit�r�li az aktu�lis mapp�b�l az �sszes f�jlt, amely r�gebbi mint a billenty�zetr�l megadott d�tum.

code segment ;code nev� szegmens l�trehoz�sa
assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
asciiz db '*.*',0 ;4eh ill. 4fh szolg. mit keressen: az  ;aktu�lis mapp�ban az �sszes f�jlt, ut�na d�ntj�k el, hogy  ;t�r�lni kell vagy sem
text1 db 'Add meg a datumot nn-hh-ee formaban: $'
text2 db 13,10,10,'A program most kitorli az osszes allomanyt az aktualis mappabol,'
      db 13,10, 'amelyek regebbiek mint az aktualis datum!'
	   db 13,10,10,'Szeretne folytatni? y/n: $'
text3 db 13,10,10,'Hiba keletkezett, a program most befejezodik...$'
text4 db 13,10,10,'Uss le barmilyen billentyut...$'
text5 db 13,10,10,'A fajlok kitorolve!$'
text6 db 13,10,10,'Nem lett kitorolve semmilyen allomany!$'
chyba1 db 13,10,10,'Hiba lepett fel, probald meg meg egyszer!$'
buffer db 9,0,9 dup(0) ;a beolvasott d�tum t�rol�s�ra
dta db 128 dup(0) ;a dta-nak
evm db ? ;a beolvasott d�tumb�l az �v t�rol�s�ra
hom db ? ;a h�nap
napm db ? ;ill. a nap
flag db ? ;volt t�r�lve f�jl? ez mondja meg, hogy igen vagy  ;nem

;macro text ki�r�s�ra
write macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm
	
;proc. ascii ==> bin�ris �talak�t�sra
asciibin proc near ;bemenet si - mutato buffer, cl hossz
                   ;kimenet ax - bin ertek
	xor ax,ax
	cmp cl,0 ;kicsit m�dos�tottam, itt a hosszt a cl  ;tartalmazza
	ja asciibin_go1
	ret

asciibin_go1:	
	mov bx,10
	
asciibin_cik1:
	mul bx ;dx null�zva, ax szorozva bx-el
	mov dl,byte ptr[si]
	sub dl,30h ;levonunk 30h-�t, mert ASCII k�d�, �s nek�nk  ;bin�risan kell
	add ax,dx ;hozz�adjuk a dx-et az ax-hez
	inc si
	dec cl
	jnz asciibin_cik1

	ret ;visszat�r�s a f�programba
asciibin endp

;macro, a buf-ban lev� k�t drb. karaktert alak�tja sz�mm�, �s  ;elmenti a kam nev� v�ltoz�ba
prem macro buf,kam
	mov si,offset buf
	mov cl,2
	call asciibin
	mov kam,al
	endm

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	mov ah,1ah ;dta kezd�c�m�nek be�ll�t�sa
	mov dx,offset dta
	int 21h
	
	mov flag,0 ;flag null�z�sa
	
go3:
	mov ax,3 ;k�perny� let�rl�se 80x25-�s m�dba val� l�p�ssel
	int 10h
	write text1 ;text1 ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;string beolvas�sa a bill.-r�l
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	cmp buffer[1],8 ;megvan az �sszes 8 drb karaktert?
	jne go3 ;ha nincs, h�t bazmeg m�gegyszer el�lr�l
	
	cmp buffer[4],'-' ;a megadott d�tumnak megadott form�ja  ;van, k�t drb � jel van benne, ha ezek nincsenek a hely�k�n  ;akkor hib�s
	jne go3 ;�s ugyan�gy mint el�bb, vissza az elej�re
	cmp buffer[7],'-'
	jne go3
	
	prem buffer[8],evm ;�talak�tjuk a megadott stringet  ;d�tumm�, most az �vet
	cmp evm,99 ;nem lehet nagyobb mint 99, ha csak 2  ;sz�mjegyet lehet megadni, most h�vom fel a figyelmet, hogy a  ;program csak 2000 ut�ni f�jlokat k�pes t�r�lni
	ja go3
	add evm,20 ;hozz�adunk 20-at, mert a dta-ban 2008-1980=28  ;lesz, �s nem 8, teh�t � 1980-t�l sz�molja, te meg 2000-t�l  ;adtad meg
	
	prem buffer[5],hom ;�talak�tjuk a h�napokat is
	cmp hom,0 ;h�nap nem lehet nulla...
	je go3
	cmp hom,12 ;se nagyobb mint 12
	ja go3
	
	prem buffer[2],napm ;a napok �talak�t�sa
	cmp napm,0 ;nem lehet nulla
	je go3
	cmp napm,31 ;se nagyobb mint 31
	ja go3
	
	write text2 ;text2 ki�r�sa
	
go2:
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;egy karakter beolvas�sa echo n�lk�l
	int 21h
	cmp al,'y' ;ha igen, akkor ugr�s tov�bb
	je go1
	cmp al,'n' ;ha nem, h�t nem, teh�t v�ge
	jne go7
	jmp konec ;ha egyik se, �jb�l kar. bek�r�se
	
go7:	
	jmp go2 ;az�rt nem k�zvetlen�l, mert t�l messze van ahova  ;ugorni akarunk, felt�teles ugr�s m�r oda nem tud ugorni
	
go1:
	mov ah,4eh ;els� f�jl keres�se
	mov dx,offset asciiz ;minden f�jl az aktu�lis mapp�ban
	mov cx,0 ;normal f�jlokat keres�nk
	int 21h
	jc nebolsubor ;nem volt f�jl, akkor cf=1
	
cik1:
	xor ah,ah ;ah null�z�sa
	mov al,dta[19h] ;a f�jl d�tum�nak bevitele az al-be 
	shr al,1 ;eltoljuk 1-el, hogy mi�rt? l�sd dta fel�p�t�se

	cmp al,evm ;az al-ben m�r az �v van, �sszehasonl�tjuk a  ;mi �v�nkkel
	jb vym ;ha kisebb, akkor lehet t�r�lni
	cmp al,evm ;ha nagyobb akkor nem
	ja go5
	
;ha egyenl� akkor vagy igen, vagy nem.. megy�nk tov�bb
	mov ax,word ptr dta[18h] ;most a h�nap j�n
	mov cl,5 ;5-el fogunk shiftelni
	shr ax,cl ;shiftel�nk
	and al,0fh ;�s itt and-el�nk is, mert ki kell l�ni az al  ;fels� n�gy bitj�t, l�sd dta fel�p�t�se, d�tum r�sz
	
	cmp al,hom ;ugyanaz mint el�bb, csak most a h�nappal
	jb vym
	cmp al,hom
	ja go5
	
	xor ah,ah ;ah null�z�sa
	mov al,dta[18h] ;most ez a b�jt kell a dta-b�l 
	and al,1fh ;fels� 3 bit kil�v�se
	
	cmp al,napm ;ha kisebb a nap, csak akkor lehet t�r�lni
	jb vym
	jmp go5
	
vym:
	mov ah,41h ;itt t�rl�nk
	mov dx,offset dta[1eh] ;a f�jln�v innen kezd�dik
	int 21h
	jc chyba ;ha nem siker�lt hiba
	mov flag,1 ;m�r volt t�r�lt f�jl
	
go5:
	mov ah,4fh ;k�v. f�jl keres�se
	mov dx,offset asciiz
	mov cx,0 ;normal f�jl
	int 21h
	jc vymkonec ;ha nincs t�bb f�jl, akkor v�ge
	jmp cik1 ;m�sk�l�nben vissza az elej�re
	
vymkonec:
	cmp flag,1 ;ha v�ge, akkor megk�rdi: volt kit�r�lt f�jl?
	jne nebolsubor ;ha nem, akkor ki�rja hogy nem
	
	write text5 ;ha igen, akkor hogy igen
	jmp konec ;�s v�ge
	
nebolsubor:
	write text6 ;nem volt t�r�lve f�jl
	jmp konec ;�s v�ge
	
chyba:
	write chyba1 ;ha valami hiba t�rt�nt, akkor ezt �rja ki
	
konec:
	write text4 ;�s v�ge

	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;egy kar.-ra v�r�s echo n�lk�l
	int 21h
	
	mov ah,4ch ;a vez�rl�s visszaad�sa az op.-nek
	int 21h
	
code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk