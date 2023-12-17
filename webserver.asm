format ELF64 executable

;; Compile time constants 

SYS_write equ 1
SYS_exit equ 60
SYS_socket equ 41
SYS_bind equ 49

AF_INET equ 2
SOCK_STREAM equ 1

INADDR_ANY equ 0

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

macro syscall3 number, a, b, c 
{
    mov rax, number
    mov rdi, a 
    mov rsi, b
    mov rdx, c 
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

macro bind sockfd, addr, addr_len
{
    syscall3 SYS_bind, sockfd, addr, addr_len
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
  ;; Startup message 
  write STDOUT, start, start_len

  ;; Create an internet (ipv4) stream (tcp) socket file descriptor 
  write STDOUT, socket_trace_msg, socket_trace_msg_len
  socket AF_INET, SOCK_STREAM, 0
  ;; check for error 
  cmp rax, 0 
  jl error
  write STDOUT, ok_msg, ok_msg_len
  mov qword [sockfd], rax 
  ;; now we need to bind the socket to an address using the bind(2) syscall 
  ;; int bind(int socket, const struct sockaddr *address, socklen_t address_len);
  write STDOUT, bind_trace_msg, bind_trace_msg_len
  mov word [servaddr.sin_family], AF_INET
  mov word [servaddr.sin_port], 14619
  mov dword [servaddr.sin_addr], INADDR_ANY
  bind [sockfd], servaddr.sin_family, sizeof_servaddr
  cmp rax, 0 
  jl error
  write STDOUT, ok_msg, ok_msg_len
 
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

sockfd dq 0
servaddr.sin_family dw 0
servaddr.sin_port   dw 0 
servaddr.sin_addr   dd 0
servaddr.sin_zero   dq 0 
sizeof_servaddr = $ - servaddr.sin_family

start db "INFO: hello web server!", 10
start_len = $ - start
error_msg db "INFO: ERROR!", 10
error_msg_len = $ - error_msg
socket_trace_msg db "INFO: Creating a socket...", 10
socket_trace_msg_len = $ - socket_trace_msg
bind_trace_msg db "INFO: binding server to addr...", 10
bind_trace_msg_len = $ - bind_trace_msg
ok_msg db "INFO: Ok!", 10
ok_msg_len = $ - ok_msg

; struct sockaddr_in {
;     short            sin_family;   // e.g. AF_INET                // 16 bits 
;     unsigned short   sin_port;     // e.g. htons(3490)            // 16 bits 
;     struct in_addr   sin_addr;     // see struct in_addr, below   // 32 bits 
;     char             sin_zero[8];  // zero this if you want to    // 64 bits 
; };


