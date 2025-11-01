# @brief Affiche les entiers de n � p, avec 500ms de d�lai
# @param t0 n
# @param t1 p

li t0, 0
li t1, 10
boucle:
addi t0, t0, 1
mv a0, t0
li a7, 1
ecall
li a0, 500
li a7, 32
ecall
blt t0, t1, boucle
li a7 10
ecall
