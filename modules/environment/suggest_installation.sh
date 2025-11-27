#!/bin/bash
# modules/enviroment/suggest_installation.sh
# Sugerir comando de instalação

suggest_installation() {
    local packages=("$@")
    local manager=""
    local command=""
    local found_manager=false
    local has_spotdl=false

    # Verificar se spotdl está na lista de pacotes
    if [[ " ${packages[*]} " =~ " spotdl " ]]; then
        has_spotdl=true
        # Remover spotdl da lista para instalação via gerenciador tradicional
        packages=("${packages[@]/spotdl/}")
    fi

    # Detectar gerenciador de pacotes para pacotes tradicionais
    if ((${#packages[@]} > 0)); then
        if command -v pacman &>/dev/null; then
            manager="pacman"
            command="sudo pacman -S ${packages[*]}"
            found_manager=true
        elif command -v apt &>/dev/null; then
            manager="apt"
            command="sudo apt update && sudo apt install ${packages[*]}"
            found_manager=true
        elif command -v dnf &>/dev/null; then
            manager="dnf"
            command="sudo dnf install ${packages[*]}"
            found_manager=true
        elif command -v zypper &>/dev/null; then
            manager="zypper"
            command="sudo zypper install ${packages[*]}"
            found_manager=true
        elif command -v emerge &>/dev/null; then
            manager="emerge"
            command="sudo emerge ${packages[*]}"
            found_manager=true
        elif command -v apk &>/dev/null; then
            manager="apk"
            command="sudo apk add ${packages[*]}"
            found_manager=true
        fi
    fi

    # Mostrar comandos de instalação
    if $found_manager || $has_spotdl; then
        fmt_info "$(get_msg install_with)"

        # Comando para pacotes tradicionais
        if $found_manager; then
            fmt_info "  $command"
        fi

        # Comando para spotdl (sempre via pip/pipx)
        if $has_spotdl; then
            if command -v pipx &>/dev/null; then
                fmt_info "  pipx install spotdl  # (Recomendado)"
            elif command -v pip3 &>/dev/null; then
                fmt_info "  pip3 install spotdl"
            elif command -v pip &>/dev/null; then
                fmt_info "  pip install spotdl"
            else
                fmt_info "  # Instale pip primeiro:"
                if command -v pacman &>/dev/null; then
                    fmt_info "  sudo pacman -S python-pip"
                elif command -v apt &>/dev/null; then
                    fmt_info "  sudo apt install python3-pip"
                elif command -v dnf &>/dev/null; then
                    fmt_info "  sudo dnf install python3-pip"
                fi
                fmt_info "  pip install spotdl"
            fi
        fi
    else
        fmt_error "$(get_msg error_pkg_manager_not_detected)"
        fmt_warning "$(get_msg please_install_manually)"

        # Instruções manuais para cada pacote
        for dep in "$@"; do
            fmt_info "  $dep:"
            case "$dep" in
            ffmpeg)
                fmt_info "    $(get_msg ffmpeg_manual_install)"
                ;;
            jq)
                fmt_info "    $(get_msg jq_manual_install)"
                ;;
            spotdl)
                fmt_info "    $(get_msg spotdl_manual_install)"
                ;;
            esac
        done
    fi

    fmt_warning "$(get_msg after_install_instructions)"
    prompt_enter_continue
}
