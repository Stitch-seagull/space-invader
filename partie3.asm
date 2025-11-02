.data 
	height: .word 256
	width: .word 256
	unitHeight: .word 8
	unitWidth: .word 8
	I_buff: .word 0

.text
	la a0, I_buff
	lw a0, 0(a0)
	li a7, 34
	ecall
	li a0, 10
	li a7, 11
	ecall
	li a0 1
	li a1 7
	li a7, 34
	jal I_xy_to_addr
	ecall
	li a7, 10
	ecall
	
	# @brief Renvoie la hauteur de la grille en Units
	# @return a0 Hauteur de la grille en unit
	I_hauteur:
	la t0, height
	lw t0, 0(t0)
	la t1, unitHeight
	lw t1, 0(t1)
	div a0, t0, t1
	ret
	
	# @brief Renvoie la largeur de la grille en Units
	# @return a0 Largeur de la grille en unit
	I_largeur:
	la t0, width
	lw t0, 0(t0)
	la t1, unitWidth
	lw t1, 0(t1)
	div a0, t0, t1
	ret
	
	# @brief Alloue la mémoire image, et écris dans I_buff l'adresse du bloc alloué

	I_creer:
	
	jal I_hauteur
	mv t0, a0
	jal I_largeur
	mv t1, a0
	
	mul a0, t0, t1 # Largeur * Hauteur
	li t2, 4
	mul a0, a0, t2 # Multiplie par 4 pour obtenir la taille en octets
	
	li a7, 9 # Alloue la mémoire
	ecall
	
	la t3, I_buff
	sw a0, 0(t3)
	ret
	
	#@brief Calcule l'adresse d'un point à partir de ses coordonées (en utilisant un système de coordonnées 0-based
	#Adresse = I_buff + (Ordonnée * largeur + Abscisse) * 4
	#@param a0 Abscisse
	#@param a1 Ordonnée
	#@return a0 Adresse du point
	I_xy_to_addr:
	addi sp, sp, -8
	sw a0, 0(sp)
	sw ra, 4(sp)
	jal I_largeur
	mv t0, a0 # t0 = largeur
	
	lw a0, 0(sp)
	lw ra, 4(sp)
	addi sp, sp, 8 # On libère la stack, et restore les valeurs de a0,a1 et ra
	
	la t1, I_buff
	lw t1, 0(t1) # t1 = I_buff

	mul a1, a1, t0
	add a0, a0, a1
	li t2, 4
	mul a0, a0, t2
	add a0, a0, t1
	ret
	
	
	
	
	
	
	
	
	
	
	
	