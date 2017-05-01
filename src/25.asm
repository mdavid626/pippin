;Program 25

;Írjon programot, amely kiírja a képernyõre az összes állományt az aktuális mappából, amely megfelelnek a bill. megadott maszknak.

code segment ;code	szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változók
dta db 128 dup(0) 
buffer db 13,0,13 dup(0) ;8+11 + pont meg az ENTER
newline db 13,10,36 ;újsor
text1 db 'Maszk: $' 
text2 db 13,10,'Az aktualis mappaban talalhato fajlok:$'
hibauz1 db 13,10,'Nem talalhato fajl!$'
hibauz2 db 13,10,'Nem adtal meg maszkot!',13,10,36

start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása
	
	mov ah,1ah ;dta beállítása
	mov dx,offset dta
	int 21h

cik1:
	mov ah,9 ;kiírjuk a text1-et
	mov dx,offset text1
	int 21h
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;karakterek beolvasása bill.-rõl
	mov dx,offset buffer
	int 21h
	
	cmp buffer[1],0 ;megnézzük a volt-e beadva karakter
;vagy csak ENTER volt leütve
	jnz go1 ;ha nem csak ENTER megyünk tovább
	
	mov ah,9 ;ha csak ENTER, hibaüzi
	mov dx,offset hibauz2
	int 21h
	jmp cik1 ;és nyomás vissza az elejére
	
go1:
	xor bh,bh ;bh=0
	mov bl,buffer[1] ;bl-be bevisszük mennyi kar. volt  beolvasva
	mov buffer[bx+2],0 ;a végére dobunk egy 0-at
	
	mov ah,9 ;kiírjuk a text2-t
	mov dx,offset text2
	int 21h
	
	mov ah,4eh ;megkeressük az elsõ fájlt
	mov dx,offset buffer[2] ;elsõ két bájtot át kell ugornunk
	mov cx,0 ;normal fájlokat keresünk
	int 21h
	jc hiba ;ha hiba történt, ugrunk

cik2:	
	mov si,1eh ;dta-ba ettõl a címtõl kezdõdik a fájlnév

	mov ah,9 ;kiírunk egy újsort
	mov dx,offset newline
	int 21h
	
cik3: 
	mov ah,2 ;és elkezdjük kiírni a fájlnevet
	mov dl,byte ptr dta[si]
	int 21h
	inc si ;mindig a köv. bájtra állítjuk az si-t
	cmp byte ptr dta[si],0 ;megnézzük nincs-e még vége
	jnz cik3 ;ha nincs akkor kiírjuk

	mov ah,4fh ;keressük a köv. fájlt
	int 21h
	jnc cik2 ;ha talált fájlt, azt kiírjuk, szóval vissza  cik2-re

	jmp vege ;itt ugrunk már a végére, átugorjuk a hibaüziket

hiba:	
	mov ah,9 ;kiírjuk a hibaüzit
	mov dx,offset hibauz1
	int 21h

;itt a vége, fuss el véle
vege:
	mov ah,4ch ;korrektül befejezzük a programot
	int 21h

code ends ;code szegmens vége
	end start ;start cimkénél kezdünk