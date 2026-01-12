#!/bin/bash

# --- CẤU HÌNH ---
DATASET_DIR="./contracts30"
RESULT_DIR="./results30_10_1"
LOG_DIR="./logs"
SOLC_BIN=$(which solc)
TARGET_VER="0.4.26"
INNER_TIMEOUT=600   # chỉ còn timeout bên trong fuzzer

mkdir -p "$RESULT_DIR"
mkdir -p "$LOG_DIR"
solc-select use "$TARGET_VER" > /dev/null

echo "=================================================="
echo "TU DONG TIM TEN CONTRACT"
echo "=================================================="

for file in "$DATASET_DIR"/*.sol; do
    filename=$(basename -- "$file")

    # --- BỘ LỌC VERSION ---
    if grep -qE "pragma solidity 0\.[5-8]|pragma solidity \^0\.[5-8]" "$file"; then
        continue
    fi
    if grep -q "pragma solidity 0.4." "$file" && ! grep -q "\^" "$file" && ! grep -q "0.4.26" "$file"; then
        continue
    fi
    if ! grep -qE "pragma solidity \^0\.4|pragma solidity 0\.4\.26" "$file"; then
        continue
    fi

    # --- TỰ ĐỘNG LẤY TÊN CONTRACT ---
    real_contract_name=$(grep "^contract " "$file" | awk '{print $2}' | sed 's/{//g' | tail -n 1)

    if [ -z "$real_contract_name" ]; then
        real_contract_name="${filename%.*}"
    fi

    output_file="$RESULT_DIR/${filename%.*}_res.json"
    log_file="$LOG_DIR/${filename%.*}.log"

    echo ">>> File: $filename"
    echo "    -> Contract Name tim thay: $real_contract_name"
    echo "    -> Log se luu tai: $log_file"

    # --- CHẠY CROSSFUZZ (không timeout) ---
    if python3 CrossFuzz.py \
        "$file" \
        "$real_contract_name" \
        "$TARGET_VER" \
        10 \
        "$INNER_TIMEOUT" \
        "$output_file" \
        "$SOLC_BIN" \
        auto \
        1 2>&1 | tee "$log_file"
    then
        if [ -f "$output_file" ]; then
            echo "    -> [OK] Ket qua da luu."
        else
            echo "    -> [FAIL] CrossFuzz chay xong NHUNG khong tao file $output_file"
            echo "       (Xem log: $log_file)"
        fi
    else
        echo "    -> [FAIL] CrossFuzz.py bi loi. Xem log: $log_file"
    fi

    echo "--------------------------------------------------"

done
