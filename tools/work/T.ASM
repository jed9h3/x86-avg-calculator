.model small
.stack 100
.data
illegal db "error: illegal digit please renter the number again$"
nmsg db "enter an amount from 2-255$"
bsizemsg db "enter the integer size (1 min)$"
asknumber db "enter a number$"
separator db "------------------------------------------------$"
newline db 0ah,0dh,"$"
summation db "Summation: $"
avg db "Average: $"
bsize db 0
n db 0
pointer dw ?
temp dw ?
storage dw ?
counter dw ?
limit dw 0
.code
mov ax,@data
mov ds,ax
;============================
;READING SIZE AND INTEGER LENGTH
mov ah,09h
lea dx,nmsg
int 21h
lea dx,newline
int 21h
lea dx,separator
int 21h
lea dx,newline
int 21h
mov cx,2
CALL READ
lea dx , n
mov pointer,dx
xor dx,dx
CALL WRITE
mov cx,1
mov ah,09h
lea dx,separator
int 21h
lea dx,newline
int 21h
lea dx,bsizemsg
int 21h
lea dx,newline
int 21h
lea dx,separator
int 21h
lea dx,newline
int 21h
CALL READ
lea dx , bsize
mov pointer,dx
xor dx,dx
CALL WRITE
;==========================================
;ALLOCATING MEMORY FOR THE NUMBERS
mov al,n
xor ah,ah
xor bh,bh
mov dl,2
mul bsize
div dl
xor dl,dl
cmp ah,0
jz oddie
inc al
oddie:
mov bl,al
mov ah,48h
int 21h
jnc shiftie
mov ah,09h
lea dx,illegal
int 21h
mov ah,4ch
int 21h
shiftie:
mov storage,ax
;---------------
;filling allocated memmory with 0s
mov al,n
xor ah,ah
mul bsize
mov cx,ax
mov di,0
clear:
mov bp,storage
mov byte ptr [bp+di],0
inc di
loop clear
;--------------- 
;===========================================================
;READING THE NUMBERS
xor ch,ch
mov cl,bsize
mov di,cx
mov cl,n
dec di
mov limit,2
numbers_loop:
push ax
mov ah,09h
push dx
lea dx,separator
int 21h
lea dx,newline
int 21h
lea dx,asknumber
int 21h
lea dx,newline
int 21h
lea dx,separator
int 21h
lea dx,newline
int 21h
pop dx
pop ax
mov al,bsize
xor ah,ah
xor dx,dx
mov counter,cx
mov cx,ax
CALL READ
CALL WRITE_BCD
mov dl,bsize
xor dh,dh
xor di,di
mov cx,limit
stupid_loop:
add di,dx
loop stupid_loop
inc limit
xor dl,dl
dec di
mov cx,counter
loop numbers_loop
;===========================================================================
;CALCULATIONS
mov al,bsize
xor ah,ah
mov counter,ax
mov al,n
mul bsize
sub ax,1
mov limit,ax
push ax
mov cx,ax
mov di,ax
xor ax,ax
mov al,bsize
sub cx,ax
xor ax,ax
inc cx
addition_loop:
mov si,cx
dec si
mov bp,storage
mov bl,byte ptr [bp+di]
mov bh,byte ptr [bp+si]
mov dl,bl
and dl,00001111b
mov dh,bh
and dh,00001111b
CALL ADD_BCD
mov ah,dl
mov dl,bl
and dl,11110000b
mov dh,bh
and dh,11110000b
shr dh,4
shr dl,4
CALL ADD_BCD
shl dl,4
add dl,ah
mov bp,storage
mov byte ptr [bp+di],dl
jmp hop
makeitlong:
jmp addition_loop
hop:
dec counter
cmp counter,0
jg continue
cmp al,0
jz continue2
dec di
cmp limit,di
jle differ
mov bp,storage
mov byte ptr [bp+di],al
jmp continue2
differ:
mov bp,storage
add byte ptr [bp+di],al
continue2:
cmp limit,di
jle skipp
mov limit,di
skipp:
pop di
push di
inc di
xor ax,ax
mov al,bsize
mov counter,ax
xor ax,ax
continue:
dec di
loop makeitlong
;----------------------
;print sum
push ax
mov ah,09h
push dx
lea dx,separator
int 21h
lea dx,newline
int 21h
lea dx,summation
int 21h
pop dx
pop ax
mov ah,02h
call PRINTER
mov ah, 09h
lea dx,newline
int 21h
;----------------------
push ax
mov ah,09h
push dx
lea dx,avg
int 21h
pop dx
pop ax
mov di,limit
pop cx
push cx
sub cx,limit
inc cx
xor dx,dx
xor ah,ah
xor dh,dh
xor ax,ax
mov counter,0
division_loop:
mov bp,storage
mov bl,byte ptr [bp+di]
mov bh,bl
shr bh,4
mov dl,bh
push dx
mov si,10
mul si
pop dx
add ax,dx
mov dl,n
xor dh,dh
cmp dx,ax
jle hop2
resume:
call VSHIFT
mov bh,bl
shl bh,4
shr bh,4
mov si,10
mul si
xor dh,dh
mov dl,bh
add ax,dx
mov dl,n
jmp hopp
dumblable:
jmp division_loop
hopp:
cmp dx,ax
jle hop3
call VSHIFT
jmp finishline
hop3:
mov dl,n
sub ax,dx
inc counter
mov dl,n
cmp ax,dx
jge hop3
call VSHIFT
jmp finishline
hop2:
mov dl,n
xor dh,dh
sub ax,dx
inc counter
mov dl,n
cmp ax,dx
jge hop2
jmp resume
finishline:
inc di
loop dumblable
cmp counter,0
jz skippppp
call VSHIFT
skippppp:
mov ah,4ch
int 21h
;===========================================================================
;PROCes
READ PROC
pop temp
again:
push cx
push word 07ah
xor bx,bx
mov ah,01h
readn: 
int 21h
cmp al,0dh
jz skippp
cmp al,030h
jl notnumber
cmp al,039h
jg notnumber
sub al,30h
mov bh,al
int 21h
cmp al,0dh
jz center2
cmp al,030h
jl notnumber
cmp al,039h
jg notnumber
sub al,30h
mov bl,al
push bx
loop readn
jmp skippp
notnumber:
pop bx
cmp bx,07ah
jne notnumber
pop cx
push ax
mov ah,09h
push dx
lea dx,newline
int 21h
lea dx,illegal
int 21h
lea dx,newline
int 21h
lea dx,separator
int 21h
lea dx,newline
int 21h
pop dx
pop ax
jmp again
center2:
mov bl,079h
push bx
skippp:
push ax
mov ah,09h
push dx
lea dx,newline
int 21h
pop dx
pop ax
push temp
RET
READ ENDP

WRITE PROC
pop temp
xor si,si
xor di,di
xor ah,ah
mov si,pointer
sizestack:
pop bx
cmp bx,07ah
jz sizestackend
cmp bl,079h
jz split
mov cx,di
mov al,01
mov dl,10
cmp cx,00
jz zeroo1
pow1:
mul dl
loop pow1
zeroo1:
mul bl
add byte ptr [si], al
inc di
jmp sizestack
split:
mov bl,bh
xor bh,bh
push bx
jmp sizestack
sizestackend:
push temp
RET 
WRITE ENDP

WRITE_BCD PROC
pop temp
mov si,storage
BCD_LOOP:
pop bx
cmp bx,07ah
jz BCD_LOOP_END
cmp bl,079h
jz BCD_LOOP_V2
mov bp,si
xor ah,ah
mov al,bh
shl al, 4
add al,bl
mov byte ptr [bp+di],al
dec di
jmp BCD_LOOP
BCD_LOOP_V2:
pop dx
cmp dx,07ah
jz V2_END
mov bp,si
add bp,di
mov [bp],dl
mov AX, [BP]
shl AX, 4
mov [BP], AX
add [bp],bh
mov bh,dh
dec di
jmp BCD_LOOP_V2
V2_END:
mov bp,si
add bp,di
mov [bp],bh
BCD_LOOP_END:
push temp
RET 
WRITE_BCD ENDP

ADD_BCD PROC
add dl,dh
add dl,al
xor al,al
cmp dl,9
jg fixing_bcd
jle finishie
fixing_bcd:
mov al,1
and dl,00001111b
add dl,6
and dl,00001111b
finishie:
RET
ADD_BCD ENDP

PRINTER PROC
pop temp
mov di,limit
pop cx
push cx
inc cx
sub cx,di
cmp cx,0
printie_loop:
mov bp,storage
mov dh,byte ptr [bp+di]
mov dl,dh
shr dl,4
add dl,30h
int 21h
mov dl,dh
shl dl,4
shr dl,4
add dl,30h
int 21h
inc di
loop printie_loop
push temp
RET
PRINTER ENDP

VSHIFT PROC
pop temp
push ax
mov ah,02h
mov dx,counter
add dl,30h
int 21h
mov counter,0
pop ax
xor dh,dh
push temp
RET
VSHIFT ENDP
end