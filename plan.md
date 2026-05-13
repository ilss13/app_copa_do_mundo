# App Copa do Mundo — Plano de Desenvolvimento

## Visão Geral

App mobile em Flutter focado na Copa do Mundo, com dados em tempo real via API Football, monetização por anúncios AdMob e assinatura premium via Google Play Billing.

---

## Arquitetura

### Padrão: Feature-First com Clean Architecture

```
lib/
├── core/
│   ├── api/              # Cliente HTTP, interceptores, tratamento de erros
│   ├── cache/            # Estratégia de cache local (Hive ou SharedPreferences)
│   ├── di/               # Injeção de dependência (get_it + injectable)
│   ├── navigation/       # Roteamento (go_router) e controle de interstitials
│   ├── ads/              # AdMob: banner e interstitial
│   ├── analytics/        # Firebase Analytics
│   └── theme/            # Cores, tipografia, estilos globais
│
├── features/
│   ├── home/             # Jogos do dia
│   ├── matches/          # Listagem de jogos por grupos
│   ├── standings/        # Tabela por grupos
│   ├── match_detail/     # Jogo em tempo real, escalação, stats, H2H
│   ├── subscription/     # Paywall e gerenciamento de assinatura
│   └── splash/           # Tela inicial com inicialização
│
└── shared/
    ├── widgets/          # Componentes reutilizáveis
    ├── models/           # DTOs e entidades
    └── extensions/       # Extensions Dart úteis
```

Cada feature segue: `presentation/` → `domain/` → `data/`

---

## Stack de Tecnologia

| Categoria | Pacote |
|---|---|
| State management | `flutter_bloc` (Cubit) |
| Injeção de dependência | `get_it` + `injectable` |
| HTTP client | `dio` |
| Cache local | `hive_flutter` |
| Roteamento | `go_router` |
| Firebase | `firebase_core`, `firebase_analytics`, `firebase_remote_config`, `cloud_firestore`, `firebase_auth` |
| AdMob | `google_mobile_ads` |
| Assinaturas | `in_app_purchase` |
| Ícones | `flutter_svg`, `font_awesome_flutter` |
| UI extras | `shimmer`, `cached_network_image`, `flutter_animate` |
| Testes | `mocktail`, `bloc_test` |

---

## Telas e Funcionalidades

### 1. Splash / Inicialização
- Inicializa Firebase, Remote Config, AdMob
- Verifica status da assinatura
- Redireciona para Home

### 2. Home — Jogos do Dia
- Lista de jogos do dia com time, placar, horário e status (ao vivo / encerrado / a jogar)
- Indicador visual de jogo ao vivo (pulsante)
- Pull-to-refresh
- Banner AdMob no rodapé
- Cache de 5 minutos; jogos ao vivo atualizam a cada 60s

### 3. Jogos — Listagem por Grupos
- Tabs ou accordion por grupo (A, B, C... H)
- Card de cada confronto: escudo dos times, data, horário, placar
- Filtro por fase (grupos / oitavas / quartas / semi / final)
- Banner AdMob no rodapé
- Cache de 30 minutos

### 4. Tabela — Classificação por Grupos
- Tabs por grupo
- Tabela com: posição, escudo, nome, P, J, V, E, D, GP, GC, SG
- Destaque visual para os 2 classificados
- Banner AdMob no rodapé
- Cache de 30 minutos

### 5. Detalhe do Jogo *(requer assinatura para H2H)*
- **Ao vivo:** placar, tempo, eventos (gols, cartões, substituições) atualizando a cada 30s
- **Escalação:** formação tática com campo visual, titulares e reservas
- **Estatísticas:** posse, chutes, escanteios, faltas, etc. com barras comparativas
- **H2H (Confrontos anteriores):** últimos 5 jogos entre os times *(bloqueado para não assinantes)*
- Banner AdMob no rodapé (ocultado para assinantes)

### 6. Assinatura Premium
- Paywall com benefícios listados:
  - Remove todos os anúncios
  - Acesso ao histórico de confrontos (H2H)
- Opções: mensal / anual (com desconto)
- Integração com Google Play Billing via `in_app_purchase`
- Verificação do recibo no Firebase Functions (ou Firestore para versão simplificada)
- Restaurar compra

---

## Firebase — Configuração

| Serviço | Uso |
|---|---|
| **Remote Config** | Quantidade de trocas de página antes do interstitial (padrão: 5), IDs dos anúncios, flags de feature |
| **Analytics** | Rastrear navegação, conversões de assinatura, visualizações de jogos |
| **Firestore** | (Opcional) Armazenar status de assinatura do usuário, sincronizado com backend |
| **Auth** | Login anônimo para persistir assinatura entre dispositivos (Google Sign-In opcional) |
| **Firebase Functions** | (Opcional) Verificação de recibo de assinatura |

---

## Anúncios — AdMob

### Banner
- Exibido em todas as telas para usuários não assinantes
- Widget `BannerAdWidget` reutilizável no rodapé de cada `Scaffold`
- Ocultado automaticamente quando `SubscriptionCubit.isPremium == true`

### Interstitial
- Controlado por `InterstitialAdController` no núcleo de navegação
- Contador de trocas de página incrementado no `GoRouter`'s `redirect` ou listener
- Threshold lido do Remote Config (chave: `interstitial_page_threshold`, padrão: `5`)
- Não exibido para assinantes premium

---

## Cache

| Recurso | TTL | Estratégia |
|---|---|---|
| Jogos do dia | 5 min | Hive, invalida em pull-to-refresh |
| Jogos ao vivo | 60s | Polling periódico, sem cache |
| Listagem de jogos | 30 min | Hive |
| Tabela de grupos | 30 min | Hive |
| Escalações | 1h | Hive |
| Estatísticas | 60s (ao vivo) / 1h (encerrado) | Hive condicional |
| H2H | 24h | Hive |

---

## API Football — Endpoints Utilizados

| Endpoint | Tela |
|---|---|
| `GET /fixtures?date={today}` | Home — jogos do dia |
| `GET /fixtures?season={year}&league={wc_id}` | Jogos por grupos |
| `GET /standings?season={year}&league={wc_id}` | Tabela |
| `GET /fixtures/{id}` | Detalhe — placar ao vivo |
| `GET /fixtures/{id}/lineups` | Detalhe — escalação |
| `GET /fixtures/{id}/statistics` | Detalhe — estatísticas |
| `GET /fixtures/headtohead?h2h={t1}-{t2}` | Detalhe — H2H (premium) |

---

## Design System

### Paleta de Cores
```
Primary:      #1A237E  (azul FIFA profundo)
Secondary:    #D4AF37  (dourado troféu)
Background:   #0D0D1A  (fundo escuro impactante)
Surface:      #1C1C2E  (cards)
Live Red:     #E53935  (indicador ao vivo)
Success:      #43A047  (vitória / classificado)
Text Primary: #FFFFFF
Text Secondary: #9E9E9E
```

### Componentes Visuais
- Cards com sombra suave e borda sutil dourada para jogos ao vivo
- Shimmer loading em todos os estados de carregamento
- Animações suaves com `flutter_animate` nas transições
- Escudos das seleções via `cached_network_image` com placeholder SVG
- Campo tático renderizado com `CustomPainter`

---

## Fases de Desenvolvimento

### Fase 1 — Fundação (Semana 1)
- [ ] Setup do projeto Flutter + estrutura de pastas
- [ ] Configuração do Firebase (Android/iOS)
- [ ] Cliente HTTP com Dio + tratamento de erros + interceptor de cache
- [ ] Design system: tema, cores, tipografia, componentes base
- [ ] Navegação com go_router
- [ ] Injeção de dependência com get_it

### Fase 2 — Telas Principais (Semana 2)
- [ ] Tela Home — jogos do dia
- [ ] Tela Jogos — listagem por grupos
- [ ] Tela Tabela — classificação por grupos
- [ ] Loading states com Shimmer em todas as telas
- [ ] Cache com Hive

### Fase 3 — Detalhe do Jogo (Semana 3)
- [ ] Placar ao vivo com polling
- [ ] Escalação com campo visual
- [ ] Estatísticas comparativas
- [ ] H2H (bloqueado para não assinantes)

### Fase 4 — Monetização (Semana 4)
- [ ] Integração AdMob (banner + interstitial)
- [ ] Remote Config para threshold de interstitial
- [ ] Google Play Billing + paywall
- [ ] Lógica de assinatura (ocultar ads, liberar H2H)

### Fase 5 — Polimento e Lançamento (Semana 5)
- [ ] Testes de unidade e widget
- [ ] Firebase Analytics nos eventos principais
- [ ] Otimização de performance (lazy loading, image caching)
- [ ] Testes em dispositivos reais
- [ ] Build de produção e publicação na Play Store

---

## Fluxo de Assinatura

```
Usuário toca em H2H
      ↓
SubscriptionCubit verifica isPremium
      ↓ (não assinante)
Exibe Paywall
      ↓
Usuário seleciona plano
      ↓
in_app_purchase processa compra
      ↓
Firestore/Auth atualiza status
      ↓
SubscriptionCubit emite isPremium = true
      ↓
H2H desbloqueado, ads removidos
```

---

## Considerações de Qualidade

- Nenhuma chamada de API sem indicador de loading
- Tratamento de erro com mensagens amigáveis e opção de retry
- Suporte a modo offline com dados em cache
- Responsivo para diferentes tamanhos de tela (tablet incluído)
- Acessibilidade: semantics nos widgets principais
- Testes unitários para Cubits e repositórios
