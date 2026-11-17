# Navidrome - Virtualmin Web App

[Navidrome](https://www.navidrome.org/) is an open-source, modern music streaming server and Subsonic-compatible API backend written in Go.

## Features

* **Subsonic API**: Fully compatible with popular mobile and desktop Subsonic clients (DSub, Ample, Symfonium, substreamer, play:Sub).
* **Modern Web Player**: Responsive, lightweight web UI based on Material-UI and React.
* **Low Resource Footprint**: Native compiled binary with minimal memory and CPU usage.
* **Multi-Format Streaming**: Transcodes and plays MP3, FLAC, OGG, AAC, ALAC, Opus, and more.
* **Multi-User**: Isolated user accounts, playlists, favorites, and scrobbling support (Last.fm, ListenBrainz).

## Virtualmin Integration Details

* **Runtime Model**: Standalone Go binary managed via dedicated `systemd` unit (`navidrome-<domain>.service`).
* **Proxy Configuration**: Automatically configured Apache / Nginx reverse proxy with WebSocket support on port `4533` (dynamic allocation).
* **Library Directory**: Dedicated user library folder at `~/music`.
* **State Directory**: Configuration and SQLite database stored in `~/navidrome/data`.
