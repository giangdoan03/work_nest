-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Dec 03, 2025 at 09:26 AM
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
-- Table structure for table `approval_instances`
--

CREATE TABLE `approval_instances` (
  `id` bigint UNSIGNED NOT NULL,
  `target_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_id` bigint UNSIGNED NOT NULL,
  `version` int NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `status` enum('not_sent','pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'not_sent',
  `current_level` int NOT NULL DEFAULT '0',
  `submitted_by` bigint UNSIGNED DEFAULT NULL,
  `submitted_at` datetime DEFAULT NULL,
  `finalized_at` datetime DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `meta_json` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_instances`
--

INSERT INTO `approval_instances` (`id`, `target_type`, `target_id`, `version`, `is_active`, `status`, `current_level`, `submitted_by`, `submitted_at`, `finalized_at`, `notes`, `meta_json`, `created_at`, `updated_at`) VALUES
(1, 'task', 26, 1, 1, 'approved', 0, 3, '2025-08-31 17:16:27', '2025-08-31 10:42:14', NULL, '{\"url\": \"/non-workflow/tasks/26/info\", \"title\": \"Thiết kế giao diện phu-task con 3\"}', '2025-08-31 17:16:27', '2025-09-28 22:27:14'),
(2, 'task', 240, 1, 1, 'approved', 0, 3, '2025-08-31 10:20:41', '2025-08-31 10:52:01', NULL, '{\"url\": \"/non-workflow/tasks/240/info\", \"title\": \"34535345\", \"assignee_name\": null}', '2025-08-31 17:20:41', '2025-09-28 22:27:14'),
(3, 'bidding', 4, 1, 1, 'approved', 1, 3, '2025-08-31 10:39:36', '2025-08-31 14:05:26', NULL, '{\"url\": \"/bid-detail/4\", \"title\": \"Cung cấp hệ thống điều khiển trung tâm cho Nhiệt điện Hải Phòng\"}', '2025-08-31 10:39:36', '2025-09-01 11:11:55'),
(4, 'bidding', 38, 1, 0, 'approved', 0, 3, '2025-08-31 14:11:36', '2025-08-31 14:12:08', NULL, '{\"url\": \"/bid-detail/38/\", \"title\": \"gói thầu mới 3\"}', '2025-08-31 14:11:36', '2025-09-01 04:18:42'),
(5, 'bidding', 37, 1, 1, 'approved', 0, 3, '2025-08-31 14:11:42', '2025-08-31 14:11:56', NULL, '{\"url\": \"/bid-detail/37/\", \"title\": \"gói thầu mới 23-08\"}', '2025-08-31 14:11:42', '2025-09-01 11:12:11'),
(6, 'bidding', 9, 1, 1, 'approved', 0, 3, '2025-08-31 14:21:11', '2025-08-31 14:21:23', NULL, '{\"url\": \"/bid-detail/9/\", \"title\": \"Lắp đặt hệ thống điện chiếu sáng – Nhiệt điện Sông Hậu\"}', '2025-08-31 14:21:11', '2025-09-01 11:12:17'),
(7, 'bidding', 7, 1, 1, 'approved', 0, 3, '2025-08-31 14:22:21', '2025-08-31 14:23:14', NULL, '{\"url\": \"/bid-detail/7/\", \"title\": \"Cung cấp vật tư phòng cháy chữa cháy – Nhiệt điện Ô Môn\"}', '2025-08-31 14:22:21', '2025-09-01 11:12:24'),
(8, 'bidding', 6, 1, 1, 'approved', 0, 3, '2025-08-31 14:23:47', '2025-08-31 14:24:09', NULL, '{\"url\": \"/bid-detail/6/\", \"title\": \"Gói thầu bảo trì định kỳ năm 2025 – Nhiệt điện Mông Dương\"}', '2025-08-31 14:23:47', '2025-09-01 11:12:30'),
(9, 'bidding', 2, 1, 1, 'approved', 0, 3, '2025-08-31 14:55:02', '2025-08-31 14:55:09', NULL, '{\"url\": \"/bid-detail/2/\", \"title\": \"Gói thầu cung cấp turbine cho Nhiệt điện Quảng Ninh\"}', '2025-08-31 14:55:02', '2025-09-01 11:12:36'),
(10, 'bidding', 11, 1, 1, 'approved', 0, 3, '2025-08-31 14:58:23', '2025-08-31 14:58:32', NULL, '{\"url\": \"/bid-detail/11/\", \"title\": \"Gói thầu thuê ngoài dịch vụ an ninh – Nhiệt điện Thái Bình 2\"}', '2025-08-31 14:58:23', '2025-09-01 11:12:44'),
(11, 'task', 238, 1, 1, 'pending', 0, 3, '2025-08-31 14:59:25', NULL, NULL, '{\"url\": \"/non-workflow/tasks/238/info\", \"title\": \"xxxxxx\", \"assignee_name\": null}', '2025-08-31 21:59:25', '2025-09-28 22:27:14'),
(12, 'task', 243, 1, 1, 'pending', 0, 3, '2025-08-31 15:25:06', NULL, NULL, '{\"url\": \"/non-workflow/tasks/243/info\", \"title\": \"4233243242\", \"assignee_name\": null}', '2025-08-31 22:25:06', '2025-09-28 22:27:14'),
(13, 'bidding', 10, 1, 0, 'pending', 0, 3, '2025-09-01 01:34:21', NULL, NULL, '{\"url\": \"/bid-detail/10/\", \"title\": \"Cung cấp hệ thống xử lý nước thải công nghiệp – Nhiệt điện Phú Mỹ\"}', '2025-09-01 01:34:21', '2025-09-01 11:12:51'),
(14, 'bidding', 10, 2, 1, 'approved', 0, 3, '2025-09-01 01:53:06', '2025-09-01 04:17:22', NULL, '{\"url\": \"/bid-detail/10/\", \"title\": \"Cung cấp hệ thống xử lý nước thải công nghiệp – Nhiệt điện Phú Mỹ\"}', '2025-09-01 01:53:06', '2025-09-01 04:17:22'),
(15, 'bidding', 38, 2, 1, 'approved', 0, 3, '2025-09-01 04:18:42', '2025-10-02 15:17:25', NULL, '{\"url\": \"/bid-detail/38\", \"title\": \"gói thầu mới 3\"}', '2025-09-01 04:18:42', '2025-10-02 15:17:25'),
(16, 'task', 199, 1, 1, 'approved', 0, 3, '2025-09-01 05:28:41', '2025-09-01 05:28:56', NULL, '{\"url\": \"/non-workflow/tasks/199/info\", \"title\": \"tesst mới\", \"assignee_name\": null}', '2025-09-01 12:28:41', '2025-09-28 22:27:14'),
(17, 'task', 200, 1, 1, 'approved', 0, 3, '2025-09-01 05:29:17', '2025-09-01 05:29:25', NULL, '{\"url\": \"/non-workflow/tasks/200/info\", \"title\": \"test 2\", \"assignee_name\": null}', '2025-09-01 12:29:17', '2025-09-28 22:27:14'),
(18, 'bidding_step', 284, 1, 1, 'approved', 0, 3, '2025-09-01 06:51:06', '2025-09-07 09:40:47', NULL, '{\"url\": \"/biddings/35/info\", \"title\": \"Bước 1: Nhận nhu cầu khách hàng\"}', '2025-09-01 06:51:06', '2025-09-07 09:40:47'),
(19, 'bidding_step', 285, 1, 1, 'approved', 0, 3, '2025-09-01 06:51:27', '2025-09-07 09:42:37', NULL, '{\"url\": \"/biddings/35/info\", \"title\": \"Bước 2: Đánh giá tính khả thi\"}', '2025-09-01 06:51:27', '2025-09-07 09:42:37'),
(20, 'bidding_step', 286, 1, 1, 'approved', 0, 3, '2025-09-01 07:59:15', '2025-09-07 09:54:40', NULL, '{\"url\": \"/biddings/35/info\", \"title\": \"Bước 3: Lập kế hoạch triển khai\"}', '2025-09-01 07:59:15', '2025-09-07 09:54:40'),
(21, 'bidding_step', 290, 1, 1, 'approved', 0, 3, '2025-09-01 08:48:33', '2025-09-07 09:37:39', NULL, '{\"url\": \"/biddings/35/info\", \"title\": \"Bước 7: Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)\"}', '2025-09-01 08:48:33', '2025-09-07 09:37:39'),
(22, 'task', 250, 1, 1, 'pending', 0, 3, '2025-09-06 04:30:48', NULL, NULL, '{\"url\": \"/non-workflow/tasks/250/info\", \"title\": \"việc con mới\", \"assignee_name\": null}', '2025-09-06 11:30:48', '2025-09-28 22:27:14'),
(23, 'task', 245, 1, 1, 'approved', 0, 3, '2025-09-07 02:17:44', '2025-09-07 09:55:15', NULL, '{\"url\": \"/non-workflow/tasks/245/info\", \"title\": \"x22222\", \"assignee_name\": null}', '2025-09-07 09:17:44', '2025-09-28 22:27:14'),
(26, 'task', 254, 1, 1, 'approved', 0, 3, '2025-09-07 02:52:10', '2025-09-07 09:19:43', NULL, '{\"url\": \"/non-workflow/tasks/254/info\", \"title\": \"43242424\", \"assignee_name\": null}', '2025-09-07 09:52:10', '2025-09-28 22:27:14'),
(27, 'task', 270, 1, 1, 'approved', 0, 3, '2025-09-07 05:09:55', '2025-09-07 09:19:29', NULL, '{\"url\": \"/non-workflow/tasks/270/info\", \"title\": \"342343424\", \"assignee_name\": null}', '2025-09-07 12:09:55', '2025-09-28 22:27:14'),
(28, 'task', 267, 1, 1, 'approved', 0, 3, '2025-09-07 09:56:27', '2025-09-07 10:03:25', NULL, '{\"url\": \"/non-workflow/tasks/267/info\", \"title\": \"4234344243\", \"assignee_name\": null}', '2025-09-07 16:56:27', '2025-09-28 22:27:14'),
(29, 'bidding', 40, 1, 1, 'approved', 0, 3, '2025-09-07 09:56:39', '2025-09-07 10:06:55', NULL, '{\"url\": \"/bid-detail/40\", \"title\": \"thầu mới 1/09\"}', '2025-09-07 09:56:39', '2025-09-07 10:06:55'),
(30, 'task', 246, 1, 1, 'approved', 0, 3, '2025-09-07 09:57:07', '2025-09-07 10:02:46', NULL, '{\"url\": \"/non-workflow/tasks/246/info\", \"title\": \"task con 2222\", \"assignee_name\": null}', '2025-09-07 16:57:07', '2025-09-28 22:27:14'),
(31, 'bidding_step', 364, 1, 1, 'pending', 0, 3, '2025-09-07 17:04:21', NULL, NULL, '{\"url\": \"/biddings/40/info\", \"title\": \"Bước 2: Phân tích và lập kế hoạch bóc\"}', '2025-09-07 17:04:21', '2025-09-07 17:04:21'),
(32, 'task', 227, 1, 1, 'pending', 0, 3, '2025-09-15 06:14:24', NULL, NULL, '{\"url\": \"/non-workflow/tasks/227/info\", \"title\": \"test 3534535435\", \"assignee_name\": null}', '2025-09-15 13:14:24', '2025-09-28 22:27:14'),
(34, 'task', 287, 1, 1, 'pending', 0, 3, '2025-09-15 06:15:40', NULL, NULL, '{\"url\": \"/non-workflow/tasks/287/info\", \"title\": \"Nhiệm vụ con 1_DVV\", \"assignee_name\": null}', '2025-09-15 13:15:40', '2025-09-28 22:27:14'),
(35, 'task', 288, 1, 1, 'pending', 0, 3, '2025-09-15 06:15:58', NULL, NULL, '{\"url\": \"/non-workflow/tasks/288/info\", \"title\": \"Nhiệm vụ cháu 1_DVV\", \"assignee_name\": null}', '2025-09-15 13:15:58', '2025-09-28 22:27:14'),
(36, 'task', 237, 1, 1, 'pending', 0, 3, '2025-09-15 06:16:52', NULL, NULL, '{\"url\": \"/non-workflow/tasks/237/info\", \"title\": \"324234234234\", \"assignee_name\": null}', '2025-09-15 13:16:52', '2025-09-28 22:27:14'),
(38, 'task', 279, 1, 1, 'pending', 0, 3, '2025-09-15 14:14:10', NULL, NULL, '{\"url\": \"/non-workflow/tasks/279/info\", \"title\": \"1.1. Lấy kế hoạch SXKD lần 1\", \"assignee_name\": null}', '2025-09-15 21:14:10', '2025-09-28 22:27:14'),
(40, 'task', 289, 1, 1, 'pending', 0, 3, '2025-09-17 07:17:19', NULL, NULL, '{\"url\": \"/non-workflow/tasks/289/info\", \"title\": \"c1\", \"assignee_name\": null}', '2025-09-17 14:17:19', '2025-09-28 22:27:14'),
(41, 'task', 290, 1, 1, 'pending', 0, 3, '2025-09-17 07:35:46', NULL, NULL, '{\"url\": \"/non-workflow/tasks/290/info\", \"title\": \"c222\", \"assignee_name\": null}', '2025-09-17 14:35:46', '2025-09-28 22:27:14'),
(43, 'task', 277, 1, 1, 'pending', 0, 3, '2025-09-28 03:43:12', NULL, NULL, '{\"url\": \"/non-workflow/tasks/277/info\", \"title\": \"1. Lấy kế hoạch SXKD\", \"assignee_name\": null}', '2025-09-28 10:43:12', '2025-09-28 22:27:14'),
(44, 'task', 281, 1, 1, 'pending', 0, 3, '2025-09-28 03:43:31', NULL, NULL, '{\"url\": \"/non-workflow/tasks/281/info\", \"title\": \"1.3. Lấy kế hoạch SXKD lần 3\", \"assignee_name\": null}', '2025-09-28 10:43:31', '2025-09-28 22:27:14'),
(45, 'task', 298, 1, 1, 'approved', 0, 3, '2025-09-28 03:45:11', '2025-10-01 15:39:04', NULL, '{\"url\": \"/non-workflow/tasks/298/info\", \"title\": \"2.1. Lấy kế hoạch SCL 1\", \"assignee_name\": null}', '2025-09-28 10:45:11', '2025-10-01 15:39:04'),
(48, 'task', 302, 1, 1, 'approved', 0, 3, '2025-09-28 03:52:04', '2025-10-01 14:43:29', NULL, '{\"url\": \"/non-workflow/tasks/302/info\", \"title\": \"nhiệm vụ mới 28/09/2025\", \"assignee_name\": null}', '2025-09-28 10:52:04', '2025-10-01 14:43:29'),
(50, 'task', 293, 1, 1, 'approved', 0, 3, '2025-09-28 04:38:12', '2025-10-01 14:32:16', NULL, '{\"url\": \"/non-workflow/tasks/293/info\", \"title\": \"Nhiệm vụ cháu 2_DVV\", \"assignee_name\": null}', '2025-09-28 11:38:12', '2025-10-01 14:32:16'),
(59, 'task', 278, 1, 1, 'pending', 0, 3, '2025-10-01 16:11:29', NULL, NULL, '{\"url\": \"/non-workflow/278/info\", \"title\": \"2. Lấy kế hoạch SCL\", \"assignee_name\": null}', '2025-10-01 23:11:29', '2025-10-01 23:11:29'),
(61, 'task', 299, 1, 1, 'pending', 0, 3, '2025-10-01 16:14:16', NULL, NULL, '{\"url\": \"/non-workflow/299/info\", \"title\": \"2.1.1. Lấy kế hoạch SCL 2.1\", \"assignee_name\": null}', '2025-10-01 23:14:16', '2025-10-01 23:14:16'),
(76, 'task', 280, 1, 1, 'pending', 0, 3, '2025-10-05 04:34:07', NULL, NULL, '{\"url\": \"/non-workflow/280/info\", \"title\": \"1.2. Lấy kế hoạch SXKD lần 2\", \"assignee_name\": null}', '2025-10-05 11:34:07', '2025-10-05 11:34:07'),
(78, 'task', 300, 1, 1, 'pending', 0, 3, '2025-10-05 04:34:52', NULL, NULL, '{\"url\": \"/non-workflow/300/info\", \"title\": \"1.3.1. Lấy kế hoạch mục 1.3\", \"assignee_name\": null}', '2025-10-05 11:34:52', '2025-10-05 11:34:52'),
(105, 'document', 53, 1, 1, 'pending', 0, 3, '2025-10-05 16:50:34', NULL, NULL, '{\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/logoMark-1.png\", \"title\": \"534543\"}', '2025-10-05 16:50:34', '2025-10-05 16:50:34'),
(106, 'document', 51, 1, 0, 'pending', 0, 3, '2025-10-05 16:51:11', NULL, NULL, '{\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/09/photo_2025-09-28_09-47-48.jpg\", \"title\": \"tài liệu batman\"}', '2025-10-05 16:51:11', '2025-10-05 16:52:33'),
(107, 'document', 51, 2, 1, 'pending', 0, 3, '2025-10-05 16:52:33', NULL, NULL, '{\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/09/photo_2025-09-28_09-47-48.jpg\", \"title\": \"tài liệu batman\"}', '2025-10-05 16:52:33', '2025-10-05 16:52:33'),
(113, 'document', 52, 1, 1, 'pending', 0, 3, '2025-10-05 17:21:32', NULL, NULL, '{\"url\": \"https://vnexpress.net/\", \"title\": \"tài liệu vnexpress\"}', '2025-10-05 17:21:32', '2025-10-05 17:21:32'),
(116, 'document', 57, 1, 1, 'pending', 0, 3, '2025-10-21 11:33:35', NULL, NULL, '{\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/20250922_BangtonghopdieuchinhbanDemolan3_T01.docx\", \"title\": \"xxxxxxxxxxxxx\"}', '2025-10-21 11:33:35', '2025-10-21 11:33:35'),
(117, 'document', 58, 1, 1, 'pending', 0, 3, '2025-10-21 15:07:34', NULL, NULL, '{\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/Bang_gia_QR_Code_Marketing_2025.pdf\", \"title\": \"vvvvvvvvvvvvvvvvvv\"}', '2025-10-21 15:07:34', '2025-10-21 15:07:34'),
(118, 'document', 56, 1, 1, 'pending', 0, 3, '2025-10-21 15:07:40', NULL, NULL, '{\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/20250925_TonghopDieuchinhChucnang-PM-QLCV_DemoL3-D.xlsx\", \"title\": \"435435453535\"}', '2025-10-21 15:07:40', '2025-10-21 15:07:40'),
(119, 'document', 59, 1, 1, 'pending', 0, 3, '2025-10-21 15:11:18', NULL, NULL, '{\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/20241007_GiahanphanmemMicrosoft365-1.pdf\", \"title\": \"công văn 01\"}', '2025-10-21 15:11:18', '2025-10-21 15:11:18');

-- --------------------------------------------------------

--
-- Table structure for table `approval_logs`
--

CREATE TABLE `approval_logs` (
  `id` bigint UNSIGNED NOT NULL,
  `approval_instance_id` bigint UNSIGNED NOT NULL,
  `actor_id` bigint UNSIGNED NOT NULL,
  `action` enum('send','approve','reject','update_steps','cancel','reset') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `data_json` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_logs`
--

INSERT INTO `approval_logs` (`id`, `approval_instance_id`, `actor_id`, `action`, `data_json`, `created_at`) VALUES
(1, 3, 3, 'send', '\"{\\\"approver_ids\\\":[5,3],\\\"meta\\\":{\\\"title\\\":\\\"Cung cấp hệ thống điều khiển trung tâm cho Nhiệt điện Hải Phòng\\\",\\\"url\\\":\\\"\\\\/biddings\\\\/4\\\\/info\\\"}}\"', '2025-08-31 10:39:36'),
(2, 1, 3, 'approve', '\"{\\\"note\\\":\\\"ok duyệt\\\"}\"', '2025-08-31 10:42:14'),
(3, 2, 3, 'approve', '\"{\\\"note\\\":\\\"ok nhá nhá\\\"}\"', '2025-08-31 10:52:01'),
(4, 3, 3, 'approve', '{\"note\": \"dsadadadadad\"}', '2025-08-31 14:02:17'),
(5, 3, 3, 'approve', '{\"note\": \"ewrwrwrr\"}', '2025-08-31 14:05:26'),
(6, 4, 3, 'send', '{\"meta\": {\"url\": \"/biddings/38/info\", \"title\": \"gói thầu mới 3\"}, \"approver_ids\": [1]}', '2025-08-31 14:11:36'),
(7, 4, 3, '', '{\"approver_ids\": [1]}', '2025-08-31 14:11:36'),
(8, 5, 3, 'send', '{\"meta\": {\"url\": \"/biddings/37/info\", \"title\": \"gói thầu mới 23-08\"}, \"approver_ids\": [5]}', '2025-08-31 14:11:42'),
(9, 5, 3, '', '{\"approver_ids\": [5]}', '2025-08-31 14:11:42'),
(10, 5, 3, 'approve', '{\"note\": \"duyệt này nhé\"}', '2025-08-31 14:11:56'),
(11, 4, 3, 'approve', '{\"note\": \"duyệt gói thầu này\"}', '2025-08-31 14:12:08'),
(12, 6, 3, 'send', '{\"meta\": {\"url\": \"/biddings/9/info\", \"title\": \"Lắp đặt hệ thống điện chiếu sáng – Nhiệt điện Sông Hậu\"}, \"approver_ids\": [5]}', '2025-08-31 14:21:11'),
(13, 6, 3, '', '{\"approver_ids\": [5]}', '2025-08-31 14:21:11'),
(14, 6, 3, 'approve', '{\"note\": \"53455353535\"}', '2025-08-31 14:21:23'),
(15, 7, 3, 'send', '{\"meta\": {\"url\": \"/biddings/7/info\", \"title\": \"Cung cấp vật tư phòng cháy chữa cháy – Nhiệt điện Ô Môn\"}, \"approver_ids\": [23]}', '2025-08-31 14:22:21'),
(16, 7, 3, '', '{\"approver_ids\": [23]}', '2025-08-31 14:22:21'),
(17, 7, 3, 'approve', '{\"note\": null}', '2025-08-31 14:23:14'),
(18, 8, 3, 'send', '{\"meta\": {\"url\": \"/biddings/6/info\", \"title\": \"Gói thầu bảo trì định kỳ năm 2025 – Nhiệt điện Mông Dương\"}, \"approver_ids\": [24]}', '2025-08-31 14:23:47'),
(19, 8, 3, '', '{\"approver_ids\": [24]}', '2025-08-31 14:23:47'),
(20, 8, 3, 'approve', '{\"note\": \"4354353535\"}', '2025-08-31 14:24:09'),
(21, 9, 3, 'send', '{\"meta\": {\"url\": \"/biddings/2/info\", \"title\": \"Gói thầu cung cấp turbine cho Nhiệt điện Quảng Ninh\"}, \"approver_ids\": [23]}', '2025-08-31 14:55:02'),
(22, 9, 3, '', '{\"approver_ids\": [23]}', '2025-08-31 14:55:02'),
(23, 9, 3, 'approve', '{\"note\": \"eweqewqe\"}', '2025-08-31 14:55:09'),
(24, 10, 3, 'send', '{\"meta\": {\"url\": \"/biddings/11/info\", \"title\": \"Gói thầu thuê ngoài dịch vụ an ninh – Nhiệt điện Thái Bình 2\"}, \"approver_ids\": [6]}', '2025-08-31 14:58:23'),
(25, 10, 3, '', '{\"approver_ids\": [6]}', '2025-08-31 14:58:23'),
(26, 10, 3, 'approve', '{\"note\": \"rưerwerrw\"}', '2025-08-31 14:58:32'),
(27, 13, 3, 'send', '{\"meta\": {\"url\": \"/biddings/10/info\", \"title\": \"Cung cấp hệ thống xử lý nước thải công nghiệp – Nhiệt điện Phú Mỹ\"}, \"approver_ids\": [15]}', '2025-09-01 01:34:21'),
(28, 13, 3, '', '{\"approver_ids\": [15]}', '2025-09-01 01:34:21'),
(29, 14, 3, 'send', '{\"meta\": {\"url\": \"/biddings/10/info\", \"title\": \"Cung cấp hệ thống xử lý nước thải công nghiệp – Nhiệt điện Phú Mỹ\"}, \"approver_ids\": [15]}', '2025-09-01 01:53:06'),
(30, 14, 3, '', '{\"approver_ids\": [15]}', '2025-09-01 01:53:06'),
(31, 14, 3, 'approve', '{\"note\": \"duyệt gói thầu này nhé\"}', '2025-09-01 04:17:22'),
(32, 15, 3, 'send', '{\"meta\": {\"url\": \"/bid-detail//38\", \"title\": \"gói thầu mới 3\"}, \"approver_ids\": [4]}', '2025-09-01 04:18:42'),
(33, 15, 3, '', '{\"approver_ids\": [4]}', '2025-09-01 04:18:42'),
(34, 16, 3, 'approve', '{\"note\": null}', '2025-09-01 05:28:56'),
(35, 17, 3, 'approve', '{\"note\": \"ok nhé\"}', '2025-09-01 05:29:25'),
(36, 18, 3, 'send', '{\"meta\": {\"url\": \"/biddings/35/info\", \"title\": \"Bước 1: Nhận nhu cầu khách hàng\"}, \"approver_ids\": [17]}', '2025-09-01 06:51:06'),
(37, 19, 3, 'send', '{\"meta\": {\"url\": \"/biddings/35/info\", \"title\": \"Bước 2: Đánh giá tính khả thi\"}, \"approver_ids\": [19]}', '2025-09-01 06:51:27'),
(38, 20, 3, 'send', '{\"meta\": {\"url\": \"/biddings/35/info\", \"title\": \"Bước 3: Lập kế hoạch triển khai\"}, \"approver_ids\": [15]}', '2025-09-01 07:59:15'),
(39, 21, 3, 'send', '{\"meta\": {\"url\": \"/biddings/35/info\", \"title\": \"Bước 7: Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)\"}, \"approver_ids\": [23]}', '2025-09-01 08:48:33'),
(40, 27, 3, 'approve', '{\"note\": \"rewrewrwerwr\"}', '2025-09-07 09:19:29'),
(41, 26, 3, 'approve', '{\"note\": \"dsadsadadad\"}', '2025-09-07 09:19:43'),
(42, 21, 3, 'approve', '{\"note\": \"dsadadad\"}', '2025-09-07 09:37:39'),
(43, 18, 3, 'approve', '{\"note\": \"354234324324\"}', '2025-09-07 09:40:47'),
(44, 19, 3, 'approve', '{\"note\": \"534543545353\"}', '2025-09-07 09:42:37'),
(45, 20, 3, 'approve', '{\"note\": \"3542423434324\"}', '2025-09-07 09:54:40'),
(46, 23, 3, 'approve', '{\"note\": \"423432424\"}', '2025-09-07 09:55:15'),
(47, 29, 3, 'send', '{\"meta\": {\"url\": \"/bid-detail/40\", \"title\": \"thầu mới 1/09\"}, \"approver_ids\": [22]}', '2025-09-07 09:56:39'),
(48, 29, 3, '', '{\"approver_ids\": [22]}', '2025-09-07 09:56:39'),
(49, 30, 3, 'approve', '{\"note\": \"sdffdsfsf\"}', '2025-09-07 10:02:46'),
(50, 28, 3, 'approve', '{\"note\": \"dsadadadad\"}', '2025-09-07 10:03:25'),
(51, 29, 3, 'approve', '{\"note\": null}', '2025-09-07 10:06:55'),
(52, 31, 3, 'send', '{\"meta\": {\"url\": \"/biddings/40/info\", \"title\": \"Bước 2: Phân tích và lập kế hoạch bóc\"}, \"approver_ids\": [5]}', '2025-09-07 17:04:21'),
(53, 50, 3, 'approve', '{\"note\": null}', '2025-10-01 14:32:16'),
(54, 48, 3, 'approve', '{\"note\": null}', '2025-10-01 14:43:29'),
(55, 45, 3, 'approve', '{\"note\": null}', '2025-10-01 15:39:04'),
(56, 15, 4, 'approve', '{\"note\": null}', '2025-10-02 15:17:25'),
(96, 105, 3, 'send', '{\"meta\": {\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/logoMark-1.png\", \"title\": \"534543\"}, \"approver_ids\": [4, 5]}', '2025-10-05 16:50:34'),
(97, 106, 3, 'send', '{\"meta\": {\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/09/photo_2025-09-28_09-47-48.jpg\", \"title\": \"tài liệu batman\"}, \"approver_ids\": [3, 5]}', '2025-10-05 16:51:11'),
(98, 107, 3, 'send', '{\"meta\": {\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/09/photo_2025-09-28_09-47-48.jpg\", \"title\": \"tài liệu batman\"}, \"approver_ids\": [5]}', '2025-10-05 16:52:33'),
(104, 113, 3, 'send', '{\"meta\": {\"url\": \"https://vnexpress.net/\", \"title\": \"tài liệu vnexpress\"}, \"approver_ids\": [5]}', '2025-10-05 17:21:32'),
(107, 116, 3, 'send', '{\"meta\": {\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/20250922_BangtonghopdieuchinhbanDemolan3_T01.docx\", \"title\": \"xxxxxxxxxxxxx\"}, \"approver_ids\": [3, 1, 4]}', '2025-10-21 11:33:35'),
(108, 117, 3, 'send', '{\"meta\": {\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/Bang_gia_QR_Code_Marketing_2025.pdf\", \"title\": \"vvvvvvvvvvvvvvvvvv\"}, \"approver_ids\": [3, 1, 4]}', '2025-10-21 15:07:34'),
(109, 118, 3, 'send', '{\"meta\": {\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/20250925_TonghopDieuchinhChucnang-PM-QLCV_DemoL3-D.xlsx\", \"title\": \"435435453535\"}, \"approver_ids\": [1, 3, 4]}', '2025-10-21 15:07:40'),
(110, 119, 3, 'send', '{\"meta\": {\"url\": \"https://assets.develop.io.vn/wp-content/uploads/2025/10/20241007_GiahanphanmemMicrosoft365-1.pdf\", \"title\": \"công văn 01\"}, \"approver_ids\": [1, 3]}', '2025-10-21 15:11:18');

-- --------------------------------------------------------

--
-- Table structure for table `approval_reads`
--

CREATE TABLE `approval_reads` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `step_id` bigint NOT NULL,
  `read_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `approval_steps`
--

CREATE TABLE `approval_steps` (
  `id` bigint UNSIGNED NOT NULL,
  `approval_instance_id` bigint UNSIGNED NOT NULL,
  `level` int NOT NULL,
  `approver_id` bigint UNSIGNED NOT NULL,
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `commented_at` datetime DEFAULT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `acted_by` bigint UNSIGNED DEFAULT NULL,
  `acted_role` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `approval_steps`
--

INSERT INTO `approval_steps` (`id`, `approval_instance_id`, `level`, `approver_id`, `status`, `commented_at`, `note`, `acted_by`, `acted_role`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 5, 'approved', '2025-08-31 10:42:13', 'ok duyệt', 3, 'admin', '2025-08-31 17:16:27', '2025-08-31 10:42:13'),
(2, 2, 1, 5, 'approved', '2025-08-31 10:52:01', 'ok nhá nhá', 3, 'admin', '2025-08-31 17:20:41', '2025-08-31 10:52:01'),
(3, 3, 1, 5, 'approved', '2025-08-31 14:02:17', 'dsadadadadad', 3, 'admin', '2025-08-31 10:39:36', '2025-08-31 14:02:17'),
(4, 3, 2, 3, 'approved', '2025-08-31 14:05:26', 'ewrwrwrr', 3, 'admin', '2025-08-31 10:39:36', '2025-08-31 14:05:26'),
(5, 4, 1, 1, 'approved', '2025-08-31 14:12:08', 'duyệt gói thầu này', 3, 'admin', '2025-08-31 14:11:36', '2025-08-31 14:12:08'),
(6, 5, 1, 5, 'approved', '2025-08-31 14:11:56', 'duyệt này nhé', 3, 'admin', '2025-08-31 14:11:42', '2025-08-31 14:11:56'),
(7, 6, 1, 5, 'approved', '2025-08-31 14:21:23', '53455353535', 3, 'admin', '2025-08-31 14:21:11', '2025-08-31 14:21:23'),
(8, 7, 1, 23, 'approved', '2025-08-31 14:23:14', NULL, 3, 'admin', '2025-08-31 14:22:21', '2025-08-31 14:23:14'),
(9, 8, 1, 24, 'approved', '2025-08-31 14:24:09', '4354353535', 3, 'admin', '2025-08-31 14:23:47', '2025-08-31 14:24:09'),
(10, 9, 1, 23, 'approved', '2025-08-31 14:55:09', 'eweqewqe', 3, 'admin', '2025-08-31 14:55:02', '2025-08-31 14:55:09'),
(11, 10, 1, 6, 'approved', '2025-08-31 14:58:32', 'rưerwerrw', 3, 'admin', '2025-08-31 14:58:23', '2025-08-31 14:58:32'),
(12, 11, 1, 24, 'pending', NULL, NULL, NULL, NULL, '2025-08-31 21:59:25', '2025-08-31 21:59:25'),
(13, 12, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-08-31 22:25:06', '2025-08-31 22:25:06'),
(14, 13, 1, 15, 'pending', NULL, NULL, NULL, NULL, '2025-09-01 01:34:21', '2025-09-01 01:34:21'),
(15, 14, 1, 15, 'approved', '2025-09-01 04:17:22', 'duyệt gói thầu này nhé', 3, 'admin', '2025-09-01 01:53:06', '2025-09-01 04:17:22'),
(16, 15, 1, 4, 'approved', '2025-10-02 15:17:25', NULL, 4, 'approver', '2025-09-01 04:18:42', '2025-10-02 15:17:25'),
(17, 16, 1, 4, 'approved', '2025-09-01 05:28:56', NULL, 3, 'admin', '2025-09-01 12:28:41', '2025-09-01 05:28:56'),
(18, 17, 1, 4, 'approved', '2025-09-01 05:29:25', 'ok nhé', 3, 'admin', '2025-09-01 12:29:17', '2025-09-01 05:29:25'),
(19, 18, 1, 17, 'approved', '2025-09-07 09:40:47', '354234324324', 3, 'admin', '2025-09-01 06:51:06', '2025-09-07 09:40:47'),
(20, 19, 1, 19, 'approved', '2025-09-07 09:42:37', '534543545353', 3, 'admin', '2025-09-01 06:51:27', '2025-09-07 09:42:37'),
(21, 20, 1, 15, 'approved', '2025-09-07 09:54:40', '3542423434324', 3, 'admin', '2025-09-01 07:59:15', '2025-09-07 09:54:40'),
(22, 21, 1, 23, 'approved', '2025-09-07 09:37:39', 'dsadadad', 3, 'admin', '2025-09-01 08:48:33', '2025-09-07 09:37:39'),
(23, 22, 1, 19, 'pending', NULL, NULL, NULL, NULL, '2025-09-06 11:30:48', '2025-09-06 11:30:48'),
(24, 23, 1, 5, 'approved', '2025-09-07 09:55:15', '423432424', 3, 'admin', '2025-09-07 09:17:44', '2025-09-07 09:55:15'),
(27, 26, 1, 5, 'approved', '2025-09-07 09:19:43', 'dsadsadadad', 3, 'admin', '2025-09-07 09:52:10', '2025-09-07 09:19:43'),
(28, 27, 1, 5, 'approved', '2025-09-07 09:19:29', 'rewrewrwerwr', 3, 'admin', '2025-09-07 12:09:55', '2025-09-07 09:19:29'),
(29, 28, 1, 4, 'approved', '2025-09-07 10:03:25', 'dsadadadad', 3, 'admin', '2025-09-07 16:56:27', '2025-09-07 10:03:25'),
(30, 29, 1, 22, 'approved', '2025-09-07 10:06:55', NULL, 3, 'admin', '2025-09-07 09:56:39', '2025-09-07 10:06:55'),
(31, 30, 1, 22, 'approved', '2025-09-07 10:02:46', 'sdffdsfsf', 3, 'admin', '2025-09-07 16:57:07', '2025-09-07 10:02:46'),
(32, 31, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-09-07 17:04:21', '2025-09-07 17:04:21'),
(33, 32, 1, 18, 'pending', NULL, NULL, NULL, NULL, '2025-09-15 13:14:24', '2025-09-15 13:14:24'),
(35, 34, 1, 3, 'pending', NULL, NULL, NULL, NULL, '2025-09-15 13:15:40', '2025-09-15 13:15:40'),
(36, 35, 1, 3, 'pending', NULL, NULL, NULL, NULL, '2025-09-15 13:15:58', '2025-09-15 13:15:58'),
(37, 36, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-09-15 13:16:52', '2025-09-15 13:16:52'),
(39, 38, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-09-15 21:14:10', '2025-09-15 21:14:10'),
(41, 40, 1, 3, 'pending', NULL, NULL, NULL, NULL, '2025-09-17 14:17:19', '2025-09-17 14:17:19'),
(42, 41, 1, 1, 'pending', NULL, NULL, NULL, NULL, '2025-09-17 14:35:46', '2025-09-17 14:35:46'),
(44, 43, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-09-28 10:43:12', '2025-09-28 10:43:12'),
(45, 44, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-09-28 10:43:31', '2025-09-28 10:43:31'),
(46, 45, 1, 9, 'approved', '2025-10-01 15:39:04', NULL, 3, 'admin', '2025-09-28 10:45:11', '2025-10-01 15:39:04'),
(49, 48, 1, 5, 'approved', '2025-10-01 14:43:29', NULL, 3, 'admin', '2025-09-28 10:52:04', '2025-10-01 14:43:29'),
(51, 50, 1, 15, 'approved', '2025-10-01 14:32:16', NULL, 3, 'admin', '2025-09-28 11:38:12', '2025-10-01 14:32:16'),
(63, 59, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-10-01 23:11:29', '2025-10-01 23:11:29'),
(65, 61, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-10-01 23:14:16', '2025-10-01 23:14:16'),
(89, 76, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-10-05 11:34:07', '2025-10-05 11:34:07'),
(91, 78, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-10-05 11:34:52', '2025-10-05 11:34:52'),
(134, 105, 1, 4, 'pending', NULL, NULL, NULL, NULL, '2025-10-05 16:50:34', '2025-10-05 16:50:34'),
(135, 105, 2, 5, 'pending', NULL, NULL, NULL, NULL, '2025-10-05 16:50:34', '2025-10-05 16:50:34'),
(136, 106, 1, 3, 'pending', NULL, NULL, NULL, NULL, '2025-10-05 16:51:11', '2025-10-05 16:51:11'),
(137, 106, 2, 5, 'pending', NULL, NULL, NULL, NULL, '2025-10-05 16:51:11', '2025-10-05 16:51:11'),
(138, 107, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-10-05 16:52:33', '2025-10-05 16:52:33'),
(147, 113, 1, 5, 'pending', NULL, NULL, NULL, NULL, '2025-10-05 17:21:32', '2025-10-05 17:21:32'),
(150, 116, 1, 3, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 11:33:35', '2025-10-21 11:33:35'),
(151, 116, 2, 1, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 11:33:35', '2025-10-21 11:33:35'),
(152, 116, 3, 4, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 11:33:35', '2025-10-21 11:33:35'),
(153, 117, 1, 3, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 15:07:34', '2025-10-21 15:07:34'),
(154, 117, 2, 1, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 15:07:34', '2025-10-21 15:07:34'),
(155, 117, 3, 4, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 15:07:34', '2025-10-21 15:07:34'),
(156, 118, 1, 1, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 15:07:40', '2025-10-21 15:07:40'),
(157, 118, 2, 3, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 15:07:40', '2025-10-21 15:07:40'),
(158, 118, 3, 4, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 15:07:40', '2025-10-21 15:07:40'),
(159, 119, 1, 1, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 15:11:18', '2025-10-21 15:11:18'),
(160, 119, 2, 3, 'pending', NULL, NULL, NULL, NULL, '2025-10-21 15:11:18', '2025-10-21 15:11:18');

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
  `manager_id` int DEFAULT NULL,
  `collaborators` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1=Đang chuẩn bị, 2=Trúng thầu, 3=Hủy thầu',
  `priority` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0=Bình thường, 1=Quan trọng',
  `approval_status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approval_steps` json DEFAULT NULL,
  `current_level` int UNSIGNED DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `biddings`
--

INSERT INTO `biddings` (`id`, `title`, `description`, `customer_id`, `estimated_cost`, `assigned_to`, `manager_id`, `collaborators`, `start_date`, `end_date`, `created_at`, `updated_at`, `status`, `priority`, `approval_status`, `approval_steps`, `current_level`) VALUES
(41, 'Cung cấp vật tư dự phòng TB1', 'Cung cấp vật tư dự phòng TB1', 10, 555.00, 5, 4, NULL, '2025-09-01', '2025-09-30', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 1, 1, 'pending', NULL, 0);

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
  `approval_steps` json DEFAULT NULL,
  `current_level` int NOT NULL DEFAULT '0',
  `approval_status` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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

INSERT INTO `bidding_steps` (`id`, `bidding_id`, `step_number`, `title`, `start_date`, `end_date`, `approval_steps`, `current_level`, `approval_status`, `department`, `created_at`, `updated_at`, `status`, `customer_id`, `assigned_to`, `task_id`) VALUES
(1, NULL, 1, 'Nhận nhu cầu của khách hàng', NULL, NULL, NULL, 0, 'draft', 'Khách hàng', '2025-06-05 03:50:22', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(2, NULL, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', 'P.KD, P.DVKT', '2025-06-05 03:51:59', '2025-09-01 13:40:50', 0, 4, NULL, 17),
(3, NULL, 3, 'Chỉnh sửa tiêu đề bước', NULL, NULL, NULL, 0, 'draft', 'P.KD', '2025-06-05 03:52:32', '2025-09-01 13:40:50', 2, 10, NULL, 2),
(4, NULL, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc', '2025-06-05 03:52:39', '2025-09-01 13:40:50', 2, 2, NULL, 16),
(5, NULL, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-05 03:52:46', '2025-09-01 13:40:50', 1, 1, NULL, 15),
(6, NULL, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', 'Khách hàng', '2025-06-05 03:52:53', '2025-09-01 13:40:50', 0, 4, NULL, 6),
(7, NULL, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', 'P.KD', '2025-06-05 03:53:00', '2025-09-01 13:40:50', 0, 4, NULL, 4),
(8, NULL, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', 'P.KD, P.TCKT, P.DVKT', '2025-06-05 03:53:07', '2025-09-01 13:40:50', 0, 5, NULL, 20),
(9, NULL, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc', '2025-06-05 03:53:14', '2025-09-01 13:40:50', 0, 3, NULL, 10),
(10, NULL, 10, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc', '2025-06-10 15:18:36', '2025-09-01 13:40:50', 1, 10, NULL, 9),
(11, 1, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', 'Khách hàng', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 2, NULL, NULL, 14),
(12, 1, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', 'P.KD, P.DVKT', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 1, NULL, NULL, 1),
(13, 1, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', 'P.KD, P.DVKT', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 0, NULL, NULL, 2),
(14, 1, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 0, NULL, NULL, 9),
(15, 1, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 0, NULL, NULL, 17),
(16, 1, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', 'Khách hàng', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 0, NULL, NULL, 17),
(17, 1, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', 'P.KD', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 0, NULL, NULL, 13),
(18, 1, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', 'P.KD, P.TCKT, P.DVKT', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 0, NULL, NULL, 14),
(19, 1, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc', '2025-06-16 09:06:25', '2025-09-01 13:40:50', 0, NULL, NULL, 9),
(20, 1, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', 'Khách hàng', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 2, NULL, NULL, 3),
(21, 1, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', 'P.KD, P.DVKT', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 0, NULL, NULL, 7),
(22, 1, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', 'P.KD, P.DVKT', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 0, NULL, NULL, 5),
(23, 1, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 0, NULL, NULL, 5),
(24, 1, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc, P.KD, P.DVKT, P.KHNS, P.TCKT', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 0, NULL, NULL, 10),
(25, 1, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', 'Khách hàng', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 0, NULL, NULL, 15),
(26, 1, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', 'P.KD', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 0, NULL, NULL, 3),
(27, 1, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', 'P.KD, P.TCKT, P.DVKT', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 0, NULL, NULL, 11),
(28, 1, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', 'Ban Giám đốc', '2025-06-20 08:34:44', '2025-09-01 13:40:50', 0, NULL, NULL, 6),
(29, 12, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, NULL, 0, 'draft', 'KT', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, 1, NULL, 15),
(30, 12, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, 1, NULL, 16),
(31, 12, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 15),
(32, 12, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 7),
(33, 12, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 7),
(34, 12, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 15),
(35, 12, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 15),
(36, 12, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 10),
(37, 12, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 5),
(38, 12, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 14),
(39, 12, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-21 01:51:18', '2025-09-01 13:40:50', 0, NULL, NULL, 12),
(40, 13, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, NULL, 0, 'draft', 'KT', '2025-06-22 03:09:31', '2025-09-01 13:40:50', 0, 1, NULL, 19),
(41, 13, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '', '2025-06-22 03:09:31', '2025-09-01 13:40:50', 0, 1, NULL, 19),
(42, 13, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 17),
(43, 13, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 6),
(44, 13, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 1),
(45, 13, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 7),
(46, 13, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 9),
(47, 13, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 7),
(48, 13, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 4),
(49, 13, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 1),
(50, 13, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:09:32', '2025-09-01 13:40:50', 0, NULL, NULL, 13),
(51, 14, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, NULL, 0, 'draft', 'KT', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 19),
(52, 14, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 18),
(53, 14, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 1, 1, NULL, 13),
(54, 14, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 11),
(55, 14, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 16),
(56, 14, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 3),
(57, 14, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 10),
(58, 14, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 19),
(59, 14, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 4),
(60, 14, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 3),
(61, 14, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:18:58', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(62, 15, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, NULL, 0, 'draft', 'KT', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 19),
(63, 15, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 8),
(64, 15, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 1, 1, NULL, 4),
(65, 15, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 14),
(66, 15, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(67, 15, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 19),
(68, 15, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 12),
(69, 15, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 2),
(70, 15, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 14),
(71, 15, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 5),
(72, 15, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:22:22', '2025-09-01 13:40:50', 0, 1, NULL, 20),
(73, 8, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 2, 7, NULL, 6),
(74, 8, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 0, 7, NULL, 10),
(75, 8, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 0, 7, NULL, 10),
(76, 8, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 0, 7, NULL, 19),
(77, 8, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 0, 7, NULL, 6),
(78, 8, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 0, 7, NULL, 10),
(79, 8, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 0, 7, NULL, 35),
(80, 8, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 0, 7, NULL, 35),
(81, 8, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:43:42', '2025-09-01 13:40:50', 0, 7, NULL, 10),
(82, 10, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 1, 9, NULL, 83),
(83, 10, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 0, 9, NULL, 14),
(84, 10, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 0, 9, NULL, 4),
(85, 10, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 0, 9, NULL, 17),
(86, 10, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 0, 9, NULL, 11),
(87, 10, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 0, 9, NULL, 4),
(88, 10, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 0, 9, NULL, 7),
(89, 10, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 0, 9, NULL, 2),
(90, 10, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:10', '2025-09-01 13:40:50', 0, 9, NULL, 83),
(91, 11, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 2, 10, 4, 203),
(92, 11, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 0, 10, NULL, 12),
(93, 11, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 0, 10, NULL, 7),
(94, 11, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 0, 10, NULL, 16),
(95, 11, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 0, 10, NULL, 1),
(96, 11, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 0, 10, NULL, 17),
(97, 11, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 0, 10, NULL, 1),
(98, 11, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 0, 10, NULL, 12),
(99, 11, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:20', '2025-09-01 13:40:50', 0, 10, NULL, 16),
(100, 5, 1, 'Nhận nhu cầu khách hàng', '2025-09-04 00:00:00', '2025-10-07 00:00:00', NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:51', '2025-09-04 02:15:42', 2, 4, 5, 3),
(101, 5, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-09-01 13:40:50', 1, 4, NULL, 9),
(102, 5, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-09-01 13:40:50', 0, 4, NULL, 14),
(103, 5, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:51', '2025-09-01 13:40:50', 0, 4, NULL, 2),
(104, 5, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:44:51', '2025-09-01 13:40:50', 0, 4, NULL, 29),
(105, 5, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:44:51', '2025-09-01 13:40:50', 0, 4, NULL, 10),
(106, 5, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:44:51', '2025-09-01 13:40:50', 0, 4, NULL, 7),
(107, 5, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:44:51', '2025-09-01 13:40:50', 0, 4, NULL, 7),
(108, 5, 9, 'Duyệt hợp đồng bán xxxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:44:51', '2025-09-01 13:40:50', 0, 4, NULL, 33),
(118, 3, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 22, 49),
(119, 3, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 8, 14),
(120, 3, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 17, 9),
(121, 3, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 5, 1),
(122, 3, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 6, 1),
(123, 3, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 19, 45),
(124, 3, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 17, 17),
(125, 3, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 16, 15),
(126, 3, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:56:49', '2025-09-01 13:40:50', 2, 2, 17, 4),
(127, 4, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 24, 14),
(128, 4, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 11, 19),
(129, 4, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 12, 10),
(130, 4, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 22, 49),
(131, 4, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 7, 20),
(132, 4, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 23, 16),
(133, 4, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 20, 20),
(134, 4, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 6, 11),
(135, 4, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 03:57:46', '2025-09-01 13:40:50', 2, 3, 7, 16),
(158, 26, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 1, 1, NULL, 7),
(159, 26, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 0, 1, NULL, 5),
(160, 26, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 0, 1, NULL, 2),
(161, 26, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 0, 1, NULL, 17),
(162, 26, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 0, 1, NULL, 18),
(163, 26, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 0, 1, NULL, 20),
(164, 26, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 0, 1, NULL, 6),
(165, 26, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 0, 1, NULL, 7),
(166, 26, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:04:45', '2025-09-01 13:40:50', 0, 1, NULL, 19),
(169, 27, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 1, 1, NULL, 14),
(170, 27, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 0, 1, NULL, 11),
(171, 27, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 0, 1, NULL, 11),
(172, 27, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 0, 1, NULL, 3),
(173, 27, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(174, 27, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 0, 1, NULL, 17),
(175, 27, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 0, 1, NULL, 3),
(176, 27, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(177, 27, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:06:25', '2025-09-01 13:40:50', 0, 1, NULL, 15),
(189, 29, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, NULL, 0, 'draft', 'KT', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 12),
(190, 29, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 15),
(191, 29, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 1, 1, NULL, 19),
(192, 29, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 9),
(193, 29, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 5),
(194, 29, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(195, 29, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 9),
(196, 29, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(197, 29, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 18),
(198, 29, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 5),
(199, 29, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:16:54', '2025-09-01 13:40:50', 0, 1, NULL, 12),
(200, 30, 1, 'Nhận nhu cầu khách hàng  Khách hàng', NULL, NULL, NULL, 0, 'draft', 'KT', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 3),
(201, 30, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 20),
(202, 30, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 1, 1, NULL, 11),
(203, 30, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 13),
(204, 30, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 13),
(205, 30, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 7),
(206, 30, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 13),
(207, 30, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 4),
(208, 30, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(209, 30, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 14),
(210, 30, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:20:16', '2025-09-01 13:40:50', 0, 1, NULL, 5),
(213, 31, 1, 'Nhận nhu cầu khách hàng', '2025-08-04 00:00:00', '2025-08-31 00:00:00', NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 1, 1, 5, 119),
(214, 31, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 0, 1, NULL, 14),
(215, 31, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 0, 1, NULL, 5),
(216, 31, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 0, 1, NULL, 4),
(217, 31, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 0, 1, NULL, 3),
(218, 31, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 0, 1, NULL, 2),
(219, 31, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 0, 1, NULL, 20),
(220, 31, 8, 'Triển khai ký hợp đồng bán', '2025-08-05 00:00:00', '2025-08-31 00:00:00', NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 0, 1, 5, 15),
(221, 31, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:22:47', '2025-09-01 13:40:50', 0, 1, NULL, 14),
(224, 32, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, 5, 4),
(225, 32, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, NULL, 18),
(226, 32, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, NULL, 18),
(227, 32, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, NULL, 13),
(228, 32, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, 24, 13),
(229, 32, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, NULL, 7),
(230, 32, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, 6, 13),
(231, 32, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, 22, 5),
(232, 32, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 05:23:23', '2025-09-01 13:40:50', 2, 1, 14, 6),
(233, 6, 1, 'Nhận nhu cầu khách hàng', '2025-07-10 00:00:00', '2025-07-28 00:00:00', NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 1, 5, 6, 15),
(234, 6, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 0, 5, NULL, 16),
(235, 6, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 0, 5, NULL, 14),
(236, 6, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 0, 5, NULL, 1),
(237, 6, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 0, 5, NULL, 2),
(238, 6, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 0, 5, NULL, 13),
(239, 6, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 0, 5, NULL, 2),
(240, 6, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 0, 5, NULL, 11),
(241, 6, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 06:55:02', '2025-09-01 13:40:50', 0, 5, NULL, 11),
(244, 33, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 1, 1, 7, 3),
(245, 33, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(246, 33, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 0, 1, NULL, 15),
(247, 33, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 0, 1, NULL, 14),
(248, 33, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 0, 1, NULL, 1),
(249, 33, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 0, 1, NULL, 6),
(250, 33, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 0, 1, NULL, 4),
(251, 33, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 0, 1, NULL, 4),
(252, 33, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 14:53:19', '2025-09-01 13:40:50', 0, 1, NULL, 7),
(253, 9, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 1, 8, NULL, 2),
(254, 9, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 0, 8, NULL, 10),
(255, 9, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 0, 8, NULL, 4),
(256, 9, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 0, 8, NULL, 7),
(257, 9, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 0, 8, NULL, 4),
(258, 9, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 0, 8, NULL, 20),
(259, 9, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 0, 8, NULL, 46),
(260, 9, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 0, 8, NULL, 38),
(261, 9, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 15:07:34', '2025-09-01 13:40:50', 0, 8, NULL, 39),
(264, 34, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, 6, 42),
(265, 34, 2, 'Đánh giá tính khả thi xxx', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, 8, 3),
(266, 34, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, 7, 16),
(267, 34, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, 20, 5),
(268, 34, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, NULL, 16),
(269, 34, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, 22, 5),
(270, 34, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, 21, 18),
(271, 34, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, 5, 12),
(272, 34, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-22 15:21:11', '2025-09-01 13:40:50', 2, 1, 11, 8),
(273, 28, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 1, 1, NULL, 4),
(274, 28, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 0, 1, NULL, 13),
(275, 28, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 0, 1, NULL, 15),
(276, 28, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 0, 1, NULL, 12),
(277, 28, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 0, 1, NULL, 17),
(278, 28, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 0, 1, NULL, 9),
(279, 28, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 0, 1, NULL, 12),
(280, 28, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 0, 1, NULL, 14),
(281, 28, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-06-29 02:35:13', '2025-09-01 13:40:50', 0, 1, NULL, 15),
(284, 35, 1, 'Nhận nhu cầu khách hàng', '2025-08-30 00:00:00', '2025-10-31 00:00:00', '[{\"note\": \"354234324324\", \"level\": 1, \"status\": \"approved\", \"approver_id\": 17, \"commented_at\": \"2025-09-07 09:40:47\"}]', 0, 'approved', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-08-04 17:26:31', '2025-09-07 09:40:47', 1, 1, 17, 254),
(285, 35, 2, 'Đánh giá tính khả thi', NULL, NULL, '[{\"note\": \"534543545353\", \"level\": 1, \"status\": \"approved\", \"approver_id\": 19, \"commented_at\": \"2025-09-07 09:42:37\"}]', 0, 'approved', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-08-04 17:26:31', '2025-09-07 09:42:37', 2, 1, 19, 201),
(286, 35, 3, 'Lập kế hoạch triển khai', NULL, NULL, '[{\"note\": \"3542423434324\", \"level\": 1, \"status\": \"approved\", \"approver_id\": 15, \"commented_at\": \"2025-09-07 09:54:40\"}]', 0, 'approved', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-08-04 17:26:31', '2025-09-07 09:54:40', 2, 1, 15, 202),
(287, 35, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-04 17:26:31', '2025-09-01 13:40:50', 2, 1, NULL, NULL),
(288, 35, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-08-04 17:26:31', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(289, 35, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-04 17:26:31', '2025-09-01 13:40:50', 2, 1, NULL, NULL),
(290, 35, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, '[{\"note\": \"dsadadad\", \"level\": 1, \"status\": \"approved\", \"approver_id\": 23, \"commented_at\": \"2025-09-07 09:37:39\"}]', 0, 'approved', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-08-04 17:26:31', '2025-09-07 09:37:39', 2, 1, 23, 209),
(291, 35, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-08-04 17:26:31', '2025-09-01 13:40:50', 2, 1, NULL, NULL),
(292, 35, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-04 17:26:31', '2025-09-01 13:40:50', 0, 1, NULL, 208),
(293, 7, 1, 'Nhận nhu cầu khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 1, 6, NULL, 240),
(294, 7, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 0, 6, NULL, NULL),
(295, 7, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 0, 6, NULL, NULL),
(296, 7, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 0, 6, NULL, NULL),
(297, 7, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 0, 6, NULL, NULL),
(298, 7, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 0, 6, NULL, NULL),
(299, 7, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 0, 6, NULL, NULL),
(300, 7, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 0, 6, NULL, NULL),
(301, 7, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-04 17:40:14', '2025-09-01 13:40:50', 0, 6, NULL, NULL),
(302, 2, 1, 'Nhận nhu cầu khách hàng', '2025-08-14 00:00:00', '2025-08-31 00:00:00', NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 1, 1, 4, NULL),
(303, 2, 2, 'Đánh giá tính khả thi', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 1, 1, NULL, NULL),
(304, 2, 3, 'Lập kế hoạch triển khai', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(305, 2, 4, 'Duyệt kế hoạch', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(306, 2, 5, 'Triển khai hồ sơ dự thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 2, 1, NULL, NULL),
(307, 2, 6, 'Chấm thầu', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(308, 2, 7, 'Nhập dữ liệu vào phần mềm QLĐTKD (nếu không trúng thầu thì kết thúc)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(309, 2, 8, 'Triển khai ký hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(310, 2, 9, 'Duyệt hợp đồng bán', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-14 10:22:14', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(313, 36, 1, 'Lấy KH: SXKD, SCL, SCTK hoặc KHK của khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 1, 1, NULL, NULL),
(314, 36, 2, 'Phân tích và lập kế hoạch bóc', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(315, 36, 3, 'Làm rõ tính chất kỹ thuật, NSX của hàng hóa, dịch vụ', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(316, 36, 4, 'Làm việc với NSX, NCC', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(317, 36, 5, 'Kiểm tra', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(318, 36, 6, 'Nhận báo giá, kiểm tra và cơ sở đàm phán (nếu có)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(319, 36, 7, 'Đánh giá, báo cáo tính khả thi', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(320, 36, 8, 'Duyệt', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(321, 36, 9, 'Xây dựng kịch bản HSMT', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(322, 36, 10, 'Duyệt', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-18 15:18:59', '2025-09-01 13:40:50', 0, 1, NULL, NULL),
(325, 37, 1, 'Lấy KH: SXKD, SCL, SCTK hoặc KHK của khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 1, 7, 19, 212),
(326, 37, 2, 'Phân tích và lập kế hoạch bóc', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(327, 37, 3, 'Làm rõ tính chất kỹ thuật, NSX của hàng hóa, dịch vụ', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(328, 37, 4, 'Làm việc với NSX, NCC', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(329, 37, 5, 'Kiểm tra', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(330, 37, 6, 'Nhận báo giá, kiểm tra và cơ sở đàm phán (nếu có)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(331, 37, 7, 'Đánh giá, báo cáo tính khả thi', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(332, 37, 8, 'Duyệt', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(333, 37, 9, 'Xây dựng kịch bản HSMT', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(334, 37, 10, 'Duyệt', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-23 02:16:14', '2025-09-01 13:40:50', 0, 7, NULL, NULL),
(337, 38, 1, 'Lấy KH: SXKD, SCL, SCTK hoặc KHK của khách hàng', '2025-08-24 00:00:00', '2025-08-31 00:00:00', NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 2, 6, NULL, 214),
(338, 38, 2, 'Phân tích và lập kế hoạch bóc', '2025-08-24 00:00:00', '2025-08-27 00:00:00', NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 215),
(339, 38, 3, 'Làm rõ tính chất kỹ thuật, NSX của hàng hóa, dịch vụ', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 216),
(340, 38, 4, 'Làm việc với NSX, NCC', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 217),
(341, 38, 5, 'Kiểm tra', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 218),
(342, 38, 6, 'Nhận báo giá, kiểm tra và cơ sở đàm phán (nếu có)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 219),
(343, 38, 7, 'Đánh giá, báo cáo tính khả thi', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 220),
(344, 38, 8, 'Duyệt', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 243),
(345, 38, 9, 'Xây dựng kịch bản HSMT', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 222),
(346, 38, 10, 'Duyệt', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-23 02:18:51', '2025-09-01 13:40:50', 0, 6, NULL, 224),
(349, 39, 1, 'Lấy KH: SXKD, SCL, SCTK hoặc KHK của khách hàng', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 1, 10, NULL, NULL),
(350, 39, 2, 'Phân tích và lập kế hoạch bóc', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-08-27 20:02:39', '2025-09-07 05:09:55', 0, 10, NULL, 270),
(351, 39, 3, 'Làm rõ tính chất kỹ thuật, NSX của hàng hóa, dịch vụ', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL);
INSERT INTO `bidding_steps` (`id`, `bidding_id`, `step_number`, `title`, `start_date`, `end_date`, `approval_steps`, `current_level`, `approval_status`, `department`, `created_at`, `updated_at`, `status`, `customer_id`, `assigned_to`, `task_id`) VALUES
(352, 39, 4, 'Làm việc với NSX, NCC', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(353, 39, 5, 'Kiểm tra', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Hành chính - Nhân sự\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(354, 39, 6, 'Nhận báo giá, kiểm tra và cơ sở đàm phán (nếu có)', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(355, 39, 7, 'Đánh giá, báo cáo tính khả thi', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(356, 39, 8, 'Duyệt', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Thương mại\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(357, 39, 9, 'Xây dựng kịch bản HSMT', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(358, 39, 10, 'Duyệt', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Kinh doanh\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(359, 39, 11, '11', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(360, 39, 22, '22', NULL, NULL, NULL, 0, 'draft', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-27 20:02:39', '2025-09-01 13:40:50', 0, 10, NULL, NULL),
(363, 40, 1, 'Lấy KH: SXKD, SCL, SCTK hoặc KHK của khách hàng', NULL, NULL, NULL, 0, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 1, 4, NULL, NULL),
(364, 40, 2, 'Phân tích và lập kế hoạch bóc', NULL, NULL, '[{\"note\": null, \"level\": 1, \"status\": \"pending\", \"approver_id\": 5, \"commented_at\": null}]', 0, 'pending', '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-09-01 07:55:31', '2025-09-07 17:04:21', 0, 4, 5, 246),
(365, 40, 3, 'Làm rõ tính chất kỹ thuật, NSX của hàng hóa, dịch vụ', NULL, NULL, NULL, 0, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(366, 40, 4, 'Làm việc với NSX, NCC', NULL, NULL, NULL, 0, NULL, '[\"Phòng Kinh doanh\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(367, 40, 5, 'Kiểm tra', NULL, NULL, NULL, 0, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(368, 40, 6, 'Nhận báo giá, kiểm tra và cơ sở đàm phán (nếu có)', NULL, NULL, NULL, 0, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(369, 40, 7, 'Đánh giá, báo cáo tính khả thi', NULL, NULL, NULL, 0, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(370, 40, 8, 'Duyệt', NULL, NULL, NULL, 0, NULL, '[\"Phòng Thương mại\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(371, 40, 9, 'Xây dựng kịch bản HSMT', NULL, NULL, NULL, 0, NULL, '[\"Phòng Kinh doanh\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(372, 40, 10, 'Duyệt', NULL, NULL, NULL, 0, NULL, '[\"Phòng Kinh doanh\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(373, 40, 11, '11', NULL, NULL, NULL, 0, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(374, 40, 22, '22', NULL, NULL, NULL, 0, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-09-01 07:55:31', '2025-09-01 07:55:31', 0, 4, NULL, NULL),
(377, 41, 1, 'Lấy KH: SXKD, SCL, SCTK hoặc KHK của khách hàng', '2025-09-01 00:00:00', '2025-09-04 00:00:00', NULL, 0, NULL, '[\"Phòng Hành chính - Nhân sự\",\"Phòng Tài chính - Kế toán\"]', '2025-09-15 04:10:10', '2025-09-28 04:45:46', 1, 10, 5, 302),
(378, 41, 2, 'Phân tích và lập kế hoạch bóc', '2025-09-05 00:00:00', '2025-09-06 00:00:00', NULL, 0, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\",\"Phòng Thương mại\"]', '2025-09-15 04:10:10', '2025-09-17 07:40:13', 1, 10, 5, 290),
(379, 41, 3, 'Làm rõ tính chất kỹ thuật, NSX của hàng hóa, dịch vụ', '2025-09-06 00:00:00', '2025-09-07 00:00:00', NULL, 0, NULL, '[\"Phòng Kinh doanh\",\"Phòng Thương mại\"]', '2025-09-15 04:10:10', '2025-09-15 04:33:22', 1, 10, 6, NULL),
(380, 41, 4, 'Làm việc với NSX, NCC', NULL, NULL, NULL, 0, NULL, '[\"Phòng Kinh doanh\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL),
(381, 41, 5, 'Kiểm tra', NULL, NULL, NULL, 0, NULL, '[\"Phòng Hành chính - Nhân sự\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL),
(382, 41, 6, 'Nhận báo giá, kiểm tra và cơ sở đàm phán (nếu có)', NULL, NULL, NULL, 0, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL),
(383, 41, 7, 'Đánh giá, báo cáo tính khả thi', NULL, NULL, NULL, 0, NULL, '[\"Phòng Dịch vụ - Kỹ thuật\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL),
(384, 41, 8, 'Duyệt', NULL, NULL, NULL, 0, NULL, '[\"Phòng Thương mại\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL),
(385, 41, 9, 'Xây dựng kịch bản HSMT', NULL, NULL, NULL, 0, NULL, '[\"Phòng Kinh doanh\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL),
(386, 41, 10, 'Duyệt', NULL, NULL, NULL, 0, NULL, '[\"Phòng Kinh doanh\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL),
(387, 41, 11, '11', NULL, NULL, NULL, 0, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL),
(388, 41, 22, '22', NULL, NULL, NULL, 0, NULL, '[\"Phòng Tài chính - Kế toán\"]', '2025-09-15 04:10:10', '2025-09-15 04:10:10', 0, 10, NULL, NULL);

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
(1, 1, 'bidding_step_01', 'Lấy KH: SXKD, SCL, SCTK hoặc KHK của khách hàng', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(2, 2, 'bidding_step_02', 'Phân tích và lập kế hoạch bóc', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(3, 3, 'bidding_step_03', 'Làm rõ tính chất kỹ thuật, NSX của hàng hóa, dịch vụ', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(4, 4, 'bidding_step_04', 'Làm việc với NSX, NCC', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(5, 5, 'bidding_step_05', 'Kiểm tra', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(6, 6, 'bidding_step_06', 'Nhận báo giá, kiểm tra và cơ sở đàm phán (nếu có)', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(7, 7, 'bidding_step_07', 'Đánh giá, báo cáo tính khả thi', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(8, 8, 'bidding_step_08', 'Duyệt', '[\"Phòng Thương mại\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(9, 9, 'bidding_step_09', 'Xây dựng kịch bản HSMT', '[\"Phòng Kinh doanh\"]', '2025-06-16 16:06:14', '2025-06-29 15:59:25'),
(10, 10, 'bidding_step_10', 'Duyệt', '[\"Phòng Kinh doanh\"]', '2025-08-14 23:07:38', '2025-08-14 23:07:38'),
(11, 11, '111', '11', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-24 17:05:07', '2025-08-24 17:05:07'),
(12, 22, '22', '22', '[\"Phòng Tài chính - Kế toán\"]', '2025-08-24 17:05:31', '2025-08-24 17:05:31');

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
-- Table structure for table `comment_reads`
--

CREATE TABLE `comment_reads` (
  `id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `comment_id` bigint NOT NULL,
  `read_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `comment_reads`
--

INSERT INTO `comment_reads` (`id`, `user_id`, `comment_id`, `read_at`) VALUES
(1, 3, 43, '2025-09-05 07:58:16'),
(2, 3, 42, '2025-09-05 07:58:16'),
(3, 3, 41, '2025-09-05 07:58:16'),
(4, 3, 40, '2025-09-05 07:58:16'),
(5, 3, 39, '2025-09-05 07:58:16'),
(6, 3, 38, '2025-09-05 07:58:16'),
(7, 3, 37, '2025-09-05 07:58:16'),
(8, 3, 36, '2025-09-05 07:58:16'),
(9, 3, 35, '2025-09-05 07:58:16'),
(10, 3, 34, '2025-09-05 07:58:16'),
(11, 3, 44, '2025-09-05 08:02:22'),
(12, 3, 33, '2025-09-05 08:09:55'),
(13, 3, 32, '2025-09-05 08:10:06'),
(14, 3, 45, '2025-09-05 08:10:18'),
(15, 5, 45, '2025-09-05 08:19:15'),
(16, 5, 44, '2025-09-05 08:19:15'),
(17, 5, 43, '2025-09-05 08:19:15'),
(18, 5, 42, '2025-09-05 08:19:15'),
(19, 5, 41, '2025-09-05 08:19:15'),
(20, 5, 35, '2025-09-05 08:19:15'),
(21, 5, 34, '2025-09-05 08:19:15'),
(22, 5, 33, '2025-09-05 08:19:15'),
(23, 5, 32, '2025-09-05 08:19:15'),
(24, 5, 30, '2025-09-05 08:19:15'),
(25, 3, 59, '2025-09-06 14:23:38'),
(26, 3, 58, '2025-09-06 14:23:38'),
(27, 3, 57, '2025-09-06 14:23:38'),
(28, 3, 56, '2025-09-06 14:23:38'),
(29, 3, 55, '2025-09-06 14:23:38'),
(30, 3, 53, '2025-09-06 14:23:38'),
(31, 3, 52, '2025-09-06 14:23:38'),
(32, 3, 51, '2025-09-06 14:23:38'),
(33, 3, 50, '2025-09-06 14:23:38'),
(34, 3, 49, '2025-09-06 14:23:38'),
(35, 3, 48, '2025-09-06 14:34:29'),
(36, 3, 47, '2025-09-06 14:34:47'),
(37, 3, 46, '2025-09-06 14:35:07'),
(38, 3, 60, '2025-09-06 14:37:07'),
(39, 3, 61, '2025-09-06 14:40:14'),
(40, 3, 62, '2025-09-06 14:51:25'),
(41, 3, 64, '2025-09-07 17:14:21'),
(42, 3, 73, '2025-09-28 15:04:25'),
(43, 3, 72, '2025-09-28 15:04:34'),
(44, 3, 70, '2025-09-28 16:15:46'),
(45, 3, 69, '2025-09-28 16:16:38'),
(46, 3, 71, '2025-09-28 16:19:47'),
(47, 3, 67, '2025-09-28 16:20:21');

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
  `manager_id` int DEFAULT NULL,
  `collaborators` json DEFAULT NULL,
  `priority` tinyint(1) NOT NULL DEFAULT '0',
  `customer_id` int DEFAULT NULL,
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

INSERT INTO `contracts` (`id`, `title`, `code`, `content`, `status`, `department_id`, `assigned_to`, `manager_id`, `collaborators`, `priority`, `customer_id`, `bidding_id`, `start_date`, `end_date`, `created_at`, `updated_at`, `updated_by`, `description`) VALUES
(30, 'Hợp đồng bảo trì hệ thống SCADA - Nhiệt điện Phả Lại', '#5465435', NULL, 1, NULL, 22, NULL, NULL, 0, 8, 9, '2025-06-04', '2025-09-29', '2025-06-21 04:41:38', '2025-08-14 23:25:36', NULL, 'Mô tả demo'),
(31, 'Cung cấp thiết bị điều khiển lò hơi - Nhiệt điện Vĩnh Tân 4', '#5222222', NULL, 4, NULL, 20, NULL, NULL, 0, 8, 9, '2025-06-07', '2025-06-16', '2025-06-21 14:24:12', '2025-06-22 14:26:44', NULL, '2343565879sdfgsdfsdfdfsf'),
(32, 'Tư vấn nâng cấp hệ thống điều khiển DCS - Nhiệt điện Mông Dương', '#44444444', NULL, 4, NULL, 14, NULL, NULL, 0, 3, 4, '2025-06-07', '2025-06-16', '2025-06-21 14:56:49', '2025-06-22 14:29:14', NULL, '3432544656fghfgbcvbvbvc'),
(33, 'Cung cấp than tổ hợp - Nhiệt điện Nghi Sơn', '#66666', NULL, 3, NULL, 22, NULL, NULL, 0, 1, 29, '2025-06-19', '2025-06-27', '2025-06-22 06:34:46', '2025-06-29 09:41:57', NULL, 'ưerrewrrrwwr'),
(34, 'test hợp đồng 2', '#444444', NULL, 1, NULL, 19, NULL, NULL, 0, 2, 3, '2025-07-18', '2025-07-29', '2025-07-20 11:51:50', '2025-07-20 12:43:15', NULL, 'demo'),
(65, 'HĐ gia công ống khói chịu nhiệt – Nhiệt điện Vĩnh Tân', 'HD001', NULL, 1, NULL, 4, NULL, '[\"5\"]', 0, NULL, 10, '2025-08-24', '2025-08-24', '2025-08-24 07:17:31', '2025-08-24 09:49:43', NULL, '423424244'),
(66, 'hợp đồng xxxx', 'xxxxxx', NULL, 1, NULL, 17, NULL, '[\"5\", \"22\"]', 0, 5, 6, '2025-08-24', '2025-08-31', '2025-08-24 08:44:13', '2025-08-24 11:01:37', NULL, 'xxxxxxx');

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
(259, 30, NULL, 10, 'Đặt hàng NCC', 2, 6, '2025-07-10', NULL, '2025-07-28 00:00:00', '2025-07-08', '2025-06-21 04:41:38', '2025-08-04 15:11:19', '[\"P.KD\", \"TP.M\", \"TP.TCKT\"]', 5),
(260, 30, NULL, 11, 'Duyệt đặt hàng', 1, NULL, NULL, NULL, NULL, '2025-07-01', '2025-06-21 04:41:38', '2025-07-08 14:41:36', '[\"Ban Giám đốc\"]', 7),
(261, 30, NULL, 12, 'Triển khai hợp đồng mua', 1, NULL, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-07-01 11:22:13', '[\"P.TCKT\", \"P.KD\", \"P.DVKT\"]', 2),
(262, 30, NULL, 13, 'Duyệt hợp đồng mua', 1, 19, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-08-02 01:35:50', '[\"Ban Giám đốc\"]', 9),
(263, 30, NULL, 14, 'Thanh toán hợp đồng mua', 0, 4, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-08-02 01:35:41', '[\"P.TM\", \"P.TCKT\"]', 17),
(264, 30, NULL, 15, 'Kiểm tra hàng hóa', 0, 5, NULL, NULL, NULL, NULL, '2025-06-21 04:41:38', '2025-07-01 11:08:45', '[\"P.TM\"]', 17),
(265, 30, NULL, 16, 'Nghiệm thu', 0, NULL, '2025-08-01', NULL, '2025-08-31 00:00:00', NULL, '2025-06-21 04:41:38', '2025-08-01 09:29:39', '[\"P.TM\", \"P.KD\", \"P.DVKT\"]', 15),
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
(343, 34, NULL, 26, 'Thoả hồ sơ lưu chứng từ & kết thúc', 0, NULL, NULL, NULL, NULL, NULL, '2025-07-20 11:51:51', '2025-07-20 11:51:51', '[\"P.KD\", \"P.TCKT\", \"P.TM\", \"P.KHNS\"]', NULL),
(344, 65, NULL, 1, 'Đặt hàng NCC', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.KD\",\"TP.M\",\"TP.TCKT\"]', NULL),
(345, 65, NULL, 2, 'Phát hành bảo lãnh', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"Ban Giám đốc\"]', NULL),
(346, 65, NULL, 3, 'Hoàn thiện hồ sơ tạm ứng (nếu có)', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.TCKT\",\"P.KD\",\"P.DVKT\"]', NULL),
(347, 65, NULL, 4, 'Đề nghị nhập hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"Ban Giám đốc\"]', NULL),
(348, 65, NULL, 5, 'Đặt hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.TM\",\"P.TCKT\"]', NULL),
(349, 65, NULL, 6, 'Giám sát, kiểm tra tình trạng đặt hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.TM\"]', NULL),
(350, 65, NULL, 7, 'Thực hiện điều chỉnh nội dung hợp đồng (nếu có)', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.TM\",\"P.KD\",\"P.DVKT\"]', NULL),
(351, 65, NULL, 8, 'Nghiệm thu hàng hoá (nội bộ)', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.TM\"]', NULL),
(352, 65, NULL, 9, 'Nghiệm thu chứng từ bằng hoá (nội bộ)', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.KHNS\",\"P.TCKT\"]', NULL),
(353, 65, NULL, 10, 'Lập kế hoạch giao hàng hoá và nghiệm thu kỹ thuật tới khách hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.KD\",\"P.TCKT\"]', NULL),
(354, 65, NULL, 11, 'Bàn giao hàng hoá và nghiệm thu kỹ thuật tới khách hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"Ban Giám đốc\"]', NULL),
(355, 65, NULL, 12, 'Xuất hoá đơn GTGT bằng hàng hoá, dịch vụ', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.KD\",\"P.KHNS\",\"P.TCKT\"]', NULL),
(356, 65, NULL, 13, 'Nghiệm thu thương mại', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"Khách hàng\"]', NULL),
(357, 65, NULL, 14, 'Phát hành bảo lãnh', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.KD\",\"P.DVKT\",\"P.TMĐ\"]', NULL),
(358, 65, NULL, 15, 'Hoàn thiện hồ sơ thanh quyết toán', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.KD\",\"P.TM\",\"P.TCKT\"]', NULL),
(359, 65, NULL, 16, 'Thu hồi công nợ', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"Khách hàng\"]', NULL),
(360, 65, NULL, 17, 'Thu hồi chứng từ', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"P.KD\",\"P.TCKT\",\"P.TM\",\"P.KHNS\"]', NULL),
(361, 65, NULL, 18, 'Thanh lý hợp đồng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"Phòng Kinh doanh\"]', NULL),
(362, 65, NULL, 19, 'Lưu hồ sơ', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 07:17:32', '2025-08-24 07:17:32', '[\"Phòng Kinh doanh\"]', NULL),
(363, 66, NULL, 1, 'Đặt hàng NCC', 1, 6, '2025-08-24', NULL, '2025-08-31 00:00:00', NULL, '2025-08-24 08:44:13', '2025-10-08 09:06:53', '[\"P.KD\",\"TP.M\",\"TP.TCKT\"]', NULL),
(364, 66, NULL, 2, 'Phát hành bảo lãnh', 1, 4, '2025-08-24', NULL, '2025-08-30 00:00:00', NULL, '2025-08-24 08:44:13', '2025-08-24 16:20:21', '[\"Ban Giám đốc\"]', NULL),
(365, 66, NULL, 3, 'Hoàn thiện hồ sơ tạm ứng (nếu có)', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.TCKT\",\"P.KD\",\"P.DVKT\"]', NULL),
(366, 66, NULL, 4, 'Đề nghị nhập hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"Ban Giám đốc\"]', NULL),
(367, 66, NULL, 5, 'Đặt hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.TM\",\"P.TCKT\"]', NULL),
(368, 66, NULL, 6, 'Giám sát, kiểm tra tình trạng đặt hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.TM\"]', NULL),
(369, 66, NULL, 7, 'Thực hiện điều chỉnh nội dung hợp đồng (nếu có)', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.TM\",\"P.KD\",\"P.DVKT\"]', NULL),
(370, 66, NULL, 8, 'Nghiệm thu hàng hoá (nội bộ)', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.TM\"]', NULL),
(371, 66, NULL, 9, 'Nghiệm thu chứng từ bằng hoá (nội bộ)', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.KHNS\",\"P.TCKT\"]', NULL),
(372, 66, NULL, 10, 'Lập kế hoạch giao hàng hoá và nghiệm thu kỹ thuật tới khách hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.KD\",\"P.TCKT\"]', NULL),
(373, 66, NULL, 11, 'Bàn giao hàng hoá và nghiệm thu kỹ thuật tới khách hàng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"Ban Giám đốc\"]', NULL),
(374, 66, NULL, 12, 'Xuất hoá đơn GTGT bằng hàng hoá, dịch vụ', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.KD\",\"P.KHNS\",\"P.TCKT\"]', NULL),
(375, 66, NULL, 13, 'Nghiệm thu thương mại', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"Khách hàng\"]', NULL),
(376, 66, NULL, 14, 'Phát hành bảo lãnh', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.KD\",\"P.DVKT\",\"P.TMĐ\"]', NULL),
(377, 66, NULL, 15, 'Hoàn thiện hồ sơ thanh quyết toán', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.KD\",\"P.TM\",\"P.TCKT\"]', NULL),
(378, 66, NULL, 16, 'Thu hồi công nợ', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"Khách hàng\"]', NULL),
(379, 66, NULL, 17, 'Thu hồi chứng từ', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"P.KD\",\"P.TCKT\",\"P.TM\",\"P.KHNS\"]', NULL),
(380, 66, NULL, 18, 'Thanh lý hợp đồng', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"Phòng Kinh doanh\"]', NULL),
(381, 66, NULL, 19, 'Lưu hồ sơ', 0, NULL, NULL, NULL, NULL, NULL, '2025-08-24 08:44:13', '2025-08-24 08:44:13', '[\"Phòng Kinh doanh\"]', NULL);

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
(1, 1, 'contract_step_1', 'Xây dựng Bảng kế hoạch triển khai hợp đồng bán', '[\"P.KD\",\"TP.M\",\"TP.TCKT\"]', '2025-06-20 23:49:21', '2025-08-24 16:49:50'),
(2, 2, 'contract_step_11', 'Phát hành bảo lãnh', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-08-15 00:00:50'),
(3, 3, 'contract_step_12', 'Hoàn thiện hồ sơ tạm ứng (nếu có)', '[\"P.TCKT\",\"P.KD\",\"P.DVKT\"]', '2025-06-20 23:49:21', '2025-08-15 00:01:13'),
(4, 4, 'contract_step_13', 'Đề nghị nhập hàng', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-08-15 00:01:30'),
(5, 5, 'contract_step_14', 'Đặt hàng', '[\"P.TM\",\"P.TCKT\"]', '2025-06-20 23:49:21', '2025-08-15 00:01:41'),
(6, 6, 'contract_step_15', 'Giám sát, kiểm tra tình trạng đặt hàng', '[\"P.TM\"]', '2025-06-20 23:49:21', '2025-08-15 00:01:54'),
(7, 7, 'contract_step_16', 'Thực hiện điều chỉnh nội dung hợp đồng (nếu có)', '[\"P.TM\",\"P.KD\",\"P.DVKT\"]', '2025-06-20 23:49:21', '2025-08-15 00:02:07'),
(8, 8, 'contract_step_17', 'Nghiệm thu hàng hoá (nội bộ)', '[\"P.TM\"]', '2025-06-20 23:49:21', '2025-08-15 00:02:20'),
(9, 9, 'contract_step_18', 'Nghiệm thu chứng từ bằng hoá (nội bộ)', '[\"P.KHNS\",\"P.TCKT\"]', '2025-06-20 23:49:21', '2025-08-15 00:02:32'),
(10, 10, 'contract_step_19', 'Lập kế hoạch giao hàng hoá và nghiệm thu kỹ thuật tới khách hàng', '[\"P.KD\",\"P.TCKT\"]', '2025-06-20 23:49:21', '2025-08-15 00:02:44'),
(11, 11, 'contract_step_20', 'Bàn giao hàng hoá và nghiệm thu kỹ thuật tới khách hàng', '[\"Ban Giám đốc\"]', '2025-06-20 23:49:21', '2025-08-15 00:03:00'),
(12, 12, 'contract_step_21', 'Xuất hoá đơn GTGT bằng hàng hoá, dịch vụ', '[\"P.KD\",\"P.KHNS\",\"P.TCKT\"]', '2025-06-20 23:49:21', '2025-08-15 00:03:09'),
(13, 13, 'contract_step_22', 'Nghiệm thu thương mại', '[\"Khách hàng\"]', '2025-06-20 23:49:21', '2025-08-15 00:03:27'),
(14, 14, 'contract_step_23', 'Phát hành bảo lãnh', '[\"P.KD\",\"P.DVKT\",\"P.TMĐ\"]', '2025-06-20 23:49:21', '2025-08-15 00:03:38'),
(15, 15, 'contract_step_24', 'Hoàn thiện hồ sơ thanh quyết toán', '[\"P.KD\",\"P.TM\",\"P.TCKT\"]', '2025-06-20 23:49:21', '2025-08-15 00:03:49'),
(16, 16, 'contract_step_25', 'Thu hồi công nợ', '[\"Khách hàng\"]', '2025-06-20 23:49:21', '2025-08-15 00:04:00'),
(17, 17, 'contract_step_26', 'Thu hồi chứng từ', '[\"P.KD\",\"P.TCKT\",\"P.TM\",\"P.KHNS\"]', '2025-06-20 23:49:21', '2025-08-15 00:04:15'),
(18, 18, NULL, 'Thanh lý hợp đồng', '[\"Phòng Kinh doanh\"]', '2025-08-15 00:04:43', '2025-08-15 00:04:43'),
(19, 19, NULL, 'Lưu hồ sơ', '[\"Phòng Kinh doanh\"]', '2025-08-15 00:05:04', '2025-08-15 00:05:04');

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
(1, 'Công ty CP Nhiệt điện Phả Lại', '02422210000', 'contact@evn.com.vn', '11 Cửa Bắc, Ba Đình', 'Hà Nội', 'khách cũ', '/uploads/evn.jpg', 6, '2025-06-13', '2025-06-11 02:10:10', '2025-09-15 03:50:58'),
(2, 'Công ty CP Nhiệt điện Hải Phòng', '02203713901', 'info@plaipower.vn', 'Phả Lại, Chí Linh', 'Hải Dương', 'tiềm năng', '/uploads/phalai.jpg', 5, '2025-06-18', '2025-06-11 02:10:22', '2025-09-15 03:50:16'),
(3, 'Nhà máy nhiệt điện Duyên Hải 3 MR', '02033855600', 'ubpower@evn.com.vn', 'Uông Bí, Quảng Ninh', 'Đà Nẵng', 'thử nghiệm', '/uploads/uongbi.jpg', 5, '2025-06-19', '2025-06-11 02:10:29', '2025-09-15 03:48:49'),
(4, 'Nhà máy Nhiệt điện Duyên Hải 3', '02923836411', 'cantho@evn.com.vn', 'Ô Môn, Cần Thơ', 'Cần Thơ', 'tiềm năng', '/uploads/cantho.jpg', 23, '2025-06-20', '2025-06-11 02:10:35', '2025-09-15 03:48:13'),
(5, 'Nhà máy Nhiệt điện Duyên Hải 1', '02033655355', 'qnpower@evn.com.vn', 'Cẩm Phả, Quảng Ninh', 'Quảng Ninh', 'vip', '/uploads/quangninh.jpg', 1, '2025-06-21', '2025-06-11 02:10:41', '2025-09-15 03:47:58'),
(6, 'Công ty Nhiệt điện Nghi Sơn', '02943923999', 'duyenhai@evn.com.vn', 'Duyên Hải, Trà Vinh', 'Trà Vinh', 'khách mới', '/uploads/duyenhai.jpg', 1, '2025-06-12', '2025-06-11 02:10:47', '2025-09-15 03:46:27'),
(7, 'Công ty CP Nhiệt điện Quảng Ninh', '02523695252', 'vinhtan@evn.com.vn', 'Tuy Phong, Bình Thuận', 'Bình Thuận', 'tiềm năng', '/uploads/vinhtan.jpg', 20, '2025-06-30', '2025-06-11 02:10:53', '2025-09-15 03:45:51'),
(8, 'Tổng công ty Phát điện 1', '02373898888', 'nghison1@evn.com.vn', 'Hải Hà, Thanh Hóa', 'Thanh Hóa', 'khách cũ', '/uploads/nghison1.jpg', 4, '2025-06-14', '2025-06-11 02:10:58', '2025-09-15 03:45:07'),
(9, 'Trung tâm Dịch vụ sửa chữa EVN', '02253717171', 'haiphongpower@evn.com.vn', 'Thủy Nguyên, Hải Phòng', 'Hải Phòng', 'vip', '/uploads/haiphong.jpg', 1, NULL, '2025-06-11 02:11:04', '2025-09-15 03:44:37'),
(10, 'Công ty Nhiệt điện Thái Bình', '02033933777', 'mongduong@evn.com.vn', 'Cẩm Phả, Quảng Ninh', 'Quảng Ninh', 'khách mới', '/uploads/mongduong.jpg', 5, NULL, '2025-06-11 02:11:09', '2025-09-15 03:43:14'),
(12, 'Nhà máy Nhiệt điện Vĩnh Tân 4', '0912345678', 'doangiang665@gmail.com', 'i3 vinsmart ', NULL, NULL, NULL, 12, NULL, '2025-08-21 14:50:45', '2025-09-15 03:42:44'),
(13, 'Công Ty CP Nhiệt điện Phả Lại', '0989268613', 'info@ttid.com.vn', '', NULL, NULL, NULL, 7, NULL, '2025-09-15 03:52:47', '2025-09-15 03:52:47');

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
(1, 'Phòng Hành chính - Nhân sự', 'Cập nhật mô tả phòng ban', '2025-05-25 02:55:43', '2025-09-06 16:10:42'),
(2, 'Phòng Tài chính - Kế toán', 'Quản lý tài chính và kế toán', '2025-06-04 09:01:59', '2025-09-06 16:10:32'),
(3, 'Phòng Kinh doanh', 'Phụ trách phát triển kinh doanh', '2025-06-04 09:02:11', '2025-06-04 09:02:11'),
(4, 'Phòng Thương mại', 'Quản lý hợp đồng và thương mại', '2025-06-04 09:02:29', '2025-06-04 09:02:29'),
(5, 'Phòng Dịch vụ - Kỹ thuật', 'Hỗ trợ kỹ thuật và dịch vụ khách hàng', '2025-06-04 09:02:38', '2025-06-04 09:02:38'),
(6, 'Ban giám dốc', 'Ban giám dốc', '2025-12-02 22:41:35', '2025-12-02 22:41:35');

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` int NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_path` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `uploaded_by` int NOT NULL,
  `source_task_id` int DEFAULT NULL,
  `comment_id` int DEFAULT NULL,
  `upload_batch` int DEFAULT '1',
  `drive_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `approval_status` enum('not_sent','pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `google_file_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `visibility` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'private'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `documents`
--

INSERT INTO `documents` (`id`, `title`, `file_path`, `file_size`, `department_id`, `uploaded_by`, `source_task_id`, `comment_id`, `upload_batch`, `drive_id`, `created_at`, `updated_at`, `approval_status`, `google_file_id`, `visibility`) VALUES
(37, 'to_trinh_09_11_2025.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-7.pdf', NULL, 2, 3, 277, NULL, 1, NULL, '2025-11-13 11:15:22', '2025-11-30 12:58:22', 'pending', NULL, 'private'),
(108, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1SQOqylVdl3QIvLfzUqJzq3gxhbeQzcwz/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', NULL, 2, 3, 277, 108, 2, '1SQOqylVdl3QIvLfzUqJzq3gxhbeQzcwz', '2025-11-28 11:01:09', '2025-11-28 11:01:09', '', NULL, 'private'),
(109, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1y-lgBSw2TNO2BtF9akDiCXyuf3w_Mx58/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', NULL, 2, 3, 277, 109, 3, '1y-lgBSw2TNO2BtF9akDiCXyuf3w_Mx58', '2025-11-28 11:01:23', '2025-11-28 11:01:23', '', NULL, 'private'),
(110, 'maudonphuc_khao123.pdf', 'https://drive.google.com/file/d/1FZSglITfLnD0Jv8PFjZwANs7kUC79YY1/view?usp=drivesdk', NULL, 2, 3, 277, 110, 4, '1FZSglITfLnD0Jv8PFjZwANs7kUC79YY1', '2025-11-28 11:01:36', '2025-11-29 09:09:24', 'pending', NULL, 'private'),
(177, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1sVv0dYAyx2HycaI7DxJ06HAgCUdtEBSCuQeqPkJCppc/edit', 316358, 2, 3, 277, 169, 5, '1sVv0dYAyx2HycaI7DxJ06HAgCUdtEBSCuQeqPkJCppc', '2025-11-30 11:41:06', '2025-11-30 11:41:06', '', '1sVv0dYAyx2HycaI7DxJ06HAgCUdtEBSCuQeqPkJCppc', 'private'),
(178, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4/edit', 315365, 2, 3, 277, 170, 6, '1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4', '2025-11-30 11:41:53', '2025-11-30 11:41:53', '', '1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4', 'private'),
(179, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-1.pdf', 126127, 1, 3, 277, NULL, NULL, '1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4', '2025-11-30 19:20:03', '2025-11-30 19:20:03', 'pending', NULL, 'private'),
(182, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/192fjz_J4k0S-7bjCSGEPxUBvjY3-Z8M2nQbQLNU9mSU/edit', 95744, 2, 3, 279, 174, 1, '192fjz_J4k0S-7bjCSGEPxUBvjY3-Z8M2nQbQLNU9mSU', '2025-12-01 11:30:09', '2025-12-01 11:30:09', '', '192fjz_J4k0S-7bjCSGEPxUBvjY3-Z8M2nQbQLNU9mSU', 'private'),
(183, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1-Z86_obmMpUTuI8fC5LCx--MCX_bGHlyW48DUhv9SPk/edit', 95744, 2, 3, 278, 175, 1, '1-Z86_obmMpUTuI8fC5LCx--MCX_bGHlyW48DUhv9SPk', '2025-12-01 11:33:13', '2025-12-01 11:33:13', '', '1-Z86_obmMpUTuI8fC5LCx--MCX_bGHlyW48DUhv9SPk', 'private'),
(197, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1V_ZcBUqz-L5KqSPyoUef89R6PwYf_oOXubEv_9z40iE/edit', 98304, 2, 3, 277, 189, 22, '1V_ZcBUqz-L5KqSPyoUef89R6PwYf_oOXubEv_9z40iE', '2025-12-02 13:06:09', '2025-12-02 13:06:09', '', '1V_ZcBUqz-L5KqSPyoUef89R6PwYf_oOXubEv_9z40iE', 'private'),
(199, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1gWeXF8PEvX86_Tkyrj5ssfSQNt89HL25g142q6krGzU/edit', 98304, 3, 1, 277, 191, 24, '1gWeXF8PEvX86_Tkyrj5ssfSQNt89HL25g142q6krGzU', '2025-12-02 14:11:10', '2025-12-02 14:11:10', '', '1gWeXF8PEvX86_Tkyrj5ssfSQNt89HL25g142q6krGzU', 'private'),
(202, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1ov9IS-v5YtGb66JxIeyuHB8BxoqB36pByJ3Qr9vqmiw/edit', 315365, 6, 1, 277, 195, 25, '1ov9IS-v5YtGb66JxIeyuHB8BxoqB36pByJ3Qr9vqmiw', '2025-12-03 00:00:37', '2025-12-03 00:00:37', '', '1ov9IS-v5YtGb66JxIeyuHB8BxoqB36pByJ3Qr9vqmiw', 'private'),
(203, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/15ZkYL_xMWa7x7yOgf0nNtKK0PBJ0Koq_xMtMnNOAvGE/edit', 318161, 1, 3, 312, 196, 1, '15ZkYL_xMWa7x7yOgf0nNtKK0PBJ0Koq_xMtMnNOAvGE', '2025-12-03 14:21:07', '2025-12-03 14:21:07', '', '15ZkYL_xMWa7x7yOgf0nNtKK0PBJ0Koq_xMtMnNOAvGE', 'private'),
(204, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso/edit', 318161, 1, 3, 312, 197, 2, '17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso', '2025-12-03 14:25:02', '2025-12-03 14:25:02', '', '17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso', 'private'),
(205, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1rWWE3lnZwvcu-T_9gPj6u-SBi51RiYoBIZXGgLI978Y/edit', 98304, 1, 3, 311, 198, 1, '1rWWE3lnZwvcu-T_9gPj6u-SBi51RiYoBIZXGgLI978Y', '2025-12-03 14:28:52', '2025-12-03 14:28:52', '', '1rWWE3lnZwvcu-T_9gPj6u-SBi51RiYoBIZXGgLI978Y', 'private'),
(206, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1fcQpS6nm6U65dRm0FZwjI02kxQZMs_Iqw1_aqfvJYpU/edit', 318161, 1, 3, 311, 199, 2, '1fcQpS6nm6U65dRm0FZwjI02kxQZMs_Iqw1_aqfvJYpU', '2025-12-03 14:31:58', '2025-12-03 14:31:58', '', '1fcQpS6nm6U65dRm0FZwjI02kxQZMs_Iqw1_aqfvJYpU', 'private'),
(207, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1S9K2vKUVkJCMvslJqjnuWsQk_Ho3abS3C4J1HE0K8wg/edit', 318161, 1, 3, 311, 200, 3, '1S9K2vKUVkJCMvslJqjnuWsQk_Ho3abS3C4J1HE0K8wg', '2025-12-03 14:38:17', '2025-12-03 14:38:17', '', '1S9K2vKUVkJCMvslJqjnuWsQk_Ho3abS3C4J1HE0K8wg', 'private'),
(208, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/11K1mssbDnLCJLuKtjqBv_dngTsHHT_IZXNO6W-1CavI/edit', 318161, 1, 3, 311, 201, 4, '11K1mssbDnLCJLuKtjqBv_dngTsHHT_IZXNO6W-1CavI', '2025-12-03 14:47:37', '2025-12-03 14:47:37', '', '11K1mssbDnLCJLuKtjqBv_dngTsHHT_IZXNO6W-1CavI', 'private'),
(209, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1rJFYoVh2YpuCcuDLS4oo2qk3kAoTj8KDG0GxLZWWWIk/edit', 318161, 1, 3, 311, 202, 5, '1rJFYoVh2YpuCcuDLS4oo2qk3kAoTj8KDG0GxLZWWWIk', '2025-12-03 14:48:45', '2025-12-03 14:48:45', '', '1rJFYoVh2YpuCcuDLS4oo2qk3kAoTj8KDG0GxLZWWWIk', 'private'),
(210, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo/edit', 318161, 1, 3, 311, 203, 6, '1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo', '2025-12-03 14:49:34', '2025-12-03 14:49:34', '', '1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo', 'private'),
(211, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit', 318161, 1, 3, 312, 204, 3, '1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0', '2025-12-03 14:51:58', '2025-12-03 14:51:58', '', '1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0', 'private');

-- --------------------------------------------------------

--
-- Table structure for table `documents_converted`
--

CREATE TABLE `documents_converted` (
  `id` int UNSIGNED NOT NULL,
  `wp_id` int NOT NULL,
  `file_url` varchar(500) NOT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `size` int DEFAULT NULL,
  `doc_type` varchar(50) DEFAULT NULL,
  `drive_id` varchar(255) DEFAULT NULL,
  `task_file_id` int DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `uploader_name` varchar(255) DEFAULT NULL,
  `wp_created_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `documents_converted`
--

INSERT INTO `documents_converted` (`id`, `wp_id`, `file_url`, `mime_type`, `title`, `size`, `doc_type`, `drive_id`, `task_file_id`, `uploaded_by`, `uploader_name`, `wp_created_at`, `created_at`, `updated_at`) VALUES
(1, 372, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/converted_1764497869141.pdf', 'application/pdf', 'Converted PDF', 126127, 'internal', '1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4', 178, NULL, NULL, '2025-11-30 10:17:54', '2025-11-30 17:17:55', '2025-12-02 14:07:32'),
(2, 373, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/converted_1764498202045.pdf', 'application/pdf', 'Converted PDF', 126127, 'internal', '1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4', 178, NULL, NULL, '2025-11-30 10:23:24', '2025-11-30 17:23:25', '2025-12-02 14:07:32'),
(3, 374, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/converted_1764498313282.pdf', 'application/pdf', 'Converted PDF', 126127, 'internal', '1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4', 277, NULL, NULL, '2025-11-30 10:25:16', '2025-11-30 17:25:17', '2025-12-02 14:07:32'),
(12, 405, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-23.pdf', 'application/pdf', 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 143401, 'internal', '192fjz_J4k0S-7bjCSGEPxUBvjY3-Z8M2nQbQLNU9mSU', 279, 3, 'Đinh Văn Vịnh', '2025-12-01 04:30:24', '2025-12-01 11:30:26', '2025-12-02 14:07:32'),
(13, 407, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-25.pdf', 'application/pdf', 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 143401, 'internal', '1-Z86_obmMpUTuI8fC5LCx--MCX_bGHlyW48DUhv9SPk', 278, 3, 'Đinh Văn Vịnh', '2025-12-01 04:33:28', '2025-12-01 11:33:29', '2025-12-02 14:07:32'),
(16, 414, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/xxxxConverted_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01.pdf', 'application/pdf', '_xxxxConverted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 143401, 'internal', '1OUEUB5-t1BXSpRkyzBThF3UwDuOgtSSAfuKzTHYCDwc', 277, 5, 'Nguyễn Văn Chiểu', '2025-12-01 06:36:16', '2025-12-01 13:36:18', '2025-12-02 14:07:32'),
(17, 415, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-32.pdf', 'application/pdf', 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 143401, 'internal', '1OUEUB5-t1BXSpRkyzBThF3UwDuOgtSSAfuKzTHYCDwc', 277, 5, 'Nguyễn Văn Chiểu', '2025-12-01 06:36:58', '2025-12-01 13:36:59', '2025-12-02 14:07:32'),
(28, 433, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-14.pdf', 'application/pdf', 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 174830, 'internal', '1yICuh4SfZig46mTVG380l_ocMxzMY03lLVEujWqwbaU', 277, 1, 'Nguyễn Cảnh Hợp', '2025-12-02 03:54:01', '2025-12-02 10:54:03', '2025-12-02 14:07:32'),
(29, 434, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-15.pdf', 'application/pdf', 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 174830, 'internal', '18QR9k7d2zkKLWDUSg4ODYJTdebQXMISMlomP-VYbWAU', 277, 3, 'Đinh Văn Vịnh', '2025-12-02 04:33:35', '2025-12-02 11:33:37', '2025-12-02 14:07:32'),
(30, 435, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-16.pdf', 'application/pdf', 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 174830, 'internal', '11ZNPSKCqE9gqyECOj-Yruj5XmVGkBPvyC3J-rjecSms', 277, 3, 'Đinh Văn Vịnh', '2025-12-02 04:53:58', '2025-12-02 11:54:00', '2025-12-02 14:07:32'),
(31, 436, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-17.pdf', 'application/pdf', 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 174830, 'internal', '1V_ZcBUqz-L5KqSPyoUef89R6PwYf_oOXubEv_9z40iE', 277, 3, 'Đinh Văn Vịnh', '2025-12-02 06:06:35', '2025-12-02 13:06:36', '2025-12-02 14:07:32'),
(32, 437, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-18.pdf', 'application/pdf', 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 174830, 'internal', '1V_ZcBUqz-L5KqSPyoUef89R6PwYf_oOXubEv_9z40iE', 277, 3, 'Đinh Văn Vịnh', '2025-12-02 07:04:58', '2025-12-02 14:04:59', '2025-12-02 14:04:59'),
(33, 438, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-19.pdf', 'application/pdf', 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 174830, 'public', '1xDoaJh2Wd8GzaYSEiewnj-KH9Lu4tuwm-f1g9FL6Jns', 277, 1, 'Nguyễn Cảnh Hợp', '2025-12-02 07:08:40', '2025-12-02 14:08:43', '2025-12-02 14:08:43'),
(34, 439, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-20.pdf', 'application/pdf', 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 174830, 'external', '1gWeXF8PEvX86_Tkyrj5ssfSQNt89HL25g142q6krGzU', 277, 1, 'Nguyễn Cảnh Hợp', '2025-12-02 07:11:37', '2025-12-02 14:11:39', '2025-12-02 14:11:39'),
(35, 440, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', 'application/pdf', 'origin_a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', 127013, 'internal', '13nWfEsimjrGJoOEDNXlFgCTFh7tFeRHQpYmEUa709N0', 277, 1, 'Nguyễn Cảnh Hợp', '2025-12-02 07:24:50', '2025-12-02 14:24:51', '2025-12-02 14:24:51'),
(36, 441, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-21.pdf', 'application/pdf', 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', 174830, 'internal', '1F2yEeKki0kCc7i6sD_hGbAPo73hchyl8yK5Old30giw', 277, 1, 'Nguyễn Cảnh Hợp', '2025-12-02 07:25:04', '2025-12-02 14:25:05', '2025-12-02 14:25:05'),
(37, 442, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-1.pdf', 'application/pdf', 'origin_a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', 127013, 'external', '13nWfEsimjrGJoOEDNXlFgCTFh7tFeRHQpYmEUa709N0', 277, 1, 'Nguyễn Cảnh Hợp', '2025-12-02 14:06:43', '2025-12-02 21:06:44', '2025-12-02 21:06:44'),
(38, 443, 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', 'application/pdf', 'origin_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 126127, 'internal', '1ov9IS-v5YtGb66JxIeyuHB8BxoqB36pByJ3Qr9vqmiw', 277, 1, 'Lương Đức Thuỷ', '2025-12-02 17:01:21', '2025-12-03 00:01:22', '2025-12-03 00:01:22');

-- --------------------------------------------------------

--
-- Table structure for table `document_approvals`
--

CREATE TABLE `document_approvals` (
  `id` int UNSIGNED NOT NULL,
  `document_id` int UNSIGNED NOT NULL,
  `source_type` enum('task_file','comment','document') DEFAULT 'task_file',
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_by` int UNSIGNED NOT NULL,
  `current_step_index` int UNSIGNED NOT NULL DEFAULT '0',
  `note` text,
  `signed_pdf_url` text,
  `finished_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `document_approvals`
--

INSERT INTO `document_approvals` (`id`, `document_id`, `source_type`, `status`, `created_by`, `current_step_index`, `note`, `signed_pdf_url`, `finished_at`, `created_at`, `updated_at`) VALUES
(19, 21, 'document', 'pending', 1, 2, NULL, NULL, NULL, '2025-11-09 11:34:16', '2025-11-14 10:25:56'),
(20, 22, 'document', 'pending', 1, 2, NULL, NULL, NULL, '2025-11-09 11:38:53', '2025-11-09 14:53:17'),
(21, 23, 'document', 'approved', 3, 4, NULL, NULL, '2025-11-13 10:29:34', '2025-11-09 15:52:48', '2025-11-13 10:29:34'),
(22, 26, 'document', 'pending', 3, 1, NULL, NULL, NULL, '2025-11-10 23:12:44', '2025-11-10 23:12:44'),
(23, 35, 'document', 'pending', 3, 3, NULL, NULL, NULL, '2025-11-13 10:47:10', '2025-11-14 11:17:09'),
(24, 36, 'document', 'pending', 4, 3, NULL, NULL, NULL, '2025-11-13 11:06:45', '2025-11-14 11:17:40'),
(25, 37, 'document', 'pending', 3, 3, NULL, NULL, NULL, '2025-11-13 11:15:32', '2025-11-14 09:49:51'),
(26, 110, 'document', 'pending', 3, 1, NULL, NULL, NULL, '2025-11-29 09:09:24', '2025-11-29 09:09:24');

-- --------------------------------------------------------

--
-- Table structure for table `document_approval_logs`
--

CREATE TABLE `document_approval_logs` (
  `id` int UNSIGNED NOT NULL,
  `approval_id` int UNSIGNED NOT NULL COMMENT 'ID của phiên duyệt (document_approvals.id)',
  `document_id` int UNSIGNED NOT NULL COMMENT 'ID của tài liệu gốc',
  `action` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'approved' COMMENT 'Loại hành động: approved / rejected / reopened / etc',
  `acted_by` int UNSIGNED NOT NULL COMMENT 'ID người thao tác',
  `acted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Thời điểm thực hiện hành động',
  `signer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Tên người ký duyệt',
  `signature_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'URL ảnh chữ ký',
  `signed_pdf_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Đường dẫn file PDF đã ký',
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci COMMENT 'Ghi chú thêm của người duyệt'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Lưu lịch sử duyệt tài liệu (ai duyệt, khi nào, file đã ký, chữ ký)';

--
-- Dumping data for table `document_approval_logs`
--

INSERT INTO `document_approval_logs` (`id`, `approval_id`, `document_id`, `action`, `acted_by`, `acted_at`, `signer_name`, `signature_url`, `signed_pdf_url`, `comment`) VALUES
(33, 20, 22, 'approved', 3, '2025-11-09 14:53:17', NULL, NULL, NULL, ''),
(34, 21, 23, 'approved', 1, '2025-11-09 17:03:24', NULL, NULL, NULL, ''),
(35, 21, 23, 'approved', 3, '2025-11-09 17:24:35', NULL, NULL, NULL, ''),
(36, 21, 23, 'approved', 4, '2025-11-09 17:30:11', NULL, NULL, NULL, ''),
(37, 21, 23, 'approved', 5, '2025-11-13 10:29:34', NULL, NULL, NULL, ''),
(38, 23, 35, 'approved', 1, '2025-11-13 10:56:48', NULL, NULL, NULL, ''),
(39, 24, 36, 'approved', 1, '2025-11-13 11:12:32', NULL, NULL, NULL, ''),
(40, 25, 37, 'approved', 1, '2025-11-13 13:49:11', NULL, NULL, NULL, ''),
(41, 25, 37, 'approved', 3, '2025-11-14 09:49:51', NULL, NULL, NULL, ''),
(42, 19, 21, 'approved', 3, '2025-11-14 10:25:56', NULL, NULL, NULL, ''),
(43, 23, 35, 'approved', 3, '2025-11-14 11:17:09', NULL, NULL, NULL, ''),
(44, 24, 36, 'approved', 3, '2025-11-14 11:17:40', NULL, NULL, NULL, '');

-- --------------------------------------------------------

--
-- Table structure for table `document_approval_steps`
--

CREATE TABLE `document_approval_steps` (
  `id` int UNSIGNED NOT NULL,
  `approval_id` int UNSIGNED NOT NULL,
  `approver_id` int UNSIGNED NOT NULL,
  `sequence` int UNSIGNED NOT NULL,
  `status` enum('waiting','active','approved','rejected') NOT NULL DEFAULT 'waiting',
  `acted_by` int UNSIGNED DEFAULT NULL,
  `acted_at` datetime DEFAULT NULL,
  `comment` text,
  `signature_url` varchar(255) DEFAULT NULL,
  `signed_at` datetime DEFAULT NULL,
  `pos_row` varchar(20) DEFAULT NULL,
  `pos_index` int DEFAULT NULL,
  `order_index` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `document_approval_steps`
--

INSERT INTO `document_approval_steps` (`id`, `approval_id`, `approver_id`, `sequence`, `status`, `acted_by`, `acted_at`, `comment`, `signature_url`, `signed_at`, `pos_row`, `pos_index`, `order_index`, `created_at`, `updated_at`) VALUES
(56, 19, 3, 1, 'approved', 3, '2025-11-14 10:25:56', '', NULL, '2025-11-14 10:25:56', NULL, NULL, NULL, '2025-11-09 11:34:16', '2025-11-14 10:25:56'),
(57, 19, 4, 2, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-09 11:34:16', '2025-11-14 10:25:56'),
(58, 19, 1, 3, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-09 11:34:16', '2025-11-09 11:34:16'),
(59, 20, 3, 1, 'approved', 3, '2025-11-09 14:53:17', '', NULL, '2025-11-09 14:53:17', NULL, NULL, NULL, '2025-11-09 11:38:53', '2025-11-09 14:53:17'),
(60, 20, 1, 2, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-09 11:38:53', '2025-11-09 14:53:17'),
(61, 20, 4, 3, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-09 11:38:53', '2025-11-09 11:38:53'),
(62, 20, 5, 4, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-09 11:38:53', '2025-11-09 11:38:53'),
(63, 21, 1, 1, 'approved', 1, '2025-11-09 17:03:24', '', NULL, '2025-11-09 17:03:24', NULL, NULL, NULL, '2025-11-09 15:52:48', '2025-11-09 17:03:24'),
(64, 21, 3, 2, 'approved', 3, '2025-11-09 17:24:35', '', NULL, '2025-11-09 17:24:35', NULL, NULL, NULL, '2025-11-09 15:52:48', '2025-11-09 17:24:35'),
(65, 21, 4, 3, 'approved', 4, '2025-11-09 17:30:11', '', NULL, '2025-11-09 17:30:11', NULL, NULL, NULL, '2025-11-09 15:52:48', '2025-11-09 17:30:11'),
(66, 21, 5, 4, 'approved', 5, '2025-11-13 10:29:34', '', NULL, '2025-11-13 10:29:34', NULL, NULL, NULL, '2025-11-09 15:52:48', '2025-11-13 10:29:34'),
(67, 22, 4, 1, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 23:12:44', '2025-11-10 23:12:44'),
(68, 22, 3, 2, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 23:12:44', '2025-11-10 23:12:44'),
(69, 22, 1, 3, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-10 23:12:44', '2025-11-10 23:12:44'),
(70, 23, 1, 1, 'approved', 1, '2025-11-13 10:56:48', '', NULL, '2025-11-13 10:56:48', NULL, NULL, NULL, '2025-11-13 10:47:10', '2025-11-13 10:56:48'),
(71, 23, 3, 2, 'approved', 3, '2025-11-14 11:17:09', '', NULL, '2025-11-14 11:17:09', NULL, NULL, NULL, '2025-11-13 10:47:10', '2025-11-14 11:17:09'),
(72, 23, 4, 3, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 10:47:10', '2025-11-14 11:17:09'),
(73, 23, 5, 4, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 10:47:10', '2025-11-13 10:47:10'),
(74, 24, 1, 1, 'approved', 1, '2025-11-13 11:12:32', '', NULL, '2025-11-13 11:12:32', NULL, NULL, NULL, '2025-11-13 11:06:45', '2025-11-13 11:12:32'),
(75, 24, 3, 2, 'approved', 3, '2025-11-14 11:17:40', '', NULL, '2025-11-14 11:17:40', NULL, NULL, NULL, '2025-11-13 11:06:45', '2025-11-14 11:17:40'),
(76, 24, 4, 3, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 11:06:45', '2025-11-14 11:17:40'),
(77, 24, 5, 4, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 11:06:45', '2025-11-13 11:06:45'),
(78, 25, 1, 1, 'approved', 1, '2025-11-13 13:49:11', '', NULL, '2025-11-13 13:49:11', NULL, NULL, NULL, '2025-11-13 11:15:32', '2025-11-13 13:49:11'),
(79, 25, 3, 2, 'approved', 3, '2025-11-14 09:49:51', '', NULL, '2025-11-14 09:49:51', NULL, NULL, NULL, '2025-11-13 11:15:32', '2025-11-14 09:49:51'),
(80, 25, 4, 3, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 11:15:32', '2025-11-14 09:49:51'),
(81, 25, 5, 4, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-13 11:15:32', '2025-11-13 11:15:32'),
(82, 26, 3, 1, 'active', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 09:09:24', '2025-11-29 09:09:24'),
(83, 26, 4, 2, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 09:09:24', '2025-11-29 09:09:24'),
(84, 26, 5, 3, 'waiting', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-29 09:09:24', '2025-11-29 09:09:24');

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
-- Table structure for table `document_sign_status`
--

CREATE TABLE `document_sign_status` (
  `id` int NOT NULL,
  `converted_id` int NOT NULL,
  `approver_id` int NOT NULL,
  `approver_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_index` int NOT NULL DEFAULT '1',
  `version` int NOT NULL DEFAULT '1',
  `status` enum('pending','signed') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `signed_at` datetime DEFAULT NULL,
  `signed_pdf_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signed_by_id` int DEFAULT NULL,
  `signed_by_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signature_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `task_file_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `document_sign_status`
--

INSERT INTO `document_sign_status` (`id`, `converted_id`, `approver_id`, `approver_name`, `order_index`, `version`, `status`, `signed_at`, `signed_pdf_url`, `signed_by_id`, `signed_by_name`, `signature_url`, `task_file_id`, `created_at`) VALUES
(1, 378, 0, NULL, 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 12:34:35'),
(2, 378, 0, NULL, 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 12:39:22'),
(3, 378, 0, NULL, 2, 1, 'pending', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 12:39:22'),
(4, 378, 0, NULL, 3, 1, 'pending', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 12:39:22'),
(5, 378, 0, NULL, 4, 1, 'pending', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 12:39:22'),
(14, 6, 0, NULL, 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 13:17:12'),
(15, 6, 0, NULL, 2, 1, '', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 13:17:12'),
(16, 6, 0, NULL, 3, 1, '', NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-30 13:17:12'),
(47, 11, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'signed', '2025-12-01 11:29:20', 'https://assets.develop.io.vn/wp-content/uploads/2025/12/Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-22.pdf', 1, 'Nguyễn Cảnh Hợp', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-01 04:28:48'),
(48, 12, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'signed', '2025-12-01 11:31:43', 'https://assets.develop.io.vn/wp-content/uploads/2025/12/Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-24.pdf', 1, 'Nguyễn Cảnh Hợp', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '279', '2025-12-01 04:30:50'),
(50, 13, 3, 'Đinh Văn Vịnh', 2, 1, 'signed', '2025-12-01 11:35:07', 'https://assets.develop.io.vn/wp-content/uploads/2025/12/Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-27.pdf', 3, 'Đinh Văn Vịnh', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '278', '2025-12-01 04:33:40'),
(52, 13, 5, 'Nguyễn Văn Chiểu', 4, 3, 'signed', '2025-12-01 13:12:58', 'https://assets.develop.io.vn/wp-content/uploads/2025/12/Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-29.pdf', 5, 'Nguyễn Văn Chiểu', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-04-1.jpg', '278', '2025-12-01 04:33:40'),
(58, 19, 1, 'Nguyễn Cảnh Hợp', 1, 2, 'signed', '2025-12-01 14:32:39', 'https://assets.develop.io.vn/wp-content/uploads/2025/12/origin_20251008_TTrHCNS_GiahanphanmemMicrosoft-365-T01-5.pdf', 1, 'Nguyễn Cảnh Hợp', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-01 07:18:36'),
(59, 19, 3, 'Đinh Văn Vịnh', 2, 3, 'signed', '2025-12-01 14:46:05', NULL, 3, 'Đinh Văn Vịnh', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-01 07:18:36'),
(60, 19, 4, 'Tạ Quý Thọ', 3, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-01 07:18:36'),
(61, 19, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-01 07:18:36'),
(62, 19, 6, 'Phạm Xuân Tuân', 5, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-01 07:18:36'),
(63, 21, 1, 'Nguyễn Cảnh Hợp', 1, 2, 'signed', '2025-12-01 15:47:47', NULL, 1, 'Nguyễn Cảnh Hợp', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-01 08:46:51'),
(64, 21, 3, 'Đinh Văn Vịnh', 2, 3, 'signed', '2025-12-01 15:49:02', NULL, 3, 'Đinh Văn Vịnh', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-01 08:46:51'),
(65, 21, 4, 'Tạ Quý Thọ', 3, 4, 'signed', '2025-12-01 15:50:29', NULL, 4, 'Tạ Quý Thọ', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/photo_2025-10-17_10-09-07-1.jpg', '277', '2025-12-01 08:46:51'),
(66, 21, 5, 'Nguyễn Văn Chiểu', 4, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-01 08:46:51'),
(67, 21, 6, 'Phạm Xuân Tuân', 5, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-01 08:46:51'),
(69, 22, 3, 'Đinh Văn Vịnh', 2, 3, 'signed', '2025-12-02 08:20:35', NULL, 3, 'Đinh Văn Vịnh', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 01:12:24'),
(70, 22, 4, 'Tạ Quý Thọ', 3, 4, 'signed', '2025-12-02 08:21:32', NULL, 4, 'Tạ Quý Thọ', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/photo_2025-10-17_10-09-07-1.jpg', '277', '2025-12-02 01:12:24'),
(71, 22, 5, 'Nguyễn Văn Chiểu', 4, 5, 'signed', '2025-12-02 09:24:32', NULL, 5, 'Nguyễn Văn Chiểu', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-04-1.jpg', '277', '2025-12-02 01:12:24'),
(73, 23, 3, 'Đinh Văn Vịnh', 2, 3, 'signed', '2025-12-02 09:14:49', NULL, 3, 'Đinh Văn Vịnh', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 02:13:39'),
(74, 23, 4, 'Tạ Quý Thọ', 3, 4, 'signed', '2025-12-02 09:15:14', NULL, 4, 'Tạ Quý Thọ', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/photo_2025-10-17_10-09-07-1.jpg', '277', '2025-12-02 02:13:39'),
(75, 23, 5, 'Nguyễn Văn Chiểu', 4, 5, 'signed', '2025-12-02 09:16:31', NULL, 5, 'Nguyễn Văn Chiểu', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-04-1.jpg', '277', '2025-12-02 02:13:39'),
(76, 24, 1, 'Nguyễn Cảnh Hợp', 1, 2, 'signed', '2025-12-02 09:48:31', NULL, 1, 'Nguyễn Cảnh Hợp', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 02:48:05'),
(77, 24, 3, 'Đinh Văn Vịnh', 2, 3, 'signed', '2025-12-02 09:49:06', NULL, 3, 'Đinh Văn Vịnh', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 02:48:05'),
(78, 24, 4, 'Tạ Quý Thọ', 3, 4, 'signed', '2025-12-02 09:49:58', NULL, 4, 'Tạ Quý Thọ', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/photo_2025-10-17_10-09-07-1.jpg', '277', '2025-12-02 02:48:05'),
(79, 24, 5, 'Nguyễn Văn Chiểu', 4, 5, 'signed', '2025-12-02 09:57:19', NULL, 5, 'Nguyễn Văn Chiểu', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-04-1.jpg', '277', '2025-12-02 02:48:05'),
(80, 25, 1, 'Nguyễn Cảnh Hợp', 1, 2, 'signed', '2025-12-02 10:28:14', NULL, 1, 'Nguyễn Cảnh Hợp', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 03:27:46'),
(81, 25, 3, 'Đinh Văn Vịnh', 2, 3, 'signed', '2025-12-02 10:30:23', NULL, 3, 'Đinh Văn Vịnh', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 03:27:46'),
(82, 25, 4, 'Tạ Quý Thọ', 3, 4, 'signed', '2025-12-02 10:32:24', NULL, 4, 'Tạ Quý Thọ', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/photo_2025-10-17_10-09-07-1.jpg', '277', '2025-12-02 03:27:46'),
(83, 25, 5, 'Nguyễn Văn Chiểu', 4, 5, 'signed', '2025-12-02 10:34:00', NULL, 5, 'Nguyễn Văn Chiểu', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-04-1.jpg', '277', '2025-12-02 03:27:46'),
(85, 26, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:44:27'),
(86, 26, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:44:27'),
(87, 26, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:44:27'),
(88, 27, 1, 'Nguyễn Cảnh Hợp', 1, 2, 'signed', '2025-12-02 11:21:25', NULL, 1, 'Nguyễn Cảnh Hợp', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 03:52:56'),
(89, 27, 3, 'Đinh Văn Vịnh', 2, 3, 'signed', '2025-12-02 11:22:40', NULL, 3, 'Đinh Văn Vịnh', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 03:52:56'),
(90, 27, 4, 'Tạ Quý Thọ', 3, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:52:56'),
(91, 27, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:52:56'),
(92, 28, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:54:13'),
(93, 28, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:54:13'),
(94, 28, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:54:13'),
(95, 28, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 03:54:13'),
(96, 29, 1, 'Nguyễn Cảnh Hợp', 1, 2, 'signed', '2025-12-02 11:35:12', NULL, 1, 'Nguyễn Cảnh Hợp', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 04:33:46'),
(97, 29, 3, 'Đinh Văn Vịnh', 2, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 04:33:46'),
(98, 29, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 04:33:46'),
(99, 29, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 04:33:46'),
(100, 31, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 06:06:56'),
(101, 31, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 06:06:56'),
(102, 31, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 06:06:56'),
(103, 31, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 06:06:56'),
(104, 32, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:05:49'),
(105, 32, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:05:49'),
(106, 32, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:05:49'),
(107, 32, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:05:49'),
(108, 33, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:08:57'),
(109, 33, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:08:57'),
(110, 33, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:08:57'),
(111, 33, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:08:57'),
(112, 34, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:11:49'),
(113, 34, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:11:49'),
(114, 34, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:11:49'),
(115, 34, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:11:49'),
(116, 36, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:25:16'),
(117, 36, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:25:16'),
(118, 36, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:25:16'),
(119, 36, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:25:16'),
(120, 35, 1, 'Nguyễn Cảnh Hợp', 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:25:24'),
(121, 35, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:25:24'),
(122, 35, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:25:24'),
(123, 35, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 07:25:24'),
(124, 37, 1, 'Nguyễn Cảnh Hợp', 1, 2, 'signed', '2025-12-03 00:03:29', NULL, 1, 'Lương Đức Thuỷ', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', '277', '2025-12-02 14:07:02'),
(125, 37, 3, 'Đinh Văn Vịnh', 2, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 14:07:02'),
(126, 37, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 14:07:02'),
(127, 37, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 14:07:02'),
(128, 38, 1, 'Lương Đức Thuỷ', 1, 1, 'pending', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 17:01:41'),
(129, 38, 3, 'Đinh Văn Vịnh', 2, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 17:01:41'),
(130, 38, 4, 'Tạ Quý Thọ', 3, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 17:01:41'),
(131, 38, 5, 'Nguyễn Văn Chiểu', 4, 1, '', NULL, NULL, NULL, NULL, NULL, '277', '2025-12-02 17:01:41');

-- --------------------------------------------------------

--
-- Table structure for table `file_signatures`
--

CREATE TABLE `file_signatures` (
  `id` int UNSIGNED NOT NULL,
  `task_file_id` int UNSIGNED NOT NULL,
  `approval_id` int UNSIGNED DEFAULT NULL,
  `document_id` int DEFAULT NULL,
  `signed_file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signed_file_path` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signed_file_size` bigint DEFAULT NULL,
  `signed_mime` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `signed_by` int UNSIGNED DEFAULT NULL,
  `signed_at` datetime DEFAULT NULL,
  `status` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'signed',
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `file_signatures`
--

INSERT INTO `file_signatures` (`id`, `task_file_id`, `approval_id`, `document_id`, `signed_file_name`, `signed_file_path`, `signed_file_size`, `signed_mime`, `signed_by`, `signed_at`, `status`, `note`, `created_at`, `updated_at`) VALUES
(9, 277, 23, 35, 'to_trinh_09_11_2025.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/signed-58.pdf', NULL, NULL, 4, '2025-11-13 16:50:19', 'approved', 'Duyệt bởi Ta Quy Tho lúc 13/11/2025, 23:50:18', '2025-11-13 23:50:19', '2025-11-13 23:50:19'),
(10, 17, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, NULL, NULL, 3, '2025-11-30 14:54:26', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 30/11/2025, 21:54:25', '2025-11-30 21:54:26', '2025-11-30 21:54:26'),
(11, 23, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, NULL, NULL, 3, '2025-12-01 01:26:58', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 08:26:57', '2025-12-01 08:26:58', '2025-12-01 08:26:58'),
(12, 24, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 02:13:53', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:13:52', '2025-12-01 09:13:53', '2025-12-01 09:13:53'),
(13, 25, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 02:34:15', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:34:14', '2025-12-01 09:34:15', '2025-12-01 09:34:15'),
(14, 27, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 02:35:40', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:35:39', '2025-12-01 09:35:40', '2025-12-01 09:35:40'),
(15, 26, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 02:40:41', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:40:40', '2025-12-01 09:40:41', '2025-12-01 09:40:41'),
(16, 28, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 02:47:22', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:47:20', '2025-12-01 09:47:22', '2025-12-01 09:47:22'),
(17, 29, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 02:49:38', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:49:35', '2025-12-01 09:49:39', '2025-12-01 09:49:39'),
(18, 30, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 02:53:55', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:53:54', '2025-12-01 09:53:57', '2025-12-01 09:53:57'),
(19, 31, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 02:55:09', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:55:07', '2025-12-01 09:55:09', '2025-12-01 09:55:09'),
(20, 32, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 03:04:46', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:04:44', '2025-12-01 10:04:47', '2025-12-01 10:04:47'),
(21, 33, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 03:13:23', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:13:22', '2025-12-01 10:13:23', '2025-12-01 10:13:23'),
(22, 34, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 03:15:22', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:15:18', '2025-12-01 10:15:22', '2025-12-01 10:15:22'),
(23, 35, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 03:21:33', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:21:32', '2025-12-01 10:21:33', '2025-12-01 10:21:33'),
(24, 36, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 03:24:00', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:23:59', '2025-12-01 10:24:02', '2025-12-01 10:24:02'),
(25, 38, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 03:42:12', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:42:11', '2025-12-01 10:42:14', '2025-12-01 10:42:14'),
(26, 39, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 03:49:00', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:48:58', '2025-12-01 10:48:59', '2025-12-01 10:48:59'),
(27, 40, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 03:58:01', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:58:00', '2025-12-01 10:58:01', '2025-12-01 10:58:01'),
(28, 46, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 04:22:21', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 11:22:20', '2025-12-01 11:22:21', '2025-12-01 11:22:21'),
(29, 47, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 1, '2025-12-01 04:29:19', 'approved', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 11:29:18', '2025-12-01 11:29:19', '2025-12-01 11:29:19'),
(30, 48, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 1, '2025-12-01 04:31:42', 'approved', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 11:31:41', '2025-12-01 11:31:42', '2025-12-01 11:31:42'),
(31, 49, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 1, '2025-12-01 04:34:34', 'approved', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 11:34:33', '2025-12-01 11:34:34', '2025-12-01 11:34:34'),
(32, 50, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 04:35:06', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 11:35:05', '2025-12-01 11:35:07', '2025-12-01 11:35:07'),
(33, 51, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 4, '2025-12-01 06:11:35', 'approved', 'Duyệt bởi Ta Quy Tho lúc 01/12/2025, 13:11:34', '2025-12-01 13:11:35', '2025-12-01 13:11:35'),
(34, 52, NULL, NULL, 'Converted_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 5, '2025-12-01 06:12:57', 'approved', 'Duyệt bởi Nguyen Van Chieu lúc 01/12/2025, 13:12:56', '2025-12-01 13:12:57', '2025-12-01 13:12:57'),
(35, 53, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 1, '2025-12-01 06:40:19', 'approved', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 13:40:18', '2025-12-01 13:40:21', '2025-12-01 13:40:21'),
(36, 54, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 06:46:44', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 13:46:43', '2025-12-01 13:46:44', '2025-12-01 13:46:44'),
(37, 57, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 07:15:32', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 14:15:31', '2025-12-01 14:15:32', '2025-12-01 14:15:32'),
(38, 58, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 1, '2025-12-01 07:32:37', 'approved', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 14:32:36', '2025-12-01 14:32:39', '2025-12-01 14:32:39'),
(39, 59, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-01 07:46:06', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 14:46:04', '2025-12-01 14:46:05', '2025-12-01 14:46:05'),
(40, 71, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 5, '2025-12-02 02:24:32', 'approved', 'Duyệt bởi Nguyen Van Chieu lúc 02/12/2025, 09:24:31', '2025-12-02 09:24:32', '2025-12-02 09:24:32'),
(41, 73, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-02 02:32:25', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 02/12/2025, 09:32:24', '2025-12-02 09:32:25', '2025-12-02 09:32:25'),
(42, 69, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-02 02:35:22', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 02/12/2025, 09:35:21', '2025-12-02 09:35:22', '2025-12-02 09:35:22'),
(43, 80, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 1, '2025-12-02 03:28:14', 'approved', 'Duyệt bởi Nguyen Canh Hop lúc 02/12/2025, 10:28:13', '2025-12-02 10:28:14', '2025-12-02 10:28:14'),
(44, 82, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 4, '2025-12-02 03:32:48', 'approved', 'Duyệt bởi Ta Quy Tho lúc 02/12/2025, 10:32:47', '2025-12-02 10:32:48', '2025-12-02 10:32:48'),
(45, 89, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 3, '2025-12-02 04:26:08', 'approved', 'Duyệt bởi Dinh Van Vinh lúc 02/12/2025, 11:26:02', '2025-12-02 11:26:08', '2025-12-02 11:26:08'),
(46, 96, NULL, NULL, 'origin_20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.pdf', NULL, NULL, NULL, 1, '2025-12-02 04:35:13', 'approved', 'Duyệt bởi Nguyen Canh Hop lúc 02/12/2025, 11:35:11', '2025-12-02 11:35:13', '2025-12-02 11:35:13'),
(47, 124, NULL, NULL, 'origin_a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', NULL, NULL, NULL, 1, '2025-12-02 17:03:29', 'approved', 'Duyệt bởi Luong Duc Thuy lúc 03/12/2025, 00:03:28', '2025-12-03 00:03:29', '2025-12-03 00:03:29');

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
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `name`, `code`, `description`, `created_at`, `updated_at`) VALUES
(1, 'super admin', 'super_admin', 'Super Admin', '2025-04-21 00:06:00', '2025-11-12 15:56:43'),
(2, 'admin', 'admin', 'admin', '2025-04-21 00:06:00', '2025-12-02 22:55:45'),
(3, 'user', 'user', 'user', '2025-04-21 00:06:00', '2025-12-02 22:55:55');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `id` int NOT NULL,
  `role_id` int NOT NULL,
  `permission_id` int DEFAULT NULL,
  `module` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
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
  `collaborated_by` int DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `proposed_by` int DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` enum('todo','doing','done','overdue','request_approval') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'todo',
  `approval_status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_at` datetime DEFAULT NULL,
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
  `approver_ids` json DEFAULT NULL COMMENT 'Danh sách id người duyệt (mảng JSON)',
  `needs_approval` tinyint(1) NOT NULL DEFAULT '0' COMMENT '0 = không cần duyệt, 1 = cần duyệt',
  `current_level` int DEFAULT '1',
  `id_department` int DEFAULT NULL,
  `progress` tinyint UNSIGNED DEFAULT '0',
  `latest_upload_batch` int DEFAULT NULL,
  `latest_files_json` json DEFAULT NULL,
  `overdue_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approval_roster_json` json NOT NULL DEFAULT (json_array())
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tasks`
--

INSERT INTO `tasks` (`id`, `parent_id`, `title`, `description`, `assigned_to`, `collaborated_by`, `assigned_by`, `proposed_by`, `start_date`, `end_date`, `status`, `approval_status`, `approved_at`, `linked_type`, `linked_id`, `step_code`, `step_id`, `created_by`, `priority`, `comments_count`, `created_at`, `updated_at`, `approval_steps`, `approver_ids`, `needs_approval`, `current_level`, `id_department`, `progress`, `latest_upload_batch`, `latest_files_json`, `overdue_reason`, `approval_roster_json`) VALUES
(1, NULL, 'Thiết kế hồ sơ thầu', 'Chuẩn bị file bản vẽ và hồ sơ năng lực', 5, NULL, NULL, 4, '2025-07-01', '2025-08-25', 'done', 'approved', NULL, 'bidding', 2, 4, 112, 1, 'normal', 0, '2025-06-04 01:23:15', '2025-09-22 09:49:04', 1, NULL, 0, 1, 4, 100, NULL, NULL, NULL, '[]'),
(2, NULL, 'Thiết kế hồ sơ thầu', 'Mô tả công việc thiết kế hồ sơ thầu', 3, NULL, NULL, 2, '2025-06-25', '2025-07-31', 'done', 'approved', NULL, 'bidding', 6, 5, 237, 2, 'high', 1, '2025-06-04 01:37:15', '2025-08-22 19:19:43', 1, NULL, 0, 1, 5, 100, NULL, NULL, NULL, '[]'),
(3, NULL, 'Nghiên cứu yêu cầu khách hàng', 'Mô tả công việc nghiên cứu yêu cầu khách hàng', 9, NULL, NULL, 4, '2025-06-29', '2025-07-31', 'todo', 'rejected', NULL, 'contract', 30, 16, 265, 1, 'high', 3, '2025-06-04 01:37:24', '2025-08-05 09:04:44', 1, NULL, 0, 1, 5, 75, NULL, NULL, NULL, '[]'),
(10, NULL, 'Mua sắm vật tư', 'Mô tả công việc mua sắm vật tư', 10, NULL, NULL, 2, '2025-06-25', '2025-07-31', 'todo', 'rejected', NULL, 'bidding', 2, 3, 111, 2, 'high', 5, '2025-06-04 01:38:26', '2025-08-14 07:20:14', 1, NULL, 0, 1, 5, 75, NULL, NULL, 'tesst', '[]'),
(26, 3, 'Thiết kế giao diện phụ - task con 3', 'Thiết kế giao diện cho phần chi tiết', 9, NULL, NULL, 2, '2025-06-15', '2025-06-16', 'todo', 'pending', NULL, 'bidding', 2, 3, 111, 1, 'high', 0, '2025-06-05 05:38:39', '2025-08-14 07:20:46', 1, NULL, 0, 1, 3, 75, NULL, NULL, 'Tổng Bí thư: Trung ương khóa mới dự kiến có 200 ủy viên ddd\n- test\n- test 2', '[]'),
(27, NULL, 'Task thuộc bước 1 - Gói thầu có ngay bat dau - ngay ket thuc', 'Mô tả công việc đăng ký bảo hành', 1, NULL, NULL, 4, '2025-06-10', '2025-06-14', 'done', 'approved', NULL, 'bidding', 2, 1, 109, 3, 'high', 0, '2025-06-05 06:16:42', '2025-08-05 09:58:25', 1, NULL, 0, 1, 1, 100, NULL, NULL, NULL, '[]'),
(28, 3, 'Thiết kế giao diện phụ - task con 3 có ngay bat dau - ngay ket thuc', 'Thiết kế giao diện cho phần chi tiết', 17, NULL, NULL, 4, '2025-06-25', '2025-07-31', 'done', 'approved', NULL, 'bidding', 2, 3, 111, 1, 'normal', 0, '2025-06-05 06:19:14', '2025-07-20 15:21:54', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(29, 18, 'sub task 1', 'tesst subtask', 13, NULL, NULL, 4, '2025-06-24', '2025-07-31', '', 'pending', NULL, 'bidding', 5, 5, 104, 1, 'normal', 0, '2025-06-23 18:15:50', '2025-07-20 15:21:54', 1, NULL, 0, 1, 5, 0, NULL, NULL, NULL, '[]'),
(30, NULL, 'test', 'tesst tesst', 22, NULL, NULL, 1, '2025-06-24', '2025-07-30', 'done', 'approved', NULL, 'bidding', 5, 5, 104, 1, 'normal', 0, '2025-06-23 18:52:15', '2025-09-03 19:15:10', 1, NULL, 0, 1, 1, 100, NULL, NULL, NULL, '[]'),
(31, NULL, 'Task thuộc bước 1 - Gói thầu có ngay bat dau - ngay ket thuc', 'Mô tả công việc đăng ký bảo hành', 1, NULL, NULL, 4, '2025-08-29', '2025-08-31', 'overdue', 'pending', NULL, 'bidding', 2, 3, 111, 3, 'high', 0, '2025-06-24 18:47:18', '2025-08-05 09:07:21', 1, NULL, 0, 1, 4, 50, NULL, NULL, NULL, '[]'),
(32, 1, 'tesst subtask', 'xxxxxxx', 22, NULL, NULL, 4, '2025-06-28', '2025-07-31', 'done', 'approved', NULL, 'bidding', 2, 1, 109, 1, 'normal', 0, '2025-06-28 08:01:02', '2025-07-20 15:21:54', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(33, NULL, 'test task mới', 'test', 3, NULL, NULL, 4, '2025-06-29', '2025-07-31', 'done', 'approved', NULL, 'bidding', 5, 9, 108, 1, 'normal', 0, '2025-06-29 01:28:22', '2025-08-22 19:20:30', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(34, NULL, 'test nhiêm vụ mới', 'test test', 7, NULL, NULL, 4, '2025-06-29', '2025-07-31', 'doing', 'pending', NULL, 'bidding', 2, 2, 110, 1, 'normal', 0, '2025-06-29 01:36:07', '2025-07-20 15:21:54', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(35, NULL, 'test mới 3', 'test nhé', 7, NULL, NULL, 2, '2025-06-29', '2025-08-07', 'doing', 'pending', NULL, 'bidding', 8, 7, 79, 1, 'high', 0, '2025-06-29 01:51:48', '2025-07-20 15:21:54', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(36, NULL, 'mới', 'đasadd', 9, NULL, NULL, 1, '2025-06-30', '2025-07-31', 'doing', 'pending', NULL, 'bidding', 2, 1, 109, 1, 'normal', 0, '2025-06-29 11:25:28', '2025-07-20 15:21:54', 1, NULL, 0, 1, 5, 0, NULL, NULL, NULL, '[]'),
(37, NULL, 'test nhiệm vụ hợp đồng 1', 'test nhiệm vụ hợp đồng 1', 23, NULL, NULL, 1, '2025-06-30', '2025-07-31', 'doing', 'pending', NULL, 'contract', 30, 10, 259, 1, 'normal', 0, '2025-06-30 09:33:07', '2025-07-20 15:21:54', 1, NULL, 0, 1, 5, 0, NULL, NULL, NULL, '[]'),
(38, NULL, 'test nhiệm vụ hợp đồng 2', 'test nhiệm vụ hợp đồng 2', 19, NULL, NULL, 4, '2025-06-30', '2025-07-31', 'doing', 'pending', NULL, 'contract', 30, 11, 260, 1, 'high', 0, '2025-06-30 09:37:45', '2025-08-03 20:30:08', 1, NULL, 0, 1, 4, 50, NULL, NULL, NULL, '[]'),
(39, NULL, 'duyệt hợp đồng mua', 'duyệt hợp đồng mua', 21, NULL, NULL, 4, '2025-06-30', '2025-07-31', 'doing', 'pending', NULL, 'contract', 30, 12, 261, 1, 'high', 0, '2025-06-30 09:48:27', '2025-07-20 15:21:54', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(40, NULL, 'nhiệm vụ cho gói thầu 1', 'test chấm thầu', 4, NULL, NULL, 1, '2025-07-10', '2025-08-05', 'doing', 'pending', NULL, 'bidding', 2, 6, 114, 1, 'normal', 0, '2025-06-30 09:54:52', '2025-08-05 09:04:31', 1, NULL, 0, 1, 2, 50, NULL, NULL, NULL, '[]'),
(41, NULL, 'nhiệm vụ hợp đồng 2', 'nghiệm thu', 23, NULL, NULL, 1, '2025-06-30', '2025-07-31', 'doing', 'pending', NULL, 'contract', 30, 16, 265, 1, 'normal', 0, '2025-06-30 09:58:15', '2025-07-20 15:21:54', 1, NULL, 0, 1, 4, 0, NULL, NULL, NULL, '[]'),
(42, NULL, 'test nhiệm vụ hợp đồng 4', 'kiểm tra hàng hóa', 5, NULL, NULL, 4, '2025-08-13', '2025-08-21', 'doing', 'pending', NULL, 'contract', 30, 15, 264, 1, 'high', 0, '2025-06-30 10:05:48', '2025-07-20 15:21:54', 1, NULL, 0, 1, 4, 0, NULL, NULL, NULL, '[]'),
(43, NULL, 'test nhiệm vụ hợp đồng 5', 'kiểm tra hàng hóa', 1, NULL, NULL, 2, '2025-07-01', '2025-08-31', 'doing', 'pending', NULL, 'contract', 30, 15, 264, 1, 'normal', 0, '2025-06-30 10:10:57', '2025-07-20 15:21:54', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(44, NULL, 'test nhiệm vụ hợp đồng 6', 'nghiệm thu', 24, NULL, NULL, 2, '2025-07-01', '2025-08-31', 'doing', 'pending', NULL, 'contract', 33, 16, 316, 1, 'normal', 0, '2025-06-30 10:12:22', '2025-07-20 15:21:54', 1, NULL, 0, 1, 5, 0, NULL, NULL, NULL, '[]'),
(45, NULL, 'test nhiệm vụ gói thầu 7', 'chấm thầu', 24, NULL, NULL, 2, '2025-07-31', '2025-08-29', 'doing', 'pending', NULL, 'bidding', 3, 6, 123, 1, 'high', 0, '2025-06-30 10:13:58', '2025-08-05 09:04:52', 1, NULL, 0, 1, 3, 50, NULL, NULL, NULL, '[]'),
(46, NULL, 'test hợp đồng 8', 'test hợp đồng 8', 1, NULL, NULL, 4, '2025-07-24', '2025-08-28', 'doing', 'pending', NULL, 'contract', 30, 10, 259, 1, 'high', 0, '2025-06-30 10:23:23', '2025-08-11 06:41:09', 1, NULL, 0, 1, 1, 50, NULL, NULL, NULL, '[]'),
(47, NULL, 'nhiệm vụ mới', 'mô tả mẫu', 15, NULL, NULL, 4, '2025-07-01', '2025-08-28', 'doing', 'pending', NULL, 'bidding', 2, 1, 109, 1, 'normal', 0, '2025-07-01 04:00:46', '2025-07-20 15:21:54', 1, NULL, 0, 1, 5, 0, NULL, NULL, NULL, '[]'),
(48, NULL, 'nhiệm vụ cho hợp đồng mới', 'mô tả mẫu', 20, NULL, NULL, 4, '2025-07-01', '2025-08-30', 'doing', 'pending', NULL, 'contract', 30, 15, 264, 1, 'normal', 0, '2025-07-01 04:07:24', '2025-07-20 15:21:54', 1, NULL, 0, 1, 4, 0, NULL, NULL, NULL, '[]'),
(59, NULL, 'duyệt 5', '234322424', 9, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 4, NULL, 1, 'normal', 0, '2025-07-31 22:19:12', '2025-07-31 22:19:12', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(60, NULL, 'duyệt 6', '3432424', 5, NULL, NULL, 4, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 4, NULL, 1, 'normal', 0, '2025-07-31 22:22:38', '2025-07-31 22:22:38', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(61, NULL, 'duyệt 4', '4234234324', 4, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 4, NULL, 1, 'normal', 0, '2025-07-31 22:59:44', '2025-07-31 22:59:44', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(62, NULL, 'tesst 6', '432424', 4, NULL, NULL, 4, '2025-08-01', '2025-09-30', '', 'pending', NULL, 'bidding', 2, 4, 112, 1, 'high', 0, '2025-07-31 23:22:55', '2025-08-05 09:04:11', 0, NULL, 0, 1, 3, 25, NULL, NULL, NULL, '[]'),
(63, NULL, 'tesst 7', '423424', 9, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 4, 112, 1, 'normal', 0, '2025-07-31 23:24:39', '2025-07-31 23:24:39', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(64, NULL, 'hồ sơ dự thầu 1', '3545345435435', 6, NULL, NULL, 4, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 5, 113, 1, 'normal', 0, '2025-07-31 23:26:27', '2025-07-31 23:26:27', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(65, NULL, 'hồ sơ dự thầu 2', '433535345', 8, NULL, NULL, 7, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 5, 113, 1, 'normal', 0, '2025-07-31 23:28:19', '2025-07-31 23:28:19', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(66, NULL, 'nhiệm vụ lập 1', '43543535435', 9, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 3, NULL, 1, 'normal', 0, '2025-07-31 23:39:43', '2025-07-31 23:39:43', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(67, NULL, 'nhiệm vụ triển khai 1', '3423432434', 8, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 5, 113, 1, 'normal', 0, '2025-07-31 23:41:24', '2025-07-31 23:41:24', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(68, NULL, 'triển khai 6', '434324324', 8, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 5, 113, 1, 'normal', 0, '2025-07-31 23:43:47', '2025-07-31 23:43:47', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(69, NULL, 'chấm 1', '4432424', 8, NULL, NULL, 6, '2025-08-01', '2025-09-24', 'doing', 'pending', NULL, 'bidding', 2, 6, 114, 1, 'normal', 0, '2025-07-31 23:49:57', '2025-07-31 23:49:57', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(70, NULL, 'chấm thầu 3', 'ưqeqeqeqe', 5, NULL, NULL, 6, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 6, 114, 1, 'normal', 0, '2025-07-31 23:54:03', '2025-07-31 23:54:03', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(71, NULL, 'chấm thầu 4', '4324242424', 8, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 6, 114, 1, 'normal', 0, '2025-07-31 23:55:42', '2025-07-31 23:55:42', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(72, NULL, 'chấm 5', '242432424324', 23, NULL, NULL, 22, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 6, 114, 1, 'normal', 0, '2025-07-31 23:57:15', '2025-07-31 23:57:15', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(73, NULL, 'chấm 7', '443242424', 21, NULL, NULL, 24, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 6, 114, 1, 'normal', 0, '2025-08-01 00:02:36', '2025-08-01 00:02:36', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(74, NULL, 'hợp đồng bán 1', '4234424234', 18, NULL, NULL, 6, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 8, 116, 1, 'normal', 0, '2025-08-01 00:05:35', '2025-08-01 00:05:35', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(75, NULL, 'hợp đồng 2', '423432424242', 7, NULL, NULL, 19, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 8, 116, 1, 'normal', 0, '2025-08-01 00:06:51', '2025-08-01 00:06:51', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(76, NULL, 'hợp đồng 3', '435435353535', 20, NULL, NULL, 13, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 8, 116, 1, 'normal', 0, '2025-08-01 00:10:44', '2025-08-01 00:10:44', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(77, NULL, 'nhập dữ liệu 1', '4324342424324', 18, NULL, NULL, 19, '2025-08-01', '2025-09-30', '', 'pending', NULL, 'bidding', 2, 7, 115, 1, 'normal', 0, '2025-08-01 00:11:29', '2025-08-01 00:11:29', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(78, NULL, 'nhập dữ liệu 2', '65465465464646', 10, NULL, NULL, 15, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 7, 115, 1, 'normal', 0, '2025-08-01 00:12:13', '2025-08-01 00:12:13', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(79, NULL, 'nhập dữ liệu 3', '453535353', 12, NULL, NULL, 17, '2025-08-01', '2025-08-31', '', 'pending', NULL, 'bidding', 2, 7, 115, 1, 'normal', 0, '2025-08-01 00:12:46', '2025-08-01 00:12:46', 0, NULL, 0, 1, 4, 0, NULL, NULL, NULL, '[]'),
(80, NULL, 'nhập dữ liệu 4', '42432424', 1, NULL, NULL, 19, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 7, 115, 1, 'normal', 0, '2025-08-01 00:13:22', '2025-08-05 09:06:48', 0, NULL, 0, 1, 3, 75, NULL, NULL, NULL, '[]'),
(81, NULL, 'duyệt 1', '4234242424', 18, NULL, NULL, 5, '2025-08-01', '2025-09-30', '', 'pending', NULL, 'bidding', 2, 9, NULL, 1, 'low', 0, '2025-08-01 00:15:01', '2025-08-01 00:15:01', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(82, NULL, 'duyệt 2', '34242434', 19, NULL, NULL, 7, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 9, 117, 1, 'normal', 0, '2025-08-01 00:15:51', '2025-08-01 00:15:51', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(83, NULL, 'duyệt 1', '543535', 21, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'request_approval', 'pending', NULL, 'bidding', 10, 1, 82, 1, 'normal', 0, '2025-08-01 00:16:45', '2025-08-01 00:16:45', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(84, NULL, 'nhận 1', '42432424', 24, NULL, NULL, 6, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 10, 1, 82, 1, 'normal', 0, '2025-08-01 00:17:30', '2025-08-01 00:17:30', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(85, NULL, 'thanh toán 1', '432432424', 22, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'contract', 30, 14, 263, 1, 'normal', 0, '2025-08-01 01:58:36', '2025-08-01 01:58:36', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(86, NULL, 'thanh toán 2', '453453535', 21, NULL, NULL, 19, '2025-08-01', '2025-09-30', 'request_approval', 'pending', NULL, 'contract', 30, 14, 263, 1, 'low', 0, '2025-08-01 01:59:17', '2025-08-01 01:59:17', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(87, NULL, 'nhập kho hàng 1', '24234243', 24, NULL, NULL, 19, '2025-08-01', '2025-09-30', 'todo', 'pending', NULL, 'contract', 30, 18, 267, 1, 'normal', 0, '2025-08-01 01:59:52', '2025-08-01 01:59:52', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(88, NULL, 'nhập kho hàng 2', '4324424', 23, NULL, NULL, 20, '2025-08-01', '2025-09-30', '', 'pending', NULL, 'contract', 30, 18, 267, 1, 'high', 0, '2025-08-01 02:00:26', '2025-08-05 09:04:55', 0, NULL, 0, 1, 4, 25, NULL, NULL, NULL, '[]'),
(89, NULL, 'đánh giá 1', 'ưqeqeqeqe', 12, NULL, NULL, 5, '2025-08-01', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 2, 2, 110, 1, 'normal', 0, '2025-08-01 02:03:52', '2025-08-01 02:03:52', 0, NULL, 0, 1, 5, 0, NULL, NULL, NULL, '[]'),
(190, NULL, 'nhiệm vụ nội bộ 18/08', '324234243', 14, NULL, NULL, 17, '2025-08-18', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-18 07:29:09', '2025-08-18 07:29:09', 0, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(191, 190, 'task con 1', '45435435', 23, NULL, NULL, 22, '2025-08-18', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-18 07:29:41', '2025-08-18 07:29:41', 0, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(192, 190, 'task con 2', '42343242', 23, NULL, NULL, 20, '2025-08-18', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-18 07:30:05', '2025-08-18 07:30:05', 0, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(193, 190, 'task con 3', '4232342', 24, NULL, NULL, 23, '2025-08-18', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-18 07:30:28', '2025-08-18 07:30:28', 0, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(194, 190, 'task con 4', '423423432', 16, NULL, NULL, 19, '2025-08-18', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-18 07:30:55', '2025-08-18 07:30:55', 0, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(195, 190, 'task con 5', '3432432424', 13, NULL, NULL, 22, '2025-08-18', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-18 07:31:34', '2025-08-18 07:31:34', 0, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(196, NULL, 'test nhiệm vụ gói thầu', '423432424', 19, NULL, NULL, 5, '2025-08-18', '2025-09-30', 'todo', 'pending', NULL, 'bidding', 2, 1, 302, 3, 'normal', 0, '2025-08-18 08:17:01', '2025-08-18 08:17:01', 0, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(197, NULL, 'việc 1', '42332424', 5, NULL, NULL, 4, '2025-08-18', '2025-09-30', '', 'pending', NULL, 'bidding', 36, 1, 313, 3, 'normal', 0, '2025-08-18 08:19:37', '2025-08-18 08:19:37', 0, NULL, 0, 1, 4, 0, NULL, NULL, NULL, '[]'),
(198, NULL, 'việc 2', '4324324324', 12, NULL, NULL, 4, '2025-08-18', '2025-09-30', 'doing', 'pending', NULL, 'bidding', 36, 1, 313, 3, 'normal', 0, '2025-08-18 08:20:04', '2025-08-18 08:20:04', 0, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(199, NULL, 'tesst mới', 'ok', 4, NULL, NULL, 4, '2025-08-21', '2025-09-30', 'request_approval', 'approved', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-08-21 08:33:49', '2025-08-31 22:28:56', 0, NULL, 0, 0, 3, 100, NULL, NULL, NULL, '[]'),
(200, NULL, 'test 2', '32424423', 4, NULL, NULL, 17, '2025-08-21', '2025-09-30', 'request_approval', 'approved', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-08-21 08:45:12', '2025-08-31 22:29:25', 0, NULL, 0, 0, 3, 100, NULL, NULL, NULL, '[]'),
(201, NULL, 'test mới 22-08 pm', '422342424', 4, NULL, NULL, 4, '2025-08-22', '2025-09-30', 'done', 'approved', NULL, 'bidding', 35, 2, 285, 3, 'normal', 0, '2025-08-22 07:51:20', '2025-08-22 07:52:11', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(202, NULL, 'test 3', '342432424', 5, NULL, NULL, 5, '2025-08-22', '2025-09-25', 'done', 'approved', NULL, 'bidding', 35, 3, 286, 3, 'high', 0, '2025-08-22 08:05:13', '2025-08-22 08:05:37', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(203, NULL, 'test mới 3', '42342424', 5, NULL, NULL, 5, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 11, 1, 91, 3, 'normal', 0, '2025-08-22 10:13:27', '2025-08-22 10:14:07', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(204, NULL, 'test mới', '34234324', 5, NULL, NULL, 19, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 35, 4, 287, 3, 'normal', 0, '2025-08-22 10:51:58', '2025-08-23 08:31:05', 1, NULL, 0, 1, 3, 100, NULL, NULL, NULL, '[]'),
(205, NULL, 'mới nữa', '32424234324', 21, NULL, NULL, 21, '2025-08-23', '2025-09-30', 'todo', 'rejected', NULL, 'bidding', 35, 6, 289, 3, 'normal', 0, '2025-08-22 10:53:12', '2025-08-23 08:35:50', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(206, NULL, 'mới 222', '3453534534', 17, NULL, NULL, 17, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 35, 8, 291, 3, 'normal', 0, '2025-08-22 10:53:50', '2025-08-23 08:50:26', 1, NULL, 0, 1, 3, 100, NULL, NULL, NULL, '[]'),
(207, NULL, 'tesst 5', '3424324', 18, NULL, NULL, 18, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 35, 7, 290, 3, 'normal', 0, '2025-08-22 18:56:00', '2025-08-27 07:15:14', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(208, NULL, 'tesst 6', '3423432', 13, NULL, NULL, 13, '2025-08-23', '2025-09-30', 'request_approval', 'pending', NULL, 'bidding', 35, 9, 292, 3, 'normal', 0, '2025-08-22 18:57:27', '2025-08-22 18:57:27', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(209, NULL, 'gói thầu mới tên dài gói thầu mới tên dài  gói thầu mới tên dài  gói thầu mới tên dài  gói thầu mới tên dài  gói thầu mới tên dài  gói thầu mới tên dài  gói thầu mới tên dài ', '3243243224', 16, NULL, NULL, 16, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 35, 7, 290, 3, 'normal', 0, '2025-08-22 19:00:57', '2025-08-23 08:51:17', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(210, NULL, 'test nhiệm vụ mới', '3424324324', 17, NULL, NULL, 17, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 37, 1, 325, 3, 'normal', 0, '2025-08-22 19:17:35', '2025-08-22 19:23:23', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(211, NULL, 'nhiệm vụ mới gói thầu', '23423423424', 18, NULL, NULL, 22, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 37, 1, 325, 3, 'normal', 0, '2025-08-22 19:21:39', '2025-08-22 19:22:05', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(212, NULL, 'thêm việc 3', '34422424', 24, NULL, NULL, 24, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 37, 1, 325, 3, 'normal', 0, '2025-08-22 19:51:39', '2025-08-22 19:52:06', 1, NULL, 0, 1, 1, 100, NULL, NULL, NULL, '[]'),
(214, NULL, 'việc 4', '324234324', 13, NULL, NULL, 13, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 38, 1, 337, 3, 'normal', 0, '2025-08-22 19:55:10', '2025-08-22 19:55:34', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(215, NULL, 'việc 5', '432424234', 22, NULL, NULL, 22, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 38, 2, 338, 3, 'normal', 0, '2025-08-22 19:56:24', '2025-08-22 19:56:39', 1, NULL, 0, 1, 4, 100, NULL, NULL, NULL, '[]'),
(216, NULL, 'việc xxx', '234234324', 22, NULL, NULL, 4, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 38, 3, 339, 3, 'normal', 0, '2025-08-22 19:58:33', '2025-08-22 19:58:52', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(217, NULL, 'việc xxx2423', '42342424', 23, NULL, NULL, 23, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'bidding', 38, 4, 340, 3, 'normal', 0, '2025-08-22 19:59:57', '2025-08-22 20:00:17', 1, NULL, 0, 1, 1, 100, NULL, NULL, NULL, '[]'),
(226, NULL, 'test việc mới nhé', 'ư3434534535', 19, NULL, NULL, 19, '2025-08-23', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-23 02:59:02', '2025-08-23 02:59:02', 1, NULL, 0, 1, 2, 75, NULL, NULL, NULL, '[]'),
(227, NULL, 'Công việc Cha_DVV', 'Công việc Cha_DVV', 3, NULL, NULL, 17, '2025-08-23', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-23 03:01:02', '2025-08-23 03:01:02', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(228, NULL, 'nhiệm vụ 2 cấp duyệt', 'nhiệm vụ 2 cấp duyệt', 5, NULL, NULL, 5, '2025-08-23', '2025-09-30', 'done', 'approved', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-23 08:43:04', '2025-08-23 08:44:13', 2, NULL, 0, 2, 1, 100, NULL, NULL, NULL, '[]'),
(229, NULL, 'nhiệm vụ con 24/08', '3424234234', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-23 19:17:16', '2025-08-23 19:17:16', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(230, NULL, 'nhiệm vụ con', '342342342', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-23 19:19:10', '2025-08-23 19:19:10', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(231, 228, 'nhiệm vụ con 2', '23424234234', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-23 19:19:46', '2025-08-23 19:19:46', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(237, 227, 'Công việc con 2_DVV', '234242424', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'doing', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'low', 0, '2025-08-23 20:07:19', '2025-08-23 20:07:19', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(238, 227, 'Công việc con 1_DVV', 'đasadsad', 3, NULL, NULL, 22, '2025-08-24', '2025-09-30', 'request_approval', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-08-23 20:07:54', '2025-08-23 20:07:54', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(239, NULL, 'xxxxx', '543454353535', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'doing', 'pending', NULL, 'contract', 32, 10, 293, 3, 'normal', 0, '2025-08-24 02:09:11', '2025-08-24 02:09:11', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(240, NULL, '34535345', '5435353535', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'request_approval', 'pending', NULL, 'contract', 32, 10, 293, 3, 'normal', 0, '2025-08-24 02:10:23', '2025-08-24 02:10:23', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(241, NULL, '3542342342', '4324324324', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'doing', 'pending', NULL, 'contract', 32, 10, 293, 3, 'normal', 0, '2025-08-24 02:14:06', '2025-08-24 02:14:06', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(242, NULL, 'xxxxxxx', '4242342342', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'request_approval', 'pending', NULL, 'contract', 32, 10, 293, 3, 'normal', 0, '2025-08-24 02:20:07', '2025-08-24 02:20:07', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(243, NULL, '4233243242', '23424234234', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'request_approval', 'pending', NULL, 'contract', 65, 1, 344, 3, 'normal', 0, '2025-08-24 02:33:59', '2025-08-24 02:41:22', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(244, NULL, 'xxxxxx', '32424234243', 5, NULL, NULL, 5, '2025-08-24', '2025-09-30', 'done', 'approved', NULL, 'contract', 65, 1, 344, 3, 'normal', 0, '2025-08-24 02:38:58', '2025-08-24 02:40:34', 1, NULL, 0, 1, 2, 100, NULL, NULL, NULL, '[]'),
(246, NULL, 'task con 2222', 'dsaddadada', 22, NULL, NULL, 22, '2025-08-24', '2025-09-30', 'request_approval', 'approved', NULL, 'contract', 66, 2, 364, 3, 'normal', 0, '2025-08-24 02:43:18', '2025-09-07 03:02:46', 0, NULL, 0, 0, 2, 100, NULL, NULL, NULL, '[]'),
(247, 201, '43424242', '42342424', 21, NULL, NULL, 17, '2025-09-01', '2025-10-31', '', 'pending', NULL, 'bidding', 35, 2, 285, 3, 'normal', 0, '2025-09-01 01:02:20', '2025-09-01 01:02:20', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(248, NULL, 'việc mới', '453454355', 24, NULL, NULL, 5, '2025-09-01', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 40, 1, 363, 3, 'normal', 0, '2025-09-01 01:39:12', '2025-10-26 02:16:36', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null}]'),
(249, NULL, 'việc mới 2', '422343243242', 17, NULL, NULL, 19, '2025-09-01', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 40, 1, 363, 3, 'normal', 0, '2025-09-01 01:39:40', '2025-09-01 01:39:40', 1, NULL, 0, 1, 4, 0, NULL, NULL, NULL, '[]'),
(250, 200, 'việc con mới', '23432432424', 19, NULL, NULL, 17, '2025-09-01', '2025-10-31', '', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-01 01:51:50', '2025-09-01 01:51:50', 1, NULL, 0, 1, 3, 55, NULL, NULL, NULL, '[]'),
(251, NULL, 'con của tesst mới', '45342424234', 5, NULL, NULL, 5, '2025-09-04', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-03 20:12:58', '2025-09-03 20:12:58', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(252, 199, 'xxxxxxx', 'sdadsadsadasd', 5, NULL, NULL, 5, '2025-09-04', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-03 20:13:39', '2025-09-03 20:13:39', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(255, NULL, 'bvnnnvnvn', '423424242424', 19, NULL, NULL, 19, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-06 20:04:30', '2025-09-06 20:04:30', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(256, NULL, '54353535', '54353535435', 17, NULL, NULL, 17, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'low', 0, '2025-09-06 20:07:05', '2025-09-06 20:07:05', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(257, NULL, 'xxxxxxxxxxxxxxxxxxxxxxxxx', '4234324242424', 5, NULL, NULL, 5, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'low', 0, '2025-09-06 20:09:20', '2025-09-06 20:09:20', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(258, 256, 'bbbbbbbbbbbbbbbbb', '324324242424', 5, NULL, NULL, 5, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-06 20:18:05', '2025-09-06 20:18:05', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(259, 258, 'mmmmmmmmmmmmmmmmmm', '23424242424', 23, NULL, NULL, 23, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-06 20:18:42', '2025-09-06 20:18:42', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(260, 259, 'bkkkkkkkkkkkkkk', '23423432424242424', 19, NULL, NULL, 19, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-06 20:25:31', '2025-09-06 20:25:31', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(261, NULL, 'ggggggggggggg', '34234342424', 16, NULL, NULL, 16, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'low', 0, '2025-09-06 20:27:57', '2025-09-06 20:27:57', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(262, NULL, 'rrrrrrrrrrrrrr', '3453454535', 14, NULL, NULL, 4, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'low', 0, '2025-09-06 20:28:39', '2025-09-06 20:28:39', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(263, NULL, '5354353535535', 'rewrwrwrwrw', 12, NULL, NULL, 3, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-06 20:29:05', '2025-09-06 20:29:05', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(264, NULL, '3424324242424', '4324242424', 12, NULL, NULL, 4, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'low', 0, '2025-09-06 20:29:30', '2025-09-06 20:29:30', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(265, NULL, '42343243242', '432432424', 23, NULL, NULL, 7, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-06 20:29:50', '2025-09-06 20:29:50', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(266, 262, '423434442', '4324324242', 22, NULL, NULL, 22, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 35, 1, 284, 3, 'normal', 0, '2025-09-06 21:12:14', '2025-09-06 21:12:14', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(267, 249, '4234344243', '4324324324324', 4, NULL, NULL, 4, '2025-09-07', '2025-10-31', 'done', 'approved', NULL, 'bidding', 40, 2, 364, 3, 'normal', 0, '2025-09-06 21:31:21', '2025-09-07 08:26:53', 0, NULL, 0, 0, 2, 100, NULL, NULL, NULL, '[]'),
(268, NULL, '2343242443', '432424244', 5, NULL, NULL, 4, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 39, 1, 349, 3, 'low', 0, '2025-09-06 21:35:26', '2025-09-06 21:35:26', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(269, 268, 'sub task 1', 'rewrerwrew', 1, NULL, NULL, 5, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 39, 1, 349, 3, 'normal', 0, '2025-09-06 21:35:52', '2025-09-06 21:35:52', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(270, 268, '342343424', '432432443', 5, NULL, NULL, 5, '2025-09-07', '2025-10-31', 'done', 'approved', NULL, 'bidding', 39, 2, 350, 3, 'normal', 0, '2025-09-06 22:08:44', '2025-09-07 02:34:54', 0, NULL, 0, 0, 2, 100, NULL, NULL, NULL, '[]'),
(271, 268, '345435435', '54354353554', 6, NULL, NULL, 6, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 39, 2, 350, 3, 'normal', 0, '2025-09-06 22:09:29', '2025-09-06 22:09:29', 1, NULL, 0, 1, 4, 0, NULL, NULL, NULL, '[]'),
(272, 210, 'task con', 'sdadasda', 4, NULL, NULL, 4, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 37, 1, 325, 3, 'normal', 0, '2025-09-07 03:00:44', '2025-09-07 03:00:44', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(273, 243, '54434535', '5435353', 22, NULL, NULL, 23, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 10, 1, 82, 3, 'normal', 0, '2025-09-07 03:29:40', '2025-09-07 03:29:40', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(274, 248, 'việc chắt mới', '3423424242', 19, NULL, NULL, 19, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 40, 1, 363, 3, 'low', 0, '2025-09-07 07:39:40', '2025-09-07 07:39:40', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(275, 248, '3424234', '3424224', 5, NULL, NULL, 5, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 40, 7, 369, 3, 'low', 0, '2025-09-07 09:24:03', '2025-09-07 09:24:03', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(276, 275, '4324324324', '4324324324', 5, NULL, NULL, 19, '2025-09-07', '2025-10-31', 'doing', 'pending', NULL, 'bidding', 40, 7, 369, 3, 'low', 0, '2025-09-07 09:24:36', '2025-09-07 09:24:36', 1, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(277, NULL, '1. Lấy kế hoạch SXKD', '1. Lấy kế hoạch SXKD', 5, 3, 8, 4, '2025-09-01', '2025-09-01', 'done', 'approved', '2025-11-12 15:41:08', 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-14 21:12:22', '2025-12-03 04:57:02', 1, '[3, 5]', 1, 1, 3, 100, NULL, NULL, NULL, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-11-30 03:36:34\", \"added_at\": \"2025-11-30 10:36:20\"}, {\"name\": \"Nguyễn Cảnh Hợp\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 7, \"acted_at\": \"2025-12-03 04:57:02\", \"added_at\": \"2025-12-03 00:00:59\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 04:57:02\", \"added_at\": \"2025-12-03 11:56:14\"}]'),
(278, NULL, '2. Lấy kế hoạch SCL', '2. Lấy kế hoạch SCL', 5, NULL, NULL, 4, '2025-09-02', '2025-09-02', 'request_approval', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-14 21:13:44', '2025-10-26 15:11:29', 1, '[4, 5, 6]', 1, 1, 3, 0, NULL, NULL, NULL, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-10-26 22:10:48\"}, {\"name\": \"Nguyễn Thị Ngọc Anh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 12, \"acted_at\": null, \"added_at\": \"2025-10-26 22:11:29\"}]'),
(279, 277, '1.1. Lấy kế hoạch SXKD lần 1', '1.1. Lấy kế hoạch SXKD lần 1', 5, NULL, NULL, 4, '2025-09-02', '2025-09-03', 'request_approval', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-14 21:15:48', '2025-10-26 15:09:07', 1, '[1]', 1, 1, 3, 75, NULL, NULL, NULL, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-10-26 22:08:29\"}, {\"name\": \"Nguyễn Cảnh Hợp\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 1, \"acted_at\": null, \"added_at\": \"2025-10-26 22:09:07\"}]'),
(280, 277, '1.2. Lấy kế hoạch SXKD lần 2', '1.2. Lấy kế hoạch SXKD lần 2', 5, NULL, NULL, 4, '2025-09-04', '2025-09-04', '', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-14 21:20:54', '2025-10-26 15:10:33', 1, '[4, 5]', 1, 1, 3, 0, NULL, NULL, NULL, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-10-26 22:09:26\"}, {\"name\": \"Tạ Quý Thọ\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 4, \"acted_at\": null, \"added_at\": \"2025-10-26 22:10:33\"}]'),
(281, 277, '1.3. Lấy kế hoạch SXKD lần 3', '1.3. Lấy kế hoạch SXKD lần 3', 5, 9, NULL, 4, '2025-09-04', '2025-09-04', 'request_approval', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-14 21:23:02', '2025-09-14 21:23:02', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(287, 238, 'Nhiệm vụ  cháu 1_DVV', 'Nhiệm vụ con 1', 3, NULL, NULL, 4, '2025-09-10', '2025-09-11', 'request_approval', 'pending', NULL, 'internal', 41, NULL, NULL, 3, 'high', 0, '2025-09-14 23:10:59', '2025-09-14 23:10:59', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(288, 287, 'Nhiệm vụ Chắt 1_DVV', 'Nhiệm vụ cháu 1_DVV', 3, NULL, NULL, 4, '2025-09-10', '2025-09-10', 'request_approval', 'pending', NULL, 'internal', 41, NULL, NULL, 3, 'high', 0, '2025-09-14 23:12:29', '2025-09-14 23:12:29', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(289, NULL, '1. Phân tích danh mục hàng hoá', '3432424', 3, NULL, NULL, 3, '2025-09-15', '2025-09-16', 'doing', 'pending', NULL, 'bidding', 41, 2, 378, 3, 'normal', 0, '2025-09-15 02:23:06', '2025-09-15 02:23:06', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(290, 289, '1.1. Phân tích danh mục hàng hoá 1', '1.1. Phân tích danh mục hàng hoá 1', 6, NULL, NULL, 5, '2025-09-15', '2025-09-16', 'request_approval', 'pending', NULL, 'bidding', 41, 2, 378, 3, 'high', 0, '2025-09-15 02:23:30', '2025-09-15 02:23:30', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(292, 287, 'Nhiệm vụ chắt 2_DVV', 'Nhiệm vụ chắt 2_DVV', 3, NULL, NULL, 4, '2025-09-11', '2025-09-11', 'request_approval', 'pending', NULL, 'internal', NULL, NULL, NULL, 3, 'high', 0, '2025-09-16 23:46:56', '2025-09-16 23:46:56', 1, NULL, 0, 1, 1, 0, NULL, NULL, NULL, '[]'),
(293, 238, 'Nhiệm vụ cháu 2_DVV', 'Nhiệm vụ cháu 2_DVV', 15, NULL, NULL, 4, '2025-09-12', '2025-09-13', 'done', 'approved', NULL, 'internal', NULL, NULL, NULL, 3, 'normal', 0, '2025-09-16 23:48:41', '2025-10-04 21:33:18', 0, NULL, 0, 0, 1, 100, NULL, NULL, NULL, '[]'),
(294, NULL, '2. Lập kế hoạch bóc tách Danh mục hàng hoá', '2. Lập kế hoạch bóc tách Danh mục hàng hoá', 6, NULL, NULL, 4, '2025-09-15', '2025-09-15', '', 'pending', NULL, 'bidding', 41, 2, 378, 3, 'high', 0, '2025-09-17 00:15:23', '2025-09-17 00:15:23', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(295, 290, '1.1.1. Phân tích danh mục hàng hoá 1.1', '1.1.1. Phân tích danh mục hàng hoá 1.1', 7, NULL, NULL, 4, '2025-09-15', '2025-09-16', '', 'pending', NULL, 'bidding', 41, 2, 378, 3, 'high', 0, '2025-09-17 00:37:42', '2025-09-17 00:37:42', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(296, 289, '1.2. Phân tích danh mục hàng hoá 2', '1.2. Phân tích danh mục hàng hoá 2', 6, NULL, NULL, 4, '2025-09-15', '2025-09-17', 'request_approval', 'pending', NULL, 'bidding', 41, 2, 378, 3, 'high', 0, '2025-09-17 00:41:55', '2025-09-17 00:41:55', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(298, 278, '2.1. Lấy kế hoạch SCL 1', '2.1. Lấy kế hoạch SCL 1', 3, 6, NULL, 4, '2025-09-03', '2025-09-03', 'done', 'approved', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-17 00:50:05', '2025-10-01 09:13:41', 0, NULL, 0, 0, 3, 100, NULL, NULL, NULL, '[]'),
(299, 298, '2.1.1. Lấy kế hoạch SCL 2.1', '2.1.1. Lấy kế hoạch SCL 2.1', 5, NULL, NULL, 4, '2025-09-03', '2025-09-03', 'done', 'approved', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-17 00:52:09', '2025-10-01 09:14:30', 1, '[3, 4]', 1, 1, 3, 100, NULL, NULL, NULL, '[]'),
(300, 281, '1.3.1. Lấy kế hoạch mục 1.3', '1.3.1. Lấy kế hoạch mục 1.3', 5, NULL, NULL, 4, '2025-09-05', '2025-09-05', '', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-17 00:57:04', '2025-10-04 21:34:52', 1, '[3]', 1, 1, 3, 0, NULL, NULL, NULL, '[]'),
(301, 281, '1.3.2. Lấy kế hoạch mục 1.3', '1.3.2. Lấy kế hoạch mục 1.3', 5, NULL, NULL, 4, '2025-09-06', '2025-09-06', '', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-17 00:58:10', '2025-09-17 00:58:10', 1, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(302, NULL, 'nhiệm vụ mới 28/09/2025', 'test nhiệm vụ 28/09/2025', 5, 8, 14, 3, '2025-09-28', '2025-10-31', 'done', 'approved', NULL, 'bidding', 41, 1, 377, 3, 'high', 0, '2025-09-27 20:51:52', '2025-10-26 15:11:40', 0, '[9]', 1, 0, 3, 100, NULL, NULL, NULL, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-10-26 22:11:40\"}]'),
(303, NULL, 'sub task 1', 'xxxxxx', 4, 5, NULL, 3, '2025-10-08', '2025-11-29', 'doing', 'pending', NULL, 'bidding', 41, 5, 381, 3, 'normal', 0, '2025-10-08 01:14:36', '2025-10-08 01:14:36', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(304, NULL, 'công việc con 2', '4354354353', 5, 6, NULL, 6, '2025-10-08', '2025-10-26', 'doing', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'normal', 0, '2025-10-08 01:17:59', '2025-10-26 15:12:54', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-10-26 22:12:26\"}, {\"name\": \"Phạm Xuân Tuân\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 6, \"acted_at\": null, \"added_at\": \"2025-10-26 22:12:54\"}]'),
(305, NULL, 'xxxxxxx', '32424242424', 5, 6, NULL, 4, '2025-10-08', '2025-11-28', 'doing', 'pending', NULL, 'contract', 66, 1, 363, 3, 'normal', 0, '2025-10-08 02:04:59', '2025-10-08 02:04:59', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(306, 305, 'yyyyyyyyyyyyyyyyy', '234324244242', 5, 7, NULL, 6, '2025-10-08', '2025-11-29', 'doing', 'pending', NULL, 'contract', 66, 1, 363, 3, 'normal', 0, '2025-10-08 02:05:36', '2025-10-08 02:05:36', 0, NULL, 0, 1, 2, 0, NULL, NULL, NULL, '[]'),
(307, 306, 'zzzzzzzzzzzzzz', '324243242424', 5, 7, NULL, 6, '2025-10-08', '2025-11-29', 'doing', 'pending', NULL, 'contract', 66, 1, 363, 3, 'normal', 0, '2025-10-08 02:06:19', '2025-10-08 02:06:19', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(308, NULL, 'nnnnnnnnnnnn', '435345535353', 7, 9, NULL, 3, '2025-10-08', '2025-11-30', 'doing', 'pending', NULL, 'contract', 66, 4, 366, 3, 'normal', 0, '2025-10-08 02:24:36', '2025-10-08 02:24:36', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(309, 308, 'vvvvvvvvvv', '432432424242', 7, 8, NULL, 3, '2025-10-08', '2025-11-29', 'doing', 'pending', NULL, 'contract', 66, 4, 366, 3, 'normal', 0, '2025-10-08 02:25:02', '2025-10-08 02:25:02', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(310, NULL, 'nhiệm vụ mới 03-12-2025', 'ok', 5, 7, NULL, 3, '2025-12-03', '2026-01-30', 'doing', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'normal', 0, '2025-12-03 06:45:29', '2025-12-03 06:45:29', 0, NULL, 0, 1, 3, 0, NULL, NULL, NULL, '[]'),
(311, NULL, 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', 3, 7, NULL, 3, '2025-12-03', '2026-01-31', 'doing', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'normal', 0, '2025-12-03 06:53:49', '2025-12-03 07:49:34', 0, NULL, 0, 1, 3, 0, 6, '[{\"doc_type\": \"internal\", \"drive_id\": \"1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo\", \"file_name\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo/edit\", \"public_url\": \"https://docs.google.com/spreadsheets/d/1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo/edit\", \"upload_batch\": 6, \"google_file_id\": \"1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo\"}]', NULL, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:28:40\"}]'),
(312, NULL, 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', 3, 7, NULL, 3, '2025-12-03', '2026-01-31', '', 'pending', NULL, 'bidding', 41, 1, 377, 3, 'normal', 0, '2025-12-03 06:56:31', '2025-12-03 09:23:46', 0, NULL, 0, 1, 3, 0, 3, '[{\"doc_type\": \"internal\", \"drive_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\", \"file_name\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"public_url\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"upload_batch\": 3, \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', NULL, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 5, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 14, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 15, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:10:03\"}, {\"name\": \"Hoàng Văn Dũng\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 8, \"acted_at\": null, \"added_at\": \"2025-12-03 16:09:30\"}, {\"name\": \"Vũ Thị Thuỷ\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 10, \"acted_at\": null, \"added_at\": \"2025-12-03 16:16:35\"}, {\"name\": \"Nguyễn Cảnh Hợp\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 7, \"acted_at\": null, \"added_at\": \"2025-12-03 16:23:46\"}]');

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
(4, 32, 1, 'approved', 1, '2025-07-08 14:25:09', 'ok', '2025-07-08 14:25:09'),
(5, 162, 1, 'approved', 1, '2025-08-05 06:25:12', 'ok', '2025-08-05 06:25:12'),
(6, 104, 1, 'rejected', 1, '2025-08-05 06:26:07', 'ko', '2025-08-05 06:26:07'),
(7, 164, 1, 'approved', 1, '2025-08-05 06:28:15', 'ok', '2025-08-05 06:28:15'),
(8, 164, 2, 'approved', 1, '2025-08-05 06:29:22', 'ok', '2025-08-05 06:29:22'),
(9, 1, 1, 'approved', 1, '2025-08-05 07:19:40', 'ok', '2025-08-05 07:19:40'),
(10, 134, 1, 'approved', 1, '2025-08-05 16:45:07', '{\"comment\":\"duyệt nhé :))\"}', '2025-08-05 16:45:07'),
(11, 134, 1, 'approved', 1, '2025-08-05 16:46:20', '{\"comment\":\"ok nhé\"}', '2025-08-05 16:46:20'),
(12, 201, 1, 'approved', 3, '2025-08-22 14:52:10', '{\"comment\":\"ok duyệt\"}', '2025-08-22 14:52:10'),
(13, 201, 1, 'approved', 3, '2025-08-22 14:52:11', '{\"comment\":\"ok duyệt\"}', '2025-08-22 14:52:11'),
(14, 202, 1, 'approved', 3, '2025-08-22 15:05:37', '{\"comment\":\"ok\"}', '2025-08-22 15:05:37'),
(15, 203, 1, 'approved', 3, '2025-08-22 17:14:07', '{\"comment\":\"ok nhé\"}', '2025-08-22 17:14:07'),
(16, 33, 1, 'approved', 3, '2025-08-23 02:20:30', '{\"comment\":\"ok nhé\"}', '2025-08-23 02:20:30'),
(17, 211, 1, 'approved', 3, '2025-08-23 02:22:05', '{\"comment\":\"ok rồi\"}', '2025-08-23 02:22:05'),
(18, 210, 1, 'approved', 3, '2025-08-23 02:23:23', '{\"comment\":\"\"}', '2025-08-23 02:23:23'),
(19, 212, 1, 'approved', 3, '2025-08-23 02:52:06', '{\"comment\":\"ok\"}', '2025-08-23 02:52:06'),
(20, 213, 1, 'approved', 3, '2025-08-23 02:53:54', '{\"comment\":\"ok\"}', '2025-08-23 02:53:54'),
(21, 214, 1, 'approved', 3, '2025-08-23 02:55:34', '{\"comment\":\"xxxx\"}', '2025-08-23 02:55:34'),
(22, 215, 1, 'approved', 3, '2025-08-23 02:56:39', '{\"comment\":\"534543535\"}', '2025-08-23 02:56:39'),
(23, 216, 1, 'approved', 3, '2025-08-23 02:58:52', '{\"comment\":\"32424324\"}', '2025-08-23 02:58:52'),
(24, 217, 1, 'approved', 3, '2025-08-23 03:00:17', '{\"comment\":\"42342342\"}', '2025-08-23 03:00:17'),
(25, 218, 1, 'approved', 3, '2025-08-23 03:02:07', '{\"comment\":\"\"}', '2025-08-23 03:02:07'),
(26, 219, 1, 'approved', 3, '2025-08-23 03:03:28', '{\"comment\":\"32424324\"}', '2025-08-23 03:03:28'),
(27, 220, 1, 'approved', 3, '2025-08-23 03:05:11', '{\"comment\":\"34424\"}', '2025-08-23 03:05:11'),
(28, 221, 1, 'approved', 3, '2025-08-23 03:06:27', '{\"comment\":\"424324\"}', '2025-08-23 03:06:27'),
(29, 222, 1, 'approved', 3, '2025-08-23 03:07:31', '{\"comment\":\"3224234\"}', '2025-08-23 03:07:31'),
(30, 223, 1, 'approved', 3, '2025-08-23 03:08:16', '{\"comment\":\"rưerewrw\"}', '2025-08-23 03:08:16'),
(31, 224, 1, 'approved', 3, '2025-08-23 03:09:38', '{\"comment\":\"eqwewqe\"}', '2025-08-23 03:09:38'),
(32, 204, 1, 'approved', 3, '2025-08-23 15:31:05', 'ok', '2025-08-23 15:31:05'),
(33, 205, 1, 'rejected', 3, '2025-08-23 15:35:50', 'chưa dc nhé, cần xem xét lại', '2025-08-23 15:35:50'),
(34, 228, 1, 'approved', 3, '2025-08-23 15:43:46', 'ok rồi', '2025-08-23 15:43:46'),
(35, 228, 2, 'approved', 3, '2025-08-23 15:44:13', 'bước 2 ok', '2025-08-23 15:44:13'),
(36, 206, 1, 'approved', 3, '2025-08-23 15:50:26', 'test duyệt', '2025-08-23 15:50:26'),
(37, 209, 1, 'approved', 1, '2025-08-23 15:51:17', 'Ái duyệt', '2025-08-23 15:51:17'),
(38, 244, 1, 'approved', 3, '2025-08-24 09:40:34', 'ok nhé', '2025-08-24 09:40:34'),
(39, 243, 1, 'approved', 3, '2025-08-24 09:41:22', 'ok duyệt', '2025-08-24 09:41:22'),
(40, 245, 1, 'approved', 3, '2025-08-24 09:42:35', 'ok duyệt', '2025-08-24 09:42:35'),
(41, 246, 1, 'approved', 3, '2025-08-24 09:43:48', 'duyệt nhé', '2025-08-24 09:43:48'),
(42, 207, 1, 'approved', 3, '2025-08-27 14:15:14', 'ok nhes', '2025-08-27 14:15:14'),
(43, 277, 1, 'approved', 3, '2025-10-01 16:11:07', NULL, '2025-10-01 16:11:07'),
(44, 299, 1, 'approved', 3, '2025-10-01 16:14:30', NULL, '2025-10-01 16:14:30');

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
  `approval_status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approver_ids` json DEFAULT NULL,
  `approval_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `approval_sent_by` int DEFAULT NULL,
  `approval_sent_at` datetime DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_comments`
--

INSERT INTO `task_comments` (`id`, `task_id`, `user_id`, `comment_id`, `content`, `created_at`, `updated_at`, `file_name`, `file_path`, `approval_status`, `approver_ids`, `approval_note`, `approval_sent_by`, `approval_sent_at`, `uploaded_by`) VALUES
(1, 277, 3, NULL, '', '2025-11-10 14:24:21', '2025-11-10 14:24:21', 'signed (3).pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/signed-3-1.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 277, 3, NULL, 'hihi', '2025-11-10 14:24:27', '2025-11-10 14:24:27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(3, 277, 3, NULL, '', '2025-11-10 14:25:35', '2025-11-10 14:25:35', 'maudonphuc_khao.doc', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao.doc', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 277, 3, NULL, 'hehe', '2025-11-10 14:26:00', '2025-11-10 14:26:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(5, 277, 3, NULL, '@Nguyễn Danh Vương Bình', '2025-11-10 14:33:27', '2025-11-10 14:33:27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(6, 277, 3, NULL, 'xxxxxx', '2025-11-10 14:34:02', '2025-11-10 14:34:03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(7, 277, 3, NULL, '', '2025-11-10 14:35:44', '2025-11-10 14:35:44', 'signed (7).pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/signed-7-1.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 277, 3, NULL, '', '2025-11-10 15:44:38', '2025-11-10 15:44:38', 'photo_2025-10-17_10-08-52.jpg', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/photo_2025-10-17_10-08-52-3.jpg', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 277, 3, NULL, '', '2025-11-10 16:00:48', '2025-11-10 16:00:48', 'to_trinh_09_11_2025.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-1.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 277, 3, NULL, '', '2025-11-11 15:50:54', '2025-11-11 15:50:54', 'to_trinh_09_11_2025.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-3.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 277, 3, NULL, '', '2025-11-11 15:54:30', '2025-11-11 15:54:30', 'signed (8).pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/signed-8-2.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 277, 3, NULL, '', '2025-11-11 15:54:43', '2025-11-11 15:54:43', 'to_trinh_09_11_2025.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-4.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(13, 277, 3, NULL, '', '2025-11-11 17:13:55', '2025-11-11 17:13:55', 'CHUYÊN  ĐỀ 1.docx', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/CHUYEN-DE-1.docx', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 277, 3, NULL, '', '2025-11-11 17:15:50', '2025-11-11 17:15:50', 'maudonphuc_khao.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao-1.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 277, 3, NULL, 'hehe', '2025-11-11 17:21:12', '2025-11-11 17:21:12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(16, 277, 3, NULL, 'https://vnexpress.net/', '2025-11-12 07:42:52', '2025-11-12 07:42:52', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(17, 277, 3, NULL, 'ok, chào', '2025-11-12 07:48:58', '2025-11-12 07:48:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(18, 277, 3, NULL, 'chào', '2025-11-12 07:49:07', '2025-11-12 07:49:07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(19, 277, 3, NULL, 'ok nhé', '2025-11-12 07:49:23', '2025-11-12 07:49:23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(20, 277, 3, NULL, 'https://dantri.com.vn/', '2025-11-12 07:56:01', '2025-11-12 07:56:01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(21, 277, 3, NULL, '@Đinh Văn Vịnh', '2025-11-12 09:16:32', '2025-11-12 09:16:32', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(22, 277, 3, NULL, '@Nguyễn Cảnh Hợp', '2025-11-12 09:16:40', '2025-11-12 09:16:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(23, 277, 3, NULL, '@Tạ Quý Thọ', '2025-11-12 09:16:45', '2025-11-12 09:16:45', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(24, 277, 3, NULL, '@Nguyễn Cảnh Hợp', '2025-11-12 09:17:39', '2025-11-12 09:17:39', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(25, 277, 3, NULL, '@Phạm Xuân Tuân', '2025-11-12 09:17:47', '2025-11-12 09:17:47', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(26, 277, 3, NULL, '', '2025-11-13 03:46:57', '2025-11-13 03:46:57', 'to_trinh_09_11_2025.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-5.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(27, 277, 4, NULL, '', '2025-11-13 04:06:17', '2025-11-13 04:06:17', 'to_trinh_09_11_2025.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-6.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(28, 277, 3, NULL, '', '2025-11-13 04:15:22', '2025-11-13 04:15:22', 'to_trinh_09_11_2025.pdf', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-7.pdf', NULL, NULL, NULL, NULL, NULL, NULL),
(29, 277, 3, NULL, '', '2025-11-14 02:59:47', '2025-11-14 02:59:47', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(30, 277, 3, NULL, '', '2025-11-24 03:11:32', '2025-11-24 03:11:32', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763953887.xlsx', 'https://netorg15468115.sharepoint.com/_layouts/15/Doc.aspx?sourcedoc=%7BB795E5E0-5B5A-474A-BEC3-95D508C27C34%7D&file=20251008_PLTTr%20HCNS_DanhmuchanghoadichvuT01_1763953887.xlsx&action=default&mobileredirect=true', NULL, NULL, NULL, NULL, NULL, NULL),
(31, 277, 3, NULL, '', '2025-11-24 06:51:02', '2025-11-24 06:51:02', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1763967057.docx', 'https://netorg15468115.sharepoint.com/_layouts/15/Doc.aspx?sourcedoc=%7B886ABA2B-24E1-4C8A-84C4-4785DC74DB53%7D&file=20251008_TTrHCNS_GiahanphanmemMicrosoft%20365%20T01_1763967057.docx&action=default&mobileredirect=true', NULL, NULL, NULL, NULL, NULL, NULL),
(32, 277, 3, NULL, '', '2025-11-24 08:00:22', '2025-11-24 08:00:22', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763971215.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQCYosJtiW4KR7ozsCDf8LD9AQ0MQ7WjevrsJ0LU8UTmji0', NULL, NULL, NULL, NULL, NULL, NULL),
(33, 277, 3, NULL, '', '2025-11-24 08:20:01', '2025-11-24 08:20:01', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763972393.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQBbehLlA82bRb06eygzg_qjAUIBY-yrHk8IPs96KlvOE2A', NULL, NULL, NULL, NULL, NULL, NULL),
(34, 277, 3, NULL, '', '2025-11-25 03:01:43', '2025-11-25 03:01:43', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764039697.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQC7tgJxfxmaR4ghnOlHnazkAeSeDjqG3LTAUL7sQr5hxqk', NULL, NULL, NULL, NULL, NULL, NULL),
(35, 277, 3, NULL, '', '2025-11-25 03:07:25', '2025-11-25 03:07:25', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764040038.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQCMs_o8EpXTRpCGdnELQSnOATvRuoK4Yc4b2KRMjy610tM', NULL, NULL, NULL, NULL, NULL, NULL),
(36, 277, 3, NULL, '', '2025-11-25 03:23:00', '2025-11-25 03:23:00', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764040973.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQAxpmYyYFfaSYYKCVGSpQKwAerA7jMeBhgVmEc90b0ogCg', NULL, NULL, NULL, NULL, NULL, NULL),
(37, 277, 3, NULL, '', '2025-11-25 07:00:44', '2025-11-25 07:00:44', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(38, 277, 3, NULL, '', '2025-11-25 07:01:40', '2025-11-25 07:01:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(39, 277, 3, NULL, '', '2025-11-25 07:06:39', '2025-11-25 07:06:39', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764054392.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQBjlNyC4KuyQYyKukQdRcphAVnCMWu8oobeqd2s1ueFX9w', NULL, NULL, NULL, NULL, NULL, NULL),
(40, 277, 3, NULL, '', '2025-11-25 07:09:09', '2025-11-25 07:09:09', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(41, 277, 3, NULL, '', '2025-11-25 07:12:05', '2025-11-25 07:12:05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(42, 277, 3, NULL, '', '2025-11-25 07:20:50', '2025-11-25 07:20:50', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(43, 277, 3, NULL, '', '2025-11-25 07:33:22', '2025-11-25 07:33:22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(44, 277, 3, NULL, '', '2025-11-25 07:35:40', '2025-11-25 07:35:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(45, 277, 3, NULL, '', '2025-11-25 07:38:18', '2025-11-25 07:38:18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(46, 277, 3, NULL, '', '2025-11-25 07:42:40', '2025-11-25 07:42:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(47, 277, 3, NULL, '', '2025-11-25 07:47:58', '2025-11-25 07:47:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(48, 277, 3, NULL, '', '2025-11-25 07:49:12', '2025-11-25 07:49:12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(49, 277, 3, NULL, '', '2025-11-25 07:56:36', '2025-11-25 07:56:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(50, 277, 3, NULL, '', '2025-11-25 07:57:32', '2025-11-25 07:57:32', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(51, 277, 3, NULL, '', '2025-11-25 08:02:22', '2025-11-25 08:02:22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(52, 277, 3, NULL, '', '2025-11-25 08:03:08', '2025-11-25 08:03:08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(53, 277, 3, NULL, '', '2025-11-25 08:05:47', '2025-11-25 08:05:47', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(54, 277, 3, NULL, '', '2025-11-25 08:06:57', '2025-11-25 08:06:57', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(55, 277, 3, NULL, '', '2025-11-25 08:08:46', '2025-11-25 08:08:46', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(56, 277, 3, NULL, '', '2025-11-25 08:14:23', '2025-11-25 08:14:23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(57, 277, 3, NULL, '', '2025-11-25 08:14:46', '2025-11-25 08:14:46', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(58, 277, 3, NULL, '', '2025-11-25 08:27:21', '2025-11-25 08:27:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(59, 277, 3, NULL, '', '2025-11-25 08:27:45', '2025-11-25 08:27:45', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(60, 277, 3, NULL, '', '2025-11-25 08:31:04', '2025-11-25 08:31:04', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(61, 277, 3, NULL, '', '2025-11-25 08:34:42', '2025-11-25 08:34:42', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(62, 277, 3, NULL, '', '2025-11-25 08:35:56', '2025-11-25 08:35:56', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(63, 277, 3, NULL, '', '2025-11-25 08:36:20', '2025-11-25 08:36:20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(64, 277, 3, NULL, '', '2025-11-25 08:41:14', '2025-11-25 08:41:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(65, 277, 3, NULL, '', '2025-11-25 08:41:44', '2025-11-25 08:41:44', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(66, 277, 3, NULL, '', '2025-11-25 08:42:14', '2025-11-25 08:42:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(67, 277, 3, NULL, '', '2025-11-25 08:44:27', '2025-11-25 08:44:27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(68, 277, 3, NULL, '', '2025-11-25 08:49:44', '2025-11-25 08:49:44', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(69, 277, 3, NULL, '', '2025-11-26 04:33:10', '2025-11-26 04:33:10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(70, 277, 3, NULL, 'alo', '2025-11-26 06:07:13', '2025-11-26 06:07:13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(71, 277, 3, NULL, 'test comment', '2025-11-26 06:07:24', '2025-11-26 06:07:24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(72, 277, 3, NULL, '@Nguyễn Danh Vương Bình', '2025-11-26 08:08:39', '2025-11-26 08:08:39', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(73, 277, 3, NULL, '', '2025-11-26 08:34:27', '2025-11-26 08:34:27', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(74, 277, 3, NULL, '', '2025-11-28 01:05:19', '2025-11-28 01:05:19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(75, 277, 3, NULL, '', '2025-11-28 01:05:32', '2025-11-28 01:05:32', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(76, 277, 3, NULL, '', '2025-11-28 01:11:52', '2025-11-28 01:11:52', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(77, 277, 3, NULL, '', '2025-11-28 01:30:14', '2025-11-28 01:30:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(78, 277, 3, NULL, '', '2025-11-28 01:31:19', '2025-11-28 01:31:19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(79, 277, 3, NULL, '', '2025-11-28 01:39:45', '2025-11-28 01:39:45', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(80, 277, 3, NULL, '', '2025-11-28 01:46:29', '2025-11-28 01:46:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(81, 277, 3, NULL, '', '2025-11-28 01:48:33', '2025-11-28 01:48:33', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(82, 277, 3, NULL, '', '2025-11-28 01:50:01', '2025-11-28 01:50:01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(83, 277, 3, NULL, '', '2025-11-28 01:52:46', '2025-11-28 01:52:46', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(84, 277, 3, NULL, '', '2025-11-28 01:53:03', '2025-11-28 01:53:03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(85, 277, 3, NULL, '', '2025-11-28 01:53:43', '2025-11-28 01:53:43', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(86, 277, 3, NULL, '', '2025-11-28 01:55:29', '2025-11-28 01:55:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(87, 277, 3, NULL, '', '2025-11-28 02:01:45', '2025-11-28 02:01:45', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(88, 277, 3, NULL, '', '2025-11-28 02:01:49', '2025-11-28 02:01:49', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(89, 277, 3, NULL, '', '2025-11-28 02:01:55', '2025-11-28 02:01:55', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(90, 277, 3, NULL, '', '2025-11-28 02:04:03', '2025-11-28 02:04:03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(91, 277, 3, NULL, '', '2025-11-28 02:09:23', '2025-11-28 02:09:23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(92, 277, 3, NULL, '', '2025-11-28 02:29:11', '2025-11-28 02:29:11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(93, 277, 3, NULL, '', '2025-11-28 02:41:15', '2025-11-28 02:41:15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(94, 277, 3, NULL, '', '2025-11-28 02:42:33', '2025-11-28 02:42:33', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(95, 277, 3, NULL, '', '2025-11-28 02:43:24', '2025-11-28 02:43:24', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(96, 277, 3, NULL, '', '2025-11-28 02:47:32', '2025-11-28 02:47:32', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(97, 277, 3, NULL, '', '2025-11-28 02:48:02', '2025-11-28 02:48:02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(98, 277, 3, NULL, '', '2025-11-28 02:51:34', '2025-11-28 02:51:34', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(99, 277, 3, NULL, '', '2025-11-28 02:55:40', '2025-11-28 02:55:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(100, 277, 3, NULL, '', '2025-11-28 03:08:55', '2025-11-28 03:08:55', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(101, 277, 3, NULL, '', '2025-11-28 03:09:46', '2025-11-28 03:09:46', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(102, 277, 3, NULL, '', '2025-11-28 03:10:14', '2025-11-28 03:10:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(103, 277, 3, NULL, '', '2025-11-28 03:10:35', '2025-11-28 03:10:35', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(104, 277, 3, NULL, '', '2025-11-28 03:48:33', '2025-11-28 03:48:33', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(105, 277, 3, NULL, '', '2025-11-28 03:48:59', '2025-11-28 03:48:59', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(106, 277, 3, NULL, '', '2025-11-28 03:49:36', '2025-11-28 03:49:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(107, 277, 3, NULL, '', '2025-11-28 03:53:47', '2025-11-28 03:53:47', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(108, 277, 3, NULL, '', '2025-11-28 04:01:07', '2025-11-28 04:01:07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(109, 277, 3, NULL, '', '2025-11-28 04:01:20', '2025-11-28 04:01:20', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(110, 277, 3, NULL, '', '2025-11-28 04:01:33', '2025-11-28 04:01:33', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(111, 277, 3, NULL, '', '2025-11-28 04:43:13', '2025-11-28 04:43:13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(112, 277, 3, NULL, '', '2025-11-28 04:48:33', '2025-11-28 04:48:33', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(113, 277, 3, NULL, '', '2025-11-28 06:27:42', '2025-11-28 06:27:42', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(114, 277, 3, NULL, '', '2025-11-28 06:48:58', '2025-11-28 06:48:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(115, 277, 3, NULL, '', '2025-11-28 06:49:49', '2025-11-28 06:49:49', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(116, 277, 3, NULL, '', '2025-11-28 07:01:50', '2025-11-28 07:01:50', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(117, 277, 3, NULL, '', '2025-11-28 07:08:07', '2025-11-28 07:08:07', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(118, 277, 3, NULL, '', '2025-11-28 07:09:35', '2025-11-28 07:09:35', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(119, 277, 3, NULL, '', '2025-11-28 07:52:55', '2025-11-28 07:52:55', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(120, 277, 3, NULL, '@Nguyễn Danh Vương Bình', '2025-11-28 08:21:01', '2025-11-28 08:21:01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(121, 277, 3, NULL, '@', '2025-11-28 08:45:21', '2025-11-28 08:45:21', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(122, 277, 3, NULL, '@Nguyễn Văn Chiểu', '2025-11-28 09:01:13', '2025-11-28 09:01:13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(123, 277, 3, NULL, '@Trần Thị Hiền', '2025-11-28 09:10:11', '2025-11-28 09:10:11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(124, 277, 3, NULL, '', '2025-11-28 09:10:25', '2025-11-28 09:10:25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(125, 277, 3, NULL, '', '2025-11-28 09:13:12', '2025-11-28 09:13:12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(126, 277, 3, NULL, '', '2025-11-28 09:18:38', '2025-11-28 09:18:38', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(127, 277, 3, NULL, '', '2025-11-28 09:23:34', '2025-11-28 09:23:34', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(128, 277, 3, NULL, '', '2025-11-29 03:26:13', '2025-11-29 03:26:13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(129, 277, 3, NULL, '', '2025-11-29 03:26:57', '2025-11-29 03:26:57', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(130, 277, 3, NULL, '', '2025-11-29 03:34:35', '2025-11-29 03:34:35', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(131, 277, 3, NULL, '', '2025-11-29 03:35:06', '2025-11-29 03:35:06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(132, 277, 3, NULL, '', '2025-11-29 03:36:08', '2025-11-29 03:36:08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(133, 277, 3, NULL, '', '2025-11-29 03:36:57', '2025-11-29 03:36:57', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(134, 277, 3, NULL, '', '2025-11-29 03:38:02', '2025-11-29 03:38:02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(135, 277, 3, NULL, '', '2025-11-29 03:38:26', '2025-11-29 03:38:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(136, 277, 3, NULL, '', '2025-11-29 03:38:46', '2025-11-29 03:38:46', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(137, 277, 3, NULL, '', '2025-11-29 03:39:35', '2025-11-29 03:39:35', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(138, 277, 3, NULL, '', '2025-11-29 04:10:57', '2025-11-29 04:10:57', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(139, 277, 3, NULL, '@Đinh Văn Vịnh', '2025-11-29 04:11:36', '2025-11-29 04:11:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(140, 277, 3, NULL, '', '2025-11-29 04:41:13', '2025-11-29 04:41:13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(141, 277, 3, NULL, '', '2025-11-29 07:02:06', '2025-11-29 07:02:06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(142, 277, 3, NULL, '', '2025-11-29 07:05:14', '2025-11-29 07:05:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(143, 277, 3, NULL, '', '2025-11-29 07:13:08', '2025-11-29 07:13:08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(144, 277, 3, NULL, '', '2025-11-29 07:14:05', '2025-11-29 07:14:05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(145, 277, 3, NULL, '', '2025-11-29 07:18:04', '2025-11-29 07:18:04', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(146, 277, 3, NULL, '', '2025-11-29 07:20:36', '2025-11-29 07:20:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(147, 277, 3, NULL, '', '2025-11-29 07:21:48', '2025-11-29 07:21:48', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(148, 277, 3, NULL, '', '2025-11-29 07:28:37', '2025-11-29 07:28:37', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(149, 277, 3, NULL, '', '2025-11-29 07:38:55', '2025-11-29 07:38:55', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(150, 277, 3, NULL, '@Nguyễn Thị Hạnh', '2025-11-29 07:56:55', '2025-11-29 07:56:55', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(151, 277, 3, NULL, '@Đinh Văn Vịnh', '2025-11-29 08:18:12', '2025-11-29 08:18:12', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(152, 277, 3, NULL, '', '2025-11-29 09:15:56', '2025-11-29 09:15:56', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(153, 277, 3, NULL, '@Đinh Văn Vịnh', '2025-11-29 09:16:25', '2025-11-29 09:16:25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(154, 277, 3, NULL, '', '2025-11-29 17:00:28', '2025-11-29 17:00:28', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(155, 277, 3, NULL, '', '2025-11-29 17:04:43', '2025-11-29 17:04:43', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(156, 277, 3, NULL, '', '2025-11-29 17:11:13', '2025-11-29 17:11:13', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(157, 277, 3, NULL, '', '2025-11-29 17:21:05', '2025-11-29 17:21:05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(158, 277, 3, NULL, '', '2025-11-29 17:24:29', '2025-11-29 17:24:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(159, 277, 3, NULL, '', '2025-11-29 17:31:14', '2025-11-29 17:31:14', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(160, 277, 3, NULL, '', '2025-11-29 17:39:26', '2025-11-29 17:39:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(161, 277, 3, NULL, '', '2025-11-29 17:51:37', '2025-11-29 17:51:37', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(162, 277, 3, NULL, '', '2025-11-29 17:53:44', '2025-11-29 17:53:44', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(163, 277, 3, NULL, '', '2025-11-30 02:32:18', '2025-11-30 02:32:18', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(164, 277, 3, NULL, '', '2025-11-30 02:45:17', '2025-11-30 02:45:17', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(165, 277, 3, NULL, '', '2025-11-30 02:48:02', '2025-11-30 02:48:02', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(166, 277, 3, NULL, '', '2025-11-30 02:51:11', '2025-11-30 02:51:11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(167, 277, 3, NULL, '', '2025-11-30 02:57:15', '2025-11-30 02:57:15', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(168, 277, 3, NULL, '', '2025-11-30 03:34:26', '2025-11-30 03:34:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(169, 277, 3, NULL, '', '2025-11-30 04:40:58', '2025-11-30 04:40:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(170, 277, 3, NULL, '', '2025-11-30 04:41:46', '2025-11-30 04:41:46', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(171, 277, 3, NULL, '', '2025-11-30 12:20:53', '2025-11-30 12:20:53', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(172, 277, 3, NULL, '', '2025-12-01 01:29:19', '2025-12-01 01:29:19', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(173, 277, 3, NULL, '', '2025-12-01 01:30:22', '2025-12-01 01:30:22', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(174, 279, 3, NULL, '', '2025-12-01 04:30:01', '2025-12-01 04:30:01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(175, 278, 3, NULL, '', '2025-12-01 04:33:06', '2025-12-01 04:33:06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(176, 277, 5, NULL, '', '2025-12-01 06:32:58', '2025-12-01 06:32:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(177, 277, 5, NULL, '', '2025-12-01 06:33:40', '2025-12-01 06:33:40', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(178, 277, 3, NULL, '', '2025-12-01 08:45:48', '2025-12-01 08:45:48', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(179, 277, 3, NULL, '', '2025-12-02 01:11:41', '2025-12-02 01:11:41', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(180, 277, 4, NULL, '', '2025-12-02 02:10:08', '2025-12-02 02:10:08', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(181, 277, 5, NULL, '', '2025-12-02 02:47:25', '2025-12-02 02:47:25', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(182, 277, 3, NULL, '', '2025-12-02 03:27:00', '2025-12-02 03:27:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(183, 277, 5, NULL, '', '2025-12-02 03:43:33', '2025-12-02 03:43:33', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(184, 277, 1, NULL, '', '2025-12-02 03:52:23', '2025-12-02 03:52:23', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(185, 277, 1, NULL, '', '2025-12-02 03:53:36', '2025-12-02 03:53:36', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(186, 277, 3, NULL, '', '2025-12-02 04:33:11', '2025-12-02 04:33:11', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(187, 277, 3, NULL, '', '2025-12-02 04:39:51', '2025-12-02 04:39:51', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(188, 277, 3, NULL, '', '2025-12-02 04:52:05', '2025-12-02 04:52:05', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(189, 277, 3, NULL, '', '2025-12-02 06:06:01', '2025-12-02 06:06:01', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(190, 277, 1, NULL, '', '2025-12-02 07:08:06', '2025-12-02 07:08:06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(191, 277, 1, NULL, '', '2025-12-02 07:11:03', '2025-12-02 07:11:03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(192, 277, 1, NULL, '', '2025-12-02 07:23:58', '2025-12-02 07:23:58', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(193, 277, 1, NULL, '', '2025-12-02 16:55:06', '2025-12-02 16:55:06', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(194, 277, 1, NULL, '', '2025-12-02 16:59:45', '2025-12-02 16:59:45', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(195, 277, 1, NULL, '', '2025-12-02 17:00:29', '2025-12-02 17:00:29', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(196, 312, 3, NULL, '', '2025-12-03 07:21:00', '2025-12-03 07:21:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(197, 312, 3, NULL, '', '2025-12-03 07:24:55', '2025-12-03 07:24:55', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(198, 311, 3, NULL, '@Đinh Văn Vịnh', '2025-12-03 07:28:45', '2025-12-03 07:28:45', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(199, 311, 3, NULL, '', '2025-12-03 07:31:51', '2025-12-03 07:31:51', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(200, 311, 3, NULL, '', '2025-12-03 07:38:10', '2025-12-03 07:38:10', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(201, 311, 3, NULL, '', '2025-12-03 07:47:30', '2025-12-03 07:47:30', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(202, 311, 3, NULL, '', '2025-12-03 07:48:39', '2025-12-03 07:48:39', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(203, 311, 3, NULL, '', '2025-12-03 07:49:26', '2025-12-03 07:49:26', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(204, 312, 3, NULL, '', '2025-12-03 07:51:51', '2025-12-03 07:51:51', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

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
(16, 51, 1, '2025-07-29 00:00:00', '2025-07-19 00:00:00', 'Gia hạn thời gian', '2025-07-20 05:46:44', '2025-07-20 05:46:44'),
(17, 38, 1, '2025-07-29 00:00:00', '2025-07-31 00:00:00', NULL, '2025-07-31 01:35:47', '2025-07-31 01:35:47'),
(18, 51, 1, '2025-07-19 00:00:00', '2025-08-28 00:00:00', NULL, '2025-07-31 01:36:25', '2025-07-31 01:36:25'),
(19, 26, 1, '2025-06-15 00:00:00', '2025-06-16 00:00:00', NULL, '2025-07-31 01:38:24', '2025-07-31 01:38:24'),
(20, 289, 3, '2025-10-31 00:00:00', '2025-09-16 00:00:00', 'Gia hạn thời gian', '2025-09-17 00:17:19', '2025-09-17 00:17:19'),
(21, 290, 3, '2025-10-31 00:00:00', '2025-09-16 00:00:00', 'Gia hạn thời gian', '2025-09-17 00:35:47', '2025-09-17 00:35:47');

-- --------------------------------------------------------

--
-- Table structure for table `task_files`
--

CREATE TABLE `task_files` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `document_id` int DEFAULT NULL,
  `comment_id` int DEFAULT NULL,
  `file_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `uploaded_by` int DEFAULT NULL,
  `link_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT NULL,
  `is_link` tinyint(1) DEFAULT '0',
  `status` enum('pending','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `approved_by` bigint UNSIGNED DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `review_note` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approvals_json` json DEFAULT NULL,
  `is_pinned` tinyint(1) NOT NULL DEFAULT '0',
  `pinned_rank` tinyint DEFAULT NULL,
  `pinned_by` int DEFAULT NULL,
  `pinned_at` datetime DEFAULT NULL,
  `file_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'wp_media',
  `file_size` bigint UNSIGNED DEFAULT '0',
  `mime_type` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `file_ext` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `wp_media_id` bigint UNSIGNED DEFAULT NULL,
  `source` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'wordpress',
  `department_id` int DEFAULT NULL,
  `visibility` enum('private','public','department','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'private',
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `upload_batch` int DEFAULT NULL,
  `google_file_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_files`
--

INSERT INTO `task_files` (`id`, `task_id`, `document_id`, `comment_id`, `file_name`, `title`, `file_path`, `uploaded_by`, `link_url`, `created_at`, `updated_at`, `is_link`, `status`, `approved_by`, `approved_at`, `review_note`, `approvals_json`, `is_pinned`, `pinned_rank`, `pinned_by`, `pinned_at`, `file_type`, `file_size`, `mime_type`, `file_ext`, `wp_media_id`, `source`, `department_id`, `visibility`, `tags`, `upload_batch`, `google_file_id`) VALUES
(24, 277, NULL, NULL, '2022104_TTr-HCNS_Dexuatgiahanphanmem1office.pdf', '2022104_TTr-HCNS_Dexuatgiahanphanmem1office.pdf', NULL, 1, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/2022104_TTr-HCNS_Dexuatgiahanphanmem1office-3.pdf', '2025-11-09 04:25:57', '2025-12-01 09:13:53', 1, 'approved', 3, '2025-12-01 09:13:53', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:13:52', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(25, 277, NULL, NULL, '2022104_TTr-HCNS_Dexuatgiahanphanmem1office.pdf', '2022104_TTr-HCNS_Dexuatgiahanphanmem1office.pdf', NULL, 1, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/2022104_TTr-HCNS_Dexuatgiahanphanmem1office-3.pdf', '2025-11-09 04:34:12', '2025-12-01 09:34:15', 1, 'approved', 3, '2025-12-01 09:34:15', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:34:14', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(26, 277, NULL, NULL, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', NULL, 1, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao123-7.pdf', '2025-11-09 04:38:49', '2025-12-01 09:40:41', 1, 'approved', 3, '2025-12-01 09:40:41', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:40:40', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(27, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025.pdf', '2025-11-09 08:52:42', '2025-12-01 09:35:40', 1, 'approved', 3, '2025-12-01 09:35:40', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:35:39', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(28, 277, NULL, NULL, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao123-7.pdf', '2025-11-09 15:14:53', '2025-12-01 09:47:22', 1, 'approved', 3, '2025-12-01 09:47:21', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:47:20', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(29, 277, NULL, NULL, 'signed (3).pdf', 'signed (3).pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/signed-3-1.pdf', '2025-11-10 14:24:36', '2025-12-01 09:49:39', 1, 'approved', 3, '2025-12-01 09:49:39', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:49:35', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(30, 277, NULL, NULL, 'maudonphuc_khao.doc', 'maudonphuc_khao.doc', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao.doc', '2025-11-10 14:25:38', '2025-12-01 09:53:57', 1, 'approved', 3, '2025-12-01 09:53:57', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:53:54', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(31, 277, NULL, NULL, 'signed (7).pdf', 'signed (7).pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/signed-7-1.pdf', '2025-11-10 14:36:02', '2025-12-01 09:55:09', 1, 'approved', 3, '2025-12-01 09:55:09', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 09:55:07', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(32, 277, NULL, NULL, 'signed (7).pdf', 'signed (7).pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/signed-7-1.pdf', '2025-11-10 14:36:03', '2025-12-01 10:04:47', 1, 'approved', 3, '2025-12-01 10:04:47', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:04:44', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(33, 277, NULL, NULL, 'maudonphuc_khao.doc', 'maudonphuc_khao.doc', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao.doc', '2025-11-10 14:41:26', '2025-12-01 10:13:23', 1, 'approved', 3, '2025-12-01 10:13:23', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:13:22', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(34, 277, NULL, NULL, 'maudonphuc_khao.doc', 'maudonphuc_khao.doc', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao.doc', '2025-11-10 16:12:36', '2025-12-01 10:15:22', 1, 'approved', 3, '2025-12-01 10:15:22', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:15:18', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(35, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-3.pdf', '2025-11-11 15:50:54', '2025-12-01 10:21:33', 1, 'approved', 3, '2025-12-01 10:21:33', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:21:32', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(36, 277, NULL, NULL, 'signed (8).pdf', 'signed (8).pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/signed-8-2.pdf', '2025-11-11 15:54:30', '2025-12-01 10:24:02', 1, 'approved', 3, '2025-12-01 10:24:02', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:23:59', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(37, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-4.pdf', '2025-11-11 15:54:43', '2025-11-12 00:04:47', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(38, 277, NULL, NULL, 'CHUYÊN  ĐỀ 1.docx', 'CHUYÊN  ĐỀ 1.docx', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/CHUYEN-DE-1.docx', '2025-11-11 17:13:55', '2025-12-01 10:42:14', 1, 'approved', 3, '2025-12-01 10:42:14', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:42:11', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(39, 277, NULL, NULL, 'maudonphuc_khao.pdf', 'maudonphuc_khao.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao-1.pdf', '2025-11-11 17:15:50', '2025-12-01 10:48:59', 1, 'approved', 3, '2025-12-01 10:48:59', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 10:48:58', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(40, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-5.pdf', '2025-11-13 03:46:57', '2025-12-01 11:01:51', 1, 'approved', 3, '2025-12-01 11:01:51', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 11:01:48', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(41, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-5.pdf', '2025-11-13 03:47:02', '2025-11-25 13:27:21', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(42, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 4, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-6.pdf', '2025-11-13 04:06:17', '2025-11-25 14:47:44', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(43, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 4, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-6.pdf', '2025-11-13 04:06:30', '2025-11-25 13:27:23', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(44, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-7.pdf', '2025-11-13 04:15:22', '2025-11-14 16:19:16', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(45, 277, NULL, NULL, 'to_trinh_09_11_2025.pdf', 'to_trinh_09_11_2025.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/to_trinh_09_11_2025-7.pdf', '2025-11-13 04:15:26', '2025-11-25 13:27:22', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(46, 277, NULL, NULL, 'maudonphuc_khao.pdf', 'maudonphuc_khao.pdf', NULL, 4, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao-1.pdf', '2025-11-13 16:58:15', '2025-12-01 11:22:21', 1, 'approved', 3, '2025-12-01 11:22:21', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 11:22:20', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(47, 277, NULL, NULL, 'maudonphuc_khao.pdf', 'maudonphuc_khao.pdf', NULL, 4, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao-1.pdf', '2025-11-13 17:04:40', '2025-12-01 11:29:19', 1, 'approved', 1, '2025-12-01 11:29:19', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 11:29:18', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(48, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763953887.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763953887.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/_layouts/15/Doc.aspx?sourcedoc=%7BB795E5E0-5B5A-474A-BEC3-95D508C27C34%7D&file=20251008_PLTTr%20HCNS_DanhmuchanghoadichvuT01_1763953887.xlsx&action=default&mobileredirect=true', '2025-11-24 03:11:32', '2025-12-01 11:31:42', 1, 'approved', 1, '2025-12-01 11:31:42', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 11:31:41', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(49, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763971215.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763971215.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQCYosJtiW4KR7ozsCDf8LD9AQ0MQ7WjevrsJ0LU8UTmji0', '2025-11-24 08:00:22', '2025-12-01 11:34:34', 1, 'approved', 1, '2025-12-01 11:34:34', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 11:34:33', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(50, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763972393.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1763972393.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQBbehLlA82bRb06eygzg_qjAUIBY-yrHk8IPs96KlvOE2A', '2025-11-24 08:20:01', '2025-12-01 11:35:07', 1, 'approved', 3, '2025-12-01 11:35:07', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 11:35:05', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(51, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764039697.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764039697.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQC7tgJxfxmaR4ghnOlHnazkAeSeDjqG3LTAUL7sQr5hxqk', '2025-11-25 03:01:44', '2025-12-01 13:11:35', 1, 'approved', 4, '2025-12-01 13:11:35', 'Duyệt bởi Ta Quy Tho lúc 01/12/2025, 13:11:34', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(52, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764040038.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764040038.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQCMs_o8EpXTRpCGdnELQSnOATvRuoK4Yc4b2KRMjy610tM', '2025-11-25 03:07:25', '2025-12-01 13:12:57', 1, 'approved', 5, '2025-12-01 13:12:57', 'Duyệt bởi Nguyen Van Chieu lúc 01/12/2025, 13:12:56', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(53, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764040973.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764040973.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQAxpmYyYFfaSYYKCVGSpQKwAerA7jMeBhgVmEc90b0ogCg', '2025-11-25 03:23:00', '2025-12-01 13:40:21', 1, 'approved', 1, '2025-12-01 13:40:21', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 13:40:18', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(54, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764054392.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764054392.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQBjlNyC4KuyQYyKukQdRcphAVnCMWu8oobeqd2s1ueFX9w', '2025-11-25 07:06:40', '2025-12-01 14:12:23', 1, 'approved', 3, '2025-12-01 14:12:23', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 14:12:20', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(55, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764054543.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764054543.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQCy7OLIdPeyQZZXhqZiLgYLAW3qnFbKolX6K5hF-k53xT0', '2025-11-25 07:09:09', '2025-11-25 14:47:14', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(56, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764054713.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764054713.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQCIHzQSYCpCTaiv6zXhp4nNAYdwqySfrjo6YAp04oDmd6U', '2025-11-25 07:12:05', '2025-11-25 14:47:15', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(57, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764054719.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764054719.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQBwIp83ufArQqbMMHh8QihgAVJe8vlgF8gqFs-SRbg0JnY', '2025-11-25 07:12:05', '2025-12-01 14:15:32', 1, 'approved', 3, '2025-12-01 14:15:32', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 14:15:31', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(58, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764055237.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764055237.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQBC9JB8cr9cSIYG5phK9dScAWz9YLWUYvvnhY5nvOvG118', '2025-11-25 07:20:50', '2025-12-01 14:32:39', 1, 'approved', 1, '2025-12-01 14:32:39', 'Duyệt bởi Nguyen Canh Hop lúc 01/12/2025, 14:32:36', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(59, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764055244.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764055244.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQA50TnHWhAFRZaRkzBBD_htAfYFkcE3_ml9xzENtVTrIho', '2025-11-25 07:20:50', '2025-12-01 15:18:11', 1, 'approved', 3, '2025-12-01 15:18:10', 'Duyệt bởi Dinh Van Vinh lúc 01/12/2025, 15:18:09', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(60, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056002.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056002.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQCuQt9EZoXvQoEedbAZV7U0ARfZWD4E44rv_4rCZlkXniI', '2025-11-25 07:33:36', '2025-11-25 14:47:17', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(61, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056009.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056009.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQD-yIvW1T91T7nzReTQYbifAX8JMcGOXSdcWGKj3o91qdo', '2025-11-25 07:33:36', '2025-11-25 14:47:16', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(62, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056140.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056140.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQA2LzqyJuSlR7iE9Zdma5GTAV134USzfkHCZeuc9TGTY5Y', '2025-11-25 07:35:52', '2025-11-25 14:47:21', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(63, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056146.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056146.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQDNlVbJFQZXTbcRsaup_0hxAdjoxBGlxn5IxSQKp4Wa0TU', '2025-11-25 07:35:53', '2025-11-25 14:47:18', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(64, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056298.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056298.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQCRYfpBcna-RIajhG9fA5JWAa5HU7ZVsR21mmoyqbJFCe4', '2025-11-25 07:38:32', '2025-11-25 14:47:23', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(65, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056305.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056305.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQAsrZLZpzKiSo3KfT3qC4wtASrcuCAPG4RYbNUgZapiy00', '2025-11-25 07:38:32', '2025-11-25 14:47:22', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(66, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056560.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056560.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQC4JD7rLsuvRK1m6-53EXWtAfrML5ndXWmHG41YD2zn_NE', '2025-11-25 07:42:53', '2025-11-25 14:47:41', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(67, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056567.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056567.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQCYa4amqm7pQa-deMQpIeqZAenCaXJvowrOJWZFCtGJUR8', '2025-11-25 07:42:54', '2025-11-25 14:47:43', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(68, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056878.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056878.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQDAASgXcSHyTKklbdHtQWdzAbsyuxRgIPRw3lkn40uylF4', '2025-11-25 07:48:11', '2025-11-25 14:54:32', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(69, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056885.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056885.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQC6P5qmp74KRbLOoQot_fhrAeWotP1o0OokrXRMXzHYGc4', '2025-11-25 07:48:12', '2025-12-02 09:35:22', 1, 'approved', 3, '2025-12-02 09:35:22', 'Duyệt bởi Dinh Van Vinh lúc 02/12/2025, 09:35:21', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(70, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056952.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764056952.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQBvXvmlNdZPTpswMr_ATVv4AY6P7csBPsqo5Z95WYtohQQ', '2025-11-25 07:49:24', '2025-11-25 14:54:33', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(71, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056958.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764056958.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQCHU49TVIpTTZrI5pdparZ3AUS8O8ynnegpuaQMdNcLlZY', '2025-11-25 07:49:25', '2025-12-02 09:24:32', 1, 'approved', 5, '2025-12-02 09:24:32', 'Duyệt bởi Nguyen Van Chieu lúc 02/12/2025, 09:24:31', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(72, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057396.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057396.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQA9zu3O0pgSQJ_YPBO3b0TjAS-GZlYUlLHzqKUfUmA81QY', '2025-11-25 07:56:49', '2025-11-25 15:02:07', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(73, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057403.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057403.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQBSoWkHRzv2QqE7R9-88v5SAU1BpfPVf_6xHnIsXwN-HAE', '2025-11-25 07:56:49', '2025-12-02 09:32:25', 1, 'approved', 3, '2025-12-02 09:32:25', 'Duyệt bởi Dinh Van Vinh lúc 02/12/2025, 09:32:24', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(74, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057452.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057452.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQBvcO9OJusJToUNLmEJQihTAclP-H6TeC16Qw_gmImJGbI', '2025-11-25 07:57:44', '2025-11-25 15:02:08', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(75, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057458.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057458.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQAqvbx3SovuTYZJEL-gfSAXAQM80_FiYwepS8Q09o6jxGE', '2025-11-25 07:57:44', '2025-11-25 15:02:09', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(76, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057742.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057742.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQC2uoG1nd02Rou-HAqchQRaAQMZ6Siz5IcXgzMJEEE7t_0', '2025-11-25 08:02:34', '2025-11-25 15:05:35', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(77, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057748.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057748.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQDlLQdWvQ9kSp4zSRLVFV7RAXPexOx7DUbpob89A4mx1DA', '2025-11-25 08:02:35', '2025-11-25 15:05:35', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(78, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057788.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057788.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQAHvnV1anbfSra147tVTkumARvv5iX-mfTn223VWcuSgcE', '2025-11-25 08:03:21', '2025-11-25 15:05:36', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(79, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057795.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057795.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQAyibbLrLgXS5LLA7z9kph8Ac1KJDNl1-Snz7Gx-z2k_V0', '2025-11-25 08:03:22', '2025-11-25 15:05:36', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(80, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057947.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764057947.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQDWN5OigUmIS4FqUfsMVaqvARa5XGN_DXa6qfrlF9YCTCo', '2025-11-25 08:06:01', '2025-12-02 10:28:14', 1, 'approved', 1, '2025-12-02 10:28:14', 'Duyệt bởi Nguyen Canh Hop lúc 02/12/2025, 10:28:13', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(81, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057954.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764057954.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQBsyaQ9ZQTmR6Lyg07mHYrlAVkShdYQTMePUgvMJgikIvc', '2025-11-25 08:06:01', '2025-11-25 15:14:18', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(82, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764058017.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764058017.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQA9_C7Av9zTQ4Hbap-kstGSAWmxovKIZEv9jzIaBpMiYf4', '2025-11-25 08:07:09', '2025-12-02 10:32:48', 1, 'approved', 4, '2025-12-02 10:32:48', 'Duyệt bởi Ta Quy Tho lúc 02/12/2025, 10:32:47', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(83, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764058023.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764058023.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQD04hbNWCtPS7OGgDtSXLtoAeTlXSPKYUdpgXQu3uSZw_A', '2025-11-25 08:07:09', '2025-11-25 15:14:16', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(84, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764058126.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764058126.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQAyUlusWFrZSZBOs0w4SgaRAW4EpcYTMqIcY4avpoiSwMA', '2025-11-25 08:08:52', '2025-11-25 15:14:15', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(85, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764058463.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764058463.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQDxXMjj6vT3SaUisdhapz8_ASSnBH3n_akB9DqPja4PGJU', '2025-11-25 08:14:35', '2025-11-25 15:26:59', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(86, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764058469.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764058469.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQC-KMfRNfPoRJF8Jx_RnM0bATtCqzmOEkIeyV0cSOwRDvs', '2025-11-25 08:14:36', '2025-11-25 15:27:00', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(87, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764058486.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764058486.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQCPUxWMV2mpR5P_L7jTd9htAbdi9Pohrob5izQxyZDudlI', '2025-11-25 08:14:53', '2025-11-25 15:27:01', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(88, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059241.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059241.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQDxmfsJ1Cp2QrggUVod1nfjATLUGWFjI5Z0Dwk6OvIPtec', '2025-11-25 08:27:34', '2025-11-25 15:30:44', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(89, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059247.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059247.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQCkkE82dEAxQacxR3znNqxiASchmeAXkiJI3uqw_NS_Mro', '2025-11-25 08:27:34', '2025-12-02 11:32:22', 1, 'approved', 3, '2025-12-02 11:32:22', 'Duyệt bởi Dinh Van Vinh lúc 02/12/2025, 11:32:20', NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(90, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059265.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059265.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQDei9sx8FCeQIsyugJ48dP1AWYnv4mfrxo67Djvkd4ifp4', '2025-11-25 08:27:51', '2025-11-25 15:35:50', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(91, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059464.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059464.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQDF4AHtj6nsS4vD6gacxPZaAaSrckHNWBd5sekzqgi5J0o', '2025-11-25 08:31:11', '2025-11-25 15:35:49', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(92, 277, NULL, 61, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059682.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059682.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQBdc0dduhY5TrBV5zig10FhAT4NQG5ZfyOk9R4Lx4TpKcw', 3, NULL, '2025-11-25 08:34:49', '2025-11-25 15:35:48', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(93, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059682.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059682.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQBdc0dduhY5TrBV5zig10FhAT4NQG5ZfyOk9R4Lx4TpKcw', '2025-11-25 08:34:49', '2025-11-25 15:41:32', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(94, 277, NULL, 62, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059756.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059756.docx', 'https://netorg15468115.sharepoint.com/:w:/g/IQDJVuEnn_D0RacBeEsHmhz-AfQmB0XEw5h9kl61rKhxEso', 3, NULL, '2025-11-25 08:36:03', '2025-11-28 11:32:50', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 45663, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 11, NULL),
(95, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059756.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059756.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQDJVuEnn_D0RacBeEsHmhz-AfQmB0XEw5h9kl61rKhxEso', '2025-11-25 08:36:03', '2025-11-25 15:41:33', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(96, 277, NULL, 63, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059780.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059780.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQCtjYWREYpcTJq-gPitmSjeAb5ATFJs4qp4CS_GL3fmhZY', 3, NULL, '2025-11-25 08:36:27', '2025-12-02 11:35:13', 0, 'approved', 1, '2025-12-02 11:35:13', 'Duyệt bởi Nguyen Canh Hop lúc 02/12/2025, 11:35:11', NULL, 0, NULL, NULL, NULL, 'sharepoint', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 12, NULL),
(97, 277, NULL, 63, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059787.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059787.docx', 'https://netorg15468115.sharepoint.com/:w:/g/IQB5SUXOPrxgSYtLcE2HTVK9AeuUb7pE0vOOVfjtYi4JoJI', 3, NULL, '2025-11-25 08:36:33', '2025-11-25 15:44:19', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 45663, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 12, NULL),
(98, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059780.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764059780.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQCtjYWREYpcTJq-gPitmSjeAb5ATFJs4qp4CS_GL3fmhZY', '2025-11-25 08:36:33', '2025-11-25 15:41:34', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(99, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059787.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764059787.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQB5SUXOPrxgSYtLcE2HTVK9AeuUb7pE0vOOVfjtYi4JoJI', '2025-11-25 08:36:34', '2025-11-25 15:41:35', 1, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(100, 277, NULL, 64, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060074.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060074.docx', 'https://netorg15468115.sharepoint.com/:w:/g/IQDa0GRtZZvrSpTzDbnbzK6SAXB4_oMfhCVOFlJ9weHqUXM', 3, NULL, '2025-11-25 08:41:20', '2025-11-25 15:44:17', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 45663, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 13, NULL),
(101, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060074.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060074.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQDa0GRtZZvrSpTzDbnbzK6SAXB4_oMfhCVOFlJ9weHqUXM', '2025-11-25 08:41:20', '2025-11-25 15:41:20', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-25 15:41:20', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(102, 277, NULL, 65, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060104.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060104.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQDYxjXHlCflQb93E56OKYT2AY9nx74w5od5UiSbTzFJOz0', 3, NULL, '2025-11-25 08:41:51', '2025-11-25 15:44:17', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 14, NULL),
(103, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060104.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060104.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQDYxjXHlCflQb93E56OKYT2AY9nx74w5od5UiSbTzFJOz0', '2025-11-25 08:41:51', '2025-11-25 15:41:51', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-25 15:41:51', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(104, 277, NULL, 66, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060134.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060134.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQAwxHK94LqCRY1HR8oVsz_MAS2bzwWczotrBfHo91RKg84', 3, NULL, '2025-11-25 08:42:21', '2025-11-25 15:44:15', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 15, NULL),
(105, 277, NULL, 66, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060141.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060141.docx', 'https://netorg15468115.sharepoint.com/:w:/g/IQALnsvxm63cS4JMNiIBP-E1AcXEFMZHzlCchIFCnKwlAVI', 3, NULL, '2025-11-25 08:42:27', '2025-11-25 15:44:15', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 45663, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 15, NULL),
(106, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060134.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060134.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQAwxHK94LqCRY1HR8oVsz_MAS2bzwWczotrBfHo91RKg84', '2025-11-25 08:42:27', '2025-11-25 15:42:28', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-25 15:42:28', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(107, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060141.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060141.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQALnsvxm63cS4JMNiIBP-E1AcXEFMZHzlCchIFCnKwlAVI', '2025-11-25 08:42:28', '2025-11-25 15:42:28', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-25 15:42:28', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(108, 277, NULL, 67, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060267.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060267.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQD5eI9pGXACSL_IolTvanSXAQIXXxvt__4VkX4F6FzTtRQ', 3, NULL, '2025-11-25 08:44:34', '2025-11-28 11:32:48', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 16, NULL),
(109, 277, NULL, 67, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060274.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060274.docx', 'https://netorg15468115.sharepoint.com/:w:/g/IQA_EFx2Ae8NSLMgp20gztypAaUpHaEU39fAOuw1hWT0r04', 3, NULL, '2025-11-25 08:44:39', '2025-11-28 11:32:49', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 45663, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 16, NULL),
(110, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060267.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764060267.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQD5eI9pGXACSL_IolTvanSXAQIXXxvt__4VkX4F6FzTtRQ', '2025-11-25 08:44:39', '2025-11-25 15:44:40', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-25 15:44:40', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(111, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060274.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060274.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQA_EFx2Ae8NSLMgp20gztypAaUpHaEU39fAOuw1hWT0r04', '2025-11-25 08:44:40', '2025-11-25 15:44:40', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-25 15:44:40', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(112, 277, NULL, 68, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060585.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060585.docx', 'https://netorg15468115.sharepoint.com/:w:/g/IQCrQIdyg5w8QL-PtqQMlQm0Ab_aBWn5haFz9U8am2aL6_g', 3, NULL, '2025-11-25 08:49:51', '2025-11-28 11:32:48', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 45663, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 17, NULL),
(113, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060585.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060585.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQCrQIdyg5w8QL-PtqQMlQm0Ab_aBWn5haFz9U8am2aL6_g', '2025-11-25 08:49:51', '2025-11-25 15:49:51', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-25 15:49:51', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(114, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060585.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764060585.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQCrQIdyg5w8QL-PtqQMlQm0Ab_aBWn5haFz9U8am2aL6_g', '2025-11-26 03:26:29', '2025-11-26 10:26:29', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-26 10:26:29', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(115, 277, NULL, 69, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764131590.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764131590.xlsx', 'https://netorg15468115.sharepoint.com/:x:/g/IQAtAvvAuuErRLBuvv26RsObAYveLV21brXDDTxfwPnnqNQ', 3, NULL, '2025-11-26 04:33:18', '2025-11-28 11:32:46', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 18, NULL),
(116, 277, NULL, 69, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764131598.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764131598.docx', 'https://netorg15468115.sharepoint.com/:w:/g/IQDLcpejPqerR7rdZ0SRxjIXAeNHetIE_OHiFuReaEZqp_c', 3, NULL, '2025-11-26 04:33:24', '2025-11-28 11:32:47', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 45663, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 18, NULL),
(117, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764131590.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01_1764131590.xlsx', NULL, 3, 'https://netorg15468115.sharepoint.com/:x:/g/IQAtAvvAuuErRLBuvv26RsObAYveLV21brXDDTxfwPnnqNQ', '2025-11-26 04:33:24', '2025-11-26 11:33:24', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-26 11:33:24', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(118, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764131598.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764131598.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQDLcpejPqerR7rdZ0SRxjIXAeNHetIE_OHiFuReaEZqp_c', '2025-11-26 04:33:25', '2025-11-26 11:33:25', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-26 11:33:25', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(119, 277, NULL, 72, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764144519.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764144519.docx', 'https://netorg15468115.sharepoint.com/:w:/g/IQDp6HgKQtQBSrPEOvXgkJpyAc4WbY2xzThkmXKhDqkFHUg', 3, NULL, '2025-11-26 08:08:45', '2025-11-28 11:32:45', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 45663, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 19, NULL),
(120, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764144519.docx', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01_1764144519.docx', NULL, 3, 'https://netorg15468115.sharepoint.com/:w:/g/IQDp6HgKQtQBSrPEOvXgkJpyAc4WbY2xzThkmXKhDqkFHUg', '2025-11-26 08:08:46', '2025-11-26 15:08:46', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-26 15:08:46', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(121, 277, NULL, 73, 'maudonphuc_khao123_1764146067.pdf', 'maudonphuc_khao123_1764146067.pdf', 'https://netorg15468115.sharepoint.com/:b:/g/IQCA_NIudFlBT75OqlViNwdoAVUjVLFhD50R-6Z5FVsdhjk', 3, NULL, '2025-11-26 08:34:32', '2025-11-28 11:32:43', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'sharepoint', 128195, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 20, NULL),
(122, 277, NULL, NULL, 'maudonphuc_khao123_1764146067.pdf', 'maudonphuc_khao123_1764146067.pdf', NULL, 3, 'https://netorg15468115.sharepoint.com/:b:/g/IQCA_NIudFlBT75OqlViNwdoAVUjVLFhD50R-6Z5FVsdhjk', '2025-11-26 08:34:32', '2025-11-26 15:34:33', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-26 15:34:33', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(123, 277, NULL, 98, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1hDrWA7YBFhrPbhnPiU7x4h1DowwsacpI/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 02:51:37', '2025-11-28 11:32:43', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 21, NULL),
(124, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1hDrWA7YBFhrPbhnPiU7x4h1DowwsacpI/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 02:51:37', '2025-12-03 00:03:29', 1, 'approved', 1, '2025-12-03 00:03:29', 'Duyệt bởi Luong Duc Thuy lúc 03/12/2025, 00:03:28', NULL, 1, NULL, 0, '2025-11-28 09:51:37', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(125, 277, NULL, 99, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1RFyyBt7pErZovWo-g94AnFj7MsKh9o90/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 02:55:43', '2025-11-28 11:32:41', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 22, NULL),
(126, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1RFyyBt7pErZovWo-g94AnFj7MsKh9o90/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 02:55:43', '2025-11-28 09:55:43', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 09:55:43', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(127, 277, NULL, 100, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1wyztpU855vdQSxm18_1BcdQVlF1T5V49/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 03:09:01', '2025-11-28 11:32:42', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 23, NULL),
(128, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1wyztpU855vdQSxm18_1BcdQVlF1T5V49/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 03:09:01', '2025-11-28 10:09:02', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 10:09:02', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(129, 277, NULL, 101, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', 'https://drive.google.com/file/d/1B097XEXIYs4LAFXZ7fmYV2gRO1ev2JIq/view?usp=drivesdk', 3, NULL, '2025-11-28 03:09:50', '2025-11-28 11:32:40', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 128195, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 24, NULL),
(130, 277, NULL, NULL, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', NULL, 3, 'https://drive.google.com/file/d/1B097XEXIYs4LAFXZ7fmYV2gRO1ev2JIq/view?usp=drivesdk', '2025-11-28 03:09:50', '2025-11-28 10:09:50', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 10:09:50', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(131, 277, NULL, 102, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1reQMfeFYJwgld0MNWdtZprWvtPF4XMUs/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 03:10:17', '2025-11-28 11:32:39', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 25, NULL),
(132, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1reQMfeFYJwgld0MNWdtZprWvtPF4XMUs/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 03:10:17', '2025-11-28 10:10:18', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 10:10:18', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(133, 277, NULL, 103, 'TỜ TRÌNH.docx', 'TỜ TRÌNH.docx', 'https://docs.google.com/document/d/1QtUt8JHoYAZzpQUTA5Oj67dj5uebFB1i/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 03:10:38', '2025-11-28 11:32:40', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 22118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 26, NULL),
(134, 277, NULL, NULL, 'TỜ TRÌNH.docx', 'TỜ TRÌNH.docx', NULL, 3, 'https://docs.google.com/document/d/1QtUt8JHoYAZzpQUTA5Oj67dj5uebFB1i/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 03:10:38', '2025-11-28 10:10:39', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 10:10:39', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(135, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1RFyyBt7pErZovWo-g94AnFj7MsKh9o90/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 03:31:54', '2025-11-28 10:31:54', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-28 10:31:54', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL);
INSERT INTO `task_files` (`id`, `task_id`, `document_id`, `comment_id`, `file_name`, `title`, `file_path`, `uploaded_by`, `link_url`, `created_at`, `updated_at`, `is_link`, `status`, `approved_by`, `approved_at`, `review_note`, `approvals_json`, `is_pinned`, `pinned_rank`, `pinned_by`, `pinned_at`, `file_type`, `file_size`, `mime_type`, `file_ext`, `wp_media_id`, `source`, `department_id`, `visibility`, `tags`, `upload_batch`, `google_file_id`) VALUES
(136, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1wyztpU855vdQSxm18_1BcdQVlF1T5V49/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 03:31:57', '2025-11-28 10:31:57', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-28 10:31:57', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(137, 277, NULL, 104, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', 'https://drive.google.com/file/d/1FNQFBAEFzIL-aPKJUts0zMFNvMOYxHEc/view?usp=drivesdk', 3, NULL, '2025-11-28 03:48:37', '2025-11-28 11:32:38', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 128195, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 27, NULL),
(138, 277, NULL, NULL, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', NULL, 3, 'https://drive.google.com/file/d/1FNQFBAEFzIL-aPKJUts0zMFNvMOYxHEc/view?usp=drivesdk', '2025-11-28 03:48:38', '2025-11-28 10:48:38', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 10:48:38', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(139, 277, NULL, 105, 'TỜ TRÌNH.docx', 'TỜ TRÌNH.docx', 'https://docs.google.com/document/d/1E-y0zxgc40VX6AHBma8yqdpCjf-CJje_/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 03:49:03', '2025-11-28 11:32:37', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 22118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 28, NULL),
(140, 277, NULL, NULL, 'TỜ TRÌNH.docx', 'TỜ TRÌNH.docx', NULL, 3, 'https://docs.google.com/document/d/1E-y0zxgc40VX6AHBma8yqdpCjf-CJje_/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 03:49:03', '2025-11-28 10:49:03', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 10:49:03', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(141, 277, NULL, 106, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1L82Gy2sEm6hS6E5dYtk9Iv17qpJxVvnc/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 03:49:39', '2025-11-28 11:32:36', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 29, NULL),
(142, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1L82Gy2sEm6hS6E5dYtk9Iv17qpJxVvnc/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 03:49:40', '2025-11-28 10:49:40', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 10:49:40', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(143, 277, NULL, 107, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1-zuuZbycSJpJJmAvn24NUt1Ef88W88Yk/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 03:53:51', '2025-11-28 11:32:34', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 30, NULL),
(144, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1-zuuZbycSJpJJmAvn24NUt1Ef88W88Yk/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 03:53:52', '2025-11-28 10:53:54', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 10:53:54', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(145, 277, NULL, 108, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1SQOqylVdl3QIvLfzUqJzq3gxhbeQzcwz/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 04:01:09', '2025-11-28 11:32:54', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 2, NULL),
(146, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1SQOqylVdl3QIvLfzUqJzq3gxhbeQzcwz/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 04:01:09', '2025-11-28 11:01:10', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 11:01:10', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(147, 277, NULL, 109, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1y-lgBSw2TNO2BtF9akDiCXyuf3w_Mx58/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 04:01:23', '2025-11-28 11:32:53', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 3, NULL),
(148, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1y-lgBSw2TNO2BtF9akDiCXyuf3w_Mx58/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 04:01:23', '2025-11-28 11:01:23', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 11:01:23', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(149, 277, NULL, 110, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', 'https://drive.google.com/file/d/1FZSglITfLnD0Jv8PFjZwANs7kUC79YY1/view?usp=drivesdk', 3, NULL, '2025-11-28 04:01:36', '2025-11-28 11:32:51', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 128195, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 4, NULL),
(150, 277, NULL, NULL, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', NULL, 3, 'https://drive.google.com/file/d/1FZSglITfLnD0Jv8PFjZwANs7kUC79YY1/view?usp=drivesdk', '2025-11-28 04:01:36', '2025-11-28 11:01:36', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 11:01:36', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(151, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1y-lgBSw2TNO2BtF9akDiCXyuf3w_Mx58/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 04:17:55', '2025-11-28 11:17:55', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-28 11:17:55', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(152, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1SQOqylVdl3QIvLfzUqJzq3gxhbeQzcwz/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 04:32:08', '2025-11-28 11:32:08', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-28 11:32:08', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(153, 277, NULL, 111, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1dU-R1KjER-USokqaubDfPW9utx_CgGu5/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 04:43:15', '2025-11-29 10:37:49', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 5, NULL),
(154, 277, NULL, 111, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/14FjgoDkODtQ_T1o70YWHVoDw-UIUbFoW/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 04:43:17', '2025-11-29 10:37:51', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 5, NULL),
(155, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1dU-R1KjER-USokqaubDfPW9utx_CgGu5/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 04:43:18', '2025-11-28 11:43:18', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 11:43:18', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(156, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/14FjgoDkODtQ_T1o70YWHVoDw-UIUbFoW/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 04:43:18', '2025-11-28 11:43:19', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 11:43:19', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(157, 277, NULL, 112, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1m0CdNgBgf_Iy1DfvWYnTQtmhTOzssNXB/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 04:48:36', '2025-11-29 10:37:44', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 6, NULL),
(158, 277, NULL, 112, 'server.docx', 'server.docx', 'https://docs.google.com/document/d/16OGN2ulcRX6LHkIBXpb1ELYMhpKtTmpW/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 04:48:38', '2025-11-29 10:37:47', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 12958, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 6, NULL),
(159, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1m0CdNgBgf_Iy1DfvWYnTQtmhTOzssNXB/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 04:48:38', '2025-11-28 11:48:39', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 11:48:39', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(160, 277, NULL, NULL, 'server.docx', 'server.docx', NULL, 3, 'https://docs.google.com/document/d/16OGN2ulcRX6LHkIBXpb1ELYMhpKtTmpW/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 04:48:39', '2025-11-28 11:48:39', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 11:48:39', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(161, 277, NULL, 113, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/16ZJMqvkoERQ1OWJNRIYtFW4ZkQ5XIfWx/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', 3, NULL, '2025-11-28 06:27:44', '2025-11-29 10:37:42', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 7, NULL),
(162, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/16ZJMqvkoERQ1OWJNRIYtFW4ZkQ5XIfWx/edit?usp=drivesdk&ouid=103803945556230726641&rtpof=true&sd=true', '2025-11-28 06:27:44', '2025-11-28 13:27:44', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 13:27:44', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(163, 277, NULL, 117, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1os8gy52_N4fCFE7AifcyPVyjs7ccvwXSlB-K8HDA3j8/edit', 3, NULL, '2025-11-28 07:08:14', '2025-11-29 10:37:39', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 8, NULL),
(164, 277, NULL, 117, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/12WJREZ8x6Y_DSyyyefxgjpamRsk3PaX13HAUosbstRY/edit', 3, NULL, '2025-11-28 07:08:25', '2025-11-29 10:37:40', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 8, NULL),
(165, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1os8gy52_N4fCFE7AifcyPVyjs7ccvwXSlB-K8HDA3j8/edit', '2025-11-28 07:08:25', '2025-11-28 14:08:25', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 14:08:25', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(166, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/12WJREZ8x6Y_DSyyyefxgjpamRsk3PaX13HAUosbstRY/edit', '2025-11-28 07:08:26', '2025-11-28 14:08:26', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 14:08:26', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(167, 277, NULL, 118, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1Nd-CK2J5sDnNejE1KQszRinXaKG_6Fy_QUvu0dtfmQI/edit', 3, NULL, '2025-11-28 07:09:42', '2025-11-29 10:37:36', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 9, NULL),
(168, 277, NULL, 118, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1a0RrfZEnI3lURK-X4OLMErQ8NcQ1AuxKAXOi7S7hUro/edit', 3, NULL, '2025-11-28 07:09:49', '2025-11-29 10:37:37', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 9, NULL),
(169, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1Nd-CK2J5sDnNejE1KQszRinXaKG_6Fy_QUvu0dtfmQI/edit', '2025-11-28 07:09:49', '2025-11-28 14:09:49', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 14:09:49', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(170, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1a0RrfZEnI3lURK-X4OLMErQ8NcQ1AuxKAXOi7S7hUro/edit', '2025-11-28 07:09:50', '2025-11-28 14:09:50', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 14:09:50', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(171, 277, NULL, 119, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1pqG74Ng-oZcF35yo04i3TQ13WBwnIt_hRfg-n5uxWVM/edit', 3, NULL, '2025-11-28 07:53:04', '2025-11-29 10:37:45', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 6, NULL),
(172, 277, NULL, 119, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1BuKwxBkynCM7CdTBPtFQ-4-4Z16BN-1r-E54779vLT0/edit', 3, NULL, '2025-11-28 07:53:12', '2025-11-29 10:37:46', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 6, NULL),
(173, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1pqG74Ng-oZcF35yo04i3TQ13WBwnIt_hRfg-n5uxWVM/edit', '2025-11-28 07:53:12', '2025-11-28 14:53:12', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 14:53:12', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(174, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1BuKwxBkynCM7CdTBPtFQ-4-4Z16BN-1r-E54779vLT0/edit', '2025-11-28 07:53:13', '2025-11-28 14:53:13', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 14:53:13', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(175, 277, NULL, 124, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1dsjNqFWoAKPkW31yapg1cFSnMcfjTkJ4FoUAWnn0gq0/edit', 3, NULL, '2025-11-28 09:10:35', '2025-11-29 10:37:43', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 7, NULL),
(176, 277, NULL, 125, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1wm6LZimG_uOWG4FEvF-wSVm5HAeywNPHKwONLzX3ZWk/edit', 3, NULL, '2025-11-28 09:13:19', '2025-11-29 10:37:41', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 8, NULL),
(177, 277, NULL, 125, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1gl7dVyyvuSJIKtVOhIzHiaFUJtTVdFWVqwGL3O2TUaI/edit', 3, NULL, '2025-11-28 09:13:26', '2025-11-29 10:37:41', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 8, NULL),
(178, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1wm6LZimG_uOWG4FEvF-wSVm5HAeywNPHKwONLzX3ZWk/edit', '2025-11-28 09:13:26', '2025-11-28 16:13:26', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 16:13:26', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(179, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1gl7dVyyvuSJIKtVOhIzHiaFUJtTVdFWVqwGL3O2TUaI/edit', '2025-11-28 09:13:27', '2025-11-28 16:13:27', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 16:13:27', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(180, 277, NULL, 126, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1_7nXjU4jqIzq0tOWwxcR6kgPuT0uw9KWZ2iW-ov7E_8/edit', 3, NULL, '2025-11-28 09:18:46', '2025-11-29 10:37:37', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 9, NULL),
(181, 277, NULL, 126, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1xUVDP0tkNZXrnZX9lZpA4-pcLh7eLf-7iSlnZ90gehI/edit', 3, NULL, '2025-11-28 09:18:52', '2025-11-29 10:37:38', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 9, NULL),
(182, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1_7nXjU4jqIzq0tOWwxcR6kgPuT0uw9KWZ2iW-ov7E_8/edit', '2025-11-28 09:18:52', '2025-11-28 16:18:52', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 16:18:52', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(183, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1xUVDP0tkNZXrnZX9lZpA4-pcLh7eLf-7iSlnZ90gehI/edit', '2025-11-28 09:18:53', '2025-11-28 16:18:53', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 16:18:53', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(184, 277, NULL, 127, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1XRvAm6suaG1iyzUzCO5ZLUW3FvGzdxxDP0LODQpSJW0/edit', 3, NULL, '2025-11-28 09:23:41', '2025-11-29 10:37:34', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 10, '1XRvAm6suaG1iyzUzCO5ZLUW3FvGzdxxDP0LODQpSJW0'),
(185, 277, NULL, 127, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1XTfUZ2fY6EE6fp2BpxmuSN4suFnftob2Miyxi_1ZmCc/edit', 3, NULL, '2025-11-28 09:23:48', '2025-11-29 10:37:35', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 10, '1XTfUZ2fY6EE6fp2BpxmuSN4suFnftob2Miyxi_1ZmCc'),
(186, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1XRvAm6suaG1iyzUzCO5ZLUW3FvGzdxxDP0LODQpSJW0/edit', '2025-11-28 09:23:48', '2025-11-28 16:23:48', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 16:23:48', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(187, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1XTfUZ2fY6EE6fp2BpxmuSN4suFnftob2Miyxi_1ZmCc/edit', '2025-11-28 09:23:49', '2025-11-28 16:23:49', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-28 16:23:49', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(188, 277, NULL, NULL, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', NULL, 3, 'https://drive.google.com/file/d/1FZSglITfLnD0Jv8PFjZwANs7kUC79YY1/view?usp=drivesdk', '2025-11-29 02:09:11', '2025-11-29 09:09:11', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-29 09:09:11', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(189, 277, NULL, NULL, 'maudonphuc_khao123.pdf', 'maudonphuc_khao123.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/maudonphuc_khao123-7.pdf', '2025-11-29 02:55:17', '2025-11-29 09:55:17', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-29 09:55:17', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(190, 277, NULL, 129, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1EO_v-rC5pwwxCqD_qVLNzKXhoIIl3JjJoysIGnqqmZw/edit', 3, NULL, '2025-11-29 03:27:06', '2025-11-29 10:37:32', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 11, '1EO_v-rC5pwwxCqD_qVLNzKXhoIIl3JjJoysIGnqqmZw'),
(191, 277, NULL, 129, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1OW6xtdafX8AYU-KQbhSMz1HqUiwJ3-XIv1OdhItdsu8/edit', 3, NULL, '2025-11-29 03:27:14', '2025-11-29 10:37:33', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 11, '1OW6xtdafX8AYU-KQbhSMz1HqUiwJ3-XIv1OdhItdsu8'),
(192, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1EO_v-rC5pwwxCqD_qVLNzKXhoIIl3JjJoysIGnqqmZw/edit', '2025-11-29 03:27:15', '2025-11-29 10:27:15', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:27:15', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(193, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1OW6xtdafX8AYU-KQbhSMz1HqUiwJ3-XIv1OdhItdsu8/edit', '2025-11-29 03:27:15', '2025-11-29 10:27:15', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:27:15', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(194, 277, NULL, 132, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1hqo_omx5pseDLqJx5ttSk6ErKbwbMGSqOE09B6mK__s/edit', 3, NULL, '2025-11-29 03:36:15', '2025-11-29 10:37:52', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 5, '1hqo_omx5pseDLqJx5ttSk6ErKbwbMGSqOE09B6mK__s'),
(195, 277, NULL, 132, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1PGaW_7jiruFo0IXmd-OWxTR7M0skt8Q57z1EW-JgDoQ/edit', 3, NULL, '2025-11-29 03:36:22', '2025-11-29 10:37:52', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 5, '1PGaW_7jiruFo0IXmd-OWxTR7M0skt8Q57z1EW-JgDoQ'),
(196, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1hqo_omx5pseDLqJx5ttSk6ErKbwbMGSqOE09B6mK__s/edit', '2025-11-29 03:36:22', '2025-11-29 10:36:22', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:36:22', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(197, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1PGaW_7jiruFo0IXmd-OWxTR7M0skt8Q57z1EW-JgDoQ/edit', '2025-11-29 03:36:23', '2025-11-29 10:36:23', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:36:23', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(198, 277, NULL, 133, 'bao_gia_web_2025.xls', 'bao_gia_web_2025.xls', 'https://docs.google.com/spreadsheets/d/1FrkSh5pO0TRJf8pgG0SpFaWVdKuOyhawi6r6S8LDcZ0/edit', 3, NULL, '2025-11-29 03:37:05', '2025-11-29 10:37:48', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 35840, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 6, '1FrkSh5pO0TRJf8pgG0SpFaWVdKuOyhawi6r6S8LDcZ0'),
(199, 277, NULL, NULL, 'bao_gia_web_2025.xls', 'bao_gia_web_2025.xls', NULL, 3, 'https://docs.google.com/spreadsheets/d/1FrkSh5pO0TRJf8pgG0SpFaWVdKuOyhawi6r6S8LDcZ0/edit', '2025-11-29 03:37:05', '2025-11-29 10:37:05', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:37:05', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(200, 277, NULL, 134, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1JPuNqsROiffVn1Btm_pzMSnq3rfyN8BUDtG7Dwx1yRU/edit', 3, NULL, '2025-11-29 03:38:09', '2025-11-30 10:33:11', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 7, '1JPuNqsROiffVn1Btm_pzMSnq3rfyN8BUDtG7Dwx1yRU'),
(201, 277, NULL, 134, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1VhxlPxTeMyUPmcEzCeAKtfm3a5T9d5zD7wzUMQOKN-E/edit', 3, NULL, '2025-11-29 03:38:16', '2025-11-30 10:33:12', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 7, '1VhxlPxTeMyUPmcEzCeAKtfm3a5T9d5zD7wzUMQOKN-E'),
(202, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1JPuNqsROiffVn1Btm_pzMSnq3rfyN8BUDtG7Dwx1yRU/edit', '2025-11-29 03:38:16', '2025-11-29 10:38:16', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:38:16', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(203, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1VhxlPxTeMyUPmcEzCeAKtfm3a5T9d5zD7wzUMQOKN-E/edit', '2025-11-29 03:38:17', '2025-11-29 10:38:17', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:38:17', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(204, 277, NULL, 135, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1r9SWWq4ts-3p-INF1_0YHzzaS0gD6lCQzCTk8HRHB2U/edit', 3, NULL, '2025-11-29 03:38:32', '2025-11-30 10:33:10', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 8, '1r9SWWq4ts-3p-INF1_0YHzzaS0gD6lCQzCTk8HRHB2U'),
(205, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1r9SWWq4ts-3p-INF1_0YHzzaS0gD6lCQzCTk8HRHB2U/edit', '2025-11-29 03:38:32', '2025-11-29 10:38:33', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:38:33', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(206, 277, NULL, 136, 'bao_gia_web_2025.xls', 'bao_gia_web_2025.xls', 'https://docs.google.com/spreadsheets/d/1RATQy5Yt3UkbolVKczWFsO3Qcn-3GJs63XMRGzf5LFE/edit', 3, NULL, '2025-11-29 03:38:53', '2025-11-30 10:33:09', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 35840, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 9, '1RATQy5Yt3UkbolVKczWFsO3Qcn-3GJs63XMRGzf5LFE'),
(207, 277, NULL, NULL, 'bao_gia_web_2025.xls', 'bao_gia_web_2025.xls', NULL, 3, 'https://docs.google.com/spreadsheets/d/1RATQy5Yt3UkbolVKczWFsO3Qcn-3GJs63XMRGzf5LFE/edit', '2025-11-29 03:38:53', '2025-11-29 10:38:53', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:38:53', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(208, 277, NULL, 137, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1Q8gc5bpQ3S-uzrMtRr3DmSzCq5uqKIerQjT2j6526cQ/edit', 3, NULL, '2025-11-29 03:39:44', '2025-11-30 10:33:08', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 10, '1Q8gc5bpQ3S-uzrMtRr3DmSzCq5uqKIerQjT2j6526cQ'),
(209, 277, NULL, 137, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1BgLbej6cfxFQBJR2w07M1_i2gwuDWC2D1RM62S8TGaU/edit', 3, NULL, '2025-11-29 03:39:51', '2025-11-30 10:33:07', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 10, '1BgLbej6cfxFQBJR2w07M1_i2gwuDWC2D1RM62S8TGaU'),
(210, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1Q8gc5bpQ3S-uzrMtRr3DmSzCq5uqKIerQjT2j6526cQ/edit', '2025-11-29 03:39:51', '2025-11-29 10:39:51', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:39:51', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(211, 277, NULL, NULL, '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1BgLbej6cfxFQBJR2w07M1_i2gwuDWC2D1RM62S8TGaU/edit', '2025-11-29 03:39:51', '2025-11-29 10:39:52', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 10:39:52', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(212, 277, NULL, 138, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1DT68_jQMjWU3mIzxX8ztLVLmHVcsFDe5kXvgP6CAR6A/edit', 3, NULL, '2025-11-29 04:11:03', '2025-11-30 10:33:07', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 11, '1DT68_jQMjWU3mIzxX8ztLVLmHVcsFDe5kXvgP6CAR6A'),
(213, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1DT68_jQMjWU3mIzxX8ztLVLmHVcsFDe5kXvgP6CAR6A/edit', '2025-11-29 04:11:03', '2025-11-29 11:11:03', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 11:11:03', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(214, 277, NULL, 140, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/15lBQ9hkcOdUAVpngAs8l90SjexHAulnBULYDdrcs91I/edit', 3, NULL, '2025-11-29 04:41:20', '2025-11-30 10:33:07', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 12, '15lBQ9hkcOdUAVpngAs8l90SjexHAulnBULYDdrcs91I'),
(215, 277, NULL, 140, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1nF6JRhAFdl80hS-sqZcGBxh3hJQI-btE-lHt_LQkEE0/edit', 3, NULL, '2025-11-29 04:41:27', '2025-11-30 10:33:07', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 12, '1nF6JRhAFdl80hS-sqZcGBxh3hJQI-btE-lHt_LQkEE0'),
(216, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/15lBQ9hkcOdUAVpngAs8l90SjexHAulnBULYDdrcs91I/edit', '2025-11-29 04:41:27', '2025-11-29 11:41:28', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 11:41:28', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(217, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1nF6JRhAFdl80hS-sqZcGBxh3hJQI-btE-lHt_LQkEE0/edit', '2025-11-29 04:41:28', '2025-11-29 11:41:28', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 11:41:28', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(218, 277, NULL, 141, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/19ERgqCA77xpREc8nAQtYVOsq7ujHy8HRBOujFoKqZhY/edit', 3, NULL, '2025-11-29 07:02:14', '2025-11-30 10:33:07', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 13, '19ERgqCA77xpREc8nAQtYVOsq7ujHy8HRBOujFoKqZhY'),
(219, 277, NULL, 141, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/10divOGSqdXZIH3COZlXkgE44X6Xa8Oc7scuJdyEnanE/edit', 3, NULL, '2025-11-29 07:02:21', '2025-11-30 10:33:06', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318118, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 13, '10divOGSqdXZIH3COZlXkgE44X6Xa8Oc7scuJdyEnanE'),
(220, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/19ERgqCA77xpREc8nAQtYVOsq7ujHy8HRBOujFoKqZhY/edit', '2025-11-29 07:02:21', '2025-11-29 14:02:21', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:02:21', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(221, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/10divOGSqdXZIH3COZlXkgE44X6Xa8Oc7scuJdyEnanE/edit', '2025-11-29 07:02:22', '2025-11-29 14:02:22', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:02:22', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(222, 277, NULL, 142, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1zLbY4CbSP6WQgESFtq4pp8U2Bi4L73TOhHsXNUjDeSU/edit', 3, NULL, '2025-11-29 07:05:21', '2025-11-30 10:33:06', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 14, '1zLbY4CbSP6WQgESFtq4pp8U2Bi4L73TOhHsXNUjDeSU'),
(223, 277, NULL, 142, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1RpiBil2a3sQvZeYxtywRoW7-RdpJJ4qh-JzT5_t5R6I/edit', 3, NULL, '2025-11-29 07:05:29', '2025-11-30 10:33:06', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318159, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 14, '1RpiBil2a3sQvZeYxtywRoW7-RdpJJ4qh-JzT5_t5R6I'),
(224, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1zLbY4CbSP6WQgESFtq4pp8U2Bi4L73TOhHsXNUjDeSU/edit', '2025-11-29 07:05:29', '2025-11-29 14:05:30', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:05:30', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(225, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1RpiBil2a3sQvZeYxtywRoW7-RdpJJ4qh-JzT5_t5R6I/edit', '2025-11-29 07:05:30', '2025-11-29 14:05:30', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:05:30', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(226, 277, NULL, 143, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1p2V0xWBcvBmivfQgTfEguJCu-cnjbwNzr6CuAIK8JD8/edit', 3, NULL, '2025-11-29 07:13:15', '2025-11-30 10:33:06', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 15, '1p2V0xWBcvBmivfQgTfEguJCu-cnjbwNzr6CuAIK8JD8'),
(227, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1p2V0xWBcvBmivfQgTfEguJCu-cnjbwNzr6CuAIK8JD8/edit', '2025-11-29 07:13:15', '2025-11-29 14:13:15', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:13:15', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(228, 277, NULL, 144, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1lWEEX04c0--RIpQSZimamW2ci-NT51fIkyeMfoujxj0/edit', 3, NULL, '2025-11-29 07:14:13', '2025-11-30 10:33:06', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318159, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 16, '1lWEEX04c0--RIpQSZimamW2ci-NT51fIkyeMfoujxj0'),
(229, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1lWEEX04c0--RIpQSZimamW2ci-NT51fIkyeMfoujxj0/edit', '2025-11-29 07:14:13', '2025-11-29 14:14:14', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:14:14', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(230, 277, NULL, 145, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1aDU2QeVdjQdfo2LfMMNNdkrl7dVlY4zRQBI3JKwj2p8/edit', 3, NULL, '2025-11-29 07:18:12', '2025-11-30 10:33:06', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318120, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 17, '1aDU2QeVdjQdfo2LfMMNNdkrl7dVlY4zRQBI3JKwj2p8'),
(231, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1aDU2QeVdjQdfo2LfMMNNdkrl7dVlY4zRQBI3JKwj2p8/edit', '2025-11-29 07:18:12', '2025-11-29 14:18:12', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:18:12', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(232, 277, NULL, 146, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1hKWEVNGmwWYVDeMxO-zGHGtdqFPb6d20h-gURayTqgQ/edit', 3, NULL, '2025-11-29 07:20:45', '2025-11-30 10:33:05', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 18, '1hKWEVNGmwWYVDeMxO-zGHGtdqFPb6d20h-gURayTqgQ'),
(233, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1hKWEVNGmwWYVDeMxO-zGHGtdqFPb6d20h-gURayTqgQ/edit', '2025-11-29 07:20:45', '2025-11-29 14:20:46', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:20:46', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(234, 277, NULL, 147, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1ROdX4yEBnwNClsY1dv6nrWn3rwgKJm7TG8XjXsDNwdk/edit', 3, NULL, '2025-11-29 07:21:56', '2025-11-30 10:33:05', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 19, '1ROdX4yEBnwNClsY1dv6nrWn3rwgKJm7TG8XjXsDNwdk'),
(235, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1ROdX4yEBnwNClsY1dv6nrWn3rwgKJm7TG8XjXsDNwdk/edit', '2025-11-29 07:21:56', '2025-11-29 14:21:56', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:21:56', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(236, 277, NULL, 148, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1YS_wLCkr6-oR3s92UtgsBCm5NazobnOF9yf9Z0YBm5k/edit', 3, NULL, '2025-11-29 07:28:44', '2025-11-30 10:33:05', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 20, '1YS_wLCkr6-oR3s92UtgsBCm5NazobnOF9yf9Z0YBm5k'),
(237, 277, NULL, 148, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1TpS1o8k6qOvj85AW3fn_b3oALAXGkzi163Dmi7aEScs/edit', 3, NULL, '2025-11-29 07:28:52', '2025-11-30 10:33:05', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 20, '1TpS1o8k6qOvj85AW3fn_b3oALAXGkzi163Dmi7aEScs'),
(238, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1YS_wLCkr6-oR3s92UtgsBCm5NazobnOF9yf9Z0YBm5k/edit', '2025-11-29 07:28:52', '2025-11-29 14:28:52', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:28:52', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(239, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1TpS1o8k6qOvj85AW3fn_b3oALAXGkzi163Dmi7aEScs/edit', '2025-11-29 07:28:53', '2025-11-29 14:28:53', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:28:53', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(240, 277, NULL, 149, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1osFYZqT7MmOds426gbjtGguerbSOdD16-0PnAsouSjQ/edit', 3, NULL, '2025-11-29 07:39:02', '2025-11-30 10:33:05', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 21, '1osFYZqT7MmOds426gbjtGguerbSOdD16-0PnAsouSjQ'),
(241, 277, NULL, 149, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/179Kzje_SKbiFTwTpD5TmJnQerRAUZCVW-8EOxOLyIPg/edit', 3, NULL, '2025-11-29 07:39:09', '2025-11-30 10:33:04', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 21, '179Kzje_SKbiFTwTpD5TmJnQerRAUZCVW-8EOxOLyIPg'),
(242, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1osFYZqT7MmOds426gbjtGguerbSOdD16-0PnAsouSjQ/edit', '2025-11-29 07:39:09', '2025-11-29 14:39:09', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:39:09', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(243, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/179Kzje_SKbiFTwTpD5TmJnQerRAUZCVW-8EOxOLyIPg/edit', '2025-11-29 07:39:10', '2025-11-29 14:39:10', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 14:39:10', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(244, 277, NULL, 152, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1qpuIaXVw2F0e4p-8mDzekVUpRexXxNgSWlyHTcG82Xc/edit', 3, NULL, '2025-11-29 09:16:03', '2025-11-30 10:33:04', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 22, '1qpuIaXVw2F0e4p-8mDzekVUpRexXxNgSWlyHTcG82Xc'),
(245, 277, NULL, 152, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1xI96iJtkE__BLX44hqYVy_dsf16YsxGEK6grrgYwJwc/edit', 3, NULL, '2025-11-29 09:16:13', '2025-11-30 10:33:04', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 22, '1xI96iJtkE__BLX44hqYVy_dsf16YsxGEK6grrgYwJwc'),
(246, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1qpuIaXVw2F0e4p-8mDzekVUpRexXxNgSWlyHTcG82Xc/edit', '2025-11-29 09:16:13', '2025-11-29 16:16:14', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 16:16:14', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(247, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1xI96iJtkE__BLX44hqYVy_dsf16YsxGEK6grrgYwJwc/edit', '2025-11-29 09:16:14', '2025-11-29 16:16:14', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-29 16:16:14', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(248, 277, NULL, 154, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1wlolxhu-exhf4X6J-RFtzE6hIASsKYAYdx5J1Uygee8/edit', 3, NULL, '2025-11-29 17:00:34', '2025-11-30 10:33:04', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 94208, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 23, '1wlolxhu-exhf4X6J-RFtzE6hIASsKYAYdx5J1Uygee8'),
(249, 277, NULL, 154, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1iU5x9m3hr8CplM5n4PISWwaRExMYIwHtCbw164Rcvbo/edit', 3, NULL, '2025-11-29 17:00:42', '2025-11-30 10:33:04', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 23, '1iU5x9m3hr8CplM5n4PISWwaRExMYIwHtCbw164Rcvbo');
INSERT INTO `task_files` (`id`, `task_id`, `document_id`, `comment_id`, `file_name`, `title`, `file_path`, `uploaded_by`, `link_url`, `created_at`, `updated_at`, `is_link`, `status`, `approved_by`, `approved_at`, `review_note`, `approvals_json`, `is_pinned`, `pinned_rank`, `pinned_by`, `pinned_at`, `file_type`, `file_size`, `mime_type`, `file_ext`, `wp_media_id`, `source`, `department_id`, `visibility`, `tags`, `upload_batch`, `google_file_id`) VALUES
(250, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1wlolxhu-exhf4X6J-RFtzE6hIASsKYAYdx5J1Uygee8/edit', '2025-11-29 17:00:43', '2025-11-30 00:00:43', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:00:43', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(251, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1iU5x9m3hr8CplM5n4PISWwaRExMYIwHtCbw164Rcvbo/edit', '2025-11-29 17:00:44', '2025-11-30 00:00:44', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:00:44', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(252, 277, NULL, 155, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1ugj7qDZ12gBjRvHXWMboMgBi44hCKgRadBlU4QO7oKo/edit', 3, NULL, '2025-11-29 17:04:49', '2025-11-30 10:33:03', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 94208, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 24, '1ugj7qDZ12gBjRvHXWMboMgBi44hCKgRadBlU4QO7oKo'),
(253, 277, NULL, 155, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1BxzY3pRDnA1n07K3wDt-aNc9o0R_xLMy1ngHpInQp04/edit', 3, NULL, '2025-11-29 17:04:56', '2025-11-30 10:33:03', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 24, '1BxzY3pRDnA1n07K3wDt-aNc9o0R_xLMy1ngHpInQp04'),
(254, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1ugj7qDZ12gBjRvHXWMboMgBi44hCKgRadBlU4QO7oKo/edit', '2025-11-29 17:04:56', '2025-11-30 00:04:56', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:04:56', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(255, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1BxzY3pRDnA1n07K3wDt-aNc9o0R_xLMy1ngHpInQp04/edit', '2025-11-29 17:04:56', '2025-11-30 00:04:57', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:04:57', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(256, 277, NULL, 156, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1RVwQzKv6PA8SAEA9jvFjuQhoZEM_28PdUgOwX1-FFLs/edit', 3, NULL, '2025-11-29 17:11:20', '2025-11-30 10:33:03', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 94208, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 25, '1RVwQzKv6PA8SAEA9jvFjuQhoZEM_28PdUgOwX1-FFLs'),
(257, 277, NULL, 156, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1XxvSnG9KK7Alb7gzvstjf3-1NeEA5-8K5Mb8M-Tsg8Y/edit', 3, NULL, '2025-11-29 17:11:27', '2025-11-30 10:33:03', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 25, '1XxvSnG9KK7Alb7gzvstjf3-1NeEA5-8K5Mb8M-Tsg8Y'),
(258, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1RVwQzKv6PA8SAEA9jvFjuQhoZEM_28PdUgOwX1-FFLs/edit', '2025-11-29 17:11:27', '2025-11-30 00:11:27', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:11:27', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(259, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1XxvSnG9KK7Alb7gzvstjf3-1NeEA5-8K5Mb8M-Tsg8Y/edit', '2025-11-29 17:11:28', '2025-11-30 00:11:28', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:11:28', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(260, 277, NULL, 157, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1gp8xhdQZUo3t2kibxieiedN_BENj3xLDENKT30q8qso/edit', 3, NULL, '2025-11-29 17:21:12', '2025-11-30 10:33:02', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 94208, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 26, '1gp8xhdQZUo3t2kibxieiedN_BENj3xLDENKT30q8qso'),
(261, 277, NULL, 157, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1qRwywIqXU9WdXG9hjJKVe5UoI5g57opYfDbrK9SCnnY/edit', 3, NULL, '2025-11-29 17:21:18', '2025-11-30 10:33:02', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 26, '1qRwywIqXU9WdXG9hjJKVe5UoI5g57opYfDbrK9SCnnY'),
(262, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1gp8xhdQZUo3t2kibxieiedN_BENj3xLDENKT30q8qso/edit', '2025-11-29 17:21:18', '2025-11-30 00:21:18', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:21:18', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(263, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1qRwywIqXU9WdXG9hjJKVe5UoI5g57opYfDbrK9SCnnY/edit', '2025-11-29 17:21:19', '2025-11-30 00:21:19', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:21:19', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(264, 277, NULL, 158, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/13eyvv6Q6Sqyayenltk5AzekAl-YR8CmIrN6tWcz0yCo/edit', 3, NULL, '2025-11-29 17:24:35', '2025-11-30 10:33:01', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 27, '13eyvv6Q6Sqyayenltk5AzekAl-YR8CmIrN6tWcz0yCo'),
(265, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/13eyvv6Q6Sqyayenltk5AzekAl-YR8CmIrN6tWcz0yCo/edit', '2025-11-29 17:24:36', '2025-11-30 00:24:36', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:24:36', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(266, 277, NULL, 159, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1ibiiclr_rIMWRHJ8tGjO_OSjKADJgp4gcGV8jdajiCE/edit', 3, NULL, '2025-11-29 17:31:20', '2025-11-30 10:33:01', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 28, '1ibiiclr_rIMWRHJ8tGjO_OSjKADJgp4gcGV8jdajiCE'),
(267, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1ibiiclr_rIMWRHJ8tGjO_OSjKADJgp4gcGV8jdajiCE/edit', '2025-11-29 17:31:20', '2025-11-30 00:31:21', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:31:21', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(268, 277, NULL, 160, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1I5n7sh_IqBUxpDZkiC-Ph-8R6Szfn8SmT2z7DnamCNI/edit', 3, NULL, '2025-11-29 17:39:34', '2025-11-30 10:33:01', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 29, '1I5n7sh_IqBUxpDZkiC-Ph-8R6Szfn8SmT2z7DnamCNI'),
(269, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1I5n7sh_IqBUxpDZkiC-Ph-8R6Szfn8SmT2z7DnamCNI/edit', '2025-11-29 17:39:35', '2025-11-30 00:39:35', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:39:35', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(270, 277, NULL, 161, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1lpItOKm6PwUGvTf1XEC-MwWNjzhFurWcf92L8vN69kI/edit', 3, NULL, '2025-11-29 17:51:43', '2025-11-30 10:33:01', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 30, '1lpItOKm6PwUGvTf1XEC-MwWNjzhFurWcf92L8vN69kI'),
(271, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1lpItOKm6PwUGvTf1XEC-MwWNjzhFurWcf92L8vN69kI/edit', '2025-11-29 17:51:43', '2025-11-30 00:51:44', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:51:44', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(272, 277, NULL, 162, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1uV2F84GWVQvobRY5cjidjxOvwRDWcuoCewl-qb_SNYE/edit', 3, NULL, '2025-11-29 17:53:50', '2025-11-30 10:33:01', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 31, '1uV2F84GWVQvobRY5cjidjxOvwRDWcuoCewl-qb_SNYE'),
(273, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1uV2F84GWVQvobRY5cjidjxOvwRDWcuoCewl-qb_SNYE/edit', '2025-11-29 17:53:50', '2025-11-30 00:53:50', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 00:53:50', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(274, 277, NULL, 163, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1leWOrh81KcE2FinI7r2gURFGjJt2-7BHxt-hGPTYN3g/edit', 3, NULL, '2025-11-30 02:32:24', '2025-11-30 10:33:01', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 32, '1leWOrh81KcE2FinI7r2gURFGjJt2-7BHxt-hGPTYN3g'),
(275, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1leWOrh81KcE2FinI7r2gURFGjJt2-7BHxt-hGPTYN3g/edit', '2025-11-30 02:32:25', '2025-11-30 09:32:25', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 09:32:25', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(276, 277, NULL, 164, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1SRM6GazNBwgDHR6hqlHneANXR_QVAL8ahlctvX3IjA4/edit', 3, NULL, '2025-11-30 02:45:23', '2025-11-30 10:33:00', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 33, '1SRM6GazNBwgDHR6hqlHneANXR_QVAL8ahlctvX3IjA4'),
(277, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1SRM6GazNBwgDHR6hqlHneANXR_QVAL8ahlctvX3IjA4/edit', '2025-11-30 02:45:23', '2025-11-30 09:45:24', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 09:45:24', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(278, 277, NULL, 165, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/19IH5evi9RsXKwqs0u6fhjs9I1cm69zoqNwWzT7o5ieg/edit', 3, NULL, '2025-11-30 02:48:07', '2025-11-30 10:32:59', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 34, '19IH5evi9RsXKwqs0u6fhjs9I1cm69zoqNwWzT7o5ieg'),
(279, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/19IH5evi9RsXKwqs0u6fhjs9I1cm69zoqNwWzT7o5ieg/edit', '2025-11-30 02:48:08', '2025-11-30 09:48:08', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 09:48:08', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(280, 277, NULL, 166, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1EfTqjr1hSThFR9AV1CAcMQWm1S2-tbILlP3BKZTOQLo/edit', 3, NULL, '2025-11-30 02:51:18', '2025-11-30 10:32:58', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 35, '1EfTqjr1hSThFR9AV1CAcMQWm1S2-tbILlP3BKZTOQLo'),
(281, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1EfTqjr1hSThFR9AV1CAcMQWm1S2-tbILlP3BKZTOQLo/edit', '2025-11-30 02:51:18', '2025-11-30 09:51:19', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 09:51:19', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(282, 277, NULL, 167, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1uHtpcu7lbsnr-b-zVkjrwpJvuLoolex0NmkXG_h7coE/edit', 3, NULL, '2025-11-30 02:57:21', '2025-11-30 10:32:58', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 36, '1uHtpcu7lbsnr-b-zVkjrwpJvuLoolex0NmkXG_h7coE'),
(283, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1uHtpcu7lbsnr-b-zVkjrwpJvuLoolex0NmkXG_h7coE/edit', '2025-11-30 02:57:21', '2025-11-30 09:57:22', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 09:57:22', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(284, 277, NULL, 168, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/15ADsbwTV-75nLorBtYB_y8JMNfqtUcy7ZShFVcOXnRM/edit', 3, NULL, '2025-11-30 03:34:32', '2025-11-30 10:34:32', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 10:34:32', 'google_drive', 316364, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 5, '15ADsbwTV-75nLorBtYB_y8JMNfqtUcy7ZShFVcOXnRM'),
(285, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/15ADsbwTV-75nLorBtYB_y8JMNfqtUcy7ZShFVcOXnRM/edit', '2025-11-30 03:34:32', '2025-11-30 10:34:33', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 10:34:33', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(286, 277, NULL, 169, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1sVv0dYAyx2HycaI7DxJ06HAgCUdtEBSCuQeqPkJCppc/edit', 3, NULL, '2025-11-30 04:41:06', '2025-11-30 11:41:06', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 11:41:06', 'google_drive', 316358, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 5, '1sVv0dYAyx2HycaI7DxJ06HAgCUdtEBSCuQeqPkJCppc'),
(287, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1sVv0dYAyx2HycaI7DxJ06HAgCUdtEBSCuQeqPkJCppc/edit', '2025-11-30 04:41:07', '2025-11-30 11:41:07', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 11:41:07', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(288, 277, NULL, 170, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4/edit', 3, NULL, '2025-11-30 04:41:53', '2025-11-30 11:41:53', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 11:41:53', 'google_drive', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 6, '1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4'),
(289, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1EA2-yIQiwHvQVNKidVkOgdI9fbvXyx9SRFlUQIsSao4/edit', '2025-11-30 04:41:53', '2025-11-30 11:41:54', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 11:41:54', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(290, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 11:22:45', '2025-11-30 18:22:45', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 18:22:45', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(291, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 11:29:10', '2025-11-30 18:29:10', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 18:29:10', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(292, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 11:52:04', '2025-11-30 18:52:04', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 18:52:04', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(293, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 11:53:45', '2025-11-30 18:53:45', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 18:53:45', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(294, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 11:55:55', '2025-11-30 18:55:55', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 18:55:55', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(295, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 11:57:36', '2025-11-30 18:57:36', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 18:57:36', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(296, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 11:58:54', '2025-11-30 18:58:54', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 18:58:54', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(297, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 12:00:24', '2025-11-30 19:00:24', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:00:24', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(298, 277, NULL, NULL, 'Converted PDF', 'Converted PDF', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/converted_1764498547746.pdf', '2025-11-30 12:01:07', '2025-11-30 19:01:07', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:01:07', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(299, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 12:02:54', '2025-11-30 19:02:54', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:02:54', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(300, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.pdf', '2025-11-30 12:10:49', '2025-11-30 19:10:49', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:10:49', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(301, 277, NULL, 171, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1biar1qStbXNLBUfxcHpkYfPGfgNSIK3pwoeUWdKIezA/edit', 3, NULL, '2025-11-30 12:21:00', '2025-11-30 19:21:00', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:21:00', 'google_drive', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 7, '1biar1qStbXNLBUfxcHpkYfPGfgNSIK3pwoeUWdKIezA'),
(302, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1biar1qStbXNLBUfxcHpkYfPGfgNSIK3pwoeUWdKIezA/edit', '2025-11-30 12:21:00', '2025-11-30 19:21:01', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-11-30 19:21:01', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(303, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-1.pdf', '2025-11-30 12:22:21', '2025-11-30 19:22:21', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:22:21', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(304, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 12:22:48', '2025-11-30 19:22:48', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:22:48', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(305, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 12:25:24', '2025-11-30 19:25:24', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:25:24', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(306, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 12:27:19', '2025-11-30 19:27:19', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:27:19', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(307, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 12:31:49', '2025-11-30 19:31:49', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:31:49', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(308, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 12:32:35', '2025-11-30 19:32:35', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:32:35', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(309, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 12:34:32', '2025-11-30 19:34:32', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 19:34:32', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(310, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 13:07:42', '2025-11-30 20:07:42', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 20:07:42', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(311, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 13:11:15', '2025-11-30 20:11:15', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 20:11:15', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(312, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 13:12:59', '2025-11-30 20:12:59', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 20:12:59', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(313, 277, NULL, NULL, 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', 'Converted_20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.pdf', NULL, 3, 'https://assets.develop.io.vn/wp-content/uploads/2025/11/Converted_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01-2.pdf', '2025-11-30 13:13:29', '2025-11-30 20:13:29', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-11-30 20:13:29', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(314, 277, NULL, 173, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1PBtCttcC_CA67XpMpN536mdUJfMO6LxlgABmmAZes0o/edit', 3, NULL, '2025-12-01 01:30:30', '2025-12-02 23:52:20', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 8, '1PBtCttcC_CA67XpMpN536mdUJfMO6LxlgABmmAZes0o'),
(315, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1PBtCttcC_CA67XpMpN536mdUJfMO6LxlgABmmAZes0o/edit', '2025-12-01 01:30:30', '2025-12-01 08:30:31', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-01 08:30:31', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(316, 279, NULL, 174, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/192fjz_J4k0S-7bjCSGEPxUBvjY3-Z8M2nQbQLNU9mSU/edit', 3, NULL, '2025-12-01 04:30:09', '2025-12-01 11:30:09', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-01 11:30:09', 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 1, '192fjz_J4k0S-7bjCSGEPxUBvjY3-Z8M2nQbQLNU9mSU'),
(317, 279, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/192fjz_J4k0S-7bjCSGEPxUBvjY3-Z8M2nQbQLNU9mSU/edit', '2025-12-01 04:30:09', '2025-12-01 11:30:09', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-01 11:30:09', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(318, 278, NULL, 175, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1-Z86_obmMpUTuI8fC5LCx--MCX_bGHlyW48DUhv9SPk/edit', 3, NULL, '2025-12-01 04:33:13', '2025-12-01 11:33:13', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-01 11:33:13', 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 1, '1-Z86_obmMpUTuI8fC5LCx--MCX_bGHlyW48DUhv9SPk'),
(319, 278, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1-Z86_obmMpUTuI8fC5LCx--MCX_bGHlyW48DUhv9SPk/edit', '2025-12-01 04:33:13', '2025-12-01 11:33:14', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-01 11:33:14', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(320, 277, NULL, 176, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1ca4UACqSTFVgmiqqGYTnjnHaatXvpjfhgUtFBnkpXPs/edit', 5, NULL, '2025-12-01 06:33:03', '2025-12-02 23:52:13', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 9, '1ca4UACqSTFVgmiqqGYTnjnHaatXvpjfhgUtFBnkpXPs'),
(321, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 5, 'https://docs.google.com/document/d/1ca4UACqSTFVgmiqqGYTnjnHaatXvpjfhgUtFBnkpXPs/edit', '2025-12-01 06:33:04', '2025-12-01 13:33:04', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-01 13:33:04', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(322, 277, NULL, 177, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1OUEUB5-t1BXSpRkyzBThF3UwDuOgtSSAfuKzTHYCDwc/edit', 5, NULL, '2025-12-01 06:33:46', '2025-12-02 23:52:13', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 10, '1OUEUB5-t1BXSpRkyzBThF3UwDuOgtSSAfuKzTHYCDwc'),
(323, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 5, 'https://docs.google.com/document/d/1OUEUB5-t1BXSpRkyzBThF3UwDuOgtSSAfuKzTHYCDwc/edit', '2025-12-01 06:33:47', '2025-12-01 13:33:47', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-01 13:33:47', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(324, 277, NULL, 178, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/12_JhQGxwd-N56g6IXQkTRvpfEidwssqcxRng9K45Dc4/edit', 3, NULL, '2025-12-01 08:45:55', '2025-12-02 23:52:12', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 11, '12_JhQGxwd-N56g6IXQkTRvpfEidwssqcxRng9K45Dc4'),
(325, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/12_JhQGxwd-N56g6IXQkTRvpfEidwssqcxRng9K45Dc4/edit', '2025-12-01 08:45:55', '2025-12-01 15:45:55', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-01 15:45:55', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(326, 277, NULL, 179, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1FNx4Awz8CH7d6jy2yjKBwpJdNQwOyrzozOcx9H4UKi0/edit', 3, NULL, '2025-12-02 01:11:49', '2025-12-02 23:52:12', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 12, '1FNx4Awz8CH7d6jy2yjKBwpJdNQwOyrzozOcx9H4UKi0'),
(327, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1FNx4Awz8CH7d6jy2yjKBwpJdNQwOyrzozOcx9H4UKi0/edit', '2025-12-02 01:11:49', '2025-12-02 08:11:50', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 08:11:50', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(328, 277, NULL, 180, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1I4cuF0Mrv5h_jAvQtOfcqFPEswk0kKSNbwsh_ixtZRs/edit', 4, NULL, '2025-12-02 02:10:16', '2025-12-02 23:52:12', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 13, '1I4cuF0Mrv5h_jAvQtOfcqFPEswk0kKSNbwsh_ixtZRs'),
(329, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 4, 'https://docs.google.com/document/d/1I4cuF0Mrv5h_jAvQtOfcqFPEswk0kKSNbwsh_ixtZRs/edit', '2025-12-02 02:10:17', '2025-12-02 09:10:17', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 09:10:17', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(330, 277, NULL, 181, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1Dxc6PptwgzMtg0ak_62m1L3L4ROafgsuPr4q8M81cBc/edit', 5, NULL, '2025-12-02 02:47:33', '2025-12-02 23:52:12', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 14, '1Dxc6PptwgzMtg0ak_62m1L3L4ROafgsuPr4q8M81cBc'),
(331, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 5, 'https://docs.google.com/document/d/1Dxc6PptwgzMtg0ak_62m1L3L4ROafgsuPr4q8M81cBc/edit', '2025-12-02 02:47:33', '2025-12-02 09:47:33', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 09:47:33', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(332, 277, NULL, 182, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1igpoRsducNtJhHsm58ZeG8MQKqM1B1MdDm3W_qmVsLk/edit', 3, NULL, '2025-12-02 03:27:07', '2025-12-02 23:52:12', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 95744, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 15, '1igpoRsducNtJhHsm58ZeG8MQKqM1B1MdDm3W_qmVsLk'),
(333, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1igpoRsducNtJhHsm58ZeG8MQKqM1B1MdDm3W_qmVsLk/edit', '2025-12-02 03:27:08', '2025-12-02 10:27:08', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 10:27:08', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(334, 277, NULL, 183, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/19K-9eRvjQJlvJRPDndQawkprluRZitE2YVb7ZAk3NkI/edit', 5, NULL, '2025-12-02 03:43:39', '2025-12-02 23:52:12', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 96256, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 16, '19K-9eRvjQJlvJRPDndQawkprluRZitE2YVb7ZAk3NkI'),
(335, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 5, 'https://docs.google.com/document/d/19K-9eRvjQJlvJRPDndQawkprluRZitE2YVb7ZAk3NkI/edit', '2025-12-02 03:43:39', '2025-12-02 10:43:39', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 10:43:39', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(336, 277, NULL, 184, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1pYiBSQ7NrFMawVP4x_vJawCVjjqMHufHCB71KWm92BI/edit', 1, NULL, '2025-12-02 03:52:29', '2025-12-02 23:52:11', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 17, '1pYiBSQ7NrFMawVP4x_vJawCVjjqMHufHCB71KWm92BI'),
(337, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 1, 'https://docs.google.com/document/d/1pYiBSQ7NrFMawVP4x_vJawCVjjqMHufHCB71KWm92BI/edit', '2025-12-02 03:52:29', '2025-12-02 10:52:30', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 10:52:30', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(338, 277, NULL, 185, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1yICuh4SfZig46mTVG380l_ocMxzMY03lLVEujWqwbaU/edit', 1, NULL, '2025-12-02 03:53:42', '2025-12-02 23:52:11', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 18, '1yICuh4SfZig46mTVG380l_ocMxzMY03lLVEujWqwbaU'),
(339, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 1, 'https://docs.google.com/document/d/1yICuh4SfZig46mTVG380l_ocMxzMY03lLVEujWqwbaU/edit', '2025-12-02 03:53:42', '2025-12-02 10:53:43', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 10:53:43', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(340, 277, NULL, 186, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/18QR9k7d2zkKLWDUSg4ODYJTdebQXMISMlomP-VYbWAU/edit', 3, NULL, '2025-12-02 04:33:18', '2025-12-02 23:52:11', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 19, '18QR9k7d2zkKLWDUSg4ODYJTdebQXMISMlomP-VYbWAU'),
(341, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/18QR9k7d2zkKLWDUSg4ODYJTdebQXMISMlomP-VYbWAU/edit', '2025-12-02 04:33:19', '2025-12-02 11:33:19', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 11:33:19', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(342, 277, NULL, 187, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1LYAr2mkQ45xxfU3-EZFhx61_H8reoYDGYrau9hmfnjw/edit', 3, NULL, '2025-12-02 04:39:57', '2025-12-02 23:52:11', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 20, '1LYAr2mkQ45xxfU3-EZFhx61_H8reoYDGYrau9hmfnjw'),
(343, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1LYAr2mkQ45xxfU3-EZFhx61_H8reoYDGYrau9hmfnjw/edit', '2025-12-02 04:39:57', '2025-12-02 11:39:57', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 11:39:57', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(344, 277, NULL, 188, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/11ZNPSKCqE9gqyECOj-Yruj5XmVGkBPvyC3J-rjecSms/edit', 3, NULL, '2025-12-02 04:52:10', '2025-12-02 23:52:10', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 21, '11ZNPSKCqE9gqyECOj-Yruj5XmVGkBPvyC3J-rjecSms'),
(345, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/11ZNPSKCqE9gqyECOj-Yruj5XmVGkBPvyC3J-rjecSms/edit', '2025-12-02 04:52:11', '2025-12-02 11:52:12', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 11:52:12', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(346, 277, NULL, 189, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1V_ZcBUqz-L5KqSPyoUef89R6PwYf_oOXubEv_9z40iE/edit', 3, NULL, '2025-12-02 06:06:09', '2025-12-02 23:52:10', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 22, '1V_ZcBUqz-L5KqSPyoUef89R6PwYf_oOXubEv_9z40iE'),
(347, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1V_ZcBUqz-L5KqSPyoUef89R6PwYf_oOXubEv_9z40iE/edit', '2025-12-02 06:06:09', '2025-12-02 13:06:09', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 13:06:09', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(348, 277, NULL, 190, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1xDoaJh2Wd8GzaYSEiewnj-KH9Lu4tuwm-f1g9FL6Jns/edit', 1, NULL, '2025-12-02 07:08:13', '2025-12-02 23:52:15', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 23, '1xDoaJh2Wd8GzaYSEiewnj-KH9Lu4tuwm-f1g9FL6Jns'),
(349, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 1, 'https://docs.google.com/document/d/1xDoaJh2Wd8GzaYSEiewnj-KH9Lu4tuwm-f1g9FL6Jns/edit', '2025-12-02 07:08:13', '2025-12-02 14:08:13', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 14:08:13', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(350, 277, NULL, 191, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1gWeXF8PEvX86_Tkyrj5ssfSQNt89HL25g142q6krGzU/edit', 1, NULL, '2025-12-02 07:11:10', '2025-12-02 23:52:09', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 24, '1gWeXF8PEvX86_Tkyrj5ssfSQNt89HL25g142q6krGzU'),
(351, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 1, 'https://docs.google.com/document/d/1gWeXF8PEvX86_Tkyrj5ssfSQNt89HL25g142q6krGzU/edit', '2025-12-02 07:11:10', '2025-12-02 14:11:10', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 14:11:10', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(352, 277, NULL, 192, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1F2yEeKki0kCc7i6sD_hGbAPo73hchyl8yK5Old30giw/edit', 1, NULL, '2025-12-02 07:24:06', '2025-12-02 23:52:19', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 25, '1F2yEeKki0kCc7i6sD_hGbAPo73hchyl8yK5Old30giw'),
(353, 277, NULL, 192, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/13nWfEsimjrGJoOEDNXlFgCTFh7tFeRHQpYmEUa709N0/edit', 1, NULL, '2025-12-02 07:24:12', '2025-12-02 23:52:16', 0, '', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 25, '13nWfEsimjrGJoOEDNXlFgCTFh7tFeRHQpYmEUa709N0'),
(354, 277, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 1, 'https://docs.google.com/document/d/1F2yEeKki0kCc7i6sD_hGbAPo73hchyl8yK5Old30giw/edit', '2025-12-02 07:24:12', '2025-12-02 14:24:12', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 14:24:12', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(355, 277, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 1, 'https://docs.google.com/spreadsheets/d/13nWfEsimjrGJoOEDNXlFgCTFh7tFeRHQpYmEUa709N0/edit', '2025-12-02 07:24:13', '2025-12-02 14:24:13', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-02 14:24:13', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(356, 277, NULL, 195, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1ov9IS-v5YtGb66JxIeyuHB8BxoqB36pByJ3Qr9vqmiw/edit', 1, NULL, '2025-12-02 17:00:37', '2025-12-03 00:00:37', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 1, '2025-12-03 00:00:37', 'google_drive', 315365, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 25, '1ov9IS-v5YtGb66JxIeyuHB8BxoqB36pByJ3Qr9vqmiw'),
(357, 277, NULL, NULL, '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', '20251008_PLTTr HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 1, 'https://docs.google.com/spreadsheets/d/1ov9IS-v5YtGb66JxIeyuHB8BxoqB36pByJ3Qr9vqmiw/edit', '2025-12-02 17:00:37', '2025-12-03 00:00:38', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-03 00:00:38', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(358, 312, NULL, 196, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/15ZkYL_xMWa7x7yOgf0nNtKK0PBJ0Koq_xMtMnNOAvGE/edit', 3, NULL, '2025-12-03 07:21:07', '2025-12-03 14:21:07', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:21:07', 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 1, '15ZkYL_xMWa7x7yOgf0nNtKK0PBJ0Koq_xMtMnNOAvGE'),
(359, 312, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/15ZkYL_xMWa7x7yOgf0nNtKK0PBJ0Koq_xMtMnNOAvGE/edit', '2025-12-03 07:21:07', '2025-12-03 14:21:08', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-03 14:21:08', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(360, 312, NULL, 197, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso/edit', 3, NULL, '2025-12-03 07:25:02', '2025-12-03 14:25:02', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:25:02', 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 2, '17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso');
INSERT INTO `task_files` (`id`, `task_id`, `document_id`, `comment_id`, `file_name`, `title`, `file_path`, `uploaded_by`, `link_url`, `created_at`, `updated_at`, `is_link`, `status`, `approved_by`, `approved_at`, `review_note`, `approvals_json`, `is_pinned`, `pinned_rank`, `pinned_by`, `pinned_at`, `file_type`, `file_size`, `mime_type`, `file_ext`, `wp_media_id`, `source`, `department_id`, `visibility`, `tags`, `upload_batch`, `google_file_id`) VALUES
(361, 312, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso/edit', '2025-12-03 07:25:02', '2025-12-03 14:25:02', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-03 14:25:02', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(362, 311, NULL, 198, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', 'https://docs.google.com/document/d/1rWWE3lnZwvcu-T_9gPj6u-SBi51RiYoBIZXGgLI978Y/edit', 3, NULL, '2025-12-03 07:28:52', '2025-12-03 14:28:52', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:28:52', 'google_drive', 98304, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 1, '1rWWE3lnZwvcu-T_9gPj6u-SBi51RiYoBIZXGgLI978Y'),
(363, 311, NULL, NULL, '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', '20251008_TTrHCNS_GiahanphanmemMicrosoft 365 T01.doc', NULL, 3, 'https://docs.google.com/document/d/1rWWE3lnZwvcu-T_9gPj6u-SBi51RiYoBIZXGgLI978Y/edit', '2025-12-03 07:28:52', '2025-12-03 14:28:53', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-03 14:28:53', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(364, 311, NULL, 199, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1fcQpS6nm6U65dRm0FZwjI02kxQZMs_Iqw1_aqfvJYpU/edit', 3, NULL, '2025-12-03 07:31:58', '2025-12-03 14:31:58', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:31:58', 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 2, '1fcQpS6nm6U65dRm0FZwjI02kxQZMs_Iqw1_aqfvJYpU'),
(365, 311, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1fcQpS6nm6U65dRm0FZwjI02kxQZMs_Iqw1_aqfvJYpU/edit', '2025-12-03 07:31:58', '2025-12-03 14:31:58', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-03 14:31:58', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(366, 311, NULL, 200, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1S9K2vKUVkJCMvslJqjnuWsQk_Ho3abS3C4J1HE0K8wg/edit', 3, NULL, '2025-12-03 07:38:17', '2025-12-03 14:38:17', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:38:17', 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 3, '1S9K2vKUVkJCMvslJqjnuWsQk_Ho3abS3C4J1HE0K8wg'),
(367, 311, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1S9K2vKUVkJCMvslJqjnuWsQk_Ho3abS3C4J1HE0K8wg/edit', '2025-12-03 07:38:18', '2025-12-03 14:38:18', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-03 14:38:18', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(368, 311, NULL, 201, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/11K1mssbDnLCJLuKtjqBv_dngTsHHT_IZXNO6W-1CavI/edit', 3, NULL, '2025-12-03 07:47:37', '2025-12-03 14:47:37', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:47:37', 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 4, '11K1mssbDnLCJLuKtjqBv_dngTsHHT_IZXNO6W-1CavI'),
(369, 311, NULL, 202, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1rJFYoVh2YpuCcuDLS4oo2qk3kAoTj8KDG0GxLZWWWIk/edit', 3, NULL, '2025-12-03 07:48:45', '2025-12-03 14:48:45', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:48:45', 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 5, '1rJFYoVh2YpuCcuDLS4oo2qk3kAoTj8KDG0GxLZWWWIk'),
(370, 311, NULL, 203, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo/edit', 3, NULL, '2025-12-03 07:49:34', '2025-12-03 14:49:34', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:49:34', 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 6, '1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo'),
(371, 311, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo/edit', '2025-12-03 07:49:34', '2025-12-03 14:49:34', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-03 14:49:34', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL),
(372, 312, NULL, 204, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit', 3, NULL, '2025-12-03 07:51:58', '2025-12-03 14:51:58', 0, '', NULL, NULL, NULL, NULL, 1, NULL, 3, '2025-12-03 14:51:58', 'google_drive', 318161, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, 3, '1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0'),
(373, 312, NULL, NULL, 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', 'a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx', NULL, 3, 'https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit', '2025-12-03 07:51:58', '2025-12-03 14:51:58', 1, '', NULL, NULL, NULL, NULL, 1, NULL, 0, '2025-12-03 14:51:58', 'wp_media', 0, NULL, NULL, NULL, 'wordpress', NULL, 'private', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `task_notifications`
--

CREATE TABLE `task_notifications` (
  `id` int NOT NULL,
  `task_id` int NOT NULL,
  `user_id` int NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('pending','sent','failed') COLLATE utf8mb4_unicode_ci DEFAULT 'pending',
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `sent_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task_roster`
--

CREATE TABLE `task_roster` (
  `id` int UNSIGNED NOT NULL,
  `task_id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `role` enum('approve','sign') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'approve' COMMENT 'vai trò: duyệt hoặc ký',
  `status` enum('processing','approved','rejected') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'processing',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Tên người tại thời điểm thêm',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_roster`
--

INSERT INTO `task_roster` (`id`, `task_id`, `user_id`, `role`, `status`, `name`, `created_at`, `updated_at`) VALUES
(420, 277, 3, 'approve', 'processing', 'Đinh Văn Vịnh', '2025-11-29 14:14:13', '2025-12-03 00:00:37'),
(438, 279, 3, 'approve', 'processing', 'Đinh Văn Vịnh', '2025-12-01 11:30:09', '2025-12-01 11:30:09'),
(439, 279, 1, 'approve', 'processing', 'Nguyễn Cảnh Hợp', '2025-12-01 11:30:09', '2025-12-01 11:30:09'),
(440, 278, 3, 'approve', 'processing', 'Đinh Văn Vịnh', '2025-12-01 11:33:13', '2025-12-01 11:33:13'),
(441, 278, 12, 'approve', 'processing', 'Nguyễn Thị Ngọc Anh', '2025-12-01 11:33:13', '2025-12-01 11:33:13'),
(460, 312, 3, 'approve', 'processing', 'Đinh Văn Vịnh', '2025-12-03 14:21:07', '2025-12-03 14:51:58'),
(461, 312, 5, 'approve', 'processing', 'Nguyễn Văn Chiểu', '2025-12-03 14:21:07', '2025-12-03 14:51:58'),
(462, 312, 9, 'approve', 'processing', 'Nguyễn Danh Vương Bình', '2025-12-03 14:21:07', '2025-12-03 14:51:58'),
(463, 312, 14, 'approve', 'processing', 'Nguyễn Thị Hạnh', '2025-12-03 14:21:07', '2025-12-03 14:51:58'),
(464, 312, 15, 'approve', 'processing', 'Trần Thị Hiền', '2025-12-03 14:21:07', '2025-12-03 14:51:58'),
(470, 311, 3, 'approve', 'processing', 'Đinh Văn Vịnh', '2025-12-03 14:28:52', '2025-12-03 14:49:34');

-- --------------------------------------------------------

--
-- Table structure for table `task_sign_logs`
--

CREATE TABLE `task_sign_logs` (
  `id` int UNSIGNED NOT NULL,
  `task_id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `file_id` int UNSIGNED NOT NULL,
  `google_file_id` varchar(255) DEFAULT NULL,
  `signed_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `task_sign_logs`
--

INSERT INTO `task_sign_logs` (`id`, `task_id`, `user_id`, `file_id`, `google_file_id`, `signed_at`) VALUES
(1, 277, 3, 156, '1qpuIaXVw2F0e4p-8mDzekVUpRexXxNgSWlyHTcG82Xc', '2025-11-29 23:58:19'),
(2, 277, 3, 157, '1xI96iJtkE__BLX44hqYVy_dsf16YsxGEK6grrgYwJwc', '2025-11-29 23:58:21'),
(3, 277, 3, 158, '1wlolxhu-exhf4X6J-RFtzE6hIASsKYAYdx5J1Uygee8', '2025-11-30 00:01:55'),
(4, 277, 3, 160, '1ugj7qDZ12gBjRvHXWMboMgBi44hCKgRadBlU4QO7oKo', '2025-11-30 00:07:57'),
(5, 277, 3, 162, '1RVwQzKv6PA8SAEA9jvFjuQhoZEM_28PdUgOwX1-FFLs', '2025-11-30 00:12:46'),
(6, 277, 3, 163, '1XxvSnG9KK7Alb7gzvstjf3-1NeEA5-8K5Mb8M-Tsg8Y', '2025-11-30 00:14:17'),
(7, 277, 3, 164, '1gp8xhdQZUo3t2kibxieiedN_BENj3xLDENKT30q8qso', '2025-11-30 00:22:58'),
(8, 277, 3, 165, '1qRwywIqXU9WdXG9hjJKVe5UoI5g57opYfDbrK9SCnnY', '2025-11-30 00:23:01'),
(9, 277, 3, 166, '13eyvv6Q6Sqyayenltk5AzekAl-YR8CmIrN6tWcz0yCo', '2025-11-30 00:25:52'),
(10, 277, 3, 168, '1I5n7sh_IqBUxpDZkiC-Ph-8R6Szfn8SmT2z7DnamCNI', '2025-11-30 00:41:48'),
(11, 277, 3, 169, '1lpItOKm6PwUGvTf1XEC-MwWNjzhFurWcf92L8vN69kI', '2025-11-30 00:52:49'),
(12, 277, 3, 170, '1uV2F84GWVQvobRY5cjidjxOvwRDWcuoCewl-qb_SNYE', '2025-11-30 00:54:33'),
(13, 277, 3, 171, '1leWOrh81KcE2FinI7r2gURFGjJt2-7BHxt-hGPTYN3g', '2025-11-30 09:33:56'),
(14, 277, 3, 173, '19IH5evi9RsXKwqs0u6fhjs9I1cm69zoqNwWzT7o5ieg', '2025-11-30 09:48:50'),
(15, 277, 3, 175, '1uHtpcu7lbsnr-b-zVkjrwpJvuLoolex0NmkXG_h7coE', '2025-11-30 09:57:47');

-- --------------------------------------------------------

--
-- Table structure for table `task_snapshots`
--

CREATE TABLE `task_snapshots` (
  `id` bigint UNSIGNED NOT NULL,
  `task_id` bigint UNSIGNED NOT NULL,
  `snapshot_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `priority` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approval_status` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `progress` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `collaborated_by` int DEFAULT NULL,
  `assigned_by` int DEFAULT NULL,
  `proposed_by` int DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `approval_roster_json` json DEFAULT NULL,
  `latest_upload_batch` int DEFAULT NULL,
  `latest_files_json` json DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `task_snapshots`
--

INSERT INTO `task_snapshots` (`id`, `task_id`, `snapshot_at`, `title`, `description`, `start_date`, `end_date`, `status`, `priority`, `approval_status`, `progress`, `assigned_to`, `collaborated_by`, `assigned_by`, `proposed_by`, `created_by`, `approval_roster_json`, `latest_upload_batch`, `latest_files_json`, `created_at`, `updated_at`) VALUES
(1, 311, '2025-12-03 13:56:09', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', 'doing', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[]', NULL, NULL, '2025-12-03 13:56:09', '2025-12-03 13:56:09'),
(2, 312, '2025-12-03 13:56:31', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[]', NULL, NULL, '2025-12-03 13:56:31', '2025-12-03 13:56:31'),
(3, 312, '2025-12-03 13:57:02', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[]', NULL, NULL, '2025-12-03 13:57:02', '2025-12-03 13:57:02'),
(4, 312, '2025-12-03 14:09:58', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}]', NULL, NULL, '2025-12-03 14:09:58', '2025-12-03 14:09:58'),
(5, 312, '2025-12-03 14:10:03', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', NULL, '[]', '2025-12-03 14:10:03', '2025-12-03 14:10:03'),
(6, 312, '2025-12-03 14:24:47', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 1, '[{\"id\": \"203\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/15ZkYL_xMWa7x7yOgf0nNtKK0PBJ0Koq_xMtMnNOAvGE/edit\", \"file_size\": \"318161\", \"google_file_id\": \"15ZkYL_xMWa7x7yOgf0nNtKK0PBJ0Koq_xMtMnNOAvGE\"}]', '2025-12-03 14:24:47', '2025-12-03 14:24:47'),
(7, 312, '2025-12-03 14:26:04', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 2, '[{\"id\": \"204\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso/edit\", \"file_size\": \"318161\", \"google_file_id\": \"17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso\"}]', '2025-12-03 14:26:04', '2025-12-03 14:26:04'),
(8, 311, '2025-12-03 14:28:32', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', 'doing', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[]', NULL, '[]', '2025-12-03 14:28:32', '2025-12-03 14:28:32'),
(9, 311, '2025-12-03 14:28:40', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', 'doing', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:28:40\"}]', NULL, '[]', '2025-12-03 14:28:40', '2025-12-03 14:28:40'),
(10, 311, '2025-12-03 14:47:24', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', 'doing', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:28:40\"}]', 3, '[{\"id\": \"207\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1S9K2vKUVkJCMvslJqjnuWsQk_Ho3abS3C4J1HE0K8wg/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1S9K2vKUVkJCMvslJqjnuWsQk_Ho3abS3C4J1HE0K8wg\"}]', '2025-12-03 14:47:24', '2025-12-03 14:47:24'),
(11, 311, '2025-12-03 14:49:20', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', 'doing', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:28:40\"}]', 5, '[{\"id\": \"209\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1rJFYoVh2YpuCcuDLS4oo2qk3kAoTj8KDG0GxLZWWWIk/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1rJFYoVh2YpuCcuDLS4oo2qk3kAoTj8KDG0GxLZWWWIk\"}]', '2025-12-03 14:49:20', '2025-12-03 14:49:20'),
(12, 311, '2025-12-03 14:49:34', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', 'doing', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:28:40\"}]', 6, '[{\"id\": \"210\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo\"}]', '2025-12-03 14:49:34', '2025-12-03 14:49:34'),
(13, 311, '2025-12-03 14:51:41', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', 'doing', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:28:40\"}]', 6, '[{\"id\": \"210\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo\"}]', '2025-12-03 14:51:41', '2025-12-03 14:51:41'),
(14, 312, '2025-12-03 14:51:45', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 2, '[{\"id\": \"204\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso/edit\", \"file_size\": \"318161\", \"google_file_id\": \"17GnBXh2E4mpCkWoAUK52-Y10gDcgg_E5hlAsSx8Gtso\"}]', '2025-12-03 14:51:45', '2025-12-03 14:51:45'),
(15, 312, '2025-12-03 14:51:58', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 14:51:58', '2025-12-03 14:51:58'),
(16, 311, '2025-12-03 15:02:12', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', 'doing', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:28:40\"}]', 6, '[{\"id\": \"210\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1X9PRipxuDt4IyySzzvEiJXaQGOh2BT0y1yS7oIH0oeo\"}]', '2025-12-03 15:02:12', '2025-12-03 15:02:12'),
(17, 312, '2025-12-03 15:02:18', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 15:02:18', '2025-12-03 15:02:18'),
(18, 312, '2025-12-03 15:02:47', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 15:02:47', '2025-12-03 15:02:47'),
(19, 312, '2025-12-03 15:08:31', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 15:08:31', '2025-12-03 15:08:31'),
(20, 312, '2025-12-03 15:17:03', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 15:17:03', '2025-12-03 15:17:03'),
(21, 312, '2025-12-03 15:17:13', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 15:17:13', '2025-12-03 15:17:13'),
(22, 312, '2025-12-03 15:17:31', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 5, \"acted_at\": null, \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 3, \"acted_at\": null, \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 9, \"acted_at\": null, \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 14, \"acted_at\": null, \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 15, \"acted_at\": null, \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 15:17:32', '2025-12-03 15:17:32'),
(23, 312, '2025-12-03 15:17:45', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 5, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 14, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 15, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 15:17:45', '2025-12-03 15:17:45'),
(24, 312, '2025-12-03 16:09:24', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 5, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 14, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 15, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:10:03\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 16:09:24', '2025-12-03 16:09:24'),
(25, 312, '2025-12-03 16:09:30', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 5, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 14, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 15, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:10:03\"}, {\"name\": \"Hoàng Văn Dũng\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 8, \"acted_at\": null, \"added_at\": \"2025-12-03 16:09:30\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 16:09:30', '2025-12-03 16:09:30'),
(26, 312, '2025-12-03 16:16:20', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 5, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 14, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 15, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:10:03\"}, {\"name\": \"Hoàng Văn Dũng\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 8, \"acted_at\": null, \"added_at\": \"2025-12-03 16:09:30\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 16:16:20', '2025-12-03 16:16:20'),
(27, 312, '2025-12-03 16:16:35', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 5, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 14, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 15, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:10:03\"}, {\"name\": \"Hoàng Văn Dũng\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 8, \"acted_at\": null, \"added_at\": \"2025-12-03 16:09:30\"}, {\"name\": \"Vũ Thị Thuỷ\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 10, \"acted_at\": null, \"added_at\": \"2025-12-03 16:16:35\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 16:16:35', '2025-12-03 16:16:35'),
(28, 312, '2025-12-03 16:23:06', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 5, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 14, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 15, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:10:03\"}, {\"name\": \"Hoàng Văn Dũng\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 8, \"acted_at\": null, \"added_at\": \"2025-12-03 16:09:30\"}, {\"name\": \"Vũ Thị Thuỷ\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 10, \"acted_at\": null, \"added_at\": \"2025-12-03 16:16:35\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 16:23:06', '2025-12-03 16:23:06'),
(29, 312, '2025-12-03 16:23:46', 'nhiệm vụ mới 03-12-2025 xxxx', 'ok', '2025-12-03', '2026-01-31', '', 'normal', 'pending', 0, 3, 7, NULL, 3, 3, '[{\"name\": \"Nguyễn Văn Chiểu\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 5, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:02:41\"}, {\"name\": \"Đinh Văn Vịnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 3, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:01:23\"}, {\"name\": \"Nguyễn Danh Vương Bình\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 9, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:07:11\"}, {\"name\": \"Nguyễn Thị Hạnh\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 14, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:08:50\"}, {\"name\": \"Trần Thị Hiền\", \"note\": null, \"role\": \"approve\", \"status\": \"approved\", \"user_id\": 15, \"acted_at\": \"2025-12-03 08:17:45\", \"added_at\": \"2025-12-03 14:10:03\"}, {\"name\": \"Hoàng Văn Dũng\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 8, \"acted_at\": null, \"added_at\": \"2025-12-03 16:09:30\"}, {\"name\": \"Vũ Thị Thuỷ\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 10, \"acted_at\": null, \"added_at\": \"2025-12-03 16:16:35\"}, {\"name\": \"Nguyễn Cảnh Hợp\", \"note\": null, \"role\": \"approve\", \"status\": \"pending\", \"user_id\": 7, \"acted_at\": null, \"added_at\": \"2025-12-03 16:23:46\"}]', 3, '[{\"id\": \"211\", \"title\": \"a_20251008_PLTTr-HCNS_DanhmuchanghoadichvuT01.xlsx\", \"file_path\": \"https://docs.google.com/spreadsheets/d/1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0/edit\", \"file_size\": \"318161\", \"google_file_id\": \"1oFuV_S2omEHbUXL7nJf-HMVQgtwdnWmQSh7nIfP7Tb0\"}]', '2025-12-03 16:23:46', '2025-12-03 16:23:46');

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
  `signature_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `preferred_marker` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `approval_marker` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `department_id` int DEFAULT NULL,
  `role_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `created_at`, `updated_at`, `name`, `phone`, `avatar`, `signature_url`, `preferred_marker`, `approval_marker`, `role`, `department_id`, `role_id`) VALUES
(1, 'thuy.luong@ttid.com.vn', '$2y$10$znGt22AodklURvc9mdHUfOK/vzj4s9IR0XCzpPIXfUs.FZj7/ABoy', '2025-04-07 18:49:01', '2025-12-02 22:56:55', 'Lương Đức Thuỷ', '0982240842', 'uploads/avatars/1764690034_cb385e2bc057c6d032b1.jpg', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', 'luongducthuy', 'luong_duc_thuy', 'super admin', 6, 1),
(3, 'info@ttid.com.vn', '$2y$10$duTynUTzT2E8r/XfWDEAv.zruGL1CwtgiFyHoBybvwd8valutSCTW', '2025-04-20 14:02:38', '2025-12-02 22:43:42', 'Đinh Văn Vịnh', '0989268613', 'uploads/avatars/1764690219_07aa7e6ea0e0c0116def.jpg', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10-1.jpg', 'dinhvanvinh', 'dinh_van_vinh', 'super admin', 1, 1),
(4, 'tho.ta@ttid.com.vn', '$2y$10$X0AYs8k7Dw8fbMqF9DzxiuBhQzGzu.ehudtC.2SWOjA4tsTZK0sYG', '2025-05-26 04:33:21', '2025-12-02 22:57:15', 'Tạ Quý Thọ', '0979412583', 'uploads/avatars/1764690599_336c8efbddc85f1c45c0.jpg', 'https://assets.develop.io.vn/wp-content/uploads/2025/11/photo_2025-10-17_10-09-07-1.jpg', 'taquytho', 'ta_quy_tho', 'admin', 3, 2),
(5, 'chieu.nguyenvan@ttid.com.vn', '$2y$10$MBmxJ.v7/6kO6HaPIDcRE.dsGApBjLkWGyF655SlW5gCBMeaCHrNe', '2025-06-04 09:10:50', '2025-12-02 23:00:18', 'Nguyễn Văn Chiểu', '0985412304', 'uploads/avatars/1764691177_7043e7f581526b0bab4a.jpg', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-04-1.jpg', 'nguyenvanchieu', 'nguyen_van_chieu', 'admin', 3, 2),
(6, 'b@worknest.vn', '$2y$10$ZKKb/DZ/dk0eFQW/xfG3Ne8Ozrdt1TcQcR1alq4KP5biJpmUm2Uuy', '2025-06-04 09:11:21', '2025-11-29 13:33:58', 'Phạm Xuân Tuân', '0911111112', NULL, 'https://assets.develop.io.vn/wp-content/uploads/2025/10/z7010742803776_61e4e0e6d2380894deeebfd1b1d5d8c0.jpg', 'phamxuantuan', 'pham_xuan_tuan', 'user', 3, 2),
(7, 'hop.nguyen@ttid.com.vn', '$2y$10$jh.Bqbz9rG5INlFCnuvo9uiL/.5Whd75mlamj14ZST9BCosMxt02a', '2025-06-04 09:11:44', '2025-12-02 22:48:14', 'Nguyễn Cảnh Hợp', '0973197806', 'uploads/avatars/1764690494_9a6c41da2fa1128e8b98.jpg', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-10.jpg', 'nguyencanhhop', 'nguyen_canh_hop', 'user', 6, 1),
(8, 'dung.hoang@ttid.com.vn', '$2y$10$UfmfTcnJd1Hc1wcH0Utaz.w9IFmXwNCzoFUQdahizBIri0BTfsDp2', '2025-06-04 09:12:07', '2025-12-02 23:01:24', 'Hoàng Văn Dũng', '0966140205', NULL, 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-07.jpg', 'hoangvandung', 'hoang_van_dung', 'user', 3, 3),
(9, 't@worknest.vn', '$2y$10$hGqQg.IGey/1/3a6Dt/3rOQKKdPgz2U787lWDghxeDqCmCk30v7SW', '2025-06-04 09:12:52', '2025-11-29 13:34:37', 'Nguyễn Danh Vương Bình', '0911111115', NULL, 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-09-04.jpg', 'nguyendanhvuong', 'nguyen_danh_vuong', 'user', 3, 3),
(10, 'thuy.vu@ttid.com.vn', '$2y$10$JGP3e6v4ZaWyO2CjAd6lieIt01IyZVyuJ3q95uT03kc4xUBzikxli', '2025-06-04 09:13:10', '2025-12-02 22:53:06', 'Vũ Thị Thuỷ', '0977587939', 'uploads/avatars/1764690786_c77cac7c876aea6f6990.jpg', 'https://assets.develop.io.vn/wp-content/uploads/2025/10/photo_2025-10-17_10-08-52.jpg', 'vuthithuy', 'vu_thi_thuy', 'user', 2, 1),
(11, 'h@worknest.vn', '$2y$10$HVsxejThJCOYfidLz.xreOCpRGZp8QI001kHhekDGq9tVFW0TWv0K', '2025-06-04 09:13:37', '2025-11-29 13:34:56', 'Đinh Thị Tú', '0911111117', NULL, NULL, 'dinhthitu', 'dinh_thi_tu', 'user', 2, 3),
(12, 'hq@worknest.vn', '$2y$10$eqebovRoFs2X3pAu5WRwWuQf6JF1t/72sSqOwcQsd8yR7yHA47Pa.', '2025-06-04 16:15:57', '2025-11-12 16:37:42', 'Nguyễn Thị Ngọc Anh', '0911111118', NULL, NULL, 'nguyenthingocanh', NULL, 'user', 4, 3),
(13, 'bich@worknest.vn', '$2y$10$QLmkrq1e97eFm2g59f06V.b1jy50AavfEWK8rJZBNYII1Dcd2nzKK', '2025-06-04 16:15:57', '2025-11-12 16:23:43', 'Hoàng Thị Lan Anh', '0911111119', NULL, NULL, 'hoangthilananh', NULL, 'user', 4, 3),
(14, 'tuan@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-11-06 23:41:13', 'Nguyễn Thị Hạnh', '0911111120', NULL, NULL, 'nguyenthihanh', NULL, 'user', 4, 3),
(15, 'phuc@worknest.vn', '$2y$10$kA/0rBhn7rfjCGZTk4SMKuON4RAmIxyjq0An4kLrgRAXX29ASbvi2', '2025-06-04 16:15:57', '2025-11-06 23:41:21', 'Trần Thị Hiền', '0911111121', NULL, NULL, 'tranthihien', NULL, 'user', 1, 3);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `approval_instances`
--
ALTER TABLE `approval_instances`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_target_active` (`target_type`,`target_id`,`is_active`),
  ADD UNIQUE KEY `uq_target_version` (`target_type`,`target_id`,`version`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_current_level` (`current_level`);

--
-- Indexes for table `approval_logs`
--
ALTER TABLE `approval_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_instance` (`approval_instance_id`);

--
-- Indexes for table `approval_reads`
--
ALTER TABLE `approval_reads`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_step` (`user_id`,`step_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_step` (`step_id`);

--
-- Indexes for table `approval_steps`
--
ALTER TABLE `approval_steps`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_instance_level` (`approval_instance_id`,`level`),
  ADD KEY `idx_instance` (`approval_instance_id`);

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
-- Indexes for table `comment_reads`
--
ALTER TABLE `comment_reads`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_user_comment` (`user_id`,`comment_id`),
  ADD KEY `idx_comment` (`comment_id`),
  ADD KEY `idx_user` (`user_id`);

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
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_documents_approval_status` (`approval_status`);

--
-- Indexes for table `documents_converted`
--
ALTER TABLE `documents_converted`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `document_approvals`
--
ALTER TABLE `document_approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_document` (`document_id`);

--
-- Indexes for table `document_approval_logs`
--
ALTER TABLE `document_approval_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_approval` (`approval_id`),
  ADD KEY `idx_document` (`document_id`),
  ADD KEY `idx_acted_by` (`acted_by`);

--
-- Indexes for table `document_approval_steps`
--
ALTER TABLE `document_approval_steps`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_approval` (`approval_id`),
  ADD KEY `idx_approver` (`approver_id`);

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
-- Indexes for table `document_sign_status`
--
ALTER TABLE `document_sign_status`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `file_signatures`
--
ALTER TABLE `file_signatures`
  ADD PRIMARY KEY (`id`),
  ADD KEY `task_file_id` (`task_file_id`),
  ADD KEY `approval_id` (`approval_id`),
  ADD KEY `signed_by` (`signed_by`);

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
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_approved_by` (`approved_by`),
  ADD KEY `idx_task_files_document_id` (`document_id`);

--
-- Indexes for table `task_notifications`
--
ALTER TABLE `task_notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_roster`
--
ALTER TABLE `task_roster`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_task_user` (`task_id`,`user_id`);

--
-- Indexes for table `task_sign_logs`
--
ALTER TABLE `task_sign_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `task_snapshots`
--
ALTER TABLE `task_snapshots`
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
-- AUTO_INCREMENT for table `approval_instances`
--
ALTER TABLE `approval_instances`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=120;

--
-- AUTO_INCREMENT for table `approval_logs`
--
ALTER TABLE `approval_logs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=111;

--
-- AUTO_INCREMENT for table `approval_reads`
--
ALTER TABLE `approval_reads`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `approval_steps`
--
ALTER TABLE `approval_steps`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=161;

--
-- AUTO_INCREMENT for table `biddings`
--
ALTER TABLE `biddings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `bidding_steps`
--
ALTER TABLE `bidding_steps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=389;

--
-- AUTO_INCREMENT for table `bidding_step_templates`
--
ALTER TABLE `bidding_step_templates`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

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
-- AUTO_INCREMENT for table `comment_reads`
--
ALTER TABLE `comment_reads`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `contracts`
--
ALTER TABLE `contracts`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `contract_steps`
--
ALTER TABLE `contract_steps`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=382;

--
-- AUTO_INCREMENT for table `contract_step_files`
--
ALTER TABLE `contract_step_files`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `contract_step_templates`
--
ALTER TABLE `contract_step_templates`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `customer_transactions`
--
ALTER TABLE `customer_transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=212;

--
-- AUTO_INCREMENT for table `documents_converted`
--
ALTER TABLE `documents_converted`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `document_approvals`
--
ALTER TABLE `document_approvals`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `document_approval_logs`
--
ALTER TABLE `document_approval_logs`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `document_approval_steps`
--
ALTER TABLE `document_approval_steps`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

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
-- AUTO_INCREMENT for table `document_sign_status`
--
ALTER TABLE `document_sign_status`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=132;

--
-- AUTO_INCREMENT for table `file_signatures`
--
ALTER TABLE `file_signatures`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=313;

--
-- AUTO_INCREMENT for table `task_approvals`
--
ALTER TABLE `task_approvals`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=220;

--
-- AUTO_INCREMENT for table `task_approval_logs`
--
ALTER TABLE `task_approval_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `task_comments`
--
ALTER TABLE `task_comments`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=205;

--
-- AUTO_INCREMENT for table `task_extensions`
--
ALTER TABLE `task_extensions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `task_files`
--
ALTER TABLE `task_files`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=374;

--
-- AUTO_INCREMENT for table `task_notifications`
--
ALTER TABLE `task_notifications`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `task_roster`
--
ALTER TABLE `task_roster`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=481;

--
-- AUTO_INCREMENT for table `task_sign_logs`
--
ALTER TABLE `task_sign_logs`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `task_snapshots`
--
ALTER TABLE `task_snapshots`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `approval_logs`
--
ALTER TABLE `approval_logs`
  ADD CONSTRAINT `fk_logs_instance` FOREIGN KEY (`approval_instance_id`) REFERENCES `approval_instances` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `approval_steps`
--
ALTER TABLE `approval_steps`
  ADD CONSTRAINT `fk_steps_instance` FOREIGN KEY (`approval_instance_id`) REFERENCES `approval_instances` (`id`) ON DELETE CASCADE;

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
