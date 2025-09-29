-- MySQL dump 10.13  Distrib 8.0.43, for Linux (x86_64)
--
-- Host: localhost    Database: Sene_db
-- ------------------------------------------------------
-- Server version	8.0.43-0ubuntu0.24.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_code` varchar(50) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `telephone` varchar(20) NOT NULL,
  `ve_id` int NOT NULL,
  `village_id` int NOT NULL,
  `date_inscription` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `client_code` (`client_code`),
  KEY `ve_id` (`ve_id`),
  KEY `village_id` (`village_id`),
  CONSTRAINT `clients_ibfk_1` FOREIGN KEY (`ve_id`) REFERENCES `ve` (`id`),
  CONSTRAINT `clients_ibfk_2` FOREIGN KEY (`village_id`) REFERENCES `villages` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `paiements`
--

DROP TABLE IF EXISTS `paiements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `paiements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `client_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `montant` decimal(10,2) NOT NULL,
  `date_paiement` date NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `client_id` (`client_id`),
  CONSTRAINT `paiements_ibfk_1` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `paiements`
--

LOCK TABLES `paiements` WRITE;
/*!40000 ALTER TABLE `paiements` DISABLE KEYS */;
/*!40000 ALTER TABLE `paiements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'manage_users','Créer et gérer les utilisateurs'),(2,'manage_ves','Créer et gérer les VEs'),(3,'manage_clients','Créer et gérer les clients'),(4,'manage_paiements','Créer et gérer les paiements');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` enum('ADMIN','USER','VE') NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'ADMIN'),(2,'USER'),(3,'VE');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles_permissions`
--

DROP TABLE IF EXISTS `roles_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles_permissions` (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `permission_id` (`permission_id`),
  CONSTRAINT `roles_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`),
  CONSTRAINT `roles_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles_permissions`
--

LOCK TABLES `roles_permissions` WRITE;
/*!40000 ALTER TABLE `roles_permissions` DISABLE KEYS */;
INSERT INTO `roles_permissions` VALUES (1,1),(1,2),(2,2),(1,3),(3,3),(1,4),(3,4);
/*!40000 ALTER TABLE `roles_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('ADMIN','USER','VE') DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin1','$2b$10$77qSEms43R14gQ.K04qJVeVGaDIvNEDTNTbj0jbrLR.ykTWp47t4y','ADMIN','2025-09-17 19:10:36'),(2,'assansv1-v01','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(3,'bakarysv1-v02','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(4,'issasv1-v03','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(5,'bakaminesv1-v04','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(6,'moussasv1-v05','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(7,'fatoumatasv1-v06','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(8,'soumailasv1-v07','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(9,'karamokosv2-v08','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(10,'mamoutousv2-v09','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(11,'mamahsv2-v10','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(12,'saliasv2-v11','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(13,'bouramasv2-v12','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(14,'fatoumatasv2-v13','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(15,'mayesv2-v14','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(16,'bamorysv3-v15','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(17,'amidousv3-v16','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(18,'adamasv3-v17','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(19,'bouramasv3-v18','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(20,'sidisv3-v19','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(21,'tayirousv3-v20','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(22,'nènèsv3-v21','$2b$10$dLQMvp.NOJEQxbNWb6tf0eMDej.l2cfUJYjD8MH88SZgWSuxyXY2.','VE','2025-09-29 16:52:26'),(33,'ibrahima.thiero','$2b$10$Xr0f2LvkLP9XZf8eVZyp.uM6utP7g4ImpDBpBpUhoamTilnF1sOBy','ADMIN','2025-09-29 17:24:40'),(34,'dramane.diarra','$2b$10$Xr0f2LvkLP9XZf8eVZyp.uM6utP7g4ImpDBpBpUhoamTilnF1sOBy','ADMIN','2025-09-29 17:24:40'),(35,'makan.keita','$2b$10$Xr0f2LvkLP9XZf8eVZyp.uM6utP7g4ImpDBpBpUhoamTilnF1sOBy','ADMIN','2025-09-29 17:24:40');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ve`
--

DROP TABLE IF EXISTS `ve`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ve` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ve_code` varchar(50) NOT NULL,
  `ve_commercant_id` varchar(50) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `prenom` varchar(100) NOT NULL,
  `user_id` int DEFAULT NULL,
  `village_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ve_code` (`ve_code`),
  UNIQUE KEY `ve_commercant_id` (`ve_commercant_id`),
  KEY `user_id` (`user_id`),
  KEY `fk_ve_village` (`village_id`),
  CONSTRAINT `fk_ve_village` FOREIGN KEY (`village_id`) REFERENCES `villages` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `ve_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ve`
--

LOCK TABLES `ve` WRITE;
/*!40000 ALTER TABLE `ve` DISABLE KEYS */;
INSERT INTO `ve` VALUES (1,'SV1-V01','SV1-V01','Assan','Diaye',2,2,'2025-09-28 22:48:17'),(2,'SV1-V02','SV1-V02','Bakary','Traoré',3,3,'2025-09-28 22:48:17'),(3,'SV1-V03','SV1-V03','Issa','Cissé',4,4,'2025-09-28 22:48:17'),(4,'SV1-V04','SV1-V04','Bakamine','Coulibaly',5,5,'2025-09-28 22:48:17'),(5,'SV1-V05','SV1-V05','Moussa','Traoré',6,6,'2025-09-28 22:48:17'),(6,'SV1-V06','SV1-V06','Fatoumata','Diallo',7,7,'2025-09-28 22:48:17'),(7,'SV1-V07','SV1-V07','Soumaila','Fofana',8,8,'2025-09-28 22:48:17'),(8,'SV2-V08','SV2-V08','Karamoko','Diarra',9,14,'2025-09-28 22:48:17'),(9,'SV2-V09','SV2-V09','Mamoutou','Diarra',10,15,'2025-09-28 22:48:17'),(10,'SV2-V10','SV2-V10','Mamah','Coulibaly',11,12,'2025-09-28 22:48:17'),(11,'SV2-V11','SV2-V11','Salia','Bouaré',12,13,'2025-09-28 22:48:17'),(12,'SV2-V12','SV2-V12','Bourama','Dembélé',13,9,'2025-09-28 22:48:17'),(13,'SV2-V13','SV2-V13','Fatoumata','Diabaté',14,10,'2025-09-28 22:48:17'),(14,'SV2-V14','SV2-V14','Maye','Sangarè',15,11,'2025-09-28 22:48:17'),(15,'SV3-V15','SV3-V15','Bamory','Marico',16,16,'2025-09-28 22:48:17'),(16,'SV3-V16','SV3-V16','Amidou','Dembélé',17,18,'2025-09-28 22:48:17'),(17,'SV3-V17','SV3-V17','Adama','Sangarè',18,19,'2025-09-28 22:48:17'),(18,'SV3-V18','SV3-V18','Bourama','Sangarè',19,20,'2025-09-28 22:48:17'),(19,'SV3-V19','SV3-V19','Sidi','Sangarè',20,1,'2025-09-28 22:48:17'),(20,'SV3-V20','SV3-V20','Tayirou','Sangarè',21,21,'2025-09-28 22:48:17'),(21,'SV3-V21','SV3-V21','Nènè','Diarra',22,17,'2025-09-28 22:48:17');
/*!40000 ALTER TABLE `ve` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ve_villages`
--

DROP TABLE IF EXISTS `ve_villages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ve_villages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ve_id` int NOT NULL,
  `village_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ve_id` (`ve_id`,`village_id`),
  KEY `village_id` (`village_id`),
  CONSTRAINT `ve_villages_ibfk_1` FOREIGN KEY (`ve_id`) REFERENCES `ve` (`id`),
  CONSTRAINT `ve_villages_ibfk_2` FOREIGN KEY (`village_id`) REFERENCES `villages` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ve_villages`
--

LOCK TABLES `ve_villages` WRITE;
/*!40000 ALTER TABLE `ve_villages` DISABLE KEYS */;
/*!40000 ALTER TABLE `ve_villages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `villages`
--

DROP TABLE IF EXISTS `villages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `villages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nom_village` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nom_village` (`nom_village`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `villages`
--

LOCK TABLES `villages` WRITE;
/*!40000 ALTER TABLE `villages` DISABLE KEYS */;
INSERT INTO `villages` VALUES (1,'Beniena'),(2,'Berthela'),(3,'Boubou were'),(20,'Boziebougou'),(12,'Dabougou'),(16,'Degnekoro'),(14,'Diolia'),(11,'Djiffina'),(6,'Fana'),(7,'Farakoro'),(4,'Kalake Bamana'),(9,'Niamana'),(18,'Ntobougou'),(15,'Oulome'),(8,'Siana'),(17,'Sirakoro'),(10,'Sontiguïla'),(19,'Tioni'),(13,'Tonga'),(21,'Torregue'),(5,'Zanfina');
/*!40000 ALTER TABLE `villages` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-09-29 18:09:41
