DROP TABLE IF EXISTS `simmer_test`.`agents`;

CREATE TABLE `simmer_test`.`agents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `call_sign` varchar(150) NOT NULL,
  `first` varchar(255) DEFAULT NULL,
  `last` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `call_sign` (`call_sign`)
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4;

DROP TABLE IF EXISTS `simmer_test`.`notes`;

CREATE TABLE `simmer_test`.`notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_id` int(11) NOT NULL,
  `note` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `agent_id` (`agent_id`),
  CONSTRAINT `notes_ibfk_1` FOREIGN KEY (`agent_id`) REFERENCES `agents` (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

DROP TABLE IF EXISTS `simmer_test`.`table`;

CREATE TABLE `simmer_test`.`table` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `column` varchar(30) NOT NULL,
  `count` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE = InnoDB AUTO_INCREMENT = 3 DEFAULT CHARSET = utf8mb4;
