#!/bin/bash

# Hàm hiển thị thông báo
log_message() {
    echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Hàm kiểm tra lỗi
check_error() {
    if [ $? -ne 0 ]; then
        log_message "LỖI: $1"
        exit 1
    fi
}

# 1. Cài đặt gói unzip
log_message "Đang cài đặt gói unzip..."
yum install unzip -y &>/dev/null
check_error "Không thể cài đặt gói unzip"

# 2. Di chuyển đến thư mục /home
log_message "Di chuyển đến thư mục /home..."
cd /home
check_error "Không thể di chuyển đến thư mục /home"

# 3. Tải file từ Dropbox
log_message "Đang tải file từ Dropbox..."
curl -L "https://www.dropbox.com/scl/fo/aquqcnofrs8ipqsmlgqz4/AMqjSwLmTuuH39adHIlaCbQ?rlkey=sh2779qzxfwj5oqv5sr7wa4kf&st=e3hm48wy&dl=1" -o downloaded_file.tar.gz --silent
check_error "Không thể tải file từ Dropbox"

# 4. Giải nén file tải về
if [ -f downloaded_file.zip ]; then
    log_message "Đang giải nén downloaded_file.zip..."
    unzip -q downloaded_file.zip
    check_error "Không thể giải nén downloaded_file.zip"
elif [ -f downloaded_file.tar.gz ]; then
    log_message "Đang giải nén downloaded_file.tar.gz..."
    tar -xzf downloaded_file.tar.gz
    check_error "Không thể giải nén downloaded_file.tar.gz"
else
    log_message "Không tìm thấy file để giải nén"
fi

# 5. Tạo thư mục Desktop trong /root nếu chưa tồn tại
log_message "Chuẩn bị thư mục Desktop..."
mkdir -p /root/Desktop
check_error "Không thể tạo thư mục /root/Desktop"

# 6. Di chuyển các tệp và thư mục được chỉ định sang /root/Desktop
log_message "Di chuyển các tệp và thư mục được chỉ định sang /root/Desktop..."
for item in 0 1.txt 2 3 4 pay.zip; do
    if [ -e "/home/$item" ]; then
        mv "/home/$item" /root/Desktop/
        check_error "Không thể di chuyển $item sang /root/Desktop"
    else
        log_message "Cảnh báo: Không tìm thấy $item trong thư mục /home"
    fi
done

# 7. Giải nén tất cả các file zip trong thư mục /home
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

# 8. Giải nén file pay.zip trong thư mục /root/Desktop
if [ -f "/root/Desktop/pay.zip" ]; then
    log_message "Giải nén pay.zip trong thư mục /root/Desktop..."
    mkdir -p "/root/Desktop/pay"
    unzip -q -o "/root/Desktop/pay.zip" -d "/root/Desktop/pay"
    check_error "Không thể giải nén pay.zip"
else
    log_message "Cảnh báo: Không tìm thấy pay.zip trong thư mục /root/Desktop"
fi

log_message "Quá trình tự động hóa hoàn tất thành công!"

# Hiển thị cấu trúc thư mục sau khi hoàn thành
log_message "Cấu trúc thư mục /home hiện tại:"
ls -la /home
log_message "Cấu trúc thư mục /root/Desktop hiện tại:"
ls -la /root/Desktop
