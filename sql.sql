CREATE DATABASE IF NOT EXISTS `extendedmode` /*!40100 DEFAULT CHARACTER SET utf8mb4 */;
USE `extendedmode`;

CREATE TABLE IF NOT EXISTS `bz_ban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `tarih` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;