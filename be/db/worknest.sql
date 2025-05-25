-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 08, 2025 at 11:10 AM
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
-- Database: `worknest`
--

-- --------------------------------------------------------

--
-- Table structure for table `businesses`
--

CREATE TABLE `businesses` (
  `id` bigint NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tax_code` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `district` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ward` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `career` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `facebook_link` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `other_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `logo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `library_images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `video_intro` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `certificate_file` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `lat` decimal(10,8) DEFAULT NULL,
  `lng` decimal(11,8) DEFAULT NULL,
  `extra_info` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `status` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  `user_id` int NOT NULL,
  `display_settings` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `businesses`
--

INSERT INTO `businesses` (`id`, `name`, `tax_code`, `country`, `city`, `district`, `ward`, `address`, `phone`, `email`, `website`, `description`, `career`, `facebook_link`, `other_links`, `logo`, `cover_image`, `library_images`, `video_intro`, `certificate_file`, `lat`, `lng`, `extra_info`, `status`, `created_at`, `updated_at`, `deleted_at`, `user_id`, `display_settings`) VALUES
(1, 'xxx', '32423234', 'việt nam', 'ha noi', 'ba đình', 'cống vị ba đình', 'xóm liều', '0387409300', 'doangiang665@gmail.com', 'develop.io.vn', 'xxxxx', '2344324', '2343244', '[]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030227_a219e8b45e3cc12378d8.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030230_ffa313e9284e59d34cdf.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030232_e04bed398cc255350886.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030234_7f855fad911edf3ee922.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030254_d9af1ae6c177f1e36141.xls\"]', NULL, NULL, '[]', 1, '2025-04-13 16:14:26', '2025-05-03 07:32:54', NULL, 1, '{\"selectedTemplate\":\"tpl-3\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"1\",\"2\",\"3\",\"4\",\"5\"],\"company\":\"selected\",\"selectedCompanies\":[],\"store\":\"selected\",\"selectedStores\":[\"1\"]}'),
(2, 'Xiaomi', 'xxxxxxxxxxxiiiiiiiiiiiiiiiiiii', 'Trung quốc', 'Thượng hải', 'Thượng hải', 'Thượng hải', 'Thượng hải', '0387409300', 'doangiang665@gmail.com', 'https://shopee.vn/', '★ Kệ máy tính để bàn còn giúp sắp xếp tài liệu, đồ dùng gọn gàng, tiện ích, khoa học\n\n★ Sử dụng chiếc kệ màn hình này giúp bạn không phải cúi người trong khi làm việc, cải thiện tư thế cổ vai gáy, bảo vệ vóc dáng\n\n★ Đáy kệ đồng thời làm hộc để đồ, bàn phím, chuột ngăn nắp tạo không làm việc gọn gàng\n\n★ TopV sở hữu công nghệ sản xuất CNC tiên tiến bậc nhất hiện nay, giúp cho sản phẩm được gia công chính xác tới 0.1mm\n\n★ Kệ màn hình TOPV được thiết kế thông minh để dấu đinh vít do đó sản phẩm nhìn rất đẹp và sang trọng\n\n★ Chất liệu: Gỗ công nghiệp MDF nhập khẩu Malaisia phủ melamine, chống ẩm mối mọt\n\n★ Gỗ dày tới 1.6cm, không mỏng như những sản phẩm khác trên thị trường (thường dày 1-1.2cm)', 'dev', 'facebook.com', '[\"facebook.com\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745505449_599f8a45b9ee7e1d9229.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745505455_b7981d8de74f5078971c.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745505458_cc3a1c933382d26b775d.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745505462_eda4879f1a14188a33a3.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745505471_4c70ac8ebced86736d2e.txt\"]', NULL, NULL, '[]', 1, '2025-04-24 14:40:00', '2025-04-24 14:40:00', NULL, 3, NULL),
(3, 'abc', '435344353', 'Viet nam', 'ha noi', 'Tay mo', 'vin home', 'vin smart', '0387409300', 'doangiang665@gmail.com', 'vnexpress.vn', 'công ty truyền thông', 'dev code', '', '[\"demo demo\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745514075_a14af045326518955620.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745514083_5ae77b2ff50d5681708a.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745514085_0f0cb594530b70223389.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745514088_63d54e4f02a4df3d4541.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745514094_a682714304111395c58a.xlsx\"]', NULL, NULL, '[]', 1, '2025-04-24 17:02:42', '2025-04-24 17:02:42', NULL, 3, NULL),
(4, 'xxxxxxxx', '3424324', 'viet nam', 'ha noi', 'ba dinh', 'cong vi', 'ngoc khanh ba dinh ha noi', '0387409300', 'doangiang@gmail.com', '', '', '', '', '[]', '[\"http:\\/\\/assets.giang.test\\/image\\/1746257908_44365af29a30d1cb69e3.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1746257913_e9957ca23bd689ae3c96.png\"]', '[]', '[]', '[]', NULL, NULL, '[]', 1, '2025-05-03 07:33:03', '2025-05-03 07:45:58', NULL, 1, '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"1\",\"3\"],\"company\":\"selected\",\"selectedCompanies\":[\"4\",\"1\"],\"store\":\"selected\",\"selectedStores\":[\"1\",\"6\"]}');

-- --------------------------------------------------------

--
-- Table structure for table `business_extra_info`
--

CREATE TABLE `business_extra_info` (
  `id` bigint NOT NULL,
  `business_id` bigint NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
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
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` text COLLATE utf8mb4_unicode_ci,
  `last_interaction` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `entity_images`
--

CREATE TABLE `entity_images` (
  `id` int UNSIGNED NOT NULL,
  `entity_type` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` int UNSIGNED NOT NULL,
  `url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_cover` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `banner` text COLLATE utf8mb4_unicode_ci,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `event_mode` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'online',
  `is_enabled` tinyint(1) DEFAULT '1',
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `district` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_first_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `contact_email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ticket_options` text COLLATE utf8mb4_unicode_ci,
  `social_links` text COLLATE utf8mb4_unicode_ci,
  `images` text COLLATE utf8mb4_unicode_ci,
  `video` text COLLATE utf8mb4_unicode_ci,
  `format_type` enum('online','offline') COLLATE utf8mb4_unicode_ci DEFAULT 'offline',
  `display_settings` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`id`, `user_id`, `name`, `banner`, `location`, `event_mode`, `is_enabled`, `start_time`, `end_time`, `description`, `created_at`, `updated_at`, `country`, `city`, `district`, `contact_first_name`, `contact_last_name`, `contact_phone`, `contact_email`, `ticket_options`, `social_links`, `images`, `video`, `format_type`, `display_settings`) VALUES
(1, 1, 'abc', 'http://assets.giang.test/image/1746037955_5db3c563bd96591ec624.jpg', 'ty mo nam tu liem', 'online', 1, '2025-04-02 05:55:14', '2025-04-09 05:55:17', '[{\"title\":\"ewqeqwqeqwe\",\"content\":\"<p>dsadsadda<\\/p>\"},{\"title\":\"57567567657\",\"content\":\"<p>fsdfdsfsfsf<\\/p>\"},{\"title\":\"mmmmmmmmmmmmmm\",\"content\":\"<p>nnnnnnnnnnnnnnnnnn<\\/p>\"}]', '2025-04-19 03:55:21', '2025-05-04 01:13:24', 'viet nam', 'ha noi', 'nam tu liem', 'doan', 'giang', '0387409300', 'doangiang665@gmail.com', '\"[{\\\"title\\\":\\\"111111111\\\",\\\"description\\\":\\\"\\\",\\\"price\\\":10000000000},{\\\"title\\\":\\\"33333333333\\\",\\\"description\\\":\\\"\\\",\\\"price\\\":6666666666666666}]\"', '\"[{\\\"type\\\":\\\"facebook\\\",\\\"url\\\":\\\"https:\\/\\/dantri.com.vn\\/giao-duc\\/top-9-truong-dai-hoc-tot-nhat-nhat-ban-nam-2025-20250501202923859.htm\\\",\\\"icon\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746201737_6b8aef50c620203911ef.jpg\\\"},{\\\"type\\\":\\\"linkedin\\\",\\\"url\\\":\\\"https:\\/\\/cdnphoto.dantri.com.vn\\/7SRYiJD05ukrmyoV6TZx1k3sAZM=\\/thumb_w\\/1020\\/2025\\/05\\/02\\/tbt-1746158118574.jpg\\\",\\\"icon\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746201920_c5131d2c0c5858f4bedb.jpg\\\"}]\"', '\"[{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746029417_20453b5636ecffe9887d.jpg\\\",\\\"is_main\\\":true},{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746030360_c16844c25c41255be6e4.jpg\\\",\\\"is_main\\\":false},{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746032537_8307b0403fe457e20580.jpg\\\",\\\"is_main\\\":false},{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746032541_35aea3dbeaa439d9cedd.jpg\\\",\\\"is_main\\\":false},{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746032548_88a4a4a19cbe5408828d.jpg\\\",\\\"is_main\\\":false},{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746037959_aff78cc90d81287f74e4.jpg\\\",\\\"is_main\\\":false},{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746037963_57a3d4cbb59f554357b3.jpg\\\",\\\"is_main\\\":false}]\"', '\"[{\\\"uid\\\":\\\"1746037845545\\\",\\\"url\\\":\\\"https:\\/\\/www.youtube.com\\/watch?v=R3GfuzLMPkA\\\",\\\"preview\\\":\\\"https:\\/\\/img.youtube.com\\/vi\\/R3GfuzLMPkA\\/hqdefault.jpg\\\",\\\"isCover\\\":false,\\\"isYoutube\\\":true},{\\\"uid\\\":\\\"1746037969377\\\",\\\"url\\\":\\\"https:\\/\\/www.youtube.com\\/watch?v=G5RpJwCJDqc\\\",\\\"preview\\\":\\\"https:\\/\\/img.youtube.com\\/vi\\/G5RpJwCJDqc\\/hqdefault.jpg\\\",\\\"isCover\\\":false,\\\"isYoutube\\\":true}]\"', 'offline', '\"{\\\"selectedTemplate\\\":\\\"tpl-3\\\",\\\"relatedProducts\\\":\\\"all\\\",\\\"selectedProducts\\\":[],\\\"company\\\":\\\"selected\\\",\\\"selectedCompanies\\\":[\\\"1\\\",\\\"4\\\"],\\\"store\\\":\\\"all\\\",\\\"selectedStores\\\":[],\\\"enableSurvey\\\":false,\\\"selectedSurveys\\\":[],\\\"enableOrderButton\\\":true,\\\"topProductsMode\\\":\\\"all\\\",\\\"topProducts\\\":[]}\"'),
(2, 1, 'xxxxxxx', 'http://assets.giang.test/image/1746202553_13787ae765a78b8865a6.jpg', 'nmnnmmnbnmbm', 'online', 1, '2025-05-02 02:16:56', '2025-05-15 02:17:01', '[{\"title\":\"6546546546\",\"content\":\"<p>t\\u1ebbtretete<\\/p>\"},{\"title\":\"rtetretet\",\"content\":\"<p>\\u1ec3trtret<\\/p>\"}]', '2025-05-02 16:15:40', '2025-05-03 14:32:42', 'vvvvvvvvvv', 'bbbbbbbbbb', 'ruiyiuyii', 'rewrewr', '56757567', '0387409300', 'doangiang665@gmail.com', '\"[{\\\"title\\\":\\\"\\\",\\\"description\\\":\\\"\\\",\\\"price\\\":0}]\"', '\"[{\\\"type\\\":\\\"instagram\\\",\\\"url\\\":\\\"https:\\/\\/antdv.com\\/components\\/upload\\/#Upload\\\",\\\"icon\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746202636_55513f183c5978bf4488.jpg\\\"}]\"', '\"[{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746202521_8a81f574aeeac142dd3c.jpg\\\",\\\"is_main\\\":true}]\"', '\"[{\\\"uid\\\":\\\"1746202578711\\\",\\\"url\\\":\\\"https:\\/\\/www.youtube.com\\/watch?v=gTkV0z3NTcA\\\",\\\"preview\\\":\\\"https:\\/\\/img.youtube.com\\/vi\\/gTkV0z3NTcA\\/hqdefault.jpg\\\",\\\"isCover\\\":false,\\\"isYoutube\\\":true}]\"', 'offline', '\"{\\\"selectedTemplate\\\":\\\"tpl-1\\\",\\\"relatedProducts\\\":\\\"all\\\",\\\"selectedProducts\\\":[],\\\"company\\\":\\\"selected\\\",\\\"selectedCompanies\\\":[\\\"1\\\",\\\"4\\\"],\\\"store\\\":\\\"all\\\",\\\"selectedStores\\\":[],\\\"enableSurvey\\\":false,\\\"selectedSurveys\\\":[],\\\"enableOrderButton\\\":true,\\\"topProductsMode\\\":\\\"all\\\",\\\"topProducts\\\":[]}\"'),
(3, 1, '33333', 'http://assets.giang.test/image/1746258612_4f4625f74cb3d27de0e4.png', 'gggggggg', 'online', 1, '2025-05-03 00:50:24', '2025-05-30 00:50:27', '[{\"title\":\"\",\"content\":\"<p><br><\\/p>\"}]', '2025-05-03 06:19:35', '2025-05-03 08:07:40', NULL, NULL, NULL, '', '', '', '', '\"[{\\\"title\\\":\\\"\\\",\\\"description\\\":\\\"\\\",\\\"price\\\":0}]\"', '\"[]\"', '\"[{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746258610_ada5434eb10a8d6fd757.png\\\",\\\"is_main\\\":false}]\"', '\"[]\"', 'offline', '[]'),
(4, 1, 'ccccccccccccccc', 'http://assets.giang.test/image/1746256539_dc524834f2899997e8c9.jpg', 'xxxxxxxxxxxxxxxx', 'online', 1, '2025-05-02 10:16:00', '2025-05-20 10:16:04', '[{\"title\":\"\",\"content\":\"<p><br><\\/p>\"}]', '2025-05-03 06:25:47', '2025-05-03 07:18:17', NULL, NULL, NULL, '', '', '', '', '\"[{\\\"title\\\":\\\"\\\",\\\"description\\\":\\\"\\\",\\\"price\\\":0}]\"', '\"[]\"', '\"[{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746256530_959ce70527ba750584b2.jpg\\\",\\\"is_main\\\":false}]\"', '\"[]\"', 'offline', '[]'),
(5, 1, 'xxxxxxxxxx', 'http://assets.giang.test/image/1746253818_9096dad87a5b81cf36b5.jpg', 'vvvvvvvvvvvvvv', 'online', 1, '2025-04-28 00:33:53', '2025-05-26 00:33:56', '[{\"title\":\"xxxxxxx\",\"content\":\"<p>vvvvvvvv<\\/p>\"},{\"title\":\"bbbbbbbbbb\",\"content\":\"<p>vvvvvvvvvvvv<\\/p>\"}]', '2025-05-03 06:30:22', '2025-05-03 09:06:11', NULL, NULL, NULL, '', '', '', '', '\"[{\\\"title\\\":\\\"\\\",\\\"description\\\":\\\"\\\",\\\"price\\\":0}]\"', '\"[{\\\"type\\\":\\\"facebook\\\",\\\"url\\\":\\\"https:\\/\\/www.youtube.com\\/watch?v=QEjB71pQDf8\\\",\\\"icon\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746261130_c74cd26ffad1ebd88c80.png\\\"}]\"', '\"[{\\\"url\\\":\\\"http:\\/\\/assets.giang.test\\/image\\/1746253811_07015ce4da9066ba0b45.jpg\\\",\\\"is_main\\\":false}]\"', '\"[]\"', 'offline', '\"{\\\"selectedTemplate\\\":\\\"tpl-1\\\",\\\"relatedProducts\\\":\\\"all\\\",\\\"selectedProducts\\\":[],\\\"company\\\":\\\"selected\\\",\\\"selectedCompanies\\\":[\\\"1\\\"],\\\"store\\\":\\\"all\\\",\\\"selectedStores\\\":[],\\\"enableSurvey\\\":false,\\\"selectedSurveys\\\":[],\\\"enableOrderButton\\\":true,\\\"topProductsMode\\\":\\\"all\\\",\\\"topProducts\\\":[],\\\"productLinks\\\":[]}\"');

-- --------------------------------------------------------

--
-- Table structure for table `landing_pages`
--

CREATE TABLE `landing_pages` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` longtext COLLATE utf8mb4_unicode_ci,
  `status` enum('draft','published') COLLATE utf8mb4_unicode_ci DEFAULT 'draft',
  `access_count` int UNSIGNED DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_gifts`
--

CREATE TABLE `loyalty_gifts` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` enum('item','vnpoint') COLLATE utf8mb4_unicode_ci DEFAULT 'item',
  `value` int DEFAULT '0',
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` tinyint(1) DEFAULT '1',
  `user_id` int UNSIGNED DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_histories`
--

CREATE TABLE `loyalty_histories` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int NOT NULL,
  `program_id` int DEFAULT NULL,
  `type` enum('participation','winning') COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `metadata` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_participation_logs`
--

CREATE TABLE `loyalty_participation_logs` (
  `id` int UNSIGNED NOT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `gift_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `program_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_winner` tinyint(1) DEFAULT '0',
  `joined_at` datetime DEFAULT NULL,
  `user_id` int UNSIGNED DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_programs`
--

CREATE TABLE `loyalty_programs` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `banner` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `video` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `status` tinyint(1) DEFAULT '1',
  `social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `display_settings` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_vouchers`
--

CREATE TABLE `loyalty_vouchers` (
  `id` int UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` int DEFAULT '0',
  `quantity` int DEFAULT '0',
  `issued` int DEFAULT '0',
  `used` int DEFAULT '0',
  `max_per_voucher` int DEFAULT '1',
  `max_per_user` int DEFAULT '1',
  `valid_from` datetime DEFAULT NULL,
  `valid_to` datetime DEFAULT NULL,
  `duration_after_issued` int DEFAULT NULL,
  `require_owner` tinyint(1) DEFAULT '0',
  `is_lucky_draw` tinyint(1) DEFAULT '0',
  `description` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` tinyint(1) DEFAULT '1',
  `user_id` int UNSIGNED DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `loyalty_winner_logs`
--

CREATE TABLE `loyalty_winner_logs` (
  `id` int UNSIGNED NOT NULL,
  `full_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone_recharge` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `gift_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `program_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reason` text COLLATE utf8mb4_unicode_ci,
  `won_at` datetime DEFAULT NULL,
  `received_at` datetime DEFAULT NULL,
  `user_id` int UNSIGNED DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` int NOT NULL,
  `key_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `first_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `video_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `social_links` text COLLATE utf8mb4_unicode_ci,
  `job_title` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `display_settings` text COLLATE utf8mb4_unicode_ci
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
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint NOT NULL,
  `sku` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `category_id` bigint DEFAULT NULL,
  `price_mode` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'single',
  `price` decimal(15,2) DEFAULT '0.00',
  `price_from` decimal(15,2) DEFAULT '0.00',
  `price_to` decimal(15,2) DEFAULT '0.00',
  `show_contact_price` tinyint(1) DEFAULT '0',
  `avatar` text COLLATE utf8mb4_unicode_ci,
  `image` text COLLATE utf8mb4_unicode_ci,
  `video` text COLLATE utf8mb4_unicode_ci,
  `certificate_file` text COLLATE utf8mb4_unicode_ci,
  `description` text COLLATE utf8mb4_unicode_ci,
  `attributes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `status` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  `user_id` int NOT NULL,
  `display_settings` text COLLATE utf8mb4_unicode_ci,
  `product_links` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `sku`, `name`, `category_id`, `price_mode`, `price`, `price_from`, `price_to`, `show_contact_price`, `avatar`, `image`, `video`, `certificate_file`, `description`, `attributes`, `status`, `created_at`, `updated_at`, `deleted_at`, `user_id`, `display_settings`, `product_links`) VALUES
(1, '5424324324kkk', 'demo 1', 1, 'range', 120000.00, 10000.00, 150000.00, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745030161_1629c049dd5304b986df.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030163_2becc0716ebd8871b505.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030164_168ff7d22e43564ad35c.jpg\"]', '[\"http:\\/\\/api.giang.test\\/uploads\\/1744558167_bca4a4605e98ca0c07e5.pdf\"]', '<p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">- Xuất xứ : Trung Quốc</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Thiết kế nhỏ gọn, vừa tầm tay.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Các phím to, rõ, dễ nhìn, không bị phai mờ theo thời gian.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Sử dụng 2 pin AAA, không cần thiết lập cài đặt.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Khoảng cách khiển lên đến 8m.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-An toàn cho người sử dụng.</span></p><p><br></p>', '[{\"id\":\"114\",\"product_id\":\"1\",\"name\":\"XL\",\"value\":\"342424324\",\"created_at\":\"2025-04-25 04:05:50\",\"updated_at\":\"2025-04-25 04:05:50\"},{\"name\":\"M\",\"value\":\"11111\"}]', 1, '2025-04-12 17:20:19', '2025-05-04 09:14:42', NULL, 1, '{\"selectedTemplate\":\"tpl-3\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"1\",\"2\"],\"company\":\"selected\",\"selectedCompanies\":[\"1\"],\"store\":\"selected\",\"selectedStores\":[\"1\"],\"enableSurvey\":true,\"selectedSurveys\":[],\"enableOrderButton\":true,\"productLinks\":[{\"platform\":\"Shopee\",\"url\":\"https://shopee.vn/\"},{\"platform\":\"Lazada\",\"url\":\"https://tiki.vn/\"},{\"platform\":\"Tiki\",\"url\":\"https://www.lazada.vn/\"}]}', NULL),
(2, '23424244', 'demo sp', 1, 'range', 120000.00, 40000.00, 60000.00, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745030182_9c8ac5def4099a010923.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030183_b10b3ec25f2fcedf2095.jpg\",\"http:\\/\\/assets.giang.test\\/image\\/1745552471_508fb17cc865c1cd3bea.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030185_6a907b219d2810ceec89.jpg\"]', '[\"http:\\/\\/api.giang.test\\/uploads\\/1744558212_d3135ea188a37ab7205c.pdf\"]', '<p>demo demo</p>', '[{\"id\":\"116\",\"product_id\":\"2\",\"name\":\"xl\",\"value\":\"120000\",\"created_at\":\"2025-04-25 04:06:04\",\"updated_at\":\"2025-04-25 04:06:04\"}]', 1, '2025-04-13 14:58:36', '2025-05-04 09:54:42', NULL, 1, '{\"selectedTemplate\":\"tpl-2\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"5\",\"4\",\"6\"],\"company\":\"selected\",\"selectedCompanies\":[\"1\"],\"store\":\"selected\",\"selectedStores\":[\"1\"],\"enableSurvey\":true,\"selectedSurveys\":[],\"enableOrderButton\":true,\"productLinks\":[{\"platform\":\"Shopee\",\"url\":\"https://vnexpress.net/\"},{\"platform\":\"Lazada\",\"url\":\"https://vnexpress.net/\"},{\"platform\":\"Tiki\",\"url\":\"https://vnexpress.net/\"}]}', NULL),
(3, '43243242', 'demo demo', 1, 'single', 100000.00, NULL, NULL, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745030199_204f7c732930f2e30a52.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030201_92e108209607bc4142c8.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745030203_d86e92994564c22c5735.jpg\"]', '[\"http:\\/\\/api.giang.test\\/uploads\\/1744557413_41644f144bdb597f2bae.pdf\"]', 'demo demo', '[{\"id\": \"24\", \"name\": \"xl \", \"value\": \"12000\", \"created_at\": \"2025-04-20 03:52:02\", \"product_id\": \"3\", \"updated_at\": \"2025-04-20 03:52:02\"}, {\"id\": \"25\", \"name\": \"xxl\", \"value\": \"20000\", \"created_at\": \"2025-04-20 03:52:02\", \"product_id\": \"3\", \"updated_at\": \"2025-04-20 03:52:02\"}]', 0, '2025-04-13 15:17:23', '2025-04-24 14:48:15', NULL, 1, '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"all\",\"company\":\"all\",\"store\":\"all\",\"enableSurvey\":true,\"enableOrderButton\":true}', NULL),
(4, '435435436787AAAAAAAAAA', 'Nước rau má', NULL, 'single', 25000.00, NULL, NULL, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745479571_e32d4ad88fe5e94a4246.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745479579_fc31d80c0b144d95d3a9.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745479581_77d80ba9c15350d71ce9.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745479589_c8a7153f6047d2b56181.html\"]', '<p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">- Xuất xứ : Trung Quốc</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Thiết kế nhỏ gọn, vừa tầm tay.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Các phím to, rõ, dễ nhìn, không bị phai mờ theo thời gian.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Sử dụng 2 pin AAA, không cần thiết lập cài đặt.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Khoảng cách khiển lên đến 8m.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-An toàn cho người sử dụng.</span></p><p><br></p>', '[{\"id\":\"69\",\"product_id\":\"4\",\"name\":\"L\",\"value\":\"25000\",\"created_at\":\"2025-04-24 07:27:16\",\"updated_at\":\"2025-04-24 07:27:16\"},{\"id\":\"70\",\"product_id\":\"4\",\"name\":\"M\",\"value\":\"20000\",\"created_at\":\"2025-04-24 07:27:16\",\"updated_at\":\"2025-04-24 07:27:16\"}]', 0, '2025-04-24 07:27:16', '2025-05-07 10:03:14', NULL, 1, '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"all\",\"company\":\"all\",\"store\":\"all\",\"enableSurvey\":true,\"enableOrderButton\":true}', NULL),
(5, '454657AADĐGGG', 'rau má', NULL, 'single', 10000.00, NULL, NULL, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745480303_0186821d966918c4db65.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745480305_272f716996ccae559ffb.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745480307_565b58fd280481cf7755.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745480311_58487ae57951309fd294.html\"]', '<p><br></p>', '[{\"id\":\"71\",\"product_id\":\"5\",\"name\":\"L\",\"value\":\"10000\",\"created_at\":\"2025-04-24 07:39:06\",\"updated_at\":\"2025-04-24 07:39:06\"}]', 1, '2025-04-24 07:39:06', '2025-05-07 10:03:18', NULL, 1, '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"all\",\"company\":\"all\",\"store\":\"all\",\"enableSurvey\":true,\"enableOrderButton\":true}', NULL),
(6, '4535353hhhhhhhh', 'Sữa đậu fami', NULL, 'single', 20000.00, NULL, NULL, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745480582_a58f7b1a82ccf75e9bd6.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1746588542_19bc23f70285d1047e52.png\",\"http:\\/\\/assets.giang.test\\/image\\/1746588547_f8e1bb55b154e37bf4d5.jpg\",\"http:\\/\\/assets.giang.test\\/image\\/1746588551_ad655404aa05b59bd397.jpg\",\"http:\\/\\/assets.giang.test\\/image\\/1746588566_5cf4df87782da1a45f51.jpg\",\"http:\\/\\/assets.giang.test\\/image\\/1746588590_caab2f3fd4acf9c458c0.png\",\"http:\\/\\/assets.giang.test\\/image\\/1746588636_ae4f0d4d5e1aeeebb28d.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745480592_4835d8dc072c7b31ad5b.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745480596_fc8f6d8c4503d8e6feff.txt\"]', '<p><span style=\"background-color: rgb(252, 250, 246); color: rgb(34, 34, 34);\">Tổng Bí thư chỉ ra Việt Nam và Kazakhstan chia sẻ nhiều điểm tương đồng về vị trí địa chiến lược, lịch sử phát triển và văn hoá, đều đề cao truyền thống hiếu học, lòng hiếu khách cũng như tinh thần đoàn kết. Hai nước đều vượt qua những giai đoạn kinh tế khó khăn và đã vươn lên mạnh mẽ nhờ tinh thần đổi mới, sáng tạo, dám nghĩ, dám làm.</span></p>', '[{\"id\":\"131\",\"product_id\":\"6\",\"name\":\"xl\",\"value\":\"10000\",\"created_at\":\"2025-05-07 03:30:38\",\"updated_at\":\"2025-05-07 03:30:38\"}]', 1, '2025-04-24 07:43:52', '2025-05-07 03:45:51', NULL, 1, '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"1\",\"2\",\"3\",\"4\"],\"company\":\"selected\",\"selectedCompanies\":[\"4\"],\"store\":\"all\",\"selectedStores\":[],\"enableSurvey\":true,\"selectedSurveys\":[],\"enableOrderButton\":true,\"productLinks\":[{\"platform\":\"Shopee\",\"url\":\"\"},{\"platform\":\"Lazada\",\"url\":\"\"},{\"platform\":\"Tiki\",\"url\":\"\"}]}', NULL),
(7, '3453454353', 'bún đậu', NULL, 'single', 140000.00, NULL, NULL, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745480966_68d7c266dac1fcb14dde.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745480970_347dc3ef1b43bf24cf4c.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745480975_9de1474121f7e51f1e7e.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745480986_6bbf44cd4056913f2f8d.png\"]', '', '[{\"name\":\"L\",\"value\":\"10000\"}]', 1, '2025-04-24 07:50:14', '2025-04-24 07:50:14', NULL, 0, '\"{\\\"selectedTemplate\\\":\\\"tpl-1\\\",\\\"relatedProducts\\\":\\\"all\\\",\\\"selectedProducts\\\":[],\\\"company\\\":\\\"all\\\",\\\"selectedCompanies\\\":[],\\\"store\\\":\\\"all\\\",\\\"selectedStores\\\":[],\\\"enableSurvey\\\":false,\\\"selectedSurveys\\\":[],\\\"enableOrderButton\\\":true,\\\"productLinks\\\":[{\\\"platform\\\":\\\"Shopee\\\",\\\"url\\\":\\\"\\\"},{\\\"platform\\\":\\\"Lazada\\\",\\\"url\\\":\\\"\\\"},{\\\"platform\\\":\\\"Tiki\\\",\\\"url\\\":\\\"\\\"}]}\"', NULL),
(8, '34234242', 'nem nuong nha trang', NULL, 'single', 23000.00, NULL, NULL, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745481478_689e4fb81f3be539c086.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745481481_adca135c4dae226d93bb.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745481484_67d6fc9c4e13a0d0e694.png\"]', '[]', '', '[{\"name\":\"X\",\"value\":\"23000\"}]', 1, '2025-04-24 07:58:36', '2025-04-24 07:58:36', NULL, 0, '\"{\\\"selectedTemplate\\\":\\\"tpl-1\\\",\\\"relatedProducts\\\":\\\"all\\\",\\\"selectedProducts\\\":[],\\\"company\\\":\\\"all\\\",\\\"selectedCompanies\\\":[],\\\"store\\\":\\\"all\\\",\\\"selectedStores\\\":[],\\\"enableSurvey\\\":false,\\\"selectedSurveys\\\":[],\\\"enableOrderButton\\\":true,\\\"productLinks\\\":[{\\\"platform\\\":\\\"Shopee\\\",\\\"url\\\":\\\"\\\"},{\\\"platform\\\":\\\"Lazada\\\",\\\"url\\\":\\\"\\\"},{\\\"platform\\\":\\\"Tiki\\\",\\\"url\\\":\\\"\\\"}]}\"', NULL),
(9, '4353543535435', 'Vịt om sấu', NULL, 'single', 124000.00, NULL, NULL, 0, '\"http:\\/\\/assets.giang.test\\/image\\/1746548933_2a0c2ddd9c1b54c12efb.jpg\"', '[\"http:\\/\\/assets.giang.test\\/image\\/1746548943_67bbb734b9e15dfd1295.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745481679_875e9a818fe1dbb531ea.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745481689_ca1989e0b3c6e8d7adaf.txt\"]', '<p><br></p>', '[{\"id\":\"75\",\"product_id\":\"9\",\"name\":\"L\",\"value\":\"120000\",\"created_at\":\"2025-04-24 08:02:04\",\"updated_at\":\"2025-04-24 08:02:04\"}]', 1, '2025-04-24 08:02:04', '2025-05-07 10:03:26', NULL, 1, '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"all\",\"company\":\"all\",\"store\":\"all\",\"enableSurvey\":true,\"enableOrderButton\":true}', NULL),
(10, '54356465464', 'Giường gấp văn phòng cao cấp gấp gọn 4 khúc H2Home khung hợp kim sơn tĩnh điện chắc chắn bảo hành 12 tháng', 1, 'single', 1500000.00, NULL, NULL, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745506841_4fab5f44fa54d974ba11.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745481785_7e1b5ecc5e060c8a96fe.png\",\"http:\\/\\/assets.giang.test\\/image\\/1745506019_855fbb66bf4f40091f09.jpg\",\"http:\\/\\/assets.giang.test\\/image\\/1745507157_375fc75b50de8a6ad20b.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745481788_49c58f5b697b0823f8ee.png\",\"http:\\/\\/assets.giang.test\\/image\\/1745507161_67fd47f8896136598fdf.jpg\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745481795_526baab6a0b8fa0aca46.html\"]', '<p>Các trường hợp bảo hành cụ thể\n\n- Sản phẩm bị hư hỏng/ bể vỡ trong quá trình vận chuyển \n\n- Sản phẩm bị lỗi do lỗi từ nhà sản xuất \n\n- Sản phẩm giao đến không đúng với đơn hàng đã đặt \n\n- Sản phẩm được giao không đủ số lượng theo đơn hàng đã đặt \n\n- Những lỗi khác do kỹ thuật, chất liệu của sản phẩm </p>', '[{\"id\":\"99\",\"product_id\":\"10\",\"name\":\"XL\",\"value\":\"2000000\",\"created_at\":\"2025-04-24 16:32:03\",\"updated_at\":\"2025-04-24 16:32:03\"}]', 1, '2025-04-24 08:05:05', '2025-04-24 17:04:00', NULL, 3, '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"10\",\"11\"],\"company\":\"selected\",\"selectedCompanies\":[\"2\",\"3\"],\"store\":\"selected\",\"selectedStores\":[\"2\",\"3\"],\"enableSurvey\":false,\"selectedSurveys\":[],\"enableOrderButton\":true,\"productLinks\":[{\"platform\":\"Shopee\",\"url\":\"https://shopee.vn/\"},{\"platform\":\"Lazada\",\"url\":\"https://www.lazada.vn/\"},{\"platform\":\"Tiki\",\"url\":\"https://tiki.vn/\"}]}', NULL),
(11, '54353453535', 'Điều khiển điều hòa NAGAKAWA - Remote máy lạnh Nagakawa hàng loại 1 bảo hành đổi trả 30 ngày', 5, 'single', 120000.00, NULL, NULL, 0, '[\"http:\\/\\/assets.giang.test\\/image\\/1745506496_b61218fe994ad5b2abe5.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745482473_c82e19525025ad5852fe.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745482475_16c60515a6f0f2b4dcab.png\"]', '[\"http:\\/\\/assets.giang.test\\/image\\/1745482482_b672aeeef7a3fc2c57d9.html\"]', '<p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">- Xuất xứ : Trung Quốc</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Thiết kế nhỏ gọn, vừa tầm tay.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Các phím to, rõ, dễ nhìn, không bị phai mờ theo thời gian.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Sử dụng 2 pin AAA, không cần thiết lập cài đặt.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Khoảng cách khiển lên đến 8m.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-An toàn cho người sử dụng.</span></p><p><br></p>', '[{\"id\":\"88\",\"product_id\":\"11\",\"name\":\"XL\",\"value\":\"230000\",\"created_at\":\"2025-04-24 15:16:05\",\"updated_at\":\"2025-04-24 15:16:05\"}]', 1, '2025-04-24 08:15:54', '2025-04-24 16:33:08', NULL, 3, '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"10\",\"11\"],\"company\":\"selected\",\"selectedCompanies\":[\"2\"],\"store\":\"selected\",\"selectedStores\":[\"2\"],\"enableSurvey\":false,\"selectedSurveys\":[],\"enableOrderButton\":true,\"productLinks\":[{\"platform\":\"Shopee\",\"url\":\"\"},{\"platform\":\"Lazada\",\"url\":\"\"},{\"platform\":\"Tiki\",\"url\":\"\"}]}', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `product_attributes`
--

CREATE TABLE `product_attributes` (
  `id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `product_attributes`
--

INSERT INTO `product_attributes` (`id`, `product_id`, `name`, `value`, `created_at`, `updated_at`) VALUES
(32, 3, 'xl ', '12000', '2025-04-20 04:09:53', '2025-04-20 04:09:53'),
(33, 3, 'xxl', '20000', '2025-04-20 04:09:53', '2025-04-20 04:09:53'),
(73, 7, 'L', '10000', '2025-04-24 07:50:14', '2025-04-24 07:50:14'),
(74, 8, 'X', '23000', '2025-04-24 07:58:36', '2025-04-24 07:58:36'),
(78, 4, 'L', '25000', '2025-04-24 08:49:28', '2025-04-24 08:49:28'),
(79, 4, 'M', '20000', '2025-04-24 08:49:28', '2025-04-24 08:49:28'),
(100, 11, 'XL', '230000', '2025-04-24 16:33:08', '2025-04-24 16:33:08'),
(101, 10, 'XL', '2000000', '2025-04-24 17:04:00', '2025-04-24 17:04:00'),
(118, 5, 'L', '10000', '2025-05-04 08:35:53', '2025-05-04 08:35:53'),
(119, 1, 'XL', '342424324', '2025-05-04 09:14:42', '2025-05-04 09:14:42'),
(120, 1, 'M', '11111', '2025-05-04 09:14:42', '2025-05-04 09:14:42'),
(121, 2, 'xl', '120000', '2025-05-04 09:54:42', '2025-05-04 09:54:42'),
(122, 9, 'L', '120000', '2025-05-06 16:29:06', '2025-05-06 16:29:06'),
(132, 6, 'xl', '10000', '2025-05-07 03:45:51', '2025-05-07 03:45:51');

-- --------------------------------------------------------

--
-- Table structure for table `purchase_histories`
--

CREATE TABLE `purchase_histories` (
  `id` int UNSIGNED NOT NULL,
  `user_id` int UNSIGNED NOT NULL,
  `customer_id` int UNSIGNED DEFAULT NULL,
  `product_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `quantity` int DEFAULT '1',
  `note` text COLLATE utf8mb4_unicode_ci,
  `purchased_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `qr_codes`
--

CREATE TABLE `qr_codes` (
  `id` int NOT NULL,
  `short_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_id` int NOT NULL,
  `target_type` enum('product','store','business','event','person') COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_id` int NOT NULL,
  `qr_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `campaign` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `expires_at` datetime DEFAULT NULL,
  `qr_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `scan_count` int DEFAULT '0',
  `last_scanned_at` datetime DEFAULT NULL,
  `settings_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `note` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `qr_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `qr_codes`
--

INSERT INTO `qr_codes` (`id`, `short_code`, `user_id`, `target_type`, `target_id`, `qr_name`, `campaign`, `is_active`, `expires_at`, `qr_url`, `scan_count`, `last_scanned_at`, `settings_json`, `note`, `created_at`, `updated_at`, `qr_id`) VALUES
(1, 'beaf3e3a', 0, 'product', 5, 'xxxxxxxxxxxxx', NULL, 1, NULL, 'https://qrcode.io/d9bff865', 0, NULL, '{\"width\":300,\"height\":300,\"margin\":0,\"data\":\"\",\"dotsOptions\":{\"color\":\"#800053\",\"type\":\"extra-rounded\"},\"cornersSquareOptions\":{\"type\":\"extra-rounded\",\"color\":\"#000000\"},\"cornersDotOptions\":{\"type\":\"dot\",\"color\":\"#000000\"},\"backgroundOptions\":{\"color\":\"#eeeeee\"},\"imageOptions\":{\"imageSize\":0.4,\"hideBackgroundDots\":true,\"margin\":0},\"qrOptions\":{\"typeNumber\":0,\"mode\":\"Byte\",\"errorCorrectionLevel\":\"Q\"},\"image\":\"\"}', NULL, '2025-05-05 09:43:03', '2025-05-06 22:39:04', 'd9bff865'),
(2, '31b1ff2f', 0, 'product', 6, 'vvvvvvvvvvvvvvv', NULL, 1, NULL, 'https://qrcode.io/d9c0bb17', 0, NULL, '{\"width\":300,\"height\":300,\"margin\":0,\"data\":\"\",\"dotsOptions\":{\"color\":\"#800053\",\"type\":\"extra-rounded\"},\"cornersSquareOptions\":{\"type\":\"extra-rounded\",\"color\":\"#000000\"},\"cornersDotOptions\":{\"type\":\"dot\",\"color\":\"#000000\"},\"backgroundOptions\":{\"color\":\"#eeeeee\"},\"imageOptions\":{\"imageSize\":0.4,\"hideBackgroundDots\":true,\"margin\":0},\"qrOptions\":{\"typeNumber\":0,\"mode\":\"Byte\",\"errorCorrectionLevel\":\"Q\"},\"image\":\"\"}', NULL, '2025-05-05 09:44:19', '2025-05-06 22:39:04', 'd9c0bb17'),
(3, '3d0dc909', 0, 'product', 2, 'tttttt222', NULL, 1, NULL, 'https://qrcode.io/d9c0c140', 0, NULL, '{\"width\":300,\"height\":300,\"margin\":0,\"data\":\"\",\"dotsOptions\":{\"color\":\"#800053\",\"type\":\"extra-rounded\"},\"cornersSquareOptions\":{\"type\":\"extra-rounded\",\"color\":\"#000000\"},\"cornersDotOptions\":{\"type\":\"dot\",\"color\":\"#000000\"},\"backgroundOptions\":{\"color\":\"#eeeeee\"},\"imageOptions\":{\"imageSize\":0.4,\"hideBackgroundDots\":true,\"margin\":0},\"qrOptions\":{\"typeNumber\":0,\"mode\":\"Byte\",\"errorCorrectionLevel\":\"Q\"},\"image\":\"\"}', NULL, '2025-05-05 09:46:17', '2025-05-06 22:39:04', 'd9c0c140'),
(4, 'a2868812', 0, 'product', 5, 'tttttttttttttt', NULL, 1, NULL, 'https://qrcode.io/d9c0c74a', 0, NULL, '{\"width\":300,\"height\":300,\"margin\":0,\"data\":\"\",\"dotsOptions\":{\"color\":\"#800053\",\"type\":\"extra-rounded\"},\"cornersSquareOptions\":{\"type\":\"extra-rounded\",\"color\":\"#000000\"},\"cornersDotOptions\":{\"type\":\"dot\",\"color\":\"#000000\"},\"backgroundOptions\":{\"color\":\"#eeeeee\"},\"imageOptions\":{\"imageSize\":0.4,\"hideBackgroundDots\":true,\"margin\":0},\"qrOptions\":{\"typeNumber\":0,\"mode\":\"Byte\",\"errorCorrectionLevel\":\"Q\"},\"image\":\"\"}', NULL, '2025-05-05 09:46:57', '2025-05-06 22:39:04', 'd9c0c74a'),
(5, '7cc36059', 0, 'product', 1, 'tyiuuuuuu', NULL, 1, NULL, 'https://qrcode.io/d9c0d21f', 0, NULL, '{\"width\":300,\"height\":300,\"margin\":0,\"data\":\"\",\"dotsOptions\":{\"color\":\"#800053\",\"type\":\"extra-rounded\"},\"cornersSquareOptions\":{\"type\":\"extra-rounded\",\"color\":\"#000000\"},\"cornersDotOptions\":{\"type\":\"dot\",\"color\":\"#000000\"},\"backgroundOptions\":{\"color\":\"#eeeeee\"},\"imageOptions\":{\"imageSize\":0.4,\"hideBackgroundDots\":true,\"margin\":0},\"qrOptions\":{\"typeNumber\":0,\"mode\":\"Byte\",\"errorCorrectionLevel\":\"Q\"},\"image\":\"\"}', NULL, '2025-05-05 09:47:00', '2025-05-06 22:39:04', 'd9c0d21f'),
(6, '6cbeb6a2', 0, 'product', 9, 'weeeeee', NULL, 1, NULL, 'https://qrcode.io/d9c0dad2', 0, NULL, '{\"width\":300,\"height\":300,\"margin\":0,\"data\":\"\",\"dotsOptions\":{\"color\":\"#800053\",\"type\":\"extra-rounded\"},\"cornersSquareOptions\":{\"type\":\"extra-rounded\",\"color\":\"#000000\"},\"cornersDotOptions\":{\"type\":\"dot\",\"color\":\"#000000\"},\"backgroundOptions\":{\"color\":\"#eeeeee\"},\"imageOptions\":{\"imageSize\":0.4,\"hideBackgroundDots\":true,\"margin\":0},\"qrOptions\":{\"typeNumber\":0,\"mode\":\"Byte\",\"errorCorrectionLevel\":\"Q\"},\"image\":\"\"}', NULL, '2025-05-05 09:47:11', '2025-05-06 22:39:04', 'd9c0dad2'),
(7, 'bdb48b5e', 0, 'product', 9, 'san pham moi 2', NULL, 1, NULL, 'https://qrcode.io/d9c0dad3', 0, NULL, '{\"width\":300,\"height\":300,\"margin\":0,\"data\":\"\",\"dotsOptions\":{\"color\":\"#800053\",\"type\":\"extra-rounded\"},\"cornersSquareOptions\":{\"type\":\"extra-rounded\",\"color\":\"#000000\"},\"cornersDotOptions\":{\"type\":\"dot\",\"color\":\"#000000\"},\"backgroundOptions\":{\"color\":\"#eeeeee\"},\"imageOptions\":{\"imageSize\":0.4,\"hideBackgroundDots\":true,\"margin\":0},\"qrOptions\":{\"typeNumber\":0,\"mode\":\"Byte\",\"errorCorrectionLevel\":\"Q\"},\"image\":\"\"}', NULL, '2025-05-06 02:08:07', '2025-05-06 22:39:04', 'd9c0dad3');

-- --------------------------------------------------------

--
-- Table structure for table `qr_links`
--

CREATE TABLE `qr_links` (
  `id` int UNSIGNED NOT NULL,
  `qr_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `qr_scan_logs`
--

CREATE TABLE `qr_scan_logs` (
  `id` int NOT NULL,
  `qr_id` int DEFAULT NULL,
  `tracking_code` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `short_code` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `qr_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `target_id` int DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `os` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `device_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `browser` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip_address` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referer` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `scan_source` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_unique` tinyint(1) DEFAULT '1',
  `country` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `qr_scan_logs`
--

INSERT INTO `qr_scan_logs` (`id`, `qr_id`, `tracking_code`, `short_code`, `qr_url`, `type`, `target_id`, `user_agent`, `os`, `device_type`, `browser`, `ip_address`, `referer`, `scan_source`, `is_unique`, `country`, `city`, `latitude`, `longitude`, `phone_number`, `created_at`) VALUES
(1, 0, 'abc123', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 06:27:08'),
(3, 0, 'fhfhfgh', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 06:40:07'),
(4, 0, '64565465654', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 06:40:27'),
(6, 0, 'dádaadsa', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 06:41:29'),
(18, 0, '3333', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 07:47:20'),
(23, 0, 'auto_42vvkxhx', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:02:18'),
(24, 0, 'auto_3tatg1aq', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:02:24'),
(25, 0, 'auto_owllr2f5', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:02:39'),
(26, 0, 'auto_o3ao1muc', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:02:43'),
(27, 0, 'auto_qx1l54ns', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:06:02'),
(28, 0, 'auto_0fxn7qa5', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:06:07'),
(29, 0, 'auto_at0na6i8', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:08:12'),
(30, 0, 'auto_gpydohki', NULL, NULL, NULL, NULL, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', NULL, NULL, NULL, '127.0.0.1', NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:09:24'),
(31, 0, 'auto_hv585id7', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'web_view', 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:15:19'),
(32, 0, 'auto_eonbvmis', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'web_view', 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:23:45'),
(33, 0, 'auto_lnucq542', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'web_view', 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:24:55'),
(34, 0, 'auto_h0z4epwu', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'web_view', 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:25:32'),
(35, 0, 'auto_zdgge1ku', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'web_view', 1, NULL, NULL, NULL, NULL, NULL, '2025-05-06 08:26:45'),
(36, 0, 'auto_fatj9f1n', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'web_view', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:27:05'),
(37, 0, 'auto_vi23xb1q', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:29:49'),
(38, 0, 'auto_nk9oo29a', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:31:27'),
(39, 0, 'auto_m6yztvhm', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:31:39'),
(40, 0, 'auto_4w1dhg9i', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:31:42'),
(41, 0, 'auto_n9ru9mjw', '31b1ff2f', 'https://qr-code.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:32:14'),
(42, 0, 'auto_4i2qrr72', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:34:28'),
(43, 0, 'auto_cii3qu34', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:34:29'),
(44, 0, 'auto_3h9jy6gk', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:36:57'),
(45, 0, 'auto_3sshtgjg', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Mobile Safari/537.36', 'Linux', 'Mobile', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:38:49'),
(46, 0, 'auto_9ojhoxgo', '6cbeb6a2', 'https://qr-code.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:38:54'),
(47, 0, 'auto_vgaee342', 'a2868812', 'https://qr-code.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qr-code.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 08:38:56'),
(48, 0, 'auto_p9u464s4', 'a2868812', 'https://qr-code.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 15:04:43'),
(49, 0, 'auto_1rhkjcsd', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 15:39:16'),
(50, 0, 'auto_m25wn35m', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 15:39:18'),
(51, 0, 'auto_xxhx0r9i', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 15:39:21'),
(52, 0, 'auto_zoimeyd0', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 15:39:25'),
(53, 0, 'auto_6czukywh', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 15:39:29'),
(54, 0, 'auto_3iwgcrf5', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 15:39:33'),
(55, 0, 'auto_kzpe3pwx', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 15:59:49'),
(56, 0, 'auto_sbadt1nj', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:09:46'),
(57, 0, 'auto_4eyc2x7k', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:13:42'),
(58, 0, 'auto_5n2nqaia', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:16:49'),
(59, 0, 'auto_0wgqz1nn', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:16:56'),
(60, 0, 'auto_g3i7e0sy', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:02'),
(61, 0, 'auto_i1s8f4is', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:03'),
(62, 0, 'auto_swwoobxa', '3d0dc909', 'https://qrcode.io/d9c0c140', 'product', 2, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:04'),
(63, 0, 'auto_se438n4v', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:16'),
(64, 0, 'auto_jmnycx9z', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:17'),
(65, 0, 'auto_wnudfs27', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:27'),
(66, 0, 'auto_35tecf5q', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:28'),
(67, 0, 'auto_fy7fns0u', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:36'),
(68, 0, 'auto_xrq4l3v3', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:37'),
(69, 0, 'auto_b2gpmg7v', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:38'),
(70, 0, 'auto_04jmm5di', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:38'),
(71, 0, 'auto_36z23i2a', '3d0dc909', 'https://qrcode.io/d9c0c140', 'product', 2, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:39'),
(72, 0, 'auto_c3vc10sv', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:40'),
(73, 0, 'auto_gqkr0sw9', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:17:41'),
(74, 0, 'auto_xzlkbtbi', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:27:54'),
(75, 0, 'auto_5bzb2jcc', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:27:58'),
(76, 0, 'auto_n4xkczrt', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:28:00'),
(77, 0, 'auto_pree2bdw', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:28:06'),
(78, 0, 'auto_0thciuxy', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:28:09'),
(79, 0, 'auto_binnhv6r', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:29:11'),
(80, 0, 'auto_fcllxsxx', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:29:13'),
(81, 0, 'auto_teltr6qe', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:29:15'),
(82, 0, 'auto_b7pmgja8', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:29:24'),
(83, 0, 'auto_ztedqa8e', '3d0dc909', 'https://qrcode.io/d9c0c140', 'product', 2, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:29:51'),
(84, 0, 'auto_fczwgabc', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:29:56'),
(85, 0, 'auto_yj6l0xc4', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:30:42'),
(86, 0, 'auto_51u2aykv', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:30:46'),
(87, 0, 'auto_b7sn2tny', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:30:53'),
(88, 0, 'auto_6j0jo637', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:34:57'),
(89, 0, 'auto_w27jdc5v', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:35:09'),
(90, 0, 'auto_mtjj5tdn', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:35:37'),
(91, 0, 'auto_mbspcw0a', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:35:51'),
(92, 0, 'auto_1498qwk4', '3d0dc909', 'https://qrcode.io/d9c0c140', 'product', 2, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:35:57'),
(93, 0, 'auto_sf9tweck', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:03'),
(94, 0, 'auto_n1yxm5ey', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:06'),
(95, 0, 'auto_32st8pq4', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:19'),
(96, 0, 'auto_c18f17f2', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:19'),
(97, 0, 'auto_lvbalw3s', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:38'),
(98, 0, 'auto_tprexg7c', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:43'),
(99, 0, 'auto_hi0722oz', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:44'),
(100, 0, 'auto_45ei7z2s', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:47'),
(101, 0, 'auto_fgsi7fji', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:47'),
(102, 0, 'auto_poy4coev', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:36:58'),
(103, 0, 'auto_uvewyyg6', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:46:55'),
(104, 0, 'auto_ekfwu787', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:46:56'),
(105, 0, 'auto_ppc6gn0c', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:47:02'),
(106, 0, 'auto_h48n25r0', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-06 16:47:25'),
(107, 0, 'auto_c1ut0q7s', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:25:03'),
(108, 0, 'auto_befky0wd', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:25:12'),
(109, 0, 'auto_sw9205g4', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:25:14'),
(110, 0, 'auto_94ck2olf', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:25:22'),
(111, 0, 'auto_3pgtrt8s', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:27:39'),
(112, 0, 'auto_nw39hshg', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:27:42'),
(113, 0, 'auto_0o3qhykq', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:27:45'),
(114, 0, 'auto_919lssc4', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:27:47'),
(115, 0, 'auto_mevicqq2', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:27:52'),
(116, 0, 'auto_ng780ckd', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:27:58'),
(117, 0, 'auto_b0bkstbg', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:28:00'),
(118, 0, 'auto_6azwuybg', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:28:03'),
(119, 0, 'auto_4ozbc1pz', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:28:12'),
(120, 0, 'auto_aky20b8u', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:29:02'),
(121, 0, 'auto_9i0ir5mj', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:29:06'),
(122, 0, 'auto_fg642lwy', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:29:08'),
(123, 0, 'auto_xtwa207k', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:29:11'),
(124, 0, 'auto_atcfgr7r', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:36:59'),
(125, 0, 'auto_pzuidrcs', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:37:01'),
(126, 0, 'auto_j7k5j1qi', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:37:04'),
(127, 0, 'auto_gmurs885', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:43:32'),
(128, 0, 'auto_u4lnk2j2', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:43:49'),
(129, 0, 'auto_pedly55a', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:44:57'),
(130, 0, 'auto_to2y6a4r', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:44:59'),
(131, 0, 'auto_92y46ypv', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:44:59'),
(132, 0, 'auto_1vb9esh9', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:45:00'),
(133, 0, 'auto_0tscd6a7', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:45:02'),
(134, 0, 'auto_fncwtpmj', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:45:03'),
(135, 0, 'auto_1zndhzor', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:48:54'),
(136, 0, 'auto_5n328jdu', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:50:33'),
(137, 0, 'auto_8qopmpdy', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:50:38'),
(138, 0, 'auto_fidlw4r3', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:51:14'),
(139, 0, 'auto_rbbw9xyk', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:51:17'),
(140, 0, 'auto_38t7dltt', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:51:29'),
(141, 0, 'auto_3a28t25i', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:52:37'),
(142, 0, 'auto_mthd2dfl', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:52:41'),
(143, 0, 'auto_odjv6pk6', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:53:35'),
(144, 0, 'auto_s4hh3xgc', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:55:42'),
(145, 0, 'auto_f92x2wok', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:58:15'),
(146, 0, 'auto_zwjumsap', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 01:58:21'),
(147, 0, 'auto_sewooasw', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:01:28'),
(148, 0, 'auto_mkvcxlf2', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:01:37'),
(149, 0, 'auto_zzen4c3t', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:01:41'),
(150, 0, 'auto_p1kb5ve3', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:05:06'),
(151, 0, 'auto_ukpmqt96', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:06:56'),
(152, 0, 'auto_sxe71jkq', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:07:07'),
(153, 0, 'auto_wg31dl0a', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:08:18'),
(154, 0, 'auto_g7z4ayqj', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:08:24'),
(155, 0, 'auto_jljsy14k', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:08:32'),
(156, 0, 'auto_0hbeceem', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:10:45'),
(157, 0, 'auto_aa5u5018', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:10:47'),
(158, 0, 'auto_rvc01w58', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:10:47'),
(159, 0, 'auto_tyvf2aqk', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:10:49'),
(160, 0, 'auto_fr8zmbs3', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:10:53'),
(161, 0, 'auto_m53nrg1o', '6cbeb6a2', 'https://qrcode.io/d9c0dad2', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:10:56'),
(162, 0, 'auto_fphv4h4n', '7cc36059', 'https://qrcode.io/d9c0d21f', 'product', 1, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:11:01'),
(163, 0, 'auto_4hy3dy53', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:11:07'),
(164, 0, 'auto_h92cer6n', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:11:10'),
(165, 0, 'auto_2jnjcxoe', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:11:14'),
(166, 0, 'auto_2cmmldby', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:11:25'),
(167, 0, 'auto_esi5zej2', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:13:57'),
(168, 0, 'auto_5fandq70', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:14:00'),
(169, 0, 'auto_0pou99vh', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:15:51'),
(170, 0, 'auto_edl1468h', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:16:28'),
(171, 0, 'auto_3dqste62', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:16:31'),
(172, 0, 'auto_hagth9bl', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:18:31'),
(173, 0, 'auto_g35nsyad', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:18:35');
INSERT INTO `qr_scan_logs` (`id`, `qr_id`, `tracking_code`, `short_code`, `qr_url`, `type`, `target_id`, `user_agent`, `os`, `device_type`, `browser`, `ip_address`, `referer`, `scan_source`, `is_unique`, `country`, `city`, `latitude`, `longitude`, `phone_number`, `created_at`) VALUES
(174, 0, 'auto_x7p2bnx3', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:18:40'),
(175, 0, 'auto_5t9fe3ok', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:18:44'),
(176, 0, 'auto_4ti0g626', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:18:47'),
(177, 0, 'auto_1ntifg5s', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:20:12'),
(178, 0, 'auto_d4owrhof', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:20:16'),
(179, 0, 'auto_bt4ii05u', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:22:55'),
(180, 0, 'auto_1aee1o48', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:22:56'),
(181, 0, 'auto_kvi2hrtg', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:22:58'),
(182, 0, 'auto_jwvvhqsf', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:23:11'),
(183, 0, 'auto_4teambm6', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:23:42'),
(184, 0, 'auto_87u5vfwk', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:27:20'),
(185, 0, 'auto_rpa0szfh', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:28:36'),
(186, 0, 'auto_p58mhgdz', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:31:40'),
(187, 0, 'auto_r924rq1t', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:36:48'),
(188, 0, 'auto_ua8xbi69', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:38:33'),
(189, 0, 'auto_4ofnb9ub', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:38:47'),
(190, 0, 'auto_cyczq1lb', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:39:51'),
(191, 0, 'auto_xyb51pex', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:39:54'),
(192, 0, 'auto_5g0knipg', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:42:33'),
(193, 0, 'auto_u5cq5izz', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:44:27'),
(194, 0, 'auto_nuoxuu01', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:45:14'),
(195, 0, 'auto_wven525l', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:45:33'),
(196, 0, 'auto_5i1gntxy', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:46:02'),
(197, 0, 'auto_7m5yjpay', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:47:47'),
(198, 0, 'auto_f7dxrtjm', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 02:48:05'),
(199, 0, 'auto_0bk4hoem', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:02:17'),
(200, 0, 'auto_y5vf42s8', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:02:22'),
(201, 0, 'auto_9csx2twe', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:02:25'),
(202, 0, 'auto_olk2trai', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:03:31'),
(203, 0, 'auto_l90p5ub5', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:03:57'),
(204, 0, 'auto_oju110lg', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:04:02'),
(205, 0, 'auto_66mvbvzn', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:04:04'),
(206, 0, 'auto_433tmd5e', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:05:55'),
(207, 0, 'auto_h1csbp9y', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:06:16'),
(208, 0, 'auto_bsalvs86', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:06:30'),
(209, 0, 'auto_rduph0yc', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:06:45'),
(210, 0, 'auto_o0xqd4p7', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:07:28'),
(211, 0, 'auto_9cbq71lx', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:07:49'),
(212, 0, 'auto_vxux36cg', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:10:17'),
(213, 0, 'auto_8zw778oi', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:30:49'),
(214, 0, 'auto_xt562m8i', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:31:24'),
(215, 0, 'auto_tcoz7qsq', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:35:40'),
(216, 0, 'auto_f7cn0c6d', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:46:45'),
(217, 0, 'auto_ahdgth63', 'a2868812', 'https://qrcode.io/d9c0c74a', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:48:44'),
(218, 0, 'auto_hpk0q7vc', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:48:58'),
(219, 0, 'auto_wqhdgfw2', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:50:53'),
(220, 0, 'auto_868keqo5', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:50:57'),
(221, 0, 'auto_w2g34km1', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:53:17'),
(222, 0, 'auto_1iai5iez', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:53:28'),
(223, 0, 'auto_3clyaumo', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:53:35'),
(224, 0, 'auto_8parzrin', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:55:00'),
(225, 0, 'auto_5ekkzv8m', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:55:17'),
(226, 0, 'auto_cpl6eeb5', '31b1ff2f', 'https://qrcode.io/d9c0bb17', 'product', 6, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:55:44'),
(227, 0, 'auto_jt8g8qvu', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:56:26'),
(228, 0, 'auto_mjljws9y', 'beaf3e3a', 'https://qrcode.io/d9bff865', 'product', 5, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:56:30'),
(229, 0, 'auto_tkz8dj53', 'bdb48b5e', 'https://qrcode.io/d9c0dad3', 'product', 9, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36', 'Windows', 'Desktop', 'Chrome', '127.0.0.1', 'http://qrcode.io/', 'chrome', 1, '1', '1', 1, 1, NULL, '2025-05-07 03:56:49');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` int NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
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
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
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
-- Table structure for table `stores`
--

CREATE TABLE `stores` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `logo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `website` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `display_settings` text COLLATE utf8mb4_unicode_ci,
  `status` tinyint(1) DEFAULT '1',
  `product_ids` text COLLATE utf8mb4_unicode_ci
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stores`
--

INSERT INTO `stores` (`id`, `user_id`, `name`, `logo`, `address`, `phone`, `email`, `website`, `description`, `created_at`, `updated_at`, `display_settings`, `status`, `product_ids`) VALUES
(1, 1, 'demo 1', 'http://assets.giang.test/image/1745041561_cfb1a46ffe8605a53362.png', 'acb xyz', '0387409300', 'doangiang665@gmail.com', NULL, '<p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">- Xuất xứ : Trung Quốc</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Thiết kế nhỏ gọn, vừa tầm tay.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Các phím to, rõ, dễ nhìn, không bị phai mờ theo thời gian.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Sử dụng 2 pin AAA, không cần thiết lập cài đặt.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-Khoảng cách khiển lên đến 8m.</span></p><p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">-An toàn cho người sử dụng.</span></p><p><br></p>', '2025-04-19 04:05:19', '2025-04-29 04:38:18', '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"3\",\"4\",\"5\",\"6\",\"9\",\"2\"],\"company\":\"selected\",\"selectedCompanies\":[\"1\"],\"store\":\"all\",\"selectedStores\":[\"1\"],\"enableSurvey\":false,\"selectedSurveys\":[],\"enableOrderButton\":true,\"topProductsMode\":\"selected\",\"topProducts\":[\"2\",\"3\",\"5\"]}', 1, '[\"3\",\"4\",\"5\",\"6\",\"9\",\"2\"]'),
(2, 3, 'Cửa hàng demo 2', 'http://assets.giang.test/image/1745508366_fbe589f048b5b352163e.png', 'tây mỗ, nam từ liêm', '0387409300', 'doangiang665@gmail.com', NULL, '<p><span style=\"background-color: rgb(255, 255, 255); color: rgba(0, 0, 0, 0.8);\">Kệ để màn hình máy tính Homeline kệ để PC decor bàn làm việc, bàn học chất liệu gỗ MDF cao cấp chống xước - D48</span></p>', '2025-04-24 15:26:22', '2025-04-24 15:26:22', NULL, 1, '[\"10\",\"11\"]'),
(3, 3, 'Cửa hàng tạp hóa pew pew', 'http://assets.giang.test/image/1745514221_cc7f4778e22f25f9e86b.jpg', 'nam từ liêm, hà nội', '0387409300', 'doangiang665@gmail.com', NULL, '<p>cửa hàng tạp hóa 10k</p>', '2025-04-24 17:03:43', '2025-04-24 17:03:43', NULL, 1, '[]'),
(4, 1, 'cửa hàng 2', 'http://assets.giang.test/image/1745902592_23ccb866515a39eacc0f.jpg', 'tay mo nam tu liem', '0387409300', 'giang@gmail.com', NULL, '', '2025-04-29 04:56:33', '2025-04-29 04:56:51', '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"4\"],\"company\":\"selected\",\"selectedCompanies\":[\"1\"],\"store\":\"all\",\"selectedStores\":[\"1\",\"4\"],\"enableSurvey\":false,\"selectedSurveys\":[],\"enableOrderButton\":true,\"topProductsMode\":\"selected\",\"topProducts\":[\"2\"]}', 1, '[\"4\"]'),
(5, 1, 'gggggggg', 'http://assets.giang.test/image/1746258587_08836e9fa786a9d22f76.png', 'xuan thuy, cau giay', '0387409300', 'qe@gmail.com', NULL, '<p>gggggggggggggg</p>', '2025-05-03 06:23:25', '2025-05-03 14:34:13', '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"3\",\"4\",\"6\"],\"company\":\"selected\",\"selectedCompanies\":[\"4\"],\"store\":\"all\",\"selectedStores\":[\"1\",\"4\",\"5\",\"6\",\"7\"],\"enableSurvey\":false,\"selectedSurveys\":[],\"enableOrderButton\":true,\"topProductsMode\":\"selected\",\"topProducts\":[\"1\",\"2\",\"4\"]}', 1, '[\"3\",\"4\",\"6\"]'),
(6, 1, 'xxxxx', 'http://assets.giang.test/image/1746254862_8f14809456d38f343fe2.jpg', 'le duc tho nam tu liem ha noi', '0387409300', 'xxx@gmail.com', NULL, '<p><br></p>', '2025-05-03 06:34:23', '2025-05-03 06:51:14', '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"selected\",\"selectedProducts\":[\"3\"],\"company\":\"selected\",\"selectedCompanies\":[\"1\"],\"store\":\"all\",\"selectedStores\":[\"1\",\"4\",\"5\",\"6\",\"7\"],\"enableSurvey\":false,\"selectedSurveys\":[],\"enableOrderButton\":true,\"topProductsMode\":\"selected\",\"topProducts\":[\"2\"]}', 1, '[\"3\"]'),
(7, 1, 'xxxxxxxxxx', 'http://assets.giang.test/image/1746254261_fc9580dbd75aa45ed9b1.jpg', 'tay mo', '0387409300', 'giang@gmail.com', NULL, '<p><br></p>', '2025-05-03 06:37:42', '2025-05-03 08:56:19', '{\"selectedTemplate\":\"tpl-1\",\"relatedProducts\":\"all\",\"selectedProducts\":[\"1\",\"2\",\"3\",\"4\",\"5\",\"6\",\"9\"],\"company\":\"all\",\"selectedCompanies\":[\"1\",\"4\"],\"store\":\"all\",\"selectedStores\":[\"1\",\"4\",\"5\",\"6\",\"7\"],\"enableSurvey\":false,\"selectedSurveys\":[],\"enableOrderButton\":true,\"topProductsMode\":\"all\",\"topProducts\":[\"1\",\"2\",\"3\",\"4\",\"5\",\"6\",\"9\"]}', 1, '[\"1\",\"2\",\"3\",\"4\",\"5\",\"6\",\"9\"]');

-- --------------------------------------------------------

--
-- Table structure for table `surveys`
--

CREATE TABLE `surveys` (
  `id` bigint NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `group_id` bigint DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `status` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int UNSIGNED NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `role` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'user',
  `role_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `created_at`, `updated_at`, `name`, `phone`, `avatar`, `role`, `role_id`) VALUES
(1, 'demo@example.com', '$2y$10$X0AYs8k7Dw8fbMqF9DzxiuBhQzGzu.ehudtC.2SWOjA4tsTZK0sYG', '2025-04-07 18:49:01', '2025-04-20 23:49:00', 'Demo User', '0123456789', 'avatar.png', 'user', 2),
(3, 'superadmin@example.com', '$2y$10$X0AYs8k7Dw8fbMqF9DzxiuBhQzGzu.ehudtC.2SWOjA4tsTZK0sYG', '2025-04-20 14:02:38', '2025-04-21 00:21:49', 'Super Admin', '0988888888', NULL, 'super admin', 1);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `businesses`
--
ALTER TABLE `businesses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `business_extra_info`
--
ALTER TABLE `business_extra_info`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `entity_images`
--
ALTER TABLE `entity_images`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `landing_pages`
--
ALTER TABLE `landing_pages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loyalty_gifts`
--
ALTER TABLE `loyalty_gifts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loyalty_histories`
--
ALTER TABLE `loyalty_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loyalty_participation_logs`
--
ALTER TABLE `loyalty_participation_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loyalty_programs`
--
ALTER TABLE `loyalty_programs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `loyalty_vouchers`
--
ALTER TABLE `loyalty_vouchers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `loyalty_winner_logs`
--
ALTER TABLE `loyalty_winner_logs`
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
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_attributes`
--
ALTER TABLE `product_attributes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `purchase_histories`
--
ALTER TABLE `purchase_histories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `qr_codes`
--
ALTER TABLE `qr_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `qr_id` (`qr_id`);

--
-- Indexes for table `qr_links`
--
ALTER TABLE `qr_links`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `short_code` (`short_code`);

--
-- Indexes for table `qr_scan_logs`
--
ALTER TABLE `qr_scan_logs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `tracking_code` (`tracking_code`);

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
-- Indexes for table `stores`
--
ALTER TABLE `stores`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `surveys`
--
ALTER TABLE `surveys`
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
-- AUTO_INCREMENT for table `businesses`
--
ALTER TABLE `businesses`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `business_extra_info`
--
ALTER TABLE `business_extra_info`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `entity_images`
--
ALTER TABLE `entity_images`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `landing_pages`
--
ALTER TABLE `landing_pages`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_gifts`
--
ALTER TABLE `loyalty_gifts`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_histories`
--
ALTER TABLE `loyalty_histories`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_participation_logs`
--
ALTER TABLE `loyalty_participation_logs`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_programs`
--
ALTER TABLE `loyalty_programs`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_vouchers`
--
ALTER TABLE `loyalty_vouchers`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `loyalty_winner_logs`
--
ALTER TABLE `loyalty_winner_logs`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

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
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `product_attributes`
--
ALTER TABLE `product_attributes`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `purchase_histories`
--
ALTER TABLE `purchase_histories`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `qr_codes`
--
ALTER TABLE `qr_codes`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `qr_links`
--
ALTER TABLE `qr_links`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `qr_scan_logs`
--
ALTER TABLE `qr_scan_logs`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=230;

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
-- AUTO_INCREMENT for table `stores`
--
ALTER TABLE `stores`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `surveys`
--
ALTER TABLE `surveys`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
