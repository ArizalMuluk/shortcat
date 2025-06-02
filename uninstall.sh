#!/bin/bash

# --- Konfigurasi ---
INSTALL_DIR="$HOME/.local/bin"
SCRIPTS_TO_UNINSTALL=("simapt" "cdisk" "gotask")

# --- Kode Warna & Style ---
BOLD='\033[1m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_CYAN='\033[0;36m'
COLOR_MAGENTA='\033[0;35m'
COLOR_WHITE='\033[1;37m'
COLOR_NC='\033[0m'

# --- Fungsi Logging & Status ---
log_info() {
    echo -e "${COLOR_BLUE}[${BOLD}INFO${COLOR_NC}${COLOR_BLUE}]${COLOR_NC} $1"
}

log_success() {
    echo -e "${COLOR_GREEN}[${BOLD}SUCCESS${COLOR_NC}${COLOR_GREEN}]${COLOR_NC} $1"
}

log_warn() {
    echo -e "${COLOR_YELLOW}[${BOLD}WARN${COLOR_NC}${COLOR_YELLOW}]${COLOR_NC} $1"
}

log_error() {
    echo -e "${COLOR_RED}[${BOLD}ERROR${COLOR_NC}${COLOR_RED}]${COLOR_NC} $1" >&2
}

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "[${COLOR_GREEN}${BOLD}OK${COLOR_NC}]"
    else
        echo -e "[${COLOR_RED}${BOLD}FAIL${COLOR_NC}]"
    fi
}

# --- Fungsi Animasi & UI ---
spinners="⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏"
spinner_index=0

display_spinner() {
    local message="$1"
    local duration=${2:-15}
    local loading_text="${COLOR_CYAN}${ITALIC}loading${COLOR_NC}"
    
    printf "\r%-80s" " "
    for i in $(seq 1 $duration); do
        frame=${spinners:$((spinner_index % 10 * 2)):1}
        printf "\r  ${COLOR_CYAN}${frame}${COLOR_NC} ${message} ${loading_text}"
        ((spinner_index++))
        sleep 0.1
    done
    printf "\r%-80s" " "
    printf "\r  ${message}"
}

display_progress_bar() {
    local current=$1
    local total=$2
    local prefix="${3:-Progress}"
    local size=40
    local percentage=$((current * 100 / total))
    local completed=$((percentage * size / 100))
    
    local bar="["
    for ((i=0; i<completed; i++)); do
        bar+="▓"
    done
    for ((i=completed; i<size; i++)); do
        bar+="░"
    done
    bar+="]"
    
    printf "\r  ${COLOR_BLUE}${prefix}${COLOR_NC}: ${bar} ${COLOR_GREEN}${percentage}%%${COLOR_NC}"
    if [ $current -eq $total ]; then
        echo ""
    fi
}

print_header() {
    local header_text="$1"
    local line_char="─"
    local width=70
    local padding=$(( (width - ${#header_text} - 4) / 2 ))
    local left_padding=$padding
    local right_padding=$padding
    
    if [ $(( (width - ${#header_text} - 4) % 2 )) -ne 0 ]; then
        right_padding=$((right_padding + 1))
    fi
    
    local top_line="┌${line_char}"
    for ((i=0; i<width-2; i++)); do
        top_line+="${line_char}"
    done
    top_line+="┐"
    
    local bottom_line="└${line_char}"
    for ((i=0; i<width-2; i++)); do
        bottom_line+="${line_char}"
    done
    bottom_line+="┘"
    
    local left_pad=""
    for ((i=0; i<left_padding; i++)); do
        left_pad+=" "
    done
    
    local right_pad=""
    for ((i=0; i<right_padding; i++)); do
        right_pad+=" "
    done
    
    echo -e "${COLOR_CYAN}${top_line}${COLOR_NC}"
    echo -e "${COLOR_CYAN}│${left_pad}${COLOR_WHITE}${BOLD}${header_text}${COLOR_NC}${right_pad}${COLOR_CYAN}│${COLOR_NC}"
    echo -e "${COLOR_CYAN}${bottom_line}${COLOR_NC}"
}

# --- Proses Uninstalasi ---
uninstall_scripts() {
    print_header "MEMULAI PROSES UNINSTALASI"
    echo ""
    
    log_info "Menghapus skrip dari '$INSTALL_DIR':"
    echo ""
    
    if [ ! -d "$INSTALL_DIR" ]; then
        log_warn "Direktori instalasi '$INSTALL_DIR' tidak ditemukan. Mungkin skrip belum diinstal atau diinstal di lokasi lain."
    else
        local total_scripts=${#SCRIPTS_TO_UNINSTALL[@]}
        local success_count=0
        local failure_details=()
        
        for script_name in "${SCRIPTS_TO_UNINSTALL[@]}"; do
            script_path="$INSTALL_DIR/$script_name"
            
            echo -n "  Menghapus '$script_name'... "
            if [ -f "$script_path" ]; then
                rm "$script_path"
                if [ $? -eq 0 ]; then
                    print_status 0
                    ((success_count++))
                else
                    print_status 1
                    log_warn "Gagal menghapus '$script_name'. Periksa izin pengguna atau hapus secara manual."
                    failure_details+=("$script_name")
                fi
            else
                print_status 1
                log_info "'$script_name' tidak ditemukan di '$INSTALL_DIR'. Mungkin sudah dihapus sebelumnya."
            fi
        done
        
        echo ""
        log_info "$success_count dari $total_scripts skrip berhasil dihapus."
        
        if [ ${#failure_details[@]} -gt 0 ]; then
            log_error "Skrip berikut gagal dihapus: ${failure_details[*]}"
        fi
    fi
}

# --- Instruksi Pasca-Uninstalasi ---
show_instructions() {
    print_header "INSTRUKSI PASCA-UNINSTALASI"
    echo ""
    
    log_success "Proses uninstalasi selesai!"
    echo ""
    echo -e "  ${BOLD}Langkah Selanjutnya:${COLOR_NC}"
    echo ""
    echo -e "  ${COLOR_YELLOW}1.${COLOR_NC} Pastikan perintah yang dihapus tidak lagi tersedia di terminal."
    echo -e "     Jika masih tersedia, muat ulang konfigurasi shell dengan perintah:"
    echo -e "     ${COLOR_GREEN}source ~/.bashrc${COLOR_NC}"
    echo ""
    echo -e "  ${COLOR_YELLOW}2.${COLOR_NC} Periksa direktori instalasi '${COLOR_BLUE}$INSTALL_DIR${COLOR_NC}' untuk memastikan tidak ada file yang tersisa."
    echo ""
}

# --- Main Execution ---
trap 'echo ""; log_error "Uninstalasi dibatalkan."; exit 1' INT TERM

print_header "SELAMAT DATANG DI UNINSTALLER"
sleep 1
uninstall_scripts
show_instructions

exit 0