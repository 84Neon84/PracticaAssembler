.data
menuStr:    .asciiz "Seleccione operacion:\n<N> Introducir nueva lista de numeros\n<O> Ordenar lista\n<P> Mostrar lista\n<C> Contar los numeros\n<A> Calcular la media aritmetica\n<M> Buscar valor maximo\n<m> Buscar valor minimo\n<S> Salir\n"
promptStr:  .asciiz "Opcion: "
invalidStr: .asciiz "Opcion no valida. Intente de nuevo.\n"
exitStr:    .asciiz "Saliendo del programa.\n"
buf:        .space 8

# Variables para el bubble sort
list:   .space 200     # 50 floats (ejemplo)
length: .word 0
tmp_f:  .space 4       # espacio temporal para swap

.text
.globl main
main:
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
bubble_sort:
    # PROLOGO
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)      # guardamos $s0 (i)

    lw   $t0, length      # t0 = n
    blez $t0, end_bubble

    addi $s0, $zero, 0    # i = 0

outer_loop:
    lw   $t0, length
    addi $t1, $t0, -1
    bge  $s0, $t1, end_bubble

    addi $t2, $zero, 0    # j = 0

inner_loop:
    lw   $t0, length
    sub  $t3, $t0, $s0
    addi $t3, $t3, -1
    bge  $t2, $t3, end_inner

    # carga list[j] -> f0
    la   $t4, list
    sll  $t5, $t2, 2
    add  $t4, $t4, $t5
    lwc1 $f0, 0($t4)

    # carga list[j+1] -> f1
    la   $t6, list
    addi $t7, $t2, 1
    sll  $t7, $t7, 2
    add  $t6, $t6, $t7
    lwc1 $f1, 0($t6)

    # comparar: swap si list[j] > list[j+1]  <=> f0 > f1
    c.lt.s $f1, $f0       # true si f1 < f0  => list[j+1] < list[j]
    bc1f no_swap          # si FALSE -> no swap (list[j] <= list[j+1])

    # do swap usando tmp en memoria (más portable que mov.s)
    swc1 $f0, tmp_f       # tmp = f0
    swc1 $f1, 0($t4)      # list[j] = f1
    lwc1 $f2, tmp_f
    swc1 $f2, 0($t6)      # list[j+1] = tmp

no_swap:
    addi $t2, $t2, 1
    j inner_loop

end_inner:
    addi $s0, $s0, 1
    j outer_loop

end_bubble:
    # EPILOGO
    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8
    jr   $ra
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
