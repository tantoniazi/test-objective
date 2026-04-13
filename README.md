# API bancária (Rails 8)

API JSON com autenticação Devise (sessão), documentação OpenAPI via rswag, testes RSpec, Mailhog e detecção de N+1 com Bullet.

## Requisitos

- Ruby 3.4+ (ver `.ruby-version`)
- Rails 8.1
- PostgreSQL 14+ (ou Docker Compose)
- Bundler

## 1. Instalação

```bash
bundle install
```

Configure o PostgreSQL. Em desenvolvimento local, defina `POSTGRES_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD` e `POSTGRES_DB` se necessário (veja `config/database.yml`). Com Docker Compose, essas variáveis já são injetadas no serviço `app`.

Crie e migre o banco:

```bash
bin/rails db:create db:migrate db:seed
```

O seed cria o usuário padrão e uma conta com saldo inicial.

## 2. Rodar o projeto

```bash
bin/rails server
```

A API escuta em `http://localhost:3000` por padrão.

Com Docker:

```bash
docker compose up --build
```

## 3. Rodar testes

```bash
bundle exec rspec
```

No ambiente de teste, a gem **Bullet** está configurada para **gerar exceção** em consultas N+1. O fluxo `GET /conta` usa `includes(:transactions)` para evitar N+1 ao serializar `transacoes`.

## 4. Mailhog (e-mails de desenvolvimento)

O Action Mailer em desenvolvimento envia via SMTP para o Mailhog (porta **1025**). Interface web: **http://localhost:8025**.

Com Docker Compose, o serviço `mailhog` sobe junto; a app usa `MAILHOG_SMTP_HOST=mailhog`.

Localmente sem Docker:

```bash
docker run -d -p 1025:1025 -p 8025:8025 mailhog/mailhog
```

Variáveis opcionais: `MAILHOG_SMTP_HOST` (padrão `localhost`), `MAILHOG_SMTP_PORT` (padrão `1025`).

Erros inesperados nos controllers que incluem `ApiErrorReporting` enfileiram o `SystemErrorMailer` (mensagem + stacktrace).

## 5. Swagger / OpenAPI

Documentação servida em **http://localhost:3000/api-docs** (UI rswag).

Especificação: `openapi/v1/openapi.yaml`.

Para regenerar a partir dos specs rswag:

```bash
RAILS_ENV=test bin/rails db:test:prepare
bundle exec rake rswag:specs:swaggerize
```

### Autenticação no Swagger

1. Execute **POST /users/sign_in** com o corpo `{"user":{"email":"...","password":"..."}}` (JSON).
2. O navegador armazena o cookie `_test_objective_session`.
3. Chame **POST /conta**, **GET /conta** e **POST /transacao** na mesma origem para o cookie ser enviado.

No campo **Authorize** da UI, use o esquema **cookieAuth** se a versão do Swagger UI permitir informar o cookie manualmente.

## 6. Credenciais padrão (seed)

| Campo  | Valor              |
|--------|--------------------|
| E-mail | `admin@example.com` |
| Senha  | `123456`           |

Conta de exemplo: `numero_conta` **10001**, saldo inicial **5000.00** (associada ao usuário acima).

## Endpoints (todos exigem sessão, exceto login)

### POST /users/sign_in

Corpo (JSON): `{ "user": { "email": "...", "password": "..." } }`

### POST /conta

Cria conta para o usuário autenticado: `numero_conta`, `saldo`.

### GET /conta?numero_conta=...

Retorna `numero_conta`, `saldo` (float) e até 20 `transacoes` recentes.

### POST /transacao

Campos: `numero_conta`, `forma_pagamento` (`P`, `D` ou `C`), `valor`.

- **P (Pix):** saída de valor sem taxa (`saldo -= valor`).
- **D (Débito):** saída com taxa de 3% sobre o valor (`saldo -= valor * 1.03`).
- **C (Crédito):** entrada líquida após taxa de 5% (`saldo += valor * 0.95`).

Não é permitido saldo negativo em débitos/Pix. Contas são sempre validadas e pertencem ao usuário autenticado.

## Rack::Attack (limite de requisições)

A API usa [rack-attack](https://github.com/rack/rack-attack) com limites por IP (tráfego geral, `/conta` e `/transacao`, e `POST /users/sign_in`). Respostas **429** e **403** vêm em JSON.

Quando um throttle, blocklist ou fail2ban dispara, é enfileirado um e-mail via `RackAttackMailer` (no máximo **um alerta por regra + discriminador a cada 10 minutos**, usando `Rails.cache`, para evitar flood na caixa de entrada).

O health check `GET /up` está em safelist. Em **teste**, o Rack::Attack fica **desligado** (`Rack::Attack.enabled = false`).

## Estrutura relevante

- `config/initializers/rack_attack.rb` — regras, respostas JSON e assinatura de notificações.
- `app/mailers/rack_attack_mailer.rb` — alertas de bloqueio/throttle.
- `app/services/transaction_service.rb` — regras de transação e persistência em `transactions`.
- `app/serializers/*` — ActiveModelSerializers.
- `app/controllers/concerns/api_error_reporting.rb` — erros inesperados + e-mail.
- `lib/custom_failure_app.rb` — respostas JSON 401 do Devise.

## CI/CD e Kubernetes

O workflow [`.github/workflows/ci.yml`](.github/workflows/ci.yml) executa Brakeman, bundler-audit, RuboCop, RSpec e, **somente no push para `main`**, faz build da imagem (Dockerfile de produção), push para **GHCR** (`ghcr.io/<org>/<repo>:sha-<commit>` e `:latest`) e `kubectl apply` nos manifests em `k8s/`.

**Secret do repositório:** `KUBE_CONFIG_DATA` — saída de `kubectl config view --raw | base64 -w0` (Linux) ou `base64` sem `-w0` no macOS.

Antes do primeiro deploy, crie o Secret de runtime no cluster (exemplo):

```bash
kubectl apply -f k8s/namespace.yaml
kubectl -n test-objective create secret generic test-objective-secrets \
  --from-literal=RAILS_MASTER_KEY="$(cat config/master.key)" \
  --from-literal=DATABASE_URL="postgres://user:pass@host:5432/dbname"
```

Se a imagem no GHCR for **privada**, configure `imagePullSecrets` no Deployment com credenciais do registry (ex.: `kubectl create secret docker-registry ...`).

## Licença

Projeto de avaliação técnica.
