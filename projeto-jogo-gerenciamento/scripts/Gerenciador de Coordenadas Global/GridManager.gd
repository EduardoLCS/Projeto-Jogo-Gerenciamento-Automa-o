extends Node

## Dicionário que mapeia coordenadas lógicas para suas respectivas entidades.
## Chave: Vector2i (coluna x, linha y) -> Valor: Node2D (árvore, prédio, etc.)
var entidades: Dictionary = {}


## Registra uma entidade em uma coordenada específica da grade.
## Retorna 'true' se o registro for realizado ou 'false' se a célula já estiver ocupada.
func registrar_coord(coord: Vector2i, entidade: Node2D) -> bool:
	# Verifica se já existe algum ocupante registrado nesta coordenada
	if entidades.has(coord):
		push_warning("[GridManager] Célula já ocupada em: ", coord, " por ", entidades[coord].name)
		return false
	
	# Salva a referência da entidade associada à coordenada lógica
	entidades[coord] = entidade
	print("[GridManager] Registrado em ", coord, " : ", entidade.name)
	return true


## Libera a célula informada quando a entidade for removida ou destruída.
## Retorna 'true' se foi removida com sucesso ou 'false' se já estava vazia.
func desregistrar(coord: Vector2i) -> bool:
	# Verifica se a coordenada realmente continha algo antes de tentar remover
	if not entidades.has(coord):
		push_warning("[GridManager] Não há entidade em ", coord)
		return false
	
	# Remove a chave do dicionário, liberando o espaço na memória
	entidades.erase(coord)
	print("[GridManager] Célula liberada em ", coord)
	return true


## Consulta e retorna a entidade presente na coordenada (ou null caso esteja vazia).
func obter_entidade(coord: Vector2i) -> Node2D:
	# Se a célula estiver vazia, retorna null silenciosamente
	if not entidades.has(coord):
		return null
	
	# Entidade encontrada: exibe aviso de teste e retorna a referência
	print("[GridManager] Há ", entidades[coord].name, " em ", coord)
	return entidades[coord]
	
##Verifica se há algo nas coordenadas informadas e retorna um booleano
func esta_livre(coord: Vector2i) -> bool:
	return not entidades.has(coord)
		
		
