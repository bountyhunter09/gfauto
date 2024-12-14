#!/bin/bash



BOLD="\e[1m"

DEEP_GREEN="\e[38;5;28m"  

DEEP_RED="\e[38;5;196m"   

RESET="\e[0m"



USER_SHELL=$(basename "$SHELL")

if [ "$USER_SHELL" == "bash" ]; then

    PROFILE_FILE="$HOME/.bashrc"

elif [ "$USER_SHELL" == "zsh" ]; then

    PROFILE_FILE="$HOME/.zshrc"

else

    echo -e "${DEEP_RED}Unsupported shell: $USER_SHELL. Exiting...${RESET}"

    exit 1

fi

INSTALL_DIR="/usr/local/go"

GO_ENV_FILE="$HOME/.go_env"

LATEST_GO_VERSION=$(curl -L -s https://golang.org/VERSION?m=text | head -1)

if command -v go &> /dev/null; then

    INSTALLED_GO_VERSION=$(go version | awk '{print $3}')

else

    INSTALLED_GO_VERSION="none"

fi

if [ "$INSTALLED_GO_VERSION" != "$LATEST_GO_VERSION" ]; then

    echo -e "${DEEP_RED}Updating Go to the latest version (${LATEST_GO_VERSION})...${RESET}"

    sudo rm -rf $INSTALL_DIR

    wget -q "https://dl.google.com/go/${LATEST_GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz

    sudo tar -C /usr/local -xzf /tmp/go.tar.gz

    rm -f /tmp/go.tar.gz
    
    cat <<EOF > $GO_ENV_FILE

export GOROOT=/usr/local/go

export GOPATH=\${HOME}/go

export PATH=\$GOPATH/bin:\$GOROOT/bin:\${HOME}/.local/bin:\$PATH

EOF
    if ! grep -q "source $GO_ENV_FILE" "$PROFILE_FILE"; then

        echo "source $GO_ENV_FILE" >> "$PROFILE_FILE"

    fi
    
    source $PROFILE_FILE

    INSTALLED_GO_VERSION=$LATEST_GO_VERSION

else

    echo -e "${DEEP_GREEN}Go (${INSTALLED_GO_VERSION}) is already up-to-date.${RESET}"

fi

WAYBACKURLS_STATUS="${DEEP_GREEN}Installed${RESET}"

GF_STATUS="${DEEP_GREEN}Installed${RESET}"

GF_PATTERNS_STATUS="${DEEP_GREEN}Already Set Up${RESET}"

if ! command -v waybackurls &> /dev/null; then

    echo -e "${DEEP_RED}waybackurls is not installed. Installing now...${RESET}"

    go install github.com/tomnomnom/waybackurls@latest

    if command -v waybackurls &> /dev/null; then

        WAYBACKURLS_STATUS="${DEEP_GREEN}Successfully Installed${RESET}"

    else

        WAYBACKURLS_STATUS="${DEEP_RED}Failed to Install${RESET}"

    fi

else

    WAYBACKURLS_STATUS="${DEEP_GREEN}Already Installed${RESET}"

fi

if ! command -v gf &> /dev/null; then

    echo -e "${DEEP_RED}gf is not installed. Installing now...${RESET}"

    go install github.com/tomnomnom/gf@latest

    if command -v gf &> /dev/null; then

        GF_STATUS="${DEEP_GREEN}Successfully Installed${RESET}"

    else

        GF_STATUS="${DEEP_RED}Failed to Install${RESET}"

    fi

else

    GF_STATUS="${DEEP_GREEN}Already Installed${RESET}"

fi

if [ ! -d ~/.gf ] || [ "$(ls -A ~/.gf | wc -l)" -eq 0 ]; then

    echo -e "${DEEP_RED}gf patterns are not set up. Setting them up now...${RESET}"

    mkdir -p ~/.gf

    git clone https://github.com/1ndianl33t/Gf-Patterns.git /tmp/Gf-Patterns > /dev/null 2>&1

    mv /tmp/Gf-Patterns/*.json ~/.gf/

    rm -rf /tmp/Gf-Patterns

    if [ "$(ls -A ~/.gf | wc -l)" -gt 0 ]; then

        GF_PATTERNS_STATUS="${DEEP_GREEN}Successfully Set Up${RESET}"

    else

        GF_PATTERNS_STATUS="${DEEP_RED}Failed to Set Up${RESET}"

    fi

else

    GF_PATTERNS_STATUS="${DEEP_GREEN}Already Set Up${RESET}"

fi

echo -e "\n${BOLD}${DEEP_GREEN}Setup Summary:${RESET}"

echo -e "${BOLD}Shell in use:${RESET} ${USER_SHELL}"

echo -e "${BOLD}Go version:${RESET} ${DEEP_GREEN}${INSTALLED_GO_VERSION}${RESET}"

echo -e "${BOLD}waybackurls:${RESET} ${WAYBACKURLS_STATUS}"

echo -e "${BOLD}gf:${RESET} ${GF_STATUS}"

echo -e "${BOLD}gf patterns:${RESET} ${GF_PATTERNS_STATUS}"

echo -e "${BOLD}${DEEP_GREEN}Setup complete!${RESET}"

