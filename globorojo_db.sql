/*
SQLyog Community Edition- MySQL GUI v5.29
Host - 5.5.27 : Database - redballoon
*********************************************************************
Server version : 5.5.27
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

create database if not exists `globorojo`;

USE `globorojo`;

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

/*Table structure for table `rb_default_hashtag` */

DROP TABLE IF EXISTS `rb_default_hashtag`;

CREATE TABLE `rb_default_hashtag` (
  `rb_default_hashtag` int(11) NOT NULL AUTO_INCREMENT,
  `rb_parent_hashtag` varchar(128) NOT NULL,
  `rb_hashtag` varchar(128) NOT NULL,
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_default_hashtag`)
) ENGINE=InnoDB AUTO_INCREMENT=480 DEFAULT CHARSET=latin1;

/*Data for the table `rb_default_hashtag` */

insert  into `rb_default_hashtag`(`rb_default_hashtag`,`rb_parent_hashtag`,`rb_hashtag`,`rb_created_time`,`rb_updated_time`) values (303,'Humor','Humor','2014-06-06 20:30:08','2014-06-06 20:30:08'),(304,'Humor','Jajaja','2014-06-06 20:30:08','2014-06-06 20:30:08'),(305,'Humor','chiste','2014-06-06 20:30:08','2014-06-06 20:30:08'),(306,'Humor','lol','2014-06-06 20:30:08','2014-06-06 20:30:08'),(307,'Humor','chistoso','2014-06-06 20:30:08','2014-06-06 20:30:08'),(308,'Humor','fun','2014-06-06 20:30:08','2014-06-06 20:30:08'),(309,'Humor','divertido','2014-06-06 20:30:08','2014-06-06 20:30:08'),(310,'Humor','diversion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(311,'Humor','diversion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(312,'Prank','Prank','2014-06-06 20:30:08','2014-06-06 20:30:08'),(313,'Prank','joke','2014-06-06 20:30:08','2014-06-06 20:30:08'),(314,'Prank','broma','2014-06-06 20:30:08','2014-06-06 20:30:08'),(315,'Prank','trampa','2014-06-06 20:30:08','2014-06-06 20:30:08'),(316,'Prank','jugarreta','2014-06-06 20:30:08','2014-06-06 20:30:08'),(317,'fail','fail','2014-06-06 20:30:08','2014-06-06 20:30:08'),(318,'fail','epicfail','2014-06-06 20:30:08','2014-06-06 20:30:08'),(319,'fail','failarmy','2014-06-06 20:30:08','2014-06-06 20:30:08'),(320,'fail','pasta','2014-06-06 20:30:08','2014-06-06 20:30:08'),(321,'fail','pastel','2014-06-06 20:30:08','2014-06-06 20:30:08'),(322,'parody','parody','2014-06-06 20:30:08','2014-06-06 20:30:08'),(323,'parody','parodia','2014-06-06 20:30:08','2014-06-06 20:30:08'),(324,'parody','imitacion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(325,'parody','imitacion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(326,'parody','imitation','2014-06-06 20:30:08','2014-06-06 20:30:08'),(327,'parody','satira','2014-06-06 20:30:08','2014-06-06 20:30:08'),(328,'parody','satire','2014-06-06 20:30:08','2014-06-06 20:30:08'),(329,'Innovation','Innovation','2014-06-06 20:30:08','2014-06-06 20:30:08'),(330,'Innovation','innovacion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(331,'Innovation','innovacion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(332,'Innovation','creatividad','2014-06-06 20:30:08','2014-06-06 20:30:08'),(333,'Innovation','creativity','2014-06-06 20:30:08','2014-06-06 20:30:08'),(334,'Innovation','Inspiration','2014-06-06 20:30:08','2014-06-06 20:30:08'),(335,'Innovation','inspiracion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(336,'Innovation','inspirador','2014-06-06 20:30:08','2014-06-06 20:30:08'),(337,'Social','Social','2014-06-06 20:30:08','2014-06-06 20:30:08'),(338,'Social','Realitycheck','2014-06-06 20:30:08','2014-06-06 20:30:08'),(339,'Social','Cause','2014-06-06 20:30:08','2014-06-06 20:30:08'),(340,'Social','Charity','2014-06-06 20:30:08','2014-06-06 20:30:08'),(341,'Social','help','2014-06-06 20:30:08','2014-06-06 20:30:08'),(342,'Social','foundation','2014-06-06 20:30:08','2014-06-06 20:30:08'),(343,'Social','ayuda','2014-06-06 20:30:08','2014-06-06 20:30:08'),(344,'Social','causa','2014-06-06 20:30:08','2014-06-06 20:30:08'),(345,'Music','Music','2014-06-06 20:30:08','2014-06-06 20:30:08'),(346,'Music','cancion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(347,'Music','song','2014-06-06 20:30:08','2014-06-06 20:30:08'),(348,'Music','musica','2014-06-06 20:30:08','2014-06-06 20:30:08'),(349,'Music','musica','2014-06-06 20:30:08','2014-06-06 20:30:08'),(350,'rock','rock','2014-06-06 20:30:08','2014-06-06 20:30:08'),(351,'rock','progrock','2014-06-06 20:30:08','2014-06-06 20:30:08'),(352,'rock','progressive','2014-06-06 20:30:08','2014-06-06 20:30:08'),(353,'rock','prog','2014-06-06 20:30:08','2014-06-06 20:30:08'),(354,'rock','rockero','2014-06-06 20:30:08','2014-06-06 20:30:08'),(355,'rock','rockear','2014-06-06 20:30:08','2014-06-06 20:30:08'),(356,'HipHop','HipHop','2014-06-06 20:30:08','2014-06-06 20:30:08'),(357,'HipHop','rap','2014-06-06 20:30:08','2014-06-06 20:30:08'),(358,'HipHop','crunk','2014-06-06 20:30:08','2014-06-06 20:30:08'),(359,'Cute','Cute','2014-06-06 20:30:08','2014-06-06 20:30:08'),(360,'Cute','Love','2014-06-06 20:30:08','2014-06-06 20:30:08'),(361,'Cute','nice','2014-06-06 20:30:08','2014-06-06 20:30:08'),(362,'Cute','tierno','2014-06-06 20:30:08','2014-06-06 20:30:08'),(363,'Cute','lindo','2014-06-06 20:30:08','2014-06-06 20:30:08'),(364,'Cute','amor','2014-06-06 20:30:08','2014-06-06 20:30:08'),(365,'Cute','amoroso','2014-06-06 20:30:08','2014-06-06 20:30:08'),(366,'Cute','adorable','2014-06-06 20:30:08','2014-06-06 20:30:08'),(367,'Cars','Cars','2014-06-06 20:30:08','2014-06-06 20:30:08'),(368,'Cars','carporn','2014-06-06 20:30:08','2014-06-06 20:30:08'),(369,'Cars','hypercar','2014-06-06 20:30:08','2014-06-06 20:30:08'),(370,'Cars','supercar','2014-06-06 20:30:08','2014-06-06 20:30:08'),(371,'Cars','supercars','2014-06-06 20:30:08','2014-06-06 20:30:08'),(372,'Cars','germancar','2014-06-06 20:30:08','2014-06-06 20:30:08'),(373,'motorsport','motorsport','2014-06-06 20:30:08','2014-06-06 20:30:08'),(374,'motorsport','motorsports','2014-06-06 20:30:08','2014-06-06 20:30:08'),(375,'motorsport','rally','2014-06-06 20:30:08','2014-06-06 20:30:08'),(376,'motorsport','rallye','2014-06-06 20:30:08','2014-06-06 20:30:08'),(377,'motorsport','wrc','2014-06-06 20:30:08','2014-06-06 20:30:08'),(378,'motorsport','lemans','2014-06-06 20:30:08','2014-06-06 20:30:08'),(379,'motorsport','racing','2014-06-06 20:30:08','2014-06-06 20:30:08'),(380,'motorsport','carrera','2014-06-06 20:30:08','2014-06-06 20:30:08'),(381,'motorsport','circuito','2014-06-06 20:30:08','2014-06-06 20:30:08'),(382,'Nature','Nature','2014-06-06 20:30:08','2014-06-06 20:30:08'),(383,'Nature','naturaleza','2014-06-06 20:30:08','2014-06-06 20:30:08'),(384,'Nature','animales','2014-06-06 20:30:08','2014-06-06 20:30:08'),(385,'Nature','planeta','2014-06-06 20:30:08','2014-06-06 20:30:08'),(386,'Nature','planet','2014-06-06 20:30:08','2014-06-06 20:30:08'),(387,'Nature','tierra','2014-06-06 20:30:08','2014-06-06 20:30:08'),(388,'Nature','earth','2014-06-06 20:30:08','2014-06-06 20:30:08'),(389,'Nature','animals','2014-06-06 20:30:08','2014-06-06 20:30:08'),(390,'Sports','Sports','2014-06-06 20:30:08','2014-06-06 20:30:08'),(391,'Sports','deporte','2014-06-06 20:30:08','2014-06-06 20:30:08'),(392,'Sports','ejercicio','2014-06-06 20:30:08','2014-06-06 20:30:08'),(393,'cycling','cycling','2014-06-06 20:30:08','2014-06-06 20:30:08'),(394,'cycling','bicycle','2014-06-06 20:30:08','2014-06-06 20:30:08'),(395,'cycling','bike','2014-06-06 20:30:08','2014-06-06 20:30:08'),(396,'cycling','baik','2014-06-06 20:30:08','2014-06-06 20:30:08'),(397,'fixie','fixie','2014-06-06 20:30:08','2014-06-06 20:30:08'),(398,'fixie','fijo','2014-06-06 20:30:08','2014-06-06 20:30:08'),(399,'fixie','fixedgear','2014-06-06 20:30:08','2014-06-06 20:30:08'),(400,'fixie','pinonfijo','2014-06-06 20:30:08','2014-06-06 20:30:08'),(401,'football','football','2014-06-06 20:30:08','2014-06-06 20:30:08'),(402,'football','futbol','2014-06-06 20:30:08','2014-06-06 20:30:08'),(403,'football','pelota','2014-06-06 20:30:08','2014-06-06 20:30:08'),(404,'football','gol','2014-06-06 20:30:08','2014-06-06 20:30:08'),(405,'football','delantero','2014-06-06 20:30:08','2014-06-06 20:30:08'),(406,'football','arquero','2014-06-06 20:30:08','2014-06-06 20:30:08'),(407,'football','defensa','2014-06-06 20:30:08','2014-06-06 20:30:08'),(408,'wc2014','wc2014','2014-06-06 20:30:08','2014-06-06 20:30:08'),(409,'wc2014','worldcup','2014-06-06 20:30:08','2014-06-06 20:30:08'),(410,'wc2014','mundial','2014-06-06 20:30:08','2014-06-06 20:30:08'),(411,'wc2014','copadelmundo','2014-06-06 20:30:08','2014-06-06 20:30:08'),(412,'Tech','Tech','2014-06-06 20:30:08','2014-06-06 20:30:08'),(413,'Tech','technology','2014-06-06 20:30:08','2014-06-06 20:30:08'),(414,'Tech','technologic','2014-06-06 20:30:08','2014-06-06 20:30:08'),(415,'Tech','tecnologia','2014-06-06 20:30:08','2014-06-06 20:30:08'),(416,'Tech','tecnologia','2014-06-06 20:30:08','2014-06-06 20:30:08'),(417,'Socialmedia','Socialmedia','2014-06-06 20:30:08','2014-06-06 20:30:08'),(418,'Socialmedia','redessociales','2014-06-06 20:30:08','2014-06-06 20:30:08'),(419,'Socialmedia','rrss','2014-06-06 20:30:08','2014-06-06 20:30:08'),(420,'Socialmedia','socialnetwork','2014-06-06 20:30:08','2014-06-06 20:30:08'),(421,'Socialmedia','sma','2014-06-06 20:30:08','2014-06-06 20:30:08'),(422,'Sexy','Sexy','2014-06-06 20:30:08','2014-06-06 20:30:08'),(423,'Sexy','sensual','2014-06-06 20:30:08','2014-06-06 20:30:08'),(424,'Sexy','mina','2014-06-06 20:30:08','2014-06-06 20:30:08'),(425,'Sexy','mino','2014-06-06 20:30:08','2014-06-06 20:30:08'),(426,'Sexy','minas','2014-06-06 20:30:08','2014-06-06 20:30:08'),(427,'Sexy','minos','2014-06-06 20:30:08','2014-06-06 20:30:08'),(428,'Sexy','rica','2014-06-06 20:30:08','2014-06-06 20:30:08'),(429,'Sexy','rico','2014-06-06 20:30:08','2014-06-06 20:30:08'),(430,'luxury','luxury','2014-06-06 20:30:08','2014-06-06 20:30:08'),(431,'luxury','luxurious','2014-06-06 20:30:08','2014-06-06 20:30:08'),(432,'luxury','luxe','2014-06-06 20:30:08','2014-06-06 20:30:08'),(433,'luxury','rich','2014-06-06 20:30:08','2014-06-06 20:30:08'),(434,'luxury','wealthy','2014-06-06 20:30:08','2014-06-06 20:30:08'),(435,'luxury','millionaire','2014-06-06 20:30:08','2014-06-06 20:30:08'),(436,'Eyecandy','Eyecandy','2014-06-06 20:30:08','2014-06-06 20:30:08'),(437,'Eyecandy','visual','2014-06-06 20:30:08','2014-06-06 20:30:08'),(438,'Eyecandy','estimulante','2014-06-06 20:30:08','2014-06-06 20:30:08'),(439,'Eyecandy','stimulating','2014-06-06 20:30:08','2014-06-06 20:30:08'),(440,'Marketing','Marketing','2014-06-06 20:30:08','2014-06-06 20:30:08'),(441,'Marketing','mktg','2014-06-06 20:30:08','2014-06-06 20:30:08'),(442,'Marketing','ad','2014-06-06 20:30:08','2014-06-06 20:30:08'),(443,'Marketing','advertising','2014-06-06 20:30:08','2014-06-06 20:30:08'),(444,'Marketing','commercial','2014-06-06 20:30:08','2014-06-06 20:30:08'),(445,'Marketing','comercial','2014-06-06 20:30:08','2014-06-06 20:30:08'),(446,'Marketing','publicidad','2014-06-06 20:30:08','2014-06-06 20:30:08'),(447,'Marketing','publicity','2014-06-06 20:30:08','2014-06-06 20:30:08'),(448,'Marketing','aviso','2014-06-06 20:30:08','2014-06-06 20:30:08'),(449,'Story','Story','2014-06-06 20:30:08','2014-06-06 20:30:08'),(450,'Story','storyteller','2014-06-06 20:30:08','2014-06-06 20:30:08'),(451,'Story','storytelling','2014-06-06 20:30:08','2014-06-06 20:30:08'),(452,'gamer','gamer','2014-06-06 20:30:08','2014-06-06 20:30:08'),(453,'gamer','videogamer','2014-06-06 20:30:08','2014-06-06 20:30:08'),(454,'gamer','game','2014-06-06 20:30:08','2014-06-06 20:30:08'),(455,'gamer','8bit','2014-06-06 20:30:08','2014-06-06 20:30:08'),(456,'Art','Art','2014-06-06 20:30:08','2014-06-06 20:30:08'),(457,'Art','arte','2014-06-06 20:30:08','2014-06-06 20:30:08'),(458,'Art','obra','2014-06-06 20:30:08','2014-06-06 20:30:08'),(459,'Art','obradearte','2014-06-06 20:30:08','2014-06-06 20:30:08'),(460,'Film','Film','2014-06-06 20:30:08','2014-06-06 20:30:08'),(461,'Film','movie','2014-06-06 20:30:08','2014-06-06 20:30:08'),(462,'Film','peli','2014-06-06 20:30:08','2014-06-06 20:30:08'),(463,'Film','pelicula','2014-06-06 20:30:08','2014-06-06 20:30:08'),(464,'Film','pelicula','2014-06-06 20:30:08','2014-06-06 20:30:08'),(465,'Film','trailer','2014-06-06 20:30:08','2014-06-06 20:30:08'),(466,'direccion','direccion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(467,'direccion','direccion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(468,'direccion','direction','2014-06-06 20:30:08','2014-06-06 20:30:08'),(469,'direccion','director','2014-06-06 20:30:08','2014-06-06 20:30:08'),(470,'photography','photography','2014-06-06 20:30:08','2014-06-06 20:30:08'),(471,'photography','fotografia','2014-06-06 20:30:08','2014-06-06 20:30:08'),(472,'photography','fotografo','2014-06-06 20:30:08','2014-06-06 20:30:08'),(473,'photography','foto','2014-06-06 20:30:08','2014-06-06 20:30:08'),(474,'photography','photo','2014-06-06 20:30:08','2014-06-06 20:30:08'),(475,'photography','direccionfotografica','2014-06-06 20:30:08','2014-06-06 20:30:08'),(476,'photography','timelapse','2014-06-06 20:30:08','2014-06-06 20:30:08'),(477,'Animation','Animation','2014-06-06 20:30:08','2014-06-06 20:30:08'),(478,'Animation','stopmotion','2014-06-06 20:30:08','2014-06-06 20:30:08'),(479,'Animation','motiongraphics','2014-06-06 20:30:08','2014-06-06 20:30:08');

/*Table structure for table `rb_friend` */

DROP TABLE IF EXISTS `rb_friend`;

CREATE TABLE `rb_friend` (
  `rb_friend` int(11) NOT NULL AUTO_INCREMENT,
  `rb_following` int(11) NOT NULL,
  `rb_follower` int(11) NOT NULL,
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_friend`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8;

/*Data for the table `rb_friend` */

insert  into `rb_friend`(`rb_friend`,`rb_following`,`rb_follower`,`rb_created_time`,`rb_updated_time`) values (1,25,27,'2014-03-17 09:00:50','2014-03-17 09:00:50'),(4,7,8,'2014-03-17 09:00:50','2014-03-17 09:00:50'),(23,26,7,'2014-06-19 11:23:57','2014-06-19 11:23:57'),(27,6,7,'2014-06-23 09:35:54','2014-06-23 09:35:54'),(29,27,7,'2014-06-27 11:32:30','2014-06-27 11:32:30');

/*Table structure for table `rb_invitation` */

DROP TABLE IF EXISTS `rb_invitation`;

CREATE TABLE `rb_invitation` (
  `rb_invitation` int(11) NOT NULL AUTO_INCREMENT,
  `rb_code` varchar(64) NOT NULL,
  `rb_valid_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_invitation`)
) ENGINE=InnoDB AUTO_INCREMENT=502 DEFAULT CHARSET=latin1;

/*Table structure for table `rb_notification` */

DROP TABLE IF EXISTS `rb_notification`;

CREATE TABLE `rb_notification` (
  `rb_notification` int(11) NOT NULL AUTO_INCREMENT,
  `rb_user` int(11) NOT NULL,
  `rb_content` varchar(512) DEFAULT NULL,
  `rb_sender` int(11) DEFAULT NULL,
  `rb_video` int(11) DEFAULT NULL,
  `rb_type` int(11) NOT NULL COMMENT '1 : Comments, 2 : Scores, 3: Add Friends',
  `rb_read_yn` char(1) NOT NULL DEFAULT 'N',
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_notification`)
) ENGINE=InnoDB AUTO_INCREMENT=497 DEFAULT CHARSET=utf8;

/*Table structure for table `rb_user` */

DROP TABLE IF EXISTS `rb_user`;

CREATE TABLE `rb_user` (
  `rb_user` int(11) NOT NULL AUTO_INCREMENT,
  `rb_username` varchar(64) NOT NULL,
  `rb_password` varchar(128) NOT NULL,
  `rb_name` varchar(64) NOT NULL,
  `rb_email` varchar(128) NOT NULL,
  `rb_photo` varchar(128) NOT NULL,
  `rb_bio` varchar(512) DEFAULT NULL,
  `rb_applications` varchar(256) DEFAULT NULL,
  `rb_cred` decimal(5,3) NOT NULL,
  `rb_email_mention_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_email_score_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_email_comment_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_email_follow_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_email_unfollow_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_valid_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_admin_yn` char(1) NOT NULL DEFAULT 'N',
  `rb_first_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_user`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;

/*Table structure for table `rb_user_sns` */

DROP TABLE IF EXISTS `rb_user_sns`;

CREATE TABLE `rb_user_sns` (
  `rb_user_sns` int(11) NOT NULL AUTO_INCREMENT,
  `rb_user` int(11) DEFAULT NULL,
  `rb_sns_type` int(11) NOT NULL COMMENT '1 : FB, 2 : TW',
  `rb_sns_id` varchar(128) NOT NULL,
  `rb_nickname` varchar(64) NOT NULL,
  `rb_email` varchar(128) DEFAULT NULL,
  `rb_photo` varchar(256) NOT NULL,
  `rb_token` varchar(256) NOT NULL,
  `rb_token2` varchar(512) DEFAULT NULL,
  `rb_valid_yn` char(1) NOT NULL DEFAULT 'N',
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_user_sns`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

/*Table structure for table `rb_user_udid` */

DROP TABLE IF EXISTS `rb_user_udid`;

CREATE TABLE `rb_user_udid` (
  `rb_user_udid` int(11) NOT NULL AUTO_INCREMENT,
  `rb_user` int(11) NOT NULL,
  `rb_dev_id` varchar(128) DEFAULT NULL,
  `rb_dev_token` varchar(128) NOT NULL,
  `rb_badge_cnt` int(11) NOT NULL,
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_user_udid`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=latin1;

/*Table structure for table `rb_user_video_comment` */

DROP TABLE IF EXISTS `rb_user_video_comment`;

CREATE TABLE `rb_user_video_comment` (
  `rb_user_video_comment` int(11) NOT NULL AUTO_INCREMENT,
  `rb_user` int(11) NOT NULL,
  `rb_video` int(11) NOT NULL,
  `rb_content` varchar(512) NOT NULL,
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_user_video_comment`)
) ENGINE=InnoDB AUTO_INCREMENT=358 DEFAULT CHARSET=utf8;

/*Table structure for table `rb_user_video_score` */

DROP TABLE IF EXISTS `rb_user_video_score`;

CREATE TABLE `rb_user_video_score` (
  `rb_user_video_score` int(11) NOT NULL AUTO_INCREMENT,
  `rb_user` int(11) NOT NULL,
  `rb_video` int(11) NOT NULL,
  `rb_user_cred` decimal(5,3) NOT NULL,
  `rb_score` int(11) NOT NULL,
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_user_video_score`)
) ENGINE=InnoDB AUTO_INCREMENT=107 DEFAULT CHARSET=utf8;

/*Table structure for table `rb_video` */

DROP TABLE IF EXISTS `rb_video`;

CREATE TABLE `rb_video` (
  `rb_video` int(11) NOT NULL AUTO_INCREMENT,
  `rb_user` int(11) NOT NULL,
  `rb_video_url` varchar(256) NOT NULL,
  `rb_content` varchar(512) DEFAULT NULL,
  `rb_hashtag` varchar(128) NOT NULL,
  `rb_video_thumb_large` varchar(256) DEFAULT NULL,
  `rb_video_thumb_small` varchar(256) DEFAULT NULL,
  `rb_video_score` decimal(5,3) NOT NULL,
  `rb_video_type` char(1) NOT NULL DEFAULT 'Y',
  `rb_valid_yn` char(1) NOT NULL DEFAULT 'Y',
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_video`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8;

/*Table structure for table `rb_video_share_count` */

DROP TABLE IF EXISTS `rb_video_share_count`;

CREATE TABLE `rb_video_share_count` (
  `rb_video_share_count` int(11) NOT NULL AUTO_INCREMENT,
  `rb_video` int(11) NOT NULL,
  `rb_count` int(11) NOT NULL,
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_video_share_count`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

/*Table structure for table `rb_video_temp` */

DROP TABLE IF EXISTS `rb_video_temp`;

CREATE TABLE `rb_video_temp` (
  `rb_video_temp` int(11) NOT NULL AUTO_INCREMENT,
  `rb_url` varchar(256) DEFAULT NULL,
  `rb_description` varchar(512) DEFAULT NULL,
  `rb_hashtag` varchar(128) DEFAULT NULL,
  `rb_facebook` char(1) NOT NULL DEFAULT 'N',
  `rb_twitter` char(1) NOT NULL DEFAULT 'N',
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_video_temp`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1;

/*Table structure for table `rb_video_view_count` */

DROP TABLE IF EXISTS `rb_video_view_count`;

CREATE TABLE `rb_video_view_count` (
  `rb_video_view_count` int(11) NOT NULL AUTO_INCREMENT,
  `rb_video` int(11) NOT NULL,
  `rb_count` int(11) NOT NULL,
  `rb_created_time` varchar(19) NOT NULL,
  `rb_updated_time` varchar(19) NOT NULL,
  PRIMARY KEY (`rb_video_view_count`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=latin1;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
