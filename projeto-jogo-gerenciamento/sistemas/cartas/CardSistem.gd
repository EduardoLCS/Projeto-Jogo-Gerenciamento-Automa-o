class_name OperacoesCartas
extends Node
@export_range(1, 10) var num_slots_cartas_comuns: int = 1
@export_range(0, 2) var num_slots_cartas_lendarias: int = 0
var slots_comuns: Array[CartaResource] = []
var slots_lendarias: Array[CartaResource] = []

## Tenta alocar uma carta no slot correspondente (Comum ou Lendária)
## Retorna true se a carta foi equipada com sucesso, ou false caso contrário
func colocar_carta(carta: CartaResource) -> bool:
	# Validação defensiva: impede operações caso o recurso passado seja nulo
	if not carta:
		print("Nenhuma carta informada.")
		return false
	
	# Roteamento baseado no atributo 'tipo' definido no recurso da carta
	match carta.tipo:
		"Comum":
			# Checa se ainda há espaço disponível nos slots comuns da construção
			if slots_comuns.size() < num_slots_cartas_comuns:
				slots_comuns.append(carta) # Registra a carta na lista de comuns
				print("Carta comum ", carta.nome, " adicionada.")
				return true
			else:
				print("Slots comuns cheios!")
				return false
			
		"Lendária":
			# Checa se ainda há espaço disponível nos slots lendários da construção
			if slots_lendarias.size() < num_slots_cartas_lendarias:
				slots_lendarias.append(carta) # Registra a carta na lista de lendárias
				print("Carta lendária ", carta.nome, " adicionada.")
				return true
			else:
				print("Slots lendários cheios.")
				return false
		
		# Caso de segurança se o tipo da carta contiver um valor inesperado
		_:
			print("Tipo de carta não reconhecido: ", carta.tipo)
			return false

## Rola um teste percentual (0.0 a 1.0) comparando contra o atributo da carta
## Retorna true se a ação foi bem-sucedida
func sucesso_na_acao(atributo_exigido: String, carta: CartaResource) -> bool:
	if not carta:
		return false

	var modificador: float = 0.0
	var teste: float = randf() # Rola um float aleatório entre 0.0 e 1.0

	match atributo_exigido:
		"Sabedoria":
			modificador = carta.sabedoria / 10.0
		"Inteligência":
			modificador = carta.inteligencia / 10.0
		"Força":
			modificador = carta.forca / 10.0
		"Destreza":
			modificador = carta.destreza / 10.0
		_:
			print("Atributo desconhecido para o teste: ", atributo_exigido)
			return false

	# Garante que o modificador não passe de 1.0 (100% de chance)
	modificador = clampf(modificador, 0.0, 1.0)

	# Sucesso ocorre quando a rolagem fica dentro da margem de chance
	return teste <= modificador
		
