boucle:
lw t1, 0xffff0000 # Charge la valeur du RCR dans t1
lw t2, 0xffff0004 # Charge la valeur du RDR dans t2
beqz t1, affichage

li t3, 105 # 105 = code ASCII i
beq t2, t3, i
li t3, 112 # 112 = code ASCII p
beq t2, t3, p
li t3, 111 # 111 = code ASCII o
beq t2, t3, o
j affichage

i: addi t0, t0, -1
	j affichage
p: addi t0, t0, 1
	j affichage
o:	li a7, 10 # Termine le programme
	ecall
	
affichage:
mv a0, t0
li a7, 1
ecall
li a7, 32
li a0, 500
ecall
j boucle