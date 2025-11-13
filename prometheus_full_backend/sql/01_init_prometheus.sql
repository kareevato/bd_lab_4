-- 🔹 CREATE USER + DB (localhost, як у твоєму відео)
DROP USER IF EXISTS 'prometheus_user'@'localhost';
CREATE USER 'prometheus_user'@'localhost' IDENTIFIED BY 'prometheus_pass_123';
GRANT ALL PRIVILEGES ON *.* TO 'prometheus_user'@'localhost';
FLUSH PRIVILEGES;

DROP DATABASE IF EXISTS prometheus_db;
CREATE DATABASE prometheus_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE prometheus_db;

-- ====== TABLES (15) ======
CREATE TABLE roles ( id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50) UNIQUE NOT NULL );
CREATE TABLE users ( id INT AUTO_INCREMENT PRIMARY KEY, full_name VARCHAR(120) NOT NULL, email VARCHAR(120) UNIQUE NOT NULL );
CREATE TABLE user_roles ( user_id INT NOT NULL, role_id INT NOT NULL, PRIMARY KEY (user_id, role_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE courses ( id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(150) NOT NULL, description TEXT );
CREATE TABLE course_instructors ( course_id INT NOT NULL, user_id INT NOT NULL, PRIMARY KEY (course_id, user_id),
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE modules ( id INT AUTO_INCREMENT PRIMARY KEY, course_id INT NOT NULL, title VARCHAR(150) NOT NULL, description TEXT,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE lessons ( id INT AUTO_INCREMENT PRIMARY KEY, module_id INT NOT NULL, title VARCHAR(150) NOT NULL, content TEXT,
  FOREIGN KEY (module_id) REFERENCES modules(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE enrollments ( user_id INT NOT NULL, course_id INT NOT NULL, enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, course_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE tests ( id INT AUTO_INCREMENT PRIMARY KEY, course_id INT NOT NULL, title VARCHAR(150) NOT NULL,
  FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE questions ( id INT AUTO_INCREMENT PRIMARY KEY, test_id INT NOT NULL, text TEXT NOT NULL,
  FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE options ( id INT AUTO_INCREMENT PRIMARY KEY, question_id INT NOT NULL, text VARCHAR(255) NOT NULL, is_correct BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE test_attempts ( id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL, test_id INT NOT NULL,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, finished_at TIMESTAMP NULL, score DECIMAL(5,2) DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (test_id) REFERENCES tests(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE test_attempt_answers ( id INT AUTO_INCREMENT PRIMARY KEY, attempt_id INT NOT NULL, question_id INT NOT NULL,
  selected_option_id INT, is_correct BOOLEAN,
  FOREIGN KEY (attempt_id) REFERENCES test_attempts(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (selected_option_id) REFERENCES options(id) ON DELETE SET NULL ON UPDATE CASCADE );
CREATE TABLE progress ( id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL, lesson_id INT NOT NULL,
  status ENUM('not_started','in_progress','completed') DEFAULT 'not_started',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_lesson (user_id, lesson_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE ON UPDATE CASCADE );
CREATE TABLE notifications ( id INT AUTO_INCREMENT PRIMARY KEY, user_id INT NOT NULL, message VARCHAR(255) NOT NULL,
  is_read BOOLEAN DEFAULT FALSE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE );

-- ====== SEED DATA ======
INSERT IGNORE INTO roles(name) VALUES ('student'),('teacher'),('admin');
INSERT IGNORE INTO users(full_name,email) VALUES
 ('Alice Johnson','alice@example.com'),('Bob Smith','bob@example.com'),
 ('Tetiana Karieieva','t.karieieva@gmail.com'),('Instructor One','teach1@example.com');
INSERT IGNORE INTO user_roles(user_id, role_id) VALUES (1,1),(2,2),(3,1),(4,2);
INSERT IGNORE INTO courses(title,description) VALUES
 ('Python Basics','Intro to Python'),('Databases 101','SQL and modeling'),('Algorithms','Sorting and graphs');
INSERT IGNORE INTO course_instructors(course_id,user_id) VALUES (1,4),(2,4);
INSERT IGNORE INTO modules(course_id,title,description) VALUES
 (1,'Syntax','Data types'),(1,'Functions','Defining functions'),
 (2,'ER Modeling','Entities & relations'),(3,'Sorting','Quick/Merge sort');
INSERT IGNORE INTO lessons(module_id,title,content) VALUES
 (1,'Numbers & Strings','...'),(2,'Def & Call','...'),(3,'Keys & FKs','...'),(4,'Quicksort','...');
INSERT IGNORE INTO enrollments(user_id,course_id) VALUES (1,1),(1,2),(2,2),(3,1),(3,3);
INSERT IGNORE INTO tests(course_id,title) VALUES (1,'Python Quiz 1'),(2,'DB Quiz'),(3,'Algorithms Quiz');
INSERT IGNORE INTO questions(test_id,text) VALUES
 (1,'What is list in Python?'),(2,'What is a primary key?'),(3,'Complexity of binary search?');
INSERT IGNORE INTO options(question_id,text,is_correct) VALUES
 (1,'Mutable sequence',TRUE),(1,'Immutable mapping',FALSE),
 (2,'Unique identifier',TRUE),(2,'Type of join',FALSE),
 (3,'O(log n)',TRUE),(3,'O(n^2)',FALSE);
INSERT IGNORE INTO test_attempts(user_id,test_id,score) VALUES (1,1,80.0),(1,2,70.0);
INSERT IGNORE INTO test_attempt_answers(attempt_id,question_id,selected_option_id,is_correct) VALUES
 (1,1,1,TRUE),(2,2,3,TRUE);
INSERT IGNORE INTO progress(user_id,lesson_id,status) VALUES
 (1,1,'completed'),(1,2,'in_progress'),(3,4,'not_started');
INSERT IGNORE INTO notifications(user_id,message,is_read) VALUES
 (1,'Welcome to the course!',FALSE),(3,'New module released',FALSE);
