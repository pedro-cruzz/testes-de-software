import tkinter as tk
from tkinter import messagebox, ttk

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


class Interface:
    def __init__(self, root):
        self.gerenciador = GerenciadorTarefas()
        self.root = root
        self.root.title("Gerenciador de Tarefas")
        self.root.geometry("600x400")  # Tamanho da janela
        self.root.configure(bg="#f0f0f0")  # Cor de fundo

        # Fonte padrão
        self.fonte = ("Arial", 12)

        # Frame principal
        self.frame = tk.Frame(root, bg="#f0f0f0")
        self.frame.pack(pady=20)

        # Campo de entrada para a descrição da tarefa
        self.label = tk.Label(self.frame, text="Descrição da Tarefa:", font=self.fonte, bg="#f0f0f0")
        self.label.grid(row=0, column=0, padx=5, pady=5)

        self.entry = tk.Entry(self.frame, width=40, font=self.fonte)
        self.entry.grid(row=0, column=1, padx=5, pady=5)

        # Botão para adicionar tarefa
        self.add_button = tk.Button(
            self.frame, text="Adicionar Tarefa", command=self.adicionar_tarefa,
            font=self.fonte, bg="#4CAF50", fg="white"
        )
        self.add_button.grid(row=0, column=2, padx=10, pady=5)

        # Lista de tarefas (Treeview)
        self.tree = ttk.Treeview(
            root, columns=("Descrição", "Status"), show="headings", height=10
        )
        self.tree.heading("Descrição", text="Descrição")
        self.tree.heading("Status", text="Status")
        self.tree.column("Descrição", width=400)
        self.tree.column("Status", width=150)
        self.tree.pack(pady=10)

        # Frame para os botões de ação
        self.button_frame = tk.Frame(root, bg="#f0f0f0")
        self.button_frame.pack(pady=10)

        # Botão para marcar tarefa como concluída
        self.complete_button = tk.Button(
            self.button_frame, text="Marcar como Concluída", command=self.marcar_como_concluida,
            font=self.fonte, bg="#008CBA", fg="white"
        )
        self.complete_button.pack(side=tk.LEFT, padx=5)

        # Botão para remover tarefa
        self.remove_button = tk.Button(
            self.button_frame, text="Remover Tarefa", command=self.remover_tarefa,
            font=self.fonte, bg="#f44336", fg="white"
        )
        self.remove_button.pack(side=tk.LEFT, padx=5)

        # Botão para listar tarefas pendentes
        self.pendentes_button = tk.Button(
            self.button_frame, text="Listar Pendentes", command=self.listar_pendentes,
            font=self.fonte, bg="#FFC107", fg="black"
        )
        self.pendentes_button.pack(side=tk.LEFT, padx=5)

        # Botão para listar todas as tarefas
        self.todas_button = tk.Button(
            self.button_frame, text="Listar Todas", command=self.listar_todas,
            font=self.fonte, bg="#9E9E9E", fg="white"
        )
        self.todas_button.pack(side=tk.LEFT, padx=5)

        # Atualiza a lista de tarefas
        self.atualizar_lista()

    def adicionar_tarefa(self):
        descricao = self.entry.get()
        if descricao:
            self.gerenciador.adicionar_tarefa(descricao)
            self.entry.delete(0, tk.END)
            self.atualizar_lista()
        else:
            messagebox.showwarning("Aviso", "A descrição da tarefa não pode estar vazia.")

    def remover_tarefa(self):
        try:
            item_selecionado = self.tree.selection()[0]
            indice = int(self.tree.index(item_selecionado))
            self.gerenciador.remover_tarefa(indice)
            self.atualizar_lista()
        except IndexError:
            messagebox.showwarning("Aviso", "Selecione uma tarefa para remover.")

    def marcar_como_concluida(self):
        try:
            item_selecionado = self.tree.selection()[0]
            indice = int(self.tree.index(item_selecionado))
            self.gerenciador.marcar_tarefa_concluida(indice)
            self.atualizar_lista()
        except IndexError:
            messagebox.showwarning("Aviso", "Selecione uma tarefa para marcar como concluída.")

    def listar_pendentes(self):
        self.tree.delete(*self.tree.get_children())
        for tarefa in self.gerenciador.listar_tarefas_pendentes():
            self.tree.insert("", "end", values=(tarefa.descricao, "Pendente"))

    def listar_todas(self):
        self.atualizar_lista()

    def atualizar_lista(self):
        self.tree.delete(*self.tree.get_children())
        for tarefa in self.gerenciador.listar_tarefas():
            status = "Concluída" if tarefa.concluida else "Pendente"
            self.tree.insert("", "end", values=(tarefa.descricao, status))


if __name__ == "__main__":
    root = tk.Tk()
    app = Interface(root)
    root.mainloop()