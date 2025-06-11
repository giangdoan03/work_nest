-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 11, 2025 at 01:29 AM
-- Server version: 8.0.30
-- PHP Version: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `work_nest`
--

-- --------------------------------------------------------

--
-- Table structure for table `bidding_steps`
--

CREATE TABLE `bidding_steps` (
  `id` int NOT NULL,
  `step_number` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '0: Chưa bắt đầu, 1: Đang xử lý, 2: Đã hoàn thành, 3: Bị hủy/bỏ qua'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bidding_steps`
--

INSERT INTO `bidding_steps` (`id`, `step_number`, `title`, `department`, `created_at`, `updated_at`, `status`) VALUES
(1, 1, 'Nhận nhu cầu của khách hàng', 'Khách hàng', '2025-06-05 03:50:22', '2025-06-05 03:50:22', 0),
(2, 2, 'Đánh giá tính khả thi', 'P.KD, P.DVKT', '2025-06-05 03:51:59', '2025-06-05 03:51:59', 0),
(3, 3, 'Chỉnh sửa tiêu đề bước', 'P.KD', '2025-06-05 03:52:32', '2025-06-10 15:35:02', 2),
(4, 4, 'Duyệt kế hoạch', 'Ban Giám đốc', '2025-06-05 03:52:39', '2025-06-10 16:04:53', 2),
(5, 5, 'Triển khai hồ sơ dự thầu', 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-05 03:52:46', '2025-06-10 16:04:53', 1),
(6, 6, 'Chấm thầu', 'Khách hàng', '2025-06-05 03:52:53', '2025-06-05 03:52:53', 0),
(7, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', 'P.KD', '2025-06-05 03:53:00', '2025-06-05 03:53:00', 0),
(8, 8, 'Triển khai ký hợp đồng bán', 'P.KD, P.TCKT, P.DVKT', '2025-06-05 03:53:07', '2025-06-05 03:53:07', 0),
(9, 9, 'Duyệt hợp đồng bán', 'Ban Giám đốc', '2025-06-05 03:53:14', '2025-06-05 03:53:14', 0),
(10, 10, 'Duyệt hợp đồng bán', 'Ban Giám đốc', '2025-06-10 15:18:36', '2025-06-10 15:18:36', 1);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `created_at`, `updated_at`) VALUES
(1, 'Điện thoại & Máy tính bảng', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(2, 'Laptop & Máy tính để bàn', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(3, 'Phụ kiện công nghệ', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(4, 'TV & Thiết bị gia dụng', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(5, 'Thời trang nam', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(6, 'Thời trang nữ', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(7, 'Giày dép & Túi xách', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(8, 'Mẹ & Bé', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(9, 'Sức khoẻ & Làm đẹp', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(10, 'Đồ dùng gia đình', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(11, 'Thể thao & Dã ngoại', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(12, 'Ô tô & Xe máy & Xe đạp', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(13, 'Sách, Văn phòng phẩm & Quà tặng', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(14, 'Đồ chơi & Giải trí', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(15, 'Nhà cửa & Đời sống', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(16, 'Thiết bị điện tử', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(17, 'Thiết bị y tế & Chăm sóc sức khoẻ', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(18, 'Nội thất & Trang trí', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(19, 'Đồng hồ & Trang sức', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(20, 'Dụng cụ & Thiết bị công nghiệp', '2025-04-12 23:49:55', '2025-04-12 23:49:55'),
(21, 'Thiết bị mạng & Camera giám sát', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(22, 'Vật liệu xây dựng & Công cụ', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(23, 'Đồ dùng học tập & Văn phòng', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(24, 'Thực phẩm & Đồ uống', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(25, 'Nhạc cụ & Thiết bị âm thanh', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(26, 'Dịch vụ & Voucher', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(27, 'Vé sự kiện & Giải trí', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(28, 'Phim ảnh & Âm nhạc', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(29, 'Mỹ phẩm & Chăm sóc cá nhân', '2025-04-12 23:50:08', '2025-04-12 23:50:08'),
(30, 'Quà lưu niệm & Thủ công mỹ nghệ', '2025-04-12 23:50:08', '2025-04-12 23:50:08');

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `id` int NOT NULL,
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `module_id` int NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `contracts`
--

CREATE TABLE `contracts` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` enum('draft','in_progress','pending_review','approved','completed','canceled') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `department_id` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `contracts`
--

INSERT INTO `contracts` (`id`, `title`, `content`, `status`, `department_id`, `assigned_to`, `start_date`, `end_date`, `created_at`, `updated_at`) VALUES
(1, 'Hợp đồng đã cập nhật', 'Chi tiết hợp đồng cung cấp dịch vụ A...', 'in_progress', 1, 3, '2025-06-01', '2025-12-31', '2025-05-26 04:37:38', '2025-05-26 04:38:33'),
(2, 'Hợp đồng cung cấp dịch vụ A2', 'Chi tiết hợp đồng cung cấp dịch vụ A2...', 'draft', 1, 3, '2025-06-01', '2025-12-31', '2025-05-26 04:42:49', '2025-05-26 04:42:49');

-- --------------------------------------------------------

--
-- Table structure for table `contract_steps`
--

CREATE TABLE `contract_steps` (
  `id` int NOT NULL,
  `contract_id` int NOT NULL,
  `step_no` int DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','in_progress','done') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `assigned_to` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `completed_at` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `contract_steps`
--

INSERT INTO `contract_steps` (`id`, `contract_id`, `step_no`, `name`, `status`, `assigned_to`, `start_date`, `due_date`, `completed_at`, `created_at`, `updated_at`) VALUES
(1, 1, 3, 'Cập nhật tài liệu xx', 'done', NULL, NULL, NULL, NULL, '2025-05-26 08:26:50', '2025-05-26 09:28:17'),
(3, 1, 2, 'Gửi báo giá mới', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 08:56:43', '2025-05-26 09:28:17'),
(4, 1, 7, 'Gửi báo giá 3', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 08:56:43', '2025-05-26 09:28:17'),
(5, 1, 5, 'Gửi báo giá 4', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 08:56:43', '2025-05-26 09:28:17'),
(6, 1, 1, 'Gửi báo giá mới', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 09:06:00', '2025-05-26 09:28:17'),
(7, 1, 10, 'Gửi báo giá 3', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 09:06:00', '2025-05-26 09:28:17'),
(8, 1, 9, 'Gửi báo giá 4', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 09:06:00', '2025-05-26 09:28:17'),
(9, 1, 6, 'Gửi báo giá 3', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 09:17:23', '2025-05-26 09:28:17'),
(10, 1, 8, 'Gửi báo giá mới', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 09:17:23', '2025-05-26 09:28:17'),
(11, 1, 11, 'Gửi báo giá 3', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 09:21:56', '2025-05-26 09:28:17'),
(12, 1, 4, 'Gửi báo giá mới', 'pending', NULL, NULL, NULL, NULL, '2025-05-26 09:21:56', '2025-05-26 09:28:17');

-- --------------------------------------------------------

--
-- Table structure for table `contract_step_files`
--

CREATE TABLE `contract_step_files` (
  `id` int NOT NULL,
  `step_id` int NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `uploaded_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `last_interaction` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Phòng Hành chính - Nhân sự', 'Cập nhật mô tả phòng ban', '2025-05-25 02:55:43', '2025-05-25 02:57:44'),
(2, 'Phòng Tài chính - Kế toán', 'Quản lý tài chính và kế toán', '2025-06-04 09:01:59', '2025-06-04 09:01:59'),
(3, 'Phòng Kinh doanh', 'Phụ trách phát triển kinh doanh', '2025-06-04 09:02:11', '2025-06-04 09:02:11'),
(4, 'Phòng Thương mại', 'Quản lý hợp đồng và thương mại', '2025-06-04 09:02:29', '2025-06-04 09:02:29'),
(5, 'Phòng Dịch vụ - Kỹ thuật', 'Hỗ trợ kỹ thuật và dịch vụ khách hàng', '2025-06-04 09:02:38', '2025-06-04 09:02:38');

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` int NOT NULL,
  `key_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `key_name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'product.view', 'Xem sản phẩm', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(2, 'product.create', 'Tạo sản phẩm', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(3, 'product.update', 'Cập nhật sản phẩm', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(4, 'product.delete', 'Xoá sản phẩm', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(5, 'category.view', 'Xem danh mục', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(6, 'category.create', 'Tạo danh mục', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(7, 'category.update', 'Cập nhật danh mục', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(8, 'category.delete', 'Xoá danh mục', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(9, 'business.view', 'Xem doanh nghiệp', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(10, 'business.create', 'Tạo doanh nghiệp', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(11, 'business.update', 'Cập nhật doanh nghiệp', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(12, 'business.delete', 'Xoá doanh nghiệp', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(13, 'person.view', 'Xem cá nhân', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(14, 'person.create', 'Tạo cá nhân', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(15, 'person.update', 'Cập nhật cá nhân', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(16, 'person.delete', 'Xoá cá nhân', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(17, 'store.view', 'Xem cửa hàng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(18, 'store.create', 'Tạo cửa hàng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(19, 'store.update', 'Cập nhật cửa hàng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(20, 'store.delete', 'Xoá cửa hàng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(21, 'event.view', 'Xem sự kiện', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(22, 'event.create', 'Tạo sự kiện', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(23, 'event.update', 'Cập nhật sự kiện', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(24, 'event.delete', 'Xoá sự kiện', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(25, 'qr.view', 'Xem QR Code', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(26, 'qr.create', 'Tạo QR Code', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(27, 'qr.update', 'Cập nhật QR Code', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(28, 'qr.delete', 'Xoá QR Code', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(29, 'loyalty.view', 'Xem chương trình loyalty', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(30, 'loyalty.create', 'Tạo chương trình loyalty', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(31, 'loyalty.update', 'Cập nhật chương trình loyalty', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(32, 'loyalty.delete', 'Xoá chương trình loyalty', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(33, 'user.view', 'Xem người dùng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(34, 'user.create', 'Tạo người dùng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(35, 'user.update', 'Cập nhật người dùng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(36, 'user.delete', 'Xoá người dùng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(37, 'setting.view', 'Xem cấu hình', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(38, 'setting.update', 'Cập nhật cấu hình', '2025-04-21 00:15:39', '2025-04-21 00:15:39');

-- --------------------------------------------------------

--
-- Table structure for table `persons`
--

CREATE TABLE `persons` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `first_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `video_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `social_links` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `job_title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `display_settings` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `persons`
--

INSERT INTO `persons` (`id`, `user_id`, `first_name`, `last_name`, `name`, `avatar`, `video_url`, `phone`, `email`, `website`, `country`, `address`, `social_links`, `job_title`, `bio`, `created_at`, `updated_at`, `display_settings`) VALUES
(1, 1, NULL, NULL, 'demo 1', 'http://assets.giang.test/image/1745030161_1629c049dd5304b986df.jpg', NULL, '0387409300', 'doangiang665@gmail.com', NULL, NULL, 'acb xyz', NULL, 'dev web', 'dev web', '2025-04-12 17:20:19', '2025-04-25 04:05:50', '{\"selectedTemplate\":\"tpl-3\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"1\",\"2\"],\"company\":\"selected\",\"selectedCompanies\":[\"1\"],\"store\":\"selected\",\"selectedStores\":[\"1\"],\"enableSurvey\":true,\"selectedSurveys\":[],\"enableOrderButton\":true,\"topProductsMode\":\"selected\",\"topProducts\":[\"2\",\"9\",\"5\"],\"productLinks\":[{\"platform\":\"Shopee\",\"url\":\"https://shopee.vn/\"},{\"platform\":\"Lazada\",\"url\":\"https://tiki.vn/\"},{\"platform\":\"Tiki\",\"url\":\"https://www.lazada.vn/\"}]}'),
(2, 1, NULL, NULL, 'chaiel', 'http://assets.giang.test/image/1745033604_a1290dbd357f8d81b784.jpg', NULL, '0387409300', 'chaiel@gmail.com', NULL, NULL, NULL, NULL, 'dev', 'dev', '2025-04-19 03:33:52', '2025-04-19 03:33:52', '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"2\",\"3\",\"4\",\"5\"],\"company\":\"selected\",\"selectedCompanies\":[\"1\"],\"store\":\"selected\",\"selectedStores\":[\"1\"]}'),
(3, 1, NULL, NULL, 'xxxxxxxxx', 'http://assets.giang.test/image/1746256163_85b41370090178cdcc1d.jpg', NULL, '0387409300', 'giang@gmail.com', NULL, NULL, NULL, NULL, 'dev', '', '2025-05-03 07:05:38', '2025-05-03 07:05:38', '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"1\"],\"company\":\"selected\",\"selectedCompanies\":[\"1\"],\"store\":\"selected\",\"selectedStores\":[\"6\"]}');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'super admin', 'Toàn quyền', '2025-04-21 00:06:00', '2025-04-21 00:06:00'),
(2, 'admin', 'Quản trị viên', '2025-04-21 00:06:00', '2025-04-21 00:06:00'),
(3, 'user', 'Người dùng', '2025-04-21 00:06:00', '2025-04-21 00:06:00');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `id` int NOT NULL,
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`id`, `role_id`, `permission_id`, `created_at`) VALUES
(4, 3, 1, '2025-04-21 00:35:31'),
(5, 3, 2, '2025-04-21 00:35:31'),
(6, 3, 3, '2025-04-21 00:35:31'),
(7, 1, 1, '2025-04-21 21:48:03'),
(8, 1, 2, '2025-04-21 21:48:03'),
(9, 1, 7, '2025-04-21 21:48:03'),
(10, 1, 18, '2025-04-21 21:48:03');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `user_id`, `key`, `value`, `created_at`, `updated_at`) VALUES
(1, 1, 'xxxxx', '2222', '2025-05-04 15:10:39', '2025-05-04 15:10:39'),
(2, 1, 'vvvvv', '222211111', '2025-05-04 15:10:48', '2025-05-04 15:10:48');

-- --------------------------------------------------------

--
-- Table structure for table `step_templates`
--

CREATE TABLE `step_templates` (
  `id` int NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `step_no` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `step_templates`
--

INSERT INTO `step_templates` (`id`, `name`, `step_no`, `created_at`, `updated_at`) VALUES
(1, 'Gửi báo giá mới', 3, '2025-05-26 08:47:22', '2025-05-26 08:48:12'),
(2, 'Gửi báo giá 3', 3, '2025-05-26 08:49:18', '2025-05-26 08:49:18'),
(3, 'Gửi báo giá 4', 4, '2025-05-26 08:49:29', '2025-05-26 08:49:29');

-- --------------------------------------------------------

--
-- Table structure for table `tasks`
--

CREATE TABLE `tasks` (
  `id` int NOT NULL,
  `bidding_step_id` int DEFAULT NULL,
  `parent_id` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `assigned_to` int NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('todo','doing','done','overdue') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'todo',
  `linked_type` enum('bidding','contract','internal') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'internal',
  `linked_id` int DEFAULT NULL,
  `step_code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` int NOT NULL,
  `priority` enum('low','normal','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'normal',
  `comments_count` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `bidding_step_id`, `parent_id`, `title`, `description`, `assigned_to`, `start_date`, `end_date`, `status`, `linked_type`, `linked_id`, `step_code`, `created_by`, `priority`, `comments_count`, `created_at`, `updated_at`) VALUES
(1, NULL, NULL, 'Thiết kế hồ sơ thầu', 'Chuẩn bị file bản vẽ và hồ sơ năng lực', 5, NULL, '2025-06-15', 'doing', 'bidding', 3, 'bidding_step_02', 1, 'normal', 0, '2025-06-04 01:23:15', '2025-06-04 01:24:15'),
(2, NULL, NULL, 'Thiết kế hồ sơ thầu', 'Mô tả công việc thiết kế hồ sơ thầu', 3, NULL, '2025-06-16', 'doing', 'bidding', 1, 'contract_step_01', 2, 'high', 1, '2025-06-04 01:37:15', '2025-06-04 01:37:15'),
(3, NULL, NULL, 'Nghiên cứu yêu cầu khách hàng', 'Mô tả công việc nghiên cứu yêu cầu khách hàng', 9, NULL, '2025-06-15', 'todo', 'contract', 1, 'internal_step_04', 1, 'high', 3, '2025-06-04 01:37:24', '2025-06-04 01:37:24'),
(4, NULL, NULL, 'Gửi báo giá', 'Mô tả công việc gửi báo giá', 8, NULL, '2025-06-17', 'overdue', 'internal', 1, 'contract_step_05', 2, 'normal', 1, '2025-06-04 01:37:33', '2025-06-04 01:37:33'),
(5, NULL, NULL, 'Làm rõ kỹ thuật', 'Mô tả công việc làm rõ kỹ thuật', 1, NULL, '2025-06-16', 'todo', 'bidding', 2, 'contract_step_06', 3, 'normal', 5, '2025-06-04 01:37:42', '2025-06-04 01:37:42'),
(6, NULL, NULL, 'Ký hợp đồng nguyên tắc', 'Mô tả công việc ký hợp đồng nguyên tắc', 1, NULL, '2025-06-17', 'doing', 'internal', 1, 'contract_step_06', 1, 'high', 0, '2025-06-04 01:37:52', '2025-06-04 01:37:52'),
(7, NULL, NULL, 'Chuẩn bị hồ sơ thanh toán', 'Mô tả công việc chuẩn bị hồ sơ thanh toán', 10, NULL, '2025-06-19', 'todo', 'bidding', 2, 'contract_step_02', 2, 'normal', 1, '2025-06-04 01:38:01', '2025-06-04 01:38:01'),
(8, NULL, NULL, 'Lên kế hoạch triển khai', 'Mô tả công việc lên kế hoạch triển khai', 5, NULL, '2025-06-21', 'overdue', 'internal', 5, 'contract_step_01', 1, 'high', 3, '2025-06-04 01:38:09', '2025-06-04 01:38:09'),
(9, NULL, NULL, 'Phân công nhiệm vụ', 'Mô tả công việc phân công nhiệm vụ', 10, NULL, '2025-06-17', 'doing', 'internal', 4, 'bidding_step_05', 1, 'high', 4, '2025-06-04 01:38:16', '2025-06-04 01:38:16'),
(10, NULL, NULL, 'Mua sắm vật tư', 'Mô tả công việc mua sắm vật tư', 10, NULL, '2025-06-14', 'overdue', 'bidding', 3, 'contract_step_06', 2, 'high', 5, '2025-06-04 01:38:26', '2025-06-04 01:38:26'),
(11, NULL, NULL, 'Lắp đặt thiết bị', 'Mô tả công việc lắp đặt thiết bị', 4, NULL, '2025-06-11', 'doing', 'bidding', 4, 'internal_step_04', 2, 'low', 1, '2025-06-04 01:38:34', '2025-06-04 01:38:34'),
(12, NULL, NULL, 'Nghiệm thu nội bộ', 'Mô tả công việc nghiệm thu nội bộ', 8, NULL, '2025-06-11', 'overdue', 'contract', 2, 'bidding_step_04', 1, 'high', 0, '2025-06-04 01:38:43', '2025-06-04 01:38:43'),
(13, NULL, NULL, 'Bàn giao cho khách hàng', 'Mô tả công việc bàn giao cho khách hàng', 2, NULL, '2025-06-23', 'overdue', 'contract', 2, 'bidding_step_03', 3, 'normal', 4, '2025-06-04 01:38:51', '2025-06-04 01:38:51'),
(14, NULL, NULL, 'Bảo trì định kỳ', 'Mô tả công việc bảo trì định kỳ', 7, NULL, '2025-06-09', 'todo', 'internal', 2, 'bidding_step_02', 2, 'low', 0, '2025-06-04 01:38:59', '2025-06-04 01:38:59'),
(15, NULL, NULL, 'Tổng hợp hồ sơ hoàn công', 'Mô tả công việc tổng hợp hồ sơ hoàn công', 3, NULL, '2025-06-14', 'doing', 'contract', 3, 'internal_step_01', 1, 'normal', 3, '2025-06-04 01:39:07', '2025-06-04 01:39:07'),
(16, NULL, NULL, 'Đối soát công nợ', 'Mô tả công việc đối soát công nợ', 9, NULL, '2025-06-19', 'doing', 'bidding', 5, 'contract_step_06', 1, 'low', 2, '2025-06-04 01:39:15', '2025-06-04 01:39:15'),
(17, NULL, NULL, 'Đánh giá nội bộ', 'Mô tả công việc đánh giá nội bộ', 5, NULL, '2025-06-17', 'overdue', 'contract', 2, 'contract_step_05', 1, 'low', 2, '2025-06-04 01:39:24', '2025-06-04 01:39:24'),
(18, NULL, NULL, 'Gửi báo cáo tiến độ', 'Mô tả công việc gửi báo cáo tiến độ', 4, NULL, '2025-06-22', 'overdue', 'internal', 1, 'bidding_step_03', 3, 'normal', 4, '2025-06-04 01:39:30', '2025-06-04 01:39:30'),
(19, NULL, NULL, 'Tiếp nhận phản hồi', 'Mô tả công việc tiếp nhận phản hồi', 8, NULL, '2025-06-23', 'done', 'contract', 1, 'internal_step_02', 2, 'normal', 2, '2025-06-04 01:39:40', '2025-06-04 01:39:40'),
(20, NULL, NULL, 'Cập nhật hồ sơ kỹ thuật', 'Mô tả công việc cập nhật hồ sơ kỹ thuật', 10, NULL, '2025-06-19', 'done', 'bidding', 5, 'bidding_step_01', 3, 'normal', 4, '2025-06-04 01:39:48', '2025-06-04 01:39:48'),
(21, NULL, NULL, 'Đăng ký bảo hành', 'Mô tả công việc đăng ký bảo hành', 1, NULL, '2025-06-14', 'overdue', 'bidding', 2, 'contract_step_04', 3, 'high', 0, '2025-06-04 01:39:57', '2025-06-04 01:39:57'),
(22, NULL, 3, 'Sửa tên subtask', 'Thiết kế giao diện cho phần chi tiết', 9, NULL, '2025-06-15', '', 'internal', NULL, NULL, 1, '', 0, '2025-06-04 19:29:35', '2025-06-05 05:40:49'),
(23, NULL, NULL, 'Đăng ký bảo hành - test task cha', 'Mô tả công việc đăng ký bảo hành', 1, NULL, '2025-06-14', 'overdue', 'bidding', 2, 'contract_step_04', 3, 'high', 0, '2025-06-04 19:32:24', '2025-06-04 19:32:24'),
(24, 1, NULL, 'Đăng ký bảo hành - test task cha', 'Mô tả công việc đăng ký bảo hành', 1, NULL, '2025-06-14', 'overdue', 'bidding', 2, 'bidding_step_04', 3, 'high', 0, '2025-06-04 21:03:42', '2025-06-04 21:03:42'),
(25, 1, NULL, 'task thuoc buoc 1 , goi thau', 'Mô tả công việc đăng ký bảo hành', 1, NULL, '2025-06-14', 'overdue', 'bidding', 2, 'bidding_step_05', 3, 'high', 0, '2025-06-04 21:06:16', '2025-06-04 21:06:16'),
(26, NULL, 3, 'Thiết kế giao diện phụ - task con 3', 'Thiết kế giao diện cho phần chi tiết', 9, NULL, '2025-06-15', 'todo', 'internal', NULL, NULL, 1, '', 0, '2025-06-05 05:38:39', '2025-06-05 05:38:39'),
(27, 1, NULL, 'Task thuộc bước 1 - Gói thầu có ngay bat dau - ngay ket thuc', 'Mô tả công việc đăng ký bảo hành', 1, '2025-06-10', '2025-06-14', 'overdue', 'bidding', 2, 'bidding_step_05', 3, 'high', 0, '2025-06-05 06:16:42', '2025-06-05 06:16:42'),
(28, NULL, 3, 'Thiết kế giao diện phụ - task con 3 có ngay bat dau - ngay ket thuc', 'Thiết kế giao diện cho phần chi tiết', 9, '2025-06-10', '2025-06-15', 'todo', 'internal', NULL, NULL, 1, '', 0, '2025-06-05 06:19:14', '2025-06-05 06:19:14');

-- --------------------------------------------------------

--
-- Table structure for table `task_comments`
--

CREATE TABLE `task_comments` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `user_id` int NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_comments`
--

INSERT INTO `task_comments` (`id`, `task_id`, `user_id`, `content`, `created_at`, `updated_at`) VALUES
(1, 3, 8, 'Đã nhận task và đang xử lý', '2025-06-04 10:06:02', '2025-06-04 10:06:02'),
(3, 3, 8, 'Đã cập nhật nội dung comment', '2025-06-04 10:06:17', '2025-06-04 10:12:40'),
(4, 3, 8, 'Đã nhận task và đang xử lý 44444', '2025-06-04 10:10:06', '2025-06-04 10:10:06'),
(5, 3, 8, 'Đây là comment kèm file', '2025-06-04 10:24:49', '2025-06-04 10:24:49'),
(6, 3, 8, 'Đây là comment kèm file', '2025-06-04 10:25:28', '2025-06-04 10:25:28'),
(7, 3, 8, 'Đây là comment kèm file 2222', '2025-06-04 10:25:51', '2025-06-04 10:25:51'),
(8, 3, 8, 'Đây là comment kèm file 2222', '2025-06-04 10:30:02', '2025-06-04 10:30:02'),
(9, 3, 8, 'Đây là comment kèm file 2222', '2025-06-04 10:30:41', '2025-06-04 10:30:41'),
(10, 3, 8, 'Đây là comment kèm file 2222 66666', '2025-06-04 10:31:08', '2025-06-04 10:31:08'),
(11, 3, 8, 'Đây là comment kèm file 3333333', '2025-06-04 10:35:20', '2025-06-04 10:35:20'),
(12, 3, 8, 'Đây là comment kèm file 8888', '2025-06-04 10:38:15', '2025-06-04 10:38:15'),
(13, 3, 8, 'Đây là comment kèm file 9999', '2025-06-04 19:03:31', '2025-06-04 19:03:31'),
(14, 3, 8, 'Đây là comment kèm file 9999', '2025-06-04 19:03:59', '2025-06-04 19:03:59');

-- --------------------------------------------------------

--
-- Table structure for table `task_files`
--

CREATE TABLE `task_files` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_files`
--

INSERT INTO `task_files` (`id`, `task_id`, `file_name`, `file_path`, `uploaded_by`, `created_at`, `updated_at`) VALUES
(1, 3, 'mã dân trí url.png', 'http://assets.worknest.local/image/1749057928_53ccf528637fdf0e2753.png', 8, '2025-06-04 10:25:28', '2025-06-04 17:25:28'),
(2, 3, 'mã dân trí url.png', 'http://assets.worknest.local/image/1749057951_f6af6958796b4f784575.png', 8, '2025-06-04 10:25:51', '2025-06-04 17:25:51'),
(3, 3, 'mã dân trí url.png', 'http://assets.worknest.local/image/1749058202_a87879f3acabe56569b8.png', 8, '2025-06-04 10:30:02', '2025-06-04 17:30:02'),
(4, 3, '無題ファイル.pdf', 'http://assets.worknest.local/image/1749058241_48f3df4fabac26fd662e.pdf', 8, '2025-06-04 10:30:41', '2025-06-04 17:30:41'),
(5, 3, '無題ファイル.pdf', 'http://assets.worknest.local/image/1749058268_452e37c0690b378d55fe.pdf', 8, '2025-06-04 10:31:08', '2025-06-04 17:31:08'),
(6, 3, '20250521805.pdf', 'http://assets.worknest.local/image/1749058520_d76b25ed4c6df7e81de9.pdf', 8, '2025-06-04 10:35:20', '2025-06-04 17:35:20'),
(7, 3, 'youtube.png', 'http://assets.worknest.local/files/1749058695_5d6e504e75601e256df4.png', 8, '2025-06-04 10:38:15', '2025-06-04 17:38:15'),
(8, 3, 'youtube.png', 'http://assets.worknest.local/files/1749089039_9852f7169f0d58483621.png', 8, '2025-06-04 19:03:59', '2025-06-05 02:03:59'),
(9, 5, 'youtube.png', 'http://assets.worknest.local/files/1749127936_5303eae0ad80c4b5bc44.png', 8, '2025-06-05 05:52:16', '2025-06-05 12:52:16');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int UNSIGNED NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `department_id` int DEFAULT NULL,
  `role_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `created_at`, `updated_at`, `name`, `phone`, `avatar`, `role`, `department_id`, `role_id`) VALUES
(1, 'demo@example.com', '$2y$10$X0AYs8k7Dw8fbMqF9DzxiuBhQzGzu.ehudtC.2SWOjA4tsTZK0sYG', '2025-04-07 18:49:01', '2025-06-04 15:09:55', 'Nguyễn Văn A sửa', '0988888888', 'avatars/1749049795_4087ec00b95ac222533a.png', 'user', 1, 2),
(3, 'superadmin@example.com', '$2y$10$X0AYs8k7Dw8fbMqF9DzxiuBhQzGzu.ehudtC.2SWOjA4tsTZK0sYG', '2025-04-20 14:02:38', '2025-05-25 09:51:46', 'Super Admin', '0988888888', NULL, 'super admin', 2, 1),
(4, 'nguyenvana@example.com', '$2y$10$NrYPWmcRo3yBFGYmTzh4pumJyQQ0zBAOHejM59sZlJj1wCtyCUpBO', '2025-05-26 04:33:21', '2025-05-26 04:33:21', 'Nguyễn Văn A', '0909123456', NULL, 'customer', NULL, NULL),
(5, 'a@worknest.vn', '$2y$10$y9WQWckMJCEVQbqG0PNSCum.x7fNlxAJK7RqwxZvlaxBVZRtre96W', '2025-06-04 09:10:50', '2025-06-04 09:10:50', 'Nguyễn Văn A', '0911111111', NULL, 'customer', 1, NULL),
(6, 'b@worknest.vn', '$2y$10$1LWsovHhrQhpuY3tvcl5Bu6nu8cWhi4U51LIHhlp7pTD3yBeY/Gz.', '2025-06-04 09:11:21', '2025-06-04 09:11:21', 'Trần Thị B', '0911111112', NULL, 'customer', 1, NULL),
(7, 'c@worknest.vn', '$2y$10$0M2AJM7k/CXzGKJCeeEh1.g2tFjFCZfeOLDGKqGgm3dUHqqpNtciW', '2025-06-04 09:11:44', '2025-06-04 09:11:44', 'Lê Văn C', '0911111113', NULL, 'customer', 2, NULL),
(8, 'd@worknest.vn', '$2y$10$Myza0k5wayRch9i2Vxxit.i26Uauc7mPyPMUJpARLSnLzQ8H79fi2', '2025-06-04 09:12:07', '2025-06-04 09:12:07', 'Phạm Thị D', '0911111114', NULL, 'customer', 2, NULL),
(9, 't@worknest.vn', '$2y$10$hGqQg.IGey/1/3a6Dt/3rOQKKdPgz2U787lWDghxeDqCmCk30v7SW', '2025-06-04 09:12:52', '2025-06-04 09:12:52', 'Bùi Minh T', '0911111115', NULL, 'customer', 3, NULL),
(10, 'l@worknest.vn', '$2y$10$In9Y8TToyh9hICfylJG.Iesgd1mvrE4L./GTSwgcuXX8zXe.tGqM2', '2025-06-04 09:13:10', '2025-06-04 09:13:10', 'Nguyễn Thị L', '0911111116', NULL, 'customer', 3, NULL),
(11, 'h@worknest.vn', '$2y$10$HVsxejThJCOYfidLz.xreOCpRGZp8QI001kHhekDGq9tVFW0TWv0K', '2025-06-04 09:13:37', '2025-06-04 09:13:37', 'Vũ Văn H', '0911111117', NULL, 'customer', 4, NULL),
(12, 'hq@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Đào Quang H', '0911111118', NULL, 'user', 4, NULL),
(13, 'bich@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Trần Thị Bích', '0911111119', NULL, 'user', 5, NULL),
(14, 'tuan@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Mai Văn Tuấn', '0911111120', NULL, 'user', 5, NULL),
(15, 'phuc@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Lê Hồng Phúc', '0911111121', NULL, 'user', 1, NULL),
(16, 'hiep@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Nguyễn Văn Hiệp', '0911111122', NULL, 'user', 1, NULL),
(17, 'huong@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Trần Thanh Hương', '0911111123', NULL, 'user', 2, NULL),
(18, 'thang@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Đinh Hữu Thắng', '0911111124', NULL, 'user', 2, NULL),
(19, 'trang@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Phạm Thu Trang', '0911111125', NULL, 'user', 3, NULL),
(20, 'hai@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Ngô Minh Hải', '0911111126', NULL, 'user', 3, NULL),
(21, 'mai@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Vũ Thị Mai', '0911111127', NULL, 'user', 4, NULL),
(22, 'huy@worknest.vn', '$2y$10$8qPYhSpBnDSx5t9admiFmO92DYr/yXNseT4b/qd6sBxxnv2n8r9Iq', '2025-06-04 16:15:57', '2025-06-08 09:26:31', 'Nguyễn Khắc Huy', '0911111128', NULL, 'user', 4, NULL),
(23, 'loan@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Bùi Thị Loan', '0911111129', NULL, 'user', 5, NULL),
(24, 'tri@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-06-04 16:15:57', 'Lê Minh Trí', '0911111130', NULL, 'user', 5, NULL),
(25, 'testuser@gmail.com', '$2y$10$HOa3vdg9C.Xhs92CPRvMPOdSWMgctBsukYFiRwsJY6OhYnE6XDLK2', '2025-06-08 09:27:07', '2025-06-08 09:27:07', 'user1', '0912345688', NULL, 'customer', NULL, NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bidding_steps`
--
ALTER TABLE `bidding_steps`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user` (`user_id`);

--
-- Indexes for table `contracts`
--
ALTER TABLE `contracts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `contract_steps`
--
ALTER TABLE `contract_steps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contract_id` (`contract_id`);

--
-- Indexes for table `contract_step_files`
--
ALTER TABLE `contract_step_files`
  ADD PRIMARY KEY (`id`),
  ADD KEY `step_id` (`step_id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `persons`
--
ALTER TABLE `persons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `step_templates`
--
ALTER TABLE `step_templates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tasks`
--
ALTER TABLE `tasks`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_comments`
--
ALTER TABLE `task_comments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_files`
--
ALTER TABLE `task_files`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bidding_steps`
--
ALTER TABLE `bidding_steps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `contracts`
--
ALTER TABLE `contracts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `contract_steps`
--
ALTER TABLE `contract_steps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `contract_step_files`
--
ALTER TABLE `contract_step_files`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `persons`
--
ALTER TABLE `persons`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `role_permissions`
--
ALTER TABLE `role_permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `step_templates`
--
ALTER TABLE `step_templates`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `tasks`
--
ALTER TABLE `tasks`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `task_comments`
--
ALTER TABLE `task_comments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `task_files`
--
ALTER TABLE `task_files`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `contract_steps`
--
ALTER TABLE `contract_steps`
  ADD CONSTRAINT `contract_steps_ibfk_1` FOREIGN KEY (`contract_id`) REFERENCES `contracts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `contract_step_files`
--
ALTER TABLE `contract_step_files`
  ADD CONSTRAINT `contract_step_files_ibfk_1` FOREIGN KEY (`step_id`) REFERENCES `contract_steps` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
