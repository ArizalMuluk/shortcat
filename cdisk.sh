#!/bin/bash

echo "=== Penggunaan Ruang Disk (Partisi Penting) ==="
df -h / /home /var

echo ""

echo "=== Ukuran Direktori Home Anda  ==="
du -sh /home/$USER

echo ""

echo "================================="
echo "Selesai Cek Disk"
