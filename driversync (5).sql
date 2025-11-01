-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 25, 2025 at 10:33 AM
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
-- Database: `driversync`
--

-- --------------------------------------------------------

--
-- Table structure for table `admindashboard`
--

CREATE TABLE `admindashboard` (
  `id` int(50) NOT NULL,
  `userid` int(50) NOT NULL,
  `availability` varchar(50) NOT NULL,
  `availability_date` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admindashboard`
--

INSERT INTO `admindashboard` (`id`, `userid`, `availability`, `availability_date`) VALUES
(1, 6, 'Yes', '2025-01-07');

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE `cars` (
  `id` int(50) NOT NULL,
  `userid` int(11) NOT NULL,
  `car_name` text NOT NULL,
  `image_path` text NOT NULL,
  `condition` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cars`
--

INSERT INTO `cars` (`id`, `userid`, `car_name`, `image_path`, `condition`) VALUES
(1, 6, '0', 'uploads/toyota_corolla.jpg', 'New'),
(2, 6, 'Toyota Corolla', 'uploads/toyota_corolla.jpg', 'New'),
(3, 6, 'Toyota Corolla new', 'uploads/toyota_corolla.jpg', 'New');

-- --------------------------------------------------------

--
-- Table structure for table `driverinfo`
--

CREATE TABLE `driverinfo` (
  `id` int(11) NOT NULL,
  `userid` varchar(50) NOT NULL,
  `age` int(50) NOT NULL,
  `experienceyears` int(50) NOT NULL,
  `contactnumber` int(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `driverinfo`
--

INSERT INTO `driverinfo` (`id`, `userid`, `age`, `experienceyears`, `contactnumber`) VALUES
(1, '6', 56, 15, 1234567890),
(2, '101', 35, 10, 1234567890),
(3, '23', 25, 9, 2147483647);

-- --------------------------------------------------------

--
-- Table structure for table `drivers`
--

CREATE TABLE `drivers` (
  `id` int(50) NOT NULL,
  `userid` int(50) NOT NULL,
  `availability_date` date NOT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pricepage`
--

CREATE TABLE `pricepage` (
  `id` int(50) NOT NULL,
  `origin` varchar(50) NOT NULL,
  `destination` varchar(50) NOT NULL,
  `price_per_day` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pricepage`
--

INSERT INTO `pricepage` (`id`, `origin`, `destination`, `price_per_day`) VALUES
(1, 'kanchipuram', 'chennai', 950.00),
(2, 'kanchipuram', 'vellore', 2800.00),
(3, 'kanchipuram', 'chengalpet', 2000.00),
(4, 'kanchipuram', 'Thiruvannamalai', 2900.00),
(5, 'kanchipuram', 'Villupuram', 3000.00),
(6, 'kanchipuram', 'Bangalore', 3500.00),
(7, 'kanchipuram', 'Tirupati', 3500.00),
(8, 'kanchipuram', 'Pondicherry', 2500.00),
(9, 'Chennai', 'Chengalpet', 2000.00),
(10, 'Chennai', 'Thiruvannamalai', 3000.00),
(11, 'Chennai', 'Villupuram', 2500.00),
(12, 'Chennai', 'Bangalore', 3800.00),
(13, 'Chennai', 'Tirupati', 3800.00),
(14, 'Chennai', 'Vellore', 2500.00),
(15, 'Chennai', 'Pondicherry', 2700.00),
(16, 'Chengalpet', 'Thiruvannamalai', 2800.00),
(17, 'Chengalpet', 'Villupuram', 2900.00),
(18, 'Chengalpet', 'Bangalore', 3800.00),
(19, 'Chengalpet', 'Tirupati', 4000.00),
(20, 'Chengalpet', 'Vellore', 2800.00),
(21, 'Chengalpet', 'Pondicherry', 3200.00),
(22, 'Thiruvannamalai', 'Villupuram', 2200.00),
(23, 'Thiruvannamalai', 'Bangalore', 3500.00),
(24, 'Thiruvannamalai', 'Tirupati', 3800.00),
(25, 'Thiruvannamalai', 'Vellore', 2500.00),
(28, 'Thiruvannamalai', 'Pondicherry', 3700.00),
(29, 'Villupuram', 'Bangalore', 3700.00),
(30, 'Villupuram', 'Tirupati', 3900.00),
(31, 'Villupuram', 'Vellore', 2600.00),
(32, 'Villupuram', 'Pondicherry', 3800.00),
(33, 'Bangalore', 'Tirupati', 2800.00),
(34, 'Bangalore', 'Vellore', 3700.00),
(35, 'Bangalore', 'Pondicherry', 4200.00),
(36, 'Thirupati', 'Vellore', 3800.00),
(37, 'Thirupati', 'Pondicherry', 4300.00),
(38, 'Vellore', 'Pondicherry', 3500.00),
(40, 'kanchipuram', 'Kanchipuram', 500.00),
(41, 'Chennai', 'Chennai', 500.00),
(42, 'Thiruvannamalai', 'Thiruvannamalai', 500.00),
(43, 'Chengalpet', 'Chengalpet', 500.00),
(44, 'Villupuram', 'Villupuram', 500.00),
(45, 'Bangalore', 'Bangalore', 500.00),
(46, 'Vellore', 'Vellore', 500.00),
(47, 'Pondicherry', 'Pondicherry', 500.00);

-- --------------------------------------------------------

--
-- Table structure for table `signup`
--

CREATE TABLE `signup` (
  `id` int(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `role` varchar(50) NOT NULL DEFAULT 'User',
  `password` varchar(255) NOT NULL,
  `contact_number` int(11) NOT NULL,
  `image_path` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `signup`
--

INSERT INTO `signup` (`id`, `name`, `username`, `email`, `role`, `password`, `contact_number`, `image_path`) VALUES
(1, 'TamizhAzhagan', 'tamizh06', 'azhagantamizh47@gmail.com', 'User', '1234', 0, ''),
(4, 'John Doe', 'Admin', 'admin@gmail.com', 'Admin', 'admin', 0, ''),
(5, 'John Doe', 'johndoe1234', 'johndoe@example.com', 'User', 'yourpassword', 0, ''),
(6, 'suhail', 'Driver', 'driver@gmail.com', 'Driver', 'yourpassword', 0, ''),
(7, 'John Doe', 'Driver1', 'driver1@gmail.com', 'Driver', 'yourpassword', 0, ''),
(23, 'don', 'don89', 'don@gmail.com', 'Driver', '9632', 2147483647, 'uploads/upload6705940068095316261.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `usersi`
--

CREATE TABLE `usersi` (
  `id` int(50) NOT NULL,
  `userid` int(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `availability_date` date NOT NULL,
  `image_path` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admindashboard`
--
ALTER TABLE `admindashboard`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cars`
--
ALTER TABLE `cars`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `driverinfo`
--
ALTER TABLE `driverinfo`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pricepage`
--
ALTER TABLE `pricepage`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `signup`
--
ALTER TABLE `signup`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `usersi`
--
ALTER TABLE `usersi`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admindashboard`
--
ALTER TABLE `admindashboard`
  MODIFY `id` int(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `id` int(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `driverinfo`
--
ALTER TABLE `driverinfo`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `pricepage`
--
ALTER TABLE `pricepage`
  MODIFY `id` int(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=48;

--
-- AUTO_INCREMENT for table `signup`
--
ALTER TABLE `signup`
  MODIFY `id` int(50) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `usersi`
--
ALTER TABLE `usersi`
  MODIFY `id` int(50) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
