# Plano de Teste

[link apresentação](https://www.canva.com/design/DAGiTmUD5yU/0-OvjAHFpY2jjmbdgezwVA/edit?utm_content=DAGiTmUD5yU&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

**Sistema de Gerenciamento de Investimentos**

*Versão 1.0*

## Histórico das alterações

   Data    | Versão |    Descrição   | Autor(a)
-----------|--------|----------------|-----------------
dd/mm/aaaa |  1.0   | Release inicial | [Seu Nome]


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
UC1 | Cadastro de investimentos
UC2 | Consulta de investimentos
UC3 | Atualização de valores
UC4 | Relatórios de rentabilidade
UC5 | Exclusão de investimento

### Requisitos não-funcionais:

Identificador do requisito   | Nome do requisito
-----------------------------|---------------------
RF1 | Tempo de resposta inferior a 2s por requisição
RF2 | Segurança dos dados conforme LGPD
RF3 | Conectividade com banco de dados sem falhas

## 3 - Tipos de teste

Os seguintes testes serão realizados:
- Teste de interface de usuário;
- Teste de API;
- Teste de carga;
- Teste de segurança;
- Teste de persistência de dados.

### 3.1 - Teste de Métodos da API

Objetivo: Verificar se os endpoints retornam os resultados esperados.

Técnica: ( ) manual  (x) automática

Estágio do teste: Unidade (x)  Integração ( )  Sistema ( )  Aceitação ( )

Abordagem do teste: Caixa branca (x)  Caixa preta (x)

Responsável: Equipe de desenvolvimento

### 3.2 - Persistência de Dados

Objetivo: Garantir que os dados não se perdem após falhas no sistema.

Técnica: (x) manual  (x) automática

Estágio do teste: Unidade ( )  Integração ( )  Sistema (x)  Aceitação ( )

Abordagem do teste: Caixa preta (x)

Responsável: Equipe de testes

### 3.3 - Teste de Performance

Objetivo: Avaliar tempo de resposta da API.

Técnica: ( ) manual  (x) automática

Estágio do teste: Unidade ( )  Integração ( )  Sistema (x)  Aceitação ( )

Abordagem do teste: Caixa preta (x)

Responsável: Equipe de QA

### 3.4 - Teste de Segurança

Objetivo: Avaliar a segurança da API contra ataques.

Técnica: ( ) manual  (x) automática

Estágio do teste: Unidade ( )  Integração ( )  Sistema (x)  Aceitação ( )

Abordagem do teste: Caixa preta (x)

Responsável: Especialista em segurança

## 4 - Recursos

### 4.1 - Ambiente de teste - Software e Hardware

- Servidor com Node.js e banco de dados PostgreSQL
- Ferramentas: Postman, JMeter, Selenium
- Ambiente cloud para testes escaláveis

### 4.2 - Ferramenta de teste

- Postman para testes de API
- JMeter para testes de carga
- OWASP ZAP para testes de segurança

## 5 - Cronograma

Tipo de teste      | Duração | Data de início | Data de término
-------------------|---------|----------------|-----------------
Planejamento      | 1 semana | dd/mm/aaaa     | dd/mm/aaaa
Desenvolvimento   | 2 semanas | dd/mm/aaaa     | dd/mm/aaaa
Implementação    | 1 semana | dd/mm/aaaa     | dd/mm/aaaa
Execução        | 2 semanas | dd/mm/aaaa     | dd/mm/aaaa
Avaliação       | 1 semana | dd/mm/aaaa     | dd/mm/aaaa

