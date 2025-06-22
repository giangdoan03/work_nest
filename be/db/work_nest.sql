-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 22, 2025 at 07:05 AM
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
-- Table structure for table `biddings`
--

CREATE TABLE `biddings` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `customer_id` int NOT NULL,
  `estimated_cost` decimal(18,2) DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `assigned_to` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `biddings`
--

INSERT INTO `biddings` (`id`, `title`, `description`, `customer_id`, `estimated_cost`, `status`, `assigned_to`, `start_date`, `end_date`, `created_at`, `updated_at`) VALUES
(2, 'Gói thầu cung cấp turbine cho Nhiệt điện Quảng Ninh', 'Turbine hơi công suất 300MW cho tổ máy số 3', 1, 4500000000.00, 'pending', 4, '2025-06-15', '2025-07-30', '2025-06-11 04:16:44', '2025-06-11 04:16:44'),
(3, 'Gói thầu xây dựng nhà điều hành Nhiệt điện Duyên Hải', 'Thi công hoàn thiện trụ sở ban quản lý nhà máy', 2, 1200000000.00, 'submitted', 23, '2025-06-20', '2025-08-10', '2025-06-11 04:16:50', '2025-06-11 04:16:50'),
(4, 'Cung cấp hệ thống điều khiển trung tâm cho Nhiệt điện Hải Phòng', 'SCADA & HMI cho toàn nhà máy', 3, 2500000000.00, 'awarded', 22, '2025-06-10', '2025-07-15', '2025-06-11 04:16:56', '2025-06-11 04:16:56'),
(5, 'Cung cấp ống khói chịu nhiệt cao', 'Ống khói chịu nhiệt độ trên 1000°C cho Nhiệt điện Vĩnh Tân', 4, 1750000000.00, 'pending', 24, '2025-06-25', '2025-07-30', '2025-06-11 04:17:01', '2025-06-11 04:17:01'),
(6, 'Gói thầu bảo trì định kỳ năm 2025 – Nhiệt điện Mông Dương', 'Bảo trì tổ máy số 2 theo tiêu chuẩn EVN', 5, 980000000.00, 'submitted', NULL, '2025-06-20', '2025-07-05', '2025-06-11 04:17:10', '2025-06-11 04:17:10'),
(7, 'Cung cấp vật tư phòng cháy chữa cháy – Nhiệt điện Ô Môn', 'Thiết bị PCCC tiêu chuẩn châu Âu', 6, 800000000.00, 'pending', 18, '2025-06-22', '2025-07-10', '2025-06-11 04:17:15', '2025-06-11 04:17:15'),
(8, 'Cải tạo hệ thống cấp than – Nhiệt điện Na Dương', 'Băng tải và phễu tiếp nhận than đá', 7, 1350000000.00, 'pending', 6, '2025-06-24', '2025-08-05', '2025-06-11 04:17:20', '2025-06-11 04:17:20'),
(9, 'Lắp đặt hệ thống điện chiếu sáng – Nhiệt điện Sông Hậu', 'Chiếu sáng toàn khu vực sân và hành lang', 8, 460000000.00, 'awarded', 17, '2025-06-28', '2025-07-25', '2025-06-11 04:17:26', '2025-06-11 04:17:26'),
(10, 'Cung cấp hệ thống xử lý nước thải công nghiệp – Nhiệt điện Phú Mỹ', 'Thiết bị xử lý hóa lý và sinh học', 9, 2600000000.00, 'pending', 21, '2025-07-01', '2025-08-15', '2025-06-11 04:17:31', '2025-06-11 04:17:31'),
(11, 'Gói thầu thuê ngoài dịch vụ an ninh – Nhiệt điện Thái Bình 2', 'Thuê bảo vệ 24/7 trong 12 tháng', 10, 500000000.00, 'submitted', 8, '2025-06-15', '2025-07-15', '2025-06-11 04:17:36', '2025-06-11 04:17:36'),
(27, 'test 2', 'test 2', 1, 6000000000.00, 'awarded', 16, '2025-06-22', '2025-06-30', '2025-06-22 05:06:25', '2025-06-22 05:06:25'),
(28, 'tesst 555555555', 'tesst 555555555', 1, 900000000.00, 'awarded', 23, '2025-06-22', '2025-06-30', '2025-06-22 05:09:50', '2025-06-22 05:09:50'),
(29, 'test hợp đồng mới', 'test hợp đồng mới', 1, 95420000000.00, 'awarded', 19, '2025-06-22', '2025-06-30', '2025-06-22 05:16:54', '2025-06-22 05:16:54'),
(30, 'test 7777777777', 'test 7777777777', 1, 9542000000.00, 'awarded', 20, '2025-06-22', '2025-06-30', '2025-06-22 05:20:16', '2025-06-22 05:20:16'),
(31, 'gói thầu mới 1', 'gói thầu mới 1', 1, 30000000000000.00, 'awarded', 24, '2025-06-22', '2025-06-30', '2025-06-22 05:22:46', '2025-06-22 05:22:46'),
(32, 'gói thầu mới 222', 'gói thầu mới 222', 1, 599231321313.00, 'awarded', 6, '2025-06-22', '2025-06-30', '2025-06-22 05:23:23', '2025-06-22 05:23:23');

-- --------------------------------------------------------

--
-- Table structure for table `bidding_steps`
--

CREATE TABLE `bidding_steps` (
  `id` int NOT NULL,
  `bidding_id` int DEFAULT NULL,
  `step_number` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '0: Chưa bắt đầu, 1: Đang xử lý, 2: Đã hoàn thành, 3: Bị hủy/bỏ qua',
  `customer_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bidding_steps`
--

INSERT INTO `bidding_steps` (`id`, `bidding_id`, `step_number`, `title`, `department`, `created_at`, `updated_at`, `status`, `customer_id`) VALUES
(1, NULL, 1, 'Nhận nhu cầu của khách hàng', 'Khách hàng', '2025-06-05 03:50:22', '2025-06-11 10:10:37', 0, 1),
(2, NULL, 2, 'Đánh giá tính khả thi', 'P.KD, P.DVKT', '2025-06-05 03:51:59', '2025-06-11 10:10:37', 0, 4),
(3, NULL, 3, 'Chỉnh sửa tiêu đề bước', 'P.KD', '2025-06-05 03:52:32', '2025-06-11 10:10:37', 2, 10),
(4, NULL, 4, 'Duyệt kế hoạch', 'Ban Giám đốc', '2025-06-05 03:52:39', '2025-06-11 10:10:37', 2, 2),
(5, NULL, 5, 'Triển khai hồ sơ dự thầu', 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-05 03:52:46', '2025-06-11 10:10:37', 1, 1),
(6, NULL, 6, 'Chấm thầu', 'Khách hàng', '2025-06-05 03:52:53', '2025-06-11 10:10:37', 0, 4),
(7, NULL, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', 'P.KD', '2025-06-05 03:53:00', '2025-06-11 10:10:37', 0, 4),
(8, NULL, 8, 'Triển khai ký hợp đồng bán', 'P.KD, P.TCKT, P.DVKT', '2025-06-05 03:53:07', '2025-06-11 10:10:37', 0, 5),
(9, NULL, 9, 'Duyệt hợp đồng bán', 'Ban Giám đốc', '2025-06-05 03:53:14', '2025-06-11 10:10:37', 0, 3),
(10, NULL, 10, 'Duyệt hợp đồng bán', 'Ban Giám đốc', '2025-06-10 15:18:36', '2025-06-11 10:10:37', 1, 10),
(11, 1, 1, 'Nhận nhu cầu khách hàng', 'Khách hàng', '2025-06-16 09:06:25', '2025-06-21 15:25:52', 2, NULL),
(12, 1, 2, 'Đánh giá tính khả thi', 'P.KD, P.DVKT', '2025-06-16 09:06:25', '2025-06-21 15:25:52', 1, NULL),
(13, 1, 3, 'Lập kế hoạch triển khai', 'P.KD, P.DVKT', '2025-06-16 09:06:25', '2025-06-16 09:06:25', 0, NULL),
(14, 1, 4, 'Duyệt kế hoạch', 'Ban Giám đốc', '2025-06-16 09:06:25', '2025-06-16 09:06:25', 0, NULL),
(15, 1, 5, 'Triển khai hồ sơ dự thầu', 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-16 09:06:25', '2025-06-16 09:06:25', 0, NULL),
(16, 1, 6, 'Chấm thầu', 'Khách hàng', '2025-06-16 09:06:25', '2025-06-16 09:06:25', 0, NULL),
(17, 1, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', 'P.KD', '2025-06-16 09:06:25', '2025-06-16 09:06:25', 0, NULL),
(18, 1, 8, 'Triển khai ký hợp đồng bán', 'P.KD, P.TCKT, P.DVKT', '2025-06-16 09:06:25', '2025-06-16 09:06:25', 0, NULL),
(19, 1, 9, 'Duyệt hợp đồng bán', 'Ban Giám đốc', '2025-06-16 09:06:25', '2025-06-16 09:06:25', 0, NULL),
(20, 1, 1, 'Nhận nhu cầu khách hàng', 'Khách hàng', '2025-06-20 08:34:44', '2025-06-21 15:25:41', 2, NULL),
(21, 1, 2, 'Đánh giá tính khả thi', 'P.KD, P.DVKT', '2025-06-20 08:34:44', '2025-06-20 08:34:44', 0, NULL),
(22, 1, 3, 'Lập kế hoạch triển khai', 'P.KD, P.DVKT', '2025-06-20 08:34:44', '2025-06-20 08:34:44', 0, NULL),
(23, 1, 4, 'Duyệt kế hoạch', 'Ban Giám đốc', '2025-06-20 08:34:44', '2025-06-20 08:34:44', 0, NULL),
(24, 1, 5, 'Triển khai hồ sơ dự thầu', 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-20 08:34:44', '2025-06-20 08:34:44', 0, NULL),
(25, 1, 6, 'Chấm thầu', 'Khách hàng', '2025-06-20 08:34:44', '2025-06-20 08:34:44', 0, NULL),
(26, 1, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', 'P.KD', '2025-06-20 08:34:44', '2025-06-20 08:34:44', 0, NULL),
(27, 1, 8, 'Triển khai ký hợp đồng bán', 'P.KD, P.TCKT, P.DVKT', '2025-06-20 08:34:44', '2025-06-20 08:34:44', 0, NULL),
(28, 1, 9, 'Duyệt hợp đồng bán', 'Ban Giám đốc', '2025-06-20 08:34:44', '2025-06-20 08:34:44', 0, NULL),
(29, 12, 1, 'Nhận nhu cầu khách hàng  Khách hàng', 'KT', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, 1),
(30, 12, 2, 'Đánh giá tính khả thi', '', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, 1),
(31, 12, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(32, 12, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(33, 12, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(34, 12, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(35, 12, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(36, 12, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(37, 12, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(38, 12, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(39, 12, 9, 'Duyệt hợp đồng bán xxxx', '[\"Phòng Kinh doanh\"]', '2025-06-21 01:51:18', '2025-06-21 01:51:18', 0, NULL),
(40, 13, 1, 'Nhận nhu cầu khách hàng  Khách hàng', 'KT', '2025-06-22 03:09:31', '2025-06-22 03:09:31', 0, 1),
(41, 13, 2, 'Đánh giá tính khả thi', '', '2025-06-22 03:09:31', '2025-06-22 03:09:31', 0, 1),
(42, 13, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(43, 13, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(44, 13, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(45, 13, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(46, 13, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(47, 13, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(48, 13, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(49, 13, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(50, 13, 9, 'Duyệt hợp đồng bán xxxx', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:09:32', '2025-06-22 03:09:32', 0, NULL),
(51, 14, 1, 'Nhận nhu cầu khách hàng  Khách hàng', 'KT', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(52, 14, 2, 'Đánh giá tính khả thi', '', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(53, 14, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 1, 1),
(54, 14, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(55, 14, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(56, 14, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(57, 14, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(58, 14, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(59, 14, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(60, 14, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(61, 14, 9, 'Duyệt hợp đồng bán xxxx', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:18:58', '2025-06-22 03:18:58', 0, 1),
(62, 15, 1, 'Nhận nhu cầu khách hàng  Khách hàng', 'KT', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(63, 15, 2, 'Đánh giá tính khả thi', '', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(64, 15, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 1, 1),
(65, 15, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(66, 15, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(67, 15, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(68, 15, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(69, 15, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(70, 15, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(71, 15, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(72, 15, 9, 'Duyệt hợp đồng bán xxxx', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:22:22', '2025-06-22 03:22:22', 0, 1),
(73, 8, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 1, 7),
(74, 8, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 0, 7),
(75, 8, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 0, 7),
(76, 8, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 0, 7),
(77, 8, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 0, 7),
(78, 8, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 0, 7),
(79, 8, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 0, 7),
(80, 8, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 0, 7),
(81, 8, 9, 'Duyệt hợp đồng bán xxxx', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:43:42', '2025-06-22 03:43:42', 0, 7),
(82, 10, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 1, 9),
(83, 10, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 0, 9),
(84, 10, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 0, 9),
(85, 10, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 0, 9),
(86, 10, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 0, 9),
(87, 10, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 0, 9),
(88, 10, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 0, 9),
(89, 10, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 0, 9),
(90, 10, 9, 'Duyệt hợp đồng bán xxxx', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:10', '2025-06-22 03:44:10', 0, 9),
(91, 11, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 1, 10),
(92, 11, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 0, 10),
(93, 11, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 0, 10),
(94, 11, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 0, 10),
(95, 11, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 0, 10),
(96, 11, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 0, 10),
(97, 11, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 0, 10),
(98, 11, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 0, 10),
(99, 11, 9, 'Duyệt hợp đồng bán xxxx', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:20', '2025-06-22 03:44:20', 0, 10),
(100, 5, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:51', '2025-06-22 03:45:07', 2, 4),
(101, 5, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-06-22 03:45:07', 1, 4),
(102, 5, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-06-22 03:44:51', 0, 4),
(103, 5, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:51', '2025-06-22 03:44:51', 0, 4),
(104, 5, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:51', '2025-06-22 03:44:51', 0, 4),
(105, 5, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:51', '2025-06-22 03:44:51', 0, 4),
(106, 5, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:51', '2025-06-22 03:44:51', 0, 4),
(107, 5, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-06-22 03:44:51', 0, 4),
(108, 5, 9, 'Duyệt hợp đồng bán xxxx', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:51', '2025-06-22 03:44:51', 0, 4),
(109, 2, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:48:05', '2025-06-22 06:36:22', 2, 1),
(110, 2, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:48:05', '2025-06-22 06:36:27', 2, 1),
(111, 2, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:48:05', '2025-06-22 06:36:27', 1, 1),
(112, 2, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:48:05', '2025-06-22 06:36:33', 2, 1),
(113, 2, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:48:05', '2025-06-22 06:36:33', 1, 1),
(114, 2, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:48:05', '2025-06-22 03:48:05', 0, 1),
(115, 2, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:48:05', '2025-06-22 03:48:05', 0, 1),
(116, 2, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:48:05', '2025-06-22 03:48:05', 0, 1),
(117, 2, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:48:05', '2025-06-22 03:48:05', 0, 1),
(118, 3, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 1, 2),
(119, 3, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 0, 2),
(120, 3, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 0, 2),
(121, 3, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 0, 2),
(122, 3, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 0, 2),
(123, 3, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 0, 2),
(124, 3, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 0, 2),
(125, 3, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 0, 2),
(126, 3, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:56:49', '2025-06-22 03:56:49', 0, 2),
(127, 4, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 1, 3),
(128, 4, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 0, 3),
(129, 4, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 0, 3),
(130, 4, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 0, 3),
(131, 4, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 0, 3),
(132, 4, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 0, 3),
(133, 4, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 0, 3),
(134, 4, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 0, 3),
(135, 4, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:57:46', '2025-06-22 03:57:46', 0, 3),
(158, 26, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 1, 1),
(159, 26, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 0, 1),
(160, 26, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 0, 1),
(161, 26, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 0, 1),
(162, 26, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 0, 1),
(163, 26, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 0, 1),
(164, 26, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 0, 1),
(165, 26, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 0, 1),
(166, 26, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:04:45', '2025-06-22 05:04:45', 0, 1),
(169, 27, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 1, 1),
(170, 27, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 0, 1),
(171, 27, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 0, 1),
(172, 27, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 0, 1),
(173, 27, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 0, 1),
(174, 27, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 0, 1),
(175, 27, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 0, 1),
(176, 27, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 0, 1),
(177, 27, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:06:25', '2025-06-22 05:06:25', 0, 1),
(189, 29, 1, 'Nhận nhu cầu khách hàng  Khách hàng', 'KT', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(190, 29, 2, 'Đánh giá tính khả thi', '', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(191, 29, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 1, 1),
(192, 29, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(193, 29, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(194, 29, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(195, 29, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(196, 29, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(197, 29, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(198, 29, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(199, 29, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:16:54', '2025-06-22 05:16:54', 0, 1),
(200, 30, 1, 'Nhận nhu cầu khách hàng  Khách hàng', 'KT', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(201, 30, 2, 'Đánh giá tính khả thi', '', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(202, 30, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 1, 1),
(203, 30, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(204, 30, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(205, 30, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(206, 30, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(207, 30, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(208, 30, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(209, 30, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(210, 30, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:20:16', '2025-06-22 05:20:16', 0, 1),
(213, 31, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 1, 1),
(214, 31, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 0, 1),
(215, 31, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 0, 1),
(216, 31, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 0, 1),
(217, 31, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 0, 1),
(218, 31, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 0, 1),
(219, 31, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 0, 1),
(220, 31, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 0, 1),
(221, 31, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:22:47', '2025-06-22 05:22:47', 0, 1),
(224, 32, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:23:23', '2025-06-22 06:43:52', 2, 1),
(225, 32, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-06-22 06:43:57', 2, 1),
(226, 32, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-06-22 06:44:10', 2, 1),
(227, 32, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:23:23', '2025-06-22 06:44:15', 2, 1),
(228, 32, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:23:23', '2025-06-22 06:44:15', 1, 1),
(229, 32, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:23:23', '2025-06-22 05:23:23', 0, 1),
(230, 32, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:23:23', '2025-06-22 05:23:23', 0, 1),
(231, 32, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-06-22 05:23:23', 0, 1),
(232, 32, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:23:23', '2025-06-22 05:23:23', 0, 1),
(233, 6, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 1, 5),
(234, 6, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 0, 5),
(235, 6, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 0, 5),
(236, 6, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 0, 5),
(237, 6, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 0, 5),
(238, 6, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 0, 5),
(239, 6, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 0, 5),
(240, 6, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 0, 5),
(241, 6, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-22 06:55:02', '2025-06-22 06:55:02', 0, 5);

-- --------------------------------------------------------

--
-- Table structure for table `bidding_step_templates`
--

CREATE TABLE `bidding_step_templates` (
  `id` int NOT NULL,
  `step_number` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bidding_step_templates`
--

INSERT INTO `bidding_step_templates` (`id`, `step_number`, `title`, `department`, `created_at`, `updated_at`) VALUES
(1, 1, 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14'),
(2, 2, 'Đánh giá tính khả thi xxx', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14'),
(3, 3, 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14'),
(4, 4, 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14'),
(5, 5, 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14'),
(6, 6, 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14'),
(7, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14'),
(8, 8, 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14'),
(9, 9, 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-16 16:06:14');

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
  `code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `status` tinyint NOT NULL DEFAULT '0',
  `department_id` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `id_customer` int DEFAULT NULL,
  `bidding_id` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by` int DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `contracts`
--

INSERT INTO `contracts` (`id`, `title`, `code`, `content`, `status`, `department_id`, `assigned_to`, `id_customer`, `bidding_id`, `start_date`, `end_date`, `created_at`, `updated_at`, `updated_by`, `description`) VALUES
(30, '3565756756', '#5465435435634', NULL, 4, NULL, 22, 8, 9, '2025-06-08', '2025-06-17', '2025-06-21 04:41:38', '2025-06-21 18:17:53', NULL, '467657yfdghhk'),
(31, 'hợp đồng mới 4', '#5222222', NULL, 4, NULL, 20, 8, 9, '2025-06-09', '2025-06-18', '2025-06-21 14:24:12', '2025-06-22 02:10:13', NULL, '2343565879sdfgsdfsdfdfsf'),
(32, 'hợp đồng mới 5', '#44444444', NULL, 4, NULL, 14, 3, 4, '2025-06-09', '2025-06-18', '2025-06-21 14:56:49', '2025-06-22 02:06:28', NULL, '3432544656fghfgbcvbvbvc'),
(33, 'hợp đồng mới', '#6666666666666666', NULL, 3, NULL, 22, 1, 29, '2025-06-22', '2025-06-30', '2025-06-22 06:34:46', '2025-06-22 06:34:46', NULL, 'ưerrewrrrwwr');

-- --------------------------------------------------------

--
-- Table structure for table `contract_steps`
--

CREATE TABLE `contract_steps` (
  `id` int NOT NULL,
  `contract_id` int NOT NULL,
  `customer_id` int DEFAULT NULL,
  `step_number` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` tinyint DEFAULT '0',
  `assigned_to` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `completed_at` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `department` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `contract_steps`
--

INSERT INTO `contract_steps` (`id`, `contract_id`, `customer_id`, `step_number`, `title`, `status`, `assigned_to`, `start_date`, `due_date`, `completed_at`, `created_at`, `updated_at`, `department`) VALUES
(259, 30, NULL, 10, 'Đặt hàng NCC', 1, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 14:23:24', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]'),
(260, 30, NULL, 11, 'Duyệt đặt hàng', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"Ban Giám đốc\"]'),
(261, 30, NULL, 12, 'Triển khai hợp đồng mua', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]'),
(262, 30, NULL, 13, 'Duyệt hợp đồng mua', 1, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:42:00', '[\"Ban Giám đốc\"]'),
(263, 30, NULL, 14, 'Thanh toán hợp đồng mua', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.TM\", \"P.TCKT\"]'),
(264, 30, NULL, 15, 'Kiểm tra hàng hóa', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.TM\"]'),
(265, 30, NULL, 16, 'Nghiệm thu', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]'),
(266, 30, NULL, 17, 'Thông báo lỗi hàng', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.TM\"]'),
(267, 30, NULL, 18, 'Nhập kho hàng hóa', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.KHNS\", \"P.TCKT\"]'),
(268, 30, NULL, 19, 'Xuất kho hàng hóa', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.KD\", \"P.TCKT\"]'),
(269, 30, NULL, 20, 'Duyệt phiếu xuất', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"Ban Giám đốc\"]'),
(270, 30, NULL, 21, 'Giao hàng', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]'),
(271, 30, NULL, 22, 'Nghiệm thu từ phía KH', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"Khách hàng\"]'),
(272, 30, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]'),
(273, 30, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]'),
(274, 30, NULL, 25, 'Thanh toán', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"Khách hàng\"]'),
(275, 30, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 0, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-21 04:41:38', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]'),
(276, 31, NULL, 10, 'Đặt hàng NCC', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:08:41', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]'),
(277, 31, NULL, 11, 'Duyệt đặt hàng', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:08:52', '[\"Ban Giám đốc\"]'),
(278, 31, NULL, 12, 'Triển khai hợp đồng mua', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:02', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]'),
(279, 31, NULL, 13, 'Duyệt hợp đồng mua', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:05', '[\"Ban Giám đốc\"]'),
(280, 31, NULL, 14, 'Thanh toán hợp đồng mua', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:08', '[\"P.TM\", \"P.TCKT\"]'),
(281, 31, NULL, 15, 'Kiểm tra hàng hóa', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:11', '[\"P.TM\"]'),
(282, 31, NULL, 16, 'Nghiệm thu', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:14', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]'),
(283, 31, NULL, 17, 'Thông báo lỗi hàng', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:17', '[\"P.TM\"]'),
(284, 31, NULL, 18, 'Nhập kho hàng hóa', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:20', '[\"P.KHNS\", \"P.TCKT\"]'),
(285, 31, NULL, 19, 'Xuất kho hàng hóa', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:23', '[\"P.KD\", \"P.TCKT\"]'),
(286, 31, NULL, 20, 'Duyệt phiếu xuất', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:28', '[\"Ban Giám đốc\"]'),
(287, 31, NULL, 21, 'Giao hàng', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:31', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]'),
(288, 31, NULL, 22, 'Nghiệm thu từ phía KH', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:35', '[\"Khách hàng\"]'),
(289, 31, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:38', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]'),
(290, 31, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:48', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]'),
(291, 31, NULL, 25, 'Thanh toán', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:51', '[\"Khách hàng\"]'),
(292, 31, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-22 02:09:54', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]'),
(293, 32, NULL, 10, 'Đặt hàng NCC', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:38:36', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]'),
(294, 32, NULL, 11, 'Duyệt đặt hàng', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:38:42', '[\"Ban Giám đốc\"]'),
(295, 32, NULL, 12, 'Triển khai hợp đồng mua', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:38:46', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]'),
(296, 32, NULL, 13, 'Duyệt hợp đồng mua', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:38:49', '[\"Ban Giám đốc\"]'),
(297, 32, NULL, 14, 'Thanh toán hợp đồng mua', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:38:53', '[\"P.TM\", \"P.TCKT\"]'),
(298, 32, NULL, 15, 'Kiểm tra hàng hóa', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:38:56', '[\"P.TM\"]'),
(299, 32, NULL, 16, 'Nghiệm thu', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:38:59', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]'),
(300, 32, NULL, 17, 'Thông báo lỗi hàng', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:02', '[\"P.TM\"]'),
(301, 32, NULL, 18, 'Nhập kho hàng hóa', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:05', '[\"P.KHNS\", \"P.TCKT\"]'),
(302, 32, NULL, 19, 'Xuất kho hàng hóa', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:09', '[\"P.KD\", \"P.TCKT\"]'),
(303, 32, NULL, 20, 'Duyệt phiếu xuất', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:12', '[\"Ban Giám đốc\"]'),
(304, 32, NULL, 21, 'Giao hàng', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:15', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]'),
(305, 32, NULL, 22, 'Nghiệm thu từ phía KH', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:18', '[\"Khách hàng\"]'),
(306, 32, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:21', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]'),
(307, 32, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:24', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]'),
(308, 32, NULL, 25, 'Thanh toán', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:28', '[\"Khách hàng\"]'),
(309, 32, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 2, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-21 17:39:32', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]'),
(310, 33, NULL, 10, 'Đặt hàng NCC', 2, NULL, NULL, NULL, '2025-06-22', '2025-06-22 06:34:46', '2025-06-22 06:35:06', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]'),
(311, 33, NULL, 11, 'Duyệt đặt hàng', 1, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:35:06', '[\"Ban Giám đốc\"]'),
(312, 33, NULL, 12, 'Triển khai hợp đồng mua', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]'),
(313, 33, NULL, 13, 'Duyệt hợp đồng mua', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"Ban Giám đốc\"]'),
(314, 33, NULL, 14, 'Thanh toán hợp đồng mua', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.TM\", \"P.TCKT\"]'),
(315, 33, NULL, 15, 'Kiểm tra hàng hóa', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.TM\"]'),
(316, 33, NULL, 16, 'Nghiệm thu', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]'),
(317, 33, NULL, 17, 'Thông báo lỗi hàng', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.TM\"]'),
(318, 33, NULL, 18, 'Nhập kho hàng hóa', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.KHNS\", \"P.TCKT\"]'),
(319, 33, NULL, 19, 'Xuất kho hàng hóa', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.KD\", \"P.TCKT\"]'),
(320, 33, NULL, 20, 'Duyệt phiếu xuất', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"Ban Giám đốc\"]'),
(321, 33, NULL, 21, 'Giao hàng', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]'),
(322, 33, NULL, 22, 'Nghiệm thu từ phía KH', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"Khách hàng\"]'),
(323, 33, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]'),
(324, 33, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]'),
(325, 33, NULL, 25, 'Thanh toán', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"Khách hàng\"]'),
(326, 33, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 0, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-22 06:34:46', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]');

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
-- Table structure for table `contract_step_templates`
--

CREATE TABLE `contract_step_templates` (
  `id` int UNSIGNED NOT NULL,
  `step_number` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `department` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `contract_step_templates`
--

INSERT INTO `contract_step_templates` (`id`, `step_number`, `title`, `department`, `created_at`, `updated_at`) VALUES
(1, 10, 'Đặt hàng NCC', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(2, 11, 'Duyệt đặt hàng', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(3, 12, 'Triển khai hợp đồng mua', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(4, 13, 'Duyệt hợp đồng mua', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(5, 14, 'Thanh toán hợp đồng mua', '[\"P.TM\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(6, 15, 'Kiểm tra hàng hóa', '[\"P.TM\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(7, 16, 'Nghiệm thu', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(8, 17, 'Thông báo lỗi hàng', '[\"P.TM\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(9, 18, 'Nhập kho hàng hóa', '[\"P.KHNS\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(10, 19, 'Xuất kho hàng hóa', '[\"P.KD\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(11, 20, 'Duyệt phiếu xuất', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(12, 21, 'Giao hàng', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(13, 22, 'Nghiệm thu từ phía KH', '[\"Khách hàng\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(14, 23, 'Xử lý sai lệch hoặc chứng từ', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(15, 24, 'Hỏi hồ sơ thanh quyết toán', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(16, 25, 'Thanh toán', '[\"Khách hàng\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21'),
(17, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]', '2025-06-20 23:49:21', '2025-06-20 23:49:21');

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
  `customer_group` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `assigned_to` int DEFAULT NULL,
  `last_interaction` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `name`, `phone`, `email`, `address`, `city`, `customer_group`, `avatar`, `assigned_to`, `last_interaction`, `created_at`, `updated_at`) VALUES
(1, 'Tập đoàn Điện lực Việt Nam (EVN) ', '02422210000', 'contact@evn.com.vn', '11 Cửa Bắc, Ba Đình', 'Hà Nội', 'khách cũ', '/uploads/evn.jpg', 6, '2025-06-13', '2025-06-11 02:10:10', '2025-06-22 06:46:30'),
(2, 'Công ty Nhiệt điện Phả Lại', '02203713901', 'info@plaipower.vn', 'Phả Lại, Chí Linh', 'Hải Dương', 'tiềm năng', '/uploads/phalai.jpg', 5, '2025-06-18', '2025-06-11 02:10:22', '2025-06-11 16:18:23'),
(3, 'Nhà máy nhiệt điện thái bình', '02033855600', 'ubpower@evn.com.vn', 'Uông Bí, Quảng Ninh', 'Đà Nẵng', 'thử nghiệm', '/uploads/uongbi.jpg', 5, '2025-06-19', '2025-06-11 02:10:29', '2025-06-22 06:47:08'),
(4, 'Công ty Nhiệt điện Cần Thơ', '02923836411', 'cantho@evn.com.vn', 'Ô Môn, Cần Thơ', 'Cần Thơ', 'tiềm năng', '/uploads/cantho.jpg', 23, '2025-06-20', '2025-06-11 02:10:35', '2025-06-20 09:13:13'),
(5, 'Công ty Nhiệt điện Quảng Ninh', '02033655355', 'qnpower@evn.com.vn', 'Cẩm Phả, Quảng Ninh', 'Quảng Ninh', 'vip', '/uploads/quangninh.jpg', 1, '2025-06-21', '2025-06-11 02:10:41', '2025-06-11 16:44:52'),
(6, 'Nhà máy nhiệt điện Duyên Hải', '02943923999', 'duyenhai@evn.com.vn', 'Duyên Hải, Trà Vinh', 'Trà Vinh', 'khách mới', '/uploads/duyenhai.jpg', 1, '2025-06-12', '2025-06-11 02:10:47', '2025-06-11 16:45:59'),
(7, 'Công ty Nhiệt điện Vĩnh Tân', '02523695252', 'vinhtan@evn.com.vn', 'Tuy Phong, Bình Thuận', 'Bình Thuận', 'tiềm năng', '/uploads/vinhtan.jpg', 20, '2025-06-30', '2025-06-11 02:10:53', '2025-06-20 09:13:29'),
(8, 'Công ty Nhiệt điện Nghi Sơn 1', '02373898888', 'nghison1@evn.com.vn', 'Hải Hà, Thanh Hóa', 'Thanh Hóa', 'khách cũ', '/uploads/nghison1.jpg', 4, '2025-06-14', '2025-06-11 02:10:58', '2025-06-11 16:51:18'),
(9, 'Công ty Nhiệt điện Hải Phòng', '02253717171', 'haiphongpower@evn.com.vn', 'Thủy Nguyên, Hải Phòng', 'Hải Phòng', 'vip', '/uploads/haiphong.jpg', 1, NULL, '2025-06-11 02:11:04', '2025-06-11 09:22:51'),
(10, 'Công ty Nhiệt điện Mông Dương', '02033933777', 'mongduong@evn.com.vn', 'Cẩm Phả, Quảng Ninh', 'Quảng Ninh', 'khách mới', '/uploads/mongduong.jpg', 5, NULL, '2025-06-11 02:11:09', '2025-06-11 09:22:51');

-- --------------------------------------------------------

--
-- Table structure for table `customer_transactions`
--

CREATE TABLE `customer_transactions` (
  `id` int NOT NULL,
  `customer_id` int NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `interaction_time` datetime DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customer_transactions`
--

INSERT INTO `customer_transactions` (`id`, `customer_id`, `type`, `content`, `interaction_time`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 5, 'call', 'Gọi điện trao đổi gói dịch vụ', '2025-06-10 10:30:00', 2, '2025-06-11 02:43:50', '2025-06-11 02:43:50'),
(2, 5, 'call', 'Gọi điện trao đổi gói dịch vụ', '2025-06-10 10:30:00', 2, '2025-06-11 03:12:06', '2025-06-11 03:12:06'),
(3, 2, 'call', 'trao đổi kỹ thuật', '2025-06-11 22:53:03', 2, '2025-06-11 15:53:17', '2025-06-11 15:53:17'),
(4, 1, 'call', 'trao đổi kxy thuật', '2025-06-11 22:54:38', 2, '2025-06-11 15:54:52', '2025-06-11 15:54:52'),
(5, 1, 'email', 'trao đổi mua hàng', '2025-06-19 22:54:53', 2, '2025-06-11 15:55:16', '2025-06-11 15:55:16'),
(6, 1, 'meeting', 'gặp mặt lãnh đạo', '2025-06-26 22:55:16', 2, '2025-06-11 15:55:33', '2025-06-11 15:55:33'),
(7, 2, 'meeting', 'xxxxxx', '2025-06-26 23:09:56', 2, '2025-06-11 16:10:05', '2025-06-11 16:10:05'),
(8, 1, 'call', 'trao đổi 2', '2025-06-12 23:17:06', 2, '2025-06-11 16:17:17', '2025-06-11 16:17:17'),
(9, 2, 'call', 'trao đổi 2', '2025-06-18 23:18:07', 2, '2025-06-11 16:18:20', '2025-06-11 16:18:20'),
(10, 3, 'call', 'trao đổi 3', '2025-06-19 23:18:34', 2, '2025-06-11 16:18:46', '2025-06-11 16:18:46'),
(11, 3, 'email', 'đã trao đổi', '2025-06-11 23:19:12', 2, '2025-06-11 16:19:28', '2025-06-11 16:19:28'),
(12, 3, 'meeting', '', '2025-06-19 23:20:07', 2, '2025-06-11 16:20:11', '2025-06-11 16:20:11'),
(13, 4, 'email', 'trao đổi ok', '2025-06-11 23:24:19', 2, '2025-06-11 16:24:28', '2025-06-11 16:24:28'),
(14, 4, 'meeting', '', '2025-06-20 23:24:38', 2, '2025-06-11 16:24:44', '2025-06-11 16:24:44'),
(15, 5, 'email', 'ok', '2025-06-21 23:44:47', 2, '2025-06-11 16:44:52', '2025-06-11 16:44:52'),
(16, 6, 'email', 'ok', '2025-06-12 23:45:54', 2, '2025-06-11 16:45:59', '2025-06-11 16:45:59'),
(17, 7, 'call', 'ok2', '2025-06-30 23:46:04', 2, '2025-06-11 16:46:15', '2025-06-11 16:46:15'),
(18, 1, 'meeting', '', '2025-06-25 23:49:35', 2, '2025-06-11 16:49:40', '2025-06-11 16:49:40'),
(19, 1, 'call', 'we', '2025-06-13 23:50:47', 2, '2025-06-11 16:50:57', '2025-06-11 16:50:57'),
(20, 8, 'email', 'ok', '2025-06-14 23:51:05', 2, '2025-06-11 16:51:18', '2025-06-11 16:51:18');

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
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` int DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `visibility` enum('private','department','public') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'private',
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_size` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `documents`
--

INSERT INTO `documents` (`id`, `title`, `file_path`, `department_id`, `uploaded_by`, `visibility`, `file_type`, `file_size`, `created_at`, `updated_at`, `tags`) VALUES
(1, 'Báo cáo Q2 đã cập nhật', 'documents/1749798305_37045c936642c36152e8.png', 3, 1, 'public', 'image/png', 528057, '2025-06-13 07:05:05', '2025-06-13 07:27:04', 'báo cáo, quý 2'),
(2, 'Báo cáo tài chính', 'documents/1749799608_3bbef2158709ab8061f4.png', 3, 1, 'public', 'image/png', 528057, '2025-06-13 07:26:48', '2025-06-13 07:26:48', 'tài chính, 2025');

-- --------------------------------------------------------

--
-- Table structure for table `document_permissions`
--

CREATE TABLE `document_permissions` (
  `id` int NOT NULL,
  `document_id` int NOT NULL,
  `shared_with_type` enum('user','department') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `shared_with_id` int NOT NULL,
  `permission_type` enum('view','edit','download') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'view',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `document_permissions`
--

INSERT INTO `document_permissions` (`id`, `document_id`, `shared_with_type`, `shared_with_id`, `permission_type`, `created_at`, `updated_at`) VALUES
(3, 1, 'user', 5, 'edit', '2025-06-13 07:14:22', '2025-06-13 09:14:57'),
(4, 1, 'department', 2, 'download', '2025-06-13 07:14:22', '2025-06-13 07:14:22'),
(5, 1, 'user', 5, 'view', '2025-06-13 07:20:13', '2025-06-13 07:20:13'),
(6, 1, 'department', 1, 'download', '2025-06-13 07:20:13', '2025-06-13 07:20:13'),
(7, 1, 'user', 1, 'view', '2025-06-13 07:20:31', '2025-06-13 07:20:31'),
(9, 1, 'user', 133, 'view', '2025-06-13 07:23:20', '2025-06-13 07:23:20'),
(10, 1, 'department', 1, 'download', '2025-06-13 07:23:20', '2025-06-13 07:23:20'),
(11, 1, 'user', 1, 'view', '2025-06-13 07:26:53', '2025-06-13 07:26:53'),
(12, 1, 'department', 1, 'download', '2025-06-13 07:26:53', '2025-06-13 07:26:53'),
(13, 1, 'user', 12, 'view', '2025-06-13 09:04:00', '2025-06-13 09:04:00');

-- --------------------------------------------------------

--
-- Table structure for table `document_settings`
--

CREATE TABLE `document_settings` (
  `id` int NOT NULL,
  `key` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `document_settings`
--

INSERT INTO `document_settings` (`id`, `key`, `value`, `updated_at`) VALUES
(1, 'default_visibility', 'pdf,docx,xlsx,pptx', '2025-06-13 22:39:39'),
(2, 'max_file_size_mb', '10', '2025-06-13 21:43:35'),
(3, 'allowed_file_types', 'pdf,docx,xlsx,png,jpg', '2025-06-13 21:43:35'),
(4, 'max_file_size', '5', '2025-06-13 22:48:25'),
(5, 'allowed_types', 'pdf,docx,xlsx,zip', '2025-06-13 22:47:45'),
(6, 'folder_structure', 'year_month', '2025-06-13 22:51:47'),
(7, 'upload_roles', '[\"admin\",\"manager\",\"staff\"]', '2025-06-13 22:48:41'),
(8, 'view_roles', '[\"admin\",\"manager\",\"staff\"]', '2025-06-13 22:48:41');

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
(2, 1, 'vvvvv', '222211111', '2025-05-04 15:10:48', '2025-05-04 15:10:48'),
(3, 1, 'bidding_steps', '{\"steps\":[{\"step_number\":1,\"title\":\"Nhận nhu cầu khách hàng  Khách hàng\",\"department\":\"KT\",\"department_ids\":[\"2\",\"3\",\"4\"]},{\"step_number\":2,\"title\":\"Đánh giá tính khả thi\",\"department_ids\":[\"2\",\"3\"]}]}', '2025-06-16 07:01:08', '2025-06-16 08:24:24');

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
(4, 'nguyenvana@example.com', '$2y$10$n65TNehIFvx11oCJ2IbjXeiyDXWe9haW0VMv6UvFhMzctFOu1Ptd.', '2025-05-26 04:33:21', '2025-06-21 15:32:53', 'Nguyễn Văn A', '0909123456', NULL, 'customer', 2, NULL),
(5, 'a@worknest.vn', '$2y$10$y9WQWckMJCEVQbqG0PNSCum.x7fNlxAJK7RqwxZvlaxBVZRtre96W', '2025-06-04 09:10:50', '2025-06-04 09:10:50', 'Nguyễn Văn A', '0911111111', NULL, 'customer', 1, NULL),
(6, 'b@worknest.vn', '$2y$10$1LWsovHhrQhpuY3tvcl5Bu6nu8cWhi4U51LIHhlp7pTD3yBeY/Gz.', '2025-06-04 09:11:21', '2025-06-04 09:11:21', 'Trần Thị B', '0911111112', NULL, 'customer', 1, NULL),
(7, 'c@worknest.vn', '$2y$10$0M2AJM7k/CXzGKJCeeEh1.g2tFjFCZfeOLDGKqGgm3dUHqqpNtciW', '2025-06-04 09:11:44', '2025-06-04 09:11:44', 'Lê Văn C', '0911111113', NULL, 'customer', 2, NULL),
(8, 'd@worknest.vn', '$2y$10$UfmfTcnJd1Hc1wcH0Utaz.w9IFmXwNCzoFUQdahizBIri0BTfsDp2', '2025-06-04 09:12:07', '2025-06-22 02:33:05', 'Phạm Thị D', '0911111114', NULL, 'customer', 2, NULL),
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
-- Indexes for table `biddings`
--
ALTER TABLE `biddings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bidding_steps`
--
ALTER TABLE `bidding_steps`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `bidding_step_templates`
--
ALTER TABLE `bidding_step_templates`
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
-- Indexes for table `contract_step_templates`
--
ALTER TABLE `contract_step_templates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customer_transactions`
--
ALTER TABLE `customer_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `document_permissions`
--
ALTER TABLE `document_permissions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `document_id` (`document_id`);

--
-- Indexes for table `document_settings`
--
ALTER TABLE `document_settings`
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
-- AUTO_INCREMENT for table `biddings`
--
ALTER TABLE `biddings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `bidding_steps`
--
ALTER TABLE `bidding_steps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=242;

--
-- AUTO_INCREMENT for table `bidding_step_templates`
--
ALTER TABLE `bidding_step_templates`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `contract_steps`
--
ALTER TABLE `contract_steps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=327;

--
-- AUTO_INCREMENT for table `contract_step_files`
--
ALTER TABLE `contract_step_files`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `contract_step_templates`
--
ALTER TABLE `contract_step_templates`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `customer_transactions`
--
ALTER TABLE `customer_transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `document_permissions`
--
ALTER TABLE `document_permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `document_settings`
--
ALTER TABLE `document_settings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

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
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

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

--
-- Constraints for table `document_permissions`
--
ALTER TABLE `document_permissions`
  ADD CONSTRAINT `document_permissions_ibfk_1` FOREIGN KEY (`document_id`) REFERENCES `documents` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
