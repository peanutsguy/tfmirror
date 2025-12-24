# TFMirror

TFMirror is a small Docker image that serves a Terraform provider mirror over HTTP (via NGINX).

The container:

- Serves provider artifacts (e.g. `.zip` files) from a local directory you mount into the container
- Ships with an `nginx.conf` baked into the image to expose the mirror on port `80` inside the container

## Quick start

### Run the container

A working command (mounting the current directory as the data volume, and using the repository `providers.json`):

```bash
docker run -p 8080:80 \
  -v $(pwd):/app/data \
  -v $(pwd)/providers.json:/app/providers.json:ro \
  ghcr.io/peanutsguy/tfmirror
```

Then browse:

- `http://localhost:8080/`

## Volumes

- **`/app/data` (required)**

  Directory that contains the mirrored provider artifacts and any files your `nginx.conf` expects to serve.

- **`/app/providers.json` (required)**

  Provider list/config used by the mirroring logic.

  Mounted read-only in the example.

- **`/etc/nginx/nginx.conf` (optional override)**

  NGINX configuration that defines how the mirror is served.

  By default, the image includes a built-in `nginx.conf`.
  You can override it at runtime by mounting a different file to this path.

  Example override:

  ```bash
  docker run -p 8080:80 \
    -v $(pwd):/app/data \
    -v $(pwd)/providers.json:/app/providers.json:ro \
    -v $(pwd)/nginx.conf:/etc/nginx/nginx.conf:ro \
    ghcr.io/peanutsguy/tfmirror
  ```

## Ports

- The container listens on **port `80`**.
- The example maps it to **`8080`** on your host:

  - Host: `8080`
  - Container: `80`

## `providers.json` schema

`providers.json` is a JSON object with these keys:

- **`providers`** (optional)

  Object mapping a local provider name (as used in `required_providers`) to an object with:

  - **`source`** (required)

    Terraform provider source address, e.g. `hashicorp/random`.

  - **`version`** (required)

    Terraform version constraint string passed into `required_providers`, e.g. `"3.7.2"`, `"~> 4.56"`.

- **`platforms`** (optional)

  Array of Terraform platform strings passed to `terraform providers mirror` as `-platform=...`.
  If omitted, the default is:

  - `linux_amd64`

Example:

```json
{
  "providers": {
    "azurerm": {
      "source": "hashicorp/azurerm",
      "version": "4.56"
    },
    "random": {
      "source": "hashicorp/random",
      "version": "3.7.2"
    }
  },
  "platforms": [
    "windows_amd64",
    "linux_amd64"
  ]
}
```

## Typical workflow

- Ensure `providers.json` lists the providers/versions you want mirrored.
- Run the mirroring script/tooling from this repo to populate the data directory with provider artifacts.
- Start the container with your data directory mounted to `/app/data`.
- Point Terraform at your network mirror endpoint.

## Notes

- If you want the mirror to be read-only, keep your mounts as `:ro` where possible.
- If you change `nginx.conf`, restart the container to pick up the changes.

---

This README was written with AI assistance.
