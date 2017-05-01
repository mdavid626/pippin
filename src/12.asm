;Program 12

;�rjon programot a sz�veges �llom�nyok megjelen�t�s�re a k�perny�n. Az �llom�ny nev�t k�rje be a billenty�zetr�l. Ha a megadott �llom�ny nem l�tezik, jelen�tsen meg hiba�zenetet: "A megadott �llom�ny nem l�tezik!". A k�perny� betel�sekor az utols� sorban jelen�tse meg: "�ss le egy billenty�t a folytat�shoz...". 

code segment ;code szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�k
buffer_file db ?
buffer_key db 65,0,65 dup(0)
text1 db 'File: $'
text2 db 13,10,'Press any key to continue or q to terminate... $'
text3 db 13,10,'Press any key to terminate... $'
hibauz1 db 13,10,'Cant find the path$'
hibauz2 db 13,10,'Access denied!$'
hibauz3 db 13,10,'The file doesnt exist!$'
hibauz4 db 13,10,'Unknown error$'
file dw ?
szemafor db 0

;egy egyszer� proced�ra, ki�rja a k�perny�re a dx-be megadott stringet, majd pedig v�r egy bill. le�t�s�re
waitproc proc near ; bemenet: dx, kimenet: con, al
	mov ah,9 ;ki�rjuk
	int 21h
	
	mov ah,0ch ;t�r�lj�k a buffert
	mov al,07h ;v�runk egy bill.-re
	int 21h
	ret ;visszat�r�nk
waitproc endp
	
start:
	mov ax,cs ;adatszegmens be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa, string ki�r�s miatt

	mov ah,9 ;ki�rjuk a kezd�sz�veget
	lea dx,text1 ;bevissz�k a dx-be a text1 offsetc�m�t
	int 21h
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah ;f�jln�v beolvas�sa
	lea dx,buffer_key 
	int 21h
	
	xor bh,bh ;bh t�rl�se
	mov bl,buffer_key[1] ;bevissz�k bl-be h�ny karaktert olvastunk be
	mov buffer_key[bx+2],0 ;a buffer v�g�re tesz�nk egy 0-at

	mov ah,3dh ;megnyitjuk a f�jlt
	xor al,al ;normal f�jl
	lea dx,buffer_key 
	add dx,2 ;az els� k�t b�jtot �tugorjuk
	int 21h
	jc hiba ;ugrunk, ha hiba van
	mov file,ax ;elmentjuk a FILE HANDLE-t
	mov szemafor,1 ;szemafor egyesbe, mert van megnyitott f�jl
	
	mov ax,3 ;t�r�lj�k a k�perny�t, 80x25 m�dba v�lt�ssal
	int 10h
	
cik1:
	mov ah,3fh ;olvasunk a f�jlb�l
	mov bx,file ;FILE HANDLE bevitele bx-be
	mov cx,1 ;1 b�jtot fogunk olvasni
	lea dx,buffer_file ;ide fogunk olvasni
	int 21h
	jc hiba ;hiba - ugrunk
	cmp ax,0 ;ha ax = 0 �s nem volt hiba, EOF � v�ge a f�jlnak
	jz vege ;teh�t befejezz�k a programot
	
	mov ah,3 ;megn�zz�k a k�perny� h�nyadik sor�ba vagyunk
	mov bh,0 ;nulladik �lapon� vagyunk
	int 10h
	cmp dh,23 ;ha a 24. sorba vagyunk �figyel�nk�
	jz felt1 ;megn�zz�k, hogy mi teljes�l m�g
	jmp ird ;ha nem a 24. sorba ki�rjuk a beolvasott b�jtot
	
felt1:
	cmp dl,79 ;vizsg�l�dunk tov�bb, 80. oszlopba vagyunk
	jz varj ;ha igen, ez azt jelenti: 24. sor 80. oszlop > ki�rjuk a �Press any key to continue�-t
	cmp buffer_file,10 ;az is fontos, hogy ha nem is vagyunk a 80. oszlopba, ha a f�jlban �j sort kezd�nk, m�r akkor is ki kell �rni a sz�veget
	jz varj
	
ird:	
	mov ah,2 ;ki�rjuk a beolvasott b�jtot
	mov dl,buffer_file
	int 21h
	jmp cik1 ;�jra el�re �s olvasunk

varj:
	lea dx,text2 ;megadjuk, hogy mit akarunk ki�rni
	call waitproc ;ki�rjuk �s v�runk
	cmp al,'q' ;megn�zz�k, mit nyomtunk le
	jz abort ;ha q-t kil�p�nk
	
	mov ax,3 ;t�r�lj�k a k�perny�t, 80x25-s m�dba val� l�p�ssel
	int 10h
	
	cmp buffer_file,10 ;ha �j sort kezdt�nk a f�jlba, ezt nem �rjuk ki az �j k�perny�re
	jnz ird
	jmp cik1 ;�jra el�re �s olvasunk
	
hiba:
	cmp ax,3 ;megn�zz�k milyen hiba keletkezett
	jz hiba1 ;�s aszerint ugrunk
	cmp ax,5
	jz hiba2
	cmp ax,2
	jz hiba3
	
	mov ah,9 ;ha egyik se, ki�rjuk, hogy ismeretlen
	lea dx,hibauz4
	int 21h
	jmp vege
	
hiba1:
	mov ah,9
	lea dx,hibauz1
	int 21h
	jmp vege
	
hiba2:
	mov ah,9
	lea dx, hibauz2
	int 21h
	jmp vege

hiba3:
	mov ah,9
	lea dx,hibauz3
	int 21h
		
vege:
	lea dx,text3 ;ki�rjuk a text3-at �s v�runk egy bill.-re
	call waitproc
	
	cmp szemafor,0 ;megn�zz�k volt-e megnyitva f�jl
	jz abort ;ha nem kil�p�nk

	mov ah,3eh ;ha igen, bez�rjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;a vez�rl�s visszaad�sa az op-nek
	int 21h

code ends ;code szegmens lez�r�sa
	end start ;start cimk�n�l l�p�nk be a programba]