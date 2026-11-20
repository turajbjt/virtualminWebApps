# MinIO Object Storage

[MinIO](https://min.io) is a high-performance, Kubernetes-native, S3 compatible object storage suite designed for high-performance cloud storage and data applications.

## Technical Specifications
- **Category**: Cloud
- **Runtime**: Native Go single binary daemon
- **Default Port**: `9000` (S3 API), `9001` (Web Console)
- **Reverse Proxy**: Apache / Nginx reverse proxy with WebSockets
- **State Directory**: `~/minio/data`

## Virtualmin Integration
- Zero-dependency binary running directly as domain user
- Auto-generated root credentials with PRNG
- Systemd daemon management via `minio-<domain>.service`
