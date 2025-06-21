-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1:3306
-- Tiempo de generación: 20-06-2025 a las 21:27:58
-- Versión del servidor: 8.0.31
-- Versión de PHP: 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `crud_node`
--

DELIMITER $$
--
-- Procedimientos
--
DROP PROCEDURE IF EXISTS `sp_create_user_with_api_user`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_user_with_api_user` (IN `p_username` VARCHAR(100), IN `p_email` VARCHAR(255), IN `p_password_hash` TEXT, IN `p_status_id` INT, IN `p_api_key` TEXT)   BEGIN
  DECLARE userId INT;
  DECLARE apiUserId INT;

  INSERT INTO User (username, email, password_hash, status_id)
  VALUES (p_username, p_email, p_password_hash, p_status_id);

  SET userId = LAST_INSERT_ID();

  INSERT INTO api_user (user_id, api_key, is_active)
  VALUES (userId, p_api_key, 1);

  SET apiUserId = LAST_INSERT_ID();

  SELECT userId AS userId, apiUserId AS apiUserId;
END$$

DROP PROCEDURE IF EXISTS `sp_create_user_with_web_user`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_create_user_with_web_user` (IN `p_username` VARCHAR(100), IN `p_email` VARCHAR(255), IN `p_password_hash` TEXT, IN `p_status_id` INT)   BEGIN
  DECLARE userId INT;
  DECLARE webUserId INT;

  -- Crear usuario en tabla User
  INSERT INTO User (username, email, password_hash, status_id)
  VALUES (p_username, p_email, p_password_hash, p_status_id);

  SET userId = LAST_INSERT_ID();

  -- Crear entrada en tabla web_user
  INSERT INTO web_user (user_id, is_active)
  VALUES (userId, 1);

  SET webUserId = LAST_INSERT_ID();

  -- Retornar ambos IDs
  SELECT userId AS userId, webUserId AS webUserId;
END$$

DROP PROCEDURE IF EXISTS `sp_delete_api_user_and_user`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_api_user_and_user` (IN `p_api_user_id` INT)   BEGIN
  DECLARE v_user_id INT;

  -- Obtener el user_id relacionado con el api_user
  SELECT user_id INTO v_user_id FROM api_user WHERE id = p_api_user_id;

  IF v_user_id IS NULL THEN
    -- Nada que borrar, devolver NULL
    SELECT NULL AS deletedUserId;
  ELSE
    -- Eliminar api_user
    DELETE FROM api_user WHERE id = p_api_user_id;

    -- Eliminar user
    DELETE FROM user WHERE id = v_user_id;

    -- Devolver el user_id eliminado
    SELECT v_user_id AS deletedUserId;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_delete_web_user_and_user`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delete_web_user_and_user` (IN `p_web_user_id` INT)   BEGIN
  DECLARE v_user_id INT;

  -- Obtener el user_id relacionado con el web_user
  SELECT user_id INTO v_user_id FROM web_user WHERE id = p_web_user_id;

  IF v_user_id IS NULL THEN
    -- Nada que borrar, devolver NULL
    SELECT NULL AS deletedUserId;
  ELSE
    -- Eliminar web_user
    DELETE FROM web_user WHERE id = p_web_user_id;

    -- Eliminar user
    DELETE FROM user WHERE id = v_user_id;

    -- Devolver el user_id eliminado
    SELECT v_user_id AS deletedUserId;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_show_active_api_users`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_show_active_api_users` ()   BEGIN
  SELECT 
    u.id AS user_id,
    u.username,
    u.email,
    u.status_id,
    u.created_at,
    u.updated_at,
    a.id AS api_user_id,
    a.api_key,
    a.is_active AS api_user_active,
    a.created_at AS api_user_created,
    a.updated_at AS api_user_updated
  FROM user u
  INNER JOIN api_user a ON a.user_id = u.id AND a.is_active = 1;
END$$

DROP PROCEDURE IF EXISTS `sp_show_active_web_users`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_show_active_web_users` ()   BEGIN
  SELECT 
    u.id AS user_id,
    u.username,
    u.email,
    u.status_id,
    u.created_at,
    u.updated_at,
    w.id AS web_user_id,
    w.is_active AS web_user_active,
    w.created_at AS web_user_created,
    w.updated_at AS web_user_updated
  FROM user u
  INNER JOIN web_user w ON w.user_id = u.id AND w.is_active = 1
  WHERE u.status_id = 1; -- Solo usuarios activos (opcional)
END$$

DROP PROCEDURE IF EXISTS `sp_show_id_user_active`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_show_id_user_active` (IN `Id` INT)   BEGIN
    SELECT US.id,US.username,US.email,US.password_hash,US.status_id,UST.name AS status_name,US.last_login,US.created_at,US.updated_at  FROM user AS US 
    INNER JOIN  user_status UST ON US.status_id=UST.id WHERE US.status_id=1 AND US.id=Id ORDER BY US.id;
    END$$

DROP PROCEDURE IF EXISTS `sp_show_user_active`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_show_user_active` ()   BEGIN
    SELECT US.id,US.username,US.email,US.password_hash,US.status_id,UST.name AS status_name,US.last_login,US.created_at,US.updated_at  FROM user AS US 
    INNER JOIN  user_status UST ON US.status_id=UST.id WHERE US.status_id=1 ORDER BY US.id;
    END$$

DROP PROCEDURE IF EXISTS `sp_update_user_and_api_user_by_api_id`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user_and_api_user_by_api_id` (IN `p_api_user_id` INT, IN `p_new_username` VARCHAR(100), IN `p_new_password_hash` TEXT, IN `p_new_is_active` TINYINT)   BEGIN
  DECLARE v_user_id INT;

  -- Buscar el user_id asociado al api_user
  SELECT user_id INTO v_user_id FROM api_user WHERE id = p_api_user_id;

  IF v_user_id IS NOT NULL THEN
    -- Actualizar usuario
    UPDATE user
    SET username = p_new_username,
        password_hash = p_new_password_hash,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = v_user_id;

    -- Actualizar api_user
    UPDATE api_user
    SET is_active = p_new_is_active,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_api_user_id;

    -- Confirmar éxito
    SELECT v_user_id AS updated_user_id;
  ELSE
    -- Si no existe, devolver NULL
    SELECT NULL AS updated_user_id;
  END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_update_user_and_web_user_by_web_id`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_user_and_web_user_by_web_id` (IN `p_web_user_id` INT, IN `p_new_username` VARCHAR(100), IN `p_new_password_hash` TEXT, IN `p_new_is_active` TINYINT)   BEGIN
  DECLARE v_user_id INT;

  -- Buscar el user_id asociado al web_user
  SELECT user_id INTO v_user_id FROM web_user WHERE id = p_web_user_id;

  IF v_user_id IS NOT NULL THEN
    -- Actualizar usuario
    UPDATE user
    SET username = p_new_username,
        password_hash = p_new_password_hash,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = v_user_id;

    -- Actualizar web_user
    UPDATE web_user
    SET is_active = p_new_is_active,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_web_user_id;

    -- Confirmar éxito
    SELECT v_user_id AS updated_user_id;
  ELSE
    -- Si no existe, devolver NULL
    SELECT NULL AS updated_user_id;
  END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `api_user`
--

DROP TABLE IF EXISTS `api_user`;
CREATE TABLE IF NOT EXISTS `api_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `api_key` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_key` (`api_key`),
  KEY `idx_api_user_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `document_type`
--

DROP TABLE IF EXISTS `document_type`;
CREATE TABLE IF NOT EXISTS `document_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 ;

--
-- Volcado de datos para la tabla `document_type`
--

INSERT INTO `document_type` (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'CC', 'Cedula de ciudadanía', '2025-06-20 00:31:11', '2025-06-20 00:31:11'),
(2, 'TI', 'Tarjeta de identidad', '2025-06-20 00:31:11', '2025-06-20 00:31:11'),
(3, 'CE', 'Cédula de Extranjería', '2025-06-20 00:31:11', '2025-06-20 00:31:11');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profile`
--

DROP TABLE IF EXISTS `profile`;
CREATE TABLE IF NOT EXISTS `profile` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `document_type_id` int NOT NULL,
  `document_number` varchar(50) NOT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `document_number` (`document_number`),
  KEY `document_type_id` (`document_type_id`),
  KEY `idx_profile_user` (`user_id`),
  KEY `idx_profile_document` (`document_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `role`
--

DROP TABLE IF EXISTS `role`;
CREATE TABLE IF NOT EXISTS `role` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `idx_role_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 ;

--
-- Volcado de datos para la tabla `role`
--

INSERT INTO `role` (`id`, `name`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'admin', 'System Administrator', 1, '2025-06-20 00:31:11', '2025-06-20 00:31:11'),
(2, 'user', 'Regular User', 1, '2025-06-20 00:31:11', '2025-06-20 00:31:11');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user`
--

DROP TABLE IF EXISTS `user`;
CREATE TABLE IF NOT EXISTS `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `status_id` int NOT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `status_id` (`status_id`),
  KEY `idx_user_username` (`username`),
  KEY `idx_user_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 ;

--
-- Volcado de datos para la tabla `user`
--

INSERT INTO `user` (`id`, `username`, `email`, `password_hash`, `status_id`, `last_login`, `created_at`, `updated_at`) VALUES
(26, 'user', 'nuevo_api@mail.com1', '$2b$10$3PK69ySq2sJtPzqP3KsU3.KynIvwtPSpM5zFyiT0GRlekmFQT.4CC', 1, '2025-06-20 21:20:02', '2025-06-20 21:07:07', '2025-06-20 21:20:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_role`
--

DROP TABLE IF EXISTS `user_role`;
CREATE TABLE IF NOT EXISTS `user_role` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  `status_id` int NOT NULL,
  `assigned_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`,`role_id`),
  KEY `status_id` (`status_id`),
  KEY `assigned_by` (`assigned_by`),
  KEY `idx_user_role_user` (`user_id`),
  KEY `idx_user_role_role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `user_status`
--

DROP TABLE IF EXISTS `user_status`;
CREATE TABLE IF NOT EXISTS `user_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 ;

--
-- Volcado de datos para la tabla `user_status`
--

INSERT INTO `user_status` (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'active', 'Active user', '2025-06-20 00:31:11', '2025-06-20 00:31:11'),
(2, 'inactive', 'Inactive user', '2025-06-20 00:31:11', '2025-06-20 00:31:11'),
(3, 'suspended', 'Suspended user', '2025-06-20 00:31:11', '2025-06-20 00:31:11');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `web_user`
--

DROP TABLE IF EXISTS `web_user`;
CREATE TABLE IF NOT EXISTS `web_user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `is_logged_in` tinyint(1) DEFAULT '0',
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_web_user_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 ;

--
-- Volcado de datos para la tabla `web_user`
--

INSERT INTO `web_user` (`id`, `user_id`, `is_logged_in`, `last_login`, `created_at`, `updated_at`, `is_active`) VALUES
(4, 26, 0, NULL, '2025-06-20 21:07:07', '2025-06-20 21:07:07', 1);

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `api_user`
--
ALTER TABLE `api_user`
  ADD CONSTRAINT `api_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `profile`
--
ALTER TABLE `profile`
  ADD CONSTRAINT `profile_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `profile_ibfk_2` FOREIGN KEY (`document_type_id`) REFERENCES `document_type` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Filtros para la tabla `user`
--
ALTER TABLE `user`
  ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (`status_id`) REFERENCES `user_status` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Filtros para la tabla `user_role`
--
ALTER TABLE `user_role`
  ADD CONSTRAINT `user_role_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_role_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `user_role_ibfk_3` FOREIGN KEY (`status_id`) REFERENCES `user_status` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `user_role_ibfk_4` FOREIGN KEY (`assigned_by`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `web_user`
--
ALTER TABLE `web_user`
  ADD CONSTRAINT `web_user_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
