import pytest
from to_do_list import GerenciadorTarefas

def test_integracao_adicionar_e_remover_tarefa():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Estudar POO")
    assert len(gerenciador.listar_tarefas()) == 1
    gerenciador.remover_tarefa(0)
    assert len(gerenciador.listar_tarefas()) == 0

def test_integracao_marcar_tarefa_como_concluida():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Estudar POO")
    gerenciador.marcar_tarefa_concluida(0)
    assert gerenciador.listar_tarefas()[0].concluida == True
