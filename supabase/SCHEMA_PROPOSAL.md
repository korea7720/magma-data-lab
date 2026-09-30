# Marketplace Product Collection Schema Proposal

Status: proposed only. This document does not create or alter any database object.

## Recommended first table: `marketplace_product_observations`

One append-only observation table is the right starting point for the three marketplaces. The first collection exercise needs comparisons across sources, but the sources do not expose the same fields. A single table keeps every collection event intact while allowing missing source-specific values to remain `NULL` instead of forcing invented defaults.

| Column | Type | Why it exists |
| --- | --- | --- |
| `id` | `uuid` primary key | Stable identifier for this collected observation. |
| `source` | `text` | Identifies `musinsa`, `naver`, or `coupang` for source-level analysis. |
| `source_product_id` | `text`, nullable | Stores a marketplace-native product identifier when the page exposes one. |
| `product_name` | `text` | The product title as observed on the public result page. |
| `brand` | `text`, nullable | Preserves a brand when the source exposes it. |
| `price_krw` | `integer`, nullable | Allows price comparison without turning a missing price into zero. |
| `rating` | `numeric`, nullable | Supports sources that expose a rating; Coupang may leave this empty. |
| `review_count` | `integer`, nullable | Preserves the displayed review count when available. |
| `purchase_count` | `integer`, nullable | Preserves Naver's displayed purchase count when available. |
| `product_attributes` | `jsonb`, nullable | Retains source-specific public attributes without repeatedly changing the schema. |
| `product_url` | `text`, nullable | Links the observation to its original public product page. |
| `keyword` | `text` | Keeps the search keyword used to collect this result. |
| `rank` | `integer`, nullable | Keeps the displayed search-result rank. |
| `is_ad` | `boolean`, nullable | Separates advertising placements from ordinary results when the source labels them. |
| `discount_rate` | `numeric`, nullable | Retains a displayed discount without deriving it from incomplete prices. |
| `collected_at` | `timestamptz` | Records when this exact observation was made. |
| `raw_payload` | `jsonb`, nullable | Preserves the non-personal, public fields received from the collector for auditability. |
| `created_at` | `timestamptz` | Records when the database row was inserted. |

## Guardrails for the eventual migration

- Use an append-only model. Do not add a unique constraint that overwrites an earlier observation of the same product.
- Add checks for the three approved sources and non-negative numeric counts.
- Index `(source, collected_at desc)` and `(keyword, collected_at desc)` for the expected comparisons.
- Enable Row Level Security and do not add permissive public policies.
- Store only public product-listing facts. Do not collect review text, account data, or other personal information.

## Alternative considered

Three source-specific tables would make each ingest shape slightly simpler, but would complicate cross-market comparison and create a fourth union view before the first report. Start with the single table above; split a source into its own normalized tables only when stable source-specific structures require it.

## Approval gate

After the owner approves this proposal, create a timestamped migration under `supabase/migrations/`. Review its SQL before using any command that applies it to the remote Supabase project.
