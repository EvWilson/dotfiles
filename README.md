# My dotfiles!

Nothing makes me happier than re-flashing my OS at 2:30 in the morning (pro tip:
not the time to be messing around with LLVM toolchain paths) on a
weekday, but thank god this repo is here to get me back on my feet as quick as
possible.

## Steps to achieve the perfect dev environment:
- Flash with latest Pop_OS! revision
- Remove unneeded home folders, add proj/tools/etc
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
    - nvm (https://github.com/nvm-sh/nvm)
    - update-golang (https://github.com/udhos/update-golang)
    - rustup (https://rustup.rs/)
    - check python3 installation (and go ahead and install python3-pip)
    - zig/zls
        - https://github.com/ziglang/zig
        - https://github.com/zigtools/zls
- Set up config symlinks, install vimplug, add bash extensions (see respective
scripts)
- Do any additional setup as mentioned in nvim config
- Set git credential store (e.g. Linux - git config --global credential.helper store)
- Add assorted applications from managed shop du jour
    - e.g. Discord, Zoom, VLC media player, VSCode
