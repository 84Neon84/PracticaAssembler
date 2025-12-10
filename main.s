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
    jal MostrarLista #Modificar
    j menu_loop

op_C:
    jal ContarNumeros
    j menu_loop

op_A:
    jal CalcularMediaAritmetica
    j menu_loop

op_M_upper:
    jal BuscarValorMaximo #Modificar
    j menu_loop

op_m_lower:
    jal BuscarValorMinimo #Modificar
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
    #Guardamos parametros y retorno en pila
    addi $sp $sp -24
    sw $a0 20($sp) #Valor de la direccion de memoria en la que esta guardado en primer elemento de vector
    sw $a1 16($sp)
    sw $a2 12($sp)
    sw $a3 8($sp)
    sw $ra 4($sp) #Valor de retorno
    
    move $t0 $a0 
    mtc1  $zero $f0 #Metemos el valor cero a f0 convirtiendolo en flotante

    loop_mostrar:
        lwc1 $f12 0($t0) #Metemos el valor al que apunta t0 a f12 para que posteriormente se pueda imprimir

        c.eq.s $f12 $f0 #Comparamos si el flotante es cero, para saber si la cadena ya ha finalizado
        bc1t   loop_end_mostrar #En el caso en el que el valor decimal sea 0 querrá decir que la cadena ha finalizado, por lo que salimos del bucle

        jal printNum #Si no hemos saltado imprimimos ese numero con la funcion printNum

        addi $t0 $t0 4 #Posteriormente le sumamos al "puntero" t0 4, para que apunte al siguiente numero decimal
        j loop_mostrar
        #Volvemos a iterar

    loop_end_mostrar:

        lw $ra 4($sp)
        lw $a3 8($sp)
        lw $a2 12($sp)
        lw $a1 16($sp)
        lw $a0 20($sp)
        addi $sp $sp 24

        jr $ra #Volvemos al main

ContarNumeros:
    la   $a0, list
    li   $a1, length
    li   $t1, 0        # different numbers count
    li   $t2, 0        # iteration variable i
    move $t0, $a0      
    move $t3, $t0      

loop1CountNum:
    bge  $t2, $a1, finishLoop1CountNum #if i<list size the loop ends
    lwc1 $f0, 0($t3)   
    move $t7, $t0      
    li   $t4, 0        # iteration variable j

loop2CountNum:
    beq  $t4, $t2, finishLoop2CountNum #if j = i the loop ends
    lwc1 $f1, 0($t7)   
    c.eq.s $f0, $f1
    bc1t addNewValue     #if list[i] = list[j] adds 1 to different numbers count
    addi $t7, $t7, 4
    addi $t4, $t4, 1
    j    loop2CountNum

addNewValue:
    addi $t2, $t2, 1
    addi $t3, $t3, 4
    j    loop1CountNum

finishLoop2CountNum:
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    addi $t3, $t3, 4
    j    loop1CountNum

finishLoop1CountNum:
    move $a0, $t1
    li   $v0, 1
    syscall
    jr   $ra


CalcularMediaAritmetica:
    # 
    jr $ra

BuscarValorMaximo:
     #Guardamos parametros y retorno en pila
    addi $sp $sp -24
    sw $a0 20($sp) #Valor de la direccion de memoria en la que esta guardado en primer elemento de vector
    sw $a1 16($sp)
    sw $a2 12($sp)
    sw $a3 8($sp)
    sw $ra 4($sp) #Valor de retorno
    
    move $t0 $a0 
    mtc1 $zero $f0 #Metemos el valor cero a f0 convirtiendolo en flotante

    #Consideramos f12 como el numero mayor que vamos a imprimir
    li $t1 0xff7fffff
    mtc1 $t1 $f12   #Metemos el valor flotante menor en el registro f12 para que el la primera iteracion reciba el primer numero de la lista que queremos comparar
    
    loop_maximo:
        lwc1 $f1 0($t0) #Consideramos $f1 como el numero actual con el que estamos iterando

        #while(listaNumeros[i] != 0) seguimos iterando
        c.eq.s $f1 $f0 #Comparamos si el flotante es cero, para saber si la cadena ya ha finalizado
        bc1t   loop_end_maximo #En el caso en el que el valor decimal sea 0 querrá decir que la cadena ha finalizado, por lo que salimos del bucle

        #if(numeroMayor < listaNumeros[i]) numeroMayor = listaNumeros[i]
        c.le.s $f12 $f1 #Comparamos si $f12 es menor o igual que $f1 si se cumple entonces tenemos que reasignar
        bc1f notReasignNumMax #En el caso en el que no se cumpla esta condicion saltamos y no reasignamos, sino reasignamos por defecto
    
        mov.s $f12 $f1     # numeroMayor = listaNumeros[i]

        notReasignNumMax:
        #i++
        addi $t0 $t0 4 #Posteriormente le sumamos al "puntero" t0 4, para que apunte al siguiente numero decimal
        j loop_maximo #Volvemos a iterar

    loop_end_maximo:

        jal printNum #Si hemos acabado el bucle saltamos para printear el numero que se ha considerado mayor

        lw $ra 4($sp)
        lw $a3 8($sp)
        lw $a2 12($sp)
        lw $a1 16($sp)
        lw $a0 20($sp)
        addi $sp $sp 24

        jr $ra #Volvemos al main

BuscarValorMinimo:
     #Guardamos parametros y retorno en pila
    addi $sp $sp -24
    sw $a0 20($sp) #Valor de la direccion de memoria en la que esta guardado en primer elemento de vector
    sw $a1 16($sp)
    sw $a2 12($sp)
    sw $a3 8($sp)
    sw $ra 4($sp) #Valor de retorno
    
    move $t0 $a0 
    mtc1 $zero $f0 #Metemos el valor cero a f0 convirtiendolo en flotante

    #Consideramos f12 como el numero menor que vamos a imprimir
    li $t1 0x7f7fffff
    mtc1 $t1 $f12   #Metemos el valor flotante mayor en el registro f12 para que el la primera iteracion reciba el primer numero de la lista que queremos comparar
    
    loop_minimo:
        lwc1 $f1 0($t0) #Consideramos $f1 como el numero actual con el que estamos iterando

        #while(listaNumeros[i] != 0) seguimos iterando
        c.eq.s $f1 $f0 #Comparamos si el flotante es cero, para saber si la cadena ya ha finalizado
        bc1t   loop_end_minimo #En el caso en el que el valor decimal sea 0 querrá decir que la cadena ha finalizado, por lo que salimos del bucle

        #if(numeroMenor > listaNumeros[i]) numeroMenor = listaNumeros[i]
        c.le.s $f1 $f12 #Comparamos si $f1 es menor o igual que $f12 si se cumple entonces tenemos que reasignar
        bc1f notReasignNumMin #En el caso en el que no se cumpla esta condicion saltamos y no reasignamos, sino reasignamos por defecto
    
        mov.s $f12 $f1     # numeroMenor = listaNumeros[i]

        notReasignNumMin:
        #i++
        addi $t0 $t0 4 #Posteriormente le sumamos al "puntero" t0 4, para que apunte al siguiente numero decimal
        j loop_minimo #Volvemos a iterar

    loop_end_minimo:

        jal printNum #Si hemos acabado el bucle saltamos para printear el numero que se ha considerado menor

        lw $ra 4($sp)
        lw $a3 8($sp)
        lw $a2 12($sp)
        lw $a1 16($sp)
        lw $a0 20($sp)
        addi $sp $sp 24

        jr $ra #Volvemos al main

printNum:
    
    li $v0 2
    syscall

    li $v0 11
    li $a0 10
    syscall

    jr $ra
