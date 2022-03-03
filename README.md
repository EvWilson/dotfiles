# My dotfiles!

Nothing makes me happier than re-flashing my OS at 2:30 in the morning (pro tip:
not the time to be messing around with LLVM toolchain paths) on a weekday, but
thank god this repo is here to get me back on my feet as quick as possible.

## Steps to achieve the perfect dev environment:
- Flash with latest Pop_OS! revision
- Install [homebrew](https://brew.sh/) for fast-moving dependencies
- Install beloved CLI utilities:
    - neovim
    - alacritty
    - ripgrep
    - fd-find (set alias)
    - htop
    - tmux
    - tree
    - fzf
- Install language toolchains
    - [nvm](https://github.com/nvm-sh/nvm)
    - [update-golang](https://github.com/udhos/update-golang)
    - [rustup](https://rustup.rs/)
    - [zig](https://github.com/ziglang/zig) and [zls](https://github.com/zigtools/zls)
- Set up config symlinks, install vimplug, add bash extensions (see respective scripts)
- Set git credential store (e.g. Linux - git config --global credential.helper store)
- Add assorted applications from managed shop du jour
    - e.g. Discord, Zoom, VLC media player, VSCode
