# Use Arch Linux as base image.
FROM archlinux:latest

# Import dotfiles folder.
COPY ./dotfiles dotfiles

# Install what's needed.
RUN yes | pacman -Syuu; pacman -S --needed --noconfirm - < dotfiles/pkglist.txt && \
       # Manual install of Criterion.
       # Can be replace with commented code below, which will install yay if you want to install AUR packages.
       # (A bit of an overkill for just Criterion).
       wget https://github.com/Snaipe/Criterion/releases/download/v2.3.3/criterion-v2.3.3-linux-x86_64.tar.bz2 -O - | tar -xj && \
       cp -r criterion-v2.3.3/include/criterion /usr/include/ && cp criterion-v2.3.3/lib/* /usr/lib/ && \
       cp criterion-v2.3.3/share/pkgconfig/* /usr/share/pkgconfig && \
       rm -rf criterion-v2.3.3 rm -rf criterion-v2.3.3-linux-x86_64.tar.bz2 && \
       # Add non root user for running makepkg to install yay for installing some AUR packages.
       # useradd non_root && mkdir /home/non_root && chown -R non_root:non_root /home/non_root && \
       # echo 'non_root ALL=NOPASSWD: ALL' >> /etc/sudoers && \
       # sudo -u non_root bash -c 'cd ~ && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && \
       #        yay -S --noconfirm criterion && cd ~ && rm -rf yay && yes | yay -Scc' && \
       # Clear the cache to reduce size.
       yes | pacman -Scc && \
       # Install oh-my-zsh and some plugins + powerlevel10k and build gitstatus.
       sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
       git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
       git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions && \
       git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && \
       $HOME/.oh-my-zsh/custom/themes/powerlevel10k/gitstatus/build -w && \
       # Install vim-plug + Neovim providers for Python and Node.
       sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
              https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'; \
       npm install -g neovim && pip install -U pynvim neovim && \
       # Move my dotfiles for Neovim and Zsh to the appropriate places.
       cp -r /dotfiles/nvim $HOME/.config/nvim && cp /dotfiles/zshrc $HOME/.zshrc && cp /dotfiles/p10k.zsh $HOME/.p10k.zsh && \
       # Install vim plugins via workaround.
       nvim --headless +PlugInstall +qall && timeout 2m nvim --headless +CocUpdateSync; exit 0

WORKDIR /home
