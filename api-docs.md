# 📘 TÀI LIỆU API – HỆ THỐNG WORKNEST

> Phiên bản: 1.0  
> Ngày cập nhật: 25/05/2025  
> Người biên soạn: Giang Đoàn

---

## 🧭 GIỚI THIỆU

Hệ thống API WorkNest xây dựng theo chuẩn RESTful, cung cấp các chức năng:
- Đăng nhập, kiểm tra phiên
- Quản lý người dùng và phòng ban
- Upload ảnh đại diện

Mọi response đều trả về dạng `application/json`.

---

## 🔐 1. AUTHENTICATION

### 🔹 `POST /api/login`

Đăng nhập bằng email và mật khẩu.

#### Request (JSON):
```json
{
  "email": "demo@example.com",
  "password": "123456"
}
 ```

---

## 👤 2. USERS – Quản lý người dùng

---

### 🔹 `GET /api/users` – Danh sách người dùng

Lấy danh sách tất cả người dùng trong hệ thống.

#### Response:
```json
[
  {
    "id": 1,
    "name": "Nguyễn Văn A",
    "email": "a@example.com",
    "phone": "0912345678",
    "role": "admin",
    "avatar_url": "http://assets.worknest.local/avatars/user1.jpg"
  },
  {
    "id": 2,
    "name": "Trần Thị B",
    "email": "b@example.com",
    "phone": "0988123456",
    "role": "customer",
    "avatar_url": null
  }
]
 ```

🔹 GET /api/users/{id} – Chi tiết người dùng

Lấy thông tin chi tiết 1 người dùng theo ID.

```json
{
  "id": 1,
  "name": "Nguyễn Văn A",
  "email": "a@example.com",
  "phone": "0912345678",
  "role": "admin",
  "avatar_url": "http://assets.worknest.local/avatars/user1.jpg"
}
```

🔹 POST /api/users – Thêm mới người dùng

```json

{
  "name": "Nguyễn Văn A",
  "email": "a@example.com",
  "phone": "0912345678",
  "password": "123456",
  "confirm_password": "123456",
  "role": "customer"
}
```

Response:

```json
{
  "status": "success",
  "message": "User created successfully",
  "id": 3
}

```


🔹 PUT /api/users/{id} – Cập nhật người dùng
Cập nhật thông tin người dùng.

Request (JSON):
```json
{
  "name": "Nguyễn Văn A update",
  "phone": "0988999999",
  "role": "admin"
}
```

Response:
```json
{
  "status": "success",
  "message": "User updated"
}

```

🔹 DELETE /api/users/{id} – Xoá người dùng

Xóa một người dùng khỏi hệ thống theo ID.

Response:

```json
{
  "status": "success",
  "message": "User deleted"
}

```

