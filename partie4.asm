.data 
	height: .word 256
	width: .word 256
	unitHeight: .word 8
	unitWidth: .word 8
	I_buff: .word 0
	I_visu: .word 0					
	I_joueur: .word 0					# Pointeurs vers bloc mémoire des structures
	I_envahisseur: .word 0			# 
	I_obstacle: .word 0				#
	I_missile: .word 0				#
		
	S_ordonnee: .word 0 				# Ordonnee du sol
					
	# Joueur 
	J_largeur: .word 2 				# En pixels
	J_hauteur: .word 1				# En pixels
	J_couleur: .word 0x000000ff 	# Bleu
	J_vies: .word 3
	
	# Envahisseurs
	E_nombre: .word 10
	E_largeur: .word 2 				# En pixels
	E_hauteur: .word 1 				# En pixels
	E_couleur: .word 0x00ff0000 	# Rouge
	E_espacement: .word 1   		# Espacement horizontal en pixels
	E_augmentation: .word 1 		# Augmentation de l'ordonnée en pixels
	E_rythme: .word 20 				# Tire tout les X frames
	E_direction: .word 1				# Direction de départ (1 = droite, -1 = gauche)
	
	#Obstacles
	O_nombre: .word 4
	O_largeur: .word 3				# En pixels
	O_hauteur: .word 1				# En pixels
	O_couleur: .word 0x00ffff00	# Jaune
	O_espacement: .word 2 			# En pixels
	
	#Missiles
	M_couleur: .word 0x00ffffff	# Blanc
	M_vitesse: .word 1 				# X pixels parcourus vers le bas en 1 frame
	M_longueur: .word 2				# En pixels
	M_simul: .word 4					# Nombre de missiles simultanés maximum
	
	# ------ STRUCTURES ------ 
	
	# Chaque structure est représenté par une suite d'entiers en mémoire
	# Ci-dessus le descriptif de chaque stucture et de chaque entier qui la compose

	# Joueur (12o)
	
	# 0(): x		Coordonnées du coins supérieur gauche
	# 4(): y		"
	# 8(): vies


	# Envahisseur (12o) :
	
	# 0(): x		Coordonnées du coins supérieur gauche
	# 4(): y		"
	# 8(): vivant (1 = oui, 0 = non) (On ne supprime pas l'instance, on choisi seulement de l'afficher ou non)
	
	# Obstacle (8o) : 
	
	# 0(): x		Coordonnées du coins supérieur gauche
	# 4(): y		"
	
	# Missile (16o):
	
	# 0(): x		Coordonnées du coins supérieur gauche
	# 4(): y		"
	# 8(): source (1: Joueur, -1: Envahisseur)
	# 12(): actif	(On ne créer par de nouvelle instance à chaque nouveau missile, on active/désactive seulement un pré-existant
	

.text
	jal I_creer
	jal J_creer
	jal E_creer
	jal O_creer
	jal M_creer
	
	li a7 10
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
	
	# @brief Alloue les deux mémoires images, et écrit dans I_buff et I_visu les adresses des blocs respectives
	I_creer:
	
	addi sp, sp, -8
	sw ra, 4(sp)
	
	jal I_hauteur
	sw a0, 0(sp) 						# Sauvegarde hauteur avant l'appel de I_largeur
	
	jal I_largeur
	mv t1, a0 							# t1 = Largeur
	lw t0, 0(sp)						# t0 = Hauteur
	
	mul t0, t0, t1
	li t2, 4
	mul t0, t0, t2 					# t0 = Largeur * Hauteur * 4
	
	mv a0, t0
	li a7, 9								# Alloue I_visu
	ecall
	la t3, I_visu						# Sauvegarde l'adresse du premier bloc d'I_visu dans I_visu
	sw a0, 0(t3)
	
	mv a0, t0							# Alloue I_buff
	li a7, 9
	ecall
	
	la t4, I_buff						# Sauvegarde l'adresse du premier bloc d'I_buff dans I_buff
	sw a0, 0(t4)
	
	lw ra, 4(sp)						# On restaure ra
	addi sp, sp, 8
	ret
	
	# @brief Calcule l'adresse d'un point à partir de ses coordonnées (en utilisant un système de coordonnées 0-based
	# @note Adresse = I_buff + (Ordonnée * largeur + Abscisse) * 4
	# @param a0 Abscisse
	# @param a1 Ordonnée
	# @return a0 Adresse du point
	I_xy_to_addr:
	addi sp, sp, -8
	sw a0, 0(sp)
	sw ra, 4(sp)
	jal I_largeur
	mv t0, a0 							# t0 = largeur
	
	lw a0, 0(sp)
	lw ra, 4(sp)
	addi sp, sp, 8 					# On libère la stack, et restore les valeurs de a0,a1 et ra
	
	la t1, I_buff
	lw t1, 0(t1) 						# t1 = I_buff

	mul a1, a1, t0
	add a0, a0, a1
	li t2, 4
	mul a0, a0, t2
	add a0, a0, t1
	ret
	
	
	# @brief Renvoie les coordonnées d'un point à partir de son adresse
	# @note Ordonnée = (Adresse - I_buff)/4 / Largeur
	# @note Abscisse = (Adresse - I_buff)/4 % Largeur
	# @param a0 Adresse
	# @return a0 Abscisse
	# @return a1 Ordonnée
	I_addr_to_xy:
	addi sp, sp, -8
	sw a0, 0(sp)
	sw ra, 4(sp)
	jal I_largeur
	mv t0, a0 							# t0 = largeur
	
	lw a0, 0(sp)
	lw ra, 4(sp)
	addi sp, sp, 8 					# On libère la stack, et restore les valeurs de a0,a1 et ra
	
	la t1, I_buff
	lw t1, 0(t1) 						# t1 = I_buff
	
	sub t2, a0, t1
	li t3, 4
	div t2, t2, t3 					# t2 = (Adresse - I_buff)/4
	
	
	rem a0, t2, t0
	div a1, t2, t0
	ret
	
	
	
	# J'ai préféré représenter un pixel par ses coordonnées x,y plutôt que par son adresse pour des raisons
	# de lisibilité. En effet, je trouve cela plus intuitif à la première lecture du code d'utiliser des
	# coordoonées x,y plutôt qu'une adresse mémoire.
	# RISC-V étant un language assembleur, il est déjà difficilement lisible et très performant, j'ai 
	# privilégié la compréhensibilité du code aux performances.
	
	# @brief Colorie un pixel
	# @param a0 Abscisse
	# @param a1 Ordonnée
	# @param a2 Couleur
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
	
	
	# @brief Réinitialise l'image en coloriant tout les pixels en noir
	I_effacer:
	addi sp, sp, -8
	sw ra, 4(sp)
	
	jal I_hauteur
	mv t0, a0
	
	sw t0, 0(sp)
	
	jal I_largeur
	mv t2, a0							# t2 = largeur
	lw t0, 0(sp)   					# t0 = hauteur
	
	lw ra, 4(sp)
	addi sp, sp, 8
	
	li t1, 0 							# t1 = compteur hauteur
	li t3, 0 							# t3 = compteur largeur
	
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
	
	li t0, 0 							# Compteur Hauteur
	li t1, 0 							# Compteur Largeur
	
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
	
	#@brief Transfère les données de I_buff vers I_visu
	#@note Requiert que I_buff et I_visu soit contigus et de même dimension
	I_buff_to_visu:
		
		addi sp, sp, -8
		sw ra, 4(sp)
		
		jal I_hauteur
		sw a0, 0(sp)					# Enregistre hauteur avant l'appel de I_largeur
		
		jal I_largeur
		mv t0, a0						# t0 = hauteur
		lw t2, 0(sp)					# t2 = largeur
		
		li t1, 0 						# t1 = compteur hauteur
		li t3, 0							# t3 = compteur largeur
		
		lw ra, 4(sp)					# Restaure ra
		addi sp, sp, 8
		
		la t4, I_buff
		lw t4, (t4)
		la t5, I_visu
		lw t5, (t5)
		sub t4, t4, t5 				# t4 = I_buff - I_visu
	
		I_btv_boucle_hauteur:
			bge t1, t0, I_btv_fin
			
			I_btv_boucle_largeur:
				bge t3, t2, I_btv_fin_largeur
				
				addi sp, sp, -24
				sw t0, 0(sp)
				sw t1, 4(sp)
				sw t2, 8(sp)
				sw t3, 12(sp)
				sw t4, 16(sp)
				sw ra, 20(sp)
				
				mv a0, t3
				mv a1, t1
				jal I_xy_to_addr
				mv t5, a0				# t5 = Adresse du point en cours de traitement
				
				lw t0, 0(sp)
				lw t1, 4(sp)
				lw t2, 8(sp)
				lw t3, 12(sp)
				lw t4, 16(sp)
				lw ra, 20(sp)
				addi sp, sp, 24
				
				sub t6, t5, t4			# t6 = Adresse du point dans I_visu
				lw t5, (t5) 			# t5 = Couleur du point dans I_buff
				sw t5, (t6)

				addi t3, t3, 1
				j I_btv_boucle_largeur
				
			I_btv_fin_largeur:
			li t3, 0
			addi t1, t1, 1
			j I_btv_boucle_hauteur	
			
		I_btv_fin:
		ret
		
		#@brief Initialise l'instance du Joueur et alloue la mémoire nécessaire
		J_creer:
		addi sp, sp, -4
		sw ra, 0(sp)
		
		li a0, 12
		li a7, 9
		ecall								# Alloue 12 octets
		la t0, I_joueur
		sw a0, (t0)						# Enregistre l'adresse du premier bloc dans I_Joueur
		
		la t0, I_joueur
		lw t1, J_vies
		sw t1, 8(t0)					# vies = J_vies
		
		jal I_hauteur						
		lw t1, J_hauteur
		sub t1, t1, a0					# t1 = Hauteur de l'image - Hauteur du joueur
		
		la t0, I_joueur
		sw t1, 4(t0)					# y = t1
		
		jal I_largeur
		lw t1, J_largeur
		add t1, t1, a0
		li t2, 2
		div t1, t1, t2					# t1 = (Largeur Image + Largeur Joueur)/2
		
		la t0, I_joueur
		sw t1, 0(t0)					# x = t1
		
		
		lw ra, 0(sp)
		addi sp, sp, 4
		ret
		
		
		#@brief Initialise les instances des envahisseurs
		E_creer:
		
		li t0, 0 						# t0 = Compteur de boucle
		lw t1, E_nombre				# t1 = E_nombre
		
		li a0, 12
		mul a0, a0, t1
		li a7, 9
		ecall								# Alloue 12 * E_nombre octets
		la t2 I_envahisseur
		sw a0, (t2)						# Enregistre l'adresse du premier bloc dans I_envahisseur
		
		E_creer_boucle:
			bge t0, t1, E_creer_fin
			
			la t2, I_envahisseur
			li t3, 12
			mul t3, t3, t0				
			add t2, t2, t3				# t2 = I_envahisseur + (Compteur * 12)    (C'est l'adresse de l'envahisseur)
			
			lw t3, E_espacement
			addi t3, t3, 1
			lw t4, E_largeur
			
			add t3, t3, t4								
			mul t3, t3, t0
			
			sw t3, 0(t2)				# x = ((E_espacement +1) + E_largeur) * t0
			
			addi sp, sp, -16
			sw t0, 0(sp)
			sw t1, 4(sp)
			sw t2, 8(sp)
			sw ra, 12(sp)
			
			jal I_hauteur
			
			lw t0, 0(sp)
			lw t1, 4(sp)
			lw t2, 8(sp)
			lw ra, 12(sp)
			addi sp, sp, 16
			
			sw a0, 4(t2)				# y = Hauteur
			
			li t3, 1
			sw t3, 8(t2)				# vivant = 1
			
			addi t0, t0, 1
			j E_creer_boucle
			
		E_creer_fin:
		ret
		
		
		#@brief Initialise les instances des obstacles
		O_creer:
		
		addi sp, sp, -4
		sw ra, 0(sp)
			
		jal I_hauteur
		li t0, 5
		div t1, a0, t0
		li t0, 4
		mul t1, t1, t0
		la t2, S_ordonnee
		sw t1, (t2)  			# S_ordonee = 4/5 * Hauteur
		
		lw ra, 0(sp)
		addi sp, sp, 4
		
		li t0, 0 						# t0 = Compteur de boucle
		lw t1, O_nombre				# t1 = O_nombre
		
		li a0, 8
		mul a0, a0, t1
		li a7, 9
		ecall								# Alloue 8 * O_nombre octets
		la t2 I_obstacle
		sw a0, (t2)						# Enregistre l'adresse du premier bloc dans I_obstacle
		
		O_creer_boucle:
			bge t0, t1, O_creer_fin
			
			la t2, I_obstacle
			li t3, 8
			mul t3, t3, t0				
			add t2, t2, t3				# t2 = I_obstacle + (Compteur * 8)    (C'est l'adresse de l'obstacle)
			
			lw t3, O_espacement
			addi t3, t3, 1
			lw t4, O_largeur
			
			add t3, t3, t4								
			mul t3, t3, t0
			
			sw t3, 0(t2)				# x = ((O_espacement +1) + O_largeur) * t0
			
			lw t3, S_ordonnee 
			sw t3, 4(t2)				# y = S_ordonnee
			
			addi t0, t0, 1
			j O_creer_boucle
			
		O_creer_fin:
		ret
		
		
		#@brief Initialise les instances des missiles
		M_creer:
		
		li t0, 0 						# t0 = Compteur de boucle
		lw t1, M_simul					# t1 = M_simul
		
		li a0, 16
		mul a0, a0, t1
		li a7, 9
		ecall								# Alloue 16 * M_simul octets
		la t2 I_missile
		sw a0, (t2)						# Enregistre l'adresse du premier bloc dans I_missile
		
		M_creer_boucle:
			bge t0, t1, M_creer_fin
			
			la t2, I_missile
			li t3, 16
			mul t3, t3, t0				
			add t2, t2, t3				# t2 = I_envahisseur + (Compteur * 12)    (C'est l'adresse de l'envahisseur)
			
	
			li t3, 0
			sw t3, 0(t2)				# x = 0 (Le missile n'as pas encore de position)

			li t3, 0			
			sw t3, 4(t2)				# y = Hauteur
			
			li t3, 0
			sw t3, 8(t2)				# source = 0 (Le missile n'as pas de sources)
			
			li t3, 0
			sw t3, 12(t2)				# actif = 0
			
			addi t0, t0, 1
			j M_creer_boucle

		M_creer_fin:
		ret
		
		
		
		
		
		
		
		
		
		
		