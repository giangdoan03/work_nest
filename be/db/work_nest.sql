-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jul 20, 2025 at 04:56 PM
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
  `assigned_to` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` int DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `biddings`
--

INSERT INTO `biddings` (`id`, `title`, `description`, `customer_id`, `estimated_cost`, `assigned_to`, `start_date`, `end_date`, `created_at`, `updated_at`, `status`) VALUES
(2, 'Gói thầu cung cấp turbine cho Nhiệt điện Quảng Ninh', 'Turbine hơi công suất 300MW cho tổ máy số 3', 1, 4500000000.00, 4, '2025-06-15', '2025-07-30', '2025-06-11 04:16:44', '2025-06-22 21:38:15', 2),
(3, 'Gói thầu xây dựng nhà điều hành Nhiệt điện Duyên Hải', 'Thi công hoàn thiện trụ sở ban quản lý nhà máy', 2, 1200000000.00, 23, '2025-06-20', '2025-08-10', '2025-06-11 04:16:50', '2025-06-22 21:39:45', 3),
(4, 'Cung cấp hệ thống điều khiển trung tâm cho Nhiệt điện Hải Phòng', 'SCADA & HMI cho toàn nhà máy', 3, 2500000000.00, 22, '2025-06-10', '2025-07-15', '2025-06-11 04:16:56', '2025-06-22 21:38:15', 3),
(5, 'Cung cấp ống khói chịu nhiệt cao', 'Ống khói chịu nhiệt độ trên 1000°C cho Nhiệt điện Vĩnh Tân', 4, 1750000000.00, 24, '2025-06-25', '2025-07-30', '2025-06-11 04:17:01', '2025-06-11 04:17:01', 0),
(6, 'Gói thầu bảo trì định kỳ năm 2025 – Nhiệt điện Mông Dương', 'Bảo trì tổ máy số 2 theo tiêu chuẩn EVN', 5, 980000000.00, 18, '2025-06-20', '2025-07-05', '2025-06-11 04:17:10', '2025-06-22 21:39:45', 2),
(7, 'Cung cấp vật tư phòng cháy chữa cháy – Nhiệt điện Ô Môn', 'Thiết bị PCCC tiêu chuẩn châu Âu', 6, 800000000.00, 18, '2025-06-22', '2025-07-10', '2025-06-11 04:17:15', '2025-06-11 04:17:15', 1),
(8, 'Cải tạo hệ thống cấp than – Nhiệt điện Na Dương', 'Băng tải và phễu tiếp nhận than đá', 7, 1350000000.00, 6, '2025-06-24', '2025-08-05', '2025-06-11 04:17:20', '2025-06-11 04:17:20', 2),
(9, 'Lắp đặt hệ thống điện chiếu sáng – Nhiệt điện Sông Hậu', 'Chiếu sáng toàn khu vực sân và hành lang', 8, 460000000.00, 17, '2025-06-28', '2025-07-25', '2025-06-11 04:17:26', '2025-06-22 21:38:15', 0),
(10, 'Cung cấp hệ thống xử lý nước thải công nghiệp – Nhiệt điện Phú Mỹ', 'Thiết bị xử lý hóa lý và sinh học', 9, 2600000000.00, 21, '2025-07-01', '2025-08-15', '2025-06-11 04:17:31', '2025-06-11 04:17:31', 0),
(11, 'Gói thầu thuê ngoài dịch vụ an ninh – Nhiệt điện Thái Bình 2', 'Thuê bảo vệ 24/7 trong 12 tháng', 10, 500000000.00, 8, '2025-06-15', '2025-07-15', '2025-06-11 04:17:36', '2025-06-22 21:39:45', 2),
(29, 'test hợp đồng mới', 'test hợp đồng mới', 1, 95420000000.00, 19, '2025-06-22', '2025-06-30', '2025-06-22 05:16:54', '2025-06-22 21:38:15', 3),
(31, 'gói thầu mới 1', 'gói thầu mới 1', 1, 30000000000000.00, 24, '2025-06-22', '2025-06-30', '2025-06-22 05:22:46', '2025-06-22 21:38:15', 2),
(32, 'gói thầu mới 222', 'gói thầu mới 222', 1, 599231321313.00, 6, '2025-06-22', '2025-06-30', '2025-06-22 05:23:23', '2025-06-22 21:38:15', 3);

-- --------------------------------------------------------

--
-- Table structure for table `bidding_steps`
--

CREATE TABLE `bidding_steps` (
  `id` int NOT NULL,
  `bidding_id` int DEFAULT NULL,
  `step_number` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '0: Chưa bắt đầu, 1: Đang xử lý, 2: Đã hoàn thành, 3: Bị hủy/bỏ qua',
  `customer_id` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `task_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bidding_steps`
--

INSERT INTO `bidding_steps` (`id`, `bidding_id`, `step_number`, `title`, `start_date`, `end_date`, `department`, `created_at`, `updated_at`, `status`, `customer_id`, `assigned_to`, `task_id`) VALUES
(1, NULL, 1, 'Nhận nhu cầu của khách hàng', NULL, NULL, 'Khách hàng', '2025-06-05 03:50:22', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(2, NULL, 2, 'Đánh giá tính khả thi', NULL, NULL, 'P.KD, P.DVKT', '2025-06-05 03:51:59', '2025-06-29 17:12:28', 0, 4, NULL, 17),
(3, NULL, 3, 'Chỉnh sửa tiêu đề bước', NULL, NULL, 'P.KD', '2025-06-05 03:52:32', '2025-06-29 17:12:28', 2, 10, NULL, 2),
(4, NULL, 4, 'Duyệt kế hoạch', NULL, NULL, 'Ban Giám đốc', '2025-06-05 03:52:39', '2025-06-29 17:12:28', 2, 2, NULL, 16),
(5, NULL, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-05 03:52:46', '2025-06-29 17:12:28', 1, 1, NULL, 15),
(6, NULL, 6, 'Chấm thầu', NULL, NULL, 'Khách hàng', '2025-06-05 03:52:53', '2025-06-29 17:12:28', 0, 4, NULL, 6),
(7, NULL, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, 'P.KD', '2025-06-05 03:53:00', '2025-06-29 17:12:28', 0, 4, NULL, 4),
(8, NULL, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, 'P.KD, P.TCKT, P.DVKT', '2025-06-05 03:53:07', '2025-06-29 17:12:28', 0, 5, NULL, 20),
(9, NULL, 9, 'Duyệt hợp đồng bán', NULL, NULL, 'Ban Giám đốc', '2025-06-05 03:53:14', '2025-06-29 17:12:28', 0, 3, NULL, 10),
(10, NULL, 10, 'Duyệt hợp đồng bán', NULL, NULL, 'Ban Giám đốc', '2025-06-10 15:18:36', '2025-06-29 17:12:28', 1, 10, NULL, 9),
(11, 1, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, 'Khách hàng', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 2, NULL, NULL, 14),
(12, 1, 2, 'Đánh giá tính khả thi', NULL, NULL, 'P.KD, P.DVKT', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 1, NULL, NULL, 1),
(13, 1, 3, 'Lập kế hoạch triển khai', NULL, NULL, 'P.KD, P.DVKT', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 0, NULL, NULL, 2),
(14, 1, 4, 'Duyệt kế hoạch', NULL, NULL, 'Ban Giám đốc', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 0, NULL, NULL, 9),
(15, 1, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 0, NULL, NULL, 17),
(16, 1, 6, 'Chấm thầu', NULL, NULL, 'Khách hàng', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 0, NULL, NULL, 17),
(17, 1, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, 'P.KD', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 0, NULL, NULL, 13),
(18, 1, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, 'P.KD, P.TCKT, P.DVKT', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 0, NULL, NULL, 14),
(19, 1, 9, 'Duyệt hợp đồng bán', NULL, NULL, 'Ban Giám đốc', '2025-06-16 09:06:25', '2025-06-29 17:12:28', 0, NULL, NULL, 9),
(20, 1, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, 'Khách hàng', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 2, NULL, NULL, 3),
(21, 1, 2, 'Đánh giá tính khả thi', NULL, NULL, 'P.KD, P.DVKT', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 0, NULL, NULL, 7),
(22, 1, 3, 'Lập kế hoạch triển khai', NULL, NULL, 'P.KD, P.DVKT', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 0, NULL, NULL, 5),
(23, 1, 4, 'Duyệt kế hoạch', NULL, NULL, 'Ban Giám đốc', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 0, NULL, NULL, 5),
(24, 1, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 0, NULL, NULL, 10),
(25, 1, 6, 'Chấm thầu', NULL, NULL, 'Khách hàng', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 0, NULL, NULL, 15),
(26, 1, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, 'P.KD', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 0, NULL, NULL, 3),
(27, 1, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, 'P.KD, P.TCKT, P.DVKT', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 0, NULL, NULL, 11),
(28, 1, 9, 'Duyệt hợp đồng bán', NULL, NULL, 'Ban Giám đốc', '2025-06-20 08:34:44', '2025-06-29 17:12:28', 0, NULL, NULL, 6),
(29, 12, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, 'KT', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, 1, NULL, 15),
(30, 12, 2, 'Đánh giá tính khả thi', NULL, NULL, '', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, 1, NULL, 16),
(31, 12, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 15),
(32, 12, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 7),
(33, 12, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 7),
(34, 12, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 15),
(35, 12, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 15),
(36, 12, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 10),
(37, 12, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 5),
(38, 12, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 14),
(39, 12, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-21 01:51:18', '2025-06-29 17:12:28', 0, NULL, NULL, 12),
(40, 13, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, 'KT', '2025-06-22 03:09:31', '2025-06-29 17:12:28', 0, 1, NULL, 19),
(41, 13, 2, 'Đánh giá tính khả thi', NULL, NULL, '', '2025-06-22 03:09:31', '2025-06-29 17:12:28', 0, 1, NULL, 19),
(42, 13, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 17),
(43, 13, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 6),
(44, 13, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 1),
(45, 13, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 7),
(46, 13, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 9),
(47, 13, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 7),
(48, 13, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 4),
(49, 13, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 1),
(50, 13, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:09:32', '2025-06-29 17:12:28', 0, NULL, NULL, 13),
(51, 14, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, 'KT', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 19),
(52, 14, 2, 'Đánh giá tính khả thi', NULL, NULL, '', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 18),
(53, 14, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 1, 1, NULL, 13),
(54, 14, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 11),
(55, 14, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 16),
(56, 14, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 3),
(57, 14, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 10),
(58, 14, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 19),
(59, 14, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 4),
(60, 14, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 3),
(61, 14, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:18:58', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(62, 15, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, 'KT', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 19),
(63, 15, 2, 'Đánh giá tính khả thi', NULL, NULL, '', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 8),
(64, 15, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 1, 1, NULL, 4),
(65, 15, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 14),
(66, 15, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(67, 15, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 19),
(68, 15, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 12),
(69, 15, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 2),
(70, 15, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 14),
(71, 15, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 5),
(72, 15, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:22:22', '2025-06-29 17:12:28', 0, 1, NULL, 20),
(73, 8, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:43:42', '2025-06-29 17:12:28', 1, 7, NULL, 6),
(74, 8, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-06-29 17:12:28', 0, 7, NULL, 10),
(75, 8, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-06-29 17:12:28', 0, 7, NULL, 10),
(76, 8, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:43:42', '2025-06-29 17:12:28', 0, 7, NULL, 19),
(77, 8, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:43:42', '2025-06-29 17:12:28', 0, 7, NULL, 6),
(78, 8, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:43:42', '2025-06-29 17:12:28', 0, 7, NULL, 10),
(79, 8, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:43:42', '2025-07-20 09:32:53', 0, 7, NULL, 35),
(80, 8, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-06-29 17:38:34', 0, 7, NULL, 35),
(81, 8, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:43:42', '2025-06-29 17:12:28', 0, 7, NULL, 10),
(82, 10, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 1, 9, NULL, 9),
(83, 10, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 0, 9, NULL, 14),
(84, 10, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 0, 9, NULL, 4),
(85, 10, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 0, 9, NULL, 17),
(86, 10, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 0, 9, NULL, 11),
(87, 10, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 0, 9, NULL, 4),
(88, 10, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 0, 9, NULL, 7),
(89, 10, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 0, 9, NULL, 2),
(90, 10, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:10', '2025-06-29 17:12:28', 0, 9, NULL, 11),
(91, 11, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 1, 10, NULL, 5),
(92, 11, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 0, 10, NULL, 12),
(93, 11, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 0, 10, NULL, 7),
(94, 11, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 0, 10, NULL, 16),
(95, 11, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 0, 10, NULL, 1),
(96, 11, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 0, 10, NULL, 17),
(97, 11, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 0, 10, NULL, 1),
(98, 11, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 0, 10, NULL, 12),
(99, 11, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:20', '2025-06-29 17:12:28', 0, 10, NULL, 16),
(100, 5, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:51', '2025-06-29 17:12:28', 2, 4, NULL, 3),
(101, 5, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-06-29 17:12:28', 1, 4, NULL, 9),
(102, 5, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-06-29 17:12:28', 0, 4, NULL, 14),
(103, 5, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:51', '2025-06-29 17:12:28', 0, 4, NULL, 2),
(104, 5, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:51', '2025-07-06 15:53:08', 0, 4, NULL, 29),
(105, 5, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:51', '2025-06-29 17:12:28', 0, 4, NULL, 10),
(106, 5, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:51', '2025-06-29 17:12:28', 0, 4, NULL, 7),
(107, 5, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-06-29 17:12:28', 0, 4, NULL, 7),
(108, 5, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:51', '2025-06-29 17:12:28', 0, 4, NULL, 11),
(109, 2, 1, 'Nhận nhu cầu khách hàng', '2025-07-07 00:00:00', '2025-07-31 00:00:00', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:48:05', '2025-07-08 14:24:18', 2, 1, 8, 32),
(110, 2, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:48:05', '2025-07-13 13:51:48', 2, 1, 22, 34),
(111, 2, 3, 'Lập kế hoạch triển khai', '2025-07-19 00:00:00', '2025-07-31 00:00:00', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:48:05', '2025-07-20 09:37:37', 2, 1, 24, 26),
(112, 2, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:48:05', '2025-07-20 12:47:51', 2, 1, NULL, 1),
(113, 2, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:48:05', '2025-07-01 11:11:05', 1, 1, NULL, 1),
(114, 2, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:48:05', '2025-07-10 03:39:12', 0, 1, NULL, 40),
(115, 2, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:48:05', '2025-06-29 17:12:28', 0, 1, NULL, 12),
(116, 2, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:48:05', '2025-06-29 17:12:28', 0, 1, NULL, 10),
(117, 2, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:48:05', '2025-06-29 17:12:28', 0, 1, NULL, 14),
(118, 3, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:56:49', '2025-07-10 05:53:50', 2, 2, 22, 49),
(119, 3, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-06-29 17:12:28', 2, 2, 8, 14),
(120, 3, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-06-29 17:12:28', 2, 2, 17, 9),
(121, 3, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:56:49', '2025-06-29 18:06:56', 2, 2, 5, 1),
(122, 3, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:56:49', '2025-06-29 17:10:31', 2, 2, 6, 1),
(123, 3, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:56:49', '2025-07-20 09:38:16', 2, 2, 19, 45),
(124, 3, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:56:49', '2025-06-29 17:12:28', 2, 2, 17, 17),
(125, 3, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-06-29 17:12:28', 2, 2, 16, 15),
(126, 3, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:56:49', '2025-06-29 17:12:28', 2, 2, 17, 4),
(127, 4, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:57:46', '2025-06-29 17:12:28', 2, 3, 24, 14),
(128, 4, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-06-29 17:12:28', 2, 3, 11, 19),
(129, 4, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-06-29 17:12:28', 2, 3, 12, 10),
(130, 4, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:57:46', '2025-07-01 11:32:47', 2, 3, 22, 49),
(131, 4, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:57:46', '2025-06-29 17:12:28', 2, 3, 7, 20),
(132, 4, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:57:46', '2025-06-29 17:12:28', 2, 3, 23, 16),
(133, 4, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:57:46', '2025-06-29 17:12:28', 2, 3, 20, 20),
(134, 4, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-06-29 17:12:28', 2, 3, 6, 11),
(135, 4, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 03:57:46', '2025-06-29 17:12:28', 2, 3, 7, 16),
(158, 26, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 1, 1, NULL, 7),
(159, 26, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 0, 1, NULL, 5),
(160, 26, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 0, 1, NULL, 2),
(161, 26, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 0, 1, NULL, 17),
(162, 26, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 0, 1, NULL, 18),
(163, 26, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 0, 1, NULL, 20),
(164, 26, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 0, 1, NULL, 6),
(165, 26, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 0, 1, NULL, 7),
(166, 26, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:04:45', '2025-06-29 17:12:28', 0, 1, NULL, 19),
(169, 27, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 1, 1, NULL, 14),
(170, 27, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 0, 1, NULL, 11),
(171, 27, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 0, 1, NULL, 11),
(172, 27, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 0, 1, NULL, 3),
(173, 27, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(174, 27, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 0, 1, NULL, 17),
(175, 27, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 0, 1, NULL, 3),
(176, 27, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(177, 27, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:06:25', '2025-06-29 17:12:28', 0, 1, NULL, 15),
(189, 29, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, 'KT', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 12),
(190, 29, 2, 'Đánh giá tính khả thi', NULL, NULL, '', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 15),
(191, 29, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 1, 1, NULL, 19),
(192, 29, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 9),
(193, 29, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 5),
(194, 29, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(195, 29, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 9),
(196, 29, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(197, 29, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 18),
(198, 29, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 5),
(199, 29, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:16:54', '2025-06-29 17:12:28', 0, 1, NULL, 12),
(200, 30, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, 'KT', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 3),
(201, 30, 2, 'Đánh giá tính khả thi', NULL, NULL, '', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 20),
(202, 30, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 1, 1, NULL, 11),
(203, 30, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 13),
(204, 30, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 13),
(205, 30, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 7),
(206, 30, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 13),
(207, 30, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 4),
(208, 30, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(209, 30, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 14),
(210, 30, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:20:16', '2025-06-29 17:12:28', 0, 1, NULL, 5),
(213, 31, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 1, 1, NULL, 2),
(214, 31, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 0, 1, NULL, 14),
(215, 31, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 0, 1, NULL, 5),
(216, 31, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 0, 1, NULL, 4),
(217, 31, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 0, 1, NULL, 3),
(218, 31, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 0, 1, NULL, 2),
(219, 31, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 0, 1, NULL, 20),
(220, 31, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 0, 1, NULL, 15),
(221, 31, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:22:47', '2025-06-29 17:12:28', 0, 1, NULL, 14),
(224, 32, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, NULL, 4),
(225, 32, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, NULL, 18),
(226, 32, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, NULL, 18),
(227, 32, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, NULL, 13),
(228, 32, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, 24, 13),
(229, 32, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, NULL, 7),
(230, 32, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, 6, 13),
(231, 32, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, 22, 5),
(232, 32, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 05:23:23', '2025-06-29 17:12:28', 2, 1, 14, 6),
(233, 6, 1, 'Nhận nhu cầu khách hàng', '2025-07-10 00:00:00', '2025-07-28 00:00:00', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 06:55:02', '2025-07-10 03:28:01', 1, 5, 6, 15),
(234, 6, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-06-29 17:12:28', 0, 5, NULL, 16),
(235, 6, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-06-29 17:12:28', 0, 5, NULL, 14),
(236, 6, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 06:55:02', '2025-06-29 17:12:28', 0, 5, NULL, 1),
(237, 6, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 06:55:02', '2025-07-06 13:45:23', 0, 5, NULL, 2),
(238, 6, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 06:55:02', '2025-06-29 17:12:28', 0, 5, NULL, 13),
(239, 6, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 06:55:02', '2025-06-29 17:11:33', 0, 5, NULL, 2),
(240, 6, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-06-29 17:12:28', 0, 5, NULL, 11),
(241, 6, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 06:55:02', '2025-06-29 17:12:28', 0, 5, NULL, 11),
(244, 33, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 1, 1, 7, 3),
(245, 33, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(246, 33, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 0, 1, NULL, 15),
(247, 33, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 0, 1, NULL, 14),
(248, 33, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 0, 1, NULL, 1),
(249, 33, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 0, 1, NULL, 6),
(250, 33, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 0, 1, NULL, 4),
(251, 33, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 0, 1, NULL, 4),
(252, 33, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 14:53:19', '2025-06-29 17:12:28', 0, 1, NULL, 7),
(253, 9, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 15:07:34', '2025-06-29 17:12:28', 1, 8, NULL, 2),
(254, 9, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 15:07:34', '2025-06-29 17:12:28', 0, 8, NULL, 10),
(255, 9, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 15:07:34', '2025-06-29 17:12:28', 0, 8, NULL, 4),
(256, 9, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 15:07:34', '2025-06-29 17:12:28', 0, 8, NULL, 7),
(257, 9, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 15:07:34', '2025-06-29 17:12:28', 0, 8, NULL, 4),
(258, 9, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 15:07:34', '2025-06-29 17:12:28', 0, 8, NULL, 20),
(259, 9, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 15:07:34', '2025-07-20 09:38:40', 0, 8, NULL, 46),
(260, 9, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 15:07:34', '2025-07-20 09:37:49', 0, 8, NULL, 38),
(261, 9, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 15:07:34', '2025-07-20 09:38:04', 0, 8, NULL, 39),
(264, 34, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 15:21:11', '2025-07-20 09:38:27', 2, 1, 6, 42),
(265, 34, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 15:21:11', '2025-07-06 17:05:22', 2, 1, 8, 3),
(266, 34, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 15:21:11', '2025-06-29 17:12:28', 2, 1, 7, 16),
(267, 34, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 15:21:11', '2025-06-29 17:12:28', 2, 1, 20, 5),
(268, 34, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 15:21:11', '2025-06-29 17:12:28', 2, 1, NULL, 16),
(269, 34, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 15:21:11', '2025-06-29 17:12:28', 2, 1, 22, 5),
(270, 34, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 15:21:11', '2025-06-29 17:12:28', 2, 1, 21, 18),
(271, 34, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-22 15:21:11', '2025-06-29 17:12:28', 2, 1, 5, 12),
(272, 34, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-22 15:21:11', '2025-06-29 17:12:28', 2, 1, 11, 8),
(273, 28, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 1, 1, NULL, 4),
(274, 28, 2, 'Đánh giá tính khả thi', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 0, 1, NULL, 13),
(275, 28, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 0, 1, NULL, 15),
(276, 28, 4, 'Duyệt kế hoạch', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 0, 1, NULL, 12),
(277, 28, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 0, 1, NULL, 17),
(278, 28, 6, 'Chấm thầu', NULL, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 0, 1, NULL, 9),
(279, 28, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 0, 1, NULL, 12),
(280, 28, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, '[\"Phòng Thương mại\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 0, 1, NULL, 14),
(281, 28, 9, 'Duyệt hợp đồng bán', NULL, NULL, '[\"Phòng Kinh doanh\"]', '2025-06-29 02:35:13', '2025-06-29 17:12:28', 0, 1, NULL, 15);

-- --------------------------------------------------------

--
-- Table structure for table `bidding_step_templates`
--

CREATE TABLE `bidding_step_templates` (
  `id` int NOT NULL,
  `step_number` int NOT NULL,
  `step_code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `department` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bidding_step_templates`
--

INSERT INTO `bidding_step_templates` (`id`, `step_number`, `step_code`, `title`, `department`, `created_at`, `updated_at`) VALUES
(1, 1, 'bidding_step_01', 'Nhận nhu cầu khách hàng', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(2, 2, 'bidding_step_02', 'Đánh giá tính khả thi', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(3, 3, 'bidding_step_03', 'Lập kế hoạch triển khai', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(4, 4, 'bidding_step_04', 'Duyệt kế hoạch', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(5, 5, 'bidding_step_05', 'Triển khai hồ sơ dự thầu', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(6, 6, 'bidding_step_06', 'Chấm thầu', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(7, 7, 'bidding_step_07', 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(8, 8, 'bidding_step_08', 'Triển khai ký hợp đồng bán', '[\"Phòng Thương mại\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(9, 9, 'bidding_step_09', 'Duyệt hợp đồng bán', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25');

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
  `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `contracts`
--

INSERT INTO `contracts` (`id`, `title`, `code`, `content`, `status`, `department_id`, `assigned_to`, `id_customer`, `bidding_id`, `start_date`, `end_date`, `created_at`, `updated_at`, `updated_by`, `description`) VALUES
(30, 'Hợp đồng bảo trì hệ thống SCADA - Nhiệt điện Phả Lại', '#5465435', NULL, 1, NULL, 22, 8, 9, '2025-06-06', '2025-06-15', '2025-06-21 04:41:38', '2025-06-29 09:42:02', NULL, '467657yfdghhk'),
(31, 'Cung cấp thiết bị điều khiển lò hơi - Nhiệt điện Vĩnh Tân 4', '#5222222', NULL, 4, NULL, 20, 8, 9, '2025-06-07', '2025-06-16', '2025-06-21 14:24:12', '2025-06-22 14:26:44', NULL, '2343565879sdfgsdfsdfdfsf'),
(32, 'Tư vấn nâng cấp hệ thống điều khiển DCS - Nhiệt điện Mông Dương', '#44444444', NULL, 4, NULL, 14, 3, 4, '2025-06-07', '2025-06-16', '2025-06-21 14:56:49', '2025-06-22 14:29:14', NULL, '3432544656fghfgbcvbvbvc'),
(33, 'Cung cấp than tổ hợp - Nhiệt điện Nghi Sơn', '#66666', NULL, 3, NULL, 22, 1, 29, '2025-06-19', '2025-06-27', '2025-06-22 06:34:46', '2025-06-29 09:41:57', NULL, 'ưerrewrrrwwr'),
(34, 'test hợp đồng 2', '#444444', NULL, 1, NULL, 19, 2, 3, '2025-07-18', '2025-07-29', '2025-07-20 11:51:50', '2025-07-20 12:43:15', NULL, 'demo');

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
  `end_date` datetime DEFAULT NULL,
  `completed_at` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `department` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `task_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `contract_steps`
--

INSERT INTO `contract_steps` (`id`, `contract_id`, `customer_id`, `step_number`, `title`, `status`, `assigned_to`, `start_date`, `due_date`, `end_date`, `completed_at`, `created_at`, `updated_at`, `department`, `task_id`) VALUES
(259, 30, NULL, 10, 'Đặt hàng NCC', 2, 6, '2025-07-10', NULL, '2025-07-28 00:00:00', '2025-07-08', '2025-06-21 04:41:38', '2025-07-10 03:36:33', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]', 5),
(260, 30, NULL, 11, 'Duyệt đặt hàng', 1, NULL, NULL, NULL, NULL, '2025-07-01', '2025-06-21 04:41:38', '2025-07-08 14:41:36', '[\"Ban Giám đốc\"]', 7),
(261, 30, NULL, 12, 'Triển khai hợp đồng mua', 1, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-07-01 11:22:13', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]', 2),
(262, 30, NULL, 13, 'Duyệt hợp đồng mua', 1, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 9),
(263, 30, NULL, 14, 'Thanh toán hợp đồng mua', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.TM\", \"P.TCKT\"]', 17),
(264, 30, NULL, 15, 'Kiểm tra hàng hóa', 0, 5, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-07-01 11:08:45', '[\"P.TM\"]', 17),
(265, 30, NULL, 16, 'Nghiệm thu', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]', 15),
(266, 30, NULL, 17, 'Thông báo lỗi hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.TM\"]', 2),
(267, 30, NULL, 18, 'Nhập kho hàng hóa', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.KHNS\", \"P.TCKT\"]', 6),
(268, 30, NULL, 19, 'Xuất kho hàng hóa', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TCKT\"]', 1),
(269, 30, NULL, 20, 'Duyệt phiếu xuất', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 8),
(270, 30, NULL, 21, 'Giao hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]', 15),
(271, 30, NULL, 22, 'Nghiệm thu từ phía KH', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"Khách hàng\"]', 10),
(272, 30, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]', 5),
(273, 30, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]', 16),
(274, 30, NULL, 25, 'Thanh toán', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"Khách hàng\"]', 2),
(275, 30, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]', 1),
(276, 31, NULL, 10, 'Đặt hàng NCC', 2, 20, '2025-06-22', NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-07-09 18:19:24', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]', 19),
(277, 31, NULL, 11, 'Duyệt đặt hàng', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 12),
(278, 31, NULL, 12, 'Triển khai hợp đồng mua', 2, 22, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]', 1),
(279, 31, NULL, 13, 'Duyệt hợp đồng mua', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 9),
(280, 31, NULL, 14, 'Thanh toán hợp đồng mua', 2, 23, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.TM\", \"P.TCKT\"]', 2),
(281, 31, NULL, 15, 'Kiểm tra hàng hóa', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.TM\"]', 2),
(282, 31, NULL, 16, 'Nghiệm thu', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]', 4),
(283, 31, NULL, 17, 'Thông báo lỗi hàng', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.TM\"]', 14),
(284, 31, NULL, 18, 'Nhập kho hàng hóa', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.KHNS\", \"P.TCKT\"]', 15),
(285, 31, NULL, 19, 'Xuất kho hàng hóa', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TCKT\"]', 13),
(286, 31, NULL, 20, 'Duyệt phiếu xuất', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 2),
(287, 31, NULL, 21, 'Giao hàng', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]', 10),
(288, 31, NULL, 22, 'Nghiệm thu từ phía KH', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"Khách hàng\"]', 5),
(289, 31, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]', 12),
(290, 31, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]', 6),
(291, 31, NULL, 25, 'Thanh toán', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"Khách hàng\"]', 14),
(292, 31, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 2, NULL, NULL, NULL, NULL, '2025-06-22', '2025-06-21 14:24:12', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]', 10),
(293, 32, NULL, 10, 'Đặt hàng NCC', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]', 6),
(294, 32, NULL, 11, 'Duyệt đặt hàng', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 1),
(295, 32, NULL, 12, 'Triển khai hợp đồng mua', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]', 6),
(296, 32, NULL, 13, 'Duyệt hợp đồng mua', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 6),
(297, 32, NULL, 14, 'Thanh toán hợp đồng mua', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.TM\", \"P.TCKT\"]', 14),
(298, 32, NULL, 15, 'Kiểm tra hàng hóa', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.TM\"]', 10),
(299, 32, NULL, 16, 'Nghiệm thu', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]', 7),
(300, 32, NULL, 17, 'Thông báo lỗi hàng', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.TM\"]', 7),
(301, 32, NULL, 18, 'Nhập kho hàng hóa', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.KHNS\", \"P.TCKT\"]', 12),
(302, 32, NULL, 19, 'Xuất kho hàng hóa', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TCKT\"]', 19),
(303, 32, NULL, 20, 'Duyệt phiếu xuất', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 18),
(304, 32, NULL, 21, 'Giao hàng', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]', 15),
(305, 32, NULL, 22, 'Nghiệm thu từ phía KH', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"Khách hàng\"]', 17),
(306, 32, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]', 2),
(307, 32, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]', 19),
(308, 32, NULL, 25, 'Thanh toán', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"Khách hàng\"]', 6),
(309, 32, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 2, NULL, NULL, NULL, NULL, '2025-06-21', '2025-06-21 14:56:49', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]', 14),
(310, 33, NULL, 10, 'Đặt hàng NCC', 2, 4, NULL, NULL, NULL, '2025-06-22', '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]', 11),
(311, 33, NULL, 11, 'Duyệt đặt hàng', 1, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 12),
(312, 33, NULL, 12, 'Triển khai hợp đồng mua', 0, 22, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]', 6),
(313, 33, NULL, 13, 'Duyệt hợp đồng mua', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 15),
(314, 33, NULL, 14, 'Thanh toán hợp đồng mua', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.TM\", \"P.TCKT\"]', 14),
(315, 33, NULL, 15, 'Kiểm tra hàng hóa', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.TM\"]', 7),
(316, 33, NULL, 16, 'Nghiệm thu', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]', 13),
(317, 33, NULL, 17, 'Thông báo lỗi hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.TM\"]', 3),
(318, 33, NULL, 18, 'Nhập kho hàng hóa', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.KHNS\", \"P.TCKT\"]', 15),
(319, 33, NULL, 19, 'Xuất kho hàng hóa', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TCKT\"]', 4),
(320, 33, NULL, 20, 'Duyệt phiếu xuất', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"Ban Giám đốc\"]', 16),
(321, 33, NULL, 21, 'Giao hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]', 8),
(322, 33, NULL, 22, 'Nghiệm thu từ phía KH', 0, NULL, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"Khách hàng\"]', 9),
(323, 33, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 0, 20, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]', 4),
(324, 33, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 0, 23, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]', 9),
(325, 33, NULL, 25, 'Thanh toán', 0, 18, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"Khách hàng\"]', 14),
(326, 33, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 0, 7, NULL, NULL, NULL, NULL, '2025-06-22 06:34:46', '2025-06-29 17:13:19', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]', 20),
(327, 34, NULL, 10, 'Đặt hàng NCC', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]', NULL),
(328, 34, NULL, 11, 'Duyệt đặt hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"Ban Giám đốc\"]', NULL),
(329, 34, NULL, 12, 'Triển khai hợp đồng mua', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]', NULL),
(330, 34, NULL, 13, 'Duyệt hợp đồng mua', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"Ban Giám đốc\"]', NULL),
(331, 34, NULL, 14, 'Thanh toán hợp đồng mua', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.TM\", \"P.TCKT\"]', NULL),
(332, 34, NULL, 15, 'Kiểm tra hàng hóa', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.TM\"]', NULL),
(333, 34, NULL, 16, 'Nghiệm thu', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]', NULL),
(334, 34, NULL, 17, 'Thông báo lỗi hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.TM\"]', NULL),
(335, 34, NULL, 18, 'Nhập kho hàng hóa', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.KHNS\", \"P.TCKT\"]', NULL),
(336, 34, NULL, 19, 'Xuất kho hàng hóa', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.KD\", \"P.TCKT\"]', NULL),
(337, 34, NULL, 20, 'Duyệt phiếu xuất', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"Ban Giám đốc\"]', NULL),
(338, 34, NULL, 21, 'Giao hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]', NULL),
(339, 34, NULL, 22, 'Nghiệm thu từ phía KH', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"Khách hàng\"]', NULL),
(340, 34, NULL, 23, 'Xử lý sai lệch hoặc chứng từ', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]', NULL),
(341, 34, NULL, 24, 'Hỏi hồ sơ thanh quyết toán', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]', NULL),
(342, 34, NULL, 25, 'Thanh toán', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"Khách hàng\"]', NULL),
(343, 34, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]', NULL);

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
  `step_code` varchar(50) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `department` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `contract_step_templates`
--

INSERT INTO `contract_step_templates` (`id`, `step_number`, `step_code`, `title`, `department`, `created_at`, `updated_at`) VALUES
(1, 10, 'contract_step_10', 'Đặt hàng NCC', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(2, 11, 'contract_step_11', 'Duyệt đặt hàng', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(3, 12, 'contract_step_12', 'Triển khai hợp đồng mua', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(4, 13, 'contract_step_13', 'Duyệt hợp đồng mua', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(5, 14, 'contract_step_14', 'Thanh toán hợp đồng mua', '[\"P.TM\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(6, 15, 'contract_step_15', 'Kiểm tra hàng hóa', '[\"P.TM\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(7, 16, 'contract_step_16', 'Nghiệm thu', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(8, 17, 'contract_step_17', 'Thông báo lỗi hàng', '[\"P.TM\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(9, 18, 'contract_step_18', 'Nhập kho hàng hóa', '[\"P.KHNS\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(10, 19, 'contract_step_19', 'Xuất kho hàng hóa', '[\"P.KD\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(11, 20, 'contract_step_20', 'Duyệt phiếu xuất', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(12, 21, 'contract_step_21', 'Giao hàng', '[\"P.KD\", \"P.KHNS\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(13, 22, 'contract_step_22', 'Nghiệm thu từ phía KH', '[\"Khách hàng\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(14, 23, 'contract_step_23', 'Xử lý sai lệch hoặc chứng từ', '[\"P.KD\", \"P.DVKT\", \"P.TMĐ\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(15, 24, 'contract_step_24', 'Hỏi hồ sơ thanh quyết toán', '[\"P.KD\", \"P.TM\", \"P.TCKT\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(16, 25, 'contract_step_25', 'Thanh toán', '[\"Khách hàng\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43'),
(17, 26, 'contract_step_26', 'Thoả hồ sơ lưu chứng từ & kết thúc', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]', '2025-06-20 23:49:21', '2025-06-29 16:07:43');

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
  `visibility` enum('private','public','department','custom') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'private',
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
(1, 'Báo cáo Q2 đã cập nhật', 'documents/1749798305_37045c936642c36152e8.png', 3, 1, 'custom', 'image/png', 528057, '2025-06-13 07:05:05', '2025-07-14 16:42:40', 'báo cáo, quý 2'),
(2, 'Báo cáo tài chính', 'documents/1749799608_3bbef2158709ab8061f4.png', 3, 1, 'custom', 'image/png', 528057, '2025-06-13 07:26:48', '2025-07-14 16:42:16', 'tài chính, 2025'),
(3, 'test', 'https://vnexpress.net/', 1, 1, 'custom', 'link', 0, '2025-07-13 14:48:56', '2025-07-14 16:42:08', NULL),
(4, 'test 2', 'https://dantri.com.vn/noi-vu/nhom-can-bo-cong-chuc-duoc-uu-tien-nghi-huu-truoc-tuoi-20250322153127598.htm', 2, 1, 'private', 'link', 0, '2025-07-13 15:01:40', '2025-07-13 15:01:40', NULL),
(5, 'test 3', 'https://dantri.com.vn/noi-vu/nhom-can-bo-cong-chuc-duoc-uu-tien-nghi-huu-truoc-tuoi-20250322153127598.htm', 3, 1, 'custom', 'link', 0, '2025-07-13 15:01:55', '2025-07-14 14:57:26', NULL),
(6, 'tài liệu kỹ thuật 4', 'https://vnexpress.net/', 3, 1, 'custom', 'link', 0, '2025-07-13 15:23:25', '2025-07-14 21:53:55', NULL);

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
(206, 6, 'user', 5, 'view', '2025-07-14 14:49:19', '2025-07-14 14:49:19'),
(207, 6, 'user', 8, 'view', '2025-07-14 14:49:19', '2025-07-14 14:49:19'),
(208, 6, 'user', 12, 'view', '2025-07-14 14:49:19', '2025-07-14 14:49:19'),
(209, 6, 'department', 2, 'view', '2025-07-14 14:49:19', '2025-07-14 14:49:19'),
(210, 6, 'department', 3, 'view', '2025-07-14 14:49:19', '2025-07-14 14:49:19'),
(211, 6, 'department', 4, 'view', '2025-07-14 14:49:19', '2025-07-14 14:49:19'),
(212, 5, 'user', 8, 'view', '2025-07-14 14:57:26', '2025-07-14 14:57:26'),
(213, 5, 'department', 2, 'view', '2025-07-14 14:57:26', '2025-07-14 14:57:26'),
(214, 5, 'department', 3, 'view', '2025-07-14 14:57:26', '2025-07-14 14:57:26'),
(215, 3, 'user', 5, 'view', '2025-07-14 16:42:08', '2025-07-14 16:42:08'),
(216, 3, 'user', 8, 'view', '2025-07-14 16:42:08', '2025-07-14 16:42:08'),
(217, 3, 'user', 12, 'view', '2025-07-14 16:42:08', '2025-07-14 16:42:08'),
(218, 3, 'department', 2, 'view', '2025-07-14 16:42:08', '2025-07-14 16:42:08'),
(219, 3, 'department', 3, 'view', '2025-07-14 16:42:08', '2025-07-14 16:42:08'),
(220, 3, 'department', 4, 'view', '2025-07-14 16:42:08', '2025-07-14 16:42:08'),
(221, 2, 'user', 8, 'view', '2025-07-14 16:42:16', '2025-07-14 16:42:16'),
(222, 2, 'department', 2, 'view', '2025-07-14 16:42:16', '2025-07-14 16:42:16'),
(223, 2, 'department', 3, 'view', '2025-07-14 16:42:16', '2025-07-14 16:42:16'),
(224, 1, 'user', 8, 'view', '2025-07-14 16:42:40', '2025-07-14 16:42:40'),
(225, 1, 'user', 12, 'view', '2025-07-14 16:42:40', '2025-07-14 16:42:40'),
(226, 1, 'department', 1, 'view', '2025-07-14 16:42:40', '2025-07-14 16:42:40'),
(227, 1, 'department', 2, 'view', '2025-07-14 16:42:40', '2025-07-14 16:42:40'),
(228, 1, 'department', 3, 'view', '2025-07-14 16:42:40', '2025-07-14 16:42:40');

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
(33, 'user.view', 'Xem người dùng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(34, 'user.create', 'Tạo người dùng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(35, 'user.update', 'Cập nhật người dùng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(36, 'user.delete', 'Xoá người dùng', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(37, 'setting.view', 'Xem cấu hình', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(38, 'setting.update', 'Cập nhật cấu hình', '2025-04-21 00:15:39', '2025-04-21 00:15:39'),
(39, 'task.view', 'Xem nhiệm vụ', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(40, 'task.create', 'Tạo nhiệm vụ', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(41, 'task.update', 'Cập nhật nhiệm vụ', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(42, 'task.delete', 'Xoá nhiệm vụ', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(43, 'department.view', 'Xem phòng ban', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(44, 'department.create', 'Tạo phòng ban', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(45, 'department.update', 'Cập nhật phòng ban', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(46, 'department.delete', 'Xoá phòng ban', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(47, 'contract.view', 'Xem hợp đồng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(48, 'contract.create', 'Tạo hợp đồng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(49, 'contract.update', 'Cập nhật hợp đồng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(50, 'contract.delete', 'Xoá hợp đồng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(51, 'bidding.view', 'Xem đấu thầu', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(52, 'bidding.create', 'Tạo đấu thầu', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(53, 'bidding.update', 'Cập nhật đấu thầu', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(54, 'bidding.delete', 'Xoá đấu thầu', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(55, 'user.view', 'Xem người dùng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(56, 'user.create', 'Tạo người dùng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(57, 'user.update', 'Cập nhật người dùng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(58, 'user.delete', 'Xoá người dùng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(59, 'setting.view', 'Xem cấu hình', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(60, 'setting.create', 'Tạo cấu hình', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(61, 'setting.update', 'Cập nhật cấu hình', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(62, 'setting.delete', 'Xoá cấu hình', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(63, 'customer.view', 'Xem khách hàng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(64, 'customer.create', 'Tạo khách hàng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(65, 'customer.update', 'Cập nhật khách hàng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(66, 'customer.delete', 'Xoá khách hàng', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(67, 'document.view', 'Xem tài liệu', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(68, 'document.create', 'Tạo tài liệu', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(69, 'document.update', 'Cập nhật tài liệu', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(70, 'document.delete', 'Xoá tài liệu', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(71, 'permission.view', 'Xem phân quyền', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(72, 'permission.create', 'Tạo phân quyền', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(73, 'permission.update', 'Cập nhật phân quyền', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(74, 'permission.delete', 'Xoá phân quyền', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(75, 'project.view', 'Xem tổng quan dự án', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(76, 'project.create', 'Tạo tổng quan dự án', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(77, 'project.update', 'Cập nhật tổng quan dự án', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(78, 'project.delete', 'Xoá tổng quan dự án', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(79, 'comment.view', 'Xem bình luận', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(80, 'comment.create', 'Tạo bình luận', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(81, 'comment.update', 'Cập nhật bình luận', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(82, 'comment.delete', 'Xoá bình luận', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(83, 'approval.view', 'Xem duyệt nhiệm vụ', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(84, 'approval.create', 'Tạo duyệt nhiệm vụ', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(85, 'approval.update', 'Cập nhật duyệt nhiệm vụ', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(86, 'approval.delete', 'Xoá duyệt nhiệm vụ', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(87, 'gantt.view', 'Xem biểu đồ Gantt', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(88, 'gantt.create', 'Tạo biểu đồ Gantt', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(89, 'gantt.update', 'Cập nhật biểu đồ Gantt', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(90, 'gantt.delete', 'Xoá biểu đồ Gantt', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(91, 'step-template.view', 'Xem mẫu bước', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(92, 'step-template.create', 'Tạo mẫu bước', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(93, 'step-template.update', 'Cập nhật mẫu bước', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(94, 'step-template.delete', 'Xoá mẫu bước', '2025-07-13 10:34:40', '2025-07-13 10:34:40'),
(95, 'my-task.view', 'View My Task', '2025-07-13 16:50:56', '2025-07-13 16:50:56'),
(96, 'my-task.create', 'Create My Task', '2025-07-13 16:50:56', '2025-07-13 16:50:56'),
(97, 'my-task.update', 'Update My Task', '2025-07-13 16:50:56', '2025-07-13 16:50:56'),
(98, 'my-task.delete', 'Delete My Task', '2025-07-13 16:50:56', '2025-07-13 16:50:56');

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
  `permission_id` int DEFAULT NULL,
  `module` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`id`, `role_id`, `permission_id`, `module`, `action`, `created_at`, `updated_at`) VALUES
(160, 1, 75, 'project', 'view', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(161, 1, 76, 'project', 'create', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(162, 1, 77, 'project', 'update', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(163, 1, 78, 'project', 'delete', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(164, 1, 63, 'customer', 'view', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(165, 1, 64, 'customer', 'create', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(166, 1, 65, 'customer', 'update', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(167, 1, 66, 'customer', 'delete', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(172, 1, 43, 'department', 'view', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(173, 1, 44, 'department', 'create', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(174, 1, 45, 'department', 'update', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(175, 1, 46, 'department', 'delete', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(180, 1, 67, 'document', 'view', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(181, 1, 68, 'document', 'create', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(182, 1, 69, 'document', 'update', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(183, 1, 70, 'document', 'delete', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(184, 1, 71, 'permission', 'view', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(185, 1, 72, 'permission', 'create', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(186, 1, 73, 'permission', 'update', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(187, 1, 74, 'permission', 'delete', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(188, 1, 37, 'setting', 'view', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(189, 1, 60, 'setting', 'create', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(190, 1, 38, 'setting', 'update', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(191, 1, 62, 'setting', 'delete', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(196, 1, 87, 'gantt', 'view', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(197, 1, 88, 'gantt', 'create', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(198, 1, 89, 'gantt', 'update', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(199, 1, 90, 'gantt', 'delete', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(200, 1, 91, 'step-template', 'view', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(201, 1, 92, 'step-template', 'create', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(202, 1, 93, 'step-template', 'update', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(203, 1, 94, 'step-template', 'delete', '2025-07-13 16:30:39', '2025-07-13 16:38:24'),
(216, 1, NULL, 'my-task', 'view', '2025-07-13 20:50:18', '2025-07-13 20:50:18'),
(217, 1, NULL, 'my-task', 'create', '2025-07-13 20:50:18', '2025-07-13 20:50:18'),
(218, 1, NULL, 'my-task', 'update', '2025-07-13 20:50:18', '2025-07-13 20:50:18'),
(219, 1, NULL, 'my-task', 'delete', '2025-07-13 20:50:18', '2025-07-13 20:50:18'),
(220, 1, NULL, 'approval', 'view', '2025-07-13 20:50:30', '2025-07-13 20:50:30'),
(221, 1, NULL, 'approval', 'create', '2025-07-13 20:50:30', '2025-07-13 20:50:30'),
(222, 1, NULL, 'approval', 'update', '2025-07-13 20:50:30', '2025-07-13 20:50:30'),
(223, 1, NULL, 'approval', 'delete', '2025-07-13 20:50:30', '2025-07-13 20:50:30'),
(224, 1, NULL, 'task', 'view', '2025-07-13 20:51:12', '2025-07-13 20:51:12'),
(228, 1, NULL, 'contract', 'view', '2025-07-13 20:52:33', '2025-07-13 20:52:33'),
(229, 1, NULL, 'contract', 'create', '2025-07-13 20:52:33', '2025-07-13 20:52:33'),
(230, 1, NULL, 'contract', 'update', '2025-07-13 20:52:33', '2025-07-13 20:52:33'),
(231, 1, NULL, 'contract', 'delete', '2025-07-13 20:52:33', '2025-07-13 20:52:33'),
(232, 1, NULL, 'bidding', 'view', '2025-07-13 20:52:46', '2025-07-13 20:52:46'),
(233, 1, NULL, 'bidding', 'create', '2025-07-13 20:52:46', '2025-07-13 20:52:46'),
(234, 1, NULL, 'bidding', 'update', '2025-07-13 20:52:46', '2025-07-13 20:52:46'),
(235, 1, NULL, 'bidding', 'delete', '2025-07-13 20:52:46', '2025-07-13 20:52:46'),
(236, 1, NULL, 'user', 'view', '2025-07-14 22:01:59', '2025-07-14 22:01:59'),
(237, 1, NULL, 'user', 'create', '2025-07-14 22:01:59', '2025-07-14 22:01:59'),
(238, 1, NULL, 'user', 'update', '2025-07-14 22:01:59', '2025-07-14 22:01:59'),
(239, 1, NULL, 'user', 'delete', '2025-07-14 22:01:59', '2025-07-14 22:01:59'),
(240, 3, NULL, 'task', 'view', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(244, 3, NULL, 'document', 'view', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(245, 3, NULL, 'document', 'create', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(246, 3, NULL, 'document', 'update', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(247, 3, NULL, 'document', 'delete', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(248, 3, NULL, 'project', 'view', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(249, 3, NULL, 'project', 'create', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(250, 3, NULL, 'project', 'update', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(251, 3, NULL, 'project', 'delete', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(252, 3, NULL, 'step-template', 'view', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(253, 3, NULL, 'step-template', 'create', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(254, 3, NULL, 'step-template', 'update', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(255, 3, NULL, 'step-template', 'delete', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(256, 3, NULL, 'my-task', 'view', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(257, 3, NULL, 'my-task', 'create', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(258, 3, NULL, 'my-task', 'update', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(259, 3, NULL, 'my-task', 'delete', '2025-07-14 22:12:00', '2025-07-14 22:12:00'),
(260, 3, NULL, 'contract', 'view', '2025-07-14 22:20:20', '2025-07-14 22:20:20'),
(261, 3, NULL, 'contract', 'create', '2025-07-14 22:20:20', '2025-07-14 22:20:20'),
(262, 3, NULL, 'contract', 'update', '2025-07-14 22:20:20', '2025-07-14 22:20:20'),
(263, 3, NULL, 'contract', 'delete', '2025-07-14 22:20:20', '2025-07-14 22:20:20'),
(272, 3, NULL, 'department', 'view', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(273, 3, NULL, 'department', 'create', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(274, 3, NULL, 'department', 'update', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(275, 3, NULL, 'department', 'delete', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(276, 3, NULL, 'bidding', 'view', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(277, 3, NULL, 'bidding', 'create', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(278, 3, NULL, 'bidding', 'update', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(279, 3, NULL, 'bidding', 'delete', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(280, 3, NULL, 'customer', 'view', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(281, 3, NULL, 'customer', 'create', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(282, 3, NULL, 'customer', 'update', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(283, 3, NULL, 'customer', 'delete', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(292, 3, NULL, 'gantt', 'view', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(293, 3, NULL, 'gantt', 'create', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(294, 3, NULL, 'gantt', 'update', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(295, 3, NULL, 'gantt', 'delete', '2025-07-14 22:21:04', '2025-07-14 22:21:04'),
(296, 3, NULL, 'task', 'create', '2025-07-14 22:21:57', '2025-07-14 22:21:57'),
(297, 3, NULL, 'task', 'update', '2025-07-14 22:21:57', '2025-07-14 22:21:57'),
(298, 3, NULL, 'task', 'delete', '2025-07-14 22:21:57', '2025-07-14 22:21:57'),
(299, 1, NULL, 'task', 'create', '2025-07-14 22:39:53', '2025-07-14 22:39:53'),
(300, 1, NULL, 'task', 'update', '2025-07-14 22:39:53', '2025-07-14 22:39:53'),
(301, 1, NULL, 'task', 'delete', '2025-07-14 22:39:53', '2025-07-14 22:39:53'),
(302, 1, NULL, 'comment', 'view', '2025-07-14 22:39:53', '2025-07-14 22:39:53'),
(303, 1, NULL, 'comment', 'create', '2025-07-14 22:39:53', '2025-07-14 22:39:53'),
(304, 1, NULL, 'comment', 'update', '2025-07-14 22:39:53', '2025-07-14 22:39:53'),
(305, 1, NULL, 'comment', 'delete', '2025-07-14 22:39:53', '2025-07-14 22:39:53'),
(306, 2, NULL, 'user', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(307, 2, NULL, 'user', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(308, 2, NULL, 'user', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(309, 2, NULL, 'user', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(310, 2, NULL, 'setting', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(311, 2, NULL, 'setting', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(312, 2, NULL, 'setting', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(313, 2, NULL, 'setting', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(314, 2, NULL, 'task', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(315, 2, NULL, 'task', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(316, 2, NULL, 'task', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(317, 2, NULL, 'task', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(318, 2, NULL, 'department', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(319, 2, NULL, 'department', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(320, 2, NULL, 'department', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(321, 2, NULL, 'department', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(322, 2, NULL, 'contract', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(323, 2, NULL, 'contract', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(324, 2, NULL, 'contract', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(325, 2, NULL, 'contract', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(326, 2, NULL, 'bidding', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(327, 2, NULL, 'bidding', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(328, 2, NULL, 'bidding', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(329, 2, NULL, 'bidding', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(330, 2, NULL, 'customer', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(331, 2, NULL, 'customer', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(332, 2, NULL, 'customer', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(333, 2, NULL, 'customer', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(334, 2, NULL, 'document', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(335, 2, NULL, 'document', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(336, 2, NULL, 'document', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(337, 2, NULL, 'document', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(338, 2, NULL, 'permission', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(339, 2, NULL, 'permission', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(340, 2, NULL, 'permission', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(341, 2, NULL, 'permission', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(342, 2, NULL, 'project', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(343, 2, NULL, 'project', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(344, 2, NULL, 'project', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(345, 2, NULL, 'project', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(346, 2, NULL, 'comment', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(347, 2, NULL, 'comment', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(348, 2, NULL, 'comment', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(349, 2, NULL, 'comment', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(350, 2, NULL, 'approval', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(351, 2, NULL, 'approval', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(352, 2, NULL, 'approval', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(353, 2, NULL, 'approval', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(354, 2, NULL, 'gantt', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(355, 2, NULL, 'gantt', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(356, 2, NULL, 'gantt', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(357, 2, NULL, 'gantt', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(358, 2, NULL, 'step-template', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(359, 2, NULL, 'step-template', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(360, 2, NULL, 'step-template', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(361, 2, NULL, 'step-template', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(362, 2, NULL, 'my-task', 'view', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(363, 2, NULL, 'my-task', 'create', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(364, 2, NULL, 'my-task', 'update', '2025-07-14 22:56:36', '2025-07-14 22:56:36'),
(365, 2, NULL, 'my-task', 'delete', '2025-07-14 22:56:36', '2025-07-14 22:56:36');

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
  `parent_id` int DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `assigned_to` int NOT NULL,
  `proposed_by` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('todo','doing','done','overdue','request_approval') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'todo',
  `approval_status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `linked_type` enum('bidding','contract','internal') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'internal',
  `linked_id` int DEFAULT NULL,
  `step_code` int DEFAULT NULL,
  `step_id` int DEFAULT NULL,
  `created_by` int NOT NULL,
  `priority` enum('low','normal','high') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'normal',
  `comments_count` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `approval_steps` int DEFAULT '1',
  `current_level` int DEFAULT '1',
  `id_department` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `parent_id`, `title`, `description`, `assigned_to`, `proposed_by`, `start_date`, `end_date`, `status`, `approval_status`, `linked_type`, `linked_id`, `step_code`, `step_id`, `created_by`, `priority`, `comments_count`, `created_at`, `updated_at`, `approval_steps`, `current_level`, `id_department`) VALUES
(1, NULL, 'Thiết kế hồ sơ thầu', 'Chuẩn bị file bản vẽ và hồ sơ năng lực', 5, 4, '2025-07-01', '2025-08-25', 'request_approval', 'pending', 'bidding', 2, 4, 112, 1, 'normal', 0, '2025-06-04 01:23:15', '2025-07-20 15:21:54', 1, 1, 4),
(2, NULL, 'Thiết kế hồ sơ thầu', 'Mô tả công việc thiết kế hồ sơ thầu', 3, 2, '2025-06-25', '2025-07-31', 'done', 'approved', 'bidding', 6, 5, 237, 2, 'high', 1, '2025-06-04 01:37:15', '2025-07-20 15:21:54', 1, 1, 5),
(3, NULL, 'Nghiên cứu yêu cầu khách hàng', 'Mô tả công việc nghiên cứu yêu cầu khách hàng', 9, 4, '2025-06-29', '2025-07-31', 'todo', 'rejected', 'contract', 30, 16, 265, 1, 'high', 3, '2025-06-04 01:37:24', '2025-07-20 15:21:54', 1, 1, 5),
(10, NULL, 'Mua sắm vật tư', 'Mô tả công việc mua sắm vật tư', 10, 2, '2025-06-25', '2025-07-31', 'todo', 'rejected', 'bidding', 2, 3, 111, 2, 'high', 5, '2025-06-04 01:38:26', '2025-07-20 15:21:54', 1, 1, 5),
(22, 3, 'Sửa tên subtask', 'Thiết kế giao diện cho phần chi tiết', 9, 4, NULL, '2025-06-15', '', 'pending', 'internal', NULL, 8, NULL, 1, 'high', 0, '2025-06-04 19:29:35', '2025-07-20 15:21:54', 1, 1, 4),
(26, 3, 'Thiết kế giao diện phụ - task con 3', 'Thiết kế giao diện cho phần chi tiết', 9, 2, NULL, '2025-06-15', 'todo', 'pending', 'bidding', 2, 3, 111, 1, 'high', 0, '2025-06-05 05:38:39', '2025-07-20 15:21:54', 1, 1, 3),
(27, NULL, 'Task thuộc bước 1 - Gói thầu có ngay bat dau - ngay ket thuc', 'Mô tả công việc đăng ký bảo hành', 1, 4, '2025-06-10', '2025-06-14', 'done', 'approved', 'bidding', 2, 1, 109, 3, 'high', 0, '2025-06-05 06:16:42', '2025-07-20 15:21:54', 1, 1, 1),
(28, 3, 'Thiết kế giao diện phụ - task con 3 có ngay bat dau - ngay ket thuc', 'Thiết kế giao diện cho phần chi tiết', 17, 4, '2025-06-25', '2025-07-31', 'done', 'approved', 'bidding', 2, 3, 111, 1, 'normal', 0, '2025-06-05 06:19:14', '2025-07-20 15:21:54', 1, 1, 3),
(29, 18, 'sub task 1', 'tesst subtask', 13, 4, '2025-06-24', '2025-07-31', '', 'pending', 'bidding', 5, 5, 104, 1, 'normal', 0, '2025-06-23 18:15:50', '2025-07-20 15:21:54', 1, 1, 5),
(30, NULL, 'test', 'tesst tesst', 22, 1, '2025-06-24', '2025-07-30', 'done', 'approved', 'bidding', 5, 5, 104, 1, 'normal', 0, '2025-06-23 18:52:15', '2025-07-20 15:21:54', 1, 1, 1),
(31, NULL, 'Task thuộc bước 1 - Gói thầu có ngay bat dau - ngay ket thuc', 'Mô tả công việc đăng ký bảo hành', 1, 4, '2025-08-29', '2025-08-31', 'overdue', 'pending', 'bidding', 2, 3, 111, 3, 'high', 0, '2025-06-24 18:47:18', '2025-07-20 15:21:54', 1, 1, 4),
(32, 1, 'tesst subtask', 'xxxxxxx', 22, 4, '2025-06-28', '2025-07-31', 'done', 'approved', 'bidding', 2, 1, 109, 1, 'normal', 0, '2025-06-28 08:01:02', '2025-07-20 15:21:54', 1, 1, 3),
(33, NULL, 'test task mới', 'test', 3, 4, '2025-06-29', '2025-07-31', 'doing', 'pending', 'bidding', 5, 9, 130, 1, 'normal', 0, '2025-06-29 01:28:22', '2025-07-20 15:21:54', 1, 1, 2),
(34, NULL, 'test nhiêm vụ mới', 'test test', 7, 4, '2025-06-29', '2025-07-31', 'doing', 'pending', 'bidding', 2, 2, 110, 1, 'normal', 0, '2025-06-29 01:36:07', '2025-07-20 15:21:54', 1, 1, 1),
(35, NULL, 'test mới 3', 'test nhé', 7, 2, '2025-06-29', '2025-08-07', 'doing', 'pending', 'bidding', 8, 7, 79, 1, 'high', 0, '2025-06-29 01:51:48', '2025-07-20 15:21:54', 1, 1, 3),
(36, NULL, 'mới', 'đasadd', 9, 1, '2025-06-30', '2025-07-31', 'doing', 'pending', 'bidding', 2, 1, 109, 1, 'normal', 0, '2025-06-29 11:25:28', '2025-07-20 15:21:54', 1, 1, 5),
(37, NULL, 'test nhiệm vụ hợp đồng 1', 'test nhiệm vụ hợp đồng 1', 23, 1, '2025-06-30', '2025-07-31', 'doing', 'pending', 'contract', 30, 10, 259, 1, 'normal', 0, '2025-06-30 09:33:07', '2025-07-20 15:21:54', 1, 1, 5),
(38, NULL, 'test nhiệm vụ hợp đồng 2', 'test nhiệm vụ hợp đồng 2', 19, 4, '2025-06-30', '2025-07-29', 'doing', 'pending', 'contract', 30, 11, 260, 1, 'high', 0, '2025-06-30 09:37:45', '2025-07-20 15:21:54', 1, 1, 4),
(39, NULL, 'duyệt hợp đồng mua', 'duyệt hợp đồng mua', 21, 4, '2025-06-30', '2025-07-31', 'doing', 'pending', 'contract', 30, 12, 261, 1, 'high', 0, '2025-06-30 09:48:27', '2025-07-20 15:21:54', 1, 1, 2),
(40, NULL, 'nhiệm vụ cho gói thầu 1', 'test chấm thầu', 4, 1, '2025-07-10', '2025-08-05', 'doing', 'pending', 'bidding', 2, 6, 114, 1, 'normal', 0, '2025-06-30 09:54:52', '2025-07-20 15:21:54', 1, 1, 2),
(41, NULL, 'nhiệm vụ hợp đồng 2', 'nghiệm thu', 23, 1, '2025-06-30', '2025-07-31', 'doing', 'pending', 'contract', 30, 16, 265, 1, 'normal', 0, '2025-06-30 09:58:15', '2025-07-20 15:21:54', 1, 1, 4),
(42, NULL, 'test nhiệm vụ hợp đồng 4', 'kiểm tra hàng hóa', 1, 4, '2025-08-13', '2025-08-21', 'doing', 'pending', 'contract', 30, 15, 264, 1, 'high', 0, '2025-06-30 10:05:48', '2025-07-20 15:21:54', 1, 1, 4),
(43, NULL, 'test nhiệm vụ hợp đồng 5', 'kiểm tra hàng hóa', 1, 2, '2025-07-01', '2025-08-31', 'doing', 'pending', 'contract', 30, 15, 264, 1, 'normal', 0, '2025-06-30 10:10:57', '2025-07-20 15:21:54', 1, 1, 1),
(44, NULL, 'test nhiệm vụ hợp đồng 6', 'nghiệm thu', 24, 2, '2025-07-01', '2025-08-31', 'doing', 'pending', 'contract', 33, 16, 316, 1, 'normal', 0, '2025-06-30 10:12:22', '2025-07-20 15:21:54', 1, 1, 5),
(45, NULL, 'test nhiệm vụ gói thầu 7', 'chấm thầu', 24, 2, '2025-07-31', '2025-08-29', 'doing', 'pending', 'bidding', 3, 6, 123, 1, 'high', 0, '2025-06-30 10:13:58', '2025-07-20 15:21:54', 1, 1, 3),
(46, NULL, 'test hợp đồng 8', 'test hợp đồng 8', 1, 4, '2025-07-24', '2025-08-28', 'doing', 'pending', 'contract', 30, 10, 259, 1, 'high', 0, '2025-06-30 10:23:23', '2025-07-20 15:21:54', 1, 1, 1),
(47, NULL, 'nhiệm vụ mới', 'mô tả mẫu', 15, 4, '2025-07-01', '2025-08-28', 'doing', 'pending', 'bidding', 2, 1, 109, 1, 'normal', 0, '2025-07-01 04:00:46', '2025-07-20 15:21:54', 1, 1, 5),
(48, NULL, 'nhiệm vụ cho hợp đồng mới', 'mô tả mẫu', 20, 4, '2025-07-01', '2025-08-30', 'doing', 'pending', 'contract', 30, 15, 264, 1, 'normal', 0, '2025-07-01 04:07:24', '2025-07-20 15:21:54', 1, 1, 4),
(49, NULL, 'nhiệm vụ  phát sinh', 'nhiêm vụ phát sinh', 1, 4, '2025-08-30', '2025-08-31', 'doing', 'pending', 'bidding', 3, 1, 118, 1, 'high', 0, '2025-07-01 04:31:44', '2025-07-20 15:21:54', 1, 1, 2),
(50, NULL, 'nhiệm vụ mới 06/07', 'test task mới', 1, 1, '2025-07-06', '2025-08-27', 'doing', 'pending', 'bidding', 2, 3, 111, 1, 'high', 0, '2025-07-06 03:52:58', '2025-07-20 15:21:54', 2, 1, 3),
(51, NULL, 'test nhiệm vụ mới', 'demo', 6, 9, '2025-07-15', '2025-07-19', 'doing', 'pending', 'contract', 34, 16, 333, 1, 'high', 0, '2025-07-20 04:53:06', '2025-07-20 15:21:54', 0, 1, 5);

-- --------------------------------------------------------

--
-- Table structure for table `task_approvals`
--

CREATE TABLE `task_approvals` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `level` tinyint NOT NULL,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` int DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_approvals`
--

INSERT INTO `task_approvals` (`id`, `task_id`, `level`, `status`, `approved_by`, `approved_at`, `comment`) VALUES
(4, 3, 1, 'rejected', 1, '2025-07-06 13:45:36', 'vẫn chưa dc'),
(5, 10, 1, 'rejected', 1, '2025-07-06 13:50:29', 'van chua dc'),
(6, 2, 1, 'approved', 1, '2025-07-06 13:57:23', 'ok dc'),
(8, 27, 1, 'approved', 1, '2025-07-06 14:10:04', 'ok'),
(10, 28, 1, 'approved', 1, '2025-07-06 13:52:52', 'ok'),
(11, 30, 1, 'approved', 1, '2025-07-06 14:10:40', 'ok'),
(12, 32, 1, 'approved', 1, '2025-07-08 14:25:09', 'ok'),
(13, 1, 1, 'pending', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `task_approval_logs`
--

CREATE TABLE `task_approval_logs` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `level` int NOT NULL,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `approved_by` int DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_approval_logs`
--

INSERT INTO `task_approval_logs` (`id`, `task_id`, `level`, `status`, `approved_by`, `approved_at`, `comment`, `created_at`) VALUES
(1, 2, 1, 'approved', 1, '2025-07-06 13:57:23', 'ok dc', '2025-07-06 13:57:23'),
(2, 27, 1, 'approved', 1, '2025-07-06 14:10:04', 'ok', '2025-07-06 14:10:04'),
(3, 30, 1, 'approved', 1, '2025-07-06 14:10:40', 'ok', '2025-07-06 14:10:40'),
(4, 32, 1, 'approved', 1, '2025-07-08 14:25:09', 'ok', '2025-07-08 14:25:09');

-- --------------------------------------------------------

--
-- Table structure for table `task_comments`
--

CREATE TABLE `task_comments` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `user_id` int NOT NULL,
  `comment_id` int DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `uploaded_by` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_comments`
--

INSERT INTO `task_comments` (`id`, `task_id`, `user_id`, `comment_id`, `content`, `created_at`, `updated_at`, `file_name`, `file_path`, `uploaded_by`) VALUES
(1, 3, 8, 10, 'Đã nhận task và đang xử lý', '2025-06-04 10:06:02', '2025-06-27 02:06:38', NULL, NULL, NULL),
(3, 3, 8, 3, 'Đã cập nhật nội dung comment', '2025-06-04 10:06:17', '2025-06-27 02:06:38', NULL, NULL, NULL),
(4, 3, 8, 2, 'Đã nhận task và đang xử lý 44444', '2025-06-04 10:10:06', '2025-06-27 02:06:38', NULL, NULL, NULL),
(5, 3, 8, 1, 'Đây là comment kèm file', '2025-06-04 10:24:49', '2025-06-27 02:06:38', NULL, NULL, NULL),
(6, 3, 8, 9, 'Đây là comment kèm file', '2025-06-04 10:25:28', '2025-06-27 02:06:38', NULL, NULL, NULL),
(7, 3, 8, 3, 'Đây là comment kèm file 2222', '2025-06-04 10:25:51', '2025-06-27 02:06:38', NULL, NULL, NULL),
(13, 3, 8, 10, 'Đây là comment kèm file 9999', '2025-06-04 19:03:31', '2025-06-27 02:06:38', NULL, NULL, NULL),
(14, 3, 8, 2, 'Đây là comment kèm file 9999', '2025-06-04 19:03:59', '2025-06-27 02:06:38', NULL, NULL, NULL),
(15, 18, 1, 8, 'ok', '2025-06-23 18:16:55', '2025-06-27 02:06:38', NULL, NULL, NULL),
(16, 10, 1, 4, 'xxxxx', '2025-06-24 18:05:04', '2025-06-27 02:06:38', NULL, NULL, NULL),
(17, 3, 1, 5, 'test comment', '2025-06-26 18:31:40', '2025-06-27 02:06:38', NULL, NULL, NULL),
(18, 1, 1, 5, 'tesst comment task cos id là 1, có kèm file', '2025-06-26 18:50:17', '2025-06-27 02:06:38', NULL, NULL, NULL),
(19, 1, 1, 6, 'ok, hiển thị file rồi nhé', '2025-06-26 18:50:34', '2025-06-27 02:06:38', NULL, NULL, NULL),
(20, 22, 1, 6, 'test comment subtask - có kèm file', '2025-06-26 18:51:04', '2025-06-27 02:06:38', NULL, NULL, NULL),
(21, 3, 1, NULL, 'test', '2025-06-26 19:10:08', '2025-06-26 19:10:08', NULL, NULL, NULL),
(22, 3, 1, NULL, 'test mới', '2025-06-26 19:13:57', '2025-06-26 19:13:57', NULL, NULL, NULL),
(28, 3, 1, NULL, 'test comment có kèm file 4', '2025-06-26 19:26:35', '2025-06-26 19:26:35', 'company_image_demo_3.png', 'http://assets.worknest.local/files/1750991195_135fcf3c15b7a40c6907.png', NULL),
(29, 3, 1, NULL, 'test comment kèm file 5', '2025-06-26 19:27:25', '2025-06-26 19:27:25', '9b29de48e98b3674281f6f5a6be86d7f.png', 'http://assets.worknest.local/files/1750991245_539843ef1666129d9b88.png', NULL),
(30, 1, 1, NULL, 'tesse', '2025-06-27 07:39:39', '2025-06-27 07:39:39', 'z4162527418501-a6d02d439cc8529-8174-3128-1678410959.jpg', 'http://assets.worknest.local/files/1751035179_959e2a1021859cd45d72.jpg', NULL),
(31, 47, 1, NULL, 'comment mới', '2025-07-01 04:03:52', '2025-07-01 04:03:52', 'zalo_sharelogo.png', 'http://assets.worknest.local/files/1751367832_a433d54a7fdf00ac5670.png', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `task_extensions`
--

CREATE TABLE `task_extensions` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `extended_by` int NOT NULL,
  `old_end_date` datetime NOT NULL,
  `new_end_date` datetime NOT NULL,
  `reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_extensions`
--

INSERT INTO `task_extensions` (`id`, `task_id`, `extended_by`, `old_end_date`, `new_end_date`, `reason`, `created_at`, `updated_at`) VALUES
(1, 45, 1, '2025-08-28 00:00:00', '2025-07-31 00:00:00', 'Gia hạn thời gian', '2025-07-09 21:47:32', '2025-07-09 21:47:32'),
(2, 45, 1, '2025-07-31 00:00:00', '2025-08-31 00:00:00', 'Gia hạn thời gian', '2025-07-09 21:57:18', '2025-07-09 21:57:18'),
(3, 45, 1, '2025-08-31 00:00:00', '2025-07-25 00:00:00', 'Gia hạn thời gian', '2025-07-09 21:58:03', '2025-07-09 21:58:03'),
(4, 45, 1, '2025-07-25 00:00:00', '2025-07-31 00:00:00', 'Gia hạn thời gian', '2025-07-09 21:58:19', '2025-07-09 21:58:19'),
(5, 45, 1, '2025-07-31 00:00:00', '2025-08-25 00:00:00', 'Gia hạn thời gian', '2025-07-09 21:58:31', '2025-07-09 21:58:31'),
(6, 45, 1, '2025-08-25 00:00:00', '2025-08-12 00:00:00', 'Gia hạn thời gian', '2025-07-09 21:58:44', '2025-07-09 21:58:44'),
(7, 45, 1, '2025-08-12 00:00:00', '2025-08-29 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:43:41', '2025-07-09 22:43:41'),
(8, 31, 1, '2025-06-14 00:00:00', '2025-07-31 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:50:50', '2025-07-09 22:50:50'),
(9, 31, 1, '2025-07-31 00:00:00', '2025-08-05 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:51:05', '2025-07-09 22:51:05'),
(10, 31, 1, '2025-08-05 00:00:00', '2025-08-10 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:51:32', '2025-07-09 22:51:32'),
(11, 42, 1, '2025-08-26 00:00:00', '2025-08-11 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:52:24', '2025-07-09 22:52:24'),
(12, 42, 1, '2025-08-11 00:00:00', '2025-08-21 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:52:44', '2025-07-09 22:52:44'),
(13, 46, 1, '2025-08-29 00:00:00', '2025-08-28 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:53:03', '2025-07-09 22:53:03'),
(14, 49, 1, '2025-08-29 00:00:00', '2025-08-31 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:53:50', '2025-07-09 22:53:50'),
(15, 31, 1, '2025-08-10 00:00:00', '2025-08-31 00:00:00', 'Gia hạn thời gian', '2025-07-09 22:58:48', '2025-07-09 22:58:48'),
(16, 51, 1, '2025-07-29 00:00:00', '2025-07-19 00:00:00', 'Gia hạn thời gian', '2025-07-20 05:46:44', '2025-07-20 05:46:44');

-- --------------------------------------------------------

--
-- Table structure for table `task_files`
--

CREATE TABLE `task_files` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `comment_id` int DEFAULT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `link_url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `is_link` tinyint(1) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_files`
--

INSERT INTO `task_files` (`id`, `task_id`, `comment_id`, `file_name`, `title`, `file_path`, `uploaded_by`, `link_url`, `created_at`, `updated_at`, `is_link`) VALUES
(7, 3, 9, 'youtube.png', 'Tài liệu C - 202', 'http://assets.worknest.local/files/1749058695_5d6e504e75601e256df4.png', 8, 'https://example.com/file-9719', '2025-06-04 10:38:15', '2025-06-04 17:38:15', 0),
(9, 5, 11, 'youtube.png', 'Tài liệu D - 531', 'http://assets.worknest.local/files/1749127936_5303eae0ad80c4b5bc44.png', 8, 'https://example.com/file-2956', '2025-06-05 05:52:16', '2025-06-05 12:52:16', 0),
(10, 18, 12, '5143502cd2109cb8dd2a45aec031de58.png', 'Tài liệu C - 621', 'http://assets.worknest.local/files/1750727815_2676b044eb8b2c255b37.png', 1, 'https://example.com/file-5623', '2025-06-23 18:16:55', '2025-06-24 01:16:55', 0),
(11, 10, 13, '7c2df40f40dcb45f66ac55d4e7b5702c.png', 'Tài liệu D - 028', 'http://assets.worknest.local/files/1750813504_712b18707a60302bb07e.png', 1, 'https://example.com/file-9249', '2025-06-24 18:05:04', '2025-06-25 01:05:04', 0),
(13, 1, 18, 'cropped-logo.png', 'Tài liệu B - 763', 'http://assets.worknest.local/files/1750989017_2dd3ca4ddbad686cdb81.png', 1, 'https://example.com/file-9376', '2025-06-26 18:50:17', '2025-06-27 01:50:17', 0),
(14, 1, 19, '0ad3eb5e73f5bca3c12da468cf3eb09f.png', 'Tài liệu E - 976', 'http://assets.worknest.local/files/1750989034_dccaa25a1226746b6ce0.png', 1, 'https://example.com/file-9135', '2025-06-26 18:50:34', '2025-06-27 01:50:34', 0),
(15, 22, 20, 'c9f4e889c38c6c40a38017072d3d6f74.png', 'Tài liệu B - 680', 'http://assets.worknest.local/files/1750989064_7b53c00c18aca4cda3b9.png', 1, 'https://example.com/file-7548', '2025-06-26 18:51:04', '2025-06-27 01:51:04', 0),
(17, 3, NULL, '0ad3eb5e73f5bca3c12da468cf3eb09f.png', 'Tài liệu B - 428', 'http://assets.worknest.local/files/1750991281_778382074d78c2bc4798.png', 1, 'https://example.com/file-336', '2025-06-26 19:28:01', '2025-06-27 02:28:01', 0),
(18, 3, NULL, 'product_image_demo_1.png', 'Tài liệu A - 937', 'http://assets.worknest.local/files/1750991281_51bf78bfe6d75ab6bd58.png', 1, 'https://example.com/file-9037', '2025-06-26 19:28:01', '2025-06-27 02:28:01', 0),
(19, 12, NULL, 'z4162527460588-39df1cc6aef941b-2286-5883-1678410959.jpg', 'Tài liệu C - 954', 'http://assets.worknest.local/files/1751035690_f23b12ab04567fe01d91.jpg', 1, 'https://example.com/file-4174', '2025-06-27 07:48:10', '2025-06-27 14:48:10', 0),
(20, 1, NULL, 'namecheap-order-170207799.pdf', 'Tài liệu A - 694', 'http://assets.worknest.local/files/1751122772_e852606a5f515a222404.pdf', 1, 'https://example.com/file-3763', '2025-06-28 07:59:32', '2025-06-28 14:59:32', 0),
(21, 1, NULL, '20240819HCNS_KHLVTuan34DinhVanVinhT01.xlsx', 'Tài liệu A - 598', 'http://assets.worknest.local/files/1751122772_1b9c09abd8da72396783.xlsx', 1, 'https://example.com/file-6291', '2025-06-28 07:59:32', '2025-06-28 14:59:32', 0),
(22, 2, NULL, '20240819HCNS_KHLVTuan34DinhVanVinhT01.xlsx', 'Tài liệu C - 120', 'http://assets.worknest.local/files/1751123519_4400d016e6c67c6e418e.xlsx', 1, 'https://example.com/file-168', '2025-06-28 08:11:59', '2025-06-28 15:11:59', 0),
(23, 47, NULL, 'Bao_gia_phat_trien_he_thong.docx', 'Tài liệu E - 910', 'http://assets.worknest.local/files/1751367803_91d4c2597ef92425dfca.docx', 1, 'https://example.com/file-1965', '2025-07-01 04:03:23', '2025-07-01 11:03:23', 0),
(24, 29, NULL, 'zalo_sharelogo.png', NULL, 'http://assets.worknest.local/files/1751816153_4ce1ccefa5405f03e6a3.png', 1, 'https://example.com/file-9325', '2025-07-06 08:35:53', '2025-07-06 15:35:53', 0),
(25, 29, NULL, 'youtube.png', NULL, 'http://assets.worknest.local/files/1751816206_c9bc8dcc5b266ed33ea2.png', 1, 'https://example.com/file-727', '2025-07-06 08:36:46', '2025-07-06 15:36:46', 0),
(26, 29, NULL, 'youtube.png', NULL, 'http://assets.worknest.local/files/1751816480_d114aa357c1f612414b6.png', 1, 'https://example.com/file-5663', '2025-07-06 08:41:20', '2025-07-06 15:41:20', 0),
(28, 29, NULL, 'Gói KVM 2.doc', 'tài liệu 2', 'http://assets.worknest.local/files/1751816750_3fb0d51efe9822d1890a.doc', 1, 'https://example.com/file-6136', '2025-07-06 08:45:50', '2025-07-06 15:45:50', 0),
(29, 29, NULL, '6833c7043c39e-abc-test-ho-so.docx', 'tài liệu 4', 'http://assets.worknest.local/files/1751816894_b62d4539cde2a2db082e.docx', 1, 'https://example.com/file-3689', '2025-07-06 08:48:14', '2025-07-06 15:48:14', 0),
(30, 29, NULL, '6833c7043c39e-abc-test-ho-so.docx', 'test tài liệu', 'http://assets.worknest.local/files/1751817141_c0e016c55a3bc6e5093f.docx', 1, 'https://example.com/file-39', '2025-07-06 08:52:21', '2025-07-06 15:52:21', 0),
(32, 3, NULL, 'Gói KVM 2.doc', 'tài liệu máy chủ', 'http://assets.worknest.local/files/1751817835_4f0ef3fb347c6887c109.doc', 1, 'https://example.com/file-9130', '2025-07-06 09:03:55', '2025-07-06 16:03:55', 0),
(33, 3, NULL, 'Gói KVM 2.doc', 'tài liệu mới 2', 'http://assets.worknest.local/files/1751817885_44fba7f3c29f59f15d83.doc', 1, 'https://example.com/file-5532', '2025-07-06 09:04:46', '2025-07-06 16:04:46', 0),
(36, 3, NULL, 'link tài liệu 4', NULL, NULL, 1, 'https://vnexpress.net/', '2025-07-06 09:52:21', '2025-07-06 16:52:21', 1),
(39, 3, NULL, 'https://vnexpress.net/', NULL, NULL, 1, 'https://vnexpress.net/', '2025-07-06 10:05:00', '2025-07-06 17:05:00', 1),
(41, 1, NULL, 'tài liệu hợp đồng', NULL, NULL, 1, 'https://mintoku.vccdev.vn/univer-jobfair/wp-admin/post.php?post=523&action=edit', '2025-07-08 07:32:22', '2025-07-08 14:32:22', 1);

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
(1, 'demo@example.com', '$2y$10$X0AYs8k7Dw8fbMqF9DzxiuBhQzGzu.ehudtC.2SWOjA4tsTZK0sYG', '2025-04-07 18:49:01', '2025-07-14 22:54:59', 'Nguyễn Văn A', '0988888888', 'avatars/1749049795_4087ec00b95ac222533a.png', 'super admin', 1, 2),
(3, 'superadmin@example.com', '$2y$10$kJ6V.Isy8GCV6kRwFekdEuS/PvVzBe4PTeQUqpWvnW3efeyhbg4Hq', '2025-04-20 14:02:38', '2025-07-14 22:52:57', 'Super Admin', '0988888888', NULL, 'super admin', 2, 1),
(4, 'nguyenvana@example.com', '$2y$10$X0AYs8k7Dw8fbMqF9DzxiuBhQzGzu.ehudtC.2SWOjA4tsTZK0sYG', '2025-05-26 04:33:21', '2025-07-14 22:13:40', 'Nguyễn Văn A', '0909123456', NULL, 'customer', 2, 3),
(5, 'a@worknest.vn', '$2y$10$fPUyT/hhSHhPknmvWgPtxelsaQfNLRiOVZ3Wayj2tbcNo4lApUFEW', '2025-06-04 09:10:50', '2025-07-14 16:27:49', 'Nguyễn Vân Anh', '0911111111', NULL, 'customer', 1, NULL),
(6, 'b@worknest.vn', '$2y$10$ZKKb/DZ/dk0eFQW/xfG3Ne8Ozrdt1TcQcR1alq4KP5biJpmUm2Uuy', '2025-06-04 09:11:21', '2025-07-14 15:34:45', 'Trần Thị B', '0911111112', NULL, 'customer', 1, NULL),
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
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_permission` (`role_id`,`module`,`action`);

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
-- Indexes for table `task_approvals`
--
ALTER TABLE `task_approvals`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_approval_logs`
--
ALTER TABLE `task_approval_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_comments`
--
ALTER TABLE `task_comments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_extensions`
--
ALTER TABLE `task_extensions`
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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `bidding_steps`
--
ALTER TABLE `bidding_steps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=282;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `contract_steps`
--
ALTER TABLE `contract_steps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=344;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `document_permissions`
--
ALTER TABLE `document_permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=229;

--
-- AUTO_INCREMENT for table `document_settings`
--
ALTER TABLE `document_settings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=99;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=366;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `task_approvals`
--
ALTER TABLE `task_approvals`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `task_approval_logs`
--
ALTER TABLE `task_approval_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `task_comments`
--
ALTER TABLE `task_comments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `task_extensions`
--
ALTER TABLE `task_extensions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `task_files`
--
ALTER TABLE `task_files`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

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
