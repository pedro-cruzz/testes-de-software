import pytest
import tkinter as tk
from to_do_list_interface import Tarefa, GerenciadorTarefas, Interface

@pytest.fixture
def app():
    root = tk.Tk()
    app = Interface(root)
    yield app
    root.quit()

def test_adicionar_tarefa(app):
    app.entry.insert(0, "Estudar POO")
    app.adicionar_tarefa()
    assert len(app.gerenciador.listar_tarefas()) == 1
    assert app.tree.item(app.tree.get_children()[0])['values'] == ['Estudar POO', 'Pendente']

def test_remover_tarefa(app):
    app.entry.insert(0, "Estudar POO")
    app.adicionar_tarefa()
    app.tree.selection_set(app.tree.get_children()[0])
    app.remover_tarefa()
    assert len(app.gerenciador.listar_tarefas()) == 0

def test_marcar_tarefa_como_concluida(app):
    app.entry.insert(0, "Estudar POO")
    app.adicionar_tarefa()
    app.tree.selection_set(app.tree.get_children()[0])
    app.marcar_como_concluida()
    assert app.tree.item(app.tree.get_children()[0])['values'] == ['Estudar POO', 'Concluída']

def test_listar_pendentes(app):
    app.entry.insert(0, "Estudar POO")
    app.adicionar_tarefa()
    app.entry.insert(0, "Estudar Design Patterns")
    app.adicionar_tarefa()
    app.tree.selection_set(app.tree.get_children()[0])
    app.marcar_como_concluida()
    app.listar_pendentes()
    assert len(app.tree.get_children()) == 1
    assert app.tree.item(app.tree.get_children()[0])['values'] == ['Estudar Design Patterns', 'Pendente']

def test_atualizar_lista(app):
    app.entry.insert(0, "Estudar POO")
    app.adicionar_tarefa()
    app.entry.insert(0, "Estudar Design Patterns")
    app.adicionar_tarefa()
    app.atualizar_lista()
    assert len(app.tree.get_children()) == 2
    assert app.tree.item(app.tree.get_children()[0])['values'] == ['Estudar POO', 'Pendente']
    assert app.tree.item(app.tree.get_children()[1])['values'] == ['Estudar Design Patterns', 'Pendente']
