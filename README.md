# tokless-flake

A [Nix Flake](https://nixos.wiki/wiki/Flakes) for the [tokless](https://github.com/HoangP8/tokless) CLI tool.

This repository contains the Nix package to easily and reproducibly install and run `tokless`.

## Usage

To run `tokless` directly using Nix (replace the URL with your own once the repository is online):

```bash
nix run github:YOUR_USERNAME/tokless-flake -- --help
```

To add it to your system, you can include it in your NixOS or Home Manager `inputs`.

## Automatic Updates

This flake includes a daily GitHub Action. It checks if a new version of `tokless` is available upstream and automatically opens a Pull Request to update the package version and hash.
