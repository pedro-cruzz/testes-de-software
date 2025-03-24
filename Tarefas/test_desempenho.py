import time
from to_do_list import GerenciadorTarefas

gerenciador = GerenciadorTarefas()
start_time = time.time()

for i in range(1000):
    gerenciador.adicionar_tarefa(f"Tarefa {i}")

end_time = time.time()
print(f"Tempo para adicionar 1000 tarefas: {end_time - start_time:.2f} segundos")