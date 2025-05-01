#!/bin/bash

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                      SCRIPT INSTALLER UTILITIES                             ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# --- Konfigurasi Instalasi ---
INSTALL_DIR="$HOME/.local/bin"
SOURCE_SCRIPT_DIR="./scripts"
SCRIPTS_TO_INSTALL=("simapt" "cdisk" )
VERSION="1.0.1 (Bahasa Indonesia)"
DEBUG_MODE="true"  # Set ke "true" untuk menampilkan pesan debug lebih detail

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
COLOR_NC='\033[0m'     # No Color

if [[ "$1" == "--version" || "$1" == "-v" ]]; then
    echo "Versi skrip: $VERSION"
    exit 0
fi

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                             HELPER FUNCTIONS                                ║
# ╚════════════════════════════════════════════════════════════════════════════╝

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

log_debug() {
    if [ "${DEBUG_MODE}" = "true" ]; then
        echo -e "${COLOR_MAGENTA}[${BOLD}DEBUG${COLOR_NC}${COLOR_MAGENTA}]${COLOR_NC} $1"
    fi
}

print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "[${COLOR_GREEN}${BOLD}OK${COLOR_NC}]"
    else
        echo -e "[${COLOR_RED}${BOLD}FAIL${COLOR_NC}]"
    fi
}

# Fungsi untuk verbose error reporting
print_error_detail() {
    local error_code=$1
    local command=$2
    local subject=$3

    case $error_code in
        1)  # Catchall untuk kesalahan umum
            echo -e "    ${COLOR_RED}→${COLOR_NC} Kesalahan umum saat $command $subject"
            ;;
        2)  # Misuse of shell builtins
            echo -e "    ${COLOR_RED}→${COLOR_NC} Kesalahan sintaks saat $command $subject"
            ;;
        13) # Permission denied
            echo -e "    ${COLOR_RED}→${COLOR_NC} Izin ditolak saat $command $subject"
            echo -e "    ${COLOR_RED}→${COLOR_NC} Periksa izin pada file/direktori"
            ;;
        21) # Is a directory
            echo -e "    ${COLOR_RED}→${COLOR_NC} $subject adalah sebuah direktori, bukan file"
            ;;
        22) # Invalid argument
            echo -e "    ${COLOR_RED}→${COLOR_NC} Argumen tidak valid saat $command $subject"
            ;;
        126) # Command cannot execute
            echo -e "    ${COLOR_RED}→${COLOR_NC} Perintah tidak dapat dieksekusi: $command"
            ;;
        127) # Command not found
            echo -e "    ${COLOR_RED}→${COLOR_NC} Perintah tidak ditemukan: $command"
            ;;
        *)  # Unknown error
            echo -e "    ${COLOR_RED}→${COLOR_NC} Kesalahan tidak diketahui (kode: $error_code)"
            ;;
    esac
}

# --- Fungsi Animasi & UI ---
spinners="⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏"
spinner_index=0

# Display spinner with message
display_spinner() {
    local message="$1"
    local duration=${2:-15}
    local loading_text="${COLOR_CYAN}${ITALIC}loading${COLOR_NC}"
    
    # Clear line before starting
    printf "\r%-80s" " "
    
    # Show spinner animation for specified duration
    for i in $(seq 1 $duration); do
        frame=${spinners:$((spinner_index % 10 * 2)):1}
        printf "\r  ${COLOR_CYAN}${frame}${COLOR_NC} ${message} ${loading_text}"
        ((spinner_index++))
        sleep 0.1
    done
    
    # Clear spinner when done
    printf "\r%-80s\r" " "  # Membersihkan baris spinner
    printf "  ${message}... [${COLOR_GREEN}${BOLD}OK${COLOR_NC}]\n"  # Tambahkan warna hijau dan bold pada [OK]
}

# Progress bar display
display_progress_bar() {
    local current=$1
    local total=$2
    local prefix="${3:-Progress}"
    local size=40
    local percentage=$((current * 100 / total))
    local completed=$((percentage * size / 100))
    
    # Construct progress bar
    local bar="["
    for ((i=0; i<completed; i++)); do
        bar+="▓"
    done
    
    for ((i=completed; i<size; i++)); do
        bar+="░"
    done
    bar+="]"
    
    # Print the progress bar
    printf "\r  ${COLOR_BLUE}${prefix}${COLOR_NC}: ${bar} ${COLOR_GREEN}${percentage}%%${COLOR_NC}"
    
    # Add newline if complete
    if [ $current -eq $total ]; then
        echo ""
    fi
}

# Show header with border
print_header() {
    local header_text="$1"
    local line_char="─"
    local width=70
    local padding=$(( (width - ${#header_text} - 4) / 2 ))
    local left_padding=$padding
    local right_padding=$padding
    
    # Adjust padding if odd length
    if [ $(( (width - ${#header_text} - 4) % 2 )) -ne 0 ]; then
        right_padding=$((right_padding + 1))
    fi
    
    # Construct the lines
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
    
    # Create left and right paddings
    local left_pad=""
    for ((i=0; i<left_padding; i++)); do
        left_pad+=" "
    done
    
    local right_pad=""
    for ((i=0; i<right_padding; i++)); do
        right_pad+=" "
    done
    
    # Print header with border
    echo -e "${COLOR_CYAN}${top_line}${COLOR_NC}"
    echo -e "${COLOR_CYAN}│${left_pad}${COLOR_WHITE}${BOLD}${header_text}${COLOR_NC}${right_pad}${COLOR_CYAN}│${COLOR_NC}"
    echo -e "${COLOR_CYAN}${bottom_line}${COLOR_NC}"
}

# Clean exit with message
clean_exit() {
    local exit_code=$1
    local message="$2"
    
    if [ $exit_code -eq 0 ]; then
        log_success "$message"
    else
        log_error "$message"
    fi
    
    exit $exit_code
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                            INSTALLER CORE                                   ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Show welcome screen
show_welcome() {
    clear
    echo ""
    echo -e "${COLOR_CYAN}${BOLD}"
    echo "  ╔═════════════════════════════════════════════════════╗"
    echo "  ║                                                     ║"
    echo "  ║   █▀ █▀▀ █▀█ █ █▀█ ▀█▀   █ █▄░█ █▀ ▀█▀ ▄▀█ █░░      ║"
    echo "  ║   ▄█ █▄▄ █▀▄ █ █▀▀ ░█░   █ █░▀█ ▄█ ░█░ █▀█ █▄▄      ║"
    echo "  ║                                                     ║"
    echo "  ╚═════════════════════════════════════════════════════╝"
    echo -e "${COLOR_NC}"
    echo -e "  ${COLOR_BLUE}Versi ${VERSION}${COLOR_NC} | ${COLOR_MAGENTA}$(date +"%d %b %Y")${COLOR_NC}"
    echo ""
    echo -e "  ${ITALIC}Utilitas untuk memudahkan pengelolaan sistem Linux${COLOR_NC}"
    echo ""
}

# Perform pre-installation checks
perform_checks() {
    print_header "PRE-INSTALLATION CHECKS"
    echo ""
    
    local all_checks_passed=true
    
    # Check source directory
    echo -n "  Memeriksa direktori sumber... "
    if [ -d "$SOURCE_SCRIPT_DIR" ]; then
        print_status 0
        
        # Cek izin akses direktori sumber
        if [ ! -r "$SOURCE_SCRIPT_DIR" ]; then
            log_warn "Direktori sumber ada tapi tidak dapat dibaca (masalah izin)."
            log_debug "Izin direktori sumber: $(ls -ld "$SOURCE_SCRIPT_DIR" | awk '{print $1}')"
            all_checks_passed=false
        fi
    else
        print_status 1
        all_checks_passed=false
        log_error "Direktori sumber '$SOURCE_SCRIPT_DIR' tidak ditemukan."
        
        # Cek direktori kerja saat ini untuk membantu diagnosa
        log_debug "Direktori kerja saat ini: $(pwd)"
        log_debug "Isi direktori kerja: $(ls -la | grep -E 'scripts|install')"
    fi
    
    # Check script files
    local scripts_missing=0
    local scripts_permissions=0
    echo -e "\n  ${UNDERLINE}Pemeriksaan file skrip:${COLOR_NC}"
    for script_name in "${SCRIPTS_TO_INSTALL[@]}"; do
        echo -n "  Memeriksa file '$script_name'... "
        if [ -f "$SOURCE_SCRIPT_DIR/$script_name" ]; then
            print_status 0
            
            # Cek izin baca untuk file sumber
            if [ ! -r "$SOURCE_SCRIPT_DIR/$script_name" ]; then
                log_warn "    → File '$script_name' ada tapi tidak dapat dibaca (masalah izin)."
                log_debug "    → Izin file: $(ls -la "$SOURCE_SCRIPT_DIR/$script_name" | awk '{print $1}')"
                ((scripts_permissions++))
                all_checks_passed=false
            else
                # Tampilkan informasi tambahan tentang file dalam mode debug
                log_debug "    → File '$script_name' ditemukan dengan ukuran: $(du -h "$SOURCE_SCRIPT_DIR/$script_name" | cut -f1)"
                log_debug "    → Izin file: $(ls -la "$SOURCE_SCRIPT_DIR/$script_name" | awk '{print $1}')"
            fi
        else
            print_status 1
            all_checks_passed=false
            ((scripts_missing++))
            
            # Periksa kemungkinan typo dalam nama file
            possible_files=$(find "$SOURCE_SCRIPT_DIR" -type f -name "*$script_name*" 2>/dev/null)
            if [ -n "$possible_files" ]; then
                log_warn "    → File yang mirip dengan '$script_name' ditemukan:"
                echo "$possible_files" | while read -r file; do
                    log_debug "      - $(basename "$file")"
                done
            else
                log_debug "    → Tidak ada file yang mirip dengan '$script_name' di direktori sumber"
            fi
        fi
    done
    
    # Check installation directory and permissions
    echo -e "\n  ${UNDERLINE}Pemeriksaan direktori instalasi:${COLOR_NC}"
    echo -n "  Memeriksa keberadaan direktori '$INSTALL_DIR'... "
    if [ -d "$INSTALL_DIR" ]; then
        print_status 0
        log_debug "    → Direktori instalasi sudah ada"
        
        # Cek permission direktori instalasi
        echo -n "  Memeriksa izin tulis ke direktori instalasi... "
        if [ -w "$INSTALL_DIR" ]; then
            print_status 0
            log_debug "    → Memiliki izin tulis ke direktori instalasi"
        else
            print_status 1
            all_checks_passed=false
            log_error "Tidak memiliki izin tulis ke direktori instalasi '$INSTALL_DIR'."
            log_debug "    → Izin direktori: $(ls -ld "$INSTALL_DIR" | awk '{print $1}')"
            log_debug "    → Pemilik direktori: $(ls -ld "$INSTALL_DIR" | awk '{print $3}')"
        fi
    else
        print_status 1
        log_debug "    → Direktori instalasi tidak ada, akan mencoba membuat"
        
        # Cek izin untuk membuat direktori
        echo -n "  Memeriksa izin untuk membuat direktori... "
        parent_dir=$(dirname "$INSTALL_DIR")
        if [ -w "$parent_dir" ]; then
            print_status 0
            log_debug "    → Memiliki izin untuk membuat direktori di '$parent_dir'"
        else
            print_status 1
            all_checks_passed=false
            log_error "Tidak memiliki izin untuk membuat direktori di '$parent_dir'."
            log_debug "    → Izin direktori parent: $(ls -ld "$parent_dir" | awk '{print $1}')"
        fi
    fi
    
    echo ""
    # Summary
    if [ "$all_checks_passed" = true ]; then
        log_success "Semua pemeriksaan berhasil dilalui!"
    else
        log_warn "Beberapa pemeriksaan gagal. Instalasi mungkin tidak sempurna."
        
        # Detail masalah
        if [ $scripts_missing -gt 0 ]; then
            log_warn "$scripts_missing skrip tidak ditemukan di direktori sumber."
            log_debug "Pastikan semua file berada di: $SOURCE_SCRIPT_DIR/"
        fi
        
        if [ $scripts_permissions -gt 0 ]; then
            log_warn "$scripts_permissions skrip memiliki masalah izin akses."
            log_debug "Coba jalankan: chmod +r $SOURCE_SCRIPT_DIR/*"
        fi
        
        # Tampilkan ringkasan sistem untuk membantu diagnosa
        log_debug "Ringkasan sistem:"
        log_debug "  - User: $(whoami)"
        log_debug "  - Direktori kerja saat ini: $(pwd)"
        log_debug "  - Shell: $SHELL"
        
        # Ask for confirmation to continue
        echo -n "  Lanjutkan instalasi meskipun ada masalah? [y/N] "
        read -r confirm
        if [[ ! "$confirm" =~ ^[yY]$ ]]; then
            clean_exit 1 "Instalasi dibatalkan oleh pengguna."
        fi
    fi
    
    echo ""
}

# Create installation directory
setup_install_dir() {
    print_header "MENYIAPKAN DIREKTORI INSTALASI"
    echo ""
    
    display_spinner "Memeriksa/membuat direktori instalasi '$INSTALL_DIR'" 10
    mkdir -p "$INSTALL_DIR" > /dev/null 2>&1
    local exit_status=$?
    
    echo -n "  Membuat direktori instalasi '$INSTALL_DIR'... "
    print_status $exit_status
    
    if [ $exit_status -ne 0 ]; then
        clean_exit 1 "Gagal membuat direktori instalasi. Instalasi dibatalkan."
    fi
    
    echo ""
    echo "------------------------------------------------------------"
    echo ""
}

# Copy scripts to installation directory
install_scripts() {
    print_header "MEMASANG SKRIP"
    echo ""
    
    log_info "Menyalin skrip dari '$SOURCE_SCRIPT_DIR' ke '$INSTALL_DIR':"
    echo ""
    
    local total_scripts=${#SCRIPTS_TO_INSTALL[@]}
    local success_count=0
    local failure_details=()
    
    for script_name in "${SCRIPTS_TO_INSTALL[@]}"; do
        (
            source_path="$SOURCE_SCRIPT_DIR/$script_name"
            dest_path="$INSTALL_DIR/$script_name"
            
            echo -n "  Memasang '$script_name'... "
            
            if [ -f "$source_path" ]; then
                cp "$source_path" "$dest_path" && chmod +x "$dest_path"
                if [ $? -eq 0 ]; then
                    print_status 0
                    log_success "'$script_name' berhasil dipasang."
                    ((success_count++))
                else
                    print_status 1
                    log_error "Gagal memasang '$script_name'."
                    failure_details+=("$script_name")
                fi
            else
                print_status 1
                log_error "File sumber '$script_name' tidak ditemukan."
                failure_details+=("$script_name")
            fi
        )
    done
    
    echo ""
    log_info "$success_count dari $total_scripts skrip berhasil dipasang."
    
    if [ ${#failure_details[@]} -gt 0 ]; then
        log_error "Skrip berikut gagal dipasang: ${failure_details[*]}"
    fi
}

# Show post-installation instructions
show_instructions() {
    print_header "INSTRUKSI PASCA-INSTALASI"
    echo ""
    
    log_success "Proses instalasi selesai!"
    echo ""
    echo -e "  ${BOLD}Langkah Selanjutnya:${COLOR_NC}"
    echo ""
    echo -e "  ${COLOR_YELLOW}1.${COLOR_NC} Pastikan direktori instalasi '${COLOR_BLUE}$INSTALL_DIR${COLOR_NC}' ada dalam variabel \$PATH."
    echo "     (Biasanya ini otomatis pada sebagian besar distribusi Linux modern)"
    echo ""
    echo -e "  ${COLOR_YELLOW}2.${COLOR_NC} Untuk mengaktifkan perintah baru tanpa restart terminal:"
    echo -e "     Jalankan: ${COLOR_GREEN}source ~/.bashrc${COLOR_NC}"
    echo ""
    echo -e "  ${COLOR_YELLOW}3.${COLOR_NC} Skrip yang telah dipasang:"
    
    # Daftar skrip dengan status instalasi dan detail tambahan
    for script_name in "${SCRIPTS_TO_INSTALL[@]}"; do
        if [ -x "$INSTALL_DIR/$script_name" ]; then
            echo -e "     - ${COLOR_GREEN}$script_name${COLOR_NC}"
            echo -e "       ${COLOR_CYAN}Lokasi:${COLOR_NC} $INSTALL_DIR/$script_name"
            echo -e "       ${COLOR_CYAN}Status:${COLOR_NC} ${COLOR_GREEN}Siap digunakan${COLOR_NC}"
            
            # Tambahan informasi izin
            permissions=$(ls -la "$INSTALL_DIR/$script_name" | awk '{print $1}')
            echo -e "       ${COLOR_CYAN}Izin:${COLOR_NC} $permissions"
        else
            echo -e "     - ${COLOR_RED}$script_name${COLOR_NC} (tidak berhasil dipasang)"
            
            # Periksa kemungkinan penyebab kegagalan
            if [ -f "$INSTALL_DIR/$script_name" ]; then
                echo -e "       ${COLOR_CYAN}Masalah:${COLOR_NC} ${COLOR_YELLOW}File ada tapi tidak memiliki izin eksekusi${COLOR_NC}"
                permissions=$(ls -la "$INSTALL_DIR/$script_name" | awk '{print $1}')
                echo -e "       ${COLOR_CYAN}Izin saat ini:${COLOR_NC} $permissions"
                echo -e "       ${COLOR_CYAN}Solusi:${COLOR_NC} Jalankan ${COLOR_GREEN}chmod +x $INSTALL_DIR/$script_name${COLOR_NC}"
            elif [ -f "$SOURCE_SCRIPT_DIR/$script_name" ]; then
                echo -e "       ${COLOR_CYAN}Masalah:${COLOR_NC} ${COLOR_YELLOW}File sumber ada tapi gagal disalin${COLOR_NC}"
                echo -e "       ${COLOR_CYAN}Solusi:${COLOR_NC} Periksa izin direktori $INSTALL_DIR"
            else
                echo -e "       ${COLOR_CYAN}Masalah:${COLOR_NC} ${COLOR_RED}File sumber tidak ditemukan${COLOR_NC}"
                echo -e "       ${COLOR_CYAN}Lokasi dicari:${COLOR_NC} $SOURCE_SCRIPT_DIR/$script_name"
                echo -e "       ${COLOR_CYAN}Solusi:${COLOR_NC} Pastikan file ada di direktori sumber"
            fi
        fi
        echo ""
    done
    
    # Tambahkan informasi tentang troubleshooting
    echo -e "  ${COLOR_YELLOW}4.${COLOR_NC} Jika ada masalah dengan instalasi:"
    echo -e "     - Pastikan direktori ${COLOR_BLUE}$SOURCE_SCRIPT_DIR${COLOR_NC} berisi semua file yang diperlukan"
    echo -e "     - Periksa izin pada direktori ${COLOR_BLUE}$INSTALL_DIR${COLOR_NC} (jalankan: ${COLOR_GREEN}ls -la $INSTALL_DIR${COLOR_NC})"
    echo -e "     - Untuk instalasi manual: ${COLOR_GREEN}cp $SOURCE_SCRIPT_DIR/[nama_file] $INSTALL_DIR/ && chmod +x $INSTALL_DIR/[nama_file]${COLOR_NC}"
    echo ""
}

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║                           MAIN EXECUTION FLOW                               ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# Trap for clean exit
trap 'echo ""; log_error "Instalasi dibatalkan."; exit 1' INT TERM

# Main execution
show_welcome
sleep 1
perform_checks
setup_install_dir
install_scripts
show_instructions

exit 0