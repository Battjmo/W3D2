PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  parent_id INTEGER,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);


CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Nasty', 'Nate'),
  ('Squirrel', 'Master'),
  ('Butter', 'Nuts'),
  ('Barack','Obama');
  
INSERT INTO
  questions (title, body, user_id)
VALUES
  ('Pry not working', 'If we''re talking bodies...', (SELECT id FROM users WHERE lname = 'Nate')),
  ('My computer spontaneously combusted', 'What do I do?!', (SELECT id FROM users WHERE lname = 'Master')),
  ('NEIGH', 'pppppp?', (SELECT id FROM users WHERE lname = 'Nuts')),
  ('Hope', 'Change?', (SELECT id FROM users WHERE lname = 'Obama'));
  
INSERT INTO 
  replies (user_id, questions_id, body, parent_id)
VALUES
  ((SELECT id FROM users WHERE lname = 'Obama'), (SELECT id FROM questions WHERE title = 'NEIGH'), 'GO FISH YOU DUMB HORSE BASTARD!', NULL),
  ((SELECT id FROM users WHERE lname = 'Nate'), (SELECT id FROM questions WHERE title = 'Hope'), 'I don''t want coins, I want change!', NULL),
  ((SELECT id FROM users WHERE lname = 'Nuts'), (SELECT id FROM questions WHERE title = 'NEIGH'), 'STAMPS HOOF MENACINGLY', (SELECT id FROM replies WHERE body = 'GO FISH YOU DUMB HORSE BASTARD!'));


INSERT INTO 
  question_follows (user_id, questions_id)
VALUES
  (2, 3),
  (3, 4),
  (4, 1);
  
INSERT INTO 
  question_likes (user_id, questions_id)
VALUES
  (2, 3),
  (3, 1),
  (1, 3);
  
  