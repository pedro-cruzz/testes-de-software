import unittest
from to_do_list import GerenciadorTarefas, Interface
import tkinter as tk

class TestInterface(unittest.TestCase):
    def setUp(self):
        self.root = tk.Tk()
        self.app = Interface(self.root)

    def test_adicionar_tarefa(self):
        self.app.entry.insert(0, "Nova Tarefa")
        self.app.adicionar_tarefa()
        self.assertEqual(len(self.app.gerenciador.listar_tarefas()), 1)

    def test_remover_tarefa(self):
        self.app.gerenciador.adicionar_tarefa("Tarefa Teste")
        self.app.atualizar_lista()
        self.app.tree.selection_set(self.app.tree.get_children()[0])
        self.app.remover_tarefa()
        self.assertEqual(len(self.app.gerenciador.listar_tarefas()), 0)

if __name__ == "__main__":
    unittest.main()