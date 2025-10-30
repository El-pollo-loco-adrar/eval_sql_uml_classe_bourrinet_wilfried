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

INSERT INTO book (title, `description`, publication_date, author, id_category) VALUES
('Le couscous du futur', "Oui.", "2025-10-30", "Harry Potter", 1),
('La chaise en slip', "Pourquoi pas.", "2024-11-10", "Hermione Granger", 2),
('Biscotte de l’enfer', "C’est chaud.", "2014-02-25", "Ron Weasley", 3),
('Le poisson sans nom', "Il flotte… un peu.", "1999-01-05", "Remus Lupin", 4),
('Crabe président', "Il dirige bien.", "2025-01-01", "Sirius Black", 5),
('La porte triste', "Elle ferme son cœur.", "2025-02-01", "Albus Perceval Wulfric Brian Dumbledore", 1),
('Un ancien président en prison', "True story.", "2025-03-01", "Minerva McGonagall", 2),
('Le pull qui aboie', "Woof.", "2025-04-01", "Ginny Weasley", 3),
('Le sandwich invisible', "Tu le vois ?", "2025-05-01", "Lord Voldemort", 4),
('Table 3000', "Elle sait tout.", "2025-06-01", "Tom Jedusor", 5),
('Le nuage en grève', "Il pleut plus.", "2025-07-01", "Hagrid the Best", 1),
('Papillon de l’espace', "Flap flap.", "2025-08-01", "Hedwige RIP", 2),
('Chaussette suprême', "Elle juge.", "2025-09-01", "Oncle Vernon", 3),
('La bouilloire maudite', "Elle siffle… encore.", "2025-10-10", "Tante Marge", 4),
('Le pigeon existentiel', "Pourquoi voler ?", "2025-11-08", "Neville Londubas", 5);

INSERT INTO users (firstname, lastname, email, `password`) VALUES
('Steven', 'Spielberg', 's.spielberg@bdd.com', 'mdp123'),
('Steven', 'Gerrard', 's.gerrard@bdd.com', 'mdp456'),
('Steven', 'Seagal', 's.seagal@bdd.com', 'mdp789');

UPDATE book SET id_users = 1
WHERE id_book IN (1,2,3,4,5);
UPDATE book SET id_users = 2
WHERE id_book IN (6,7,8,9,10);
UPDATE book SET id_users = 3
WHERE id_book IN (11,12,13,14,15);


-- Requêtes de création de compte
CREATE USER 'Utilisateur'@'localhost' IDENTIFIED BY 'azertyUser';
GRANT INSERT, UPDATE, DELETE ON books . users TO 'Utilisateur'@'localhost';
GRANT INSERT, UPDATE, DELETE ON books . book TO 'Utilisateur'@'localhost';

CREATE USER 'Admin'@'localhost' IDENTIFIED BY 'azerty';
GRANT ALL PRIVILEGES ON books . * TO 'admin'@'localhost';

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