;Program 11

;Írjon programot szöveges állomány létrehozására a lemezen, és a megtöltésére a bill. beadott karakterekkel. A tevékenység befejezõ karakterének az ESC bill. válassza. Megjegyzés: a vezérlõ billentyûket, nyilakat és a Backspace bill. ignorálja!

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés
	
;változók
text1 db 'Add meg a kivant fajlnevet: $'
text2 db 13,10,'Nyomj le egy billentyut a folytatashoz...$'
text3 db 13,10,'A szoveg sikeresen elmentve a(z) $'
text4 db ' allomanyba!$' 
hibauz1 db 13,10,'Nem talalom az utat!$'
hibauz2 db 13,10,'Nincs engedelyezve a hozzaferes!$'
hibauz3 db 13,10,'Ismeretlen hiba!$'
hibauz4 db 13,10,'Nem tudom letrehozni a fajlt! (Lehet, hogy mar letezik?)$'
file dw ? ;FILE HANDLE szám eltárolására
szemaforfile db 0 ;volt-e megnyitott fájl
buffer_key db 65,0,65 dup(0) ;ide mentjük a beolvasott  fájlnevet
ir db ? ;ide mentjük a beolvasott karaktert

;macro string kiírására
ps macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm ;macro vége

;macro egy karakter olvasására echo nélkül
olvas macro
	mov ah,0ch
	mov al,7
	int 21h
	endm

;macro a képernyõ törlésére
clrscr macro
	mov ax,3 ;váltunk 80x25-ös módba, evvel töröljük a kép.
	int 10h
	endm

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullazása
	
	clrscr ;képernyõ törlése
	ps text1 ;text1 kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;fájlnév beolvasása
	mov dx,offset buffer_key ;ide olvasunk
	int 21h ;csináld!
	
	xor bh,bh ;bh nullázása, azért, mert a bx-et fogjuk  használni, de nem fogunk írni a bh-ba 
	mov bl,buffer_key[1] ;bl-be a beolvasott karakterek száma
	mov buffer_key[bx+2],0 ;ez alapján a string végére egy  nullát
	
	mov ah,3dh ;a fájl megnyitása, azért, hogy ne írjuk felül
	xor al,al ;normal file, al=0
	mov dx,offset buffer_key[2] ;buffer_key elsõ két bájtját  át kell ugorni
	int 21h
	jc go1 ;ha megnyitotta, akkor az nekünk hiba
	
	ps hibauz4 ;kiírjuk hogy hiba
	jmp abort ;és kilépunk
	
go1:
	mov ah,3ch ;létrehozunk fájlt írásra 
	xor cx,cx ;normal fájl, cx=0
	mov dx,offset buffer_key[2] ;fájl neve
	int 21h
	jc hiba ;ha hiba keletkezett, akkor ugrunk
	mov file,ax ;file-be a FILE HANDLE szám
	mov szemaforfile,1 ;szemafor egyesbe, hisz most nyitottuk  meg
	
	ps text2 ;text2 kiírása
	olvas ;várunk egy karakterre
	clrscr ;képernyõ törlése
	
cik1:	
	olvas ;egy karakter beolvasása echo nélkül
	mov ir,al ;elmentjük ezt a karaktert
	
	cmp ir,27 ;megnézzük nem ESCAPE-e
	je go2 ;ha igen, ugrunk
;itt leellenõrizzuk, hogy „normális” karaktert ütött le, nem  valami speciális vezérlõt
	cmp ir,20h ;norm. karakterek 20h-tól 7fh-ig
	jb cik1 ;ha kisebb mint ez, akkor vissza az elejére
	cmp ir,7fh
	ja cik1 ;szintén, csak ha nagyobb

	mov ah,40h ;írás fájlba
	mov bx,file ;file-ba
	mov cx,1 ;1 bájtot
	mov dx,offset ir ;„ir nevû bájtot”
	int 21h
	
	mov ah,2 ;kiírjuk a képernyõre is
	mov dl,ir
	int 21h
	
	jmp cik1 ;vissza az elejére
	
go2:
	xor bh,bh ;bh nullázása, mint elõbb fent
	mov bl,buffer_key[1]
	mov buffer_key[bx+2],'$' ;csak most a végére egy  dollárjelet teszünk, mert a 9-es DOS szolgáltatással akarjuk  kiírni
	
	ps text3 ;text3 kiírni
	ps buffer_key[2] ;elsõ két bájtot nem kell kiírni
	ps text4 ;a szöveg további része
	
	jmp vege ;ugrás végére, átugorjuk a hibaüziket

hiba:	
	cmp ax,3 ;ax=3?
	jz hiba1 ;ha igen, akkor ugrunk
	cmp ax,5 ;ax=5?
	jz hiba2 ;ha igen, akkor ugrunk

	ps hibauz3 ;ha egyik se, akkor ismeretlen hiba
	jmp vege ;ugrunk végére

hiba1:
	ps hibauz1 ;kiírjuk a hibauz1-et
	jmp vege ;ugrás végére
	
hiba2:
	ps hibauz2

vege:
	cmp szemaforfile,1 ;megnézzük volt-e megnyitott fájl
	jnz abort ;ha nem akkor vége

	mov ah,3eh ;ha volt, lezárjuk
	mov bx,file
	int 21h
	
abort:
	mov ah,4ch ;visszaadjuk a vezérlést az op.-nek
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk