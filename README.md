# Patch Việt hóa Zoo Tycoon: Complete Collection

**QUÁN GAME XÓM — bản thử chơi ổn ngày 05/11/2026**

Gói này chỉ chứa bản vá nhị phân (`.xdelta`), lớp hiển thị tiếng Việt và công cụ cài. **Không chứa game đầy đủ.** Bạn cần có Zoo Tycoon: Complete Collection tương thích của riêng mình. Không áp dụng cho các bản game khác: bộ cài sẽ kiểm tra SHA-256 trước khi ghi bất cứ file nào.

**[Tải gói patch ZIP v1.0.1](https://github.com/quangamexom/zoo-tycoon-complete-collection-viet-hoa-patch/archive/refs/tags/v1.0.1.zip)** hoặc bấm **Code → Download ZIP** trên trang repo.

## Cách cài trên Windows

1. Thoát game. Sao lưu toàn bộ thư mục game nếu bạn muốn có thêm một bản dự phòng.
2. Tải và giải nén [gói patch ZIP v1.0.1](https://github.com/quangamexom/zoo-tycoon-complete-collection-viet-hoa-patch/archive/refs/tags/v1.0.1.zip). Bộ giải mã `xdelta3.exe` đã đi kèm.
3. Mở PowerShell trong thư mục patch vừa giải nén và chạy:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Install-VietHoa.ps1 -GameDir 'D:\Games\Zoo Tycoon Complete Collection'
   ```

   Thay đường dẫn bằng thư mục game trên máy bạn. Có thể thêm `-XdeltaPath 'D:\Tools\xdelta3.exe'` nếu muốn dùng bản xdelta3 khác.
4. Mở `Zoo Tycoon Viet Hoa.cmd` trong thư mục game. Game khởi động trong cửa sổ 1024×768, không cần đổi System Locale hoặc dùng Locale Emulator.

Bộ cài **không sửa `zoo.exe`**. Nó tạo `BACKUP_BEFORE_VIET_HOA_<ngày giờ>` trong thư mục game, dựng và kiểm hash toàn bộ file vá trước khi chép. Nếu bản gốc khác phiên bản đã kiểm thử, bộ cài dừng và báo file không khớp. Bản game tương thích cần có `ijl15_org.dll` và `ztpatch.ini`; bộ cài sao chép lớp vá `ijl15.dll` đang có thành `ijl15_patch.dll` trước khi đặt lớp Unicode mới.

## Có gì trong bản vá

- Menu, bản đồ, tooltip, thông báo, hướng dẫn, kịch bản và bách khoa tiếng Việt theo các bảng dịch đã được kiểm tra.
- Lớp hiển thị Unicode cho dấu tiếng Việt; xử lý tên bản đồ và tên thú của một số bản lưu cũ.
- Mặc định cửa sổ 1024×768; zoom cảnh trong game chỉnh bằng nút `+` cạnh bản đồ nhỏ.

Một số tên riêng, chữ nằm trong ảnh và nội dung hiếm gặp có thể còn nguyên bản gốc. Nếu gặp lỗi, gửi ảnh, tên file save và màn hình đang mở để tái hiện.

## Lưu ý

Các file `.xdelta` chỉ áp dụng lên đúng các file gốc có mã SHA-256 trong `patch_manifest.json`. Repo không chứa DLL ngôn ngữ hay kho `.ztd` nguyên vẹn của game. Mã nguồn và nhật ký kỹ thuật được lưu riêng, không nằm trong gói patch công khai này.

`third_party/xdelta3.exe` là bản [xdelta3 3.0.11 chính thức](https://github.com/jmacd/xdelta-gpl/releases/tag/v3.0.11). Bản quyền GPL, nội dung giấy phép `third_party/COPYING-xdelta3.txt` và mã nguồn `third_party/xdelta3-3.0.11-source.tar.gz` đi kèm.
