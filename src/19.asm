;Program 19

;Írjon programot, amely az aktuális mappában létrehoz egy mappát a bill. megadott névvel, és az aktuális könyvtárrá teszi. 

code segment ;szegmens nyitása
	assume cs:code,ds:code ;hozzárendelés a kód ill. adatszeg.hez

;változók létrehozása
text1 db 'Almappa neve (max 8 karakter): $'
hibauz1 db 13,10,'Hiba: az ut nem talalhato!$'
hibauz2 db 13,10,'Hiba: az eleres nincs engedelyezve!$'
hibauz3 db 13,10,'Hiba: nem adtal meg eleresi utat!',13,10,36
hibauz4 db 13,10,'Hiba: ismeretlen!$'
buffer db 9,0,9 dup(0)

start:	
	mov ax,cs ;beállítjuk az adatszegmens-t
	mov ds,ax
	cld ;0-ba állítjuk a DF-et, a szövegkiíráshoz

cik1:	
	mov ah,09h ;kiírjuk a text1-et
	mov dx,offset text1 
	int 21h

	mov ah,0ch ;billentyûzetbuffer törlése
	mov al,0ah ;mappanév beolvasása a bufferba
	mov dx,offset buffer
	int 21h
	
	cmp buffer[1],0 ;megnézzük, hogy van-e beolvasott karakter
	jnz tovabb ;ha van továbbmegyünk

	mov ah,9 ;ha nincs hibaüzi
	mov dx,offset hibauz3
	int 21h
	jmp cik1 ;és vissza az elejére
	
tovabb:  
	xor dh,dh ; dh törlése
	mov dl,buffer[1] ;beolvasott karakterek számának bevitele a dl-be
	mov di,dx ;ezt átvisszük a di-be
	mov buffer[di+2],0 ;a végére teszünk egy 0-át

	mov ah,39h ;létrehozom az alkönyvtárat
	mov dx,offset buffer
	add dx,2 ;ez azért kell, hogy a buffer elsõ két bájtját átugorjuk
	int 21h
	jc hiba ;ha hiba történt ugrunk
	
	mov ah,3bh ;aktuálissá tesszük a létrehozott alkönyvtárat
	mov dx,offset buffer
	add dx,2 ;ugyanaz mint elõbb
	int 21h
	jc hiba ;ugrunk, ha hiba történt

	jmp vege ;átugorjuk a hibaüziket

hiba:		
	cmp ax,3 ;megnézzük, melyik „hiba” történt
	jz hiba1
	cmp ax,5
	jz hiba2

	mov ah,09h ;nem tudjuk pontosan, kiírjuk, hogy ismeretlen
	mov dx,offset hibauz4
	int 21h

	jmp vege ;ugrunk a végére

hiba1:  
	mov ah,09h ;hibaüzi kiírása
	mov dx,offset hibauz1
	int 21h
	jmp vege

hiba2:   
	mov ah,09h ;hibaüzi kiírása
	mov dx,offset hibauz2
	int 21h

vege:		
	mov ah,4ch ;befejezzük a programot
	int 21h

code ends ;lezárjuk a code nevû szegmenst
	end start ;start cimkénél kezdünk