# Pokemon Card Sim (iOS prototype)

Rudimentary **SwiftUI + SwiftData** app that:

- Fetches all Pokémon TCG **sets and cards** from the public [Pokémon TCG API](https://pokemontcg.io) (`api.pokemontcg.io/v2`)
- Simulates **booster pack** opens with rarity-weighted pulls (simplified, not pack-accurate per era)
- Persists a **collection** in **SwiftData** (binder with 3×3 pages, card detail with zoom + **TCGPlayer** link from API metadata)
- **Credits** with mocked daily login, missions, ad reward, and IAP; **optional “premium”** via local flag (no StoreKit/AdMob in v1)

## Requirements

- **macOS** with **Xcode 15+** and iOS 17+ SDK
- iOS **17+** (SwiftData)
- **Network** for the Pokémon TCG API

## Open in Xcode

1. `open PokemonCardSim.xcodeproj`
2. Select a simulator (e.g. iPhone 16) and **Run** (⌘R)

## Optional: API key

The API works without a key with lower rate limits. For higher limits, create a key at [dev.pokemontcg.io](https://dev.pokemontcg.io) and set the environment variable before launching from the terminal, or add the header in code:

- `X-Api-Key: <key>` (see `PokemonTCGAPI.swift`)

## Tests

- **Unit tests** target: `PokemonCardSimTests` (pack randomizer, credits in-memory SwiftData)

## Project layout

- `PokemonCardSim/` — app sources (Models, Services, Views, `Resources/Assets.xcassets`)
- `PokemonCardSimTests/`

## Notes

- **Affiliate / TCGPlayer**: card detail uses `tcgplayer.url` from the API. Wire your [TCGPlayer affiliate / Impact](https://docs.tcgplayer.com/docs/affiliate) parameters when you have an account.
- **Resume piece**: this repo is a learning/portfolio **prototype**—add real **Sign in with Apple**, cloud sync, and **StoreKit 2** when you’re ready.

## License

Prototype code; Pokémon card data and images are provided by the Pokémon TCG API and their respective owners.
