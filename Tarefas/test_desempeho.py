import time
import unittest
from to_do_list import GerenciadorTarefas  

class TestDesempenho(unittest.TestCase):
    
    def setUp(self):
        """Configura o ambiente de teste antes de cada método de teste"""
        self.gerenciador = GerenciadorTarefas()

    def test_adicionar_tarefas_desempenho(self):
        """Teste de desempenho para adicionar um grande número de tarefas"""
        inicio = time.time()  # Registra o tempo de início
        
        for i in range(10000):  # Adiciona 10.000 tarefas
            self.gerenciador.adicionar_tarefa(f"Tarefa {i}")
        
        fim = time.time()  # Registra o tempo final
        duracao = fim - inicio  # Calcula a duração
        print(f"Tempo para adicionar 10.000 tarefas: {duracao:.6f} segundos")
        
        # Vamos considerar que o tempo de execução não deve ultrapassar 5 segundos para 10.000 tarefas
        self.assertLess(duracao, 5, "Tempo de adição de tarefas excedeu o limite esperado")

    def test_listar_tarefas_desempenho(self):
        """Teste de desempenho para listar todas as tarefas"""
        # Adiciona 10.000 tarefas
        for i in range(10000):
            self.gerenciador.adicionar_tarefa
