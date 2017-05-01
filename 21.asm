;Program 21

;Írjon programot, amely a billentyûzetrõl karaktereket olvas be, és megjeleníti õket a képernyõn. A program az end szó beírásával ér véget, de ez a szó már nem jelenik meg a képernyõn.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

long EQU 3 ;long szó jelentse azt, hogy 3, a fordító minden  long szó helyére 3-at fog írni, az kilépõ szó hosszát jelöli

;változók
escape db 'end' ;erre a karakterláncra fogunk kilépni
text db 'Karakterek elolvasasa a bill.-rol az end szo beirasaig.',13,10,36 ;36 = ’$’
kar db ?
torleskar db 8,32,8,36
newline db 13,10,36

;egy macro a képernyõn lévõ karakterek törlésére
;a hanyszor jelöli, hogy hány karaktert fog letörölni
;ez az egyetlen paramétere
torles macro hanyszor
local cikm1 ;lokális cimke

	push cx ;elmentjük a cx-et
	mov cx,hanyszor ;a cx lesz a ciklusváltozónk
	
cikm1:	
	mov ah,9 ;kiírjuk a torleskar-t, ezzel törlünk egy  karaktert, lásd torleskar felépítése, 8-as ASCII karakter
	mov dx,offset torleskar
	int 21h
	loop cikm1 ;addig ismételjük, ameddig a cx nulla nem lesz
;azaz annyiszor amennyit a hanyszor-ban megadtunk
	
	pop cx ;visszatesszük a cx tartalmát
	endm ;vége a macro-nak

start:
	mov ax,cs ;beállítjuk az adatszegmenst
	mov ds,ax
	mov ax,0b800h ;az es-t beállítjuk a videomemória  kezdõcímére
	mov es,ax
	cld ;df=0
	
	mov ax,3 ;letöröljük a képernyõt, 80x25-ös módba lépéssel
	int 10h ;BIOS szolgáltatás
	
	mov ah,9 ;kiírjuk a text1-et
	mov dx,offset text
	int 21h

;a cik1 ciklust fogjuk ismételgetni
cik1:	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;egy karakter beolvasása echo nélkül
	int 21h 
	mov kar,al ;elmentjük a beolvasott karaktert a kar  változóba

;itt megnézzük mi volt az elolvasott karakter
	cmp kar,13 ;ha 13 volt akkor az ENTER volt leütve
	je go1 ;tehát egy új sor kell, hát ugrunk oda, ahol ezt  tesszük
	cmp kar,8 ;ha 8-as, akkor a BACKSPACE volt leütve
	je go1 ;ekkor törlünk egy karaktert
	cmp kar,32 ;ez 32-127 közötti karakterek azok, amiket  kiírunk, a többi vezérlõkarakter, ezekkel nem foglalkozunk 
	jb cik1
	cmp kar,127
	jae cik1

	mov ah,2 ;ha ide eljutunk, akkor kiírjuk a kar-t
	mov dl,kar
	int 21h
	
	mov ah,3 ;lekérjük az aktuális kurzorpozíciót
	mov bh,0 ;nulladik lapon vagyunk, ez nem olyan fontos
int 10h ;egy BIOS szolgáltatással kérjük le
	
;na a helyzet az, hogy mi közvetlenül a videomemóriát fogjuk  vizsgálni, nincs e a képernyõn az end szó
;ehhez viszont az aktuális lekért kurzorpozíciókat át kell  kicsit alakítani

	shl dl,1 ;az oszlopokat meg kell szorozni kettõvel
	mov al,dh ;a sorokat meg 160-al
	mov bl,160
	mul bl ;itt csináljuk ezt

	mov si,ax ;az si-vel címezzük a videomemóriát
	mov al,dl 
	xor ah,ah
	add si,ax
	
;itt már az si az aktuális pozícióra mutat a videomem-ben
;azt a bájtot címzi, ahol épp villog a kurzor

	mov di,long ;egy ciklus, összehasonlítjuk az utolsó 3  karaktert az end szóval
cik2:
	sub si,2 ;a videomem-ben kettõvel kell lépkednünk
	dec di ;a end szóban eggyel
	mov al,byte ptr es:[si]
	cmp al,escape[di] ;itt hasonlítunk egy karaktert
	jne cik1 ;ha nem egyezik vissza az elejére
	cmp di,0 ;ha már di 0 akkor végignéztük az egészet
	jnz cik2
	
	jmp vege ;ha ide eljutunk vége a proginak, end volt beírva
	
go1:
	cmp kar,13 ;ide ugrunk ha ENTER vagy BACKSPACE volt leütve
	je go2 ;ha ENTER akkor ugrunk

	torles 1 ;ha BAKCSPACE akkor törlünk egy karaktert
	jmp cik1 ;ugrunk vissza a cik1-re, hisz nincs még vége
	
go2:
	mov ah,9 ;ENTER, tehát új sor
	mov dx,offset newline
	int 21h
	jmp cik1 ;ugrunk vissza a cik1-re, hisz nincs még vége

vege:
	torles long ;letörlünk az end szó hosszúságának megfelelõ  karaktert

	mov ah,4ch ;visszaadjuk a vezérlést az op.-nek
	int 21h

code ends ;code szegmens vége
	end start ;start cimkénél kezdünk