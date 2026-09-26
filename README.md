# site

The static site for 2143 Labs, served at **labs.2143.me** — and eventually the
front door for 2143.me.

Content sits at the repo root and is baked into an image
(`ghcr.io/2143-labs/site`) built by [`.github/workflows/build.yml`](.github/workflows/build.yml).
The Kubernetes manifests live in [2143-k8s](https://github.com/2143-Labs/2143-k8s),
not here.

```
index.html     the page
style.css      all of the styling
tile.svg       seamless background tile (168x168)
favicon.svg    tab icon
Dockerfile     nginx-unprivileged + COPY . /usr/share/nginx/html
```

No JavaScript, no external requests, no fonts to download.

## The layout

One idea: a reading column that **is** the page on mobile and keeps its size on
desktop.

| | Mobile (< 42rem) | Desktop (>= 42rem) |
|---|---|---|
| Column | full bleed, `100dvh`, 2px brand-gradient edge at the top | `27rem` wide, `min(100svh - 5rem, 40rem)` tall, bordered and rounded, centred |
| Behind it | nothing — the column is the page | the tiled background plus two brand glows |
| Contact | follows the content | anchored to the bottom of the frame |

To change how much room the column gets, edit the `@media (min-width: 42rem)`
block in `style.css`. To change the tile's density, edit `background-size`;
the tile is drawn so its edges complete across neighbours.

## Running it locally

```bash
docker build -t site .
docker run --rm -p 8080:8080 site        # http://localhost:8080
```

Or skip the container entirely — the files are just files:

```bash
python3 -m http.server 8080
```

## How it deploys

Push to `main` to build and smoke-test the site before publishing
`ghcr.io/2143-labs/site:<run_number>` and `:latest`. After a successful push
build, the promotion job uses an SSH deploy key to update only the production
site `newTag` in `2143-k8s/overlays/prod/kustomization.yaml`; Flux reconciles
the commit within a minute. Older runs cannot move the pin backward. A rerun
may reuse its run-number tag only when the rebuilt image is identical; changed
content requires a new commit and run number. A failed build or promotion
leaves the current pin unchanged. A manual `workflow_dispatch` builds and
publishes the image but does not promote it.

Promotion requires `DEPLOY_KEY_2143_K8S` as a `site` Actions secret: its private
half must match a public deploy key registered with write access on `2143-k8s`.
No key material belongs in either repository. Without that secret, promotion
fails rather than silently skipping the deployment.

The production image is pinned deliberately; publishing `:latest` alone never
deploys it. Flux image automation controllers (`image-reflector-controller` and
`image-automation-controller`) are not installed.

## Adding pages

The image keeps directories, so anything nested works as a path:

```
store/index.html   ->  labs.2143.me/store/
```

Nothing needs registering — nginx serves the whole tree — and `tile.svg` or any
other asset can be linked from a nested page with an absolute path (`/style.css`).
