.data
menuStr:    .asciiz "Seleccione operacion:\n<N> Introducir nueva lista de numeros\n<O> Ordenar lista\n<P> Mostrar lista\n<C> Contar los numeros\n<A> Calcular la media aritmetica\n<M> Buscar valor maximo\n<m> Buscar valor minimo\n<S> Salir\n"
promptStr:  .asciiz "Opcion: "
invalidStr: .asciiz "Opcion no valida. Intente de nuevo.\n"
exitStr:    .asciiz "Saliendo del programa.\n"
buf:        .space 8

.text
.globl main
main:
    jal Menu
    li $v0, 10
    syscall

Menu:
menu_loop:
    # Print menu
    la $a0, menuStr
    li $v0, 4
    syscall

    la $a0, promptStr
    li $v0, 4
    syscall

    # Leer primer caracter del input
    la $a0, buf
    li $a1, 8
    li $v0, 8
    syscall
    lb $t0, 0($a0)

    # Comprobar opcion
    li $t1, 'N'
    beq $t0, $t1, op_N
    li $t1, 'O'
    beq $t0, $t1, op_O
    li $t1, 'P'
    beq $t0, $t1, op_P
    li $t1, 'C'
    beq $t0, $t1, op_C
    li $t1, 'A'
    beq $t0, $t1, op_A
    li $t1, 'M'
    beq $t0, $t1, op_M_upper
    li $t1, 'm'
    beq $t0, $t1, op_m_lower
    li $t1, 'S'
    beq $t0, $t1, op_S

    # Opcion invalida
    la $a0, invalidStr
    li $v0, 4
    syscall
    j menu_loop

op_N:
    jal NuevaLista
    j menu_loop

op_O:
    jal OrdenarLista
    j menu_loop

op_P:
    jal MostrarLista
    j menu_loop

op_C:
    jal ContarNumeros
    j menu_loop

op_A:
    jal CalcularMediaAritmetica
    j menu_loop

op_M_upper:
    jal BuscarValorMaximo
    j menu_loop

op_m_lower:
    jal BuscarValorMinimo
    j menu_loop

op_S:
    la $a0, exitStr
    li $v0, 4
    syscall
    li $v0, 10
    syscall

NuevaLista:
    # 
    jr $ra

OrdenarLista:
    # 
    jr $ra

MostrarLista:
    # 
    jr $ra

ContarNumeros:
    # 
    jr $ra

CalcularMediaAritmetica:
    # 
    jr $ra

BuscarValorMaximo:
    # 
    jr $ra

BuscarValorMinimo:
    # 
    jr $ra
