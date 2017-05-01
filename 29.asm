;Program 29

;Írjon programot, amely bekér a bill. 3 kétjegyû egész számot, és ezeket megjeleníti a képernyõn a legnagyobbtól a legkisebbig.

code segment ;code nevû szegmens létrehozása
  assume cs:code,ds:code ;hozzárendelés

;long szó jelentse azt, hogy 3, ez jelzi a beolvasandó számok   számát, ha itt átírjuk, akkor mindenhol átíródik a  programban, ha mondjuk 10 számot akarnánk bekérni, itt elég  lenne átírni, és a program automatikusan 10 számot kérne be, és rendezne
long EQU 3

;változók
text1 db 'Legnagyobbtol a legkisebbig'
      db 13,10,'***************************'
      db 13,10,'Adj meg $'
text11 db ' szamot!',13,10,36
text2 db '. szam: $'
text3 db 13,10,13,10,'A szamok rendezve:',13,10,36
text4 db 13,10,13,10,'Nyomj le egy billentyut a kilepeshez...$'
hibauz1 db 13,10,'A megadhato legkisebb szam a 10, a legnagyobb a 99!$'
newline db 13,10,36 ;új sor írásához
buffer_key db 3,0,3 dup(0)
buffer_sort db long dup(0)
szemafor db ?
index dw ? ;a buffer_sort indexeléséhez

;macro string kiírására
kiir macro text
  mov ah,9
  mov dx,offset text
  int 21h
  endm ;macro vége

;macro egy karakter kiírására
putchar macro char
  mov ah,2
  mov dl,char
  int 21h
  endm ;macro vége

;procedúra bináris szám kiírására
binascii proc near ;bemenet ax
  mov szemafor,0 ;szemafor nullázása
  cmp ax,0 ;ax=0?
  jne gop21 ;ha nem akkor megyünk tovább
  putchar '0' ;ha ige, akkor kirakunk egy nullát
  jmp vegep2 ;és megyünk a végére

gop21:
  mov bx,10000 ;10000-rel fogunk osztani
  xor dx,dx ;az osztás elõtt nullázni kell a dx-et

cikp21:
  div bx ;osztjuk az ax-et bx-el
  mov si,dx ;a maradék az si-be
  cmp ax,0 ;ax=0?
  jne gop22 ;ha nem akkor gop22-re
  cmp szemafor,0 ;ha igen, akkor szemafor=0?
  je gop23 ;ha igen, ugrunk a gop23-ra

gop22:
  add al,30h ;al-hez adjunk hozzá 30h, ASCII!
  putchar al ;kitesszük a képernyõre
  mov szemafor,1 ;már itt biztos volt kiírva karakter, ezért  szemafor egyesbe

gop23:
  mov ax,bx ;az osztót osztani kell 10-el
  mov bx,10 ;10-el
  xor dx,dx ;dx nullázása, mint fent
  div bx ;kinullazza a dx-et, osztjuk az ax-et
  cmp ax,1 ;megnézzük ax=1?
  jb vegep2 ;ha kisebb mint 1, akkor vége
  mov bx,ax ;ha nem, bx-be vissza az osztót
  mov ax,si ;ax-be vissza a maradékot
  jmp cikp21 ;vissza az elejére

vegep2:
  ret ;visszatérünk a fõprogramba
binascii endp ;proc. vége

;ASCII karaktereket alakít számmá
asciibin proc near ;bemenet si - mutato buffer+1
                   ;kimenet ax - bin ertek
  mov cl,byte ptr[si] ;bevisszük a cl-be a beolvasott  karakterek számát
  xor ax,ax ;ax-et nullázzuk
  cmp cl,0 ;megnézzük volt-e beolvasott karakter
  ja gop31 ;ha igen, akkor tovább
  jmp vegep3 ;ha nem akkor vége

gop31:
  mov bx,10 ;10-el fogunk szorozni

cikp31:
  mul bx ;dx nullázva, szorozzuk az ax-et bx-el
  inc si ;si köv. elemre mutasson
  mov dl,byte ptr[si] ;bevisszük dl-be a karaktert
  sub dl,30h ;levonunk belõle 30h, lásd ASCII!
  add ax,dx ;hozzáadjuk az ax-hez a számjegyet
  dec cl ;cl-1
  jnz cikp31 ;addig míg cl!=0 vissza az elejére

vegep3:
  ret ;visszatérés a fõprogramba
asciibin endp ;proc. vége

;ez a lényeg, a rendezõ algoritmus
;bubblesort-ot használjuk, mivel kevés az elemszám
bubblesort proc near ;bemenet si - mutato a rendezendo tomb  elso elemere, long a tomb hossza
  jmp startp5 ;átugorjuk a változókat

;változók
p db ? ;egy szemafor, hogy tudjuk volt csere
buf dw ? ;buffer, amibe elmentjük az si kezdeti értékét

startp5:
  mov buf,si ;elõbb mondtam, itt mentjük el
  mov dl,long ;dl-be azt, hogy mennyi bájtot kell rendezni

gop51:
  mov p,0 ;p-t nullázzuk
  mov si,buf ;si-be a kezdeti értékét
  dec dl ;dl-be eggyel kevesebbet
  jz vegep5 ;ha dl=0 akkor vége

  mov cl,dl ;cl-be dl-t

atnezes:
  mov al,byte ptr[si] ;bevisszük al-be, a buffer si-edik  bájtját
  cmp al,byte ptr[si+1] ;megnézzük hogyan viszonyul ez az  elem a következõvel
  jae gop52 ;LÉNYEGES RÉSZ! Ha nagyobb vagy egyenlõ akkor  ugrunk, ha ezt átírjuk jbe gop52-re akkor legkisebbtõl  legnagyobbig rendez

  xchg al,byte ptr[si+1] ;felcseréljük a két elemet
  mov byte ptr[si],al
  mov p,1 ;és p-t egyesbe állítjuk

gop52:
  inc si ;si köv. elemre mutasson
  dec cl ;cl eggyel kevesebb
  jnz atnezes ;ha cl még nem nulla, akkor vissza az elejére

  cmp p,1 ;megnézzük p=1?
  je gop51 ;ha igen, ugrunk

vegep5:
  ret ;visszatérés a fõprogramba
bubblesort endp ;proc. vége

;fõprogram
start:
  mov ax,cs ;adatszegmens kezdõcímének beállítása
  mov ds,ax

  mov ax,3 ;képernyõ törlése, 80x25-ös módba való váltással
  int 10h

  kiir text1 ;kiírjuk a text1-et
  mov ax,long ;bevisszük azt az ax-be, hogy mennyi számot  kell megadni
  call binascii ;kiírjukl ezt a számot
  kiir text11 ;itt meg a szöveg többi része

  mov index,1 ;index=1, ez egyben ciklusváltozó is

;itt olvassuk be a számokat
cik1:
  kiir newline ;írunk egy új sort
  mov ax,index ;kiírjuk, hogy hanyadik számot adjuk meg épp
  call binascii
  kiir text2 ;és kiírjuk, hogy . szám:

  mov ah,0ch ;bill. buffer törlése
  mov al,0ah ;string beolvasása
  mov dx,offset buffer_key ;a buffer_key-be
  int 21h ;csináld

  xor bx,bx ;bx nullázása

cik3:
  cmp buffer_key[bx+2],30h ;megnézzük, hogy a beolvasott két  karakter szám volt-e
  jb go1
  cmp buffer_key[bx+2],39h
  ja go1
  inc bl ;végignézzük a tömböt
  cmp bl,buffer_key[1]
  jb cik3
  jmp go2 ;ha ide eljutunk, akkor minden rendben, mehetünk  tovább

go1:
  kiir hibauz1 ;ha nem volt rendben, akkor kiírjuk, hogy  hiba
  jmp cik1 ;és bekérjük még 1x

go2:
  mov si,offset buffer_key+1 ;si-be a buffer második  bájtjára mutató mutató
  call asciibin ;csinálunk belõle számot
  cmp al,10 ;az ax-be lesz ez a szám, megnézzük nagyobb mint  10?
  jb go1 ;ha kisebb, akkor baj van, megyünk a hibára

  mov si,index ;si-be index
  mov buffer_sort[si-1],al ;elmentjük a buffer_sort-ba a  számot
  inc index ;index mutasson a buffer köv. elemére, a köv. mentéshez
  cmp index,long ;megnézzük bekértük már az összes számot?
  jbe cik1 ;ha még nem, akkor kérjük

  mov si,offset buffer_sort ;na itt rendezzük
  call bubblesort ;ez csinálja

  kiir text3 ;kiírju, hogy a tömb rendezve
  mov index,1 ;index=1

cik2:
  kiir newline ;újsor
  mov ax,index ;ax-be index
  call binascii ;kiírjuk az index-et
  kiir text2 ;kiírjuk, hogy . szám:

  xor ah,ah ;ah-t nullázzuk
  mov si,index ;si-be index
  mov al,buffer_sort[si-1] ;buffer megfelelõ bájtját al-be
  call binascii ;kiírni

  inc index ;index köv. elemre
  cmp index,long ;megnézzük kiírtuk már az összes elemet?
  jbe cik2 ;ha még nem, akkor vissza a cik2-re

  kiir text4 ;kiírjuk, hogy nyomj bármilyen bill.-t

  mov ah,0ch ;bill. buffer törlése
  mov al,7 ;várás echo nélkül egy bill. lenyomására
  int 21h

  mov ah,4ch ;a vezérlés visszaadása az op.-nek
  int 21h

code ends ;code szegmens vége
  end start ;start cimkénél kezdünk