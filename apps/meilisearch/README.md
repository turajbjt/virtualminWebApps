# Meilisearch

[Meilisearch](https://www.meilisearch.com) is an open-source, lightning-fast, and hyper-relevant search engine built in Rust. It offers typo tolerance, filters, facet search, and instant search-as-you-type responses in under 50 milliseconds.

## Technical Specifications
- **Category**: Utilities
- **Runtime**: Native Rust standalone binary or container daemon
- **Default Port**: `7700`
- **Reverse Proxy**: Apache / Nginx reverse proxy
- **State Directory**: `~/meilisearch/data`

## Virtualmin Integration
- Standalone zero-dependency binary running directly as domain user
- Auto-generated secure 32-character master API key
- Systemd daemon management via `meilisearch-<domain>.service`
