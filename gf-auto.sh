#!/bin/bash

GO_VERSION="go1.20.6"
INSTALL_DIR="/usr/local/go"
TAR_FILE="/tmp/${GO_VERSION}.linux-amd64.tar.gz"
GO_ENV_FILE="$HOME/.go_env"  

echo "Removing any existing Golang installation and configurations"
sudo rm -rf $INSTALL_DIR
sed -i '/export GOROOT=\/usr\/local\/go/d' ~/.profile
sed -i '/export GOPATH=${HOME}\/go/d' ~/.profile
sed -i '/export PATH=\$GOPATH\/bin:\$GOROOT\/bin:\${HOME}\/.local\/bin:\$PATH/d' ~/.profile
rm -rf ~/go ~/.gf

echo "Removing waybackurls and gf binaries if installed"
rm -f ~/go/bin/waybackurls ~/go/bin/gf

echo "Downloading Go"
wget "https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz" -O $TAR_FILE

echo "Installing Go"
sudo tar -C /usr/local -xzf $TAR_FILE
rm -f $TAR_FILE
cat <<EOF > $GO_ENV_FILE
export GOROOT=/usr/local/go
export GOPATH=\${HOME}/go
export PATH=\$GOPATH/bin:\$GOROOT/bin:\${HOME}/.local/bin:\$PATH
EOF

if ! grep -q "source $GO_ENV_FILE" ~/.zshrc; then
    echo "source $GO_ENV_FILE" >> ~/.zshrc
fi
source $GO_ENV_FILE
if command -v go &> /dev/null; then
    echo "Go installed successfully"
    echo "Go environment settings:"
    go env
else
    echo "Go installation failed"
    exit 1
fi
echo "Installing waybackurls and gf"
go install github.com/tomnomnom/waybackurls@latest
go install github.com/tomnomnom/gf@latest
if ! command -v waybackurls &> /dev/null || ! command -v gf &> /dev/null; then
    echo "Installation of waybackurls or gf failed"
    exit 1
fi
echo "Setting up gf patterns"
mkdir -p ~/.gf
git clone https://github.com/1ndianl33t/Gf-Patterns.git /tmp/Gf-Patterns
mv /tmp/Gf-Patterns/*.json ~/.gf/
rm -rf /tmp/Gf-Patterns

echo "Installation and setup Done!!!!!!"
