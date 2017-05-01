;Program 04

;Írjon programot két hatjegyû billentyûzetrõl beadott BCD szám összeadására. Az eredményt (BCD szám) jelenítse meg a számítógép monitorán.

code segment ;code nevû szegmens létrehozása
	assume cs:code,ds:code ;hozzárendelés

;szamjegy nevû konstans, írhattuk volna azt is, hogy szamjegy  EQU 6, de nekem ez így jobban teccik
szamjegy = 6

;változók
;36 = ‘$’, 13,10 új sor írására, ha több új sort akarunk, nem  kell többször a 13, elég a 10, mivel lényegében ez tesz új  sort, a 13 csak a sor elejére viszi a kurzort 
text1 db 'Adj meg ket hatjegyu szamot: ',13,10,10,36
text2 db '. szam:      $'
text3 db 13,10,10,'Nyomj le egy billentyut a kilepeshez...$'
text4 db ' Ok!',13,10,36
text5 db '             -------' 
      db 13,10,'Az osszeguk: $'
szam1 db szamjegy dup(0) ;az elsõ szám tárolására
szam2 db szamjegy dup(0) ;a második szám tárolására
eredmeny db szamjegy+1 dup(0) ;az eredmény tárolására, eggyel  nagyobb, mert lehet, hogy a végén kimarad az egy, ezt  valahova el kell tenni...
index1 db 0 ;ez arra, hogy amikor kiírja, hogy .szam, akkor  tudja, hogy épp hanyadik számnál tartunk, lehet nyugodtan itt  nullázni 
kar db ? ;a beolvasott kar. tárolására 
flag1 db ? ;volt már szám, nullán kívül? ezt mondja meg

;macro string kiírására
kiir macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm
	
;macro a BCD kódú szám beolvasására, a szám elsõ bájtja a szam
beolvas macro szam
local beolvas_go1,beolvas_cik1 ;lokális cimkék
	mov flag1,0 ;flag-et nullázzuk
	xor si,si ;si-t szintén
	inc index1 ;index legyen eggyel nagyobb
	mov ah,2 ;írjuk ki az indexet
	mov dl,index1
	add dl,30h ;elõbb hozzáadunk 30h-t, mivel számként akarjuk  kiírni
	int 21h
	
	kiir text2 ;aztán a szöveg többi részét is kiírjuk
	
	mov ah,0ch ;bill. buffert töröljük
	int 21h

beolvas_cik1:
	mov ah,7 ;beolvasunk egy karaktert
	int 21h
	
	mov kar,al ;elmentjük az al-be
	
	cmp kar,30h ;megnézzük 0 volt? 30h = ’0’
	jne beolvas_go1 ;ha nem akkor semmi, tovább megyünk
	cmp flag1,0 ;ha igen, akkor volt már kiírt számjegy?
	je beolvas_cik1 ;ha nem, akkor még ezt sem írjuk ki, mert  ugyebár egy szám nem kezdõdhet nullával
	
beolvas_go1:
	cmp kar,30h ;meg kell nézni, hogy szám volt-e leütve
	jb beolvas_cik1 ;ha kisebb volt mint 30h, az baj
	cmp kar,39h ;ha nagyobb mint 39h az is, ezért nem érdekel  minket, és egyszerûen kérünk egy új számot
	ja beolvas_cik1
	
	mov ah,2 ;ha minden rendben volt, kiírjuk a számot
	mov dl,kar
	int 21h
	mov flag1,1 ;és flag egyesbe, mert már volt kiírt szám
	
	sub kar,30h ;el is mentjük a számot, levonunk 30h-át, mert  nem ASCII-ban akarjuk elmenteni, hanem egyszerû számként
	mov al,kar
	mov szam[si],al ;si-vel címezzük a szám indexet
	inc si ;köv. számjegyre mutass!
	
	cmp si,szamjegy ;van már elég számjegy?
	jb beolvas_cik1 ;ha még nincs, akkor olvass!
	endm
	
start:
	mov ax,cs ;adatszegmens kezdõcímének beállítása
	mov ds,ax
	cld ;df nullázása, azért mert az alacsonyabb bájttól a  magasabb bájtig fogjuk kiírni a stringeket, nem fordítva
	
	mov ax,3 ;képernyõ törlése, 80x25-ös módba való lépéssel
	int 10h
	
	kiir text1 ;text1 kiírása
	
	beolvas szam1 ;elsõ szám beolvasása
	kiir text4 ;kiírjuk, hogy ok
	beolvas szam2 ;ugyanaz
	kiir text4
	
	mov si,szamjegy ;na itt fogunk összeadnik, a végérõl  kezdjük, mint a normális összeadásnál 
	
cik1:
	dec si ;si dekrementálása
	mov al,szam1[si] ;átvisszük az elsõ számot az al-be
	add al,szam2[si] ;hozzáadjuk a másikat
	add eredmeny[si+1],al;itt menti el az eredménybe, si+1  azért, mert az eredmény egy bájttal el van tolva a két  beolvasott számhoz képest, nem muszáj ez hogy így legyen, én  így találtam ki
	cmp eredmeny[si+1],al ;megnézzük túl csordul-e
	jbe go1 ;ha nem akkor semmi gond, továbbmehetünk

	sub eredmeny[si+1],10 ;ha igen, akkor le kell vonni belõle  10-et, gondolkozz el miért, és a köv. számjegyhez hozzáadni egyet
	inc eredmeny[si] ;és menni tovább, nem?
	
go1:
	cmp si,0 ;már a tömb végén vagyunk?
	jnz cik1 ;ha nem akkor ismételj!
	
	kiir text5 ;jó készen van az összeadás, írjuk ki az  eredményt!
	
	xor si,si ;az elejérõl kezdjük kiírni, si-vel cimezzük
	cmp eredmeny[0],0 ;ha nem volt a végén maradék, akkor az  eredmény elsõ bájtja, nulla maradt, de ez nem jó, ekkor  helyette ki kell írni egy szóközt
	jne cik2
	mov ah,2
	mov dl,' ' ;itt írunk helyette egy szóközt
	int 21h
	inc si ;és si eggyel nagyobb, mert az elsõ számjegyet  akkor már nem kell nézni, hisz most írtuk ki
	
cik2:
	mov ah,2 ;kiírjuk a számjegyet
	mov dl,eredmeny[si]
	add dl,30h ;ASCII azért kell +30h
	int 21h
	inc si
	cmp si,szamjegy ;már kiírtuk az összeset?
	jbe cik2

	kiir text3 ;ez már a vége
	
	mov ah,0ch ;bill. buffer törlése
	mov al,7 ;várás egy kar.-ra echo nélkül
	int 21h
	
	mov ah,4ch ;a vezérlés visszaadása az op.-nek
	int 21h
	
code ends ;code nevû szegmens vége
	end start ;a start cimkénél kezdünk