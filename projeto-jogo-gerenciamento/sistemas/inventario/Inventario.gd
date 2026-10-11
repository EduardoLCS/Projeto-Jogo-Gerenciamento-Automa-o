class_name InventarioComponent
extends Node

@export var slots_maximos: int = 50
@export var limite_stack: int = 100

var itens: Dictionary = {}


func adicionar_item(recurso: String, quantidade: int) -> bool:
	if quantidade <= 0:
		return false

	# 1. Se o recurso já existe no inventário
	if itens.has(recurso):
		var espaco_disponivel: int = limite_stack - itens[recurso]
		
		# O stack já está no talo
		if espaco_disponivel <= 0:
			print("Inventário: Stack de ", recurso, " já está cheio!")
			return false
		
		# Adiciona o que couber (o total pedido ou só até encher o stack)
		var quantidade_a_adicionar: int = mini(quantidade, espaco_disponivel)
		itens[recurso] += quantidade_a_adicionar
		return true

	# 2. Se é um recurso novo
	else:
		if itens.size() < slots_maximos:
			# Respeita o limite_stack mesmo se for o primeiro lote adicionado
			itens[recurso] = mini(quantidade, limite_stack)
			return true
		else:
			print("Inventário: Sem slots livres para novos recursos!")
			return false
