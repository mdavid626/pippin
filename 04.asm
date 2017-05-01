;Program 04

;�rjon programot k�t hatjegy� billenty�zetr�l beadott BCD sz�m �sszead�s�ra. Az eredm�nyt (BCD sz�m) jelen�tse meg a sz�m�t�g�p monitor�n.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;szamjegy nev� konstans, �rhattuk volna azt is, hogy szamjegy  EQU 6, de nekem ez �gy jobban teccik
szamjegy = 6

;v�ltoz�k
;36 = �$�, 13,10 �j sor �r�s�ra, ha t�bb �j sort akarunk, nem  kell t�bbsz�r a 13, el�g a 10, mivel l�nyeg�ben ez tesz �j  sort, a 13 csak a sor elej�re viszi a kurzort 
text1 db 'Adj meg ket hatjegyu szamot: ',13,10,10,36
text2 db '. szam:      $'
text3 db 13,10,10,'Nyomj le egy billentyut a kilepeshez...$'
text4 db ' Ok!',13,10,36
text5 db '             -------' 
      db 13,10,'Az osszeguk: $'
szam1 db szamjegy dup(0) ;az els� sz�m t�rol�s�ra
szam2 db szamjegy dup(0) ;a m�sodik sz�m t�rol�s�ra
eredmeny db szamjegy+1 dup(0) ;az eredm�ny t�rol�s�ra, eggyel  nagyobb, mert lehet, hogy a v�g�n kimarad az egy, ezt  valahova el kell tenni...
index1 db 0 ;ez arra, hogy amikor ki�rja, hogy .szam, akkor  tudja, hogy �pp hanyadik sz�mn�l tartunk, lehet nyugodtan itt  null�zni 
kar db ? ;a beolvasott kar. t�rol�s�ra 
flag1 db ? ;volt m�r sz�m, null�n k�v�l? ezt mondja meg

;macro string ki�r�s�ra
kiir macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm
	
;macro a BCD k�d� sz�m beolvas�s�ra, a sz�m els� b�jtja a szam
beolvas macro szam
local beolvas_go1,beolvas_cik1 ;lok�lis cimk�k
	mov flag1,0 ;flag-et null�zzuk
	xor si,si ;si-t szint�n
	inc index1 ;index legyen eggyel nagyobb
	mov ah,2 ;�rjuk ki az indexet
	mov dl,index1
	add dl,30h ;el�bb hozz�adunk 30h-t, mivel sz�mk�nt akarjuk  ki�rni
	int 21h
	
	kiir text2 ;azt�n a sz�veg t�bbi r�sz�t is ki�rjuk
	
	mov ah,0ch ;bill. buffert t�r�lj�k
	int 21h

beolvas_cik1:
	mov ah,7 ;beolvasunk egy karaktert
	int 21h
	
	mov kar,al ;elmentj�k az al-be
	
	cmp kar,30h ;megn�zz�k 0 volt? 30h = �0�
	jne beolvas_go1 ;ha nem akkor semmi, tov�bb megy�nk
	cmp flag1,0 ;ha igen, akkor volt m�r ki�rt sz�mjegy?
	je beolvas_cik1 ;ha nem, akkor m�g ezt sem �rjuk ki, mert  ugyeb�r egy sz�m nem kezd�dhet null�val
	
beolvas_go1:
	cmp kar,30h ;meg kell n�zni, hogy sz�m volt-e le�tve
	jb beolvas_cik1 ;ha kisebb volt mint 30h, az baj
	cmp kar,39h ;ha nagyobb mint 39h az is, ez�rt nem �rdekel  minket, �s egyszer�en k�r�nk egy �j sz�mot
	ja beolvas_cik1
	
	mov ah,2 ;ha minden rendben volt, ki�rjuk a sz�mot
	mov dl,kar
	int 21h
	mov flag1,1 ;�s flag egyesbe, mert m�r volt ki�rt sz�m
	
	sub kar,30h ;el is mentj�k a sz�mot, levonunk 30h-�t, mert  nem ASCII-ban akarjuk elmenteni, hanem egyszer� sz�mk�nt
	mov al,kar
	mov szam[si],al ;si-vel c�mezz�k a sz�m indexet
	inc si ;k�v. sz�mjegyre mutass!
	
	cmp si,szamjegy ;van m�r el�g sz�mjegy?
	jb beolvas_cik1 ;ha m�g nincs, akkor olvass!
	endm
	
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa, az�rt mert az alacsonyabb b�jtt�l a  magasabb b�jtig fogjuk ki�rni a stringeket, nem ford�tva
	
	mov ax,3 ;k�perny� t�rl�se, 80x25-�s m�dba val� l�p�ssel
	int 10h
	
	kiir text1 ;text1 ki�r�sa
	
	beolvas szam1 ;els� sz�m beolvas�sa
	kiir text4 ;ki�rjuk, hogy ok
	beolvas szam2 ;ugyanaz
	kiir text4
	
	mov si,szamjegy ;na itt fogunk �sszeadnik, a v�g�r�l  kezdj�k, mint a norm�lis �sszead�sn�l 
	
cik1:
	dec si ;si dekrement�l�sa
	mov al,szam1[si] ;�tvissz�k az els� sz�mot az al-be
	add al,szam2[si] ;hozz�adjuk a m�sikat
	add eredmeny[si+1],al;itt menti el az eredm�nybe, si+1  az�rt, mert az eredm�ny egy b�jttal el van tolva a k�t  beolvasott sz�mhoz k�pest, nem musz�j ez hogy �gy legyen, �n  �gy tal�ltam ki
	cmp eredmeny[si+1],al ;megn�zz�k t�l csordul-e
	jbe go1 ;ha nem akkor semmi gond, tov�bbmehet�nk

	sub eredmeny[si+1],10 ;ha igen, akkor le kell vonni bel�le  10-et, gondolkozz el mi�rt, �s a k�v. sz�mjegyhez hozz�adni egyet
	inc eredmeny[si] ;�s menni tov�bb, nem?
	
go1:
	cmp si,0 ;m�r a t�mb v�g�n vagyunk?
	jnz cik1 ;ha nem akkor ism�telj!
	
	kiir text5 ;j� k�szen van az �sszead�s, �rjuk ki az  eredm�nyt!
	
	xor si,si ;az elej�r�l kezdj�k ki�rni, si-vel cimezz�k
	cmp eredmeny[0],0 ;ha nem volt a v�g�n marad�k, akkor az  eredm�ny els� b�jtja, nulla maradt, de ez nem j�, ekkor  helyette ki kell �rni egy sz�k�zt
	jne cik2
	mov ah,2
	mov dl,' ' ;itt �runk helyette egy sz�k�zt
	int 21h
	inc si ;�s si eggyel nagyobb, mert az els� sz�mjegyet  akkor m�r nem kell n�zni, hisz most �rtuk ki
	
cik2:
	mov ah,2 ;ki�rjuk a sz�mjegyet
	mov dl,eredmeny[si]
	add dl,30h ;ASCII az�rt kell +30h
	int 21h
	inc si
	cmp si,szamjegy ;m�r ki�rtuk az �sszeset?
	jbe cik2

	kiir text3 ;ez m�r a v�ge
	
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy kar.-ra echo n�lk�l
	int 21h
	
	mov ah,4ch ;a vez�rl�s visszaad�sa az op.-nek
	int 21h
	
code ends ;code nev� szegmens v�ge
	end start ;a start cimk�n�l kezd�nk