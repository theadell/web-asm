format ELF64 executable

;; Compile time constants 

SYS_write equ 1
SYS_exit equ 60
SYS_socket equ 41

AF_INET equ 2
SOCK_STREAM equ 1

STDOUT equ 1
STDERR equ 2

EXIT_SUCCESS equ 0
EXIT_FAILURE equ 1

;; some macros to make life easy 
macro write fd,buf,count
{
    mov rax, SYS_write
    mov rdi, fd
    mov rsi, buf
    mov rdx, count
    syscall
}

macro socket domain, type, protocol
{
    mov rax, SYS_socket
    mov rdi, domain
    mov rsi, type
    mov rdx, protocol
    syscall
}

macro exit code
{
    mov rax, SYS_exit
    mov rdi, code
    syscall
}

;; code section
segment readable executable
entry main
main:
  write STDOUT, start, start_len
  socket AF_INET, SOCK_STREAM, 0
  cmp rax, 0 
  jl error
  mov dword [sockfd], eax 
  exit 0

error:
  write STDERR, error_msg, error_msg_len
  exit 1

;; db - 1 byte 
;; dw - 2 byte 
;; dd - 4 byte 
;; dq - 8 byte

;; data section
segment readable writeable
sockfd dd 0
start db "hello web server!", 10
start_len = $ - start
error_msg db "ERROR!", 10
error_msg_len = $ - error_msg
