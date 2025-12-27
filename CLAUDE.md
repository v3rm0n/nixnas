# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NixOS-based NAS installation project for the **UGreen DXP 2800** two-bay NAS enclosure. 

This repository contains:
1. **ISO Builder** (`iso/` directory): A Nix flake configuration for building a minimal NixOS installation ISO image
2. **NAS Configuration** (root directory): A NixOS flake-based configuration for the final NAS system

## Deployment Workflow

1. Build the installation ISO from the `iso/` directory
2. Boot the UGreen DXP 2800 NAS from the ISO image
3. Use `nixos-anywhere` to apply the NixOS flake configuration from the project root directory to the NAS
4. All build steps are orchestrated through the Makefile using the `nix` tool

## Architecture

### ISO Builder (`iso/flake.nix`)

The ISO builder flake:
- Targets NixOS 25.11 stable release
- Builds an x86_64-linux ISO image
- Extends the minimal installation CD configuration from NixOS
- Includes essential tools: neovim, git, rsync, wget, curl
- Default package output: `self.nixosConfigurations.nasIso.config.system.build.isoImage`

### NAS Configuration (Root Directory)

The main NAS configuration is a flake-based NixOS configuration in the project root, applied to the UGreen DXP 2800 via `nixos-anywhere` after booting from the installation ISO.

## Build Commands

All build steps are available via the Makefile in the project root. Use `make` commands for building both the ISO and deploying the NAS configuration.

### Manual ISO Build Commands

Build the NixOS installer ISO:
```bash
cd iso
nix build
```

The resulting ISO will be in `./result/iso/`.

Build and show the output path:
```bash
cd iso
nix build --print-out-paths
```

Update flake inputs:
```bash
cd iso
nix flake update
```

Check flake configuration:
```bash
cd iso
nix flake check
```

Show flake outputs:
```bash
cd iso
nix flake show
```

## Development Notes

- The project is split into two parts:
  - `iso/` directory: ISO builder configuration (intentionally minimal)
  - Root directory: Main NAS flake configuration for the UGreen DXP 2800
- The ISO flake uses the standard NixOS installer CD modules as a base
- The ISO configuration is intentionally minimal - modifications should maintain this simplicity
- When modifying flake files, ensure the flake lock file is updated if dependencies change
- Target hardware: UGreen DXP 2800 two-bay NAS enclosure (x86_64-linux)
- Deployment uses `nixos-anywhere` to remotely apply the configuration
