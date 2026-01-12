#!/bin/bash

# 1. Cấu hình đường dẫn
DATASET_DIR="./contracts"      # Thư mục chứa code .sol
RESULT_DIR="./results"  # Thư mục chứa kết quả
SOLC_BIN=$(which solc)         # Tự động lấy đường dẫn solc
SOLC_VERSION="0.4.26"          # Phiên bản Solidity của Dataset (Lưu ý phải khớp)
TIME_LIMIT=60                  # Thời gian chạy mỗi file (giây)

# Tạo thư mục kết quả nếu chưa có
mkdir -p "$RESULT_DIR"

# 2. Vòng lặp quét từng file trong thư mục
for file in "$DATASET_DIR"/*.sol; do
    
    # Lấy tên file (ví dụ: Token.sol -> Token)
    filename=$(basename -- "$file")
    contract_name="${filename%.*}"
    
    # Đường dẫn file kết quả riêng cho từng contract
    output_file="$RESULT_DIR/${contract_name}_res.json"

    echo "------------------------------------------------"
    echo "Dang chay fuzzing cho file: $filename"
    echo "Contract Name du kien: $contract_name"
    
    # 3. Chạy lệnh CrossFuzz (theo đúng cấu trúc CLI trong Readme)
    # python CrossFuzz.py [File] [ContractName] [Ver] [Depth] [Time] [OutFile] [SolcPath] [Args] [Dup]
    
    python3 CrossFuzz.py \
        "$file" \
        "$contract_name" \
        "$SOLC_VERSION" \
        5 \
        "$TIME_LIMIT" \
        "$output_file" \
        "$SOLC_BIN" \
        auto \
        0

    echo "Da luu ket qua tai: $output_file"
done

echo "------------------------------------------------"
echo "DA HOAN TAT CHAY DATASET!"
