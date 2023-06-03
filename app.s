		.equ SCREEN_WIDTH,   640 //Ancho
		.equ SCREEN_HEIGH,   480 //Alto
		.equ BITS_PER_PIXEL, 32

		.equ GPIO_BASE,    0x3f200000
		.equ GPIO_GPFSEL0, 0x00
		.equ GPIO_GPLEV0,  0x34

		.equ DELEY_VALUE, 1000

		.globl main


//------------------------------------ CODE HERE ------------------------------------//

/*
X0...X7   : argumentos/resultados
X8        : ...
X9...x15  : Temporales
X16       : IP0
X17       : IP1
X18       : ...
X19...X27 : Saved
X28       : SP
X29       : FP
X30       : LR
Xzr       : 0
*/


main:
	// x0 = direccion base del framebuffer

	/* Inicializacion */
	
	mov x20, x0 	// Guarda la dirección base del framebuffer en x20
	
	//-------------------- CODE MAIN ---------------------------//

	movz x1, 0x0E, lsl 16		
	movk x1, 0x0E0E, lsl 00		//Color del fondo (gris oscuro)
	bl pintarFondo 

	mov x21, 150
	mov x1, 320  // x
	mov x2, 400  // y
	
	// NAVE EN MOVIMIENTO
 loop:   
	bl fondoEstrellado 	// Se pinta el fondo con las estrellas
	mov x1, 320  		// x
	bl nave				// Dibuja la nave

	sub x2, x2, 2  		// y - 1
	mov x1 , 13			// Setea el deley
	bl deley			// Ejecuta el deley

	sub x21, x21, 1
	cbnz x21, loop
	//-------------------- END CODE MAIN -------------------------//

endMain: 
	b endMain

// Herramientas basicas:

deley: // pre: {}    args: (in x1 = tamaño del deley)
	//-------------------- CODE ---------------------------//
	mov x9, DELEY_VALUE
	lsl x9, x9, x1
 deley_loop:   	
    sub x9, x9, #1
    cbnz x9, deley_loop
	//-------------------- END CODE -------------------------//
endDeley:	br lr 

p_pixel: // pre: { 0 <= x <= 480 && 0 <= y <= 640}    args: ( x0 = direccion base del framebufer, x1 = x,  x2 = y, x3 = color )
	//-------------------- CODE ---------------------------//
	lsl x9, x1, 2 // x9 = x * 4
	lsl x10, x2, 2 // x10 = y * 4
	mov x11, SCREEN_WIDTH
	mul x10, x10, x11 // x10 = y * 4 * 640
	add x9, x9, x10 // x9 = x * 4 + y * 4 * 640
	add x9, x9 , x0 // x9 = direccion base del framebufer +  x * 4 + y * 4 * 640

	str w3, [x9,#0]
	//-------------------- END CODE -------------------------//
end_p_pixel: br lr

// Formas basicas:

triangulo_punta_abajo:  // pre: {}    args: (in x0 = direccion base framebufer, x1 = x, x2 = y,  x3 = color,  x4 = alto)
	
	/* Inicializacion */
	
	sub sp, sp , 56
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur x21 , [sp, #32]
	stur x22 , [sp, #40]
	stur lr , [sp, #48]

	mov x21, x1 // x (cordenada)
	mov x22, x2 // y (cordenada)

    //-------------------- CODE ---------------------------//
	
	mov x19, x1 // x (cordenada)
	mov x20, x2 // y (cordenada)

	// Calculamos el inicio y final del triangulo:
	lsr x9, x4, 1             // Mitad del alto
	
	// Inicio:
	lsr x10, x4, 2             // Mitad de la mitad del alto
	sub x19, x1, x9            // x - mitad del alto
	
	sub x20, x2, x10           // y - mitad del alto
	
	// Final de x e y:
	add x26, x1, x9           	  // x26 = x + mitad del alto  
	add x27, x2, x10               // x27 = y + mitad del alto
	//add x27, x27, 1               // x27 = y + mitad del alto

	// Dibujamos: 
	mov x2, x20   	          // y
 tri_p_abajo_loop1:
	mov x1, x19               // x
 tri_p_abajo_loop2:	
	bl p_pixel                // args: ( x0 = direccion base del framebufer, x1 = x,  x2 = y, x3 = color )
	adds x1,x1, #1 	          // x + 1
	cmp x1 , x26     
	b.lt tri_p_abajo_loop2    // if (x < final_x ) -> tri_p_abajo_loop2
	add  x19, x19, 1          //  x + 1
	sub  x26, x26, 1		  // final_x - 1
	adds x2, x2, #1           // y + 1
	cmp x2 , x27 
	b.lt  tri_p_abajo_loop1   // if (y < final_y ) -> tri_p_abajo_loop1
	
	//-------------------- END CODE -------------------------//
	mov x1, x21
	mov x2, x22

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur x21 , [sp, #32]
	ldur x22 , [sp, #40]
	ldur lr , [sp, #48]
	add sp, sp , 56

end_triangulo_punta_abajo: br lr

triangulo_punta_arriba:  // pre: {}    args: (in x0 = direccion base framebufer, x1 = x, x2 = y,  x3 = color,  x4 = alto)
	
	/* Inicializacion */
	sub sp, sp , 56
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur x21 , [sp, #32]
	stur x22 , [sp, #40]
	stur lr , [sp, #48]

	mov x21, x1 // x (cordenada)
	mov x22, x2 // y (cordenada)

    //-------------------- CODE ---------------------------//
	mov x19, x1 // x (cordenada)
	mov x20, x2 // y (cordenada)
	// Calculamos el inicio y final del triangulo:
	lsr x9, x4, 1             // Mitad del alto
	
	// Inicio:
	lsr x10, x4, 2             // Mitad de la mitad del alto
	sub x19, x1, x9            // x - mitad del alto
	add x20, x2, x10           // y + mitad del alto
	
	// Final de x e y:
	add x26, x1, x9           	  // x26 = x + mitad del alto  
	sub x27, x2, x10               // x27 = y - mitad del alto
	//sub x27, x27, 1               // x27 = y - mitad del alto

	// Dibujamos: 
	mov x2, x20   	          // y
 tri_p_arriba_loop1:
	mov x1, x19               // x
 tri_p_arriba_loop2:	
	bl p_pixel                // args: ( x0 = direccion base del framebufer, x1 = x,  x2 = y, x3 = color )
	adds x1,x1, #1 	          // x + 1
	cmp x1 , x26     
	b.lt tri_p_arriba_loop2    // if (x < final_x ) -> tri_p_arriba_loop2
	add  x19, x19, 1          //  x + 1
	sub  x26, x26, 1		  // final_x - 1
	subs x2, x2, #1           // y + 1
	cmp x2 , x27 
	b.gt  tri_p_arriba_loop1   // if (y > final_y ) -> tri_p_arriba_loop1
	
	//-------------------- END CODE -------------------------//

	mov x1, x21
	mov x2, x22

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur x21 , [sp, #32]
	ldur x22 , [sp, #40]
	ldur lr , [sp, #48]
	add sp, sp , 56

end_triangulo_punta_arriba: br lr

rectangulo: // pre: {}    args: (in x0 = direccion base framebufer, x1 = x, x2 = y,  x3 = color, x4 = ancho, x5 = alto)

	/* Inicializacion */
	sub sp, sp , 56
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur x26 , [sp, #32]
	stur x27 , [sp, #40]
	stur lr , [sp, #48]
	
	mov x21, x1 // x (cordenada)
	mov x22, x2 // y (cordenada)

	
	//-------------------- CODE ---------------------------//

	mov x19, x1 // x (cordenada)
	mov x20, x2 // y (cordenada)
	
	// Calculamos el inicio y final del rectangulo:
	lsr x9, x4, 1    // Mitad del ancho
	lsr x10, x5, 1   // Mitad del alto
	
	// Inicio:
	sub x19, x1, x9  // x - mitad del ancho
	sub x19, x19, 1  // x - mitad del ancho - 1
	sub x20, x2, x10 // y - mitad del alto
	sub x20, x20, 1 // y - mitad del alto - 1
	
	// Final:
	add x26, x1, x9  // x + mitad del ancho
	sub x26, x26, 1  // x + mitad del ancho - 1
	add x27, x2, x10 // y + mitad del alto
	sub x27, x27, 1  // x + mitad del ancho - 1
	
	// Dibujamos: 
	mov x2, x20   	 // y
 rect_loop1:
	mov x1, x19  	 // x
	adds x2, x2, #1  // y + 1
 rect_loop2:	
	adds x1,x1, #1 	 // x + 1
	bl p_pixel       // args: ( x0 = direccion base del framebufer, x1 = x,  x2 = y, x3 = color )
	cmp x1 , x26     //
	b.lt rect_loop2  // if (x < ancho) -> rect_loop2
	cmp x2 , x27     // 
	b.lt rect_loop1  // if (y < alto) -> rect_loop1
	
	//-------------------- END CODE -------------------------//

	mov x1, x21 // x (cordenada)
	mov x2, x22 // y (cordenada)

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur x26 , [sp, #32]
	ldur x27 , [sp, #40]
	ldur lr , [sp, #48]
	add sp, sp , 56

endRectangulo:	br lr

// Formas combinadas:

pintarFondo: // pre: {}  args: (in x0 = direccion base del framebuffer, x1 = color del fondo)

	/* Inicializacion */
	sub sp, sp , 48
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur x23 , [sp, #32]
	stur lr , [sp, #40]

	mov x19, x1
	mov x20, x2
	mov x21, x3
	mov x22, x4
	mov x23, x5
	//-------------------- CODE ---------------------------//

	mov x9, SCREEN_WIDTH  // x
	lsr x9, x9, 1		  // x
	mov x10, SCREEN_HEIGH // y
	lsr x10, x10, 1		  // y

	mov x1, x9            // arg: x
	mov x2, x10           // arg: y
	mov x3, x19 		  // arg: color
	mov x4, SCREEN_WIDTH  // arg: ancho
	mov x5, SCREEN_HEIGH  // arg: alto
	bl rectangulo 		  // construimos el rectangulo que ocupa toda la pantalla

	//-------------------- END CODE -------------------------//

	mov x1, x19
	mov x2, x20 
	mov x3, x21 
	mov x4, x22 
	mov x5, x23 

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur x23 , [sp, #32]
	ldur lr , [sp, #40]

	add sp, sp , 48
endPintarFondo:	br lr

estrella: // pre: {}    args: (in x0 = direccion base del framebuffer, x1 = x, x2 = y, x3 = color, x4 = ancho)

	sub sp, sp , 24
	stur x19 , [sp, #0]
	stur x20 , [sp, #8] // No hace falta guardar en el stack x3 y  x4  porque solo usamos las funciones de triangulos y no las modifican
	stur lr , [sp, #16]

	mov x19, x1
	mov x20, x2
    //-------------------- CODE ---------------------------//
	lsr x9, x4, 2
	sub x9, x20, x9 
	//Triangulo superior 
	           // x0 = arg: direccion base framebufer
	           // x1 = arg: x
	mov x2, x9 // arg: y
	           // x3 = arg: color
	           // x4 = arg: ancho
	bl triangulo_punta_arriba

	// Triangulo inferrior
	lsr x9, x4, 2
	add x9, x20, x9 

				// x0 = arg: direccion base framebufer
				// x1 = arg: x
	mov x2,  x9 // arg: y
	            // x3 = arg: color
	 		    // x4 = arg: ancho
	bl triangulo_punta_abajo
 //-------------------- END CODE ---------------------------//
	mov  x1, x19
	mov  x2, x20

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur lr , [sp, #16]
	add sp, sp , 24

endEstrella: br lr

nave: 		// pre: { 0 <= x <= 480 && 0 <= y <= 640}   args: (in x0 = direccion base del framebuffer, x1 = x, x2 = y)         
	sub sp, sp , 80
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur x23 , [sp, #32]
	stur x24 , [sp, #40]
	stur x25 , [sp, #48]
	stur x26 , [sp, #56]
	stur x27 , [sp, #64]
	stur lr , [sp, #72]

	mov x19, x1
	mov x20, x2
	mov x25, x3
	mov x26, x4
	mov x27, x5

 //-------------------- CODE ---------------------------//

	movz x21, 0xF5, lsl 16		//BLANCO
	movk x21, 0xF5F5, lsl 00	//BLANCO (#F5F5F5)

	movz x22, 0x1E, lsl 16		//AZUL
	movk x22, 0x86F5, lsl 00	//AZUL (#1E86F5)

	movz x23, 0xF1, lsl 16		//AMARILLO
	movk x23, 0xCE2D, lsl 00	//AMARILLO (#F1CE2D)

	movz x24, 0xF7, lsl 16		//ROJO
	movk x24, 0x3822, lsl 00	//ROJO (#F73822)

	
	//Rectangulo negro fondo
						// arg: x0 = direccion base del framebuffer
	add x9, x20, 21
	mov x1,	x19 		// arg: x
	mov x2,	x9			// arg: y
	movz x3, 0x0E, lsl 16		
	movk x3, 0x0E0E, lsl 00		//Color del fondo (gris oscuro)
	mov x4, 75		    // arg: ancho
	mov x5, 38			// arg: alto
	bl rectangulo 

	//Rectangulo central blanco
						// arg: x0 = direccion base del framebuffer
	mov x1,	x19 		// arg: x
	mov x2,	x20			// arg: y
	mov x3, x21 		// arg: color
	mov x4, 24		    // arg: ancho
	mov x5, 56			// arg: alto
	bl rectangulo 

	//Rectangulo superior azul
	sub x9, x20, 30		// calculo: y - 30
	
					    // arg: x0 = direccion base del framebuffer
	mov x1,	x19		    // arg: x
	mov x2,	x9			// arg: y
	mov x3, x22  		// arg: color
	mov x4, 24			// arg: ancho
	mov x5, 6			// arg: alto
	bl rectangulo 

	//Triangulo Blanco superior
	sub x9, x20, 40  	// calculo: y - 36 - 12

						// arg: x0 = direccion base del framebuffer
						// arg: x1 = x
	mov x2,	x9			// arg: y    
	mov x3, x21         // arg: color
	mov x4, 24			// arg: ancho
	bl triangulo_punta_arriba 
 
	//Rectangulo central alargado
	movz x9, 0xab, lsl 16		// GRIS
	movk x9, 0xa3a2, lsl 00		// GRIS

						// arg: X0 = direccion base del framebuffer
	mov x1,	x19 		// arg: x
	mov x2,	x20			// arg: y
	mov x3, x9			// arg: color
	mov x4, 60			// arg: ancho
	mov x5, 6			// arg: alto
	bl rectangulo  

	//Rectangulo derecho
	add x9, x19, 30		// calculo: x + 30
	
						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 		    // arg: x
	mov x2,	x20			// arg: y
	mov x3, x21 		// arg: color
	mov x4, 6			// arg: ancho
	mov x5, 30			// arg: alto
	bl rectangulo 
   

	//Rectangulo izquierdo
	sub x9, x19, 30		// calculo: x - 30
	
						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x20			// arg: y
	mov x3, x21 		// arg: color
	mov x4, 6			// arg: ancho
	mov x5, 30			// arg: alto
	bl rectangulo 

 	//Rectangulo derecho mas chico
	add x9, x19, 18		// calculo: x + 18
	
						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x20			// arg: y
	mov x3, x21 		// arg: color
	mov x4, 4			// arg: ancho
	mov x5, 18		    // arg: alto
	bl rectangulo 
    
	//Rectangulo izquierdo mas chico
	sub x9, x19, 18		// calculo: x - 18

						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x20			// arg: y
	bl rectangulo 

	//Rectangulo derecho mas chico rojo
	add x9, x19, 30		 // calculo: x + 30
	sub x10, x20, 10     // calculo y - 5

						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	mov x3, x24 		// arg: color
	mov x4, 6			// arg: ancho
	mov x5, 4		    // arg: alto
	bl rectangulo


	//Rectangulo izquierdo mas chico rojo
	sub x9, x19, 30		// calculo: x - 30
	sub x10, x20, 10     // calculo y - 5

						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	bl rectangulo


	//Rectangulo derecho mas chico amarillo
	add x9, x19, 30		// calculo: x + 30
	add x10, x20, 15     // calculo y + 15

						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	mov x3, x23 		// arg: color
	mov x4, 6			// arg: ancho
	mov x5, 5			// arg: alto
	bl rectangulo
    

	//Rectangulo izquierdo mas chico amarillo
	sub x9, x19, 30		// calculo: x - 30
	add x10, x20, 15    // calculo y + 15

						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	bl rectangulo

	//Rectangulo derecho mas chico naranja/rojo
	add x9, x19, 30		// calculo: x + 30
	add x10, x20, 20     // calculo y + 20

						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	mov x3, x24 			// arg: color
	mov x4, 6			// arg: ancho
	mov x5, 6			// arg: alto
	
	bl rectangulo
    
	//Rectangulo izquierdo mas chico naranja/rojo
	sub x9, x19, 30		// calculo: x - 30
	add x10, x20, 20     // calculo y + 20

						// arg: X0 = direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	bl rectangulo

	//Rectangulo abajo amarillo
	add x10, x20, 31    // calculo y + 31

						// arg: X0 = direccion base del framebuffer
	mov x1,	x19 		// arg: x
	mov x2,	x10			// arg: y
    mov x3, x23 		// arg: color
	mov x4, 22			// arg: ancho
	mov x15, 6			// arg: alto
	bl rectangulo
	

	//Rectangulo abajo naranja/rojo
	add x10, x20, 36    // calculo y + 36

						// arg: direccion base del framebuffer
	mov x1,	x19 		// arg: x
	mov x2,	x10			// arg: y
	mov x3, x24 		// arg: color
	mov x4, 20			// arg: ancho
	mov x5, 5			// arg: alto
	bl rectangulo


    //Rectangulo derecho mas chico azul
	add x9, x19, 18		// calculo: x + 18
	sub x10, x20, 7     // calculo y - 7
	
						// arg: direccion base del framebuffer
	mov x1, x9 		    // arg: x
	mov x2, x10			// arg: y
	mov x3, x22 		// arg: color
	mov x4, 4			// arg: ancho
	mov x5, 4		    // arg: alto
	bl rectangulo
    

	//Rectangulo izquierdo mas chico azul
	sub x9, x19, 18		// calculo: x - 18
	sub x10, x20, 7     // calculo y - 7 
	
						// arg: direccion base del framebuffer
	mov x1, x9 		    // arg: x
	mov x2, x10			// arg: y
	bl rectangulo

 //-------------------- END CODE ---------------------------//

	mov  x1, x19
	mov  x2, x20
	mov  x3, x25 
	mov  x4, x26 
	mov  x5, x27 

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur x23 , [sp, #32]
	ldur x24 , [sp, #40]
	ldur x25 , [sp, #48]
	ldur x26 , [sp, #56]
	ldur x27 , [sp, #64]
	ldur lr , [sp, #72]
	add sp, sp , 80

endNave: br lr

fondoEstrellado:
	sub sp, sp , 40
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur lr , [sp, #32]
	mov x19, x1
	mov x20, x2
	mov x21, x3
	mov x22, x4
	

 //-------------------- CODE ---------------------------//

	movz x3, 0xF3, lsl 16		
	movk x3, 0xF3F3, lsl 00		//Color del las estrellas
    	
	mov x23, 50
	mov x24, 5
	
    mov x1, 10
	mov x2, 10
	mov x4, 16
    mov x5, 5

    lopi: mov x4, 8

	kl:
	    add x1, x2, x1
		add x1, x1, 100
	    bl estrella
		add x1, x2, x1
		sub x24, x24, 1
		cbnz x24, kl
    mov x24, 1
    add x2, x2, x23
	bl estrella
	sub x23, x23, 1
	cbnz x23, lopi 

	mov x1, 50
	mov x2, 17
	mov x4, 16
    mov x5, 5


    mov x23, 50
    lopi2: mov x4, 12

	kll:
	    add x1, x2, x1
		add x1, x1, 70
	    bl estrella
		add x1, x2, x1
		sub x24, x24, 1
		cbnz x24, kll
    mov x24, 1
    add x2, x2, 10
	bl estrella
	sub x23, x23, 1
	cbnz x23, lopi2 

 //-------------------- END CODE ---------------------------//

	mov x1, x19 
	mov x2, x20 
	mov x3, x21 
	mov x4, x22 	

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur lr , [sp, #32]
	add sp, sp , 40
endFondoEstrellado: br lr

// HAY UN BUG PORQUE NO PUEDEN HABER ESTRELLAS DEBAJO DE LA NAVE

Error: // Nunca se deberia ejecutar esto
		b Error
