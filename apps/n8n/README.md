# n8n Workflow Automation Platform for Virtualmin

**n8n** is a fair-code, self-hosted workflow automation and integration platform (Zapier alternative). It allows teams to build complex multi-step automations connecting webhooks, APIs, databases, and LLM AI agents using a visual node editor.

---

## Features

- **Visual Workflow Builder**: Drag-and-drop canvas connecting 400+ built-in app integrations, databases, and custom HTTP webhooks.
- **Custom Functions & Logic**: Native JavaScript and Python code nodes for transformations and custom algorithms.
- **AI Agent Integration**: Built-in LangChain nodes to orchestrate AI agents, memory stores, and vector databases.
- **Execution History & Debugging**: Step-by-step visual inspection of node input and output payloads.

---

## Virtualmin Integration

- **Script Name**: `n8n.pl`
- **Category**: Development
- **Runtime**: Isolated Container Daemon (`podman` or `docker`)
- **Database**: Embedded SQLite
- **Deployment**: Managed `systemd` service (`n8n-<domain>.service`) listening on a dynamic local TCP port, reverse-proxied by Apache/Nginx with WebSocket forwarding enabled.

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **n8n** from the catalog.
3. Configure the local reverse-proxy port (auto-allocated by default).
4. Access `https://yourdomain.com/` to set up your owner account and start building workflows.
