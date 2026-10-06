# md CLI

Releases of `md`, the command-line tool for publishing markdown files to an
md server. This repository only hosts the release binaries; they're built
and published automatically from the (private) source repository.

## Install

macOS and Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/jamosaur/md-cli/main/install.sh | sh
```

This installs to `~/.local/bin` (set `MD_INSTALL_DIR` to change it, or
`MD_VERSION=0.1.0` for a specific version) and verifies the download against
the release's `checksums.txt`.

Windows, or manually: download the archive for your platform from the
[latest release](https://github.com/jamosaur/md-cli/releases/latest), check it
against `checksums.txt`, and put `md` / `md.exe` on your `PATH`.

## Use

Create an API token in your md server under **Settings → API tokens**, then:

```sh
md login --url https://md.example.com --token md_...
md publish notes.md --theme essay     # prints the share URL
md publish notes.md                   # republishing updates the same page
md list
md unpublish notes.md
md open notes.md
```

## Updates

```sh
md update           # install the latest release
md update --check   # just check
```

`md` also checks for a new release once a day and prints a one-line notice.
Turn that off with `md config update-check off` or `MD_NO_UPDATE_CHECK=1`.
