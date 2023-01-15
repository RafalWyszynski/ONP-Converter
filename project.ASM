;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
;KRÓTKI OPIS NAJCIEKAWSZYCH FUNKCJI:
;> Program wy³apuje 8 ró¿nych rodzajów b³edow w równaniu zanim przyst¹pi do konwersji. Odró¿nia je i wyœwietla w postaci komunikatu na konsole.
;> Posiada procedury delay oraz delay2, pozwalaj¹ce na czytelniejszcze wyœwietlanie komunikatów i imitacjê "myœlenia" komputera.
;> Jeœli ktoraœ wprowadzona liczba przekracza maksymaln¹ wartoœæ 16 bitow¹, program wy³apuje to i informuje u¿ytkownika.
;> Jeœli podczas obliczeñ na którymœ etapie liczba przekroczy maksymaln¹ wartoœæ 16 bitow¹, program wy³apuje to i informuje u¿ytkownika.
;> Program pozwala na zaczêcie zamiany od pocz¹tku, dziêki dwum buforom czyszcz¹cym kolejki wejœcia i wyjœcia.
;> Jeœli w wyniku obliczeñ otrzymamy wynik ujemny, program potrafi go wyœwietliæ.
;> Posiada procedurê usSpacje, która przed przyst¹pieniem do konwersji usuwa z równania wszystkie spacje
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
org 100h

	start:
	FINIT
		
		call menu

		procedura:
			call ent
			call rownanie

			call sprawdz

			call ent
			call delay
			call TakOrNie
			cmp word [warunek],1
			je procedura

	koniec:

	mov	ax, 4C00h
	int	21h

ent:

	pusha
	pushf
		mov ah,2
		mov dl,10
		int 21h
		
		mov dl,13
		int 21h
	popf
	popa
ret

spacja:

	pusha
	pushf
		mov ah,2
		mov dl,32
		int 21h
	popf
	popa
ret

rownanie:

	pusha
	pushf
		mov ah,9
		mov dx,wprWej
		int 21h
		mov ah,10
		mov dx,wejscie
		int 21h
	popf
	popa
ret


;//////////////////////////////////////////////////CZÊŒÆ SPRAWDZAJ¥CA POPRAWNOŒÆ I KONWERTUJ¥CA RÓWNANIE\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

sprawdz: ;PROCEDURA SPRAWDZAJ¥CA CZY RÓWNANIE JEST PRAWID£OWE

	pusha
	pushf
	   
	    call usSpacje
	    call StLubKn
		cmp word [warunek],1
		je blStvKn
		
		xor ax,ax
		xor cx,cx
		mov bx,2
		mov cl, byte [wejscie+1]

		cmp cl,0
		je koncze

		xor dx,dx

		petla:

			mov al,[wejscie+bx]

			cmp al,48
			jb czyZnaki

			cmp al,57
			ja czyZnaki

			jmp kont ;JEST CYRF¥, WIÊC WSZYSTKO SIÊ ZGADZA

			czyZnaki:

				cmp al,40
				je otw

				cmp al,41
				je zamk

				cmp al,42
				je sprMn

				cmp al,43
				je sprMn

				cmp al,45
				je sprMn

				cmp al,47
				je sprMn

				jmp zlyZnak ;WSKAZUJEMY NA Z£Y ZNAK, WIÊC KOÑCZYMY PROGRAM

					sprMn:

						cmp bx,2
						je kont

						call jakiMnZn

						cmp word [warunek],1
						je dwaOpy

						jmp kont

			otw: ;LICZY ILOŒÆ OTWARTYCH NAWIASÓW

				cmp bx,2
				je sprOtw

				call sprOtwZL ;Czy po lewej jest operator lub otwarcie nawiasu?

				cmp word [warunek],1
				je blOtwZL

				cmp cx,1
				je sprOtw

				call sprOtwZP ;Czy po prawej jest liczba, zamkniecie lub otwarcie nawiasu?

				cmp word [warunek],1
				je blOtwZP

			sprOtw:

				inc dl

				jmp kont

			zamk: ;JESLI ZOSTANIE ZAMKNIÊTY NAWIAS KTÓREGO NIE OTWORZONO, PROGRAM ZAKOÑCZY DZIA£ANIE

				call sprZamZL ;Czy po lewej jest liczba, zamkniecie lub otwarcie nawiasu?

				cmp word [warunek],1
				je blZamZL

				cmp cx,1
				je sprZam

				call sprZamZP ;Czy po prawej jest operator lub zamkniecie nawiasu?

				cmp word [warunek],1
				je blZamZP

			sprZam:

				dec dl

				cmp dl,0
				js zlee

				jmp kont

			kont:

				inc bx
				dec cx
				jz poPetli

			jmp petla

;////////////////////////////////////////////////// TUTAJ SKACZEMY W RAZIE B£ÊDÓW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

			zlee:  ;WYŒWIETLA KOMUNIKAT O B£ÊDZIE W NAWIASACH

				mov ah,9
				mov dx,zle
				int 21h

			jmp koncze

			zlyZnak: ;WYŒWIETLA KOMUNIKAT O B£ÊDNYM ZNAKU W RÓWNANIU

				mov ah,9
				mov dx,zly
				int 21h

			jmp koncze

			dwaOpy: ;WYŒWIETLA KOMUNIKAT O DWÓCH OPERATORACH W RÓWNANIU PO SOBIE

				mov ah,9
				mov dx,dwaOper
				int 21h

			jmp koncze

			blOtwZL:

				mov ah,9
				mov dx,blOtwL
				int 21h

			jmp koncze

			blOtwZP:

				mov ah,9
				mov dx,blOtwP
				int 21h

			jmp koncze

			blZamZL:

				mov ah,9
				mov dx,blZamL
				int 21h

			jmp koncze

			blZamZP:

				mov ah,9
				mov dx,blZamP
				int 21h

			jmp koncze

			blStvKn:

				mov ah,9
				mov dx,PocLubKn
				int 21h

			jmp koncze

;////////////////////////////////////////////////////////// KONIEC B£ÊDÓW \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


		poPetli: ;JEŒLI NIE ZAMKNIÊTO WSZYSTKICH NAWIASÓW, PROGRAM ZAKOÑCZY DZIA£ANIE. W PRZECIWNYM RAZIE ZAMIENIA DZIA£ANIE NA ONP

			cmp dl,0
			jne zlee

			mov ah,9
			mov dx,konw
			int 21h
			call opznia
			call zamien  ;WYWO£ANIE PROCEDURY ZAMIENIAJ¥CEJ NA POSTAÆ ONP

			call delay
			mov ah,9
			mov dx,obli
			int 21h
			call opznia
			call oblicz ;WYWO£ANIE PROCEDURY OBLICZAJ¥CEJ RÓWNANIE

		jmp koncze

	koncze:
	popf
	popa
ret

zamien: ;PROCEDURA ZAMIENIAJ¥CA POSTAÆ RÓWNANIA NA ONP

	pusha
	pushf
		xor ax,ax
		xor cx,cx
		xor dx,dx
		mov dl,2
		mov bx,2
		mov bp,sp

		petla2: ;SPRAWDZAMY NA JAKI ZNAK WSKAZUJEMY

			mov al,[wejscie+bx]

			cmp al,48
			jb czyOtw

			cmp al,57
			ja czyOtw

			call doWyjscia ;JEŒLI DOSZ£O DO TEGO MIEJSCA TO WSKAZUJEMY NA CYFRÊ, WIÊC DODAJEMY J¥ DO WYJŒCIA
			inc dl
			jmp kont2

			czyOtw: ;SPRAWDZAMY CZY WSKAZUJEMY NA OTWARCIE NAWIASU, JEŒLI TAK, WRZUCAMY JE NA STOS

				cmp al,40
				jne czyZam

				push ax
			jmp kont2

			czyZam: ;SPRAWDZAMY CZY WSKAZUJEMY NA ZAMKNIECIE NAWIASU, JEŒLI TAK, TO ZDEJMUJEMY ZE STOSU A¯ ZNAJDZIEMY OTWARCIE NAWIASU	
			
				cmp al,41
				jne czyOpr

					doWyjsc:

						pop word [temp]

						cmp word [temp],40
						je kont2

						push ax
						mov ax,word [temp]

						call spDoWyjscia
						inc dl

						call doWyjscia
						inc dl

						pop ax
					jmp doWyjsc

			czyOpr: ;SPRAWDZAMY CZY WSKAZUJEMY NA KTÓRYŒ Z OPERATORÓW

				call spDoWyjscia
				inc dl

				call prioSet

				mov word [temp],ax
				mov cx, word [prior]

				czyPust: ;SPRAWDZAMY, CZY STOS JEST PUSTY

					cmp bp,sp
					jne czyOprA

					push word [temp]
				jmp kont2

				czyOprA: ;SPRAWDZAMY, CZY OPERATOR MA WIEKSZY PRIORYTET NIZ PRIORYTET NA WIERZCHOLKU STOSU

					pop ax

					call prioSet

					cmp cx, word [prior]
					jbe czyOprBE

					push ax
					push word [temp]
				jmp kont2

				czyOprBE: ;SPRAWDZAMY, CZY OPERATOR MA PRIORYTET RÓWNY LUB MNIEJSZY NIZ PRIORYTET NA WIERZCHOLKU STOSU

					call doWyjscia
					inc dl		

					call spDoWyjscia
					inc dl

				jmp czyPust

			kont2:

				inc bx
				inc dh

				cmp dh, byte [wejscie+1]
				jne petla2
			jmp wypStos

		wypStos:

			cmp bp,sp
			je wyswietl

			pop ax

			call spDoWyjscia
			inc dl

			call doWyjscia
			inc dl			
		jmp wypStos
				

		wyswietl:

			call wysWyj
		jmp koniec2
			
	koniec2:	
	popf
	popa
ret

doWyjscia:

	pusha
	pushf
		mov bl,dl
		mov [wyjscie+bx],al
	popf
	popa
ret


prioSet:

	pusha
	pushf
		czyznak:
			cmp al,40
			je otNaw

			cmp al,41
			je zamNaw

			cmp al,42
			je mno

			cmp al,43
			je dod

			cmp al,45
			je ode

			cmp al,47
			je dzi

			mov word [prior], -1  ;ODRÓ¯NIAMY, JEŒLI NIE JEST INTERESUJ¥CYM NAS ZNAKIEM
			jmp prioEnd

		otNaw:

			mov word [prior], 0
			jmp prioEnd

		zamNaw:

			mov word [prior], 1
			jmp prioEnd

		dod:

			mov word [prior], 1
			jmp prioEnd

		ode:

			mov word [prior], 1
			jmp prioEnd

		mno:

			mov word [prior], 2
			jmp prioEnd

		dzi:

			mov word [prior], 2
			jmp prioEnd

		pot:
			mov word [prior], 3
			jmp prioEnd

	prioEnd:
	popf
	popa
ret

spDoWyjscia:

	pusha
	pushf 
		mov bl,dl
		mov al,32
		mov [wyjscie+bx],al
	popf
	popa
ret

wysWyj:

	pusha
	pushf
		mov ah,9
		mov dx,otrWyj
		int 21h
		mov ah,9
		mov dx,wyjscie+2
		int 21h
	popf
	popa
ret

jakiMnZn:

	pusha
	pushf
		mov al,[wejscie+bx-1]

		cmp al,48
		jb czyZnak

		cmp al,57
		ja czyZnak

		jmp endJMZ ;JEST CYRF¥, WIÊC WSZYSTKO SIÊ ZGADZA

		czyZnak:
			cmp al,42
			je jestOper

			cmp al,43
			je jestOper

			cmp al,45
			je jestOper

			cmp al,47
			je jestOper

			mov word [warunek],0
		jmp endJMZ

		jestOper:
			mov word [warunek],1
		jmp endJMZ

	endJMZ:
	popf
	popa
ret
		
sprOtwZL:

	pusha
	pushf
		mov al, [wejscie+bx-1]

			cmp al,40
			je sprOtwD

			cmp al,42
			je sprOtwD

			cmp al,43
			je sprOtwD

			cmp al,45
			je sprOtwD

			cmp al,47
			je sprOtwD

			mov word [warunek],1
		jmp endSprOt

			sprOtwD:

				mov word [warunek],0
			jmp endSprOt

	endSprOt:
	popf
	popa
ret

sprOtwZP:

	pusha
	pushf
		mov al, [wejscie+bx+1]

			cmp al,48
			jb zmLubOt

			cmp al,57
			ja sprOtwZ

		jmp sprOtwTD

		zmLubOt:

			cmp al,40
			je sprOtwTD

			cmp al,41
			je sprOtwTD

		jmp sprOtwZ

		sprOtwTD:

			mov word [warunek],0
		jmp endSprOP

			sprOtwZ:
				mov word [warunek],1
			jmp endSprOP

	endSprOP:
	popf
	popa
ret

sprZamZL:

	pusha
	pushf
		mov al, [wejscie+bx-1]

			cmp al,48
			jb zmLubOt2

			cmp al,57
			ja sprOtwZ2

		jmp sprOtwTD2

		zmLubOt2:

			cmp al,40
			je sprOtwTD2

			cmp al,41
			je sprOtwTD2

		jmp sprOtwZ2

		sprOtwTD2:

			mov word [warunek],0
		jmp endSprOP2

			sprOtwZ2:

				mov word [warunek],1
			jmp endSprOP2

	endSprOP2:
	popf
	popa
ret

sprZamZP:

	pusha
	pushf

		mov al, [wejscie+bx+1]

			cmp al,41
			je sprZamD

			cmp al,42
			je sprZamD

			cmp al,43
			je sprZamD

			cmp al,45
			je sprZamD

			cmp al,47
			je sprZamD

			mov word [warunek],1
		jmp endSprZm

			sprZamD:
				mov word [warunek],0
			jmp endSprZm

	endSprZm:
	popf
	popa
ret

StLubKn:

	pusha
	pushf

		xor bx,bx
		mov bl,[wejscie+1]
		add bl,1
		mov al,[wejscie+2]

			cmp al,42
			je StvKnSp

			cmp al,43
			je StvKnSp

			cmp al,45
			je StvKnSp

			cmp al,47
			je StvKnSp

		mov al,[wejscie+bx]

			cmp al,42
			je StvKnSp

			cmp al,43
			je StvKnSp

			cmp al,45
			je StvKnSp

			cmp al,47
			je StvKnSp

			mov word [warunek],0
		jmp ExitStvK

			StvKnSp:
				mov word [warunek],1
			jmp ExitStvK

	ExitStvK:
	popf
	popa
ret

;///////////////////////////////////////////////////////////////////CZÊŒÆ OBLICZENIOWA\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

oblicz:
	pusha
	pushf
		
		xor ax,ax
		xor dx,dx
		xor cx,cx
		mov bx,2

		PetlaObl:
				mov al,[wyjscie+bx]

				cmp al,36
				je PoPetObl

				cmp al,32
				je poSpraw

				cmp al,48
				jb jakiZn
						
				cmp al,57
				ja jakiZn

		
				sub al,48
				coDalej: ;SPRAWDZÊ CO JEST NA KOLEJNYM ZNAKU - JEŒLI SPACJA LUB KONIEC, TO WRZUCAM LICZBÊ NA STOS
					cmp bx,55
					je naStos

					mov cl,[wyjscie+bx+1]
					xor ch,ch

					cmp cl,36
					je naStos

					cmp cl,32
					je naStos
			
					sub cl,48

					push cx
						mov cl,10
						mul cx
					pop cx
						cmp ax, word [max]
						ja zaDuza

					add ax,cx

						cmp ax, word [max]
						ja zaDuza

					inc bx
						jmp coDalej

					naStos:
						cmp ax, word [max]
						ja zaDuza
						mov [temp],ax
						fild word [temp]
						xor ah,ah
						jmp poSpraw

				jakiZn:
					cmp al,42
					je mnoz

					cmp al,43
					je dodaj

					cmp al,45
					je odejmij

					cmp al,47
					je dziel

					mnoz:
						FMULP
						push ax	
							ficom word [max]   
							fstsw ax   
							sahf    
						pop ax
						ja zaDuza
						jmp poSpraw

					dodaj:
						FADDP
						push ax
							ficom word [max] 
							fstsw ax   
							sahf    
						pop ax
						ja zaDuza
						jmp poSpraw

					odejmij:
						FSUBP
						push ax
							ficom word [min] 
							fstsw ax   
							sahf    
						pop ax
						jb zaDuza
						jmp poSpraw

					dziel:
						push ax
							ficom word [zero]      
							fstsw ax   
							sahf    
						pop ax
						jz divZero
						FDIVP
						jmp poSpraw

					;poteguj:
						jmp poSpraw

				poSpraw:
					inc bx
					jmp PetlaObl

			PoPetObl:
				fist word [temp]
				cmp word [temp], 0
				js zmien
				jmp zostaw

				zmien:
					mov ah,9
					mov dx,otrWyn
					int 21h
					mov ah,2
					mov dl,45
					int 21h
					neg word [temp]
					call wyswietla
					jmp endOblicz
				zostaw:
					mov ah,9
					mov dx,otrWyn
					int 21h
					call wyswietla
					jmp endOblicz
			
			zaDuza:
				mov ah,9
				mov dx,zaDuzaL
				int 21h
				jmp endOblicz
			divZero:
				mov ah,9
				mov dx,divZer
				int 21h
				jmp endOblicz
		
		endOblicz:
		popf
		popa
	ret

wyswietla:
	pusha                   
	pushf         
		mov ax,[temp] 
		mov bx,10         
		xor dx,dx
		xor cl,cl  ;65 536 

		dziele:
		inc cl							 
		div bx       	
		push dx 
		xor dx,dx
		cmp ax,0
		je wypisz
			jmp dziele

		wypisz:      
		pop dx             
		xor dh,dh         
		add dl,48          
		mov ah,2           
		int 21h            
		dec cl			   
		cmp cl,0
		je koncz2
			jmp wypisz

	koncz2:
	popf
	popa
ret

TakOrNie:

	pusha
	pushf
		checkCzy:
			mov ah,9
			mov dx,czyChce
			int 21h
			call delay
			mov ah,9
			mov dx,czyChce1
			int 21h
			call delay
			mov ah,9
			mov dx,czyChce2
			int 21h
			call delay

			call ent
			mov ah,1
			int 21h

			cmp al,49
			je takChce

			cmp al,50
			je nieChce

			mov ah,9
			mov dx,czyChce3
			int 21h
			jmp checkCzy

		takChce:
			mov word [warunek],1
			call czyscNap
			jmp endCzy

		nieChce:
			mov word [warunek],0
			jmp endCzy

	endCzy:
	popf
	popa
ret

czyscNap:
	pusha
	pushf
		mov word [wejscie+1], 0
		mov cx,26
		mov si,bufor1
		mov di,wejscie+2
		cld
		rep movsb

		mov cx,52
		mov si,bufor2
		mov di,wyjscie+2
		cld
		rep movsb

		mov cx,26
		mov si,bufor3
		mov di,wejscie2+2
		cld
		rep movsb
		cmp word [warunek],0
	popf
	popa
ret

delay:
	pusha
	pushf
		xor cx,cx
		xor dx,dx
		mov ah,86h
		mov cx,10
		int 15h
	popf
	popa
ret

delay2:
	pusha
	pushf
		xor cx,cx
		xor dx,dx
		mov ah,86h
		mov cx,15
		int 15h
	popf
	popa
ret

menu:
	pusha
	pushf
		mov ah,9
		mov dx,menu1
		int 21h
		call delay2
		mov dx,menu2
		int 21h
		call delay2
		mov dx,menu3
		int 21h
		call delay2
		mov dx,menu4
		int 21h
		call delay2
	popf
	popa
ret

opznia:
	pusha
	pushf
		call delay
		mov ah,2
		mov dl,32
		int 21h
		mov dl,46
		int 21h
		call delay
		mov dl,32
		int 21h
		mov dl,46
		int 21h
		call delay
		mov dl,32
		int 21h
		mov dl,46
		int 21h
		call delay
	popf
	popa
	ret

usSpacje:
	pusha
	pushf
		xor cx,cx
		xor dx,dx
		mov si,2
		mov bx,2
		mov cl,[wejscie+1]
		usunLoop:
			cmp dl,cl
			ja wyjdzUs
			mov al,[wejscie+bx]
			inc bx
			inc dl
			cmp al,32
			je usunLoop
			mov [wejscie2+si],al
			inc si
			jmp usunLoop
		wyjdzUs:
		mov ax,si
		dec ax
		dec ax
		dec ax
		xor ah,ah
		mov byte [wejscie+1], al
		mov cx,26
		mov si,bufor1
		mov di,wejscie+2
		cld
		rep movsb

		mov cx,ax
		mov si,wejscie2+2
		mov di,wejscie+2
		cld
		rep movsb
	popf
	popa
ret
		

;///////////////////////////////////////////////////////////////////ZMIENNE I KOMUNIKATY\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

warunek dw 0
temp dw 0
prior dw 0
zero dw 0
max dw 32767
min dw -32768
wejscie db 26
	 db 0
	 times 27 db "$"
wejscie2 db 26
	 db 26
	 times 27 db "$$$$$$$$$$$$$$$$$$$$$$$$$$"
wyjscie db 52
	 db 52
	 times 53 db "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
wprWej db 10,13, "> Wprowadz rownanie wejsciowe: $"
otrWyj: db 10,13, "> Rownanie w ONP: $"
otrWyn: db 10,13, "> Otrzymany wynik: $"
zle db 10,13, "[BLAD] Popelniono blad w nawiasach!$"
zly db 10,13, "[BLAD] Wprowadzono bledny znak!$"
dwaOper db 10,13, "[BLAD] Napisano po sobie dwa operatory!$"
blOtwL db 10,13, "[BLAD] Po lewej stronie otwarcia nawiasu moze znajdowac sie tylko operator lub otwarcie nawiasu!$"
blOtwP db 10,13, "[BLAD] Po prawej stronie otwarcia nawiasu moze znajdowac sie tylko liczba, zamkniecie nawiasu lub otwarcie nawiasu!$"
blZamP db 10,13, "[BLAD] Po prawej stronie zamkniecia nawiasu moze znajdowac sie tylko operator lub zamkniecie nawiasu!$"
blZamL db 10,13, "[BLAD] Po lewej stronie zamkniecia nawiasu moze znajdowac sie tylko liczba, zamkniecie nawiasu lub otwarcie nawiasu!$"
PocLubKn db 10,13, "[BLAD] Zaczeto lub zakonczono program operatorem!$"
divZer db 10,13, "[BLAD] Nie mozna dzielic przez zero!$"
zaDuzaL db 10,13, "[BLAD] Wynik przekroczyl max. 16 bitowa wartosc ze znakiem! (-32768, 32767)$"
bufor1 times 26 db 36
bufor2 times 52 db 36
bufor3 times 26 db 36
czyChce db 10,13, "Czy chcesz przekonwertowac kolejne rownanie?$"
czyChce1 db 10,13, "[1] Tak.$"
czyChce2 db 10,13, "[2] Nie.$"
czyChce3 db 10,13, "[BLAD] Nacisnij [1] lub [2]!$"
menu1 db 10,13, "Witaj w krotkim programie konwertujacym rownania do ONP. Oto kilka zasad:$"
menu2 db 10,13, "- Program dziala w zakresie (-32768, 32767), nie przekrocz 16 bitow!$"
menu3 db 10,13, "- Wpisuj rownania poprawne matematycznie, program znajdzie twoj blad!$"
menu4 db 10,13, "- Program dziala dla 4 podstawowych operacji: '+', '-', '*', '/' !$"
konw db 10,13, "Konwertowanie$"
obli db 10,13, "Obliczanie$"