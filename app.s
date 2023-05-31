		.equ SCREEN_WIDTH,   640 //Ancho
		.equ SCREEN_HEIGH,   480 //Alto
		.equ BITS_PER_PIXEL, 32

		.equ GPIO_BASE,    0x3f200000
		.equ GPIO_GPFSEL0, 0x00
		.equ GPIO_GPLEV0,  0x34

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
	
	mov x20, x0 // Guarda la dirección base del framebuffer en x20
	
	//-------------------- CODE MAIN ---------------------------//
				
	/* ESTO PINTA TODO EL FONDO DE BLANCO */
	movz x19, 0x0E, lsl 16		//VIOLETA OSCURO
	movk x19, 0x0E0E, lsl 00	//VIOLETA OSCURO

	mov x0, x20    // arg: direccion base del framebuffer
	mov x1, x19    // arg: color
	bl pintarFondo


	// Varias Estrellas
	movz x19, 0xFF, lsl 16		
	movk x19, 0xFFFF, lsl 00	// (0xFFFFFF = BLANCO)
	mov x0, x20         // arg: direccion base del framebuffer
	mov x1, 320			// arg: x
	mov x2, 200			// arg: y
	mov x3,  8          // arg: alto
	mov x4, x19 		// arg: color
	bl estrella

	mov x0, x20         // arg: direccion base del framebuffer
	mov x1, 310			// arg: x
	mov x2, 190			// arg: y
	mov x3,  8          // arg: alto
	mov x4, x19 		// arg: color
	bl estrella

	mov x0, x20         // arg: direccion base del framebuffer
	mov x1, 330			// arg: x
	mov x2, 180			// arg: y
	mov x3,  12          // arg: alto
	mov x4, x19 		// arg: color
	bl estrella

	// Nave espacial
	mov x0, x20			// arg: direccion base del framebuffer
	mov x1, 320			// arg: x
	mov x2, 340			// arg: y
	bl nave

	//-------------------- END CODE MAIN -------------------------//

endMain: 
	b InfLoop

temp_cero: // pre: {}    args: ()
	mov x9, xzr
	mov x10, xzr
	mov x11, xzr
	mov x12, xzr
	mov x13, xzr
	mov x14, xzr
	mov x15, xzr
endTemp_cero:	br lr

pos_base: // pre: { 0 <= x <= 480 && 0 <= y <= 640}    args: (in x0 = direccion base del framebuffer, x1 = x,  x2 = y ;  out x7 = posicion de retorno)

	/* Inicializacion */
	sub sp, sp , 32
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur lr , [sp, #24]

	bl temp_cero

	mov x20, x0
	mov x19, x1 // x
	mov x21, x2 // y

	//-------------------- CODE ---------------------------//

	/* 	Objetivo del siguiente bloque: 
		Calcular x0 = direccion base + (640 * 4 * y + x * 4) */
	mov x9 , SCREEN_WIDTH
	lsl x9, x9, 2 // 640 * 4
	mul x9 , x9, x21 // 640 * 4 * y
	lsl x10, x19, 2 // x * 4
	add x9, x9, x10 // 640 * 4 * y + x * 4
	add x10 , x20, x9	// x10 = direccion base + 640 * 4 * y + x * 4
	
	//-------------------- END CODE -------------------------//

	mov x0, x20
	mov x1, x19
	mov x2, x21
	mov x7 , x10 // ret x0 = x10

	bl temp_cero

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur lr , [sp, #24]
	add sp, sp , 32
endPos_base:	br lr

deley: // pre: {}    args: (in x1 = tamaño del deley)

	/* Inicializacion */
	
	sub sp, sp , 16
	stur x19 , [sp, #0]
	stur lr , [sp, #8]

	bl temp_cero

	mov x19, x1

	//-------------------- CODE ---------------------------//
	
	mov x9, 1000
	lsl x9, x9, x19
 time:   	
    sub x9, x9, #1
    cbnz x9, time

	//-------------------- END CODE -------------------------//

	mov x1, x19

	bl temp_cero

	ldur x19 , [sp, #0]
	ldur lr , [sp, #8]
	add sp, sp , 16

endDeley:	br lr 

// Formas basicas:

triangulo_bajo: // pre: {}    args: (in x0 = centro de la figura,  x1 = alto,  x2 = color)

	/* Inicializacion */

	sub sp, sp , 32
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur lr , [sp, #24]

	bl temp_cero

	mov x19, x0
	mov x20, x1
	mov x21, x2

	//-------------------- CODE ---------------------------//

	// x0 = direcion del centro - (alto / 2) * 640 * 4  
	// x0 = direcion del centro -  alto * 640 * 2
	lsl x9, x20, 1				// x9 = alto * 2
	mov x10, SCREEN_WIDTH
	mul x9 , x9 , x10  			// x9 = alto * 2 * 640
	sub x19, x19, x9
 

	mov x9, x20  // x9 = Altura
	mov x11, 1  // x10 = Cantidad de pixeles por pintar
	mov x10, x11

 loop_triangulo_bajo:
	stur w21, [x19, #0]     // Coloreo un pixel
	add  x19, x19 , 4		// Abanzo al siguiente pixel
	sub  x10, x10, 1	// Decremento el contador de la fila
	cbnz x10, loop_triangulo_bajo	// Si no pinte todos itero de nuevo
	
	sub  x9, x9, 1		// Decremento el contador de las columnas

	add x11, x11, 1		// Aumeno 1 la cantidad de pixeles que debo pintar

	mov x10, SCREEN_WIDTH   // x10 = 640
	lsl x12, x10, 2			// x12 = 640 * 4
	lsl x13, x11, 2			// x13 = cant_pixeles * 4
	sub x12, x12 ,x13		// x12 = 640 * 4 - x11 * 4
	add x19, x19, x12	


	add x11, x11, 1     // Aumento 1 de nuevo la cantidad de pixeles que debo pintar
	mov x10 , x11		// Seteo la cantidad de pixeles que se deben pintar
	cbnz x9, loop_triangulo_bajo
  end_loop_triangulo_bajo:	

	//-------------------- END CODE -------------------------//

	mov x0, x19
	mov x1, x20
	mov x2, x21

	bl temp_cero

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur lr , [sp, #24]
	add sp, sp , 32

endTiangulo_bajo: br lr

triangulo_alto:  // pre: {}    args: (in x0 = centro de la figura,  x1 = alto,  x2 = color)
	
	/* Inicializacion */

	sub sp, sp , 32
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur lr , [sp, #24]

	bl temp_cero

	mov x19, x0
	mov x20, x1
	mov x21, x2

	//-------------------- CODE ---------------------------//
	
	// x0 = direcion del centro + (alto / 2) * 640 * 4  
	// x0 = direcion del centro +  alto * 640 * 2
	lsl x9, x20, 1				// x9 = alto * 2
	mov x10, SCREEN_WIDTH		// x10 = 640
	mul x9 , x9 , x10  			// x9 = alto * 2 * 640
	add x19, x19, x9
 

	mov x9, x20  // x9 = Altura
	mov x11, 1  // x10 = Cantidad de pixeles por pintar
	mov x10, x11

 loop_triangulo_alto:

	stur w21, [x19, #0]  // Coloreo un pixel
	add  x19, x19 , 4		// Abanzo al siguiente pixel
	sub  x10, x10, 1	// Decremento el contador de la fila
	cbnz x10, loop_triangulo_alto	// Si no pinte todos itero de nuevo
	
	sub  x9, x9, 1		// Decremento el contador de las columnas

	add x11, x11, 1		// Aumeno 1 la cantidad de pixeles que debo pintar
	
	mov x10, SCREEN_WIDTH   // x10 = 640
	lsl x12, x10, 2			// x12 = 640 * 4
	lsl x13, x11, 2			// x13 = cant_pixeles * 4
	add x12, x12 ,x13		// x12 = 640 * 4 + x11 * 4
	sub x19, x19, x12			// x12 = direccion_base - 640 * 4 + (cantd_pixeles + 1) * 4


	add x11, x11, 1     // Aumeno 1 de nuevo la cantidad de pixeles que debo pintar
	mov x10 , x11		// Seteo la cantidad de pixeles que se deben pintar
	cbnz x9, loop_triangulo_alto

 end_loop_triangulo_alto:	

	//-------------------- END CODE -------------------------//

	mov x0, x19
	mov x1, x20
	mov x2, x21

	bl temp_cero

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur lr , [sp, #24]
	add sp, sp , 32

end_triangulo_alto: br lr

rectangulo: // pre: {x1 y x2  son pares}    args: (in x0 = centro de la figura,  x1 = ancho,  x2 = alto, x3 = color)

	/* Inicializacion */
	sub sp, sp , 40
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur lr , [sp, #32]

	bl temp_cero

	mov x19, x0
	mov x20, x1
	mov x21, x2
	mov x22, x3
	
	//-------------------- CODE ---------------------------//
	//Objetivo del siguiente bloque :   x12 = (alto / 2 ) * 4 * 640
	mov x12, x21					// x12 = x21 (alto)
	lsr x12, x12 , #1			// x12 = x21/2 (alto / 2)
	mov x15 , SCREEN_WIDTH		// x15 = 640 
	mul x12, x12, x15			// x12 = 640 * (alto / 2)
	lsl x12, x12, #2			// x12 = (alto / 2 ) * 4 * 640

	sub x19, x19 ,x12             // Le restamos al centro (x19)  el alto necesario 
	
	// Objetivo del siguiente bloque :   x13 = (ancho / 2 ) * 4 = ancho * 2
	mov x13 , x20				// x13 = x20 (ancho)
	lsl x13, x13, 1				// x13 = x20 (ancho * 2)

	sub x19, x19, x13				// Le restamos al centro (x19)  el ancho necesario 

	/* Objetivo del siguiente bloque : Caclular la distancia desde el ultimo pixel 
	   de la fila al proximo pixel que queremos pintar de la siguiente columna. */
	mov x14, SCREEN_WIDTH		// X14 = 640
	sub x14, x14, x20			// X14 = 640 - ancho
	lsl x14, x14, 2				// X14 = (640 - ancho) * 4
	

	// Objetivo del siguiente bloque : Pintar todos los elementos.
	mov x9, x21			// i = x21 (alto)
 loop_rectangulo1:	
	mov x10, x20			// j = x20 (ancho) 	      
 loop_rectangulo2:
	stur w22,[x19]  		// Colorear el pixel
	add x19,x19,4   	 	// Siguiente pixel
	sub x10,x10,1   	// Decrementar contador  j
	cbnz x10,loop_rectangulo2  	// Si no terminó la fila, itero de nuevo
	sub x9,x9,1 		// Decremento i
	add x19,x19, x14		// Salto a la siguiente columna en la direccion de memoria
	cbnz x9,loop_rectangulo1		// Si no terminó la columna, itero de nuevo

	//-------------------- END CODE -------------------------//

	mov x0, x19
	mov x1, x20
	mov x2, x21
	mov x3, x22

	bl temp_cero

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur lr , [sp, #32]

	add sp, sp , 40

endRectangulo:	br lr

// Funciones mas complejas: 

pintarFondo: // pre: {}    args: (in x0 = direccion base del framebuffer, x1 = color del fondo)

	/* Inicializacion */

	sub sp, sp , 40
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur lr , [sp, #32]

	bl temp_cero

	mov x19, x0
	mov x20, x1

	//-------------------- CODE ---------------------------//

	mov x21, SCREEN_WIDTH // x
	lsr x21, x21, 1		  // x
	mov x22, SCREEN_HEIGH // y
	lsr x22, x22, 1		  // y

	mov x0, x19           // arg: direccion base del framebuffer
	mov x1, x21           // arg: x
	mov x2, x22           // arg: y
	bl pos_base           // ret: x7 = &( 320, 240 ).

	mov x0, x7            // arg: centro
	mov x1, SCREEN_WIDTH  // arg: ancho
	mov x2, SCREEN_HEIGH  // arg: alto
	mov x3, x20 		  // arg: color
	bl rectangulo 		  // construimos el rectangulo que ocupa toda la pantalla

	//-------------------- END CODE -------------------------//

	mov x0, x19
	mov x1, x20

	bl temp_cero

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x21 , [sp, #24]
	ldur lr , [sp, #32]

	add sp, sp , 40


endPintarFondo:	br lr

estrella: // pre: {mod (x3/3), 2 = 0}    args: (in x0 = direccion base del framebuffer, x1 = x, x2 = y, x3 = alto, x4 = color)

	sub sp, sp , 72
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur x23 , [sp, #32]
	stur x24 , [sp, #40]
	stur x25 , [sp, #48]
	stur x26 , [sp, #56]
	stur lr , [sp, #64]

	bl temp_cero

	mov x19, x0
	mov x20, x1
	mov x21, x2
	mov x22, x3
	mov x23, x4

 //-------------------- CODE ---------------------------//
	
	lsr  x24, x22, 1		// x24 = alto / 2
	lsr  x9, x24, 1
	sub  x25, x21, x9
	add  x26, x21, x9

	//Triangulo superior
	
	mov x0, x19 		// arg: direccion base del framebuffer
	mov x1,	x20			// arg: x
	mov x2,	x25			// arg: y
	bl pos_base 		// ret: x7

	mov x0, x7			// arg: centro de la figura 
	mov x1, x24			// arg: alto
	mov x2, x23 		// arg: color
	bl triangulo_bajo

	// Triangulo inferrior
	sub x9, x26, 1

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x20 		// arg: x
	mov x2,	x9			// arg: y
	bl pos_base			// ret: x7

	mov x0, x7			// arg: centro de la figura 
	mov x1, x24			// alto
	mov x2, x23 		// color
	bl triangulo_alto

 //-------------------- END CODE ---------------------------//

	mov  x0, x19
	mov  x1, x20
	mov  x2, x21
	mov  x3, x22
	mov  x4, x23

	bl temp_cero

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur x23 , [sp, #32]
	ldur x21 , [sp, #40]
	ldur x22 , [sp, #48]
	ldur x23 , [sp, #56]
	ldur lr , [sp, #64]
	add sp, sp , 72

endEstrella: br lr

nave: 		// pre: { 0 <= x <= 480 && 0 <= y <= 640}   args: (in x0 = direccion base del framebuffer, x1 = x, x2 = y)         
	sub sp, sp , 40
	stur x19 , [sp, #0]
	stur x20 , [sp, #8]
	stur x21 , [sp, #16]
	stur x22 , [sp, #24]
	stur lr , [sp, #32]

	bl temp_cero

	mov x19, x0
	mov x20, x1
	mov x21, x2

 //-------------------- CODE ---------------------------//

	//Rectangulo central blanco
	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x20 		// arg: x
	mov x2,	x21			// arg: y
	bl pos_base			// ret: x7 = &( x, y ).

	movz x22, 0xF5, lsl 16		//BLANCO
	movk x22, 0xF5F5, lsl 00	//BLANCO	

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 24		// arg: ancho
	mov x2, 56			// arg: alto
	mov x3, x22 		// arg: color
	bl rectangulo

	//Rectangulo superior azul
	sub x9, x21, 30		// calculo: y - 30
	
	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x20 		// arg: x
	mov x2,	x9			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0x1E, lsl 16		//AZUL
	movk x9, 0x86F5, lsl 00	    //AZUL (#1E86F5)

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 24			// arg: ancho
	mov x2, 6			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo

	//Triangulo Blanco superior
	sub x9, x21, 38		// calculo: y - 36 - 12

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x20 		// arg: x
	mov x2,	x9			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).
    
	mov x0, x7			// arg: centro de la figura 
	mov x1, 12			// arg: alto
	mov x2, x22 		// arg: color
	bl triangulo_bajo

	//Rectangulo central alargado

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x20 		// arg: x
	mov x2,	x21			// arg: y
	bl pos_base			// ret: x7 = &( x, y ).
    
	movz x9, 0xab, lsl 16		//gris
	movk x9, 0xa3a2, lsl 00	


	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 60			// arg: ancho
	mov x2, 6			// arg: alto
	mov x3, x9			// arg: color
	bl rectangulo

	//Rectangulo derecho
	add x9, x20, 30		// calculo: x + 30
	
	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 		// arg: x
	mov x2,	x21			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 6			// arg: ancho
	mov x2, 30			// arg: alto
	mov x3, x22 		// arg: color
	bl rectangulo
    

	//Rectangulo izquierdo
	sub x9, x20, 30	// calculo: x - 30
	
	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 		// arg: x
	mov x2,	x21			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 6			// arg: ancho
	mov x2, 30			// arg: alto
	mov x3, x22 			// arg: color
	bl rectangulo
	//Rectangulo derecho mas chico
	add x9, x20, 18		// calculo: x + 18
	
	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 		// arg: x
	mov x2,	x21			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 4			// arg: ancho
	mov x2, 18		// arg: alto
	mov x3, x22 			// arg: color
	bl rectangulo
    

	//Rectangulo izquierdo mas chico
	sub x9, x20, 18		// calculo: x - 18
	
	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 		// arg: x
	mov x2,	x21			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 4			// arg: ancho
	mov x2, 18			// arg: alto
	mov x3, x22 			// arg: color
	bl rectangulo
	//Rectangulo derecho mas chico rojo
	add x9, x20, 30		// calculo: x + 30
	sub x10, x21, 10     // calculo y - 5

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 		// arg: x
	mov x2,	x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0xe0, lsl 16		//gris
	movk x9, 0x4136, lsl 00	

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 6			// arg: ancho
	mov x2, 4		// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo
    

	//Rectangulo izquierdo mas chico rojo
	sub x9, x20, 30		// calculo: x - 30
	sub x10, x21, 10     // calculo y - 5

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 		// arg: x
	mov x2,	x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0xe0, lsl 16		//gris
	movk x9, 0x4136, lsl 00	

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 6			// arg: ancho
	mov x2, 4			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo


	//Rectangulo derecho mas chico amarillo
	add x9, x20, 30		// calculo: x + 30
	add x10, x21, 15     // calculo y + 15

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0xF1, lsl 16		//Amarillo
	movk x9, 0xCE2D, lsl 00	

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 6			// arg: ancho
	mov x2, 5			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo
    

	//Rectangulo izquierdo mas chico amarillo
	sub x9, x20, 30		// calculo: x - 30
	add x10, x21, 15     // calculo y + 15

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0xF1, lsl 16		//Amarillo
	movk x9, 0xCE2D, lsl 00	

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 6			// arg: ancho
	mov x2, 5			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo
    
	//Rectangulo derecho mas chico naranja
	add x9, x20, 30		// calculo: x + 30
	add x10, x21, 20     // calculo y + 20

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 			// arg: x
	mov x2,	x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0xF7, lsl 16		//Naranja
	movk x9, 0x3822, lsl 00	

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 6			// arg: ancho
	mov x2, 6			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo
    

	//Rectangulo izquierdo mas chico naranja
	sub x9, x20, 30		// calculo: x - 30
	add x10, x21, 20     // calculo y + 20

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x9 		// arg: x
	mov x2,	x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0xF7, lsl 16		//Naranja
	movk x9, 0x3822, lsl 00	

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 6			// arg: ancho
	mov x2, 6			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo

	//Rectangulo abajo amarillo
	add x10, x21, 31    // calculo y + 31

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x20 		// arg: x
	mov x2,	x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0xF1, lsl 16		//Amarillo
	movk x9, 0xCE2D, lsl 00	

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 22			// arg: ancho
	mov x2, 6			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo

	//Rectangulo abajo naranja
	add x10, x21, 36    // calculo y + 36

	mov x0, x19			// arg: direccion base del framebuffer
	mov x1,	x20 		// arg: x
	mov x2,	x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).

	movz x9, 0xF7, lsl 16		//Naranja
	movk x9, 0x3822, lsl 00		

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 20			// arg: ancho
	mov x2, 5			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo

    //Rectangulo derecho mas chico
	add x9, x20, 18		// calculo: x + 18
	sub x10, x21, 7                // calculo y - 7
	
	mov x0, x19			// arg: direccion base del framebuffer
	mov x1, x9 		        // arg: x
	mov x2, x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).
	
	movz x9, 0x09, lsl 16		//gris
	movk x9, 0x57bd, lsl 00

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 4			// arg: ancho
	mov x2, 4		       // arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo
    

	//Rectangulo izquierdo mas chico
	sub x9, x20, 18		// calculo: x - 18
	sub x10, x21, 7                // calculo y - 7 
	
	mov x0, x19			// arg: direccion base del framebuffer
	mov x1, x9 		       // arg: x
	mov x2, x10			// arg: y
	bl pos_base			// ret: x7 = &( x, (y - 30) ).
	
	movz x9, 0x09, lsl 16		//gris
	movk x9, 0x57bd, lsl 00

	mov x0, x7			// arg: &( x, y ) es el centro de la figura.
	mov x1, 4			// arg: ancho
	mov x2, 4			// arg: alto
	mov x3, x9 			// arg: color
	bl rectangulo




 //-------------------- END CODE ---------------------------//
	mov  x0, x19
	mov  x1, x20
	mov  x2, x21

	bl temp_cero

	ldur x19 , [sp, #0]
	ldur x20 , [sp, #8]
	ldur x21 , [sp, #16]
	ldur x22 , [sp, #24]
	ldur lr , [sp, #32]
	add sp, sp , 40

endNave: br lr




InfLoop:
		b InfLoop
