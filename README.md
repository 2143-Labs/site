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

1. Push to `main`. The workflow builds, smoke-tests (`title`, CSS, tile and
   favicon must all fetch), then pushes `ghcr.io/2143-labs/site:<run_number>`
   and `:latest`.
2. Bump the pin in `2143-k8s` — `overlays/prod/kustomization.yaml` — to the new
   run number. Flux picks it up within a minute and the pod rolls.

The image is pinned deliberately: nothing deploys just because this repo
changed. `:latest` exists for local use and for an eventual Flux image
automation, which would need `image-reflector-controller` and
`image-automation-controller` added to the cluster.

## Adding pages

The image keeps directories, so anything nested works as a path:

```
store/index.html   ->  labs.2143.me/store/
```

Nothing needs registering — nginx serves the whole tree — and `tile.svg` or any
other asset can be linked from a nested page with an absolute path (`/style.css`).
