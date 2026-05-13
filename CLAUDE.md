# CLAUDE.md — App Copa do Mundo

## Visão do Projeto

App Flutter de Copa do Mundo com dados em tempo real via API Football, monetização por AdMob e assinatura premium Google Play. Design escuro e impactante, focado no conteúdo esportivo.

---

## Tecnologia Principal

- **Flutter** (Dart) — versão estável mais recente
- **State Management:** `flutter_bloc` com Cubit
- **DI:** `get_it` + `injectable`
- **HTTP:** `dio` com interceptores de cache e erro
- **Cache:** `hive_flutter`
- **Roteamento:** `go_router`
- **Firebase:** Core, Analytics, Remote Config, Firestore, Auth
- **Ads:** `google_mobile_ads`
- **Assinatura:** `in_app_purchase`

---

## Estrutura de Pastas

```
lib/
├── core/           # Infraestrutura transversal (api, cache, di, ads, theme, navigation)
├── features/       # Uma pasta por feature (home, matches, standings, match_detail, subscription, splash)
│   └── <feature>/
│       ├── presentation/   # Screens, Cubits, Widgets específicos
│       ├── domain/         # Entidades, UseCases, interfaces de Repository
│       └── data/           # Repository impl, DTOs, DataSources
└── shared/         # Widgets reutilizáveis, models comuns, extensions
```

---

## Regras de Código

### Geral
- Seguir Clean Architecture: dados fluem `data → domain → presentation`
- Cubits gerenciam estado; nunca chame API diretamente de widgets
- Todo repositório tem interface em `domain/` e implementação em `data/`
- Usar `injectable` + `get_it` para injeção — nunca instanciar serviços manualmente em widgets

### API e Cache
- Toda chamada de API deve passar pelo `ApiClient` em `core/api/`
- Toda tela com dado remoto exibe `ShimmerLoading` enquanto carrega
- TTLs de cache definidos em `CacheConfig` (constantes centralizadas)
- Jogos ao vivo: polling a cada 60s (fixtures) / 30s (placar em detalhe); sem cache
- Nunca fazer chamada de API sem loading state no Cubit

### Anúncios
- `BannerAdWidget` é um widget reutilizável colocado no rodapé de cada `Scaffold`
- Verificar `SubscriptionCubit.isPremium` antes de renderizar qualquer anúncio
- Threshold de interstitial lido do Remote Config (chave: `interstitial_page_threshold`)
- `InterstitialAdController` vive em `core/ads/` e é incrementado pelo listener do `GoRouter`

### Assinatura
- Status de assinatura centralizado em `SubscriptionCubit` (injetado globalmente)
- H2H só renderiza se `isPremium == true`; caso contrário, exibir `PaywallWidget` inline
- Lógica de compra em `SubscriptionRepository`; não colocar lógica de billing em widgets

### Design
- Usar apenas cores do `AppColors` (definido em `core/theme/`)
- Shimmer em tons de `Surface` do tema
- Animações via `flutter_animate`: entrada de cards com `fadeIn` + `slideY`
- Escudos sempre via `CachedNetworkImage` com placeholder SVG
- Nunca hardcode de cor fora do tema

---

## Comandos Úteis

```bash
# Gerar código (injeção de dependência, mocks)
flutter pub run build_runner build --delete-conflicting-outputs

# Rodar testes
flutter test

# Analisar código
flutter analyze

# Build Android release
flutter build appbundle --release
```

---

## API Football

- **Base URL:** `https://v3.football.api-sports.io`
- **Auth Header:** `x-apisports-key: {API_KEY}`
- Chave da API armazenada via `--dart-define=API_FOOTBALL_KEY=xxx` ou `firebase remote config`
- Liga Copa do Mundo: `league=1` (verificar ID atual na documentação)
- Nunca expor a chave no código-fonte

---

## Firebase

| Serviço | Uso |
|---|---|
| Remote Config | `interstitial_page_threshold` (int, padrão 5), IDs de ad units, feature flags |
| Analytics | Eventos: `match_viewed`, `subscription_started`, `subscription_converted`, `h2h_blocked` |
| Auth | Login anônimo para persistência de assinatura; Google Sign-In opcional |
| Firestore | Coleção `users/{uid}/subscription` com status e validade |

---

## AdMob

- IDs de ad units lidos do Remote Config (não hardcoded em produção)
- IDs de teste hardcoded apenas em `debug` mode via `kDebugMode`
- Banner: `AdSize.banner`, posição `Alignment.bottomCenter`
- Interstitial: pré-carregado na inicialização e recarregado após exibição

---

## Convenções de Nomenclatura

| Artefato | Convenção |
|---|---|
| Cubit | `MatchesCubit`, `HomeCubit` |
| Estado | `MatchesState` com subclasses `Initial`, `Loading`, `Loaded`, `Error` |
| Repository interface | `MatchesRepository` |
| Repository impl | `MatchesRepositoryImpl` |
| DTO | `FixtureDto` (mapeia JSON da API) |
| Entidade | `Match` (modelo de domínio limpo) |
| Screen | `HomeScreen`, `MatchDetailScreen` |
| Widget reutilizável | `MatchCard`, `GroupTab`, `BannerAdWidget` |

---

## Fluxo de Dados (Exemplo)

```
HomeScreen
  → HomeCubit.loadTodayMatches()
    → GetTodayMatchesUseCase.execute()
      → MatchesRepository.getTodayMatches()
        → CacheManager: hit? → retorna cache
        → miss? → ApiClient.get('/fixtures?date=today')
          → parse FixtureDto → converte para Match
          → salva no cache com TTL 5min
      → emite MatchesLoaded([Match, ...])
  → BlocBuilder rebuilda lista
```

---

## Checklist Antes de Cada PR

- [ ] Nenhuma lógica de negócio em widgets
- [ ] Nenhuma chamada de API sem loading state
- [ ] Nenhuma cor hardcoded fora do tema
- [ ] Ads ocultos quando `isPremium == true`
- [ ] H2H bloqueado para não assinantes
- [ ] `flutter analyze` sem warnings
- [ ] Testes unitários para o Cubit da feature
