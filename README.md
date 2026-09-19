# Dotfiles

This repository serves as a source of truth for installing software across my machines and making distro hopping as seamless as possible.

As a software engineer, gamer, and occasional content creator, these scripts allow me to quickly bootstrap my development environment, gaming setup, and media creation tools.

> [!NOTE]
> **Windows is explicitly not supported.** I encountered too many issues and do not wish to support it.

---

## Supported Environments & Bootstrap Profiles

The repository provides automated bootstrap entrypoints tailored for specific operating systems and machine profiles:

| Script | Platform | Profile | Description |
|---|---|---|---|
| `macbook.sh` | macOS | Workstation | Installs Homebrew, command-line utilities, GUI apps (casks), and global NPM packages. |
| `cachy-workstation.sh` | Arch Linux / CachyOS | Workstation | Updates the system and installs development tools, terminal utilities, desktop apps via Pacman, AUR packages via Yay, and global NPM packages. |
| `cachy-gaming.sh` | Arch Linux / CachyOS | Gaming & Media | Installs gaming platforms (Steam, Lutris, Heroic), emulators (Dolphin, RetroArch), streaming tools (Sunshine, OBS Studio), controller utilities (xone), and dev tools. |
| `fedora-workstation.sh` | Fedora Linux | Workstation | Updates the system and installs RPM packages via DNF, desktop applications from Flathub via Flatpak, standalone tools via curl, and global NPM packages. |

> [!WARNING]
> Both `cachy-workstation.sh` and `cachy-gaming.sh` will automatically reboot the machine upon successful completion.

---

## Repository Architecture

To avoid monolithic, inflexible setups, software installations are split into individual, modular scripts categorized by package manager:

```text
.
├── brew/                  # macOS Homebrew formulas and casks
├── containers/            # Container engine configs (OpenShift SCC compliance)
├── curl/                  # Standalone binary installer scripts (hk, zed)
├── dnf/                   # Fedora native RPM packages and repository setups
├── flatpak/               # Flathub sandboxed desktop applications
├── npm/                   # Global Node.js utilities and CLIs
├── pacman/                # Arch Linux official repository packages
├── yay/                   # Arch User Repository (AUR) helper scripts
├── cachy-gaming.sh        # Arch / CachyOS gaming bootstrap entrypoint
├── cachy-workstation.sh   # Arch / CachyOS workstation bootstrap entrypoint
├── fedora-workstation.sh  # Fedora workstation bootstrap entrypoint
├── macbook.sh             # macOS bootstrap entrypoint
├── mise.toml              # Tool version configuration and task runner
└── hk.pkl                 # Pre-commit hooks and repo lint configuration
```

### Running Standalone Installers

Any tool can be installed or re-installed independently without running an entire bootstrap script:

```sh
# Install Zed editor on macOS
sh brew/zed.sh

# Install Neovim on Arch/CachyOS
sh pacman/neovim.sh

# Install Obsidian via Flatpak on Fedora
sh flatpak/obsidian.sh
```

---

## Development & Local Tooling

This repository uses [mise](https://mise.jdx.dev/) for managing tool runtimes and [hk](https://github.com/jdx/hk) for pre-commit hooks and local quality checks.

### Managed Tools

Tool versions are pinned in [`mise.toml`](file:///Users/josephking/Code/projects/dotfiles/mise.toml):

- **actionlint**: GitHub Actions workflow linter
- **betterleaks**: Secrets detection
- **hk**: Fast Git hooks manager and runner
- **pkl**: Apple's Pkl configuration language evaluator
- **shellcheck**: Shell script static analysis
- **tombi**: TOML linter and formatter
- **zizmor**: Security audit for GitHub Actions

### Setup & Common Tasks

1. **Install hooks and dependencies**:
   ```sh
   mise run install
   ```
   *Runs `hk install --mise` to register pre-commit and commit-msg hooks.*

2. **Run repository checks**:
   ```sh
   mise run hk
   ```
   *Executes all linters, formatters, leak scans, and hook validations across all files in the repository.*

---

## Continuous Integration & Security

Automated workflows in `.github/workflows/` validate every change using reusable workflows from [`joeckr/ci-templates`](https://github.com/joeckr/ci-templates):

- **Lint Scan** (`lint.yml`): Runs `actionlint`, `commitlint` (enforcing [Conventional Commits](https://www.conventionalcommits.org/)), and `shellcheck`.
- **Security Audit** (`security.yml`): Runs `betterleaks` for secret detection and `zizmor` for GitHub Actions workflow auditing.
- **Automated Releases** (`release.yml`): Publishes semantic releases and updates changelogs upon merging to `main`.

## Support

If you find this project useful, consider supporting my work on [Ko-fi](https://ko-fi.com/joeckr):

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/joeckr)

## License

Please refer to the `LICENSE` file for details.
