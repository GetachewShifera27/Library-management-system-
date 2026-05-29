.model small
.stack 100h
.data

; ================= MENUS =================
mainMenu db 10,13,"=== LIBRARY SYSTEM ===",10,13
        db "1. Student",10,13
        db "2. Admin",10,13
        db "0. Exit",10,13
        db "Choose: $"

studentMenu db 10,13,"=== STUDENT MENU ===",10,13
           db "1. Register",10,13
           db "2. Login",10,13
           db "0. Back",10,13
           db "Choice: $"

studDash db 10,13,"=== STUDENT DASHBOARD ===",10,13
         db "1. Search Books",10,13
         db "2. View Books",10,13
         db "3. Borrow Book",10,13
         db "4. Return Book",10,13
         db "5. My Books",10,13
         db "0. Logout",10,13
         db "Choice: $"

adminMenu db 10,13,"=== ADMIN PANEL ===",10,13
         db "1. Add Book",10,13
         db "2. Update Book",10,13
         db "3. Delete Book",10,13
         db "4. View Books",10,13
         db "5. Borrow Status",10,13
         db "0. Back",10,13
         db "Choice: $"

; ================= MESSAGES =================
msg1 db 10,13,"Enter Name: $"
msg2 db 10,13,"Enter Password: $"
msg3 db 10,13,"Registration Successful!$"
msg4 db 10,13,"Login Successful!$"
msg5 db 10,13,"Invalid!$"
msg6 db 10,13,"Book added!$"
msg7 db 10,13,"Book updated!$"
msg8 db 10,13,"Book deleted!$"
msg9 db 10,13,"Enter book name: $"
msg10 db 10,13,"Enter copies: $"
msg11 db 10,13,"Book not found!$"
msg12 db 10,13,"Borrowed successfully!$"
msg13 db 10,13,"No copies available!$"
msg14 db 10,13,"Returned successfully!$"
msg15 db 10,13,"You haven't borrowed this book!$"
msg16 db 10,13,"No books in library!$"
msg17 db 10,13,"Enter book number: $"
msg18 db 10,13,"=== ADMIN LOGIN ===",10,13,"$"
msg19 db "Enter username: $"
msg20 db 10,13,"Enter password: $"
msg21 db 10,13,"Admin access granted!$"
msg22 db 10,13,"=== YOUR BORROWED BOOKS ===",10,13,"$"
msg23 db 10,13,"=== SEARCH RESULTS ===",10,13,"$"
msg24 db 10,13,"No books borrowed yet!$"
msg25 db 10,13,"Borrowed by Student ID: $"
msg26 db 10,13,"Copies borrowed: $"
msg27 db 10,13,"=== CURRENTLY BORROWED BOOKS ===",10,13,"$"

press db 10,13,"Press any key...$"
line db "----------------------------------------$"

; ================= DATA =================
maxStudents equ 10
maxBooks equ 30

studentCount db 0
studentNames db 10 dup(25 dup('$'))
studentPasswords db 10 dup(25 dup('$'))
currentStudent db 0FFh

bookCount db 5
bookNames db 30 dup(30 dup('$'))
bookAvail db 30 dup(0)
bookBorrowed db 30 dup(0)
studBorrowed db 30 dup(0)

; Track which student borrowed which book (store student index)
borrowerStudent db 30 dup(0FFh)

; Sample books
bk1 db "Assembly Language$"
bk2 db "Java Programming$"
bk3 db "Data Structures$"
bk4 db "Python$"
bk5 db "C++$"

; Buffers
tempName db 25 dup('$')
tempPass db 25 dup('$')
loginName db 25 dup('$')
loginPass db 25 dup('$')
searchName db 25 dup('$')
adminUser db 25 dup('$')
adminPass db 25 dup('$')
tempNum dw 0

; Admin credentials
adminUsername db "admin$"
adminPassword db "admin123$"

.code

; ================= UTILITIES =================
cls proc
    mov ah,0
    mov al,3
    int 10h
    ret
cls endp

waitKey proc
    lea dx,press
    mov ah,9
    int 21h
    mov ah,1
    int 21h
    ret
waitKey endp

inputStr proc
    push di
in_loop:
    mov ah,1
    int 21h
    cmp al,13
    je in_done
    mov [di],al
    inc di
    jmp in_loop
in_done:
    mov byte ptr [di],'$'
    pop di
    ret
inputStr endp

strcmp proc

comp:
    mov al,[si]
    mov bl,[di]
    cmp al,'$'
    je chk_end
    cmp bl,'$'
    je not_eq
    cmp al,bl
    jne not_eq
    inc si
    inc di
    jmp comp
chk_end:
    cmp bl,'$'
    je equal
not_eq:
    mov ax,1
    jmp done
equal:
    mov ax,0
done:

    ret
strcmp endp

strcpy proc
cp:
    mov al,[si]
    mov [di],al
    cmp al,'$'
    je cp_done
    inc si
    inc di
    jmp cp
cp_done:
    ret
strcpy endp

inputNum proc
    mov bx,0
num_in:
    mov ah,1
    int 21h
    cmp al,13
    je num_done
    sub al,30h
    mov cl,al
    mov ax,bx
    mov dx,10
    mul dx
    add ax,cx
    mov bx,ax
    jmp num_in
num_done:
    mov ax,bx
    ret
inputNum endp

printNum proc
    push ax
    cmp al,10
    jb one
    mov ah,0
    mov dl,10
    div dl
    push ax
    mov dl,al
    add dl,30h
    mov ah,2
    int 21h
    pop ax
    mov dl,ah
    add dl,30h
    jmp print
one:
    add al,30h
    mov dl,al
print:
    mov ah,2
    int 21h
    pop ax
    ret
printNum endp

; ================= INIT BOOKS =================
initBooks proc
    ; Book 1
    lea si,bk1
    lea di,bookNames
    call strcpy
    mov bookAvail[0],5
    mov bookBorrowed[0],0
    mov borrowerStudent[0],0FFh
    
    ; Book 2
    lea si,bk2
    lea di,bookNames+30
    call strcpy
    mov bookAvail[1],4
    mov bookBorrowed[1],0
    mov borrowerStudent[1],0FFh
    
    ; Book 3
    lea si,bk3
    lea di,bookNames+60
    call strcpy
    mov bookAvail[2],6
    mov bookBorrowed[2],0
    mov borrowerStudent[2],0FFh
    
    ; Book 4
    lea si,bk4
    lea di,bookNames+90
    call strcpy
    mov bookAvail[3],3
    mov bookBorrowed[3],0
    mov borrowerStudent[3],0FFh
    
    ; Book 5
    lea si,bk5
    lea di,bookNames+120
    call strcpy
    mov bookAvail[4],3
    mov bookBorrowed[4],0
    mov borrowerStudent[4],0FFh
    ret
initBooks endp

; ================= DISPLAY BOOKS =================
showBooks proc
    mov al,bookCount
    cmp al,0
    jne sb_ok
    lea dx,msg16
    mov ah,9
    int 21h
    ret
sb_ok:
    mov cx,0
    mov cl,bookCount
    mov bx,0
    mov dl,'1'
sb_loop:
    push cx
    
    ; Print book number
    mov ah,2
    int 21h
    mov dl,'.'
    int 21h
    mov dl,' '
    int 21h
    mov dl,' '
    int 21h
    
    ; Print book name
    lea dx,bookNames
    mov al,bl
    mov ah,30
    mul ah
    add dx,ax
    mov ah,9
    int 21h
    
    ; Print copies
    mov dl,' '
    mov ah,2
    int 21h
    mov dl,' '
    int 21h
    mov al,bookAvail[bx]
    call printNum
    
    call waitKey
    
    inc bl
    mov dl,'1'
    add dl,bl
    pop cx
    loop sb_loop
    ret
showBooks endp

; ================= MAIN =================
main:
    mov ax,@data
    mov ds,ax
    call initBooks

start:
    call cls
    lea dx,mainMenu
    mov ah,9
    int 21h
    mov ah,1
    int 21h
    
    cmp al,'1'
    je student
    cmp al,'2'
    je adminLogin
    cmp al,'0'
    je exit
    jmp start

; ================= ADMIN LOGIN =================
adminLogin:
    call cls
    lea dx,msg18
    mov ah,9
    int 21h
    
    lea dx,msg19
    mov ah,9
    int 21h
    lea di,adminUser
    call inputStr
    
    lea dx,msg20
    mov ah,9
    int 21h
    lea di,adminPass
    call inputStr
    
    ; Compare credentials
    lea si,adminUser
    lea di,adminUsername
    call strcmp
    cmp ax,0
    jne adminFail
    
    lea si,adminPass
    lea di,adminPassword
    call strcmp
    cmp ax,0
    jne adminFail
    
    lea dx,msg21
    mov ah,9
    int 21h
    call waitKey
    jmp admin

adminFail:
    lea dx,msg5
    mov ah,9
    int 21h
    call waitKey
    jmp start

; ================= STUDENT =================
student:
    call cls
    lea dx,studentMenu
    mov ah,9
    int 21h
    mov ah,1
    int 21h
    
    cmp al,'1'
    je register
    cmp al,'2'
    je login
    cmp al,'0'
    jmp start
    jmp student

register:
    call cls
    lea dx,msg1
    mov ah,9
    int 21h
    lea di,tempName
    call inputStr
    
    lea dx,msg2
    mov ah,9
    int 21h
    lea di,tempPass
    call inputStr
    
    mov al,studentCount
    mov bl,25
    mul bl
    mov si,ax
    lea di,studentNames[si]
    lea si,tempName
    call strcpy
    
    mov al,studentCount
    mov bl,25
    mul bl
    mov si,ax
    lea di,studentPasswords[si]
    lea si,tempPass
    call strcpy
    
    inc studentCount
    lea dx,msg3
    mov ah,9
    int 21h
    call waitKey
    jmp student

login:
    call cls
    lea dx,msg1
    mov ah,9
    int 21h
    lea di,loginName
    call inputStr
    
    lea dx,msg2
    mov ah,9
    int 21h
    lea di,loginPass
    call inputStr
    
    mov cx,0
    mov cl,studentCount
    mov bx,0
    
loginLoop:
    cmp bx,cx
    je loginFail
    
    mov al,bl
    push bx
    mov bl,25
    mul bl
    mov si,ax
    lea si,studentNames[si]
    lea di,loginName
    call strcmp
    pop bx
    cmp ax,0
    jne nextStudent
    
    mov al,bl
    push bx
    mov bl,25
    mul bl
    mov si,ax
    lea si,studentPasswords[si]
    lea di,loginPass
    call strcmp
    pop bx
    cmp ax,0
    je loginSuccess
    
nextStudent:
    inc bx
    jmp loginLoop

loginSuccess:
    mov currentStudent,bl
    lea dx,msg4
    mov ah,9
    int 21h
    call waitKey
    jmp studDashboard

loginFail:
    lea dx,msg5
    mov ah,9
    int 21h
    call waitKey
    jmp student

; ================= STUDENT DASHBOARD =================
studDashboard:
    call cls
    lea dx,studDash
    mov ah,9
    int 21h
    mov ah,1
    int 21h
    
    cmp al,'1'
    je searchBooks
    cmp al,'2'
    je viewBooks
    cmp al,'3'
    je borrowBook
    cmp al,'4'
    je returnBook
    cmp al,'5'
    je myBooks
    cmp al,'0'
    jmp student
    jmp studDashboard

searchBooks:
    call cls
    lea dx,msg23
    mov ah,9
    int 21h
    lea dx,msg9
    mov ah,9
    int 21h
    lea di,searchName
    call inputStr
    
    mov cx,0
    mov cl,bookCount
    mov bx,0
    mov dh,0
    
searchLoop:
    push cx
    lea si,bookNames
    mov al,bl
    mov ah,30
    mul ah
    add si,ax
    lea di,searchName
    call strcmp
    cmp ax,0
    jne nextSearch
    
    inc dh
    lea dx,bookNames
    mov al,bl
    mov ah,30
    mul ah
    add dx,ax
    mov ah,9
    int 21h
    mov dl,' '
    mov ah,2
    int 21h
    mov al,bookAvail[bx]
    call printNum
    call waitKey
    
nextSearch:
    inc bx
    pop cx
    loop searchLoop
    
    cmp dh,0
    jne searchDone
    lea dx,msg11
    mov ah,9
    int 21h
searchDone:
    call waitKey
    jmp studDashboard

viewBooks:
    call cls
    call showBooks
    call waitKey
    jmp studDashboard

borrowBook:
    call cls
    call showBooks
    lea dx,msg17
    mov ah,9
    int 21h
    call inputNum
    cmp ax,0
    je borrowInv
    cmp al,bookCount
    ja borrowInv
    dec al
    mov bl,al
    
    ; Check if student already borrowed this book
    mov al,studBorrowed[bx]
    cmp al,1
    je alreadyBorrowed
    
    ; Check if copies available
    mov al,bookAvail[bx]
    cmp al,0
    jle borrowNo
    
    ; Borrow the book - decrease available, increase borrowed
    dec bookAvail[bx]
    inc bookBorrowed[bx]
    mov studBorrowed[bx],1
    mov al,currentStudent
    mov borrowerStudent[bx],al
    
    lea dx,msg12
    mov ah,9
    int 21h
    jmp borrowDone

alreadyBorrowed:
    lea dx,msg15
    mov ah,9
    int 21h
    jmp borrowDone

borrowNo:
    lea dx,msg13
    mov ah,9
    int 21h
    jmp borrowDone

borrowInv:
    lea dx,msg11
    mov ah,9
    int 21h
borrowDone:
    call waitKey
    jmp studDashboard

returnBook:
    call cls
    
    ; First check if student has any borrowed books
    mov cx,0
    mov cl,bookCount
    mov bx,0
    mov dh,0
    
checkBorrowed:
    cmp studBorrowed[bx],1
    jne nextCheck
    inc dh
nextCheck:
    inc bx
    loop checkBorrowed
    
    cmp dh,0
    jne showReturnList
    lea dx,msg24
    mov ah,9
    int 21h
    call waitKey
    jmp studDashboard
    
showReturnList:
    mov cx,0
    mov cl,bookCount
    mov bx,0
    mov dh,0
    
returnShow:
    cmp studBorrowed[bx],1
    jne returnNext
    inc dh
    mov al,dh
    call printNum
    mov dl,'.'
    mov ah,2
    int 21h
    mov dl,' '
    int 21h
    
    lea dx,bookNames
    mov al,bl
    mov ah,30
    mul ah
    add dx,ax
    mov ah,9
    int 21h
    call waitKey
    
returnNext:
    inc bx
    loop returnShow
    
returnAsk:
    lea dx,msg17
    mov ah,9
    int 21h
    call inputNum
    cmp ax,0
    je returnInv
    cmp al,bookCount
    ja returnInv
    dec al
    mov bl,al
    
    cmp studBorrowed[bx],1
    jne returnNot
    
    ; Return the book - increase available, decrease borrowed
    inc bookAvail[bx]
    dec bookBorrowed[bx]
    mov studBorrowed[bx],0
    mov borrowerStudent[bx],0FFh
    
    lea dx,msg14
    mov ah,9
    int 21h
    jmp returnDone

returnInv:
    lea dx,msg11
    mov ah,9
    int 21h
    jmp returnDone

returnNot:
    lea dx,msg15
    mov ah,9
    int 21h
returnDone:
    call waitKey
    jmp studDashboard

; ================= MY BOOKS =================
myBooks:
    call cls
    lea dx,msg22
    mov ah,9
    int 21h
    
    mov cx,0
    mov cl,bookCount
    mov bx,0
    mov dh,0
    
myLoop:
    cmp studBorrowed[bx],1
    jne myNext
    inc dh
    mov al,dh
    call printNum
    mov dl,'.'
    mov ah,2
    int 21h
    mov dl,' '
    int 21h
    
    lea dx,bookNames
    mov al,bl
    mov ah,30
    mul ah
    add dx,ax
    mov ah,9
    int 21h
    call waitKey
    
myNext:
    inc bx
    loop myLoop
    
    cmp dh,0
    jne myDone
    lea dx,msg24
    mov ah,9
    int 21h
myDone:
    call waitKey
    jmp studDashboard

; ================= ADMIN =================
admin:
    call cls
    lea dx,adminMenu
    mov ah,9
    int 21h
    mov ah,1
    int 21h
    
    cmp al,'1'
    je addBook
    cmp al,'2'
    je updateBook
    cmp al,'3'
    je deleteBook
    cmp al,'4'
    je viewBooksAdmin
    cmp al,'5'
    je borrowStatus
    cmp al,'0'
    jmp start
    jmp admin

addBook:
    call cls
    mov al,bookCount
    cmp al,maxBooks
    jae addFull
    
    lea dx,msg9
    mov ah,9
    int 21h
    mov al,bookCount
    mov bl,30
    mul bl
    mov si,ax
    lea di,bookNames[si]
    call inputStr
    
    lea dx,msg10
    mov ah,9
    int 21h
    call inputNum
    
    mov bl,bookCount



    inc bookCount
    
    lea dx,msg6
    mov ah,9
    int 21h
    call waitKey
    jmp admin

addFull:
    lea dx,msg16
    mov ah,9
    int 21h
    call waitKey
    jmp admin

updateBook:
    call cls
    call showBooks
    lea dx,msg17
    mov ah,9
    int 21h
    call inputNum
    dec al
    mov bl,al
    
    lea dx,msg10
    mov ah,9
    int 21h
    call inputNum

    
    lea dx,msg7
    mov ah,9
    int 21h
    call waitKey
    jmp admin

deleteBook:
    call cls
    call showBooks
    lea dx,msg17
    mov ah,9
    int 21h
    call inputNum
    dec al
    mov bl,al
    
    ; Shift books left
    mov al,bl
    mov cl,bookCount
    sub cl,al
    dec cl
    
    mov al,bl
    mov ah,30
    mul ah
    mov si,ax
    
    mov al,bl
    inc al
    mov ah,30
    mul ah
    mov di,ax
    
delLoop:
    cmp cl,0
    je delDone
    push cx
    mov cx,30
shiftName:
    mov al,bookNames[di]
    mov bookNames[si],al
    inc si
    inc di
    loop shiftName
    
    ; Shift related arrays
    mov al,bookAvail[di/30]
    mov bookAvail[si/30],al
    mov al,bookBorrowed[di/30]
    mov bookBorrowed[si/30],al
    mov al,borrowerStudent[di/30]
    mov borrowerStudent[si/30],al
    
    pop cx
    dec cl
    jmp delLoop
    
delDone:
    dec bookCount
    lea dx,msg8
    mov ah,9
    int 21h
    call waitKey
    jmp admin

viewBooksAdmin:
    call cls
    call showBooks
    call waitKey
    jmp admin

; ================= BORROW STATUS (FIXED) =================
borrowStatus:
    call cls
    lea dx,msg27
    mov ah,9
    int 21h
    
    mov cx,0
    mov cl,bookCount
    mov bx,0
    mov dh,0
    
    ; First loop: Check if any books are borrowed
checkLoop:
    push cx
    mov al,bookBorrowed[bx]
    cmp al,0
    je noBorrow
    inc dh
noBorrow:
    inc bx
    pop cx
    loop checkLoop
    
    ; If no books borrowed, show message and return
    cmp dh,0
    jne showBorrowed
    lea dx,msg24
    mov ah,9
    int 21h
    call waitKey
    jmp admin
    
showBorrowed:
    ; Reset for second loop to display
    mov cx,0
    mov cl,bookCount
    mov bx,0
    mov dh,0
    
displayLoop:
    push cx
    mov al,bookBorrowed[bx]
    cmp al,0
    je skipDisplay
    
    inc dh
    
    ; Print book number
    mov al,dh
    call printNum
    mov dl,'.'
    mov ah,2
    int 21h
    mov dl,' '
    int 21h
    
    ; Print book name
    push dx
    lea dx,bookNames
    mov al,bl
    mov ah,30
    mul ah
    add dx,ax
    mov ah,9
    int 21h
    pop dx
    call waitKey
    
    ; Print copies borrowed
    lea dx,msg26
    mov ah,9
    int 21h
    mov al,bookBorrowed[bx]
    call printNum
    call waitKey
    
    ; Print student ID who borrowed
    mov al,borrowerStudent[bx]
    cmp al,0FFh
    je skipStudent
    lea dx,msg25
    mov ah,9
    int 21h
    mov al,borrowerStudent[bx]
    add al,31h
    mov dl,al
    mov ah,2
    int 21h
    call waitKey
    
skipStudent:
    call waitKey
    
skipDisplay:
    inc bx
    pop cx
    loop displayLoop
    
    call waitKey
    jmp admin

exit:
    mov ah,4ch
    int 21h

end main