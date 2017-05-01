;Program 28

;Írjon programot, amely kiírja az aktuális mappából azokat az állományokat, amelyek mérete nagyobb mint a bill. megadott érték.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;változój
dta db 128 dup(0) ;dta tárolására
path db '*.*',0 ;elérési út az akt. mappa, minden fájlja
newline db 13,10,36 ;új sor írására
text1 db 'Fajlok listazasa, amelyek nagyobbak mint (bajtokban, max. 4 GB): $'
text2 db 13,10,'Press any key to continue...$'
hibauz1 db 13,10,'Nem talalhato fajl!$'
buffer db 11,0,11 dup(0) ;a szám beolvasása
meret_al dw ? ;meret alacsonyabb bájt
meret_mag dw ? ;meret magasabb bájt
flag db 0 ;volt fájl?

;macro text kiírására
kiir macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm ;macro vége
	
;macro szöveg beolvasására
beolvas macro hova
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah
	mov dx,offset hova
	int 21h
	endm
	
;proc. 32 bites bináris számmá való alakításra ASCIIkódból
;nem magyarázom, ezt nem vettük
;de ide ez kell, lehetne 16 bites is, csak az nem az igazi...
asciibin_32 proc near ;bemenet si - mutato buffer+2
                      ;kimenet dx:ax - bin ertek
	jmp start_asciibin_32
	
magasabb_szo dw ?
alacsonyabb_szo dw ?	

start_asciibin_32:

	cmp byte ptr [si],13
	jne asciibin_32_go1
	xor ax,ax
	xor dx,dx
	ret
	
asciibin_32_go1:
	mov magasabb_szo,0
	mov alacsonyabb_szo,0
	
asciibin_32_ciklus:
	mov cx,magasabb_szo
	mov bx,alacsonyabb_szo
	xor dx,dx
	mov ax,10
	call longmul
	push ax
	mov al,byte ptr [si]
	cbw ;elojeles kiterjesztese az al-nek az az-be
	push dx
	cwd ;ax > dx-be valo kiterjesztese
	pop bx
	pop cx
	add cx,ax
	adc bx,dx
	sub cx,30h
	sbb bx,0
	mov magasabb_szo,bx
	mov alacsonyabb_szo,cx
	inc si
	cmp byte ptr [si],13
	jne asciibin_32_ciklus
	
	mov dx,magasabb_szo
	mov ax,alacsonyabb_szo
	ret
	
asciibin_32 endp

;ez a proc. a asciibin_32-nek kell
longmul proc near
	push si
	xchg si,ax
	xchg dx,ax
	jcxz longmul_go1 ;teszteli, hogy a cx-ben 0 ertek van-e
	xchg cx,ax
	mul si
	
longmul_go1:
	xchg si,ax
	mul bx
	add dx,si
	pop si
	ret
longmul endp ;proc. vége

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása
	
	kiir text1 ;text1 kiírása
	beolvas buffer ;a szám beolvasása
	mov si,offset [buffer+2]
	call asciibin_32 ;átalakítása binárissa
	mov meret_al,ax ;és elmentése
	mov meret_mag,dx
	
	mov ah,1ah ;dta kezdõcímének beállítása
	mov dx,offset dta
	int 21h
	
	mov ah,4eh ;elsõ fájl keresése
	mov dx,offset path ;a path által adott mappában
	mov cx,0 ;normal fájlokat keress
	int 21h
	jnc tovabb ;ha nincs hiba, vagyis találtál, akkor tovább
	
	jmp vege ;ha hiba akkor ugrunk a végére

tovabb:	
	mov si,1ch ;megnézzük a fájlméretet
	mov ax,word ptr dta[si] ;elõször a magasabb bájtot
	cmp ax,meret_mag ;ha ez kisebb akkor az nem jó, következõ
	jb kov
	mov ax,word ptr dta[si-2] ;alacsonyabb bájt
	cmp ax,meret_al ;ha ez kisebb vagy egyenlõ akkor nem jó 
	jbe kov ;és jöhet a következõ

	kiir newline ;új sor írása
	mov si,1eh ;innen kezdõdik a fájlnév

cik1: 
	mov ah,2 ;egy kar. kiírása
	mov dl,byte ptr dta[si] ;ezen kar. kiírása
	int 21h ;tedd meg!
	inc si ;köv. karra mutass
	cmp byte ptr dta[si],0 ;az nulla?
	jnz cik1 ;ha még nem akkor ismételj
	mov flag,1 ;egy fájlnév már biztos ki volt írva, ezért  flag egyesbe

kov:
	mov ah,4fh ;köv. fájl keresése
	int 21h
	jnc tovabb ;ha cf=0, már nincs fájl
	
vege:
	cmp flag,0 ;flag=0?
	jne abort ;ha nem, akkor vége
	kiir hibauz1 ;ha igen kiírunk egy hibaüzit, hogy nem volt  fájl 
	
abort:
	kiir text2 ;várás egy bill.-re szöveg
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy bill.-re
	int 21h

	mov ah,4ch ;vezérlés vissza az op.-nek
	int 21h

code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk