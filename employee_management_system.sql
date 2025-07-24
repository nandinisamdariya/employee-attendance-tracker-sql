--  Project: Employee Attendance Tracker using PostgreSQL
--  Author: Nandini Samdariya

--  Objective:
-- Build an employee attendance tracking system that:
-- - Records attendance data (check-in/out)
-- - Tracks late entries
-- - Calculates total working hours
-- - Provides analytical queries & reports
-- - Includes automated logic via triggers

--  Technologies: PostgreSQL, pgAdmin

--  Step 1: Create Tables

-- Create Departments Table
CREATE TABLE Departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create Roles Table
CREATE TABLE Roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create Employees Table
CREATE TABLE Employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    department_id INT REFERENCES Departments(department_id) ON DELETE SET NULL,
    role_id INT REFERENCES Roles(role_id) ON DELETE SET NULL,
    hire_date DATE
);

-- Create Attendance Table
CREATE TABLE Attendance (
    attendance_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES Employees(employee_id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    check_in_time TIMESTAMP,
    check_out_time TIMESTAMP,
    status VARCHAR(20)
);

--  Step 2: Insert sample Departments and Roles

INSERT INTO Departments (department_name) VALUES
('HR'), ('Finance'), ('Engineering'), ('Sales'), ('Marketing');

INSERT INTO Roles (role_name) VALUES
('Manager'), ('Developer'), ('Analyst'), ('Sales Executive'), ('HR Specialist');

--  Step 3: Insert 200 dummy Employees

INSERT INTO Employees (first_name, last_name, email, department_id, role_id, hire_date)
SELECT 
    'FirstName' || gs AS first_name,
    'LastName' || gs AS last_name,
    'user' || gs || '@company.com' AS email,
    (1 + (random() * 4))::int AS department_id,
    (1 + (random() * 4))::int AS role_id,
    (CURRENT_DATE - (random() * 3650)::int)
FROM generate_series(1, 200) AS gs;

--  Step 4: Insert July attendance (weekdays only)

INSERT INTO Attendance (employee_id, attendance_date, check_in_time, check_out_time, status)
SELECT 
    emp_id,
    day::DATE,
    check_in,
    check_out,
    CASE
        WHEN check_in::TIME > '09:30:00' THEN 'Late'
        ELSE 'Present'
    END
FROM (
    SELECT 
        day,
        emp_id,
        day + INTERVAL '9 hour' + (random() * INTERVAL '45 minutes') AS check_in,
        day + INTERVAL '17 hour' + (random() * INTERVAL '30 minutes') AS check_out
    FROM 
        generate_series('2025-07-01'::date, '2025-07-31'::date, '1 day') AS day
    CROSS JOIN 
        generate_series(1, 200) AS emp_id
    WHERE 
        EXTRACT(DOW FROM day) NOT IN (0, 6)
) AS attendance_data;

-- 🔍 Step 5: View records for a specific employee

SELECT employee_id, attendance_date, check_in_time, check_out_time, status
FROM Attendance
WHERE employee_id = 2
  AND attendance_date BETWEEN '2025-07-01' AND '2025-07-31'
ORDER BY attendance_date;

--  Step 6: Total days present and late

SELECT 
    employee_id,
    COUNT(*) AS total_days_present,
    SUM(CASE WHEN status = 'Late' THEN 1 ELSE 0 END) AS total_late_days
FROM Attendance
WHERE attendance_date BETWEEN '2025-07-01' AND '2025-07-31'
GROUP BY employee_id
ORDER BY employee_id;

--  Step 7: Trigger to auto-set status (if not provided)

CREATE OR REPLACE FUNCTION set_attendance_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status IS NULL THEN
        IF NEW.check_in_time::TIME > TIME '09:30:00' THEN
            NEW.status := 'Late';
        ELSE
            NEW.status := 'Present';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_status
BEFORE INSERT ON Attendance
FOR EACH ROW
EXECUTE FUNCTION set_attendance_status();

--  Step 8: Work hour calculation function

CREATE OR REPLACE FUNCTION calculate_work_hours(emp_id INT, work_date DATE)
RETURNS INTERVAL AS $$
DECLARE
    in_time TIMESTAMP;
    out_time TIMESTAMP;
    duration INTERVAL;
BEGIN
    SELECT check_in_time, check_out_time
    INTO in_time, out_time
    FROM Attendance
    WHERE employee_id = emp_id AND attendance_date = work_date;

    IF in_time IS NULL OR out_time IS NULL THEN
        RETURN NULL;
    END IF;

    duration := out_time - in_time;
    RETURN duration;
END;
$$ LANGUAGE plpgsql;

--  Step 9: Test the function

SELECT calculate_work_hours(5, '2025-07-01');

--  Employees late more than 5 days in July

SELECT employee_id, COUNT(*) AS late_days
FROM Attendance
WHERE status = 'Late' AND attendance_date BETWEEN '2025-07-01' AND '2025-07-31'
GROUP BY employee_id
HAVING COUNT(*) > 5
ORDER BY late_days DESC;

-- 🔍 Step 10: Create View for working hours

CREATE OR REPLACE VIEW work_hours_july AS
SELECT 
    employee_id,
    attendance_date,
    check_out_time - check_in_time AS work_duration
FROM Attendance
WHERE attendance_date BETWEEN '2025-07-01' AND '2025-07-31'
  AND check_in_time IS NOT NULL
  AND check_out_time IS NOT NULL;

--  Total hours worked in July per employee

SELECT 
    employee_id,
    SUM(work_duration) AS total_worked_hours
FROM work_hours_july
GROUP BY employee_id
ORDER BY total_worked_hours DESC;
