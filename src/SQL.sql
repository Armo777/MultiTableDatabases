Создание таблиц:

CREATE TABLE curators (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  surname TEXT NOT NULL
);

CREATE TABLE faculties (
  id SERIAL PRIMARY KEY,
  financing MONEY NOT NULL DEFAULT 0 CHECK (financing >= CAST(0 AS MONEY)),
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE departments (
  id SERIAL PRIMARY KEY,
  financing MONEY NOT NULL DEFAULT 0 CHECK (financing >= CAST(0 AS MONEY)),
  name VARCHAR(100) NOT NULL UNIQUE,
  facultyId INT NOT NULL REFERENCES faculties(id)
);

CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(10) NOT NULL UNIQUE,
    year INT NOT NULL CHECK (year >= 1 AND year <= 5),
    departmentId INT NOT NULL REFERENCES departments(id)
);

CREATE TABLE groupsCurators (
   id SERIAL PRIMARY KEY,
   curatorId INT NOT NULL REFERENCES curators(id),
   groupId INT NOT NULL REFERENCES Groups(id)
);

CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE teachers (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  salary MONEY NOT NULL CHECK (Salary > CAST(0 AS MONEY)),
  surname TEXT NOT NULL
);

CREATE TABLE lectures (
    Id SERIAL PRIMARY KEY,
    lectureRoom TEXT NOT NULL,
    subjectId INT NOT NULL REFERENCES subjects(id),
    teacherId INT NOT NULL REFERENCES teachers(id)
);

CREATE TABLE groupsLectures (
    id SERIAL PRIMARY KEY,
    groupId INT NOT NULL REFERENCES Groups(id),
    lectureId INT NOT NULL REFERENCES Lectures(id)
);

Заполнение таблиц:

INSERT INTO curators (id, name, surname)
VALUES
(1, 'Иван', 'Иванов'),
(2, 'Петр', 'Петров'),
(3, 'Сергей', 'Сергеев'),
(4, 'Анна', 'Аннова'),
(5, 'Мария', 'Маринина');

INSERT INTO faculties (id, financing, name)
VALUES
(1, 1500000, 'Факультет прикладной математики'),
(2, 3000000, 'Факультет информационных технологий'),
(3, 2000000, 'Факультет экономики и менеджмента'),
(4, 2500000, 'Факультет механики и материаловедения'),
(5, 2000000, 'Факультет иностранных языков');

INSERT INTO departments (id, financing, name, facultyid)
VALUES
(1, 3000000, 'Кафедра информационных технологий', 1),
(2, 1500000, 'Кафедра экономики', 2),
(3, 1500000, 'Кафедра математики', 1),
(4, 2000000, 'Кафедра иностранных языков', 2),
(5, 2000000, 'Кафедра физики', 3);

INSERT INTO groups (id, name, year, departmentid)
VALUES
(1, 'Группа 1', 3, 1),
(2, 'Группа 2', 4, 1),
(3, 'Группа 3', 1, 2),
(4, 'Группа 4', 5, 2),
(5, 'Группа 5', 2, 3);

INSERT INTO groupsCurators (curatorid, groupid)
VALUES (1, 1), (2, 2), (3, 3), (4, 4), (5, 5);

INSERT INTO teachers (name, salary, surname) VALUES
('Арман', 15000, 'Саркисян'),
('Мария', 20000, 'Сергеевна'),
('Давид', 18000, 'Геворкович'),
('Анна', 19000, 'Петровна'),
('Михаил', 22000, 'Анатольевич');

INSERT INTO subjects (id, name)
VALUES
(1, 'Математика'),
(2, 'Физика'),
(3, 'Информатика'),
(4, 'История'),
(5, 'Английский язык');

INSERT INTO lectures (id, lectureroom, subjectid, teacherid)
VALUES
(1, 'A101', 3, 5),
(2, 'A102', 1, 2),
(3, 'A103', 2, 3),
(4, 'A104', 4, 1),
(5, 'A105', 5, 4);

INSERT INTO groupsLectures (groupid, lectureid)
VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5);

Запросы:

SELECT Teachers.*, Groups.*
FROM Teachers
CROSS JOIN Groups;

SELECT name, financing
FROM faculties
WHERE financing < (SELECT SUM(financing)
                   FROM departments
                   WHERE departments.facultyid = faculties.id);

SELECT
    (SELECT Surname FROM Curators WHERE id = groupsCurators.curatorid) AS CuratorSurname,
    (SELECT Name FROM Groups WHERE id = groupsCurators.groupid) AS GroupName
FROM
    groupsCurators;

SELECT Name, Surname
FROM Teachers
WHERE Id IN (
    SELECT TeacherId
    FROM Lectures
    WHERE Lectures.Id IN (
        SELECT LectureId
        FROM GroupsLectures
        WHERE GroupId = (
            SELECT Id
            FROM Groups
            WHERE Name = 'P107'
        )
    )
);

SELECT Teachers.Surname, Faculties.Name
FROM Teachers, Lectures, GroupsLectures, Groups, Departments, Faculties
WHERE Teachers.Id = Lectures.TeacherId
    AND Lectures.Id = GroupsLectures.LectureId
    AND GroupsLectures.GroupId = Groups.Id
    AND Groups.DepartmentId = Departments.Id
    AND Departments.FacultyId = Faculties.Id

SELECT
    (SELECT name FROM departments WHERE id = groups.departmentid) AS department_name,
    name AS group_name
FROM
    groups;

SELECT Name
FROM Subjects
WHERE Id IN (
    SELECT SubjectId
    FROM Lectures
    WHERE TeacherId = (
        SELECT Id
        FROM Teachers
        WHERE Name = 'Samantha Adams'
    )
);

SELECT groups.name
FROM groups, departments, faculties
WHERE groups.departmentid = departments.id
AND departments.facultyid = faculties.id
AND faculties.name = 'Информатика';

SELECT groups.name, departments.name
FROM groups, departments
WHERE groups.departmentid = departments.id AND groups.year = 5

SELECT
    (SELECT name || ' ' || surname FROM teachers WHERE teachers.id = lectures.teacherid) as teacher_name,
    (SELECT name FROM subjects WHERE subjects.id = lectures.subjectid) as subject_name,
    (SELECT name FROM groups WHERE groups.id = groupslectures.groupid) as group_name
FROM
    lectures, groupslectures
WHERE
    lectures.id = groupslectures.lectureid AND
    lectures.lectureroom = 'B103';