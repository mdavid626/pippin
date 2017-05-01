;Program 20

;�rjon programot, amely az aktu�lis k�nyvt�rban l�trehoz egy �llom�nyt a k�nyvt�rban lev� �llom�nyok nev�vel. 

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
dta db 128 dup(0)
asciiz1 db 'FILELIST.TXT',0
asciiz2 db '*.*',0
newline db 13,10,36
text1 db 'A lista sikeresen letrehozva a FILELIST.TXT allomanyba!$'
hibauz1 db 'Nem talalom az utat!$'
hibauz2 db 'Nincs engedelyezve a hozzaferes!$'
hibauz3 db 'Nem talalhato fajl!$'
hibauz4 db 'Ismeretlen hiba!$'
hibauz5 db 'Nem tudom letrehozni a fajlt! (Lehet, hogy mar letezik?)$'
file dw ?
szemaforfile db 0
szemaforelso db 0

start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	mov ah,1ah ;dta be�ll�t�sa
	mov dx,offset dta
	int 21h

	mov ah,4eh ;f�jl keres�se az adott mapp�ban
	mov dx,offset asciiz2
	mov cx,0 ;normal f�jlokat keres�nk
	int 21h
	jc hiba ;ha hiba keletkezett, ugrunk

	mov ah,3dh ;megpr�b�ljuk megnyitni a FILELIST.TXT f�jlt
;ha megnyitja, akkor l�tezik, ha nem akkor l�trehozzuk
	xor al,al ;csak olvas�sra nyitjuk meg
	mov dx,offset asciiz1 ;a f�jln�v c�m�t a dx-be
	int 21h
	jc go1 ;ha nem l�tezik akkor tov�bbmegy�nk 
	
	mov ah,9 ;ha igen, hiba�zenet
	mov dx,offset hibauz5
	int 21h
	jmp abort ;�s kil�p�nk
	
go1:
	mov ah,3ch ;l�trehozzuk a f�jlt
	xor cx,cx ;normal f�jl
	mov dx,offset asciiz1 ;�tadjuk a nev�t
	int 21h
	jc hiba ;ha nem siker�lt l�trehozni, ugrunk a hib�ra
	mov file,ax ;elmentj�k a FILE HANDLE-t
	mov szemaforfile,1 ;be�ll�tjuk a szemaforfile-t 1-re, hogy 
;a v�g�n tudjuk, hogy volt megnyitott f�jl
	
cik1:	
	cmp szemaforelso,0 ;el�sz�r nem kell �j sor
	jz go2 ;teh�t �tugorjuk

	mov ah,40h ;itt �rjuk az �j sort a f�jlba
	mov bx,file ;bxbe tessz�k, hogy melyik f�jlba akarunk �rni
	mov cx,2 ;k�t b�jtot �runk
	mov dx,offset newline ;ezt �rjuk
	int 21h
	jc hiba ;ha hiba ugrunk

go2:	
	mov szemaforelso,1 ;t�bbsz�r m�r nem kell �tugorni
	mov di,1eh ;innen n�zz�k v�gig a dta-t
	
cik2:	
	cmp dta[di],0 ;meg kell sz�molni mennyi b�jtot kell ki�rni
	lea di,[di+1] ;ezt nem vett�k, de �gy szinte t�k�letes:D
	jnz cik2
	
	mov cx,di ;cx-be kell a ki�rni k�v�nt b�jtok sz�ma
	sub cx,1fh ;de a di-be pont 1fh-val t�bb van

	mov ah,40h ;be�rjuk a f�jlba
	mov bx,file ;melyikbe?
	mov dx,offset dta[1eh] ;mit?
	int 21h
	
	mov ah,4fh ;keress�k tov�bb a tov�bbi f�jlokat
	int 21h
	jnc cik1 ;ha van akkor ki�rjuk, ha nincs akkor k�sz
	
	mov ah,9 ;ki�runk egy �zit, hogy k�sz
	mov dx,offset text1
	int 21h

	jmp vege ;�s ugrunk a v�g�re

;hib�k kezel�se
hiba:
	cmp ax,3 ;megn�zz�k mi volt az ax-be, aszerint ugrunk
	jz hiba1
	cmp ax,5
	jz hiba2
	cmp ax,12h
	jz hiba3

	mov ah,9
	mov dx,offset hibauz4
	int 21h
	jmp vege

hiba1:
	mov ah,9 ;ezekkel ki�rjuk a hiba�ziket
	mov dx,offset hibauz1
	int 21h
	jmp vege
	
hiba2:
	mov ah,9
	mov dx,offset hibauz2
	int 21h
	jmp vege

hiba3:
	mov ah,9
	mov dx,offset hibauz3
	int 21h
	jmp vege

;itt a v�ge, fuss el v�le... :D
vege:
	cmp szemaforfile,1 ;ha volt megnyitva f�jl akkor a  szemafor 1-es, �s be kell z�rni
	jnz abort ;ha nem akkor v�ge

	mov ah,3eh
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;korrekt�l bez�rjuk a programot 
	int 21h

code ends ;code szegmens v�ge
	end start ;start cimk�n kezd�nk