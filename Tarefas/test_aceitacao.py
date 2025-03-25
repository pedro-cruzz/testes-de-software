import unittest
from to_do_list import GerenciadorTarefas

class TestAceitacao(unittest.TestCase):
    def test_lista_tarefas_pendentes(self):
        gerenciador = GerenciadorTarefas()
        gerenciador.adicionar_tarefa("Comprar leite")
        gerenciador.adicionar_tarefa("Estudar para prova")
        gerenciador.marcar_tarefa_concluida(1)  # Marca a segunda tarefa como concluída
        
        pendentes = gerenciador.listar_tarefas_pendentes()
        self.assertEqual(len(pendentes), 1)  # Verifica que a lista de pendentes tem 1 tarefa
        self.assertEqual(pendentes[0].descricao, "Comprar leite")  # Verifica se a tarefa pendente é "Comprar leite"
