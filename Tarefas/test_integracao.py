import unittest
from io import StringIO
import sys
from to_do_list import main

class TestSistema(unittest.TestCase):
    def test_interacao_usuario(self):
        entrada = "1\nFazer exercícios\n4\n6\n"  # Simula a entrada do usuário
        sys.stdin = StringIO(entrada)
        sys.stdout = StringIO()
        
        main()  # Executa o menu principal
        
        saida = sys.stdout.getvalue()
        self.assertIn("Tarefa: Fazer exercícios | Status: Pendente", saida)  # Verifica se a tarefa foi adicionada e está pendente
