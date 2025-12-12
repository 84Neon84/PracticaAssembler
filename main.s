.data
menuStr:    .asciiz "Seleccione operacion:\n<N> Introducir nueva lista de numeros\n<O> Ordenar lista\n<P> Mostrar lista\n<C> Contar los numeros\n<A> Calcular la media aritmetica\n<M> Buscar valor maximo\n<m> Buscar valor minimo\n<S> Salir\n"
promptStr:  .asciiz "Opcion: "
invalidStr: .asciiz "Opcion no valida. Intente de nuevo.\n"
exitStr:    .asciiz "Saliendo del programa.\n"
buf:        .space 8

# Variables de Nueva lista
.align 2
floatList: .space 200        # Espacio para 50 floats (4 bytes cada uno)
msg1: .asciiz "Ingrese un número en coma flotante (0 para terminar): "
newline: .asciiz "\n\n"
countMsg: .asciiz "Números ingresados: "
zeroFloat: .float 0.0        # Constante para comparar
counter: .word 0             # Contador

# Variables para el bubble sort
.align 2
tmp_f:  .float 0.0       # espacio temporal para swap

# Variables media aritmetica
mediaMsg: .asciiz "Media aritmetica: "
# Mensaje contar numeros distintos
distinctCountMsg: .asciiz "Cantidad de numeros distintos: "
# Mensaje valor maximo
maxMsg: .asciiz "Valor maximo: "
# Mensaje valor minimo
minMsg: .asciiz "Valor minimo: "

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
    # PROLOGO
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $t1, 12($sp)
    sw $t2, 8($sp)
    sw $t3, 4($sp)
    sw $t0, 0($sp)

    # Inicializar contador y puntero
    sw $zero, counter         # counter = 0
    la $t1, floatList         # puntero a la lista
    li $t2, 50                # maximo de elementos permitidos

inputLoop:
    # Imprimir mensaje
    la $a0, msg1
    li $v0, 4
    syscall

    # Leer float
    li $v0, 6
    syscall                   # valor en f0

    # Comparar con 0.0
    la $t3, zeroFloat
    lwc1 $f1, 0($t3)
    c.eq.s $f0, $f1
    bc1t inputDone

    # Guardar float en lista
    swc1 $f0, 0($t1)

    # Mover puntero
    addi $t1, $t1, 4

    # Incrementar contador: counter++
    lw $t0, counter
    addi $t0, $t0, 1
    sw $t0, counter

    # Si aún no llegamos a 50, continuar
    blt $t0, $t2, inputLoop

inputDone:
    # Imprimir mensaje
    la $a0, countMsg
    li $v0, 4
    syscall

    # Imprimir valor de counter
    lw $a0, counter
    li $v0, 1
    syscall

    # Nueva línea
    la $a0, newline
    li $v0, 4
    syscall

    # EPILOGO
    lw $ra, 16($sp)
    lw $t1, 12($sp)
    lw $t2, 8($sp)
    lw $t3, 4($sp)
    lw $t0, 0($sp)
    addiu $sp, $sp, 20

    jr $ra


OrdenarLista:
    bubble_sort:
    # PROLOGO
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)      # guardamos $s0 (i)

    lw   $t0, counter       # t0 = n
    blez $t0, end_bubble

    addi $s0, $zero, 0     # i = 0

outer_loop:
    lw   $t0, counter
    addi $t1, $t0, -1
    bge  $s0, $t1, end_bubble

    addi $t2, $zero, 0     # j = 0

inner_loop:
    lw   $t0, counter
    sub  $t3, $t0, $s0
    addi $t3, $t3, -1       # t3 = counter - i - 1
    bge  $t2, $t3, end_inner

    # carga list[j] -> f0
    la   $t4, floatList
    sll  $t5, $t2, 2
    add  $t4, $t4, $t5
    lwc1 $f0, 0($t4)

    # carga list[j+1] -> f1
    la   $t6, floatList
    addi $t7, $t2, 1
    sll  $t7, $t7, 2
    add  $t6, $t6, $t7
    lwc1 $f1, 0($t6)

    # comparar: swap si list[j] > list[j+1]  <=> f0 > f1
    c.lt.s $f1, $f0        # true si f1 < f0  => list[j+1] < list[j]
    bc1f no_swap            # si FALSE -> no swap (list[j] <= list[j+1])

    # do swap usando tmp en memoria (más portable que mov.s)
    swc1 $f0, tmp_f         # tmp = f0
    swc1 $f1, 0($t4)        # list[j] = f1
    lwc1 $f2, tmp_f
    swc1 $f2, 0($t6)        # list[j+1] = tmp

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


MostrarLista:
    #Guardamos parametros y retorno en pila
    addiu $sp, $sp, -24
    sw $a0, 20($sp)
    sw $a1, 16($sp)
    sw $a2, 12($sp)
    sw $a3, 8($sp)
    sw $ra, 4($sp)

    # Usamos floatList y counter
    la   $t0, floatList    # puntero a inicio lista
    lw   $t1, counter      # numero de elementos
    beq  $t1, $zero, loop_end_mostrar  # si no hay elementos salir

loop_mostrar:

    beqz $t1, loop_end_mostrar # Si el contador es 0, salir del bucle

    lwc1 $f12, 0($t0) #Metemos el valor al que apunta t0 a f12 para que posteriormente se pueda imprimir
    li $v0, 2 # Imprimir float
    syscall

    li $v0, 4 #Movemos el puntero al siguiente numero (4 bytes) y salto de linea
    la $a0, newline
    syscall

    addiu $t0, $t0, 4 # Avanzar al siguiente número (puntero += 4)
    addiu $t1, $t1, -1 # contador--
    j loop_mostrar # Continuar

loop_end_mostrar:

    lw $ra, 4($sp)
    lw $a3, 8($sp)
    lw $a2, 12($sp)
    lw $a1, 16($sp)
    lw $a0, 20($sp)
    addiu $sp, $sp, 24

    jr $ra #Volvemos al main


ContarNumeros:
    la   $a0, floatList
    lw   $a1, counter   # a1 = numero de elementos (n)
    li   $t1, 0  #contador de numeros distintos     
    li   $t2, 0  #variable de iteracion i     
    move $t0, $a0      # t0 = base pointer
    move $t3, $t0      # t3 sera puntero a elemento i

    # Si no hay elementos imprimimos 0 y volvemos
    beq  $a1, $zero, finish_loop1CountNum

loop1CountNum:
    #if i is >= than the counter of the list the loop ends
    move $t4, $t2
    blt  $t4, $a1, enter_loop1CountNum 
    j    finish_loop1CountNum

enter_loop1CountNum:
    lwc1 $f0, 0($t3)     # f0 = list[i]
    move $t7, $t0        # t7 = puntero base (usado para j)
    li   $t4, 0          #iteration variable j
    li   $t5, 1          #variable "bool" newValue   (1 = es nuevo)

loop2CountNum:
    #if j = i the loop ends
    move $t6, $t4
    beq  $t6, $t2, check_if_new_valueCountNum
    lwc1 $f1, 0($t7)     # f1 = list[j]
    c.eq.s $f0, $f1  
    bc1t not_new_valueCountNum #if list[i] = list[j] then newValue = 0
    addiu $t7, $t7, 4
    addiu $t4, $t4, 1
    j loop2CountNum 

not_new_valueCountNum:
    li $t5, 0          
    j check_if_new_valueCountNum      

check_if_new_valueCountNum:
    beqz $t5 finish_loop2CountNum #si newValue == 0 entonces no incrementamos el contador
    addiu $t1, $t1, 1   # distinct++

finish_loop2CountNum:
    addiu $t2, $t2, 1   # i++
    addiu $t3, $t3, 4   # avanzar puntero i
    j loop1CountNum 
    
finish_loop1CountNum:
    la  $a0, distinctCountMsg
    li $v0, 4
    syscall
    move $a0, $t1 # distinct a0 para imprimir
    li   $v0, 1
    syscall
    la   $a0, newline
    li   $v0, 4
    syscall
    jr   $ra
    
CalcularMediaAritmetica:
    # PROLOGO
    addiu $sp, $sp, -20
    sw $ra, 16($sp)
    sw $t0, 12($sp)
    sw $t1, 8($sp)
    sw $t2, 4($sp)
    sw $t3, 0($sp)

    # Cargar contador
    lw $t0, counter

    # Si no hay elementos, media = 0
    beq $t0, $zero, media_cero

    # Preparar puntero a floatList
    la $t1, floatList

    # Copiar contador en t2
    move $t2, $t0

    # Inicializar suma: f2 = 0.0
    li.s $f2, 0.0

suma_loop:
    lwc1 $f0, 0($t1)      # cargar float actual
    add.s $f2, $f2, $f0   # suma parcial

    addi $t1, $t1, 4      # avanzar puntero
    addi $t2, $t2, -1     # contador--

    bgtz $t2, suma_loop   # continuar si quedan

    # Calcular media = suma / total
    mtc1 $t0, $f4         # pasar contador a coprocesador 1
    cvt.s.w $f4, $f4      # convertir a float

    div.s $f12, $f2, $f4  # f12 = media

    # Imprimir mensaje
    la $a0, mediaMsg
    li $v0, 4
    syscall

    # Imprimir media
    li $v0, 2
    syscall

    # Salto a final
    b fin_media


media_cero:
    la $a0, mediaMsg
    li $v0, 4
    syscall

    li.s $f12, 0.0
    li $v0, 2
    syscall


fin_media:
    # Imprimir salto de línea
    la $a0, newline
    li $v0, 4
    syscall

    # EPILOGO
    lw $ra, 16($sp)
    lw $t0, 12($sp)
    lw $t1, 8($sp)
    lw $t2, 4($sp)
    lw $t3, 0($sp)
    addiu $sp, $sp, 20

    jr $ra


BuscarValorMaximo:
     #Guardamos parametros y retorno en pila
    addiu $sp, $sp, -24
    sw $a0, 20($sp) #Valor de la direccion de memoria en la que esta guardado en primer elemento de vector
    sw $a1, 16($sp)
    sw $a2, 12($sp)
    sw $a3, 8($sp)
    sw $ra, 4($sp) #Valor de retorno
    
    move $t0, $a0 
    # mtc1 $zero $f0 #Metemos el valor cero a f0 convirtiendolo en flotante  (NO usar así)

    # Usamos counter. Si no hay elementos imprimir 0.0
    lw   $t2, counter
    beq  $t2, $zero, loop_end_maximo_zero

    la   $t0, floatList
    lwc1 $f12, 0($t0)    # inicializar numero mayor con primer elemento
    addiu $t0, $t0, 4
    addiu $t2, $t2, -1   # ya procesamos 1

    #Consideramos f1 como el numero actual con el que estamos iterando
    loop_maximo:
        beqz $t2, loop_end_maximo
        lwc1 $f1, 0($t0) #Consideramos $f1 como el numero actual con el que estamos iterando

        #if(numeroMayor < listaNumeros[i]) numeroMayor = listaNumeros[i]
        c.le.s $f12, $f1 #Comparamos si $f12 es menor o igual que $f1 si se cumple entonces tenemos que reasignar
        bc1f notReasignNumMax #En el caso en el que no se cumpla esta condicion saltamos y no reasignamos, sino reasignamos por defecto
    
        mov.s $f12, $f1     # numeroMayor = listaNumeros[i]

        notReasignNumMax:
        #i++
        addiu $t0, $t0, 4 #Posteriormente le sumamos al "puntero" t0 4, para que apunte al siguiente numero decimal
        addiu $t2, $t2, -1
        j loop_maximo #Volvemos a iterar

    loop_end_maximo:
        
        la $a0, maxMsg # imprimir mensaje de numero maximo 
        li $v0, 4
        syscall
        
        # imprimir f12
        li $v0, 2
        syscall

        # salto linea
        la $a0, newline
        li $v0, 4
        syscall

        lw $ra, 4($sp)
        lw $a3, 8($sp)
        lw $a2, 12($sp)
        lw $a1, 16($sp)
        lw $a0, 20($sp)
        addiu $sp, $sp, 24

        jr $ra #Volvemos al main

loop_end_maximo_zero:
    la $a0, maxMsg # imprimir mensaje de numero maximo 
    li $v0, 4
    syscall
    li.s $f12, 0.0
    li $v0, 2
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    lw $ra, 4($sp)
    addiu $sp, $sp, 24
    jr $ra

BuscarValorMinimo:
     #Guardamos parametros y retorno en pila
    addiu $sp, $sp, -24
    sw $a0, 20($sp) #Valor de la direccion de memoria en la que esta guardado en primer elemento de vector
    sw $a1, 16($sp)
    sw $a2, 12($sp)
    sw $a3, 8($sp)
    sw $ra, 4($sp) #Valor de retorno
    
    move $t0, $a0 
    # mtc1 $zero $f0 #Metemos el valor cero a f0 convirtiendolo en flotante (NO usar así)

    # Usamos counter (numero de elementos) en lugar de sentinel 0. Si no hay elementos imprimir 0.0
    lw   $t2, counter
    beq  $t2, $zero, loop_end_minimo_zero

    la   $t0, floatList
    lwc1 $f12, 0($t0)    # inicializar numero menor con primer elemento
    addiu $t0, $t0, 4
    addiu $t2, $t2, -1   # ya procesamos 1

    loop_minimo:
        beqz $t2, loop_end_minimo
        lwc1 $f1, 0($t0) #Consideramos $f1 como el numero actual con el que estamos iterando

        #if(numeroMenor > listaNumeros[i]) numeroMenor = listaNumeros[i]
        c.le.s $f1, $f12 #Comparamos si $f1 es menor o igual que $f12 si se cumple entonces tenemos que reasignar
        bc1f notReasignNumMin #En el caso en el que no se cumpla esta condicion saltamos y no reasignamos, sino reasignamos por defecto
    
        mov.s $f12, $f1     # numeroMenor = listaNumeros[i]

        notReasignNumMin:
        #i++
        addiu $t0, $t0, 4 #Posteriormente le sumamos al "puntero" t0 4, para que apunte al siguiente numero decimal
        addiu $t2, $t2, -1
        j loop_minimo #Volvemos a iterar

    loop_end_minimo:
        
        la $a0, minMsg # imprimir mensaje de numero minimo
        li $v0, 4
        syscall

        # imprimir f12
        li $v0, 2
        syscall

        la $a0, newline
        li $v0, 4
        syscall

        lw $ra, 4($sp)
        lw $a3, 8($sp)
        lw $a2, 12($sp)
        lw $a1, 16($sp)
        lw $a0, 20($sp)
        addiu $sp, $sp, 24

        jr $ra #Volvemos al main

loop_end_minimo_zero:
    la $a0, minMsg # imprimir mensaje de numero minimo
    li $v0, 4
    syscall
    li.s $f12, 0.0
    li $v0, 2
    syscall
    la $a0, newline
    li $v0, 4
    syscall
    lw $ra, 4($sp)
    addiu $sp, $sp, 24
    jr $ra
