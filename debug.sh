#!/usr/bin/env bash
# debug.sh — depuração interativa com log, flags e rastreamento avançado
# Compatível com scripts interativos, logging confiável e organizado

# ==================================================
# DIRETÓRIOS E ARQUIVOS
# ==================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/debug.conf"
LOG_FILE="$SCRIPT_DIR/debug.log"
MAIN_SCRIPT="$SCRIPT_DIR/main.sh"
LAUNCHER="$SCRIPT_DIR/launcher.sh"

# ==================================================
# CORES E FORMATAÇÃO
# ==================================================
RESET=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)

# ==================================================
# DETECÇÃO DE IDIOMA
# ==================================================
case "${LANG,,}" in
pt_br*) LANG_CODE="pt_BR" ;;
*) LANG_CODE="en_US" ;;
esac

# ==================================================
# MENSAGENS
# ==================================================
declare -A MSG
if [[ "$LANG_CODE" == "pt_BR" ]]; then
    MSG=(
        [title]="MENU DE DEPURAÇÃO"
        [flags]="Configurar flags de execução"
        [run]="Executar scripts"
        [logs]="Gerenciar logs"
        [advanced]="Depuração avançada"
        [exit]="Sair"
        [choose]="Escolha uma opção"
        [invalid]="Opção inválida."
        [press_enter]="Pressione Enter para continuar..."
        [saving]="Salvando configurações..."
        [script_not_found]="Arquivo não encontrado"
        [log_not_found]="Log não encontrado"
        [log_archived]="Logs antigos movidos para logs/"
        [running]="Executando"
        [script_exit]="Código de saída"
        [prompt_path]="Digite o caminho do script"
        [list_header]="Conteúdo do diretório atual:"
        [list_footer]="Use caminhos relativos ao projeto."
        [view_env]="Exibir variáveis de ambiente"
        [list_scripts]="Deseja listar todos os scripts do projeto? (s/n, 0 para cancelar): "
        [simple]="Simples"
        [advanced_mode]="Avançado"
    )
else
    MSG=(
        [title]="DEBUG MENU"
        [flags]="Configure debug flags"
        [run]="Run scripts"
        [logs]="Manage logs"
        [advanced]="Advanced debug"
        [exit]="Exit"
        [choose]="Choose an option"
        [invalid]="Invalid option."
        [press_enter]="Press Enter to continue..."
        [saving]="Saving configuration..."
        [script_not_found]="File not found"
        [log_not_found]="Log not found"
        [log_archived]="Old logs moved to logs/"
        [running]="Running"
        [script_exit]="Exit code"
        [prompt_path]="Enter script path"
        [list_header]="Project directory content:"
        [list_footer]="Use paths relative to the project root."
        [view_env]="View environment variables"
        [list_scripts]="Do you want to list all project scripts? (y/n, 0 to cancel): "
        [simple]="Simple"
        [advanced_mode]="Advanced"
    )
fi

# ==================================================
# FLAGS DE DEBUG PADRÃO
# ==================================================
DEBUG_X=false
DEBUG_E=true
DEBUG_U=true
DEBUG_PIPEFAIL=true

# ==================================================
# FUNÇÕES UTILITÁRIAS
# ==================================================
remove_non_printable() { sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g" | tr -cd '\11\12\15\40-\176'; }
icon_status() { [[ "$1" == true ]] && printf "${GREEN}ON${RESET}" || printf "${RED}OFF${RESET}"; }
load_config() { [[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"; }
save_config() {
    printf "${YELLOW}${MSG[saving]}${RESET}\n"
    cat >"$CONFIG_FILE" <<EOF
DEBUG_X=$DEBUG_X
DEBUG_E=$DEBUG_E
DEBUG_U=$DEBUG_U
DEBUG_PIPEFAIL=$DEBUG_PIPEFAIL
EOF
}
reset_flags() {
    DEBUG_X=false
    DEBUG_E=true
    DEBUG_U=true
    DEBUG_PIPEFAIL=true
    printf "${GREEN}Flags restauradas aos padrões.${RESET}\n"
    sleep 1
}
apply_debug_flags() {
    [[ $DEBUG_X == true ]] && set -x || set +x
    [[ $DEBUG_E == true ]] && set -e || set +e
    [[ $DEBUG_U == true ]] && set -u || set +u
    [[ $DEBUG_PIPEFAIL == true ]] && set -o pipefail || set +o pipefail
}

# ==================================================
# LOGS
# ==================================================
write_log_header() {
    local path="$1" type="$2"
    printf "\n"
    printf '#%.0s' {1..80}
    printf "\n"
    printf "####### NOVA EXECUÇÃO: $(date '+%Y-%m-%d %H:%M:%S') #######\n"
    printf "# TIPO   : %s\n" "$type"
    printf "# SCRIPT : %s\n" "$path"
    printf "# FLAGS  : X=%s E=%s U=%s PIPEFAIL=%s\n" "$DEBUG_X" "$DEBUG_E" "$DEBUG_U" "$DEBUG_PIPEFAIL"
    printf '#%.0s' {1..80}
    printf "\n"
    echo >>"$LOG_FILE"
}

write_log_footer() {
    local code="$1"
    printf '#%.0s' {1..80} >>"$LOG_FILE"
    printf "\n" >>"$LOG_FILE"
    printf "####### FIM DA EXECUÇÃO: $(date '+%Y-%m-%d %H:%M:%S') #######\n" >>"$LOG_FILE"
    printf "# SAÍDA: %s\n" "$code" >>"$LOG_FILE"
    printf '#%.0s' {1..80} >>"$LOG_FILE"
    printf "\n\n" >>"$LOG_FILE"
}

run_script() {
    local path="$1" type="${2:-${MSG[simple]}}"
    [[ -f "$path" ]] || {
        printf "${RED}%s: %s${RESET}\n" "${MSG[script_not_found]}" "$path"
        sleep 1
        return 1
    }

    printf "\n${BOLD}${GREEN}%s:${RESET} %s\n" "${MSG[running]}" "$path"
    write_log_header "$path" "$type"
    apply_debug_flags

    # Executa via pseudo-terminal para preservar entrada
    script -q -c "bash \"$path\"" -f "$LOG_FILE"

    local code=${PIPESTATUS[0]:-0}
    write_log_footer "$code"

    printf "\n${BOLD}${YELLOW}%s: %s${RESET}\n" "${MSG[script_exit]}" "$code"
    printf "${CYAN}${MSG[press_enter]}${RESET} "
    read -r
    set +x
    return $code
}

view_env_vars() { env | sort | less; }

list_root_files() {
    printf "\n${CYAN}%s${RESET}\n" "${MSG[list_header]}"
    ls -1p --color=auto "$SCRIPT_DIR" | sort | column
    printf "\n${DIM}%s${RESET}\n" "${MSG[list_footer]}"
}

archive_logs() {
    local LOGS_DIR="$SCRIPT_DIR/logs"
    mkdir -p "$LOGS_DIR"
    local timestamp
    timestamp=$(date +"%Y%m%d_%H%M%S")
    mv "$SCRIPT_DIR"/debug*.log "$LOGS_DIR"/debug_"$timestamp".log 2>/dev/null || true
    printf "\n${GREEN}%s${RESET}\n" "${MSG[log_archived]}"
    printf "\n${YELLOW}${MSG[press_enter]}${RESET}"
    read -r
}

# ==================================================
# LISTAGEM RECURSIVA DE SCRIPTS
# ==================================================
list_all_scripts() {
    mapfile -t scripts < <(find "$SCRIPT_DIR" -type f -name "*.sh" | sort)
    printf "\n${CYAN}Scripts encontrados:${RESET}\n"
    local i=1
    for s in "${scripts[@]}"; do
        printf "%3d) %s\n" "$i" "${s#$SCRIPT_DIR/}"
        ((i++))
    done
}

select_script_from_list() {
    list_all_scripts
    printf "\nDigite o número do script (0 para cancelar): "
    read -r num
    [[ "$num" == "0" ]] && return 1
    [[ "$num" -ge 1 && "$num" -le "${#scripts[@]}" ]] || {
        printf "${RED}%s${RESET}\n" "${MSG[invalid]}"
        sleep 1
        return 1
    }
    echo "${scripts[$((num - 1))]}"
}

# ==================================================
# SUBMENUS
# ==================================================
submenu_flags() {
    while true; do
        clear
        printf "${BOLD}${CYAN}=== %s ===${RESET}\n" "${MSG[flags]}"
        printf "1) set -x        (%s)\n" "$(icon_status "$DEBUG_X")"
        printf "2) set -e        (%s)\n" "$(icon_status "$DEBUG_E")"
        printf "3) set -u        (%s)\n" "$(icon_status "$DEBUG_U")"
        printf "4) pipefail      (%s)\n" "$(icon_status "$DEBUG_PIPEFAIL")"
        printf "5) Restaurar padrão\n0) Voltar\n"
        printf "\n${BOLD}%s: ${RESET}" "${MSG[choose]}"
        read -n1 -r ch
        case "$ch" in
        1) DEBUG_X=$([[ $DEBUG_X == true ]] && echo false || echo true) ;;
        2) DEBUG_E=$([[ $DEBUG_E == true ]] && echo false || echo true) ;;
        3) DEBUG_U=$([[ $DEBUG_U == true ]] && echo false || echo true) ;;
        4) DEBUG_PIPEFAIL=$([[ $DEBUG_PIPEFAIL == true ]] && echo false || echo true) ;;
        5) reset_flags ;;
        0) break ;;
        *)
            printf "${RED}%s${RESET}\n" "${MSG[invalid]}"
            sleep 1
            ;;
        esac
    done
}

submenu_run() {
    while true; do
        clear
        printf "${BOLD}${CYAN}=== %s ===${RESET}\n" "${MSG[run]}"
        printf "1) Executar launcher.sh\n2) Executar main.sh\n3) Executar outro script\n0) Voltar\n"
        printf "\n${BOLD}%s: ${RESET}" "${MSG[choose]}"
        read -n1 -r ch
        case "$ch" in
        1)
            save_config
            run_script "$LAUNCHER" "${MSG[simple]}"
            ;;
        2)
            save_config
            run_script "$MAIN_SCRIPT" "${MSG[simple]}"
            ;;
        3)
            save_config
            printf "%s" "${MSG[list_scripts]}"
            read -r list_choice
            if [[ "$list_choice" =~ ^[Ss]$ ]]; then
                sel_script=$(select_script_from_list) || continue
                run_script "$sel_script" "${MSG[simple]}"
            elif [[ "$list_choice" =~ ^[Nn]$ ]]; then
                printf "%s (0 para cancelar): " "${MSG[prompt_path]}"
                read -r path
                [[ "$path" == "0" || -z "$path" ]] && continue
                [[ "$path" != /* ]] && path="$SCRIPT_DIR/$path"
                run_script "$path" "${MSG[simple]}"
            fi
            ;;
        0) break ;;
        *)
            printf "${RED}%s${RESET}\n" "${MSG[invalid]}"
            sleep 1
            ;;
        esac
    done
}

submenu_logs() {
    while true; do
        clear
        printf "${BOLD}${CYAN}=== %s ===${RESET}\n" "${MSG[logs]}"
        printf "1) Ver log atual\n2) Arquivar logs antigos\n0) Voltar\n"
        printf "\n${BOLD}%s: ${RESET}" "${MSG[choose]}"
        read -n1 -r ch
        case "$ch" in
        1) [[ -f "$LOG_FILE" ]] && ${EDITOR:-nano} "$LOG_FILE" || printf "${RED}%s${RESET}\n" "${MSG[log_not_found]}" ;;
        2) archive_logs ;;
        0) break ;;
        *)
            printf "${RED}%s${RESET}\n" "${MSG[invalid]}"
            sleep 1
            ;;
        esac
    done
}

submenu_advanced() {
    while true; do
        clear
        printf "${BOLD}${CYAN}=== %s ===${RESET}\n" "${MSG[advanced]}"
        printf "1) Modo Detalhado (main.sh)\n2) Modo Detalhado (outro script)\n3) Ver variáveis de ambiente\n0) Voltar\n"
        printf "\n${BOLD}%s: ${RESET}" "${MSG[choose]}"
        read -n1 -r ch
        case "$ch" in
        1) run_script "$MAIN_SCRIPT" "${MSG[advanced_mode]}" ;;
        2)
            printf "%s" "${MSG[list_scripts]}"
            read -r list_choice
            if [[ "$list_choice" =~ ^[Ss]$ ]]; then
                sel_script=$(select_script_from_list) || continue
                run_script "$sel_script" "${MSG[advanced_mode]}"
            elif [[ "$list_choice" =~ ^[Nn]$ ]]; then
                printf "%s (0 para cancelar): " "${MSG[prompt_path]}"
                read -r path
                [[ "$path" == "0" || -z "$path" ]] && continue
                [[ "$path" != /* ]] && path="$SCRIPT_DIR/$path"
                run_script "$path" "${MSG[advanced_mode]}"
            fi
            ;;
        3) view_env_vars ;;
        0) break ;;
        *)
            printf "${RED}%s${RESET}\n" "${MSG[invalid]}"
            sleep 1
            ;;
        esac
    done
}

# ==================================================
# EXECUÇÃO PRINCIPAL
# ==================================================
load_config
while true; do
    clear
    printf "${BOLD}${CYAN}========== %s ==========${RESET}\n" "${MSG[title]}"
    printf "1) %s\n2) %s\n3) %s\n4) %s\n0) %s\n" "${MSG[flags]}" "${MSG[run]}" "${MSG[logs]}" "${MSG[advanced]}" "${MSG[exit]}"
    printf "${CYAN}------------------------------------${RESET}\n"
    printf "\n${BOLD}%s: ${RESET}" "${MSG[choose]}"
    read -n1 -r option
    case "$option" in
    1) submenu_flags ;;
    2) submenu_run ;;
    3) submenu_logs ;;
    4) submenu_advanced ;;
    0)
        save_config
        printf "${RED}%s${RESET}\n" "${MSG[exit]}"
        exit 0
        ;;
    *)
        printf "${RED}%s${RESET}\n" "${MSG[invalid]}"
        sleep 1
        ;;
    esac
done
