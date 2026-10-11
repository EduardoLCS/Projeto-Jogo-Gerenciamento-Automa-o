class_name CartaResource
extends Resource
				  #Características Primárias
@export var nome: String = "Nome da Carta"
@export var numero: int = 0 #Número da carta
@export_enum('Comum', 'Lendária') var tipo: String = "Comum"
@export_range(0, 5000) var vida: int = 0
@export_range(0, 100) var transportadores: int = 0
@export_multiline var descricao: String = "Descreva a carta"

				 #Atributos
@export_range(0, 10) var inteligencia: int = 0
@export_range(0, 10) var destreza: int = 0
@export_range(0, 10) var sabedoria: int = 0
@export_range(0, 10) var forca: int = 0
 
				#Modificadores
@export_range(0, 10) var satisfacao: int = 10
@export_range(0, 10) var alimentacao: int = 10              
