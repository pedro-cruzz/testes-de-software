from to_do_list import GerenciadorTarefas

def test_regressao():
    gerenciador = GerenciadorTarefas()
    gerenciador.adicionar_tarefa("Estudar POO")
    assert len(gerenciador.listar_tarefas()) == 1
    gerenciador.marcar_tarefa_concluida(0)
    assert gerenciador.listar_tarefas()[0].concluida == True
    gerenciador.remover_tarefa(0)
    assert len(gerenciador.listar_tarefas()) == 0

