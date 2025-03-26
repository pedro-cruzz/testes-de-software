import time
from to_do_list import GerenciadorTarefas

def test_desempenho():
    gerenciador = GerenciadorTarefas()
    
    start_time = time.time()
    for i in range(10000):
        gerenciador.adicionar_tarefa(f"Tarefa {i}")
    end_time = time.time()
    tempo_adicionar = end_time - start_time
    assert tempo_adicionar < 2  

    start_time = time.time()
    for i in range(10000):
        gerenciador.remover_tarefa(0)
    end_time = time.time()
    tempo_remover = end_time - start_time
    assert tempo_remover < 2  

