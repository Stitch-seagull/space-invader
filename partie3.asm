.data 
	height: .word 256
	width: .word 256
	unitHeight: .word 8
	unitWidth: .word 8
	I_buff: .word 0

.text
	jal I_creer
	jal I_effacer

	li a0, 9
	li a1, 0
	li a2, 7
	li a3, 4
	li a4, 0x00ff00ff
	jal I_rectangle
	li a0, 500
	li a7, 32
	ecall
	
	jal I_effacer
	li a0, 500
	li a7, 32
	ecall
	
	li a0, 11
	li a1, 0
	li a2, 7
	li a3, 4
	li a4, 0x00ff00ff
	jal I_rectangle
	li a0, 500
	li a7, 32
	ecall
	
	
	jal I_effacer
	li a0, 500
	li a7, 32
	ecall
	
	li a0, 13
	li a1, 0
	li a2, 7
	li a3, 4
	li a4, 0x00ff00ff
	jal I_rectangle
	li a0, 500
	li a7, 32
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
	
	addi sp, sp, -8
	sw ra, 4(sp)
	
	jal I_hauteur
	mv t0, a0
	
	sw t0, 0(sp) # Déplace hauteur dans t0, et sauvegarde t0 avant l'appel de I_largeur
	
	jal I_largeur
	mv t1, a0
	
	lw t0, 0(sp)
	
	mul a0, t0, t1 # Largeur * Hauteur
	li t2, 4
	mul a0, a0, t2 # Multiplie par 4 pour obtenir la taille en octets
	
	li a7, 9 # Alloue la mémoire
	ecall
	
	la t3, I_buff
	sw a0, 0(t3)
	
	lw ra, 4(sp)
	addi sp, sp, 8
	
	ret
	
	#@brief Calcule l'adresse d'un point à partir de ses coordonnées (en utilisant un système de coordonnées 0-based
	# Adresse = I_buff + (Ordonnée * largeur + Abscisse) * 4
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
	
	
	#@brief Renvoie les coordonnées d'un point à partir de son adresse
	# Ordonnée = (Adresse - I_buff)/4 / Largeur
	# Abscisse = (Adresse - I_buff)/4 % Largeur
	#@param a0 Adresse
	#@return a0 Abscisse
	#@return a1 Ordonnée
	I_addr_to_xy:
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
	
	sub t2, a0, t1
	li t3, 4
	div t2, t2, t3 # t2 = (Adresse - I_buff)/4
	
	
	rem a0, t2, t0
	div a1, t2, t0
	ret
	
	
	
	# J'ai préféré représenter un pixel par ses coordonnées x,y plutôt que par son adresse pour des raisons
	# de lisibilité. En effet, je trouve cela plus intuitif à la première lecture du code d'utiliser des
	# coordoonées x,y plutôt qu'une adresse mémoire.
	# RISC-V étant un language assembleur, il est déjà difficilement lisible et très performant, j'ai 
	# privilégié la compréhensibilité du code aux performances.
	
	#@brief Colorie un pixel
	#@param a0 Abscisse
	#@param a1 Ordonnée
	#@param a2 Couleur
	I_plot:
	
	addi sp, sp, -16
	sw a0, 0(sp)
	sw a1, 4(sp)
	sw a2, 8(sp)
	sw ra, 12(sp)
	
	jal I_xy_to_addr
	mv t0, a0
	
	lw a0, 0(sp)
	lw a1, 4(sp)
	lw a2, 8(sp)
	lw ra, 12(sp)
	addi sp, sp, 16
	
	sw a2, 0(t0)
	ret
	
	
	#@brief Réinitialise l'image en coloriant tout les pixels en noir
	I_effacer:
	
	#Récupère la largeur et la hauteur
	addi sp, sp, -8
	sw ra, 4(sp)
	
	jal I_hauteur
	mv t0, a0
	
	sw t0, 0(sp)
	
	jal I_largeur
	mv t2, a0
	
	lw t0, 0(sp)
	lw ra, 4(sp)
	addi sp, sp, 8
	
	# t0 = hauteur
	# t2 = largeur
	
	li t1, 0
	li t3, 0
	
	# t1 = compteur hauteur
	# t3 = compteur largeur
	
	I_effacer_boucle_hauteur:
		bge t1, t0, I_effacer_fin
		
			I_effacer_boucle_largeur:
				bge t3, t2, I_effacer_fin_largeur
				
				addi sp, sp, -24
				sw t0, 0(sp)
				sw t1, 4(sp)
				sw t2, 8(sp)
				sw t3, 12(sp)
				sw t4, 16(sp)
				sw ra, 20(sp)
				
				mv a0, t3
				mv a1, t1
				li a2, 0x00000000
				jal I_plot
				
				lw t0, 0(sp)
				lw t1, 4(sp)
				lw t2, 8(sp)
				lw t3, 12(sp)
				lw t4, 16(sp)
				lw ra, 20(sp)
				addi sp, sp, 24
				
				addi t3, t3, 1
				j I_effacer_boucle_largeur
			
		I_effacer_fin_largeur:
		li t3, 0
		addi t1, t1, 1
		j I_effacer_boucle_hauteur
	
	I_effacer_fin:
	ret
	
	
	# @brief Dessine un rectangle
	# @param a0 Abscisse coin supérieur gauche
	# @param a1 Ordonnée coin supérieur gauche
	# @param a2 Largeur
	# @param a3 Hauteur
	# @param a4 Couleur
	
	I_rectangle:
	
	li t0, 0 # Compteur Hauteur
	li t1, 0 # Compteur Largeur
	
	I_rectangle_boucle_hauteur:
		bge t0, a2, I_rectangle_fin
		
		I_rectangle_boucle_largeur:
			bge t1, a2, I_rectangle_fin_largeur
			
			addi sp, sp, -28
			sw a0, 0(sp)
			sw a1, 4(sp)
			sw a2, 8(sp)
			sw a3, 12(sp)
			sw a4, 16(sp)
			sw t0, 20(sp)
			sw t1, 24(sp)
			sw ra, 28(sp)
			
			add a0, a0, t1
			add a1, a1, t0
			mv a2, a4
			jal I_plot
			
			lw a0, 0(sp)
			lw a1, 4(sp)
			lw a2, 8(sp)
			lw a3, 12(sp)
			lw a4, 16(sp)
			lw t0, 20(sp)
			lw t1, 24(sp)
			lw ra, 28(sp)
			addi sp, sp, 28
			
			addi t1, t1, 1
			j I_rectangle_boucle_largeur
			
		I_rectangle_fin_largeur:
			li t1, 0
			addi t0, t0, 1
			j I_rectangle_boucle_hauteur
	I_rectangle_fin:
	ret
	
	
	
	
	
	
	
	
	
	
	
	
	
