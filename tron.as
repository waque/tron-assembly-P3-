;*****************************************************************************************
;#ZONA1###############################"CONSTANTES"########################################
;-----------------------------------------------------------------------------------------


IO_CONTROL 		EQU 	FFFCh
IO_WRITE        EQU     FFFEh
SP_INICIAL      EQU     FDFFh
FIM_TEXTO		EQU		'@'
INT_MASK_ADDR	EQU		FFFAh
INT_MASK_INIT	EQU		0000000000000010b
INT_MASK_GAME	EQU		1000101010000011b
POS_MENSAGEM	EQU		0C20h ; mensagem inicial
POS_MENSAGEM2	EQU		0D16h ; mensagem inicial
POS_MENSAGEM3	EQU		0C20h ; mensagem final
POS_MENSAGEM4	EQU		0D16h ; mensagem final

DIPLAY_7SGM		EQU		FFF0h
N_LINHAS		EQU		24
TIMER_CONTROL	EQU		FFF7h
TIMER_VALUE		EQU		FFF6h
INICIO_TAB		EQU		010Fh

VELOCIDADE1		EQU		7
VELOCIDADE2		EQU		5
VELOCIDADE3		EQU		3
VELOCIDADE4		EQU		2
VELOCIDADE5		EQU		1 ; BUG
NIVEL2			EQU		100 
NIVEL3			EQU		200
NIVEL4			EQU		400
NIVEL5			EQU		600

IO_LCD_WRITE		EQU		FFF5h	; carater em codigo ascii estendido corresponde aos 8 bits menos significativos do valor escrito
IO_LCD_CONTROL		EQU		FFF4h	;Porto de Controlo
LINHA_1_LCD			EQU		0000h	; Posicao onde vai escrever 'TEMPO MAX:'
LINHA_2_LCD_P1		EQU		0010h	; Posicao onde vai escrever 'JOG1:'
LINHA_2_LCD_P2		EQU		001Bh	; Posicao onde vai escrever 'JOG2:'
LINHA_1_LCD_VALOR	EQU		000Bh	; Posicao onde vai escrever o tempo maximo (valor)




;*****************************************************************************************
;#ZONA3##############################"VARIAVEIS"##########################################
;-----------------------------------------------------------------------------------------




				ORIG	8000h
Tabela_jogo		TAB		2000h
ContadorSegundo	WORD	10
TempoJogo		WORD	0
ContadorTemp	WORD	0
Velocidade_Jogo	WORD	7
ContadorNivel	WORD	0
TempoEntreNivel	WORD	100
STATUS			WORD	0			;STATUS=0 --> Inicio de Jogo ou Fim de Jogo / STATUS=1 --> Ciclo de Jogo 
FLAG_0			WORD	0
FLAG_B			WORD	0
FLAG_7			WORD	0
FLAG_9			WORD	0
CONT_TEMPO_JOGO	WORD	0000h 		;contador do nivel
POS_JOG1		WORD	0C17h
POS_JOG2		WORD	0C37h
NIVEL			WORD	7d
LEDS_CONTER		WORD	0000h
vetor_J1		WORD	0001h
vetor_J2		WORD	0001h

TempoEscLCD		WORD	0000h
TempoMaxEscLCD	WORD	0000h
VitoriasJ1		WORD	0000h
VitoriasJ2		WORD	0000h



;*****************************************************************************************
;#ZONA4##############################"STRINGS"############################################
;-----------------------------------------------------------------------------------------

	
STR_MENSAGEM 	STR 	'Bem-vindo ao TRON', FIM_TEXTO
STR_MENSAGEM2	STR 	'Prima o interruptor I1 para comecar', FIM_TEXTO
STR_FIMJOGO		STR 	'Fim do Jogo', FIM_TEXTO
STR_FIMJOGO2	STR 	'Prima o interruptor I1 para recomecar', FIM_TEXTO
STR_limpa		STR 	'                                                                                ', FIM_TEXTO
STR_TOPO		STR 	'+------------------------------------------------+', FIM_TEXTO
LATERAL			STR		'|', FIM_TEXTO
JOGADOR1		STR	    'X', FIM_TEXTO
JOGADOR2		STR		'#', FIM_TEXTO
STR_LCD_TEMPO_MAX	STR		'TEMPO MAX:', FIM_TEXTO
STR_LCD_JOG1		STR		'J1:', FIM_TEXTO
STR_LCD_JOG2		STR		'J2:', FIM_TEXTO




;*****************************************************************************************
;#ZONA5############################"INTERRUPCOES"#########################################
;-----------------------------------------------------------------------------------------


				
				ORIG	FE00h ;TABELA DE INTERRUPCOES
INT0			WORD	INTERRUPCAO
interrupcao1	WORD	INTERRUPCAO1

				ORIG	FE07h
interrupcao7	WORD	INTERRUPCAO7
				ORIG	FE09h
interrupcao9	WORD	INTERRUPCAO9
				ORIG	FE0Bh
interrupcaob	WORD	INTERRUPCAOB
				ORIG	FE0Fh
interrupcao_tmp	WORD	INTERRUPCAO_15
	

;*****************************************************************************************
;#ZONA6#########################"INICIO DO CODIGO"########################################
;-----------------------------------------------------------------------------------------	
	
	
				ORIG	0000h
				MOV     R7, SP_INICIAL ;Ativa a pilha
				MOV     SP, R7
				
				
				MOV 	R7, FFFFh		;Ativa o apontador do Ecra;
				MOV 	M[IO_CONTROL], R7	
				
				MOV  	R7, INT_MASK_INIT
				MOV		M[INT_MASK_ADDR], R7
				ENI
				
				JMP		Inicio


;-----------------------------------------------------------------------------------------
;ROTINAS DE INTERRUPÇAO					
;-----------------------------------------------------------------------------------------				
				
				
INTERRUPCAO1:	INC		M[STATUS]
				RTI

INTERRUPCAO:	INC		M[FLAG_0]
				RTI
				
INTERRUPCAOB:	INC		M[FLAG_B]
				RTI
				
INTERRUPCAO7:	INC		M[FLAG_7]
				RTI
				
INTERRUPCAO9:	INC		M[FLAG_9]
				RTI
;Interrupcao15	Trata a interrupcao do temporizador
;				EFEITOS:	Altera M[ContadorTemp]
;							Reativa contador
INTERRUPCAO_15:	MOV		R7, 1d				
				RTI
			

;******************************************************************************************	
			
;EscreveCar:	Imprime um caracter no ecra
;	INPUT:	R1: Posicao
;			R3: Caracter
;Esta funcao e utilizada para escrever as mensagens inciais e finais. nao guarda em espacos na memoria

EscreveCar:		PUSH	R1
				PUSH 	R3
				MOV		M[IO_CONTROL], R1
				MOV		M[IO_WRITE], R3
				POP		R3
				POP		R1
				RET

				
				
;EscreveStr		Imprime uma string
;	INPUT:	R1: Posicao inicial
;			R2:	string
;Esta funcao e utilizada para escrever as mensagens inciais e finais. nao guarda em espacos na memoria

EscreveStr:		PUSH	R1
				PUSH	R2
				PUSH	R3
CicloString:	MOV		R3, M[R2]
				CMP		R3, FIM_TEXTO 
				BR.Z	FimEscStr
				CALL	EscreveCar
				INC		R2
				INC		R1

				BR		CicloString
FimEscStr:		POP		R3
				POP		R2
				POP		R1
				RET
				
				

;##########################################

EscCarTab:		PUSH	R1
				PUSH 	R3
				MOV		M[IO_CONTROL], R1
				MOV		R6,R1
				ADD		R6,Tabela_jogo
				MOV		R5,1
				MOV		M[R6],R5
				MOV		M[IO_WRITE], R3
				POP		R3
				POP		R1
				RET
;EscreveStr		Imprime uma string
;	INPUT:	R1: Posicao inicial
;			R2:	string
EscStrTab:		PUSH	R1
				PUSH	R2
				PUSH	R3
CicloString2:	MOV		R3, M[R2]
				CMP		R3, FIM_TEXTO 
				BR.Z	FimEscStr2
				CALL	EscCarTab
				INC		R2
				INC		R1

				BR		CicloString2
FimEscStr2:		POP		R3
				POP		R2
				POP		R1
				RET
				
				
				
;******************************************************************************************	



;ESCREVE_LCD:		PUSH	R5
;					PUSH	R6
;					PUSH	R7				
;CICLO_ESC_LCD:		MOV		R5, M[R6]		
;					CMP		R5, FIM_TEXTO
;					BR.Z	FIM_LCD
;					MVBL	M[IO_LCD_CONTROL], R7		; posicionar o cursor
;					MOV		M[IO_LCD_WRITE], R5
;					INC		R6					; passar para o proximo endereco de caracter
;					INC		R7					; passar o cursor para a proxima posicao
;					BR		CICLO_ESC_LCD
;					
;	FIM_LCD:		POP		R7
;					POP		R6
;					POP		R5
;					RETN	1
				
				

;******************************************************************************************	


		
				
;EscreveNo7SGM:	
;				INPUT:	R1 => valor a imprimir
;				OUTPUT:	NADA
;				EFEITOS: Altera o display de 7 segmentos

EscreveNo7SGM:	PUSH	R1
				PUSH	R2
				PUSH	R3
				MOV		R3,	DIPLAY_7SGM
Ciclo7SGM:		MOV		R2,10
				DIV		R1,R2
				MOV		M[R3],R2
				INC		R3
				CMP		R1,R0
				BR.NZ	Ciclo7SGM
				POP		R3
				POP		R2
				POP		R1
				RET
				
;LimpaEcra	Imprime uma string
;	INPUT:	

LimpaEcra:		PUSH 	R1
				PUSH	R2
				PUSH 	R3
				MOV		R3,N_LINHAS
				
				MOV		R1, 0001h
				MOV		R2, STR_limpa
CicloLE:		CMP		R3,R0
				BR.Z	FimLE
				CALL	EscreveStr
				ADD		R1, 0100h
				DEC		R3
				BR		CicloLE
FimLE:			POP		R3
				POP		R2
				POP		R1
				RET
				
;******************************************************************************************	
;Esta funcao permite desenhar o taboleiro inicial

DesenhaTab:		MOV		R1, INICIO_TAB
				MOV		R2, STR_TOPO
				CALL	EscStrTab
				MOV		R3,20
DesLim:			CMP		R3, R0
				BR.Z	DesFim
				ADD		R1, 0100h
				MOV		R2, LATERAL
				CALL	EscStrTab
				ADD		R1, 0031h
				CALL	EscStrTab
				SUB		R1, 0031h
				DEC		R3
				JMP		DesLim				
DesFim:			ADD		R1, 0100h
				MOV		R2, STR_TOPO
				CALL	EscStrTab
				RET		
;******************************************************************************************	
;Esta funcao altera o vetor do jogador um caso uma interropcao seja activada, altera a posicao
;seguinte do jogador, guarda-a na memoria e compara se e' possivel efectual essa jogada sem que
;haja gameover

EscJ1:			PUSH	R1
				PUSH	R2
				PUSH	R3
				CAll 	VETOR_J1 ; altera o vetor
				MOV		R2, M[vetor_J1]
				ADD		M[POS_JOG1],R2
				MOV		R1,M[POS_JOG1]
				MOV		R6,R1
				ADD		R6,Tabela_jogo
				CMP		M[R6],R0
				JMP.NZ	MSG_Fim_Jogo
				MOV		R3, M[JOGADOR1]
				CALL	EscCarTab
				POP		R3
				POP		R2
				POP		R1
				RET
				

;******************************************************************************************	
;Esta funcao altera o vetor do jogador um caso uma interropcao seja activada, altera a posicao
;seguinte do jogador, guarda-a na memoria e compara se e' possivel efectual essa jogada sem que
;haja gameover				
				
				
EscJ2:			PUSH	R1
				PUSH	R2
				PUSH	R3
				CAll 	VETOR_J2 ; altera o vetor
				MOV		R2, M[vetor_J2]
				ADD		M[POS_JOG2],R2
				MOV		R1,M[POS_JOG2]
				MOV		R6,R1
				ADD		R6,Tabela_jogo
				CMP		M[R6],R0
				JMP.NZ	MSG_Fim_Jogo
				MOV		R3, M[JOGADOR2]
				CALL	EscCarTab
				POP		R3
				POP		R2
				POP		R1
				RET
				
				
;******************************************************************************************
				
UpdateJogo:		PUSH	R1
				MOV		M[ContadorTemp],R0 ;Az qualquer coisa que e suposto fazer a cada 0.7segundos
				CALL	EscJ1
				CALL	EscJ2
				POP		R1
				RET

				
;******************************************************************************************

MudaNivel:		PUSH	R1
				PUSH	R2
				PUSH	R3
				PUSH	R4
				MOV		R4, 000Fh
				
;vai mudar do nivel 1 para o 2

MudaNivel2:		MOV		R1,NIVEL2		
				CMP		M[TempoEntreNivel],R1	
				BR.NZ	MudaNivel3
				MOV		R5, VELOCIDADE2
				MOV		M[Velocidade_Jogo],R5
				MOV		R1,NIVEL3
				MOV		M[TempoEntreNivel],R1
				ADD		M[LEDS_CONTER], R4
				JMP		FimMudaNivel
				
;vai mudar do nivel 2 para o 3
				
MudaNivel3:		MOV		R1,NIVEL3				
				CMP		M[TempoEntreNivel],R1	
				BR.NZ	MudaNivel4
				MOV		R5, VELOCIDADE3
				MOV		M[Velocidade_Jogo],R5
				MOV		R1,NIVEL4
				MOV		M[TempoEntreNivel],R1
				ROL		M[LEDS_CONTER],4
				ADD		M[LEDS_CONTER], R4
				JMP		FimMudaNivel
				
;vai mudar do nivel 3 para o 4
				
MudaNivel4:		MOV		R1,NIVEL4				
				CMP		M[TempoEntreNivel],R1	
				BR.NZ	MudaNivel5
				MOV		R5, VELOCIDADE4
				MOV		M[Velocidade_Jogo],R5
				MOV		R1,NIVEL5
				MOV		M[TempoEntreNivel],R1
				ROL		M[LEDS_CONTER],4
				ADD		M[LEDS_CONTER], R4
				JMP		FimMudaNivel

MudaNivel5:		MOV		R1, VELOCIDADE5			;BUG EM POR A VELOCIADE A 1
				MOV		M[Velocidade_Jogo],R1
				ROL		M[LEDS_CONTER],4
				ADD		M[LEDS_CONTER], R4

				
FimMudaNivel:	CALL	LEDS
				POP		R4
				POP		R3
				POP		R2
				POP		R1
				RET
				
;******************************************************************************************				
				
Inc7SGM:		PUSH	R1
				MOV		R1,10
				MOV		M[ContadorSegundo],R1
				INC		M[TempoJogo]
				MOV		R1,M[TempoJogo]
				CALL	EscreveNo7SGM
				POP		R1
				RET


;******************************************************************************************
				
LEDS:			PUSH	R1
				MOV		R1,M[LEDS_CONTER]
				MOV		M[FFF8h], R1
				POP		R1
				RET

;******************************************************************************************
				
;######################################################
;JOGADOR 1
;######################################################

VETOR_J1:		CMP	M[FLAG_0],R0
				JMP.Z	direita_J1
				MOV		R2,M[vetor_J1]
				CMP		R2,0001h
				BR.NZ   teste1
				MOV		R2,0100h
				MOV		M[vetor_J1],R2
				NEG		M[vetor_J1]
				MOV		M[FLAG_0],R0
				RET
teste1:			MOV		R3,0001h
				NEG		R3
				CMP		R2,R3
     			BR.NZ   teste2
				MOV		R2,0100h
				MOV		M[vetor_J1],R2
				MOV		M[FLAG_0],R0
				RET
teste2:			MOV		R3,0100h
				NEG		R3
				CMP		R2,R3
				BR.NZ   teste3
				MOV		R2,0001h
				MOV		M[vetor_J1],R2
				NEG		M[vetor_J1]
				MOV		M[FLAG_0],R0
				RET
teste3:			MOV		R2,0001h
				MOV		M[vetor_J1],R2
				MOV		M[FLAG_0],R0
				RET
direita_J1:		CMP	M[FLAG_B],R0
				JMP.Z    sair
				MOV		R2,M[vetor_J1]
				CMP		R2,0001h
				BR.NZ   teste4
				MOV		R2,0100h
				MOV		M[vetor_J1],R2
				MOV		M[FLAG_B],R0
				RET
teste4:			MOV		R3,0001h
				NEG		R3
				CMP		R2,R3
     			BR.NZ   teste5
				MOV		R2,0100h
				MOV		M[vetor_J1],R2
				NEG		M[vetor_J1]
				MOV		M[FLAG_B],R0
				RET
teste5:			MOV		R3,0100h
				NEG		R3
				CMP		R2,R3
				BR.NZ   teste6
				MOV		R2,0001h
				MOV		M[vetor_J1],R2
				MOV		M[FLAG_B],R0
				RET
teste6:			MOV		R2,0001h
				MOV		M[vetor_J1],R2
				NEG		M[vetor_J1]
				MOV		M[FLAG_B],R0
sair:			RET


;######################################################
;JOGADOR 2
;######################################################


VETOR_J2:		CMP	M[FLAG_7],R0
				JMP.Z	direita_J2
				MOV		R2,M[vetor_J2]
				CMP		R2,0001h
				BR.NZ   teste7
				MOV		R2,0100h
				MOV		M[vetor_J2],R2
				NEG		M[vetor_J2]
				MOV		M[FLAG_7],R0
				RET
teste7:			MOV		R3,0001h
				NEG		R3
				CMP		R2,R3
     			BR.NZ   teste8
				MOV		R2,0100h
				MOV		M[vetor_J2],R2
				MOV		M[FLAG_7],R0
				RET
teste8:			MOV		R3,0100h
				NEG		R3
				CMP		R2,R3
				BR.NZ   teste9
				MOV		R2,0001h
				MOV		M[vetor_J2],R2
				NEG		M[vetor_J2]
				MOV		M[FLAG_7],R0
				RET
teste9:			MOV		R2,0001h
				MOV		M[vetor_J2],R2
				MOV		M[FLAG_7],R0
				RET
direita_J2:		CMP	M[FLAG_9],R0
				JMP.Z    sair2
				MOV		R2,M[vetor_J2]
				CMP		R2,0001h
				BR.NZ   teste10
				MOV		R2,0100h
				MOV		M[vetor_J2],R2
				MOV		M[FLAG_9],R0
				RET
teste10:		MOV		R3,0001h
				NEG		R3
				CMP		R2,R3
     			BR.NZ   teste11
				MOV		R2,0100h
				MOV		M[vetor_J2],R2
				NEG		M[vetor_J2]
				MOV		M[FLAG_9],R0
				RET
teste11:		MOV		R3,0100h
				NEG		R3
				CMP		R2,R3
				BR.NZ   teste12
				MOV		R2,0001h
				MOV		M[vetor_J2],R2
				MOV		M[FLAG_9],R0
				RET
teste12:		MOV		R2,0001h
				MOV		M[vetor_J1],R2
				NEG		M[vetor_J1]
				MOV		M[FLAG_9],R0
sair2:			RET


;*****************************************************************************************
;####################################"PRINCIPAL"##########################################
;-----------------------------------------------------------------------------------------										
	
Inicio:			MOV		R1, POS_MENSAGEM
				MOV		R2, STR_MENSAGEM
				CALL	EscreveStr
				MOV		R1, POS_MENSAGEM2
				MOV		R2, STR_MENSAGEM2
				CALL	EscreveStr
			
				;MOV 	R7, LINHA_1_LCD	 	; mover a posicao do caracter inicial para o R7
				;MOV		R6, STR_LCD_TEMPO_MAX 	 	; mover o endereco do texto a escrever para o R6
				;CALL	ESCREVE_LCD
				;MOV 	R7, LINHA_2_LCD_P1	 	; mover a posicao do caracter inicial para o R7
				;MOV		R6, STR_LCD_JOG1 	 	; mover o endereco do texto a escrever para o R6
				;CALL	ESCREVE_LCD
				;MOV 	R7, LINHA_2_LCD_P2 	; mover a posicao do caracter inicial para o R7
				;MOV		R6, STR_LCD_JOG2 	 	; mover o endereco do texto a escrever para o R6
				;CALL	ESCREVE_LCD
				
;*****************************************************************************************		

;R1 --> 
;R2 --> 
;R3 --> 
;R4 --> 
;R5 --> 
;R6 -->
;R7 --> 



Ciclo:			CMP		M[STATUS],R0
				BR.Z	Ciclo
InitJogo:		CALL	LimpaEcra
				MOV		R1,R0
				CALL	EscreveNo7SGM
				
				MOV  	R7, INT_MASK_GAME
				MOV		M[INT_MASK_ADDR], R7		
				CALL	DesenhaTab
				MOV		R1, POS_JOG1
				MOV 	R3, JOGADOR1
				CALL	EscreveCar
				MOV		R1, POS_JOG2
				MOV		R3, JOGADOR2
				CALL	EscreveCar
				MOV		R5, VELOCIDADE1
				MOV		M[Velocidade_Jogo],R5
				
				
CicloJogo:		MOV		R7,1
				MOV		M[TIMER_VALUE],R7
				MOV		M[TIMER_CONTROL],R7				
				MOV		R7, R0
				ENI
				CMP		R7, R0
				BR.Z 	-3
				INC		M[ContadorTemp]
				INC		M[ContadorNivel]
				DEC		M[ContadorSegundo]
				
				MOV		R5,M[Velocidade_Jogo] ;Se passaram X segundos, atualiza o jogo
				CMP		M[ContadorTemp], R5;	x=0.7, 0.5, 0.3, 0.2, 0.1
				CALL.Z	UpdateJogo
				
				MOV		R1,M[TempoEntreNivel] ;Se passaram Y segundos, muda de nivel
				CMP		M[ContadorNivel],R1;	Y = 10, 20, 40, 60
				CALL.Z	MudaNivel
				
				CMP		M[ContadorSegundo],R0
				CALL.Z	Inc7SGM
				
				JMP		CicloJogo
				
MSG_Fim_Jogo:	MOV		R1, POS_MENSAGEM3
				MOV		R2, STR_FIMJOGO
				CALL	EscreveStr
				MOV		R1, POS_MENSAGEM4
				MOV		R2, STR_FIMJOGO2
				CALL	EscreveStr
				
;*****************************************************************************************

;Vai por o record de tempo no LCD
;Falta fazer uma comparacao	com o tempo do jogo que acabou, para ver qual é maior. o que for maior vai ser imprimido no LCD
;Usar TempoEscLCD e TempoMaxEscLCD para comparar
;LCD_TEMPO_MAX:	MOV		R5, M[TempoEscLCD]
;				MOV		R6, M[TempoMaxEscLCD]
;				CMP		R6, R5
;				BR.NN	LCD_TMP_MAX
;				MOV		M[TempoMaxEscLCD], R5



;LCD_TMP_MAX:	MOV		R6, M[TempoMaxEscLCD]
;				MOV		R7, LINHA_1_LCD_VALOR
;				ADD		R6, 0030h		;converte o valor para ASCII
;				CALL	ESCREVE_LCD

;*****************************************************************************************		
				
				
FimDoJogo:		MOV		M[STATUS],R0
NewGame:		MOV		R1, 2000h
				MOV		R2, Tabela_jogo   
cicloNW:		MOV		M[R2], R0
				INC		R2
				DEC		R1
				CMP		R1,R0
				BR.NZ	cicloNW
				MOV		R1, 0C17h	
				MOV		M[POS_JOG1], R1
				MOV		R1, 0C37h
				MOV		M[POS_JOG2], R1
				
				MOV		R1,0001h
				MOV		M[vetor_J1], R1
				MOV		M[vetor_J2], R1
				MOV 	M[TempoJogo], R0
				MOV		M[ContadorTemp], R0
				MOV		R1, 7h	
				MOV		M[Velocidade_Jogo], R1 
				MOV		M[ContadorNivel], R0
				MOV		M[CONT_TEMPO_JOGO], R0
				MOV		R1, 7d
				MOV		M[NIVEL], R1
				MOV		M[LEDS_CONTER], R0

FDJ:			CMP		M[STATUS], R0
				JMP.NZ	Ciclo
				BR		FDJ
				
	

;*****************************************************************************************

