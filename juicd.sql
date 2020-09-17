-- Name: Chi Gou Lo


-- -----------------------------------------------------
-- Checking if Database Exists and Sorting it out
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `juic`;
CREATE SCHEMA IF NOT EXISTS `juic`;


-- -----------------------------------------------------
-- Using newly created database
-- -----------------------------------------------------
USE `juic` ;


-- -----------------------------------------------------
-- Creating Table `juic`.`customer`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`customer`;
CREATE TABLE IF NOT EXISTS `juic`.`customer` (
  `customer_id` INT(11) NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(20) NOT NULL,
  `last_name` VARCHAR(20) NOT NULL,
  `dob` DATE NOT NULL,
  `gender` ENUM('F', 'M') NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `contact_no` INT(10) NOT NULL,
  `points` INT(11) NOT NULL,
  PRIMARY KEY (`customer_id`)
  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`employee`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`employee`;
CREATE TABLE IF NOT EXISTS `juic`.`employee` (
  `employee_id` INT(11) NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(20) NOT NULL,
  `last_name` VARCHAR(20) NOT NULL,
  `dob` DATE NOT NULL,
  `gender` ENUM('F', 'M') NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `contact_no` INT(10) NOT NULL,
  `salary` INT(11) NOT NULL,
  `home_address` VARCHAR(255) NOT NULL,
  `report_to` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`employee_id`)
  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`ingredient`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`ingredient`;
CREATE TABLE IF NOT EXISTS `juic`.`ingredient` (
  `name` VARCHAR(255) NOT NULL,
  `price per ml` INT(11) NOT NULL,
  PRIMARY KEY (`name`)
  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`size`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`size`;
CREATE TABLE IF NOT EXISTS `juic`.`size` (
  `size` VARCHAR(255) NOT NULL,
  `volume (ml)` INT(9) NOT NULL,
  PRIMARY KEY (`size`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`juice`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`juice`;
CREATE TABLE IF NOT EXISTS `juic`.`juice` (
  `cup_no` INT(11) NOT NULL AUTO_INCREMENT,
  `ingredient` VARCHAR(255) NOT NULL,
  `percentage` DECIMAL(2,0) NOT NULL,
  `size` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`cup_no`, `ingredient`),
  CONSTRAINT `juice_ibfk_1`
    FOREIGN KEY (`ingredient`)
    REFERENCES `juic`.`ingredient` (`name`),
  CONSTRAINT `juice_ibfk_2`
    FOREIGN KEY (`size`)
    REFERENCES `juic`.`size` (`size`)
    )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`non-juice`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`non-juice`;
CREATE TABLE IF NOT EXISTS `juic`.`non-juice` (
  `name` VARCHAR(255) NOT NULL,
  `price per unit` INT(11) NOT NULL,
  PRIMARY KEY (`name`)
  )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`outlet`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`outlet`;
CREATE TABLE IF NOT EXISTS `juic`.`outlet` (
  `name` VARCHAR(20) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `contact_no` INT(10) NOT NULL,
  `manager_id` INT(10) NOT NULL,
  PRIMARY KEY (`address`, `manager_id`),
  CONSTRAINT `outlet_ibfk_1`
    FOREIGN KEY (`manager_id`)
    REFERENCES `juic`.`employee` (`employee_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`product`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`product`;
CREATE TABLE IF NOT EXISTS `juic`.`product` (
  `product_no` INT(11) NOT NULL AUTO_INCREMENT,
  `cup_no` INT(11) NULL DEFAULT NULL,
  `name` VARCHAR(255) NULL DEFAULT NULL,
  `product_type` ENUM('nj', 'j') NOT NULL,
  PRIMARY KEY (`product_no`),
  CONSTRAINT `product_ibfk_1`
    FOREIGN KEY (`name`)
    REFERENCES `juic`.`non-juice` (`name`),
  CONSTRAINT `product_ibfk_2`
    FOREIGN KEY (`cup_no`)
    REFERENCES `juic`.`juice` (`cup_no`)
    )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`order`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`order`;
CREATE TABLE IF NOT EXISTS `juic`.`order` (
  `order_id` INT(11) NOT NULL AUTO_INCREMENT,
  `customer_id` INT(11) NOT NULL,
  `product_no` INT(11) NOT NULL,
  `quantity` INT(99) NOT NULL,
  `employee_id` INT(11) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `date_of_purchase` DATE NOT NULL,
  `price` INT(11) NOT NULL,
  PRIMARY KEY (`order_id`, `product_no`),
  CONSTRAINT `orders_ibfk_1`
    FOREIGN KEY (`customer_id`)
    REFERENCES `juic`.`customer` (`customer_id`),
  CONSTRAINT `orders_ibfk_2`
    FOREIGN KEY (`address`)
    REFERENCES `juic`.`outlet` (`address`),
  CONSTRAINT `orders_ibfk_3`
    FOREIGN KEY (`employee_id`)
    REFERENCES `juic`.`employee` (`employee_id`),
  CONSTRAINT `orders_ibfk_4`
    FOREIGN KEY (`product_no`)
    REFERENCES `juic`.`product` (`product_no`)
    )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Creating Table `juic`.`workin`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `juic`.`workin`;
CREATE TABLE IF NOT EXISTS `juic`.`workin` (
  `employee_id` INT(11) NOT NULL,
  `address` VARCHAR(255) NOT NULL,
  `percentage` DECIMAL(2,0) NOT NULL,
  PRIMARY KEY (`employee_id`, `address`),
  CONSTRAINT `workin_ibfk_1`
    FOREIGN KEY (`employee_id`)
    REFERENCES `juic`.`employee` (`employee_id`),
  CONSTRAINT `workin_ibfk_2`
    FOREIGN KEY (`address`)
    REFERENCES `juic`.`outlet` (`address`))
ENGINE = InnoDB;

