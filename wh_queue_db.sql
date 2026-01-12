-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 12, 2026 at 02:31 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `wh_queue_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` int(11) NOT NULL,
  `sales_name` varchar(100) DEFAULT NULL,
  `customer_name` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `product_detail` text DEFAULT NULL,
  `zone` varchar(5) NOT NULL,
  `booking_date` date NOT NULL,
  `time_slot` varchar(20) NOT NULL,
  `booking_type` enum('normal','insert') DEFAULT 'normal',
  `status` enum('pending_approval','confirmed','rejected') DEFAULT 'pending_approval',
  `tech_status` enum('waiting','accepted','completed') DEFAULT 'waiting',
  `tech_name` varchar(100) DEFAULT NULL,
  `tech_start_time` datetime DEFAULT NULL,
  `tech_end_time` datetime DEFAULT NULL,
  `photo_proof` varchar(255) DEFAULT NULL,
  `lat` double DEFAULT NULL,
  `lng` double DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `sales_name`, `customer_name`, `phone`, `product_detail`, `zone`, `booking_date`, `time_slot`, `booking_type`, `status`, `tech_status`, `tech_name`, `tech_start_time`, `tech_end_time`, `photo_proof`, `lat`, `lng`, `created_at`) VALUES
(1, 'ພະນັກງານຂາຍ 1', 'guk', 'gku', 'gk', 'B', '2026-01-11', '09:00-11:00', 'normal', 'confirmed', 'completed', 'ຊ່າງ ແກ້ວ (Tech)', '2026-01-12 04:56:24', '2026-01-12 04:56:34', '1768168594_47676956d033984d24e361487c12e79c.jpg', 17.966, 102.613, '2026-01-11 21:46:39');

-- --------------------------------------------------------

--
-- Table structure for table `slot_configs`
--

CREATE TABLE `slot_configs` (
  `id` int(11) NOT NULL,
  `zone` varchar(5) NOT NULL,
  `time_slot` varchar(20) NOT NULL,
  `config_date` date NOT NULL,
  `max_limit` int(11) DEFAULT 3
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `slot_configs`
--

INSERT INTO `slot_configs` (`id`, `zone`, `time_slot`, `config_date`, `max_limit`) VALUES
(1, 'B', '09:00-11:00', '2026-01-11', 5);

-- --------------------------------------------------------

--
-- Table structure for table `tech_locations`
--

CREATE TABLE `tech_locations` (
  `id` int(11) NOT NULL,
  `lat` double NOT NULL,
  `lng` double NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tech_locations`
--

INSERT INTO `tech_locations` (`id`, `lat`, `lng`, `updated_at`) VALUES
(1, 17.983282499869702, 102.62938719248832, '2026-01-11 21:59:34');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `fullname` varchar(100) NOT NULL,
  `role` enum('admin','sales','tech') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `fullname`, `role`, `created_at`) VALUES
(1, 'admin', '1234', 'ຜູ້ດູແລລະບົບ', 'admin', '2026-01-11 21:45:05'),
(2, 'sale1', '1234', 'ພະນັກງານຂາຍ 1', 'sales', '2026-01-11 21:45:05'),
(3, 'tech1', '1234', 'ຊ່າງຕິດຕັ້ງ 1', 'tech', '2026-01-11 21:45:05');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `slot_configs`
--
ALTER TABLE `slot_configs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `zone` (`zone`,`time_slot`,`config_date`);

--
-- Indexes for table `tech_locations`
--
ALTER TABLE `tech_locations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `slot_configs`
--
ALTER TABLE `slot_configs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
