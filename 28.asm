;Program 28

;�rjon programot, amely ki�rja az aktu�lis mapp�b�l azokat az �llom�nyokat, amelyek m�rete nagyobb mint a bill. megadott �rt�k.

code segment ;code nev� szegmens l�trehoz�sa
	assume cs:code,ds:code ;hozz�rendel�s

;v�ltoz�j
dta db 128 dup(0) ;dta t�rol�s�ra
path db '*.*',0 ;el�r�si �t az akt. mappa, minden f�jlja
newline db 13,10,36 ;�j sor �r�s�ra
text1 db 'Fajlok listazasa, amelyek nagyobbak mint (bajtokban, max. 4 GB): $'
text2 db 13,10,'Press any key to continue...$'
hibauz1 db 13,10,'Nem talalhato fajl!$'
buffer db 11,0,11 dup(0) ;a sz�m beolvas�sa
meret_al dw ? ;meret alacsonyabb b�jt
meret_mag dw ? ;meret magasabb b�jt
flag db 0 ;volt f�jl?

;macro text ki�r�s�ra
kiir macro text
	mov ah,9
	mov dx,offset text
	int 21h
	endm ;macro v�ge
	
;macro sz�veg beolvas�s�ra
beolvas macro hova
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,0ah
	mov dx,offset hova
	int 21h
	endm
	
;proc. 32 bites bin�ris sz�mm� val� alak�t�sra ASCIIk�db�l
;nem magyar�zom, ezt nem vett�k
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
longmul endp ;proc. v�ge

;f�program
start:
	mov ax,cs ;adatszegmens kezd�c�m�nek be�ll�t�sa
	mov ds,ax
	cld ;df null�z�sa
	
	kiir text1 ;text1 ki�r�sa
	beolvas buffer ;a sz�m beolvas�sa
	mov si,offset [buffer+2]
	call asciibin_32 ;�talak�t�sa bin�rissa
	mov meret_al,ax ;�s elment�se
	mov meret_mag,dx
	
	mov ah,1ah ;dta kezd�c�m�nek be�ll�t�sa
	mov dx,offset dta
	int 21h
	
	mov ah,4eh ;els� f�jl keres�se
	mov dx,offset path ;a path �ltal adott mapp�ban
	mov cx,0 ;normal f�jlokat keress
	int 21h
	jnc tovabb ;ha nincs hiba, vagyis tal�lt�l, akkor tov�bb
	
	jmp vege ;ha hiba akkor ugrunk a v�g�re

tovabb:	
	mov si,1ch ;megn�zz�k a f�jlm�retet
	mov ax,word ptr dta[si] ;el�sz�r a magasabb b�jtot
	cmp ax,meret_mag ;ha ez kisebb akkor az nem j�, k�vetkez�
	jb kov
	mov ax,word ptr dta[si-2] ;alacsonyabb b�jt
	cmp ax,meret_al ;ha ez kisebb vagy egyenl� akkor nem j� 
	jbe kov ;�s j�het a k�vetkez�

	kiir newline ;�j sor �r�sa
	mov si,1eh ;innen kezd�dik a f�jln�v

cik1: 
	mov ah,2 ;egy kar. ki�r�sa
	mov dl,byte ptr dta[si] ;ezen kar. ki�r�sa
	int 21h ;tedd meg!
	inc si ;k�v. karra mutass
	cmp byte ptr dta[si],0 ;az nulla?
	jnz cik1 ;ha m�g nem akkor ism�telj
	mov flag,1 ;egy f�jln�v m�r biztos ki volt �rva, ez�rt  flag egyesbe

kov:
	mov ah,4fh ;k�v. f�jl keres�se
	int 21h
	jnc tovabb ;ha cf=0, m�r nincs f�jl
	
vege:
	cmp flag,0 ;flag=0?
	jne abort ;ha nem, akkor v�ge
	kiir hibauz1 ;ha igen ki�runk egy hiba�zit, hogy nem volt  f�jl 
	
abort:
	kiir text2 ;v�r�s egy bill.-re sz�veg
	mov ah,0ch ;bill. buffer t�rl�se
	mov al,7 ;v�r�s egy bill.-re
	int 21h

	mov ah,4ch ;vez�rl�s vissza az op.-nek
	int 21h

code ends ;code nev� szegmens v�ge
	end start ;start cimk�n�l kezd�nk