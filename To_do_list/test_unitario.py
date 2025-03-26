import pytest
from to_do_list import Tarefa, GerenciadorTarefas

def test_tarefa_criacao():
    tarefa = Tarefa("Estudar POO")
    assert tarefa.descricao == "Estudar POO"
    assert tarefa.concluida == False

def test_marcar_como_concluida():
    tarefa = Tarefa("Estudar POO")
    tarefa.marcar_como_concluida()
    assert tarefa.concluida == True

def test_str_tarefa():
    tarefa = Tarefa("Estudar POO")
    assert str(tarefa) == "Tarefa: Estudar POO | Status: Pendente"
    tarefa.marcar_como_concluida()
    assert str(tarefa) == "Tarefa: Estudar POO | Status: Concluída"

def test_adicionar_tarefa():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Estudar POO")
    assert len(gerenciador.listar_tarefas()) == 1

def test_remover_tarefa():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Estudar POO")
    gerenciador.remover_tarefa(0)
    assert len(gerenciador.listar_tarefas()) == 0

def test_marcar_tarefa_concluida():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Estudar POO")
    gerenciador.marcar_tarefa_concluida(0)
    assert gerenciador.listar_tarefas()[0].concluida == True

def test_listar_tarefas_pendentes():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Estudar POO")
    gerenciador.adicionar_tarefa("Estudar Design Patterns")
    gerenciador.marcar_tarefa_concluida(0)
    pendentes = gerenciador.listar_tarefas_pendentes()
    assert len(pendentes) == 1
    assert pendentes[0].descricao == "Estudar Design Patterns"
