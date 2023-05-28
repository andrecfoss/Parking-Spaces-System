; P3 -> Arquitetura de Computadores 
; Sistema de gestão de entradas em um parque de estacionamento
; Linguagem Assembly 

;Definição de constantes

;luzes
Verde1		EQU  P1.0		; LED Verde1 
Vermelho1	EQU  P1.1		; LED Vermelho1 
Amarelo		EQU  P1.2		; LED Amarelo 
Verde2		EQU  P1.3		; LED Verde2 
Vermelho2	EQU  P1.4		; LED Vermelho2 

;sensores
Sensor1		EQU  P3.2		; Sensor1 -> P3^2
Sensor2		EQU  P3.3		; Sensor2 -> P3^3 
	
;ciclos
Contagens 	EQU 100			; 10000us = 100contagens para chegar a 1s
	
;LUGARES DE ESTACIONAMENTO
lugar		EQU 9			; lotação máxima de 9 lugares no estacionamento 

constante 	EQU 5			; Constante para controlar as contagens de 1 segundo

;display
display		EQU P2			; display -> P2 (P2^0, P2^1, P2^2, P2^3)
	
	
; Depois do reset
CSEG AT 0000h				; 1º Endereço de Memória do Programa 
JMP Inicio					; Salto Incondicional para o Início do Programa 

; Se ocorrer a interrupção externa 0
CSEG AT 0003h				
JMP  InterrupcaoExt0		; Salto Incondicional para a Interrupção Externa 0

; Se ocorrer a interrupção externa 1
CSEG AT 00013h
JMP  InterrupcaoExt1		; Salto Incondicional para a Interrupção Externa 1

; Tratamento da interrupção de temporização 0, para contar 10ms
CSEG AT 000Bh
JMP  InterrupcaoTemp0		; Salto Incondicional para a Interrupção Timer 0



CSEG AT 0050h				; Programa inicia no endereço de Memória 50H
Inicio:
	MOV SP, #7				; Endereço da STACK POINTER
	CALL Inicializacao		; Chamada à Rotina de Inicialização onde vai conter as configurações dos registos SFR
	
;Programa principal
Principal:					
	;ligar e desligar leds
	CLR Verde1 				; liga o led verde1
	SETB Vermelho1			; desliga o led vermelho1
	SETB Amarelo			; desliga o led amarelo
	CLR Verde2				; liga o led verde2
	SETB Vermelho2			; desliga o led vermelho1
	MOV display, R1			; Move os Dados do Display para R1
	JMP Principal			; Salto Incondicional para o Programa Principal 
	
;Inicialização 
Inicializacao:
	;IE - Interrupt Enable 
	SETB EA					; Ativa as interrupções globais 
	SETB EX0				; Ativa a interrupção Externa 0
	SETB ET0				; Ativa a interrupção Timer 0
	SETB EX1				; Ativa a interrupção Externa 1
	
	;TMOD - Timer Mode 
	MOV TMOD, #1			; Timer Mode 1 -> 
	MOV TH0, #0xD8  		; Bit menos significativo no TH0 = 0xD8
	MOV TL0, #0xF0			; Bit mais significativo em TL0 = 0xF0
	
	;IP
	MOV IP, #2		;prioridade mais elevada no zero
	
	;TCON - Timer Control 
	SETB IT0 				; Ativa Flag da interrupção Timer 0
	SETB IT1				; Ativa Flag da interrupção Timer 0	
	
	MOV R1, #9				; Inicializa o Display no Dígito 9
	
	RET						; Retorno da Rotina Inicializacao
	

;Interrupção externa 0
InterrupcaoExt0:			; Inicia a Rotina da Interrupção Externa 0
	CJNE R1, #0, Entrada	; Compara se R1 != 0
	RETI					; Retorno da Interrupção 
	
Entrada: ;controlar o ciclo dos 5 segundos	
	CLR Amarelo				; Desliga o LED Amarelo 
	MOV R3, #0				; Contagem dos segundos = 0
	MOV R4, #0				; Contagem de cada segundo = 0
	SETB TR0 				; TR0 =1 -> Inicia o Timer 0
TempoAmarelo:
	CJNE R3, #5	, TrocaAmarelo	;Compara se R3 != 5
	SETB Amarelo			; Ativa o LED Amarelo 
	JMP FimEntrada			; Salto Incondicional para a etiqueta FimEntrada
	
TrocaAmarelo:				
	CLR Verde1				; Desliga o LED Verde1
	CLR Vermelho2			; Desliga o LED Vermelho2 
	SETB Vermelho1			; Liga o LED Vermelho1 
	SETB Verde2				; Liga o LED Verde2 
	CJNE R4, #Contagens, TrocaAmarelo
	CPL Amarelo 			; nega o bit
	MOV R4, #0 				; Inicia a Contagem de cada segundo  
	INC R3 					; Incrementa a contagem dos 5 segundos
	JMP TempoAmarelo		; Salto Incondicional para a Etiqueta TempoAmarelo 
	
FimEntrada:
	DEC R1 					; LUGAR = LUGAR - 1
	CLR TR0					; Desativa Timer 0
	RETI					; Retorno da Interrupção 	
	
;Interrupção externa 1
InterrupcaoExt1:			; Inicia a Rotina da Interrupção Externa 1
	CJNE R1, #9, Saida		; Compara se R1 != 9
	RETI					; Retorno da Interrupção 

Saida: ;controlar o ciclo dos 5 segundos	
	CLR Amarelo
	MOV R3, #0				; Contagem dos segundos = 0
	MOV R4, #0				; Contagem de cada segundo = 0
	SETB TR0 				; TR0 = 1 -> Inicia o Timer 0
Tempo_Amarelo:
	CJNE R3, #5	, Troca_Amarelo	;COMPARA 
	SETB Amarelo			; Liga o LED Amarelo 
	JMP FimSaida			; Salto Incondicional para a etiqueta FimSaida 
	
Troca_Amarelo:
	CLR Verde2				; Desliga o LED Verde2 
	CLR Vermelho1			; Desliga o LED Vermelho1 
	SETB Vermelho2			; Liga o LED Vermelho2 
	SETB Verde1				; Liga o LED Verde1 
	CJNE R4, #Contagens, Troca_Amarelo	; Compara se R4 != #Contagens 
	CPL Amarelo 			; nega o bit (complemento para 2)
	MOV R4, #0 				; Inicia a Contagem de cada segundo  
	INC R3 					; Incrementa a contagem dos 5 segundos 
	JMP Tempo_Amarelo		; Salto Incondicional para a Etiqueta Tempo_Amarelo 
	
FimSaida:
	INC R1 					; LUGAR = LUGAR + 1
	CLR TR0					; Desativa Timer 0
	RETI					; Retorno da Interrupção 
	
;Interrupção do timer
InterrupcaoTemp0:
	MOV TH0, #0xD8			; Coloca o valor de TH0 -> MSB: D8H
	MOV TL0, #0xF0			; Coloca o valor de TL0 -> LSB: F0H 
	INC R4					; Incrementa a contagem de cada segundo 
	RETI					; Retorno da Interrupção 

END						