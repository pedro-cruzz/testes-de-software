import pytest
from to_do_list import Tarefa, GerenciadorTarefas

def test_criar_tarefa():
    tarefa = Tarefa("Estudar Python")
    assert tarefa.descricao == "Estudar Python"
    assert tarefa.concluida is False

def test_marcar_como_concluida():
    tarefa = Tarefa("Fazer compras")
    tarefa.marcar_como_concluida()
    assert tarefa.concluida is True

def test_str_tarefa():
    tarefa = Tarefa("Ir à academia")
    assert str(tarefa) == "Tarefa: Ir à academia | Status: Pendente"
    tarefa.marcar_como_concluida()
    assert str(tarefa) == "Tarefa: Ir à academia | Status: Concluída"

def test_adicionar_tarefa():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Comprar leite")
    assert len(gerenciador.tarefas) == 1
    assert gerenciador.tarefas[0].descricao == "Comprar leite"

def test_remover_tarefa():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Ir ao dentista")
    gerenciador.remover_tarefa(0)
    assert len(gerenciador.tarefas) == 0

def test_marcar_tarefa_concluida():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Ler um livro")
    gerenciador.marcar_tarefa_concluida(0)
    assert gerenciador.tarefas[0].concluida is True

def test_listar_tarefas():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Fazer exercícios")
    assert len(gerenciador.listar_tarefas()) == 1

def test_listar_tarefas_pendentes():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Meditar")
    gerenciador.adicionar_tarefa("Praticar violão")
    gerenciador.marcar_tarefa_concluida(0)
    tarefas_pendentes = gerenciador.listar_tarefas_pendentes()
    assert len(tarefas_pendentes) == 1
    assert tarefas_pendentes[0].descricao == "Praticar violão"
