
append() {
  local file=$1
  local line; for line in "${@:2}"; do
    echo "$line" >> $file
  done
}

create_file() {
  local file=$1
  rm -f $file
  local line; for line in "${@:2}"; do
    echo "$line" >> $file
  done
}

install_neovim() {
  sudo apt install -y neovim
}

install_git() {
  sudo apt install -y git
  git config --global init.defaultBranch 'main'
  git config --global user.email 'jacobcohen76@protonmail.com'
  git config --global user.name 'Jacob Cohen'
  git config --global core.editor 'nvim'
}

install_zsh() {
  sudo apt install -y zsh
  chsh -s $(which zsh)
}

install_ohmyzsh() {
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}

install_pyenv() {
  sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
                      libreadline-dev libsqlite3-dev wget curl llvm         \
                      libncursesw5-dev xz-utils tk-dev libxml2-dev          \
                      libxmlsec1-dev libffi-dev liblzma-dev
  curl https://pyenv.run | bash

  # pyenv rc setup
  append ~/.bashrc \
    ''                                                                   \
    '# pyenv'                                                            \
    'export PYENV_ROOT="$HOME/.pyenv"'                                   \
    'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' \
    'eval "$(pyenv init -)"'

  # pyenv-virtualenv rc setup
  append ~/.bashrc \
    ''                                      \
    '# pyenv-virtualenv'                    \
    'eval "$(pyenv virtualenv-init -)"'
}

install_poetry() {
  curl -sSL https://install.python-poetry.org | python3 - -y
  append ~/.bashrc \
      ''                                           \
      '# poetry'                                   \
      'export PATH="/home/cohen/.local/bin:$PATH"'
}

install_nvm() {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
  append ~/.bashrc \
    ''                                                                   \
    '# nvm'                                                              \
    'export NVM_DIR="$HOME/.nvm"'                                        \
    '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'                   \
    '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"'
}

install_rustup() {
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

install_build2() {
  sudo apt install -y g++
  mkdir -p temp && cd temp
  curl -sSfO https://download.build2.org/0.15.0/build2-install-0.15.0.sh
  yes | sh build2-install-0.15.0.sh
  cd .. && rm -rf temp
}

install_gcc_12() {
  mkdir -p temp && cd temp
  sudo apt install -y flex gcc gcc-multilib make
  git clone https://gcc.gnu.org/git/gcc.git && cd gcc
  git checkout remotes/origin/releases/gcc-12
  ./contrib/download_prerequisites
  mkdir -p ../gcc-build && cd ../gcc-build
  ./../gcc/configure --prefix=$(pwd)/../gcc-install --enable-languages=c,c++
  make -j $(($(getconf _NPROCESSORS_ONLN) + 1))
  make install
  cd ../gcc-install
  cd ../.. && rm -rf temp
}

make_zshrc() {
  create_file ~/.zshrc \
    '# path to oh-my-zsh installation'                                   \
    'export ZSH="$HOME/.oh-my-zsh"'                                      \
    ''                                                                   \
    '# theme'                                                            \
    'ZSH_THEME="robbyrussell"'                                           \
    ''                                                                   \
    '# cargo'                                                            \
    '. "$HOME/.cargo/env"'                                               \
    ''                                                                   \
    '# pyenv'                                                            \
    'export PYENV_ROOT="$HOME/.pyenv"'                                   \
    'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' \
    'eval "$(pyenv init -)"'                                             \
    ''                                                                   \
    '# pyenv-virtualenv'                                                 \
    'eval "$(pyenv virtualenv-init -)"'                                  \
    ''                                                                   \
    '# poetry'                                                           \
    'export PATH="/home/cohen/.local/bin:$PATH"'                         \
    ''                                                                   \
    '# nvm'                                                              \
    'export NVM_DIR="$HOME/.nvm"'                                        \
    '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'                   \
    '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' \
    ''                                                                   \
    '# plugins'                                                          \
    'plugins=('                                                          \
    '  git'                                                              \
    '  gnu-utils'                                                        \
    '  node'                                                             \
    '  npm'                                                              \
    '  nvm'                                                              \
    '  pip'                                                              \
    '  poetry'                                                           \
    '  pyenv'                                                            \
    '  python'                                                           \
    '  rust'                                                             \
    '  yarn'                                                             \
    ')'                                                                  \
    ''                                                                   \
    'source $ZSH/oh-my-zsh.sh'
}

main() {
  touch ~/.hushlogin
  sudo apt update
  sudo apt upgrade -y
  install_neovim
  install_git
  install_zsh
  install_ohmyzsh
  install_pyenv
  install_poetry
  install_nvm
  install_rustup
  make_zshrc
}

main
