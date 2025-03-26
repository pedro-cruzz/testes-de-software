# Plano de Teste

[link apresentação](https://www.canva.com/design/DAGiTmUD5yU/0-OvjAHFpY2jjmbdgezwVA/edit?utm_content=DAGiTmUD5yU&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

**Organiza+ | Gerenciador de tarefas**

*Versão 1.0*

## Histórico das alterações

   Data    | Versão |    Descrição   | Autor(a)
-----------|--------|----------------|-----------------
27/03/2025 |  1.0   | Release inicial | Pedro, Danyllo, Matheus, Davi, Higor, Flávio, Gabriel, Igor


## 1 - Introdução

Este documento descreve os requisitos a testar, os tipos de testes definidos para cada iteração, os recursos de hardware e software a serem empregados e o cronograma dos testes ao longo do projeto. As seções referentes aos requisitos, recursos e cronograma servem para permitir ao gerente do projeto acompanhar a evolução dos testes.

Com esse documento, será possível:
- Identificar informações de projeto existentes e os componentes de software que devem ser testados.
- Listar os requisitos a testar.
- Recomendar e descrever as estratégias de teste a serem empregadas.
- Identificar os recursos necessários e prover uma estimativa dos esforços de teste.
- Listar os elementos resultantes do projeto de testes.

## 2 - Requisitos a Testar

### Casos de uso:

Identificador do caso de uso | Nome do caso de uso
-----------------------------|---------------------
UC1 | Cadastrar tarefas
UC2 | Escluir tarefas
UC3 | Atualizar status da tarefa

### Requisitos não-funcionais:

Identificador do requisito   | Nome do requisito
-----------------------------|---------------------
RF1 | Usabilidade
RF2 | Desempenho
RF3 | Armazenamento de dados
RF4 | Interface intuitiva

## 3 - Tipos de teste

Os seguintes testes serão realizados:
- Teste de integração;
- Teste de sistema;
- Teste de unidade;
- Teste de aceitação;
- Teste de regressão;
- Teste de desempenho;

## 3.1 - Teste de Integração

Objetivo: Avaliar a interação entre módulos do sistema.

Técnica: ( ) manual  (x) automática

Estágio do teste: Unidade ( )  Integração (x)  Sistema ( )  Aceitação ( )

Abordagem do teste: Caixa branca (x)  Caixa preta (x)

Responsável: Equipe de desenvolvimento

## 3.2 - Teste de Sistema

Objetivo: Verificar se o sistema atende aos requisitos funcionais e não funcionais.

Técnica: (x) manual  (x) automática

Estágio do teste: Unidade ( )  Integração ( )  Sistema (x)  Aceitação ( )

Abordagem do teste: Caixa preta (x)

Responsável: Equipe de testes

## 3.3 - Teste de Unidade

Objetivo: Verificar o funcionamento correto de cada componente individualmente.

Técnica: ( ) manual  (x) automática

Estágio do teste: Unidade (x)  Integração ( )  Sistema ( )  Aceitação ( )

Abordagem do teste: Caixa branca (x)

Responsável: Equipe de desenvolvimento

## 3.4 - Teste de Aceitação

Objetivo: Garantir que o sistema atende às necessidades do usuário final.

Técnica: (x) manual  (x) automática

Estágio do teste: Unidade ( )  Integração ( )  Sistema ( )  Aceitação (x)

Abordagem do teste: Caixa preta (x)

Responsável: Equipe de testes

## 3.5 - Teste de Regressão

Objetivo: Garantir que novas modificações não impactam funcionalidades existentes.

Técnica: ( ) manual  (x) automática

Estágio do teste: Unidade (x)  Integração (x)  Sistema (x)  Aceitação ( )

Abordagem do teste: Caixa preta (x)

Responsável: Equipe de QA

## 3.6 - Teste de Desempenho

Objetivo: Avaliar tempo de resposta e escalabilidade do sistema.

Técnica: ( ) manual  (x) automática

Estágio do teste: Unidade ( )  Integração ( )  Sistema (x)  Aceitação ( )

Abordagem do teste: Caixa preta (x)

Responsável: Equipe de QA

## 4 - Recursos

### 4.1 - Ambiente de teste - Software e Hardware

- Código em Python, utilizando local Storage
- Ferramentas: Pytest, tkinker, Io, Unittest

### 4.2 - Ferramenta de teste

- Pytest para testes em geral
- Unittest para testes unitários
- tkinker para simular uma interface
- Io para gerar um input de string

## 5 - Cronograma

Tipo de teste      | Duração | Data de início | Data de término
-------------------|---------|----------------|-----------------
Planejamento      | 1 semana | 10/03/2025     | 16/03/2025
Desenvolvimento   | 1 semana | 17/03/2025     | 23/03/2025
Implementação    | 2 dias | 24/03/2025     | 25/03/2025
Execução        | 2 dias | 26/03/2025     | 27/03/2025
Avaliação       | 1 dia | 27/03/2025     | 27/03/2025

