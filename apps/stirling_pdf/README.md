# Stirling-PDF Tools Server for Virtualmin

**Stirling-PDF** is a powerful, locally hosted web application that performs various operations on PDF files (merging, splitting, rotating, converting, adding images, extracting text, OCR, electronic signatures, and password protection) completely client/server-side without transmitting documents to third-party services.

---

## Features

- **Full Document Operations**: Merge multiple PDFs, split by pages, rotate, reorder, compress, and flatten.
- **Conversion Suite**: Convert PDFs to and from images (PNG, JPEG), HTML, Word documents, and Markdown.
- **Optical Character Recognition (OCR)**: Extract text and generate searchable PDFs powered by Tesseract OCR.
- **Security & Permissions**: Add or remove password protection, set document permissions, and sign documents electronically.
- **100% On-Premises Privacy**: All PDF processing runs locally in your server instance.

---

## Virtualmin Integration

- **Script Name**: `stirling_pdf.pl`
- **Category**: Utilities
- **Runtime**: Isolated Container Daemon (`podman` or `docker`)
- **Deployment**: Managed `systemd` service (`stirling-pdf-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx.
- **Storage**: Custom configs and OCR training assets stored in `~/stirling-pdf/`.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **Stirling-PDF** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` to start using the full PDF toolkit immediately.
