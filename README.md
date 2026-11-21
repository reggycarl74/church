# Altona Church Finance (Ruby on Rails)

A small Rails 8 app that replaces the four paper tithes & offerings sheets and the monthly cash record.

## What it does

**Tithes & offerings sheet (one page)**
- All names on one page, grouped in sections: *Church Leaders*, *Members — Part One / Two / Three*. Sections can be renamed, added, reordered or deleted, with no limit of 25 names.
- One column per Sunday of the month. Each section has a **weekly total** row, and the **month total** is in the far-right column. A grand total covers all sections.
- One tab per offering type (Tithe, Offering, plus any you add) and an **All types** summary tab.
- Amounts save automatically as you type (`20`, `12,50`, `1.234,56`). Pressing Enter moves to the next name.
- Print (A4 landscape) and Export CSV (Excel, German decimal comma).

**Cash record (monthly, filled weekly)**
- **Receipts per week**: tithe and offering totals come straight from the sheet. You can add other income such as loose plate offerings or donations, and it can be counted as a tithe/offering type or as "other income".
- **Payments per week** by category (rent, transport, welfare, …), each with a date, description and receipt number.
- **Cash brought forward**: the previous month's closing balance, carried automatically. Enter it by hand only for the first month.
- **LDF**: 10% of the tithes and offerings received. The percentage, and which offering types count, are configurable. You choose in Settings whether LDF is deducted from the cash balance.
- **Closing balance** = cash brought forward + receipts − payments (− LDF if deducted). This becomes next month's cash brought forward.
- **Petty cash** (physical cash not in the bank) and **bank balance**: enter the counted figures and the app shows whether they add up to the closing balance (✓ balanced, or the difference).

**Other features**
- Logins for treasurers and financial secretaries.
- Admins can manage users and settings.
- Admins can download a full database backup.

## Run it on your computer

Requires Ruby 3.2+ (3.3 recommended).

```bash
cd altona_finance
bundle install
ADMIN_EMAIL=you@example.com ADMIN_PASSWORD='choose-a-password' bin/setup
bin/rails server
```

Open http://localhost:3000 and log in. Then:
1. Under **Names & sections**, paste your names into each section.
2. Under **Offering types**, add the types you use and tick "counts for LDF" on the ones that make up tithes and offerings.
3. Under **Cash record**, enter the first month's cash brought forward, the bank balance and the petty cash.

Run the tests with `bin/rails test`.

## Hosting (with Cloudflare)

Cloudflare Workers and Pages cannot run Ruby, so run the app on a Rails-friendly host and put Cloudflare in front for your domain, HTTPS and access control. The app stores everything in one SQLite file, so the host **must have a persistent disk or volume** mounted at `/rails/storage`.

| Option | Cost (approx.) | Notes |
| --- | --- | --- |
| **Fly.io** | a few € / month | `fly launch` detects the Dockerfile; create a volume and mount it at `/rails/storage`. |
| **Render** | paid instance + disk | "New Web Service → Docker", add a Disk mounted at `/rails/storage`. |
| **Hetzner VPS + Kamal** | ~€4–5 / month | Most control; Kamal ships with Rails. |
| Cloudflare Containers | Workers paid plan | Possible, but its disk is not permanent, so it would need an external database. Not recommended for this app. |

Environment variables to set on the host:

```
SECRET_KEY_BASE=<run: bin/rails secret>
ADMIN_EMAIL=treasurer@example.org      # first admin login (created once)
ADMIN_PASSWORD=<strong password>
APP_HOST=finance.your-church.org        # optional: only allow this host name
DATABASE_PATH=/rails/storage/production.sqlite3   # default
```

Build and run with Docker anywhere:

```bash
docker build -t altona-finance .
docker run -p 3000:3000 -v altona_data:/rails/storage \
  -e SECRET_KEY_BASE=... -e ADMIN_EMAIL=... -e ADMIN_PASSWORD=... altona-finance
```

### Cloudflare in front
1. Add your domain to Cloudflare.
2. Create a DNS record, e.g. `finance` CNAME pointing to your Fly/Render host name, with the proxy (orange cloud) on.
3. Set SSL/TLS mode to **Full (strict)**.
4. Recommended: **Zero Trust → Access → Applications**, add `finance.your-church.org` and allow only the treasurers' email addresses. This adds a second lock on top of the app's own login.

## Backups
**Settings → Download database backup** (admins) gives a complete copy. Download one at the end of every month and keep it somewhere safe.

## Project layout
- `app/models/money.rb` — amount parsing and formatting (stored as whole cents, no rounding errors)
- `app/models/tithes_sheet.rb` — totals for the one-page sheet
- `app/models/cash_record.rb` — weekly receipts and payments, LDF, brought forward, closing balance, reconciliation
- `app/assets/javascripts/application.js` — autosave and live totals on the sheet
