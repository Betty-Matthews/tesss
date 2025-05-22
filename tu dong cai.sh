#!/bin/bash

# Hàm hiển thị thông báo
log_message() {
    echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Hàm kiểm tra lỗi
check_error() {
    if [ $? -ne 0 ]; then
        log_message "LỖI: $1"
        exit 1  # Thoát ngay khi có lỗi
    fi
}

# 1. Cài đặt gói unzip nếu chưa được cài đặt
if ! command -v unzip &> /dev/null; then
    log_message "Đang cài đặt gói unzip..."
    yum install unzip -y
    check_error "Không thể cài đặt gói unzip"
else
    log_message "Gói unzip đã được cài đặt."
fi

# 2. Di chuyển đến thư mục /home
log_message "Di chuyển đến thư mục /home..."
cd /home || { log_message "Không thể di chuyển đến thư mục /home"; exit 1; }

# 3. Tải file từ Dropbox
log_message "Đang tải file từ Dropbox..."
curl -L "https://www.dropbox.com/scl/fo/aquqcnofrs8ipqsmlgqz4/AMqjSwLmTuuH39adHIlaCbQ?rlkey=sh2779qzxfwj5oqv5sr7wa4kf&st=e3hm48wy&dl=1" -o downloaded_file.zip
check_error "Không thể tải file từ Dropbox"

# 4. Xác định loại file đã tải về
log_message "Kiểm tra loại file đã tải về..."
file_type=$(file -b downloaded_file.zip | cut -d' ' -f1)
log_message "Loại file: $file_type"

# 5. Giải nén file tải về dựa vào loại file
case "$file_type" in
    "Zip")
        log_message "Đang giải nén file ZIP..."
        unzip -o downloaded_file.zip
        check_error "Không thể giải nén file ZIP"
        ;;
    "gzip")
        log_message "Đang giải nén file TAR.GZ..."
        tar -xzf downloaded_file.zip
        check_error "Không thể giải nén file TAR.GZ"
        ;;
    "XZ")
        log_message "Đang giải nén file TAR.XZ..."
        tar -xJf downloaded_file.zip
        check_error "Không thể giải nén file TAR.XZ"
        ;;
    "tar")
        log_message "Đang giải nén file TAR..."
        tar -xf downloaded_file.zip
        check_error "Không thể giải nén file TAR"
        ;;
    *)
        log_message "File tải về không phải là file nén được hỗ trợ."
        exit 1
        ;;
esac

# 6. Tạo thư mục Desktop trong /root nếu chưa tồn tại
log_message "Chuẩn bị thư mục Desktop..."
mkdir -p /root/Desktop
check_error "Không thể tạo thư mục /root/Desktop"

# 7. Di chuyển các tệp và thư mục được chỉ định sang /root/Desktop (nếu tồn tại)
log_message "Di chuyển các tệp và thư mục được chỉ định sang /root/Desktop..."
for item in 0 1.txt 2 3 4 pay.zip; do
    if [ -e "/home/$item" ]; then
        mv "/home/$item" /root/Desktop/
        log_message "Đã di chuyển $item sang /root/Desktop"
    else
        log_message "Cảnh báo: Không tìm thấy $item trong thư mục /home"
    fi
done

# 8. Giải nén tất cả các file zip trong thư mục /home (nếu tồn tại)
log_message "Giải nén các file zip trong thư mục /home..."
for zipfile in cgalaxy.zip client.zip server.zip; do
    if [ -f "/home/$zipfile" ]; then
        dirname=$(basename "$zipfile" .zip)
        mkdir -p "/home/$dirname"
        log_message "Đang giải nén $zipfile vào thư mục /home/$dirname..."
        unzip -q -o "/home/$zipfile" -d "/home/$dirname"
        check_error "Không thể giải nén $zipfile"
    else
        log_message "Cảnh báo: Không tìm thấy $zipfile trong thư mục /home"
    fi
done

# 9. Giải nén file pay.zip trong thư mục /root/Desktop (nếu tồn tại)
if [ -f "/root/Desktop/pay.zip" ]; then
    log_message "Giải nén pay.zip trong thư mục /root/Desktop..."
    mkdir -p "/root/Desktop/pay"
    unzip -q -o "/root/Desktop/pay.zip" -d "/root/Desktop/pay"
    check_error "Không thể giải nén pay.zip"
else
    log_message "Cảnh báo: Không tìm thấy pay.zip trong thư mục /root/Desktop"
fi

log_message "Quá trình tự động hóa hoàn tất!"

# Hiển thị cấu trúc thư mục sau khi hoàn thành
log_message "Cấu trúc thư mục /home hiện tại:"
ls -la /home
log_message "Cấu trúc thư mục /root/Desktop hiện tại:"
ls -la /root/Desktop
