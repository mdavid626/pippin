;Program 11

;�rjon programot sz�veges �llom�ny l�trehoz�s�ra a lemezen, �s a megt�lt�s�re a bill. beadott karakterekkel. A tev�kenys�g befejez� karakter�nek az ESC bill. v�lassza. Megjegyz�s: a vez�rl� billenty�ket, nyilakat �s a Backspace bill. ignor�lja!

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s
	
;v�ltoz�k
text1 db 'Add meg a kivant fajlnevet: $'
text2 db 13,10,'Nyomj le egy billentyut a folytatashoz...$'
text3 db 13,10,'A szoveg sikeresen elmentve a(z) $'
text4 db ' allomanyba!$' 
hibauz1 db 13,10,'Nem talalom az utat!$'
hibauz2 db 13,10,'Nincs engedelyezve a hozzaferes!$'
hibauz3 db 13,10,'Ismeretlen hiba!$'
hibauz4 db 13,10,'Nem tudom letrehozni a fajlt! (Lehet, hogy mar letezik?)$'
file dw ? ;FILE HANDLE sz�m elt�rol�s�ra
szemaforfile db 0 ;volt-e megnyitott f�jl
buffer_key db 65,0,65 dup(0) ;ide mentj�k a beolvasott  f�jlnevet
ir db ? ;ide mentj�k a beolvasott karaktert

;macro string ki�r�s�ra
ps macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm ;macro v�ge

;macro egy karakter olvas�s�ra echo n�lk�l
olvas macro
	mov ah,0ch
	mov al,7
	int 21h
	endm

;macro a k�perny� t�rl�s�re
clrscr macro
	mov ax,3 ;v�ltunk 80x25-�s m�dba, evvel t�r�lj�k a k�p.
	int 10h
	endm

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df nullaz�sa
	
	clrscr ;k�perny� t�rl�se
	ps text1 ;text1 ki�r�sa
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;f�jln�v beolvas�sa
	mov dx,offset buffer_key ;ide olvasunk
	int 21h ;csin�ld!
	
	xor bh,bh ;bh null�z�sa, az�rt, mert a bx-et fogjuk  haszn�lni, de nem fogunk �rni a bh-ba 
	mov bl,buffer_key[1] ;bl-be a beolvasott karakterek sz�ma
	mov buffer_key[bx+2],0 ;ez alapj�n a string v�g�re egy  null�t
	
	mov ah,3dh ;a f�jl megnyit�sa, az�rt, hogy ne �rjuk fel�l
	xor al,al ;normal file, al=0
	mov dx,offset buffer_key[2] ;buffer_key els� k�t b�jtj�t  �t kell ugorni
	int 21h
	jc go1 ;ha megnyitotta, akkor az nek�nk hiba
	
	ps hibauz4 ;ki�rjuk hogy hiba
	jmp abort ;�s kil�punk
	
go1:
	mov ah,3ch ;l�trehozunk f�jlt �r�sra 
	xor cx,cx ;normal f�jl, cx=0
	mov dx,offset buffer_key[2] ;f�jl neve
	int 21h
	jc hiba ;ha hiba keletkezett, akkor ugrunk
	mov file,ax ;file-be a FILE HANDLE sz�m
	mov szemaforfile,1 ;szemafor egyesbe, hisz most nyitottuk  meg
	
	ps text2 ;text2 ki�r�sa
	olvas ;v�runk egy karakterre
	clrscr ;k�perny� t�rl�se
	
cik1:	
	olvas ;egy karakter beolvas�sa echo n�lk�l
	mov ir,al ;elmentj�k ezt a karaktert
	
	cmp ir,27 ;megn�zz�k nem ESCAPE-e
	je go2 ;ha igen, ugrunk
;itt leellen�rizzuk, hogy �norm�lis� karaktert �t�tt le, nem  valami speci�lis vez�rl�t
	cmp ir,20h ;norm. karakterek 20h-t�l 7fh-ig
	jb cik1 ;ha kisebb mint ez, akkor vissza az elej�re
	cmp ir,7fh
	ja cik1 ;szint�n, csak ha nagyobb

	mov ah,40h ;�r�s f�jlba
	mov bx,file ;file-ba
	mov cx,1 ;1 b�jtot
	mov dx,offset ir ;�ir nev� b�jtot�
	int 21h
	
	mov ah,2 ;ki�rjuk a k�perny�re is
	mov dl,ir
	int 21h
	
	jmp cik1 ;vissza az elej�re
	
go2:
	xor bh,bh ;bh null�z�sa, mint el�bb fent
	mov bl,buffer_key[1]
	mov buffer_key[bx+2],'$' ;csak most a v�g�re egy  doll�rjelet tesz�nk, mert a 9-es DOS szolg�ltat�ssal akarjuk  ki�rni
	
	ps text3 ;text3 ki�rni
	ps buffer_key[2] ;els� k�t b�jtot nem kell ki�rni
	ps text4 ;a sz�veg tov�bbi r�sze
	
	jmp vege ;ugr�s v�g�re, �tugorjuk a hiba�ziket

hiba:	
	cmp ax,3 ;ax=3?
	jz hiba1 ;ha igen, akkor ugrunk
	cmp ax,5 ;ax=5?
	jz hiba2 ;ha igen, akkor ugrunk

	ps hibauz3 ;ha egyik se, akkor ismeretlen hiba
	jmp vege ;ugrunk v�g�re

hiba1:
	ps hibauz1 ;ki�rjuk a hibauz1-et
	jmp vege ;ugr�s v�g�re
	
hiba2:
	ps hibauz2

vege:
	cmp szemaforfile,1 ;megn�zz�k volt-e megnyitott f�jl
	jnz abort ;ha nem akkor v�ge

	mov ah,3eh ;ha volt, lez�rjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;visszaadjuk a vez�rl�st az op.-nek
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk