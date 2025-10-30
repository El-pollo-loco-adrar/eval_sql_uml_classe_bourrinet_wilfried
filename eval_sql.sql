CREATE DATABASE books CHARSET utf8mb4;
USE books;

CREATE TABLE IF NOT EXISTS users(
id_users INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
firstname VARCHAR(50) NOT NULL,
lastname VARCHAR(50) NOT NULL,
email VARCHAR(50) UNIQUE NOT NULL,
`password` VARCHAR(100) NOT NULL,
CONSTRAINT check_users_firstname CHECK (char_length(firstname) >=2 ),
CONSTRAINT check_users_lastname CHECK (char_length(lastname) >=2 )
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS category(
id_category INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
`name` VARCHAR(50) UNIQUE NOT NULL
)ENGINE=Innodb;

CREATE TABLE IF NOT EXISTS book(
id_book INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
title VARCHAR(50) NOT NULL,
`description` TEXT NOT NULL,
publication_date DATE NOT NULL,
author VARCHAR(50) NOT NULL,
id_category INT,
id_users INT,
CONSTRAINT fk_book_category FOREIGN KEY (id_category) 
		REFERENCES category(id_category) ON DELETE CASCADE,
CONSTRAINT fk_book_users FOREIGN KEY (id_users) 
		REFERENCES users(id_users) ON DELETE CASCADE,
CONSTRAINT check_book_title CHECK (char_length(title) >=3 ),
CONSTRAINT check_book_description CHECK (char_length(`description`) > 0
	AND char_length(`description`) <=500 )
)ENGINE=Innodb;

-- Requêtes de mise à jour
INSERT INTO category (`name`) VALUE ('Roman'),('SF'),('fantastique'),('biopic'),('thriller');

INSERT INTO users (firstname, lastname, email, `password`) VALUES
('Steven', 'Spielberg', 's.spielberg@bdd.com', 'mdp123'),
('Steven', 'Gerrard', 's.gerrard@bdd.com', 'mdp456'),
('Steven', 'Seagal', 's.seagal@bdd.com', 'mdp789');

INSERT INTO book (title, `description`, publication_date, author, id_category) VALUES
('Livre 1', "Le titre n'est pas ouf 1", "2025-10-30", "Harry Potter", 1),
('Livre 2', "Le titre n'est pas ouf 2", "2024-11-10", "Hermione Granger", 2),
('Livre 3', "Le titre n'est pas ouf 3", "2014-02-25", "Ron Weasley", 3),
('Livre 4', "Le titre n'est pas ouf 4", "1999-01-05", "Remus Lupin", 4),
('Livre 5', "Le titre n'est pas ouf 5", "2025-01-01", "Sirius Black", 5),
('Livre 6', "Le titre n'est pas ouf 6", "2025-02-01", "Albus Perceval Wulfric Brian Dumbledore", 1),
('Livre 7', "Le titre n'est pas ouf 7", "2025-03-01", "Minerva McGonagall", 2),
('Livre 8', "Le titre n'est pas ouf 8", "2025-04-01", "Ginny Weasley", 3),
('Livre 9', "Le titre n'est pas ouf 9", "2025-05-01", "Lord Voldemort", 4),
('Livre 10', "Le titre n'est pas ouf 10", "2025-06-01", "Tom Jedusor", 5),
('Livre 11', "Le titre n'est pas ouf 11", "2025-07-01", "Hagrid the Best", 1),
('Livre 12', "Le titre n'est pas ouf 12", "2025-08-01", "Hedwige RIP", 2),
('Livre 13', "Le titre n'est pas ouf 13", "2025-09-01", "Oncle Vernon", 3),
('Livre 14', "Le titre n'est pas ouf 14", "2025-10-10", "Tante Marge", 4),
('Livre 15', "Le titre n'est pas ouf 15", "2025-11-08", "Neville Londubas", 5);

UPDATE book SET id_users = 1
WHERE id_book IN (1,2,3,4,5);
UPDATE book SET id_users = 2
WHERE id_book IN (6,7,8,9,10);
UPDATE book SET id_users = 3
WHERE id_book IN (11,12,13,14,15);


-- Requêtes de création de compte
CREATE USER 'Admin'@'localhost' IDENTIFIED BY 'azerty';
GRANT ALL PRIVILEGES ON books . * TO 'admin'@'localhost';

CREATE USER 'Utilisateur'@'localhost' IDENTIFIED BY 'azertyUser';
GRANT INSERT, UPDATE, DELETE ON books . users TO 'Utilisateur'@'localhost';
GRANT INSERT, UPDATE, DELETE ON books . book TO 'Utilisateur'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'Utilisateur'@'localhost';
SHOW GRANTS FOR 'Admin'@'localhost';


-- Requêtes de consultations
SELECT u.id_users, u.firstname, u.lastname, u.email
FROM users AS u;

SELECT b.id_book, b.title, b.`description`, b.publication_date
FROM book AS b
ORDER BY b.title ASC, b.publication_date ASC;

SELECT  b.id_book, b.title, b.`description`, b.publication_date, b.author, c.`name`
FROM book AS b
INNER JOIN category AS c ON b.id_category = c.id_category;

SELECT concat(u.firstname, ' ', u.lastname) AS Users,
group_concat(
	concat(
		'(id : ', b.id_book, ') ', b.title, ' - ', b.`description`, ' - ', b.publication_date, ' - ',c.`name`, ' | '
    )
    
) AS Livres
FROM users AS u
INNER JOIN book AS b ON u.id_users = b.id_users
INNER JOIN category AS c ON b.id_category = c.id_category
GROUP BY u.id_users;

-- Requête de procédure
Delimiter $$
CREATE PROCEDURE createUser(
IN n_firstname VARCHAR(50),
IN n_lastname VARCHAR(50),
IN n_email VARCHAR(50),
IN n_password VARCHAR(100)
)
BEGIN
IF EXISTS (SELECT 1 FROM users WHERE email = n_email) THEN
ROLLBACK;
	SIGNAL SQLSTATE '10000' SET MESSAGE_TEXT = 'le compte existe déjà en BDD' ;
ELSE
	INSERT INTO users(firstname, lastname, email, `password`)
    VALUE (n_firstname, n_lastname, n_email, n_password);
END IF;
END $$

-- CALL createUser('Steven', 'Gerrard', 's.gerrard@bdd.com', 'mdp456');
CALL createUser('Ed', 'Gein', 'e.gein@bdd.com', 'netflix');