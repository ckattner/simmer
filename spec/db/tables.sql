DROP TABLE IF EXISTS `simmer_test`.`notes`;
DROP TABLE IF EXISTS `simmer_test`.`agents`;

CREATE TABLE `simmer_test`.`agents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `call_sign` varchar(150) NOT NULL,
  `first` varchar(255),
  `last` varchar(255),
  PRIMARY KEY (`id`),
  UNIQUE INDEX (`call_sign`)
);

CREATE TABLE `simmer_test`.`notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_id` int(11) NOT NULL,
  `note` varchar(255),
  PRIMARY KEY (`id`),
  INDEX (`agent_id`),
  FOREIGN KEY (`agent_id`) REFERENCES `simmer_test`.`agents`(`id`)
);
