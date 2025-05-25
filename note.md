# 🧹 XÓA CACHE GIT (Chỉ xóa khỏi Git, không xóa khỏi thư mục)

## 🎯 Mục đích

- Xóa cache Git cho một hoặc nhiều file đang bị theo dõi (`tracked`)
- Giữ file lại trong thư mục, nhưng **xoá khỏi việc bị theo dõi bởi Git**
- Hữu ích khi bạn **thêm file đó vào `.gitignore`** nhưng Git vẫn đang theo dõi

---

## 🔸 Xóa một file khỏi cache Git

```bash
git rm --cached fe/vite.config.js
git rm --cached be/public/index.php
git commit -m "Remove tracked vite.config.js and index.php"

```

## 🔸 Xóa toàn bộ cache Git (bỏ theo dõi tất cả file)

```bash

git rm -r --cached .
git add .
git commit -m "Xóa cache Git và add lại toàn bộ file"

```

## 🔸 Cấu hình file .env trong be
```bash
UPLOAD_PATH_AVATAR=D:/laragon/www/work_nest/assets/avatars
AVATAR_BASE_URL=http://assets.worknest.local/avatars

đường dẫn phụ thuộc vị trí cài đặt
```

