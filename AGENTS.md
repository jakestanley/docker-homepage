# docker-homepage

## Gotchas

### Restarting vs recreating the container

`docker compose restart homepage` does NOT re-read `.env`. New or changed environment variables (including `HOMEPAGE_VAR_*`) require a full container recreate:

```sh
docker compose up -d homepage
```

### Credentialed customapi widgets: use username/password, not query params

Prefer `username`/`password` over embedding a credential in the URL — Homepage
builds a real `Authorization: Basic` header server-side from these two
fields, so the credential never appears in the request line that nginx (or
any upstream) access-logs:

```yaml
widget:
  type: customapi
  url: "https://example.com/api"
  username: someuser
  password: "{{HOMEPAGE_VAR_MY_TOKEN}}"
```

`{{HOMEPAGE_VAR_*}}` substitution is a blind find-replace over the whole raw
YAML file before parsing (confirmed in Homepage's own source,
`utils/config/config.js`'s `substituteEnvironmentVars`), so it isn't
field-specific — it works in `username`/`password` exactly like it does in
`url` (confirmed live: `homelab-infra`'s Apollo widget, 2026-10-02). An
earlier version of this note claimed substitution doesn't work in `headers`
specifically and recommended query params instead — that was never retested
against `username`/`password`, and in hindsight was more likely a YAML
quoting mistake (`{{...}}` unquoted is flow-mapping syntax to a YAML parser)
than a real substitution gap. If you do need raw `headers:`, quote the
value and verify with `curl -H "Host: <allowed host>"
"http://127.0.0.1:<port>/api/services/proxy?group=<group>&service=<service>&index=<n>"`
rather than assuming — this is the actual server-side proxy route Homepage
uses for `customapi` widgets (not `/api/widgets/customapi`, which doesn't
exist as a route; that path is reserved for a fixed set of built-in widget
types like `glances`/`weather`/etc.).

### Tailscale widget API key expiry

`HOMEPAGE_VAR_TAILSCALE_KEY` is a Tailscale API access token, which expires after at most 90 days (Tailscale's own hard cap, chosen at creation time — not configurable past that). The widget fails silently, not loudly, once it expires. Regenerate at https://login.tailscale.com/admin/settings/keys and update `.env`, then recreate the `homepage` container (see above — a restart won't pick it up).
