# FlatPress - Virtualmin Web App

[FlatPress](https://www.flatpress.org/) is a lightweight, extensible open-source blogging engine that stores all posts and settings in simple text files—no SQL database engine required.

## Features

* **Zero Database Required**: All content, configurations, and comments are saved in flat files (`fp-content/`).
* **Easy Backups & Mobility**: Simply copy or sync the folder to back up or move your entire blog.
* **Extensible & Themed**: Supports standard plugins (BBCode, Markdown, Akismet, Google Analytics) and Smarty-powered themes.
* **Standards-Compliant**: Generates valid HTML5, RSS 2.0 feeds, Atom feeds, and XML sitemaps out of the box.

## Virtualmin Integration Details

* **Runtime Model**: Standard PHP application in `public_html` (or subfolder like `/blog`).
* **Database Requirement**: None (`script_flatpress_uses` specifies only `php`).
* **Initial Setup**: Directs administrator to the bundled `setup.php` wizard to create admin credentials and set blog name.
