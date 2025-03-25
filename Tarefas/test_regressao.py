import unittest
from to_do_list import GerenciadorTarefas

class TestRegressao(unittest.TestCase):
    def test_remocao_nao_quebra_lista(self):
        gerenciador = GerenciadorTarefas()
        gerenciador.adicionar_tarefa("Revisar código")
        gerenciador.adicionar_tarefa("Fazer backup")
        
        gerenciador.remover_tarefa(0)  # Remove a primeira tarefa
        
        self.assertEqual(gerenciador.tarefas[0].descricao, "Fazer backup")  # Verifica se a lista não quebrou e a segunda tarefa está correta
