# 💳 API de Gestão Bancária

API REST desenvolvida para gerenciamento de contas bancárias e
realização de transações financeiras.

------------------------------------------------------------------------

## 📌 Funcionalidades

-   Criar conta bancária
-   Consultar saldo da conta
-   Realizar transações:
    -   Débito (3% de taxa)
    -   Crédito (5% de taxa)
    -   Pix (sem taxa)
-   Validações:
    -   Conta não pode ser duplicada
    -   Não permite saldo negativo
    -   Conta deve existir para operações

------------------------------------------------------------------------

## 🚀 Tecnologias Utilizadas

-   Ruby 3.x
-   Ruby on Rails (API Only)
-   PostgreSQL (opcional)
-   RSpec (testes)

------------------------------------------------------------------------

## 📦 Endpoints

### ➤ Criar Conta

**POST /conta**

#### Request

``` json
{
  "numero_conta": 234,
  "saldo": 180.37
}
```

#### Response (201)

``` json
{
  "numero_conta": 234,
  "saldo": 180.37
}
```

#### Erros

-   422 → Conta já existente

------------------------------------------------------------------------

### ➤ Consultar Conta

**GET /conta?numero_conta=234**

#### Response (200)

``` json
{
  "numero_conta": 234,
  "saldo": 170.07
}
```

#### Erros

-   404 → Conta não encontrada

------------------------------------------------------------------------

### ➤ Realizar Transação

**POST /transacao**

#### Request

``` json
{
  "forma_pagamento": "D",
  "numero_conta": 234,
  "valor": 10
}
```

#### Regras de Taxa

  Tipo      Sigla   Taxa
  --------- ------- ------
  Débito    D       3%
  Crédito   C       5%
  Pix       P       0%

#### Exemplo cálculo

-   Débito de R\$10 → desconto total = **R\$10,30**
-   Crédito de R\$10 → desconto total = **R\$10,50**
-   Pix de R\$10 → desconto total = **R\$10,00**

#### Response (201)

``` json
{
  "numero_conta": 234,
  "saldo": 170.07
}
```

#### Erros

-   404 → Conta não encontrada
-   404 → Saldo insuficiente

------------------------------------------------------------------------

## ⚙️ Como Executar o Projeto

### Opção recomendada (Docker + Make)

Pré-requisitos:

- Docker
- Docker Compose (plugin `docker compose`)
- Make

Subir toda a stack (API + PostgreSQL + Redis):

```bash
make up
```

A API ficará disponível em:

  http://localhost:3000

Comandos úteis:

```bash
make logs     # acompanha logs da aplicação
make shell    # abre shell no container da aplicação
make down     # derruba os containers
make clean    # derruba e remove volumes
```

------------------------------------------------------------------------

### 1. Clonar repositório

``` bash
git clone git@github.com:seu-usuario/banking-api.git
cd banking-api
```

### 2. Instalar dependências

``` bash
bundle install
```

### 3. Configurar banco (opcional)

``` bash
rails db:create db:migrate
```

### 4. Rodar servidor

``` bash
rails s
```

API disponível em:

    http://localhost:3000

------------------------------------------------------------------------

## 🧪 Rodar Testes

``` bash
bundle exec rspec
```

------------------------------------------------------------------------

## 🧠 Regras de Negócio

-   Não é permitido saldo negativo
-   Não existe limite (sem cheque especial)
-   Taxas são **sempre somadas ao valor da transação**
-   As transações alteram o saldo em tempo real

------------------------------------------------------------------------

## 🏗️ Arquitetura (Sugestão)

-   Controllers → entrada da API
-   Services → regras de negócio (ex: TransactionService)
-   Models → Account
-   Validators → validações específicas

### Patterns utilizados:

-   Service Object
-   Strategy Pattern (para cálculo de taxas)

------------------------------------------------------------------------

## 📌 Melhorias Futuras

-   Autenticação (JWT)
-   Histórico de transações
-   Rate limiting
-   Logs estruturados
-   Dockerização
-   Observabilidade (Prometheus/Grafana)

------------------------------------------------------------------------

## 📄 Licença

Este projeto é apenas para fins de avaliação técnica.
