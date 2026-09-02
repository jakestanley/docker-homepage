# docker-homepage

## Gotchas

### Restarting vs recreating the container

`docker compose restart homepage` does NOT re-read `.env`. New or changed environment variables (including `HOMEPAGE_VAR_*`) require a full container recreate:

```sh
docker compose up -d homepage
```

### Variable substitution in customapi widgets

`{{HOMEPAGE_VAR_*}}` substitution does NOT work inside the `headers` field of a `customapi` widget. Pass credentials as URL query parameters instead:

```yaml
widget:
  type: customapi
  url: "https://example.com/api?token={{HOMEPAGE_VAR_MY_TOKEN}}"
```

### Tailscale widget API key expiry

`HOMEPAGE_VAR_TAILSCALE_KEY` is a Tailscale API access token, which expires after at most 90 days (Tailscale's own hard cap, chosen at creation time — not configurable past that). The widget fails silently, not loudly, once it expires. Regenerate at https://login.tailscale.com/admin/settings/keys and update `.env`, then recreate the `homepage` container (see above — a restart won't pick it up).
