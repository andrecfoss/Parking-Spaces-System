// P3 -> Arquitetura de Computadores
// Sistema de gestão de entradas em um parque de estacionamento
// Linguagem C

#include <reg51.h>						// biblioteca do 8051

//ciclos
#define Contagens 100					// 100 contagens * 10000us = 1s

//luzes
sbit Verde1 = P1^0;						//LED Verde1
sbit Vermelho1 = P1^1;				//LED Vermelho1 
sbit Amarelo = P1^2;					//LED Amarelo 
sbit Verde2 = P1^3;						//LED Verde2 
sbit Vermelho2 = P1^4;				//LED Vermelho2 

//sensores
bit Sensor1 = 0;							//Sensor1	-> P3^2
bit Sensor2 = 0;							//Sensor2 -> P3^3

//display
int display = 9;							//valores do display 

//lugares de estacionamento
int lugar = 9;								//Número máximo de lugares disponíveis 

//Variáveis Globais 
int cada_segundo = 0;					//conta cada segundo 
int conta = 0; 								//contar os 5 segundos


void Init(void) {
	//IE
	EA = 1;											//Ativa Interrupções Globais			
	EX0 = 1;										//Ativa Interrupção Externa 0
	ET0 = 1;										//Ativa Interrupção Timer 0
	EX1 = 1;										//Ativa Interrupção Externa 1
	
	//TMOD - Timer Mode Configuration
	// 2^16 - 10000 = 55536 -> D8F0H
	TMOD |= 0x01;								//Timer Mode 1
	TH0 = 0xD8;									//Bit menos significativo no TH0 = 0xD8
	TL0 = 0xF0;									//Bit mais significativo em TL0 = 0xF0
	
	//IP
	IP = 2;											//prioridade mais elevada no zero
	
	//TCON
	IT0 = 1;										//Ser detetado na Transição descendente
	IT1 = 1;
	
	P2 = display;								//Inicializa o Display 9
}

//Programa Principal
void main(void) {							// Inicia o Programa Principal 
	
	//Inicializações
	Init();
	
	//LOOP Infinito
	while(1) {
	
	//Estado inicial dos LEDs
	Verde1 = 0;									// Ativa o LED Verde1	
	Vermelho1 = 1;							// Desativa o LED Vermelho1 
	Amarelo = 1;								// Desativa o LED Amarelo 
	Verde2 = 0;									// Ativa o LED Verde2
	Vermelho2 = 1;							// Desativa o LED Vermelho2
	P2 = display;								// lugares no momento
	}		
}

void Entrada(void) {
	Amarelo = 0;
	conta = 0;
	TR0 = 1;
	while(conta < 5){														// ciclo while -> se a contagem for menor que 5 segundos
		if(cada_segundo == Contagens){						// se a contagem de cada segundo for igual ao número de contagens 
			conta++;																// incrementa a contagem dos 5 segundos 
			Amarelo = ~Amarelo;											// Altera o estado do LED Amarelo 
			cada_segundo = 0;									
		}
		//alteração dos leds, caso entre um carro
		Verde1 = 0;																// Desliga o LED Verde1
		Vermelho1 = 1;														// Liga o LED Vermelho1
		Verde2 = 1;																// Liga o LED Verde2
		Vermelho2 = 0;														// Desliga o LED Vermelho2
	}
	Amarelo = 1;
	display--;																	// Decrementa o número do Display, ou seja, é ocupado mais um lugar no estacionamento
	TR0 = 0;																		// Para o Timer 0
}

void Saida(void) {
	Amarelo = 0;
	conta = 0;
	TR0 = 1;
	while(conta < 5){														// Se o contador não ultrapassar os 5 segundos
		if(cada_segundo == Contagens){						// Cada segundo corresponde ao número de contagens 
			conta++;																// Incrementa a contagem dos 5 segundos 
			Amarelo = ~Amarelo;											// Altera o estado do LED Amarelo 
			cada_segundo = 0;
		}
		//alteração dos leds, caso entre um carro
		Verde1 = 1;																// Desliga o LED Verde1
		Vermelho1 = 0;														// Desliga o LED Vermelho1
		Verde2 = 0;																// Desliga o LED Verde2
		Vermelho2 = 1;														// Liga o LED Vermelho2
	}
	Amarelo = 1;																// Ativa o LED Amarelo 
	display++;																	// Incrementa o valor do Display, ou seja, existe mais um lugar livre no estacionamento 
	TR0 = 0;																		// Para o Timer 0
}


//Interrupção Externa 0
void InterrupcaoExt0(void) interrupt 0 {			// De acordo com o Registo -> EX0 é o Bit 0
	if(display > 0) {														// Se o estacionamento tiver algum lugar livre 			
		Entrada();																// Chama a função Entrada
	} 
}

//Interrupção Timer 0
void InterrupcaoTemp0(void) interrupt 1 {			// De acordo com o Registo -> ET1 é o Bit 1
	TH0 = 0xD8;																	// Byte mais Significativo: TH0 -> D8H
	TL0 = 0xF0;																	// Byte menos Significativo: TL0 -> F0H
	cada_segundo++;															// Incrementa a contagem de 1 em 1 segundo 
}


//Interrupção Externa 1
void InterrupcaoExt1(void) interrupt 2 {			// De acordo com o Registo -> EX1 é o Bit 2
	if(display < 9) {														// Se o estacionamento tiver algum lugar ocupado
		Saida();																	// Chama a função Saída
	}
}


