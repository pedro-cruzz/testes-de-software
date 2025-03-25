import unittest
from to_do_list import Tarefa , GerenciadorTarefas

class TestTarefa(unittest.TestCase):
    def test_criacao_tarefa(self):
        tarefa = Tarefa("Estudar Python")
        self.assertEqual(tarefa.descricao, "Estudar Python")  # Verifica se a descrição está correta
        self.assertFalse(tarefa.concluida)  # Verifica se a tarefa começa como não concluída

    def test_marcar_como_concluida(self):
        tarefa = Tarefa("Fazer compras")
        tarefa.marcar_como_concluida()
        self.assertTrue(tarefa.concluida)  # Verifica se a tarefa foi marcada como concluída

    def test_str(self):
        tarefa = Tarefa("Ler um livro")
        self.assertEqual(str(tarefa), "Tarefa: Ler um livro | Status: Pendente")  # Verifica o retorno do __str__
        tarefa.marcar_como_concluida()
        self.assertEqual(str(tarefa), "Tarefa: Ler um livro | Status: Concluída")  # Verifica se o status é alterado

class TestGerenciadorTarefas(unittest.TestCase):
    def setUp(self):
        # Inicializa o GerenciadorTarefas antes de cada teste
        self.gerenciador = GerenciadorTarefas()

    def test_adicionar_tarefa(self):
        self.gerenciador.adicionar_tarefa("Ler um livro")
        self.assertEqual(len(self.gerenciador.tarefas), 1)  # Verifica se a tarefa foi adicionada
        self.assertEqual(self.gerenciador.tarefas[0].descricao, "Ler um livro")  # Verifica a descrição da tarefa

    def test_remover_tarefa(self):
        self.gerenciador.adicionar_tarefa("Fazer compras")
        self.gerenciador.remover_tarefa(0)
        self.assertEqual(len(self.gerenciador.tarefas), 0)  # Verifica se a tarefa foi removida

    def test_marcar_tarefa_concluida(self):
        self.gerenciador.adicionar_tarefa("Estudar matemática")
        self.gerenciador.marcar_tarefa_concluida(0)
        self.assertTrue(self.gerenciador.tarefas[0].concluida)  # Verifica se a tarefa foi marcada como concluída

    def test_listar_tarefas(self):
        self.gerenciador.adicionar_tarefa("Ir ao mercado")
        tarefas = self.gerenciador.listar_tarefas()
        self.assertEqual(len(tarefas), 1)  # Verifica se a lista de tarefas contém 1 tarefa
        self.assertEqual(tarefas[0].descricao, "Ir ao mercado")  # Verifica se a tarefa na lista é a correta

    def test_listar_tarefas_pendentes(self):
        self.gerenciador.adicionar_tarefa("Estudar física")
        self.gerenciador.adicionar_tarefa("Ler um artigo")
        self.gerenciador.marcar_tarefa_concluida(0)
        pendentes = self.gerenciador.listar_tarefas_pendentes()
        self.assertEqual(len(pendentes), 1)  # Verifica se restou 1 tarefa pendente
        self.assertEqual(pendentes[0].descricao, "Ler um artigo")  # Verifica se a tarefa pendente é a correta
