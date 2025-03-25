import unittest
from unittest.mock import patch
import tkinter as tk
from to_do_list_interface import Interface 

class TestInterface(unittest.TestCase):
    
    def setUp(self):
        # Criar uma instância de Tkinter e da Interface
        self.root = tk.Tk()
        self.app = Interface(self.root)

    def tearDown(self):
        # Fechar a janela após o teste
        self.root.destroy()

    @patch('tkinter.messagebox.showwarning')  # Mock da função de aviso
    def test_adicionar_tarefa(self, mock_showwarning):
        # Adicionar tarefa
        self.app.entry.insert(0, "Estudar Python")
        self.app.adicionar_tarefa()  # Chama o método de adicionar tarefa

        # Verificar se a tarefa foi adicionada à lista
        tarefas = self.app.tree.get_children()  # Pega as tarefas na árvore
        self.assertEqual(len(tarefas), 1)  # Verifica se
