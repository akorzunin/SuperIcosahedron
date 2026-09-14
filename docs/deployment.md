# Build and deployment

- All branch pushes and pull requests: pre-commit and containerized GUT tests.
- Default-branch pushes: Docker debug exports for Linux, Windows, Web and Android;
  immutable `dev-<run>-<sha>` GitHub prerelease; workstation archive and live update.
- `v*` tags: permanent GitHub releases and workstation archive only. The live site
  continues following the default branch. Android APKs remain debug-signed.
- No automatic retention/deletion yet. Monitor workstation disk usage.

Every qualifying push builds and publishes independently. Live updates use a host
lock and increasing workflow run numbers so a slow older build cannot replace a
newer live build. If a controller is killed mid-deploy, verify no deployment is
running before removing `~/Documents/supericosahedron-dev/.deploy-lock` and rerunning
the workflow. Normal task failures release the lock automatically.

`web/` is only the UI, published to GHCR and deployed by digest. Release assets
include platform ZIPs, metadata, SHA256SUMS, the UI image reference and a deployment
bundle. Deployments download and verify the published assets, rather than rebuild.
Published release assets are not overwritten on retries; failed draft releases can
be recreated. Do not move published version tags.

The workstation service configuration lives at `~/Documents/supericosahedron-dev`,
on port 8282. All game archives live directly in `/mnt/storage/supericosahedron`
on the large storage disk, bind-mounted read-only at `/srv/build`. Deployment and
migration require `/mnt/storage` to be mounted before writing any artifacts.
Caddy serves the archive at `/download/`, the active game via
`/download/web/index.html`, and its metadata via `/download/latest_version.json`.
`/mnt/storage/supericosahedron/.current` selects the active version. Tagged exports remain playable at
`/download/<tag>/web/index.html`. Historical archives remain in their original layout.

## GitHub configuration

The `dev` environment needs `ANSIBLE_PASS` and `ANSIBLE_KNOWN_HOSTS` (the verified
workstation SSH host key), and the repository/environment needs `ANSIBLE_HOSTS`
containing `remote_workstation`. The inventory must be reachable
from hosted runners and contain authentication settings usable with the vault.
Variables: `VITE_HOST_URL`, `VITE_OG_DESCRIPTION`, optional `DISCORD_APP_ID`.
The workflow requires contents/package write permissions. The host must be able to
pull the frontend GHCR package (public package or preconfigured Docker login).

## One-time migration

From the game repository, with access to the adjacent infrastructure checkout:

```sh
ansible-playbook -i ../ansible-playbooks/hosts \
  --vault-password-file ../ansible-playbooks/.ansible_pass deploy/dev/migrate.yaml
```

This discovers the Pi container's archive mount, snapshots/fetches the archive into
ignored `build/migration.tar.gz`, copies it to the workstation and verifies its HTTP
endpoints. It does not stop or delete the Pi service. Do not rerun during active CI
deployment; it is a one-time bootstrap, not an ongoing synchronization job.

After verifying the workstation, from `../ansible-playbooks` run:

```sh
ansible-playbook -i hosts --vault-password-file .ansible_pass \
  playbooks/pi-caddy/switch-supericosahedron.yaml
```

This changes only the game's upstream to `192.168.1.132:8282`, validates Caddy, and
reloads the existing proxy without restarting other sites. The infrastructure
Caddyfile records the same change. TLS/DNS remain on the Pi; only the site and
archive move. Confirm the public UI, archive, iframe and metadata endpoints.

## Rollback

For game rollback, on the workstation in `/mnt/storage/supericosahedron`:

```sh
ln -s <previous-release-directory> .current-next
mv -Tf .current-next .current
```

For UI rollback, set `FRONTEND_IMAGE` in the service `.env` to the prior release's
`frontend-image.txt` value, then `docker compose up -d`. Deployment validates the UI
before switching the game, but does not automatically roll back a failed UI restart.
For migration rollback, rerun the switch playbook with
`--extra-vars supericosahedron_upstream=192.168.1.58:8282` and restore the same upstream
in the infrastructure Caddyfile. The original Pi archive/service remains available.

Legacy local deployment tasks/playbooks have been removed. Host-based development
build tasks remain, but do not publish artifacts.
