INCLUDE Irvine32.inc
INCLUDE macros.inc

BUFFER_SIZE = 2000000                                   ; MAXIUMSIZE FILE
IMAGE_OFFSET = 54
FILTER_BUFFER_SIZE = 1250000                            ; MAXIUMSIZE FLOAT　FILTER BUFFER SIZE
FILTER_FILE_ARRAY_SIZE = 111000                         ; MAXIUMSIZE FLOAT　FILTER ARRAY SIZE 
START = 20

RGB    struct 
blue            BYTE    ?
green           BYTE    ?
red             BYTE    ?
RGB    ends

.data
    

.code
main PROC
    
	call StartFunction


    invoke ExitProcess,0 
    
main ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 開始
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StartFunction	PROC
.data
	filename        BYTE    80 DUP(?)
.code
	call	Break
    mov     dl, 0  
	mov     dh, 0
	call    Gotoxy
	call	GameName
	mov		ecx, START
	call	RepeatBlack
	mWrite  "Enter an input filename: "                 ; 輸入檔案名稱
    mov     edx,OFFSET filename
    mov     ecx,SIZEOF filename
    call    ReadString
	call    Selection
    lea     edx, filename
	.IF		al == 20
        call LutsAdjustment
	.ELSEIF al == 42
        call CallStickerFunc
	.ELSEIF al == 56
        call ForMenu
	.ELSEIF al == 72
        call CallDoubleFunc
	.ENDIF
	call	AgainOrEnd
	ret
StartFunction   ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Again
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AgainOrEnd	PROC
.data
yes BYTE 21 DUP(?)

.code
	mov  dl, 20  
	mov  dh, 32
	call Gotoxy
	mWrite  "Would you want to filter another image? (y/n)"                 
	lea     edx, yes
	mov     ecx, SIZEOF yes
	call    ReadString

    lea     edx, yes
	call    WriteString

	.IF		yes == "y"
	    call	Clrscr
	    call	StartFunction
	.ENDIF

	ret

AgainOrEnd	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; choose enlarge or shrink size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ChooseSize PROC
.data
col_size	BYTE	27
.code
	mov		dl, 20  
	mov		dh, 27
	call	Gotoxy
	mWrite  "Size:    25%    50%    75%" 

	mov		dl, col_size  
    mov		dh, 27
    call	Gotoxy

	LookForKey:
    mov		eax,50          ; sleep, to allow OS to time slice
    call	Delay           ; (otherwise, some key presses are lost)

    call	ReadKey         ; look for keyboard input
    jz		LookForKey      ; no key pressed yet

    cmp		dx,VK_ESCAPE  ; time to quit?

	.IF	dx == 0Dh
		
		.IF		col_size == 27
			mov	cl, 0
		.ELSEIF col_size == 34
			mov cl, 1
		.ELSEIF col_size == 41
			mov cl, 2
		.ENDIF

		jmp		decided

	.ELSE
		.IF dx == 25h && col_size != 27		;left
			sub		col_size, 7
		.ELSEIF dx == 27h && col_size != 41   ;right
			add		col_size, 7
		.ENDIF
	.ENDIF

	mov		dl, col_size  ;column
	mov		dh, 27
    call	Gotoxy

    jne    LookForKey    ; no, go get next key.

	;call	crlf
	;call	crlf
	decided:

	ret
ChooseSize ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 選單
; al -> get topic
; bl -> get filter
; cl -> get size
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Selection PROC

.data
col			BYTE	20
row			BYTE	13
.code
	call	Break
	mov		edx, OFFSET str6
	call	Crlf
	mWrite	"		    LUTs adjustment:	  Sticker:	Collage:	Multiple Exposure:"
	call	Crlf
	call	Crlf
	call	Break
	mWrite  "		      Blue Architecture	    Capoo	  Blur Filter	  Sunset"                 
	call	Crlf
	mWrite  "		      BlueHour		    Frame1	  Blur Frames	  Sea"                 
	call	Crlf
	mWrite  "		      ColdChrome	    Frame2	  Photo Frames	  Aurora"                 
	call	Crlf
	mWrite  "		      CrispAutumn           Flower	  Layout	  Firefly"                 
	call	Crlf	 
	mWrite  "		      DarkAndSomber	    Text	  Shrink"                
	call	Crlf
	mWrite  "		      Landscape		    Godzilla	  Enlarge"                 
	call	Crlf
	mWrite  "		      Long Beach Morning"                 
	call	Crlf
	mWrite  "		      Lush Green"                 
	call	Crlf
	mWrite  "		      MagicHour"                 
	call	Crlf
	mWrite  "		      NaturalBoost"                 
	call	Crlf
	mWrite  "		      OrangeAndBlue"                 
	call	Crlf
	mWrite  "		      SoftBlackAndWhite"                 
	call	Crlf
	mWrite  "		      Waves"                 
	call	Crlf

	mov		dl, col  
    mov		dh, row
    call Gotoxy

	LookForKey:
    mov		eax,50          ; sleep, to allow OS to time slice
    call	Delay           ; (otherwise, some key presses are lost)

    call	ReadKey         ; look for keyboard input
    jz		LookForKey      ; no key pressed yet

    ;mShow  dx,h
	;mShow  col, d

    cmp    dx,VK_ESCAPE  ; time to quit?

	.IF dx == 0Dh
		.IF row == 17 && col == 56
			call ChooseSize
		.ELSEIF row == 18 && col == 56
			call ChooseSize
		.ENDIF
		jmp decided

	.ELSE
		.IF col == 20
			.IF dx == 26h && row != 13		;top
				dec row
			.ELSEIF dx == 27h && col != 30   ;right
				mov  dl, 42  
				mov  dh, 13
				call Gotoxy
				mov  col, 42
				mov  row, 13
			.ELSEIF dx == 28h && row != 25	;bottom
				inc row
			.ENDIF

		.ELSEIF col == 42
			.IF dx == 25h			 		;left
				mov  dl, 20  
				mov  dh, 13
				call Gotoxy
				mov  col, 20
				mov  row, 13
			.ELSEIF dx == 26h && row != 13	;top
				dec row
			.ELSEIF dx == 27h && col != 30  ;right
				mov  dl, 56  
				mov  dh, 13
				call Gotoxy
				mov  col, 56
				mov  row, 13
			.ELSEIF dx == 28h && row != 18	;bottom
				inc row
			.ENDIF

		.ELSEIF col == 56
			.IF dx == 25h			 		;left
				mov  dl, 42  
				mov  dh, 13
				call Gotoxy
				mov  col, 42
				mov  row, 13
			.ELSEIF dx == 26h && row != 13	;top
				dec	 row
			.ELSEIF dx == 27h && col != 30  ;right
				mov  dl, 72  
				mov  dh, 13
				call Gotoxy
				mov  col, 72
				mov  row, 13
			.ELSEIF dx == 28h && row != 18	;bottom
				inc row
			.ENDIF

		.ELSEIF col == 72
			.IF dx == 25h			 		;left
				mov	 dl, 56
				mov  dh, 13
				call Gotoxy
				mov	 col, 56
				mov	 row, 13
			.ELSEIF dx == 26h && row != 13	;top
				dec	 row
			.ELSEIF dx == 28h && row != 16	;bottom
				inc	 row
			.ENDIF

		.ENDIF
	.ENDIF

	mov		dl, col  ;column
    mov		dh, row
    call	Gotoxy

    jne		LookForKey    ; no, go get next key.

	call	crlf
	call	crlf

	decided:

	mov		al, col
	mov		bl, row
	sub		bl, 13

	ret
Selection ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Game Name
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GameName PROC
.data
str6	 BYTE 32, 0

.code
	call	crlf
	call	crlf

	mov		edx, OFFSET str6
	mov		ecx, START
	call	RepeatBlack
	mov		ecx, 9			;f
	call	RepeatWhite
	mov		ecx, 3
	call	RepeatBlack
	mov		ecx, 9			;i
	call	RepeatWhite
	mov		ecx, 3
	call	RepeatBlack
	mov		ecx, 3			;l
	call	RepeatWhite
	mov		ecx, 9
	call	RepeatBlack
	mov		ecx, 9			;t
	call	RepeatWhite
	mov		ecx, 3
	call	RepeatBlack
	mov		ecx, 9			;e
	call	RepeatWhite
	mov		ecx, 3
	call	RepeatBlack
	mov		ecx, 8			;r
	call	RepeatWhite

	call	crlf

	mov		ecx, START
	call	RepeatBlack
	mov		ecx, 3			;f
	call	RepeatWhite
	mov		ecx, 12
	call	RepeatBlack
	mov		ecx, 3			;i
	call	RepeatWhite
	mov		ecx, 6
	call	RepeatBlack
	mov		ecx, 3			;l
	call	RepeatWhite
	mov		ecx, 12
	call	RepeatBlack
	mov		ecx, 3			;t
	call	RepeatWhite
	mov		ecx, 6
	call	RepeatBlack
	mov		ecx, 3			;e
	call	RepeatWhite
	mov		ecx, 9
	call	RepeatBlack
	mov		ecx, 3			;r
	call	RepeatWhite
	mov		ecx, 3
	call	RepeatBlack
	mov		ecx, 3			;r
	call	RepeatWhite

	call	crlf

	mov		ecx, START
	call	RepeatBlack
	mov		ecx, 7			;f
	call	RepeatWhite
	mov		ecx, 8
	call	RepeatBlack
	mov		ecx, 3			;i
	call	RepeatWhite
	mov		ecx, 6
	call	RepeatBlack
	mov		ecx, 3			;l
	call	RepeatWhite
	mov		ecx, 12
	call	RepeatBlack
	mov		ecx, 3			;t
	call	RepeatWhite
	mov		ecx, 6
	call	RepeatBlack
	mov		ecx, 7			;e
	call	RepeatWhite
	mov		ecx, 5
	call	RepeatBlack
	mov		ecx, 8			;r
	call	RepeatWhite

	call	crlf

	call	Break

	mov		ecx, START
	call	RepeatBlack
	mov		ecx, 3			;f
	call	RepeatWhite
	mov		ecx, 12
	call	RepeatBlack
	mov		ecx, 3			;i
	call	RepeatWhite
	mov		ecx, 6
	call	RepeatBlack
	mov		ecx, 3			;l
	call	RepeatWhite
	mov		ecx, 12
	call	RepeatBlack
	mov		ecx, 3			;t
	call	RepeatWhite
	mov		ecx, 6
	call	RepeatBlack
	mov		ecx, 3			;e
	call	RepeatWhite
	mov		ecx, 9
	call	RepeatBlack
	mov		ecx, 3			;r
	call	RepeatWhite
	mov		ecx, 1
	call	RepeatBlack
	mov		ecx, 3			;r
	call	RepeatWhite

	call	crlf

	mov		ecx, START
	call	RepeatBlack
	mov		ecx, 3			;f
	call	RepeatWhite
	mov		ecx, 9
	call	RepeatBlack
	mov		ecx, 9			;i
	call	RepeatWhite
	mov		ecx, 3
	call	RepeatBlack
	mov		ecx, 9			;l
	call	RepeatWhite
	mov		ecx, 6
	call	RepeatBlack
	mov		ecx, 3			;t
	call	RepeatWhite
	mov		ecx, 6
	call	RepeatBlack
	mov		ecx, 9			;e
	call	RepeatWhite
	mov		ecx, 3
	call	RepeatBlack
	mov		ecx, 3			;r
	call	RepeatWhite
	mov		ecx, 3
	call	RepeatBlack
	mov		ecx, 3			;r
	call	RepeatWhite

	mov		eax, WHITE + (BLACK SHL 4)
	call	SetTextColor

	call	crlf
	call	crlf
	call	crlf

	ret
GameName ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Factor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RepeatWhite PROC 
	repeatAgain:

		mov		eax, 3     
		call	RandomRange 
		.IF		eax == 2
		mov		eax, 239     
		call	RandomRange
		add		eax, 16
		.ELSE 
		mov		eax, BLACK + (WHITE SHL 4)
		.ENDIF
		call	SetTextColor
		call	WriteString
		loop	repeatAgain
	
	ret
RepeatWhite ENDP

RepeatBlack PROC 

	mov		eax, WHITE + (BLACK SHL 4)
	call	SetTextColor

	repeatAgain:
		call WriteString
		loop repeatAgain
	
	ret
RepeatBlack ENDP

Break PROC 
	mov		eax,5             
	add		eax,6             
	
	ret
Break ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 讀小數的filter
; edx -> return floatFilterArr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadFloatFilterFile proc
.data
    
    number          DWORD ?
    thousands       DWORD 100000
    floatFileHandle HANDLE  ?
    filterBuffer    BYTE    FILTER_BUFFER_SIZE DUP(?)       ; float filter buffer
    floatFilterArr  DWORD   FILTER_FILE_ARRAY_SIZE DUP(?)   ; float filter array
    isNegative      BYTE   0
    hasOne          BYTE   0
    hasTwo          BYTE   0


.code
    mov     eax,0
    mov     al,bl
    mov     ebx,4
    mul     ebx
    mov     ebx,OFFSET filePtr
    add     ebx,eax
	mov     edx,[ebx] 

	call    OpenInputFile
    mov     floatFileHandle,eax                                         
    cmp     eax, INVALID_HANDLE_VALUE                
    jne     file_ok   
    mWrite  <"Cannot open file",0dh,0ah>
    jmp quit                                     
    file_ok:                                      
        mov     edx, OFFSET filterBuffer
        mov     ecx, FILTER_BUFFER_SIZE
        call    ReadFromFile
        jnc     check_buffer_size                       
        call    WriteWindowsMsg
        jmp     close_file

    check_buffer_size:
        cmp     eax, FILTER_BUFFER_SIZE                          
        jb      buf_size_ok
        mWrite  "Error: Buffer too small for the file",0dh,0ah
        jmp     quit                                     

    buf_size_ok:
        mov     filterBuffer[eax],0  

        lea     esi, filterBuffer             
        mov     ecx, FILTER_BUFFER_SIZE
        lea     edi, floatFilterArr

        L3:
            mov     al, [esi]
            mov     ebx, 0
            .IF al == 45
                mov isNegative, 1
            .ENDIF
            .IF al == 49
                mov hasOne, 1
            .ENDIF
            .IF al == 50
                mov hasTwo, 1
            .ENDIF
            .IF al == 46

            push    ecx
            mov     ecx, 6
            mov     number, 0

            L4: 
                inc     esi
                mov     al, [esi]
                sub     al, 48
                mov     bl, al
                mov     eax, 0
                add     eax, ebx
                mul     thousands
                add     number, eax
                mov     eax, thousands
                mov     ebx, 10
                div     ebx
                mov     thousands, eax
                loop    L4
            
                mov     eax, number
            .IF hasOne == 1
                add     eax, 1000000
            .ENDIF
            .IF hasTwo == 1
                add     eax, 2000000
            .ENDIF
            .IF isNegative == 1
                neg     eax
            .ENDIF
            mov     isNegative, 0
            mov     hasOne, 0
            mov     hasTwo, 0

            mov     [edi],eax
            add     edi, 4
            pop     ecx
            sub     ecx, 6
            mov     thousands, 100000
        .ENDIF

        not_start:
                inc     esi
                inc     edx

                dec     ecx
                mov     eax,0h
                cmp     ecx,eax
             
                JNZ L3

                mov edx, offset floatFilterArr
    
        
    
                ;call    WriteString
                ;call    Crlf
                ret

    close_file:
        mov eax,floatFileHandle
        call CloseFile

    quit:
        exit


ReadFloatFilterFile ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 讀小數的filter
; edx -> get floatFilterArr
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetFilterFile proc
                                                      
	mov     ecx,FILTER_FILE_ARRAY_SIZE
	mov     edi,edx

	L3:
        mov     eax, [edi]
        call    WriteInt
        call    Crlf
		add     edi, 4
        call    waitMsg
        loop    L3
    
    ret


GetFilterFile ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 輸入檔案和操作
; edi -> get buffer offset
; edx -> get filename
; edx -> return image array ptr 
; eax -> return image height 
; ebx -> return image width
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
InputBMPFile PROC                               
.data
fileHandle      HANDLE  ?
bufferInput     DWORD   ?
.code
    mov  bufferInput, edi                                   
    call    OpenInputFile
    mov     fileHandle,eax
                                            
    cmp     eax,INVALID_HANDLE_VALUE                    ; 確認檔案是否正確
    jne     file_ok                                  
    mWrite  <"Cannot open file",0dh,0ah>
    jmp     quit                                     

file_ok:
    mov     edx, bufferInput                            ; 讀檔案內容
    mov     ecx,BUFFER_SIZE
    call    ReadFromFile
    jnc     check_buffer_size                           ; 確認buffer size使否足夠
    mWrite  "Error reading file. "               
    call    WriteWindowsMsg
    jmp     close_file

check_buffer_size:
    cmp     eax,BUFFER_SIZE                             ; 確認buffer size是否足夠
    jb      buf_size_ok                               
    mWrite  "Error: Buffer too small for the file",0dh,0ah
    jmp     quit                                    

buf_size_ok:                                            ; buffer size是足夠
    
    mov     edi, bufferInput
    call    GetImageArrayPointer

    ret
    

close_file:
    mov     eax,fileHandle
    call    CloseFile

quit:
    exit

    ret

InputBMPFile ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; create new array
; ebx -> get size (bytes)
; edx -> return array pointer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CreateNewArray PROC
.data
imageHeap       DWORD   ?
dwFlags         DWORD   HEAP_ZERO_MEMORY ; set memory bytes to all zeros
.code
    INVOKE  GetProcessHeap                              ; imageHeap
    mov     imageHeap,eax
    INVOKE  HeapAlloc, imageHeap, dwFlags, ebx          ; allocate the array's memory  
    .IF eax == NULL
    lea     edx, str1 
    call    WriteString
    jmp     quit
    .ELSE
    mov edx, eax                                        ; save the pointer to edx

    .ENDIF
    ret

    quit:
        exit
CreateNewArray ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 讀image header rgb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetImageArrayPointer PROC
.data

height          DWORD   ?                                   ; image height
hwidth          DWORD   ?                                   ; image width
bitsperpixel    DWORD   ?                                  ; bitsperpixel
str1            BYTE    "Cannot allocate heap memory!",0dh,0ah,0
bufferPointer   DWORD ?

.code
    
    ;mWrite  <"Successful",0dh,0ah,0dh,0ah> 

    mov     bufferPointer, edi
    mov     eax,[edi+28]                                ; 讀bitsperpixel
    cmp     eax, 24
    jne     isNot24BitsPerPixel

    mov     eax,[edi+18]
    mov     hwidth, eax                                 ; 讀image width
    mov     ebx,[edi+22]
    mov     height, ebx                                 ; 讀image height
    mul     ebx
    mov     ebx, 3
    mul     ebx
    mov     ebx, eax

    call CreateNewArray

    mov     ecx, height
    mov     edi, bufferPointer
    add     edi, IMAGE_OFFSET
    mov     esi, edx
    call    Crlf
ReadImageRGB:

    push    ecx 
    mov     ecx, hwidth 

    ReadImageRGBByWidth:
        mov     al,[edi]                                ; BLUE
        mov     BYTE PTR [esi].RGB.blue,al
        ;call writeHex
        inc     edi
        mov     al,[edi]                                ; GREEN
        mov     BYTE PTR [esi].RGB.green,al
        ;call writeHex
        inc     edi
        mov     al,[edi]                                ; RED
        mov     BYTE PTR [esi].RGB.red,al
        ;call writeHex
        ;call Crlf
        inc     edi
        add     esi,sizeof RGB
        loop ReadImageRGBByWidth 

    pop     ecx         
    
    loop    ReadImageRGB

    mov     eax, height
    mov     ebx, hwidth


    ret

    isNot24BitsPerPixel:
        mWrite  "It is not 24 bits per pixel"          ; 輸入output檔案名稱

    

    ret
    

GetImageArrayPointer ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 生成圖片
; edx -> get image array ptr 
; eax -> get image height 
; ebx -> get image width
; esi -> get image header
; edi -> get buffer offset
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CreateBMPImage PROC                             
.data
imageHeightOut     DWORD   ?                               ; image height
imageWidthOut      DWORD   ?                               ; image width
pImageArrOut       DWORD   ?                               ; image rgb arr
outputFilename     BYTE    80 DUP(?)
bufferOut       DWORD ? 
.code
    mov     pImageArrOut, edx                                       ; save the pointer
    mov     imageHeightOut, eax 
    mov     imageWidthOut, ebx 
    mov     bufferOut, edi
    mov     eax, imageWidthOut
    mov     [esi+18], eax
    mov     eax, imageHeightOut
    mov     [esi+22], eax
    mov     ecx, IMAGE_OFFSET

copyHeader:
    mov     al, [esi]
    mov     [edi], al
    inc     edi
    inc     esi

    loop    copyHeader

    mov     esi, pImageArrOut                           
    mov     ecx, imageHeightOut

Result:                                                 ; 生成後轉換進去

    push    ecx    
    mov     ecx, imageWidthOut     

    ResultByWidth:

        mov     al, [esi].RGB.blue                      
        mov     [edi], al
        inc     edi
        mov     al, [esi].RGB.green
        mov     [edi], al
        inc     edi
        mov     al, [esi].RGB.red
        mov     [edi], al
        inc     edi
        add     esi,SIZEOF RGB

        loop ResultByWidth 

    pop     ecx 
    

    loop    Result


    mov		dl, 20  ;column
	mov		dh, 30
    call	Gotoxy

    mWrite  "Enter an output filename:(.bmp) "          ; 輸入output檔案名稱
    lea     edx, outputFilename  
    mov     ecx, SIZEOF outputFilename
    call    ReadString
    mov     edx, OFFSET outputFilename 
    call    CreateOutputFile 
    push    eax                                         ; save file handle
    mov     ecx, BUFFER_SIZE  
    mov     edx, bufferOut
    call    WriteToFile 
    pop     eax                                         ; restore file handle
    
    call    CloseFile 

    ret
CreateBMPImage ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ForMenu PROC

.data

.code
    
    .IF bl == 0

        call BlurMode

    .ELSEIF bl == 1

        call BlurFrameMode

    .ELSEIF bl == 2 

        call PhotoFrameMode

    .ELSEIF bl == 3

        call LayoutMode

    .ELSEIF bl == 4

        call ShrinkMode

    .ELSEIF bl == 5

        call EnlargeMode

    .ENDIF




    ret
ForMenu ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

setRatio PROC
.data

.code
    .IF  cl == 0    ;25%

        mov esi,4h
        mov edi,3h

    .ELSEIF cl == 1  ;50%
        
        mov esi,2h
        mov edi,1h
    
    .ELSEIF cl == 2 ;75%

        mov esi,4h
        mov edi,1h
    
    .ENDIF

    ret
setRatio ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BlurFrameMode PROC

.data
buffer          BYTE    BUFFER_SIZE DUP(?)

filterHeight    DWORD   ?                               ; filter height
filterWidth     DWORD   ?                               ; filter width
pfilterArr      DWORD   ?                               ; filter rgb arr

filter2Height   DWORD   ?                               ; filter2 height
filter2Width    DWORD   ?                               ; filter2 width
pfilter2Arr     DWORD   ?                               ; filter2 rgb arr

imageHeader     BYTE    IMAGE_OFFSET DUP(?)
imageHeight     DWORD   ?                               ; image height
imageWidth      DWORD   ?                               ; image width
pImageArr       DWORD   ?                               ; image rgb arr

bordername      BYTE    "BG3.bmp",0  ;檔案路徑

.code

 ;;;;;;;原本的 pImageArr讀檔

   
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                  ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx

    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader



    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth  
    call   CreateOtherImage     ;多開一張圖
    mov pfilterArr   , edx
    mov filterHeight , eax
    mov filterWidth  , ebx
    


    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth
    mov     esi , 5h
    mov     edi , 4h
    call    ShrinkImageFilter   ;img1縮小
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx


    mov     edx , pfilterArr                              
    mov     eax , filterHeight
    mov     ebx , filterWidth
    call    BlurImageFilter     ;img2模糊
    mov pfilterArr   , edx
    mov filterHeight , eax
    mov filterWidth  , ebx



    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth
    mov     esi , pfilterArr
    mov     edi , filterWidth
    mov     ebp , filterHeight
    call    LapImageFilter      ;img1 疊 imag2
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx
    


    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth
    call SoftImageBorderFilter
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx
    

    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage

    ret

BlurFrameMode ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


BlurMode PROC

.data



.code

 ;;;;;;;原本的 pImageArr讀檔

   
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                  ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx

    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader



    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth
    call    BlurImageFilter 
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx

    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage

    ret

BlurMode ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ShrinkMode PROC

.data

.code
    
    
    call setRatio
    mov u,esi
    mov l,edi
   
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                  ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx

    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader



    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth
    mov     esi , u
    mov     edi , l
    call    ShrinkImageFilter      
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx


    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage

    ret

ShrinkMode ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


EnlargeMode PROC

.data



.code

    
    mov ecx,1
    call setRatio


    ;Ratio
    mov u,esi
    mov l,edi
   
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                  ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx

    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader

    
    

    mov eax,imageWidth
    mul u
    mov edx,0h
    div l
    mov filterWidth,eax  ;new Width
    
    mov eax,imageHeight
    mul u
    mov edx,0h
    div l
    mov filterHeight,eax ;new Height


    mov eax,filterWidth
    mul filterHeight
    mov ebx,SIZEOF RGB
    mul ebx
    mov ebx,eax

    call CreateNewArray  ;create new image 
    mov pfilterArr,edx



    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth
    mov     ecx , pfilterArr
    mov     esi , u
    mov     edi , l
    call    EnlargeImageFilter      
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx


    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage

    ret

EnlargeMode ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PhotoFrameMode PROC

.data

.code

 ;;;;;;;原本的 pImageArr讀檔

   
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                  ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx

    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader


    ;;;;;;;濾鏡1 pfilterArr讀檔

    
    mov     edx, OFFSET bordername

    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pfilterArr, edx                                  
    mov     filterHeight, eax
    mov     filterWidth, ebx



    ;mov     edx , pImageArr                                     
    ;mov     eax , imageHeight
    ;mov     ebx , imageWidth
    ;mov     esi , 3h
    ;mov     edi , 2h

    ;call    ShrinkImageFilter   ;img1縮小
    ;mov pImageArr   , edx
    ;mov imageHeight , eax
    ;mov imageWidth  , ebx

    
    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth
    mov     esi , pfilterArr
    mov     edi , filterWidth
    mov     ebp , filterHeight
    
    call    LapImageFilter      ;img1 疊 imag2
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx



    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth

    call SoftImageBorderFilter
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx

    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage

    ret

PhotoFrameMode ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LayoutMode PROC

.data

newImageArr DWORD ?
Arr DWORD ?

.code
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                  ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx
    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader

    ;;;;;;;濾鏡1 pfilterArr讀檔

    mWrite  "Enter an input filename: "                 ; 輸入檔案名稱
    mov     edx, OFFSET filename
    mov     ecx, SIZEOF filename
    call    ReadString

    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pfilterArr, edx                                  
    mov     filterHeight, eax
    mov     filterWidth, ebx

    ;;;;;;;濾鏡2 pfilterArr讀檔

    mWrite  "Enter an input filename: "                 ; 輸入檔案名稱
    mov     edx, OFFSET filename
    mov     ecx, SIZEOF filename
    call    ReadString

    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pfilter2Arr,edx                                     ; save the pointer
    mov     filter2Height, eax
    mov     filter2Width, ebx


    mov eax,imageHeight
    add eax,filterHeight
    add eax,filter2Height
    mul imageWidth
    mov ebx,SIZEOF RGB
    mul ebx
    mov ebx,eax
    call createNewArray
    mov newImageArr,edx

    mov esi,offset Arr
    mov edi,esi

    mov eax,imageWidth
    mov [edi],eax
    add edi,SIZEOF Arr

    mov eax,pImageArr
    mov [edi],eax
    add edi,SIZEOF Arr

    mov eax,imageHeight
    mov [edi],eax
    add edi,SIZEOF Arr

    mov eax,pfilterArr
    mov [edi],eax
    add edi,SIZEOF Arr

    mov eax,filterHeight
    mov [edi],eax
    add edi,SIZEOF Arr

    mov eax,pfilter2Arr
    mov [edi],eax
    add edi,SIZEOF Arr

    mov eax,filter2Height
    mov [edi],eax
    add edi,SIZEOF Arr

    mov eax,newImageArr
    mov [edi],eax
    add edi,SIZEOF Arr


    
    call LayoutImageFilter
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx


    mov     edx , pImageArr                                     
    mov     eax , imageHeight
    mov     ebx , imageWidth
    mov esi,3h
    mov edi,1h
    call ShrinkImageFilter
    mov pImageArr   , edx
    mov imageHeight , eax
    mov imageWidth  , ebx

    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage


    ret
LayoutMode ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;copy a same image in other Array

;edx -> ptr
;eax -> height
;ebx -> width

;eax  return -> iHeight
;ebx  return -> iWidth
;edx  return -> new_pos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CreateOtherImage PROC

.data

new_pos DWORD ?
new_currentPos DWORD ?
.code

    mov     head_pos,edx                                  
    mov     iHeight, eax
    mov     iWidth, ebx
    mov current_pos,edx

    mul iWidth
    mov ebx,SIZEOF RGB
    mul ebx
    mov ebx,eax

    call CreateNewArray

    mov new_pos,edx
    mov new_currentPos,edx
    
    mov ecx,iHeight
    heightLoop:
        push ecx

        mov ecx,iWidth
        widthLoop:
            
            mov esi,current_pos
            call getColor
            
            mov esi,new_currentPos
            call setColor

            add new_currentPos,SIZEOF RGB
            add current_pos,SIZEOF RGB
            
            loop widthLoop
        
        pop ecx

        loop heightLoop

    mov eax,iHeight
    mov ebx,iWidth
    mov edx,new_pos
    

    ret

CreateOtherImage ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; edx -> get image1 array ptr 
; eax -> get image1 height 
; ebx -> get image1 width
; esi -> get u
; edi -> get i

; image array ptr  -> return edx
; image height  -> return eax
; image width -> return ebx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShrinkImageFilter PROC                                        ;FILTER MODE
.data
    
r Byte ?
g Byte ? 
b Byte ?
i_h DWORD ?
i_w DWORD ?
upper DWORD ?
lower DWORD ?
u DWORD ?
l DWORD ?
iHeight DWORD ? 
iWidth DWORD ?
current_pos DWORD ?
head_pos DWORD ?
new_width DWORD ?
new_height DWORD ?
modw DWORD ?
modh DWORD ?
x DWORD ?
y DWORD ?
ii DWORD ?
avg DWORD ?
count DWORD ?
RD DWORD ?
GD DWORD ? 
BD DWORD ?
.code

                                      
    mov     head_pos,edx                                   ; save the pointer
    mov     iHeight, eax
    mov     iWidth, ebx

    ;Ratio u/l
    mov u,esi 
    mov l,edi

    mov esi, head_pos ;圖片head指標位置
    mov current_pos,esi
    
    mov eax,iHeight ;縮小圖的Height
    mul l
    mov edx,0h
    div u
    mov new_height,eax

    mov eax,iWidth ;縮小圖的Width
    mul l
    mov edx,0h
    div u
    mov new_Width,eax

    
    mov eax,u
    sub eax,l
    mov lower,eax

    
    mov i_h,0h         ;idx start : 0h
    mov ecx , iHeight  ;idx count iHeight

ChangeImageRGB:
    
    
    push  ecx 

    mov i_w,0h       ;idx start :0h
    mov  ecx, iWidth ;idx count iWidth
   
    ChangeImageRGBByWidth:
             
         mov edx,0h
         mov eax,i_w
         div u       ;對i_w取餘數


         .IF edx >= lower

             mov edx,0h
             mov eax,i_h
             div u       ;對i_h取餘數 
            
            .IF edx >= lower
                
                
                mov eax,iWidth
                mul i_h
                add eax,i_w
                mov ebx,SIZEOF RGB
                mul ebx
                add eax,head_pos

                mov esi,eax

                call getColor

                mov esi,current_pos

                call setColor

                add current_pos,SIZEOF RGB

                  
            .ENDIF
        .ENDIF

        
        add i_w,1h
        dec ecx
       
        mov eax , 0h
        cmp ecx,eax
        JNZ ChangeImageRGBByWidth 
        
        
    pop     ecx 
    dec ecx

    add i_h,1h
    
    mov eax ,0h
    cmp ecx,eax
    JNZ    ChangeImageRGB

    mov edx,head_pos
    mov eax,new_height;變更圖片Height
    mov ebx,new_width ;變更圖片Width

    
    
    ret
ShrinkImageFilter ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; edx -> get image1 array ptr 
; eax -> get image1 height 
; ebx -> get image1 width
; ecx -> get image2 array ptr 
; esi -> get u
; edi -> get l 

; image array ptr  -> return edx
; image height  -> return eax
; image width -> return ebx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EnlargeImageFilter PROC                                        ;FILTER MODE
.data
    
jj DWORD ?
newWidth DWORD ?
newHeight DWORD ?
newHeadPos DWORD ?


.code

    mov head_pos  , edx
    mov iHeight   , eax
    mov iWidth    , ebx
    mov newHeadPos, ecx
    mov current_pos,ecx
    
    ;Ratio
    mov u , esi
    mov l , edi

    mov eax,iHeight
    mul u
    mov edx,0h
    div l
    mov newHeight,eax  ;新高

    mov eax,iWidth
    mul u
    mov edx,0h
    div l
    mov newWidth,eax   ;新寬
 
    mov i_h,0h
    mov ecx , newHeight
    heightLoop:
    
        push ecx

        mov i_w,0h    
        mov ecx ,newWidth
        
        widthLoop:
        
                      
                        
            mov eax,i_h
            mul l
            mov edx,0h
            div u
            mov x,eax

            
            mov eax,i_w
            mul l
            mov edx,0h
            div u
            mov y,eax

            mov eax,x
            .IF eax >= iHeight

                mov eax,iHeight
                sub eax,1
                mov x,eax

            .ENDIF
           
            mov eax,y
            .IF eax >= iWidth

                mov eax,iWidth
                sub eax,1
                mov y,eax

            .ENDIF

            mov eax,iWidth
            mul x
            add eax,y
            mov ebx,SIZEOF RGB
            mul ebx
            add eax,head_pos
            mov esi,eax

            call getColor
            mov r,dl
            mov g,bl
            mov b,al

            mov eax,newWidth
            mul i_h
            add eax,i_w
            mov ebx,SIZEOF RGB
            mul ebx
            add eax,newHeadPos
            mov esi,eax
           

            mov dl,r
            mov bl,g
            mov al,b
            call setColor


            inc i_w

            
            dec ecx

            mov eax,0h
            cmp ecx ,eax
            JNZ widthLoop
    
        inc i_h

        pop ecx 
        dec ecx 

        mov eax,0h
        cmp ecx,eax
        JNZ heightLoop

    mov edx,newHeadPos
    mov eax,newHeight
    mov ebx,newWidth

    ret
EnlargeImageFilter ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; edx -> get image1 array ptr 
; eax -> get image1 height 
; ebx -> get image1 width

; image array ptr  -> return edx
; image height  -> return eax
; image width -> return ebx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BlurImageFilter PROC                                        ;FILTER MODE
.data
    

i_l DWORD ?
i_u DWORD ?
j_l DWORD ?
j_u DWORD ?


.code


    mov head_pos,edx
    mov iHeight ,eax
    mov iWidth ,ebx



    mov i_h,0h
    mov i_w,0h

    
    mov avg,10h
    ;count = (avg*2+1)**2


    mov ecx,iHeight


    ChangeImageRGB:
    
    
    
        mov RD,0h
        mov GD,0h
        mov BD,0h
        mov r,0h
        mov g,0h
        mov b,0h

    
        mov eax,avg

        .IF eax>i_h  
        
            mov i_l,0h
    
        .ELSE
        
            mov eax,i_h
            sub eax,avg
            mov i_l,eax

        .ENDIF


        mov eax,i_h
        add eax,avg
        mov i_u,eax
    

        .IF eax >= iHeight
        
            mov eax,iHeight
            dec eax
            mov i_u,eax

        .ENDIF

        push ecx

        mov ecx,avg 
        add ecx,1h
    

        mov x,0h
        L1:
            push ecx

            mov ecx ,i_u
            sub ecx,i_l
            add ecx,1h

            mov eax,i_l
        
            mov y,eax
            L2:
            
                mov eax,iWidth
                mul y
                add eax,x
                mov ebx,SIZEOF RGB
                mul ebx    
                add eax,head_pos       
                mov esi,eax
            
                
                mov eax,0h
                mov al, [esi].RGB.red 
                add RD,eax
            
            
                mov eax,0h
                mov al, [esi].RGB.green 
                add GD,eax
            

                mov eax,0h
                mov al, [esi].RGB.blue   
                add BD,eax
            
                inc y

                sub ecx,1h
                mov eax,0h
                cmp ecx,eax
                JNZ L2

        
            pop ecx
            sub ecx,1h
        
            inc x

            mov eax,0h
            cmp ecx,eax
            JNZ L1

        mov ecx,iWidth
        mov i_w,0h
        ChangeImageRGBByWidth:
        
            push ecx
        

            mov eax,avg
            .IF eax > i_w
            
                mov j_l,0h

            .ELSE
            
                mov eax,i_w
                sub eax,avg
                mov j_l,eax

            .ENDIF

            mov eax,i_w
            add eax,avg
            mov j_u,eax
        
            .IF eax >= iWidth
            
                mov eax ,iWidth
                dec eax
                mov j_u,eax

            .ENDIF

       
            mov eax,i_u
            sub eax,i_l
            inc eax
        

            mov ebx,j_u
            sub ebx,j_l
            inc ebx
       

            mul ebx
            mov count ,eax
        
            mov edx,0h
            mov eax,RD
            div count
            mov r,al
        

            mov edx,0h
            mov eax,GD
            div count
            mov g,al
        

            mov edx,0h
            mov eax,BD
            div count
            mov b,al


            mov eax,iWidth
            mul i_h
            add eax,i_w
            mov ebx,SIZEOF RGB
            mul ebx
            add eax,head_pos
            mov esi,eax

            
            mov dl,r
            mov bl,g
            mov al,b
            call setcolor

            mov ecx,i_u
            sub ecx,i_l
            add ecx,1h

            mov eax,i_l
            mov ii,eax
            L4:
            
                mov eax,avg
                .IF i_w >= eax
                
                    mov eax,i_w
                    sub eax,avg
                    mov ebx,eax

                    mov eax,iWidth
                    mul ii
                    add eax,ebx
                    mov ebx ,SIZEOF RGB
                    mul ebx
                    add eax,head_pos
                    mov esi ,eax

                    mov eax,0h
                    mov al ,[esi].RGB.red
                    sub RD,eax

                    mov eax,0h
                    mov al ,[esi].RGB.green
                    sub GD,eax

                    mov eax,0h
                    mov al ,[esi].RGB.blue
                    sub BD,eax
                .ENDIF

            
                mov ebx,i_w
                add ebx,avg

                .IF ebx < iWidth
                
                    mov eax,iWidth
                    mul ii
                    add eax,ebx
                    mov ebx ,SIZEOF RGB
                    mul ebx
                    add eax,head_pos
                    mov esi ,eax
                
                    mov eax,0h
                    mov al ,[esi].RGB.red
                    add RD,eax

                    mov eax,0h
                    mov al ,[esi].RGB.green
                    add GD,eax

                    mov eax,0h
                    mov al ,[esi].RGB.blue
                    add BD,eax
                .ENDIF
   
                
                add ii,1h

                dec ecx
                mov eax,0h
                cmp ecx,eax
                JNZ L4


            pop ecx
        
            inc i_w

            dec ecx
            mov eax,0h
            cmp ecx,eax

            JNZ ChangeImageRGBByWidth 
        

        inc i_h

        pop ecx
        dec ecx
        mov eax,0h
        cmp ecx,eax
        
        JNZ    ChangeImageRGB

    mov edx,head_pos
    mov eax,iHeight
    mov ebx,iWidth

    

    ret
BlurImageFilter ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; edx -> get image1 array ptr 
; eax -> get image1 height 
; ebx -> get image1 width
; esi -> get image2 array ptr 
; ebp -> get image2 height 
; edi -> get image2 width

; image array ptr  -> return edx
; image height  -> return eax
; image width -> return ebx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LapImageFilter PROC                                        ;FILTER MODE
.data
    
bgWidth DWORD ?
bgHeight DWORD ?
bgHeadPos DWORD ?
mainWidth DWORD ?
mainHeight DWORD ?
mainHeadPos DWORD ?

c_w DWORD ?
c_h DWORD ?

.code

    mov mainHeight  , eax
    mov mainWidth   , ebx
    mov mainHeadPos , edx

    mov bgHeadPos   , esi
    mov bgHeight    , ebp
    mov bgWidth     , edi

    mov eax , mainHeight
    mov ecx , mainWidth
    mul ecx
    mov ebx , eax

    mov eax , bgHeight
    mov ecx , bgWidth
    mul ecx


    .IF eax < ebx
        
        mov eax , bgHeadPos
        mov ebx , mainHeadPos
        mov bgHeadPos,ebx
        mov mainHeadPos,eax

        mov eax , bgWidth
        mov ebx , mainWidth
        mov bgWidth,ebx
        mov mainWidth,eax

        mov eax , bgHeight
        mov ebx , mainHeight
        mov bgHeight,ebx
        mov mainHeight,eax


    .ENDIF
    

    mov i_h,0h
    mov ecx,mainHeight
    heightLoop:

        push ecx
        mov i_w,0h
        mov ecx,mainWidth

        widthLoop:
            
         
            mov eax,mainWidth
            mul i_h
            add eax,i_w
            mov ebx ,SIZEOF RGB
            mul ebx
            add eax,mainHeadPos
            mov esi,eax


            call getColor
            mov r,dl
            mov g,bl
            mov b,al

            mov edx,0h
            mov eax,bgWidth
            sub eax,mainWidth
            mov ebx,2h
            div ebx
            add eax,i_w
            mov c_w,eax

            mov edx,0h
            mov eax,bgHeight
            sub eax,mainHeight
            mov ebx,2h
            div ebx
            add eax,i_h
            mov c_h,eax



            mov eax,bgWidth
            mul c_h
            add eax,c_w
            mov ebx ,SIZEOF RGB
            mul ebx
            add eax,bgHeadPos
            mov esi,eax

            mov dl,r
            mov bl,g
            mov al,b
            call setColor

            add i_w,1h

            sub ecx,1h
            
            mov eax,0h
            cmp ecx,eax
            JNZ widthLoop

        pop ecx
        sub ecx,1h

        add i_h,1h

        mov eax,0h
        cmp ecx,eax
        JNZ heightLoop

    mov edx,bgHeadPos
    mov eax,bgHeight
    mov ebx,bgWidth
    
    
    
    ret
LapImageFilter ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; esi -> get array ptr include three image data 


; image array ptr  -> return edx
; image height  -> return eax
; image width -> return ebx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LayoutImageFilter PROC

.data


image1ptr DWORD ?
image1Height DWORD ?

image2ptr DWORD ?
image2Height DWORD ?

image3ptr DWORD ?
image3Height DWORD ?

newImagePtr DWORD ?
newImageHeight DWORD ?

.code
    
    mov eax,[esi]
    mov iWidth ,eax 
    add esi , SIZEOF DWORD
    mov eax,[esi]
    mov image1ptr , eax
    add esi , SIZEOF DWORD
    mov eax,[esi]
    mov image1Height , eax
    add esi , SIZEOF DWORD

    mov eax,[esi]
    mov image2ptr , eax
    add esi , SIZEOF DWORD
    mov eax,[esi]
    mov image2Height , eax
    add esi , SIZEOF DWORD

    mov eax,[esi]
    mov image3ptr , eax
    add esi , SIZEOF DWORD
    mov eax,[esi]
    mov image3Height , eax
    add esi , SIZEOF DWORD

    mov eax,[esi]
    mov newImagePtr , eax
    add esi , SIZEOF DWORD
    
    mov eax , image1Height
    add eax , image2Height
    add eax , image3Height
    mov newImageHeight , eax


    mov eax,newImagePtr
    mov current_pos,eax

    mov i_h,0h

    mov ecx,image1Height

    L1:
        push ecx 

        mov i_w,0h
        mov ecx,iWidth

        L2:
            
            mov eax,iWidth
            mul i_h
            add eax,i_w
            mov ebx,SIZEOF RGB
            mul ebx
            add eax,image1ptr
            mov esi,eax

            call getColor

            mov esi,current_pos

            call setColor
            
            mov ebx,SIZEOF RGB
            add current_pos,ebx
            
            inc i_w

            dec ecx
            mov eax,0h
            cmp eax,ecx
            JNZ L2
        
        inc i_h

        pop ecx
        dec ecx
        mov eax,0h
        cmp eax,ecx
        JNZ L1

    mov i_h,0h

    mov ecx,image2Height

    L3:
        push ecx 

        mov i_w,0h
        mov ecx,iWidth

        L4:
            
            mov eax,iWidth
            mul i_h
            add eax,i_w
            mov ebx,SIZEOF RGB
            mul ebx
            add eax,image2ptr
            mov esi,eax

            call getColor

            mov esi,current_pos

            call setColor
            
            mov ebx,SIZEOF RGB
            add current_pos,ebx
            
            inc i_w

            dec ecx
            mov eax,0h
            cmp eax,ecx
            JNZ L4
        
        inc i_h

        pop ecx
        dec ecx
        mov eax,0h
        cmp eax,ecx
        JNZ L3

    mov i_h,0h

    mov ecx,image3Height

    L5:
        push ecx 

        mov i_w,0h
        mov ecx,iWidth

        L6:
            
            mov eax,iWidth
            mul i_h
            add eax,i_w
            mov ebx,SIZEOF RGB
            mul ebx
            add eax,image3ptr
            mov esi,eax

            
            call getColor
            mov esi,current_pos
            call setColor
            
            
            mov ebx,SIZEOF RGB
            add current_pos,ebx
            
            inc i_w

            dec ecx
            mov eax,0h
            cmp eax,ecx
            JNZ L6
        
        inc i_h

        pop ecx
        dec ecx
        mov eax,0h
        cmp eax,ecx
        JNZ L5


    mov edx,newImagePtr
    mov eax,newImageHeight
    mov ebx,iWidth

    ret
LayoutImageFilter ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;esi ->ptr

;dl  -> return r 
;bl -> return g
;al -> return b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getColor PROC 
.data

.code

    mov dl,[esi].RGB.red
    mov bl,[esi].RGB.green
    mov al,[esi].RGB.blue

    ret
getColor ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;dl -> r
;bl -> g
;al -> b
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
setColor PROC 
.data

.code
    
    mov [esi].RGB.red,dl
    mov [esi].RGB.green,bl
    mov [esi].RGB.blue,al

    ret
setColor ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; edx -> get image array ptr 
; eax -> get image height 
; ebx -> get image width
; image array ptr  -> return edx
; image height  -> return eax
; image width -> return ebx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SoftImageBorderFilter PROC

.data

halfWidth DWORD ?
halfHeight DWORD ?

.code

    mov head_pos,edx
    mov iHeight ,eax
    mov iWidth ,ebx
  
    mov u,3h
    mov l,2h

    mov eax,iWidth
    mul l
    mov edx,0h
    div u
    mov new_width,eax
    

    mov eax,iHeight
    mul l
    mov edx,0h
    div u
    mov new_height,eax
    

    mov edx,0h
    mov eax,iHeight
    sub eax,new_height
    mov ebx,2h
    div ebx
    mov halfHeight,eax
    

    mov edx,0h
    mov eax,iWidth
    sub eax,new_width
    mov ebx,2h
    div ebx
    mov halfWidth,eax
    
    
    mov eax,9h
    mov avg,eax

    ;下
        
    mov eax,iWidth
    mul halfHeight
    add eax,halfWidth
    mov ebx,SIZEOF RGB
    mul ebx
    add eax,head_pos
    mov esi,eax
    mov current_pos,esi

    
    mov ecx,new_width

    L1:
        
        push ecx
        mov RD , 0h
        mov GD , 0h
        mov BD , 0h

        ;中
        mov esi ,current_pos
        
        call Cal

        mov ebx,SIZEOF RGB
        add current_pos,ebx

        pop ecx
        dec ecx
        mov eax,0h
        cmp ecx,eax
        JNZ L1

    ;;;;;;;;;;;;;;;;;;;;;;;;
    

    ;左

    mov eax,iWidth
    mul halfHeight
    add eax,halfWidth
    mov ebx,SIZEOF RGB
    mul ebx
    add eax,head_pos
    mov esi,eax
    mov current_pos,esi


    mov ecx,new_height

    L2:
        
        
        push ecx
        mov RD , 0h
        mov GD , 0h
        mov BD , 0h

        ;中
        mov esi ,current_pos
        
        call Cal

        mov eax,iWidth
        mov ebx,SIZEOF RGB
        mul ebx
        add current_pos,eax

        pop ecx
        dec ecx
        mov eax,0h
        cmp ecx,eax
        JNZ L2

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ;上

    mov eax,iWidth
    mov ebx,halfHeight
    
    add ebx,new_height
    
    mul ebx
    add eax,halfWidth
    mov ebx,SIZEOF RGB
    mul ebx
    add eax,head_pos
    mov esi,eax
    mov current_pos,esi
    
    mov ecx,new_width

    L3:
        push ecx
        mov RD , 0h
        mov GD , 0h
        mov BD , 0h

        ;中
        mov esi ,current_pos
        
        call Cal

        mov ebx,SIZEOF RGB
        add current_pos,ebx

        pop ecx
        dec ecx
        mov eax,0h
        cmp ecx,eax
        JNZ L3

   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
   ;右

    mov eax,iWidth
    mul halfHeight
    add eax,halfWidth
    add eax,new_width
    mov ebx,SIZEOF RGB
    mul ebx
    add eax,head_pos
    mov esi,eax
    mov current_pos,esi

    mov ecx,new_height

    L4:
        push ecx

        mov RD , 0h
        mov GD , 0h
        mov BD , 0h
      
        ;中
        mov esi ,current_pos
        
        call Cal

        mov eax,iWidth
        mov ebx,SIZEOF RGB
        mul ebx
        add current_pos,eax

        pop ecx
        dec ecx
        mov eax,0h
        cmp ecx,eax
        JNZ L4

    
    mov edx , head_pos
    mov eax , iHeight
    mov ebx , iWidth

     
    ret
SoftImageBorderFilter ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Cal PROC

.data

current_ptr DWORD ?
.code
    
    mov current_ptr,esi
    mov edi,esi
        

    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx

    ;中下
    mov esi,edi
    mov eax,iWidth
    mov ebx,SIZEOF RGB
    mul ebx
    sub esi,eax
        

    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx


    ;中上
    mov esi,edi
    mov eax,iWidth
    mov ebx,SIZEOF RGB
    mul ebx
    add esi,eax


    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx

    ;左
    mov esi ,current_ptr
    sub esi,SIZEOF RGB
    mov edi,esi

    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx


    ;左下
    mov esi ,edi
    mov eax,iWidth
    mov ebx,SIZEOF RGB
    mul ebx
    sub esi,eax

    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx

    ;左上
    mov esi ,edi
    mov eax,iWidth
    mov ebx,SIZEOF RGB
    mul ebx
    add esi,eax

    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx


    ;右
    mov esi ,current_ptr
    add esi,SIZEOF RGB
    mov edi,esi

    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx
        
    ;右下
    mov esi ,edi
    mov eax,iWidth
    mov ebx,SIZEOF RGB
    mul ebx
    sub esi,eax

    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx

    ;右上
    mov esi ,edi
    mov eax,iWidth
    mov ebx,SIZEOF RGB
    mul ebx
    add esi,eax

    call RGBsum
    add RD,ebx
    add GD,ecx
    add BD,edx

    mov ebx,RD
    mov ecx,GD
    mov edx,BD

    call DivideSum
    mov r,bl
    mov g,cl
    mov b,dl


    mov esi,current_ptr

    mov dl,r
    mov bl,g
    mov al,b
    call setColor


    ret
Cal ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RGBsum PROC 
.data
.code
    ;RD ->ebx
    ;GD ->ecx
    ;BD ->edx


    mov eax,0h
    mov al,[esi].RGB.red
    mov ebx,eax
    
    mov eax,0h
    mov al,[esi].RGB.green
    mov ecx,eax
    
    mov eax,0h
    mov al,[esi].RGB.blue
    mov edx,eax


    ret
RGBsum ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;ebx -> RD
;ecx -> GD
;edx -> BD

;RD/avg ->return  bl
;GD/avg ->return cl
;BD/avg ->return  dl
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DivideSum PROC

.data
 
.code

    
    mov edx,0h
    mov eax,ebx
    div avg
    mov bl,al

    mov edx,0h
    mov eax,ecx
    div avg
    mov cl,al

    mov edx,0h
    mov eax,edx
    div avg
    mov dl,al

    ret
DivideSum ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;CallStickerFunc -> Sticker_Filter
;CallDoubleFunc  -> Double_Filter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 讀檔
; 0_s(Capoo) 1_s(Frame1) 2_s(Frame2) 3_s(Flower) 4_s(Text) 5_s(Godzilla)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CallStickerFunc PROC

.data

HeightWidth     DWORD   4 DUP(?)
Choose          BYTE   "a_s.bmp",0 

.code

;;;;;;;濾鏡1 pfilterArr讀檔

    add     bl, '0'
    mov     choose[0],   bl

 ;;;;;;;原本的 pImageArr讀檔

   
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                   ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx

    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader
    
    
    mov      edx , OFFSET choose
    ;call     WriteString


    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pfilterArr, edx                                  
    mov     filterHeight, eax
    mov     filterWidth, ebx
    
     

    ;;;;;;;原本的 pImageArr濾鏡後

    
    mov     esi,        OFFSET  HeightWidth
    mov     [esi],      eax
    mov     [esi+4],    ebx

    mov     eax,        imageWidth
    mov     [esi+8],    eax
    mov     [esi+16],   eax
    mov     eax,        [esi+4]
    sub     [esi+16],    eax

    mov     edx,        pfilterArr                                     ; filter pointer
    mov     ebx,        pImageArr                                      ; ori pointer

    call    Sticker_Filter                                        ;呼叫FilterImage
                                       

    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      ; save the pointer
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage

    ret

CallStickerFunc ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 改這邊
; 處理image RGB
; 註解為測試用
; ebx -> get image array ptr
; edx -> get filter array ptr 
; [esi] -> get filter height 
; [esi+4] -> get filter width
; [esi+8] -> get image width
; [esi+16] -> space
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Sticker_Filter PROC                                        ;FILTER MODE
    
    mov eax,0

    mov ecx, [esi]

    ChangeImageRGB:

        push    ecx 
        mov     ecx, [esi+4] 
        

        ChangeImageRGBByWidth:

            push    ebx

            mov     ebx,    0
            mov     eax,    0

            mov     bl,     [edx].RGB.red
            mov     al,     [edx].RGB.green
            add     eax,     ebx
            mov     ebx,    0
            mov     bl,     [edx].RGB.blue
            add     eax,     ebx
            
            pop     ebx
            

            cmp     eax,    765
            je     next
            ;jmp     next
           
            mov eax,0
		    thenblock:
			    mov     al, [edx].RGB.red                       ; RED
                mov     [ebx].RGB.red, al

                mov     al, [edx].RGB.green                   ; GREEN
                mov     [ebx].RGB.green, al

                mov     al, [edx].RGB.blue                     ; BLUE
                mov     [ebx].RGB.blue, al
			
		    next:

        
            add     edx,SIZEOF RGB
            add     ebx,SIZEOF RGB


        loop ChangeImageRGBByWidth 


        pop     ecx
        
       


    loop    ChangeImageRGB
    
    

    ret

Sticker_Filter ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 讀檔
; 0_d(Sunset) 1_d(Sea) 2_d(Aurora) 3_d(Firefly)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CallDoubleFunc PROC

.data

Choose2          BYTE   "a_d.bmp",0 

.code

;;;;;;;濾鏡1 pfilterArr讀檔
    add     bl, '0'
    mov     choose2[0],   bl

 ;;;;;;;原本的 pImageArr讀檔

   
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                   ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx

    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader


    
    mov      edx , OFFSET choose2
    ;call     WriteString

    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pfilterArr, edx                                  
    mov     filterHeight, eax
    mov     filterWidth, ebx
    
     

    ;;;;;;;原本的 pImageArr濾鏡後

    
    mov     esi,        OFFSET  HeightWidth
    mov     [esi],      eax
    mov     [esi+4],    ebx

    mov     eax,        imageWidth
    mov     [esi+8],    eax
    mov     [esi+16],   eax
    mov     eax,        [esi+4]
    sub     [esi+16],    eax

    mov     edx,        pfilterArr                                     ; filter pointer
    mov     ebx,        pImageArr                                      ; ori pointer

    call    Double_Filter                                        ;呼叫FilterImage
                                       

    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      ; save the pointer
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage

    ret

CallDoubleFunc ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 改這邊
; 處理image RGB
; 註解為測試用
; ebx -> get image array ptr
; edx -> get filter array ptr 
; [esi] -> get filter height 
; [esi+4] -> get filter width
; [esi+8] -> get image width
; [esi+16] -> space
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Double_Filter PROC                                        ;FILTER MODE
    

.data
    
    
    index     DWORD   0

.code
    mov eax,0


    mov ecx, [esi]

    ChangeImageRGB:

        push    ecx 
        mov     ecx, [esi+4] 
        

        ChangeImageRGBByWidth:

            push    ebx
            push    edx

            cdq
            mov     eax,    index
            mov     ebx,    2
            idiv ebx
            
            cmp    edx, 0
            pop    edx
            pop    ebx
            je     next
           
		    thenblock:
			    mov     al, [edx].RGB.red                       ; RED
                mov     [ebx].RGB.red, al

                mov     al, [edx].RGB.green                   ; GREEN
                mov     [ebx].RGB.green, al

                mov     al, [edx].RGB.blue                     ; BLUE
                mov     [ebx].RGB.blue, al

			
		    next:
                inc index
        
            add     edx,SIZEOF RGB
            add     ebx,SIZEOF RGB


        loop ChangeImageRGBByWidth 

        inc index
        pop     ecx
        
       


    loop    ChangeImageRGB
    
    

    ret
Double_Filter ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;yui

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetPTR PROC USES esi edi

.data
    f1              BYTE    "BlueArchitecture.cube",0;
    f2              BYTE    "BlueHour.cube",0;
    f3              BYTE    "ColdChrome.cube",0;
    f4              BYTE    "CrispAutumn.cube",0;
    f5              BYTE    "DarkAndSomber.cube",0;
    f6              BYTE    "HardBoost.cube",0;
    f7              BYTE    "LongBeachMorning.cube",0;
    f8              BYTE    "LushGreen.cube",0;
    f9              BYTE    "MagicHour.cube",0;
    f10             BYTE    "NaturalBoost.cube",0;
    f11             BYTE    "OrangeAndBlue.cube",0;
    f12             BYTE    "SoftBlackAndWhite.cube",0;
    f13             BYTE    "Waves.cube",0;
    filePtr         DWORD 13 DUP(?)

.code
    mov esi,OFFSET filePtr
    mov edi,OFFSET f1
    mov [esi],edi
    add esi,4
    
    mov edi,OFFSET f2
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f3
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f4
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f5
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f6
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f7
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f8
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f9
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f10
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f11
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f12
    mov [esi],edi
    add esi,4
    mov edi,OFFSET f13
    mov [esi],edi
    add esi,4

    ret

SetPTR ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LUTsAdjustment PROC
    
.data
    
    filterList BYTE "BlueArchitecture.cube",0
    LutArray DWORD ?

.code
    call    SetPTR
    ;;;;;;;原本的 pImageArr讀檔

    push    ebx
    
    lea     edi, buffer
    call    InputBMPFile                                   
    mov     pImageArr, edx                                   ; save the pointer
    mov     imageHeight, eax
    mov     imageWidth, ebx

    lea     edi, buffer                                     ; 原本的 pImageArr header
    lea     esi, imageHeader
    mov     ecx, IMAGE_OFFSET 
    FileHeader:                                             ; 讀file header
    mov     al, [edi] 
    mov     [esi], al
    add     edi, TYPE buffer 
    add     esi, TYPE buffer
    loop    FileHeader

    
    pop     ebx

    call    ReadFloatFilterFile

    mov     LutArray,edx
    mov     eax,imageHeight

    mov     ebx,imageWidth
    mov     edi,pImageArr
    mov     esi,LutArray
   


    call    LUTsLoop                                             ;呼叫FilterImage






    ;;;;;;;用 pImageArr生圖
    mov     edx, pImageArr                                      ; save the pointer
    mov     eax, imageHeight
    mov     ebx, imageWidth
    lea     esi, imageHeader
    lea     edi, buffer
    call    CreateBMPImage

    INVOKE  HeapFree, imageHeap, dwFlags, pImageArr
    ;call    WaitMsg
    ret



LUTsAdjustment ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; edi -> image array ptr 
; eax -> image height 
; ebx -> image width
; esi -> LutArray
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LUTsLoop PROC
.data

    RGB_HL DWORD 6 DUP(?);
    control WORD 0;
    color DWORD 0;

.code
   
    mov ecx, eax
    
    push eax
    ;設為無條件捨去
	;;;;;;;;;;;;;;
	fnstcw control
	mov ax, control
	or ax, 0c00h
	mov control, ax
	fldcw control
	;;;;;;;;;;;;;;
    pop eax

ChangeImageRGB:

    push    ecx 
    mov     ecx, ebx 
    push    ebx

    ChangeImageRGBByWidth:

        push ecx

        push esi

        mov esi,OFFSET RGB_HL
        
        mov edx,0
        mov dl,[edi].RGB.red
        mov color ,edx


        fild color;
	    call SetVar;
        
        
        mov dl,[edi].RGB.green
        mov color ,edx


	    fild color;
	    call SetVar;

        mov dl,[edi].RGB.blue
        mov color ,edx


	    fild color;
	    call SetVar;

        pop esi
        push edi
        mov edi,OFFSET RGB_HL
        
	    call CalParameter;
        pop edi

        mov cl,[edx]
        mov [edi].RGB.red,cl

        mov cl,[edx+1]
        mov [edi].RGB.green,cl

        mov cl,[edx+2]
        mov [edi].RGB.blue,cl
       
        
        pop ecx

        add     edi,SIZEOF RGB

        loop ChangeImageRGBByWidth 

    pop     ebx
    pop     ecx 
    
    loop    ChangeImageRGB

    ret



LUTsLoop ENDP
;;;;;;;;;;;;;
; esi -> RGBHL
;;;;;;;;;;;;;
SetVar Proc 
.data 
	tmp DWORD ?;
	color_num DWORD 255;
	lut_num DWORD 32;
    ceil real4 0.5;
.code
	fidiv color_num	;/255
	fimul lut_num	;*32
	fist tmp;
	mov eax,tmp		;L
	
    fadd ceil
	fist tmp   		;H
    mov ebx,tmp

    fsub ceil
    mov tmp,eax
	fisub tmp		;Delta

	mov [esi] , eax	;
	add esi , 4		;
	mov [esi] , ebx	;
	add esi , 4		;




	ret;
SetVar ENDP
;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;
; edi -> RGB_HL
; esi -> LutArray
; retrun edx -> NewRGB
;;;;;;;;;;;;;
CalParameter PROC USES eax ebx ecx
	
.data
	deltaR real8 ?;
	deltaG real8 ?
	deltaB real8 ?
    

    calInfo DWORD 18 DUP(?)
    relC SDWORD 12 DUP(?)
    

.code
	
	
	fstp deltaB;
	
	fstp deltaG;
	
	fstp deltaR;

	fld deltaG;
	fld deltaR;
	
	fcomip st,st(1);
	fadd
	

	jc GR;

;R>=G
RG:
	
	fld deltaB
	fld deltaR

	fcomip st,st(1);
	fadd
	jc BRG

	;R>=B R>=G
	R_BG:
		fld deltaB
		fld deltaG

		fcomip st,st(1);
		fadd

		jc BRG

		;R>=G>=B
		RGB_:
            ;;;;;;
            ; edi   = RL
            ; edi+4 = RH
            ; edi+8 = GL
            ; edi+12= GH
            ; edi+16= BL
            ; edi+20= BH
            ;;;;;;

            mov edx,OFFSET calInfo
            ;;;;c1 HLL LLL
            mov eax, [edi+4]
            mov ebx ,[edi+8]
            mov ecx ,[edi+16]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi]
            mov ebx ,[edi+8]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx

            add edx,24
            ;;;;;;
            
            ;;;;;;c2 HHL HLL

            mov eax, [edi+4]
            mov ebx ,[edi+12]
            mov ecx ,[edi+16]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi+4]
            mov ebx ,[edi+8]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx
            add edx,24
            ;;;;;;
            
            ;;;;;;c3 HHH HHL
            mov eax, [edi+4]
            mov ebx ,[edi+12]
            mov ecx ,[edi+20]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi+4]
            mov ebx ,[edi+12]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx
            add edx,24

            
            mov ebx,OFFSET calInfo
            mov edx,OFFSET relC
            call CalC
           

			mov eax,1;
			jp ED;

		;R>=B>=G
		RBG:

            mov edx,OFFSET calInfo
            ;;;;c1 HLL LLL
            mov eax, [edi+4]
            mov ebx ,[edi+8]
            mov ecx ,[edi+16]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi]
            mov ebx ,[edi+8]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx

            add edx,24
            ;;;;;;
            
            ;;;;;;c2 HHH HLH

            mov eax, [edi+4]
            mov ebx ,[edi+12]
            mov ecx ,[edi+20]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi+4]
            mov ebx ,[edi+8]
            mov ecx ,[edi+20]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx
            add edx,24
            ;;;;;;
            
            ;;;;;;c3 HLH HLL
            mov eax, [edi+4]
            mov ebx ,[edi+8]
            mov ecx ,[edi+20]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi+4]
            mov ebx ,[edi+8]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx
            add edx,24

            
            mov ebx,OFFSET calInfo
            mov edx,OFFSET relC
            call CalC

			mov eax,2;
			jp ED;
		

		jp ED;

	;B>=R>=G
	BRG:
        mov edx,OFFSET calInfo
        ;;;;c1 HLH LLH
        mov eax, [edi+4]
        mov ebx ,[edi+8]
        mov ecx ,[edi+20]

        mov [edx],eax
        mov [edx+4],ebx
        mov [edx+8],ecx
            
        mov eax, [edi]
        mov ebx ,[edi+8]
        mov ecx ,[edi+20]

        mov [edx+12],eax
        mov [edx+16],ebx
        mov [edx+20],ecx

        add edx,24
        ;;;;;;
            
        ;;;;;;c2 HHH HLH

        mov eax, [edi+4]
        mov ebx ,[edi+12]
        mov ecx ,[edi+20]

        mov [edx],eax
        mov [edx+4],ebx
        mov [edx+8],ecx
            
        mov eax, [edi+4]
        mov ebx ,[edi+8]
        mov ecx ,[edi+20]

        mov [edx+12],eax
        mov [edx+16],ebx
        mov [edx+20],ecx
        add edx,24
        ;;;;;;
            
        ;;;;;;c3 LLH LLL
        mov eax, [edi]
        mov ebx ,[edi+8]
        mov ecx ,[edi+20]

        mov [edx],eax
        mov [edx+4],ebx
        mov [edx+8],ecx
            
        mov eax, [edi]
        mov ebx ,[edi+8]
        mov ecx ,[edi+16]

        mov [edx+12],eax
        mov [edx+16],ebx
        mov [edx+20],ecx
        add edx,24

            
        mov ebx,OFFSET calInfo
        mov edx,OFFSET relC
        call CalC
		mov eax,3;
		jp ED;
	

;G>=R
GR:
	fld deltaB
	fld deltaG

	fcomip st,st(1);
	fadd
	jc BGR

	;G>=B G>=R 
	G_BR:
		fld deltaB
		fld deltaR

		fcomip st,st(1);
		fadd
		jc GBR

		GRB:
            mov edx,OFFSET calInfo
            ;;;;c1 HHL LHL
            mov eax, [edi+4]
            mov ebx ,[edi+12]
            mov ecx ,[edi+16]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi]
            mov ebx ,[edi+12]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx

            add edx,24
            ;;;;;;
            
            ;;;;;;c2 LHL LLL

            mov eax, [edi]
            mov ebx ,[edi+12]
            mov ecx ,[edi+16]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi]
            mov ebx ,[edi+8]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx
            add edx,24
            ;;;;;;
            
            ;;;;;;c3 HHH HHL
            mov eax, [edi+4]
            mov ebx ,[edi+12]
            mov ecx ,[edi+20]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi+4]
            mov ebx ,[edi+12]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx
            add edx,24

            
            mov ebx,OFFSET calInfo
            mov edx,OFFSET relC
            call CalC
			mov eax,4
			jp ED;
		GBR:
            mov edx,OFFSET calInfo
            ;;;;c1 HHH LHH
            mov eax, [edi+4]
            mov ebx ,[edi+12]
            mov ecx ,[edi+20]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi]
            mov ebx ,[edi+12]
            mov ecx ,[edi+20]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx

            add edx,24
            ;;;;;;
            
            ;;;;;;c2 LHL LLL

            mov eax, [edi]
            mov ebx ,[edi+12]
            mov ecx ,[edi+16]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi]
            mov ebx ,[edi+8]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx
            add edx,24
            ;;;;;;
            
            ;;;;;;c3 LHH LHL
            mov eax, [edi]
            mov ebx ,[edi+12]
            mov ecx ,[edi+20]

            mov [edx],eax
            mov [edx+4],ebx
            mov [edx+8],ecx
            
            mov eax, [edi]
            mov ebx ,[edi+12]
            mov ecx ,[edi+16]

            mov [edx+12],eax
            mov [edx+16],ebx
            mov [edx+20],ecx
            add edx,24

            
            mov ebx,OFFSET calInfo
            mov edx,OFFSET relC
            call CalC

			mov eax,5
			jp ED;

	
	;B=>G>=R
	BGR:
        
        mov edx,OFFSET calInfo
        ;;;;c1 HHH LHH
        mov eax, [edi+4]
        mov ebx ,[edi+12]
        mov ecx ,[edi+20]

        mov [edx],eax
        mov [edx+4],ebx
        mov [edx+8],ecx
            
        mov eax, [edi]
        mov ebx ,[edi+12]
        mov ecx ,[edi+20]

        mov [edx+12],eax
        mov [edx+16],ebx
        mov [edx+20],ecx

        add edx,24
        ;;;;;;
            
        ;;;;;;c2 LHH LLH

        mov eax, [edi]
        mov ebx ,[edi+12]
        mov ecx ,[edi+20]

        mov [edx],eax
        mov [edx+4],ebx
        mov [edx+8],ecx
            
        mov eax, [edi]
        mov ebx ,[edi+8]
        mov ecx ,[edi+20]

        mov [edx+12],eax
        mov [edx+16],ebx
        mov [edx+20],ecx
        add edx,24
        ;;;;;;
            
        ;;;;;;c3 LLH LLL
        mov eax, [edi]
        mov ebx ,[edi+8]
        mov ecx ,[edi+20]

        mov [edx],eax
        mov [edx+4],ebx
        mov [edx+8],ecx
            
        mov eax, [edi]
        mov ebx ,[edi+8]
        mov ecx ,[edi+16]

        mov [edx+12],eax
        mov [edx+16],ebx
        mov [edx+20],ecx
        add edx,24

            
        mov ebx,OFFSET calInfo
        mov edx,OFFSET relC
        call CalC


		mov eax,6
		jp ED;



ED:
    
    
    ;;;;;1
    mov ebx,[edi];RL
    mov eax,[edi+8];GL
    mov ecx,33
    mul ecx;GL*33
    add ebx,eax;RL+GL*33
    mov eax,[edi+16];BL
    mov ecx,1089
    mul ecx;BL*33*33
    add eax,ebx
    mov ecx,12
    mul ecx

    ;call WriteInt
    ;call Crlf

    mov ebx,esi
    add ebx,eax
    mov eax,[ebx]
    ;call WriteInt
    ;call Crlf
    mov [relC+36],eax

    ;;;;;;2
    mov ebx,[edi]
    mov eax,[edi+8]
    mov ecx,33
    mul ecx
    add ebx,eax
    mov eax,[edi+16]
    mov ecx,1089
    mul ecx
    add eax,ebx
    mov ecx,12
    mul ecx

    mov ebx,esi
    add ebx,eax
    mov eax,[ebx+4]
    mov [relC+40],eax

    ;;;;;;;;;3
    mov ebx,[edi]
    mov eax,[edi+8]
    mov ecx,33
    mul ecx
    add ebx,eax
    mov eax,[edi+16]
    mov ecx,1089
    mul ecx
    add eax,ebx
    mov ecx,12
    mul ecx

    mov ebx,esi
    add ebx,eax
    mov eax,[ebx+8]
    mov [relC+44],eax
    
    



    mov eax,OFFSET relC


    fld deltaR
    fld deltaG
    fld deltaB

	call CalNewRGB


	ret;

CalParameter ENDP

;;;;;;;;;;;;;;
; ebx -> calInfo
; edx -> relC
; esi -> LutArray
; return -> relC
;;;;;;;;;;;;;;
CalC PROC USES edi ecx eax
    
    mov edi,ebx
    
    push ebp
    mov ebp,esp
    sub esp,16
    mov [ebp-4],esi

    mov eax,0
    

    mov ecx,3

    CalFirstAndSecondLoop:
        push ecx;

        call CalIndex
        
        mov [ebp-8],eax
        add edi,12
        call CalIndex
        mov [ebp-12],eax
        add edi,12
        

        mov ecx,3

        CalC123:
            ;;;; [ebp-4]=LutArray
            ;;;; [ebp-8]=first
            ;;;; [ebp-12]=second
            mov eax,[ebp-8]
            ;call WriteInt
            ;call Crlf
            mov eax,[ebp-12]
            ;call WriteInt
            ;call Crlf
            ;call WaitMsg

            mov eax,3

            sub eax,ecx

            push ecx
            
            add eax,eax
            add eax,eax


            mov esi,[ebp-4];LutArray
            add esi,[ebp-8];first
           
            add esi,eax
            mov ecx,[esi];first rel

            mov esi,[ebp-4];LutArray
            add esi,[ebp-12];Second
            add esi,eax;
            mov eax,[esi]
            sub ecx,eax
            mov [edx],ecx
            add edx,4


            pop ecx

            Loop CalC123


        pop ecx;

        loop CalFirstAndSecondLoop

    mov esi,[ebp-4]

    mov esp,ebp
    pop ebp



    ret

CalC ENDP


;;;;;;;;;;;;;;;;;;;
; edi -> CalInfo
; return eax
;;;;;;;;;;;;;;;;;;;
CalIndex PROC USES ebx ecx edx
    
    mov     eax,[edi]
    ;call    WriteInt
    ;call    Crlf
    mov     eax,[edi+4]
    ;call    WriteInt
    ;call    Crlf
    mov     eax,[edi+8]
    ;call    WriteInt
    ;call    Crlf
    ;call    Crlf
    
    push    ebp
    mov     ebp,esp;
    sub     esp,16;

    ;;;;local

    mov     ebx,[edi]
    mov     ecx,[edi+4]
    mov     edx,[edi+8]

    mov     [ebp-4], ebx
    mov     [ebp-8], ecx
    mov     [ebp-12], edx
    
    mov     ebx,[ebp-4]    
    mov     eax,[ebp-8]
    mov     ecx,33
    mul     ecx
    add     ebx,eax;
    mov     eax,[ebp-12]
    mov     ecx,1089
    mul     ecx


    add     eax,ebx

    mov     ecx,12

    mul     ecx

    mov     esp,ebp
    pop     ebp

    

    ret
CalIndex ENDP


;;;;;;;;;;;;;;;
; esi -> LutArray
; deltaRGB
; eax -> relC
; return edx -> NewRGB 
;;;;;;;;;;;;;;;
CalNewRGB PROC USES ebx ecx
.data
    NewRGB BYTE 3 DUP(?)
    tt real8 0.0
.code
    
    ;call WriteFloat
    ;call Crlf
	fstp deltaB;
    ;call WriteFloat
    ;call Crlf
	fstp deltaG;
    ;call WriteFloat
    ;call Crlf
    ;call Crlf
	fstp deltaR;

    fld tt
    fst deltaR
    fst deltaG
    fstp deltaB
    

    push ebp;
    mov ebp,esp
    sub esp,28
    mov [ebp-4],esi
    mov [ebp-8],eax
    mov ebx,500000
    mov [ebp-12],ebx
    mov ebx,1000000
    mov [ebp-16],ebx
    mov ebx,255
    mov [ebp-24],ebx

    ;;;;;; [ebp-4]=LutArray
    ;;;;;; [ebp-8]=relC
    ;;;;;; [ebp-12]=500000
    ;;;;;; [ebp-16]=1000000
    ;;;;;; [ebp-20]=tmp
    ;;;;;; [ebp-24]=255

    mov eax,[ebp-8]
    ;;;;;;;;;;;;;;;NewR
    

    fild SDWORD PTR [eax+36];Init
    ;call Writefloat
    ;call Crlf

    fld deltaR;

    fild SDWORD PTR [eax]
    fmul;dR*c1
    fadd;init + dr*c1

    fld deltaG
    fild SDWORD PTR [eax+12];c2
    fmul;dG*c2
    fadd;init + dR*c1 + dG*c2
 
    fld deltaB
    fild SDWORD PTR [eax+24];c3
    fmul;dB*c3
    fadd;init + dR*c1 + dG*c2 +dB*c3


    fidiv DWORD PTR [ebp-16]
    fimul DWORD PTR [ebp-24]
    ;call WriteFloat
    ;call Crlf
    
    fldz
    fcomip st,st(1)
    fistp SDWORD PTR [ebp-20]

    jnc SET_NR

    jmp END_NR

    SET_NR:
        fldz
        fistp SDWORD PTR [ebp-20]

    END_NR:

    mov ebx,[ebp-20]
    
    .IF ebx>255
        mov ebx,255
    .ENDIF

    mov [NewRGB],bl
    
    ;;;;;;;NewG
    fild SDWORD PTR [eax+40]
    ;call WriteFloat
    ;call Crlf
    fld deltaR
    fild SDWORD PTR [eax+4]
    fmul
    fadd

    fld deltaG
    fild SDWORD PTR [eax+16]
    fmul
    fadd

    fld deltaB
    fild SDWORD PTR [eax+28]
    fmul
    fadd


    fidiv DWORD PTR [ebp-16]
    fimul DWORD PTR [ebp-24]

    fldz
    fcomip st,st(1)
    fistp SDWORD PTR [ebp-20]

    jnc SET_NG

    jmp END_NG

    SET_NG:

        fldz
        fistp SDWORD PTR [ebp-20]

    END_NG:

    mov ebx,[ebp-20]


    .IF ebx>255
        mov ebx,255
    .ENDIF
    mov [NewRGB+1],bl


    ;;;;;;;NewB
    fild DWORD PTR [eax+44]
    ;call WriteFloat
    ;call Crlf
    fld deltaR
    fild SDWORD PTR [eax+8]
    fmul
    fadd

    fld deltaG
    fild SDWORD PTR [eax+20]
    fmul
    fadd

    fld deltaB
    fild DWORD PTR [eax+32]
    fmul
    fadd

    fidiv DWORD PTR [ebp-16]
    fimul SDWORD PTR [ebp-24]
    ;call WriteFloat
    ;call Crlf
    
    fldz
    fcomip st,st(1)

    fistp SDWORD PTR [ebp-20]

    jnc SET_NB
    jmp END_NB

    SET_NB:
        fldz
        fistp SDWORD PTR [ebp-20]

    END_NB:
    
    mov ebx,[ebp-20]
   


    .IF ebx>255
        mov ebx,255
    .ENDIF
    mov [NewRGB+2],bl

    ;;;;;;;;;;;;;;;;;;;;;;;
    mov esi,[ebp-4]

    mov esp,ebp
    pop ebp


    mov edx,OFFSET NewRGB

    push eax

    mov eax,0
    mov al,[NewRGB]
    ;call WriteInt
    mov eax,0
    mov al,[NewRGB+1]
    ;call WriteInt
    mov eax,0
    mov al,[NewRGB+2]
    ;call WriteInt
    ;call Crlf
    ;call Crlf
    
    pop eax
    
    ;call WaitMsg
    ret




CalNewRGB ENDP





call    WaitMsg
END     main