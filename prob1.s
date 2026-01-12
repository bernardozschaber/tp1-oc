.data
##### R1 START MODIFIQUE AQUI START #####

mensagem1: .word 2, 3, 4       # mensagem simulada 1
mensagem2: .word 1, 5, 4, 7    # mensagem simulada 2
chave:     .word 3, 5, 7, 9    # chave secreta

##### R1 END MODIFIQUE AQUI END #####

.text
    add s0, zero, zero # s0 armazenará o número de testes que passaram
teste_1:
    # Chama procedimento
    la a0, mensagem1
    la a1, chave
    addi a2, zero, 3
    jal onetime_pad

# Compara saída com a saída esperada
# 2 ^ 3 = 1
# 3 ^ 5 = 6
# 4 ^ 7 = 3
lw t1, 0(a0)
li t2, 1
bne t1, t2, teste_2

lw t1, 4(a0)
li t2, 6
bne t1, t2, teste_2

lw t1, 8(a0)
li t2, 3
bne t1, t2, teste_2
addi s0,s0,1

teste_2:
    # Chama procedimento
    la a0, mensagem2
    la a1, chave
    addi a2, zero, 4
    jal onetime_pad

# Compara saída com a saída esperada
# 1 ^ 3 = 2
# 5 ^ 5 = 0
# 4 ^ 7 = 3
# 7 ^ 9 = 14

lw t1, 0(a0)
li t2, 2
bne t1, t2, FIM

lw t1, 4(a0)
li t2, 0
bne t1, t2, FIM

lw t1, 8(a0)
li t2, 3
bne t1, t2, FIM

lw t1, 12(a0)
li t2, 14
bne t1, t2, FIM

addi s0,s0,1
j FIM


##### R2 START MODIFIQUE AQUI START #####

onetime_pad:
# a0 = endereço da mensagem
# a1 = endereço da chave
# a2 = tamanho da mensagem
# Realiza mensagem[i] = mensagem[i] XOR chave[i]

    addi t0, zero, 0             # t0 = i = 0 (contador de elementos)
    beq a2, zero, onetime_return # se tamanho == 0, nada a fazer

onetime_loop:
    beq t0, a2, onetime_return   # se i == tamanho, fim do loop

    slli t1, t0, 2               # t1 = i * 4 (deslocamento em bytes)
    add t2, a0, t1               # t2 = endereço de mensagem[i]
    add t3, a1, t1               # t3 = endereço de chave[i]

    lw t4, 0(t2)                 # t4 = mensagem[i]
    lw t5, 0(t3)                 # t5 = chave[i]
    xor t6, t4, t5               # t6 = mensagem[i] XOR chave[i]
    sw t6, 0(t2)                 # mensagem[i] = t6

    addi t0, t0, 1               # i = i + 1
    j onetime_loop               # repete o loop

onetime_return:
    jalr zero, 0(ra)             # retorna para o chamador

##### R2 END MODIFIQUE AQUI END #####

FIM: