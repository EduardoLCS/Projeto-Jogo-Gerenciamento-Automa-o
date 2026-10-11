extends Node2D
class_name Bananeira

@export var coordenada_grid: Vector2i = Vector2i.ZERO

## 1. Definição dos estágios numerados de 0 a 4
enum Estagio {
	BROTO,           # 0
	MUDA,            # 1
	ADULTA_VERDE,    # 2
	ADULTA_MADURA,   # 3
	CORTADA          # 4
}

## 2. Texturas visuais correspondentes a cada estágio (configuradas no Inspetor)
@export var texturas_estagios: Array[Texture2D] = []

## 3. Estágio inicial padrão
@export var estagio_atual: Estagio = Estagio.BROTO

## 4. Referência ao nó visual único da planta
@onready var sprite_2d: Sprite2D = $Sprite2D

## 5. Variáveis de controle de ciclo de crescimento
var tempo_acumulado: int = 0
var tempo_por_estagio: int = 10


func _ready() -> void:
	# Inscreve a bananeira no grupo de atualização do pulso global
	add_to_group("plantas")
	atualizar_visual()
	GridManager.registrar_coord(coordenada_grid, self) #Registra a coordenada
	#definir_estagio(Estagio.ADULTA_MADURA) #Teste
	#colher() #Teste
	#arrancar() #Teste
	print("[Bananeira] Instanciada na cena no estágio: ", Estagio.keys()[estagio_atual])


## Altera o estágio e reflete a mudança gráfica imediatamente
func definir_estagio(novo_estagio: Estagio) -> void:
	estagio_atual = novo_estagio
	atualizar_visual()


## Atualiza o sprite conforme o índice do enum
func atualizar_visual() -> void:
	if estagio_atual < texturas_estagios.size():
		sprite_2d.texture = texturas_estagios[estagio_atual]
	else:
		push_warning("[Bananeira] Textura ausente para o estágio: " + str(estagio_atual))


## Chamado a cada segundo pelo pulso global do jogo
func acumular_tempo() -> void:
	# Quando madura, suspende o relógio e aguarda a colheita
	if estagio_atual == Estagio.ADULTA_MADURA:
		return
	
	tempo_acumulado += 1
	print("[Bananeira] Pulso: ", tempo_acumulado, "/", tempo_por_estagio, " (Estágio: ", Estagio.keys()[estagio_atual], ")")
	
	if tempo_acumulado >= tempo_por_estagio:
		tempo_acumulado = 0
		
		if estagio_atual == Estagio.CORTADA:
			# O toco se regenera e inicia um novo broto da touceira
			definir_estagio(Estagio.BROTO)
			print("[Bananeira] Novo broto surgiu da touceira cortada!")
		else:
			# Evolui para o estágio seguinte na ordem sequencial
			var proximo: int = estagio_atual + 1
			definir_estagio(proximo as Estagio)
			print("[Bananeira] Evoluiu para: ", Estagio.keys()[estagio_atual])


## Realiza a colheita dos cachos e fibras (acionado pela Sede ou coletor)
func colher() -> Dictionary:
	# Se ainda não estiver madura, recusa a colheita e retorna vazio
	if estagio_atual != Estagio.ADULTA_MADURA:
		print("[Bananeira] Tentativa de colheita ignorada: planta ainda não está madura.")
		return {}
	
	var recursos_obtidos: Dictionary = {
		"Penca de Bananas": 2,
		"Fibra Vegetal Frágil": 10
	}
	
	# Muda para toco e atualiza a imagem no mesmo instante
	definir_estagio(Estagio.CORTADA)
	print("[Bananeira] Colheita realizada com sucesso! Itens entregues: ", recursos_obtidos)
	
	return recursos_obtidos


## Arranca o toco para liberar o espaço e recuperar a muda
func arrancar() -> Dictionary:
	# Só pode ser arrancada se estiver no toco pós-corte
	if estagio_atual != Estagio.CORTADA:
		print("[Bananeira] Não é possível arrancar: a planta precisa estar no estágio CORTADA.")
		return {}
	
	var recursos_obtidos: Dictionary = {
		"Muda de Bananeira": 1
	}
	
	print("[Bananeira] Touceira arrancada! Entregando muda e destruindo nó: ", recursos_obtidos)
	
	# Destrói a instância e a remove automaticamente de todos os grupos
	GridManager.desregistrar(coordenada_grid) #Remove o registro da coordenada
	queue_free()
	
	return recursos_obtidos
