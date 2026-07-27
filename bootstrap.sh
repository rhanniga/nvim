#!/usr/bin/env bash
set -euo pipefail

# Bootstrap external dependencies for the Neovim config.
# Safe to re-run — only installs what's missing.
#   Handles: git, C compiler, ripgrep, fd, node, go, rustup,
#            tree-sitter CLI, leptosfmt.
# After this finishes, launch nvim; Mason installs LSP servers on first run.

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
have() { command -v "$1" >/dev/null 2>&1; }

OS="$(uname -s)"

install_mac() {
	if ! have brew; then
		info "Installing Homebrew"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	# C compiler + build tools (needed to compile treesitter parsers)
	if ! xcode-select -p >/dev/null 2>&1; then
		info "Installing Xcode command line tools"
		xcode-select --install || true
	fi

	for pkg in git ripgrep fd node go; do
		if ! brew list "$pkg" >/dev/null 2>&1; then
			info "brew install $pkg"
			brew install "$pkg"
		fi
	done
}

install_linux() {
	if have apt-get; then
		sudo apt-get update
		sudo apt-get install -y git ripgrep fd-find nodejs npm golang build-essential curl
	elif have dnf; then
		sudo dnf install -y git ripgrep fd-find nodejs golang gcc gcc-c++ make curl
	elif have pacman; then
		sudo pacman -S --needed --noconfirm git ripgrep fd nodejs npm go base-devel curl
	else
		echo "Unsupported Linux distro — install git, ripgrep, node, go and a C compiler manually." >&2
	fi
}

case "$OS" in
	Darwin) install_mac ;;
	Linux) install_linux ;;
	*)
		echo "Unsupported OS: $OS" >&2
		exit 1
		;;
esac

# Rust toolchain (rustup) — same on every platform.
# Needed by: rust_analyzer, blink.cmp's rust fuzzy matcher, leptosfmt.
if ! have rustup; then
	info "Installing rustup (Rust toolchain)"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	# shellcheck disable=SC1091
	source "$HOME/.cargo/env"
fi

# Cargo-installed CLIs the config expects.
if have cargo; then
	have tree-sitter || { info "cargo install tree-sitter-cli"; cargo install tree-sitter-cli; }
	have leptosfmt   || { info "cargo install leptosfmt";      cargo install leptosfmt; }
else
	echo "cargo not on PATH — open a new shell (or 'source \$HOME/.cargo/env') and re-run." >&2
fi

info "Done. Launch nvim — Mason will install LSP servers on first run."
