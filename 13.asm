;Program 13

;Írjon programot, ami kitöröli az aktuális mappából az összes fájlt, amely régebbi mint a billentyûzetrõl megadott dátum.

code segment ;code nevû szegmens létrehozása
assume cs:code,ds:code ;hozzárendelés

;változók
asciiz db '*.*',0 ;4eh ill. 4fh szolg. mit keressen: az  ;aktuális mappában az összes fájlt, utána döntjük el, hogy  ;törölni kell vagy sem
text1 db 'Add meg a datumot nn-hh-ee formaban: $'
text2 db 13,10,10,'A program most kitorli az osszes allomanyt az aktualis mappabol,'
      db 13,10, 'amelyek regebbiek mint az aktualis datum!'
	   db 13,10,10,'Szeretne folytatni? y/n: $'
text3 db 13,10,10,'Hiba keletkezett, a program most befejezodik...$'
text4 db 13,10,10,'Uss le barmilyen billentyut...$'
text5 db 13,10,10,'A fajlok kitorolve!$'
text6 db 13,10,10,'Nem lett kitorolve semmilyen allomany!$'
chyba1 db 13,10,10,'Hiba lepett fel, probald meg meg egyszer!$'
buffer db 9,0,9 dup(0) ;a beolvasott dátum tárolására
dta db 128 dup(0) ;a dta-nak
evm db ? ;a beolvasott dátumból az év tárolására
hom db ? ;a hónap
napm db ? ;ill. a nap
flag db ? ;volt törölve fájl? ez mondja meg, hogy igen vagy  ;nem

;macro text kiírására
write macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm
	
;proc. ascii ==> bináris átalakításra
asciibin proc near ;bemenet si - mutato buffer, cl hossz
                   ;kimenet ax - bin ertek
	xor ax,ax
	cmp cl,0 ;kicsit módosítottam, itt a hosszt a cl  ;tartalmazza
	ja asciibin_go1
	ret

asciibin_go1:	
	mov bx,10
	
asciibin_cik1:
	mul bx ;dx nullázva, ax szorozva bx-el
	mov dl,byte ptr[si]
	sub dl,30h ;levonunk 30h-át, mert ASCII kódú, és nekünk  ;binárisan kell
	add ax,dx ;hozzáadjuk a dx-et az ax-hez
	inc si
	dec cl
	jnz asciibin_cik1

	ret ;visszatérés a fõprogramba
asciibin endp

;macro, a buf-ban levõ két drb. karaktert alakítja számmá, és  ;elmenti a kam nevû változóba
prem macro buf,kam
	mov si,offset buf
	mov cl,2
	call asciibin
	mov kam,al
	endm

;fõprogram
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása
	
	mov ah,1ah ;dta kezdõcímének beállítása
	mov dx,offset dta
	int 21h
	
	mov flag,0 ;flag nullázása
	
go3:
	mov ax,3 ;képernyõ letörlése 80x25-ös módba való lépéssel
	int 10h
	write text1 ;text1 kiírása
	
	mov ah,0ch ;bill. buffer törlése
	mov al,0ah ;string beolvasása a bill.-rõl
	mov dx,offset buffer ;a buffer-ba
	int 21h
	
	cmp buffer[1],8 ;megvan az összes 8 drb karaktert?
	jne go3 ;ha nincs, hát bazmeg mégegyszer elölrõl
	
	cmp buffer[4],'-' ;a megadott dátumnak megadott formája  ;van, két drb – jel van benne, ha ezek nincsenek a helyükön  ;akkor hibás
	jne go3 ;és ugyanúgy mint elõbb, vissza az elejére
	cmp buffer[7],'-'
	jne go3
	
	prem buffer[8],evm ;átalakítjuk a megadott stringet  ;dátummá, most az évet
	cmp evm,99 ;nem lehet nagyobb mint 99, ha csak 2  ;számjegyet lehet megadni, most hívom fel a figyelmet, hogy a  ;program csak 2000 utáni fájlokat képes törölni
	ja go3
	add evm,20 ;hozzáadunk 20-at, mert a dta-ban 2008-1980=28  ;lesz, és nem 8, tehát õ 1980-tól számolja, te meg 2000-tõl  ;adtad meg
	
	prem buffer[5],hom ;átalakítjuk a hónapokat is
	cmp hom,0 ;hónap nem lehet nulla...
	je go3
	cmp hom,12 ;se nagyobb mint 12
	ja go3
	
	prem buffer[2],napm ;a napok átalakítása
	cmp napm,0 ;nem lehet nulla
	je go3
	cmp napm,31 ;se nagyobb mint 31
	ja go3
	
	write text2 ;text2 kiírása
	
go2:
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;egy karakter beolvasása echo nélkül
	int 21h
	cmp al,'y' ;ha igen, akkor ugrás tovább
	je go1
	cmp al,'n' ;ha nem, hát nem, tehát vége
	jne go7
	jmp konec ;ha egyik se, újból kar. bekérése
	
go7:	
	jmp go2 ;azért nem közvetlenül, mert túl messze van ahova  ;ugorni akarunk, feltételes ugrás már oda nem tud ugorni
	
go1:
	mov ah,4eh ;elsõ fájl keresése
	mov dx,offset asciiz ;minden fájl az aktuális mappában
	mov cx,0 ;normal fájlokat keresünk
	int 21h
	jc nebolsubor ;nem volt fájl, akkor cf=1
	
cik1:
	xor ah,ah ;ah nullázása
	mov al,dta[19h] ;a fájl dátumának bevitele az al-be 
	shr al,1 ;eltoljuk 1-el, hogy miért? lásd dta felépítése

	cmp al,evm ;az al-ben már az év van, összehasonlítjuk a  ;mi évünkkel
	jb vym ;ha kisebb, akkor lehet törölni
	cmp al,evm ;ha nagyobb akkor nem
	ja go5
	
;ha egyenlõ akkor vagy igen, vagy nem.. megyünk tovább
	mov ax,word ptr dta[18h] ;most a hónap jön
	mov cl,5 ;5-el fogunk shiftelni
	shr ax,cl ;shiftelünk
	and al,0fh ;és itt and-elünk is, mert ki kell lõni az al  ;felsõ négy bitjét, lásd dta felépítése, dátum rész
	
	cmp al,hom ;ugyanaz mint elõbb, csak most a hónappal
	jb vym
	cmp al,hom
	ja go5
	
	xor ah,ah ;ah nullázása
	mov al,dta[18h] ;most ez a bájt kell a dta-ból 
	and al,1fh ;felsõ 3 bit kilövése
	
	cmp al,napm ;ha kisebb a nap, csak akkor lehet törölni
	jb vym
	jmp go5
	
vym:
	mov ah,41h ;itt törlünk
	mov dx,offset dta[1eh] ;a fájlnév innen kezdõdik
	int 21h
	jc chyba ;ha nem sikerült hiba
	mov flag,1 ;már volt törölt fájl
	
go5:
	mov ah,4fh ;köv. fájl keresése
	mov dx,offset asciiz
	mov cx,0 ;normal fájl
	int 21h
	jc vymkonec ;ha nincs több fájl, akkor vége
	jmp cik1 ;máskülönben vissza az elejére
	
vymkonec:
	cmp flag,1 ;ha vége, akkor megkérdi: volt kitörölt fájl?
	jne nebolsubor ;ha nem, akkor kiírja hogy nem
	
	write text5 ;ha igen, akkor hogy igen
	jmp konec ;és vége
	
nebolsubor:
	write text6 ;nem volt törölve fájl
	jmp konec ;és vége
	
chyba:
	write chyba1 ;ha valami hiba történt, akkor ezt írja ki
	
konec:
	write text4 ;és vége

	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;egy kar.-ra várás echo nélkül
	int 21h
	
	mov ah,4ch ;a vezérlés visszaadása az op.-nek
	int 21h
	
code ends ;code nevû szegmens vége
	end start ;start cimkénél kezdünk