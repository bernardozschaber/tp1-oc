.data
##### R1 START MODIFIQUE AQUI START #####
matriz_a: .word 1, 2, 3, 4
matriz_b: .word 5, 6, 7, 8
matriz_c: .word 0, 0, 0, 0
##### R1 END MODIFIQUE AQUI END #####

.text
add s0, zero, zero      # s0 armazenará o número de testes que passaram
teste_1:
# Chama procedimento
    la a0, matriz_a
    la a1, matriz_b
    la a2, matriz_c
    addi a3, zero, 2
    jal mat_mult

# Compara saída com a saída esperada
# | 1 2 | X | 5 6 | = | 19 22 |
# | 3 4 |   | 7 8 |   | 43 50 |
la a0, matriz_c
lw t1, 0(a0)
li t2, 19
bne t1, t2, teste_2

lw t1, 4(a0)
li t2, 22
bne t1, t2, teste_2

lw t1, 8(a0)
li t2, 43
bne t1, t2, teste_2

lw t1, 12(a0)
li t2, 50
bne t1, t2, teste_2
addi s0, s0, 1

teste_2:
    # Chama procedimento
    la a0, matriz_a    
    la a1, matriz_b
    addi a2, zero, 2     
    addi a3, zero, 0    
    jal dot_product

# Compara saída com a saída esperada
# (1, 2) * (5, 7) = 1*5 + 2*7 = 19
    li t1, 19
    bne a0, t1, FIM
    addi s0, s0, 1
    j FIM

##### R2 START MODIFIQUE AQUI START #####

mat_mult:
    # a0 = endereço da matriz A
    # a1 = endereço da matriz B
    # a2 = endereço da matriz C
    # a3 = tamanho das matrizes (n)
    # Realiza C = A * B

    addi sp, sp, -28       # aloca 7 palavras (28 bytes) na pilha
    sw ra, 0(sp)           # salva o endereço de retorno
    sw s1, 4(sp)           # s1: contador 'i' (linhas)
    sw s2, 8(sp)           # s2: contador 'j' (colunas)
    sw s3, 12(sp)          # s3: guarda endereço base de C
    sw s4, 16(sp)          # s4: guarda endereço base de A
    sw s5, 20(sp)          # s5: guarda endereço base de B
    sw s6, 24(sp)          # s6: guarda dimensão 'n'

    mv s4, a0              # salva o endereço de A
    mv s5, a1              # salva o endereço de B
    mv s3, a2              # salva o endereço de C
    mv s6, a3              # salva a dimensão 'n'

    add s1, zero, zero     # i = 0, primeira linha

outer_loop: # Loop para percorrer as linhas de C (e de A)
    bge s1, s6, end_mat_mult # caso i >= n, fim da multiplicação

    add s2, zero, zero     # j = 0, primeira coluna
inner_loop: # Loop para percorrer as colunas de C (e de B)
    bge s2, s6, next_row   # caso j >= n, termina-se a linha e pula para a próxima
   
    mul t0, s1, s6         # t0 = i * n
    slli t0, t0, 2         # t0 = i * n * 4 (byte offset)
    add t0, s4, t0         # t0 = &A + offset (endereço da linha i)

    mv a0, t0              # a0 = endereço da linha 'i' de A
    mv a1, s5              # a1 = endereço base da matriz B
    mv a2, s6              # a2 = dimensão 'n'
    mv a3, s2              # a3 = índice da coluna 'j'

    jal dot_product        
                           
    mul t1, s1, s6         # t1 = i * n
    add t1, t1, s2         # t1 = (i * n) + j
    slli t1, t1, 2         # t1 = ((i * n) + j) * 4 (byte offset)
    add t1, s3, t1         # t1 = &C + offset
    sw a0, 0(t1)           # armazena o resultado de a0 em C[i][j]

    addi s2, s2, 1         # j++
    j inner_loop

next_row:
    addi s1, s1, 1         # i++
    j outer_loop

end_mat_mult:
    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    addi sp, sp, 28        # libera o espaço da pilha
    jalr zero, 0(ra)      

dot_product:
    # a0 = endereço base da linha da matriz A
    # a1 = endereço base da coluna da matriz B
    # a2 = tamanho das matrizes (n)
    # a3 = índice da coluna 'j' a ser usada
    # Retorna a0 = produto interno entre a linha de A e a coluna de B

    addi sp, sp, -12
    sw ra, 0(sp)
    sw s1, 4(sp)           # s1: contador 'k' para o somatório
    sw s2, 8(sp)           # s2: guarda a dimensão 'n' (a2)

    mv s2, a2              # guarda 'n' em s2

    add s1, zero, zero     # k = 0
    add t0, zero, zero     # somatório = 0

dot_loop:
    bge s1, s2, dot_end    # caso k >= n, fim do loop

    lw t1, 0(a0)

    mul t2, s1, s2         # t2 = k * n
    add t2, t2, a3         # t2 = k * n + j
    slli t2, t2, 2         # t2 = (k * n + j) * 4 (byte offset)
    add t2, a1, t2         # t2 = &B + offset
    lw t3, 0(t2)           # carrega o valor B[k][j]

    mul t4, t1, t3         # t4 = A[i][k] * B[k][j]
    add t0, t0, t4         # somatorio += t4

    addi a0, a0, 4         # avança para o próximo elemento da linha de A
    addi s1, s1, 1         # k++
    j dot_loop

dot_end:
    mv a0, t0              # resultado final em a0 para retornar

    lw ra, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12
    jalr zero, 0(ra)       # retorna
##### R2 END MODIFIQUE AQUI END #####

FIM: