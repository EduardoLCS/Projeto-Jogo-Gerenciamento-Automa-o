extends Area2D
class_name Sede

# --- Componentes e Referências ---
@onready var inventario_sede: InventarioComponent = $InventariodaSede
@onready var operacoes_cartas: OperacoesCartas = $OperacoesCartas
@onready var tempo_coleta: Timer = $TempoColeta

# --- Configurações e Variáveis de Estado ---
@export var carta_teste: CartaResource
@export var tempo_determinado_coleta: float = 0.0

# TESTE: Dicionário simulando fontes de recursos ao redor do edifício (remover na integração com o mapa)
var recursos_no_range: Dictionary = {
	"Banana": 100,
	"Maçã": 20
}


func _ready() -> void:
	# Aloca cartas de exemplo para testar o sistema no arranque
	if carta_teste:
		operacoes_cartas.colocar_carta(carta_teste)
		operacoes_cartas.colocar_carta(carta_teste)
	
	# Garante que o sinal timeout está conectado apenas uma vez
	if not tempo_coleta.timeout.is_connected(on_tempo_coleta_timeout):
		tempo_coleta.timeout.connect(on_tempo_coleta_timeout)
		
	# Calibra e inicia o temporizador com base nas cartas equipadas
	atualizar_ciclo_coleta()


## Recalcula o tempo e ajusta o temporizador (chamar sempre que equipar/remover cartas)
func atualizar_ciclo_coleta() -> void:
	tempo_determinado_coleta = determinar_tempo_coleta()
	
	if tempo_determinado_coleta > 0.0:
		tempo_coleta.wait_time = tempo_determinado_coleta
		tempo_coleta.start()
		print("Temporizador iniciado com intervalo de: ", tempo_determinado_coleta, "s")
	else:
		tempo_coleta.stop()
		print("Temporizador pausado: sem cartas ou destreza insuficiente.")


## Função executada a cada disparo do Timer
func on_tempo_coleta_timeout() -> void:
	print("--- O timer apitou! Ciclo de coleta em execução ---")
	
	# Cláusula de guarda inicial: para o ciclo se o mapa estiver completamente sem itens
	if not existem_recursos(recursos_no_range):
		print("Sem recursos em redor para extrair. Temporizador pausado.")
		tempo_coleta.stop()
		return

	# Junta as cartas comuns e lendárias em uma única lista para evitar código duplicado
	var todas_as_cartas: Array[CartaResource] = operacoes_cartas.slots_comuns + operacoes_cartas.slots_lendarias

	for carta in todas_as_cartas:
		# Proteção defensiva: se o último item acabou na carta anterior, interrompe o restante da rodada
		if not existem_recursos(recursos_no_range):
			print("Recursos esgotados durante a rodada de coleta.")
			tempo_coleta.stop()
			break

		# Rola o teste de probabilidade usando o atributo exigido
		var sucesso: bool = operacoes_cartas.sucesso_na_acao("Sabedoria", carta)
		if sucesso:
			efetivar_coleta(recursos_no_range)
		else:
			var nome_carta: String = carta.nome if "nome" in carta else "Carta"
			print(nome_carta, " falhou no teste de Sabedoria.")


## Calcula o intervalo em segundos usando a escala inversa da destreza
func determinar_tempo_coleta() -> float:
	var modificador_tempo: float = 0.0
	var destreza_total: int = 0
	
	# Soma a destreza das cartas comuns
	for carta in operacoes_cartas.slots_comuns:
		destreza_total += carta.destreza
		
	# Soma a destreza das cartas lendárias (o laço não roda se o array estiver vazio)
	for carta in operacoes_cartas.slots_lendarias:
		destreza_total += carta.destreza
			
	print("Destreza Total: ", destreza_total)
	
	# Proteção estrita contra divisão por zero
	if destreza_total <= 0:
		print("Sem cartas ou destreza nula. Coleta parada.")
		return 0.0
	
	# Divisão em float (400.0) para manter a precisão decimal
	modificador_tempo = 400.0 / float(destreza_total)
	print("O tempo calculado é: ", modificador_tempo, " segundos")
	
	return modificador_tempo


## Verifica se ainda há pelo menos uma unidade de qualquer recurso disponível no dicionário
func existem_recursos(recursos_em_volta: Dictionary) -> bool:
	for item in recursos_em_volta:
		if recursos_em_volta[item] > 0:
			return true
	return false


## Seleciona aleatoriamente um recurso disponível, deduz da fonte e deposita no inventário
func efetivar_coleta(recursos_em_volta: Dictionary) -> void:
	var array_recursos_disponiveis: Array = []

	# Filtra apenas recursos cujo saldo atual seja maior que 0
	for item in recursos_em_volta:
		if recursos_em_volta[item] > 0:
			array_recursos_disponiveis.append(item)

	# Trava de segurança contra sorteio em lista vazia
	if array_recursos_disponiveis.is_empty():
		return

	# Sorteia um dos recursos válidos
	var recurso_escolhido: String = array_recursos_disponiveis.pick_random()
	
	# Abate o item da fonte e envia para o inventário local
	recursos_em_volta[recurso_escolhido] -= 1
	inventario_sede.adicionar_item(recurso_escolhido, 1)
	
	print("Coletado 1x ", recurso_escolhido, " | Restante na fonte: ", recursos_em_volta[recurso_escolhido])
