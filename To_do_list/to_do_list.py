class Tarefa:
    def __init__(self, descricao):
        self.descricao = descricao
        self.concluida = False

    def marcar_como_concluida(self):
        self.concluida = True

    def __str__(self):
        status = "Concluída" if self.concluida else "Pendente"
        return f"Tarefa: {self.descricao} | Status: {status}"


class GerenciadorTarefas:
    def __init__(self):
        self.tarefas = []

    def adicionar_tarefa(self, descricao):
        tarefa = Tarefa(descricao)
        self.tarefas.append(tarefa)

    def remover_tarefa(self, indice):
        if 0 <= indice < len(self.tarefas):
            self.tarefas.pop(indice)

    def marcar_tarefa_concluida(self, indice):
        if 0 <= indice < len(self.tarefas):
            self.tarefas[indice].marcar_como_concluida()

    def listar_tarefas(self):
        return self.tarefas

    def listar_tarefas_pendentes(self):
        return [tarefa for tarefa in self.tarefas if not tarefa.concluida]


def main():
    gerenciador = GerenciadorTarefas()

    while True:
        print("\n1. Adicionar Tarefa")
        print("2. Remover Tarefa")
        print("3. Marcar Tarefa como Concluída")
        print("4. Listar Tarefas")
        print("5. Listar Tarefas Pendentes")
        print("6. Sair")

        opcao = input("Escolha uma opção: ")

        if opcao == "1":
            descricao = input("Descrição da tarefa: ")
            gerenciador.adicionar_tarefa(descricao)
        elif opcao == "2":
            indice = int(input("Índice da tarefa a remover: "))
            gerenciador.remover_tarefa(indice)
        elif opcao == "3":
            indice = int(input("Índice da tarefa a marcar como concluída: "))
            gerenciador.marcar_tarefa_concluida(indice)
        elif opcao == "4":
            tarefas = gerenciador.listar_tarefas()
            for i, tarefa in enumerate(tarefas):
                print(f"{i}. {tarefa}")
        elif opcao == "5":
            tarefas_pendentes = gerenciador.listar_tarefas_pendentes()
            for i, tarefa in enumerate(tarefas_pendentes):
                print(f"{i}. {tarefa}")
        elif opcao == "6":
            break
        else:
            print("Opção inválida, tente novamente.")

if __name__ == "__main__":
    main()
