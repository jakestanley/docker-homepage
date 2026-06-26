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
