create extension if not exists pgcrypto;

create table public.marketplace_product_observations (
  id uuid primary key default gen_random_uuid(),
  source text not null check (source in ('musinsa', 'naver', 'coupang')),
  source_product_id text,
  product_name text not null check (btrim(product_name) <> ''),
  brand text,
  price_krw integer check (price_krw is null or price_krw >= 0),
  rating numeric(3, 2) check (rating is null or rating between 0 and 5),
  review_count integer check (review_count is null or review_count >= 0),
  purchase_count integer check (purchase_count is null or purchase_count >= 0),
  product_attributes jsonb,
  product_url text,
  keyword text not null check (btrim(keyword) <> ''),
  rank integer check (rank is null or rank >= 1),
  is_ad boolean,
  discount_rate numeric(5, 2) check (discount_rate is null or discount_rate between 0 and 100),
  collected_at timestamptz not null default now(),
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

alter table public.marketplace_product_observations enable row level security;

create index marketplace_product_observations_source_collected_at_idx
  on public.marketplace_product_observations (source, collected_at desc);

create index marketplace_product_observations_keyword_collected_at_idx
  on public.marketplace_product_observations (keyword, collected_at desc);

comment on table public.marketplace_product_observations is
  'Append-only observations of public marketplace product listing results.';
