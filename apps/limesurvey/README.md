# LimeSurvey Online Survey Platform for Virtualmin

**LimeSurvey** is the world's leading open-source statistical survey and questionnaire web application. It enables companies, educational institutions, researchers, and government agencies to build complex online surveys, collect responses, and analyze results.

---

## Features

- **Advanced Question Types**: Supports 30+ question types including Likert scales, matrix arrays, file uploads, rankings, and masked questions.
- **Conditional Logic & Branching**: Complex skip patterns and expression manager scripting.
- **Quota & Token Management**: Anonymous or invitation-only tracked participant surveys with personalized tokens.
- **Multilingual Support**: Conduct surveys in over 80 languages simultaneously.
- **Comprehensive Reporting**: Real-time charts, statistical summaries, and data export (SPSS, R, CSV, PDF, Excel).

---

## Virtualmin Integration

- **Script Name**: `limesurvey.pl`
- **Category**: Surveys
- **Runtime**: PHP 8.0+
- **Database**: MySQL / MariaDB
- **Document Root**: Direct execution under domain's `public_html` (or `/surveys` subdirectory)

---

## Installation & Configuration

1. In Virtualmin, navigate to **Server Configuration** -> **Manage Web Apps**.
2. Select **LimeSurvey** from the catalog.
3. Choose the target subdirectory (default `/surveys` or root `/`).
4. Virtualmin provisions the MariaDB database and user credentials automatically.
5. Visit the installation wizard at `https://yourdomain.com/surveys/admin` to set up the administrator account and database tables.
