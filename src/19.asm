;Program 19

;�rjon programot, amely az aktu�lis mapp�ban l�trehoz egy mapp�t a bill. megadott n�vvel, �s az aktu�lis k�nyvt�rr� teszi. 

code segment ;szegmens nyit�sa
	assume cs:code,ds:code ;hozz�rendel�s a k�d ill. adatszeg.hez

;v�ltoz�k l�trehoz�sa
text1 db 'Almappa neve (max 8 karakter): $'
hibauz1 db 13,10,'Hiba: az ut nem talalhato!$'
hibauz2 db 13,10,'Hiba: az eleres nincs engedelyezve!$'
hibauz3 db 13,10,'Hiba: nem adtal meg eleresi utat!',13,10,36
hibauz4 db 13,10,'Hiba: ismeretlen!$'
buffer db 9,0,9 dup(0)

start:	
	mov ax,cs ;be�ll�tjuk az adatszegmens-t
	mov ds,ax
	cld ;0-ba �ll�tjuk a DF-et, a sz�vegki�r�shoz

cik1:	
	mov ah,09h ;ki�rjuk a text1-et
	mov dx,offset text1 
	int 21h

	mov ah,0ch ;billenty�zetbuffer t�rl�se
	mov al,0ah ;mappan�v beolvas�sa a bufferba
	mov dx,offset buffer
	int 21h
	
	cmp buffer[1],0 ;megn�zz�k, hogy van-e beolvasott karakter
	jnz tovabb ;ha van tov�bbmegy�nk

	mov ah,9 ;ha nincs hiba�zi
	mov dx,offset hibauz3
	int 21h
	jmp cik1 ;�s vissza az elej�re
	
tovabb:  
	xor dh,dh ; dh t�rl�se
	mov dl,buffer[1] ;beolvasott karakterek sz�m�nak bevitele a dl-be
	mov di,dx ;ezt �tvissz�k a di-be
	mov buffer[di+2],0 ;a v�g�re tesz�nk egy 0-�t

	mov ah,39h ;l�trehozom az alk�nyvt�rat
	mov dx,offset buffer
	add dx,2 ;ez az�rt kell, hogy a buffer els� k�t b�jtj�t �tugorjuk
	int 21h
	jc hiba ;ha hiba t�rt�nt ugrunk
	
	mov ah,3bh ;aktu�liss� tessz�k a l�trehozott alk�nyvt�rat
	mov dx,offset buffer
	add dx,2 ;ugyanaz mint el�bb
	int 21h
	jc hiba ;ugrunk, ha hiba t�rt�nt

	jmp vege ;�tugorjuk a hiba�ziket

hiba:		
	cmp ax,3 ;megn�zz�k, melyik �hiba� t�rt�nt
	jz hiba1
	cmp ax,5
	jz hiba2

	mov ah,09h ;nem tudjuk pontosan, ki�rjuk, hogy ismeretlen
	mov dx,offset hibauz4
	int 21h

	jmp vege ;ugrunk a v�g�re

hiba1:  
	mov ah,09h ;hiba�zi ki�r�sa
	mov dx,offset hibauz1
	int 21h
	jmp vege

hiba2:   
	mov ah,09h ;hiba�zi ki�r�sa
	mov dx,offset hibauz2
	int 21h

vege:		
	mov ah,4ch ;befejezz�k a programot
	int 21h

code ends ;lez�rjuk a code nev� szegmenst
	end start ;start cimk�n�l kezd�nk