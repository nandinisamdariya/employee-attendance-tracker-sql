# Employee Management & Attendance Tracker 📋
A PostgreSQL-based employee attendance tracking system featuring triggers, dummy data generation for 200 employees, and daily attendance auto-population for July 2025.

---
## 👩‍💻 Author

**Nandini Samdariya**  
📧 [nandinisamdariya@gmail.com](mailto:nandinisamdariya@gmail.com)  
🔗 [LinkedIn](https://www.linkedin.com/in/nandinisamdariya)  
🔗 [GitHub](https://github.com/nandinisamdariya)

---

## 🧾 Project Overview

The system includes four core entities:
- **Departments**
- **Roles**
- **Employees**
- **Attendance**

Each employee belongs to a department and role. Attendance is recorded daily with timestamps, working hours, and status like 'Present' or 'Late'.

---

## 🔧 Tools Used

- **PostgreSQL**
- **pgAdmin 4**
- SQL scripting for schema creation and logic

---

## 📦 How Dummy Data Was Created

Instead of inserting data manually for each employee:

- **Departments and Roles**: Added 5 sample entries manually.
- **Employees**: 
  - Inserted initial 10 manually.
  - Then auto-generated **200 employees** using a loop inside a `DO $$` block with:
    - Auto-incremented names & emails
    - Random department & role assignment
    - Random hire dates
  
- **Attendance**:
  - Used **`generate_series()`** to simulate daily attendance for the entire month of **July 2025**
  - Skipped weekends using **`EXTRACT(DOW...)`**
  - Randomized check-in and check-out times within realistic office hours
  - Automatically assigned **status** based on check-in time (e.g., ‘Late’ if after 10 AM)

This saved hours of manual work and allowed realistic data simulation for reports.

---

## ⚙️ Key Functionalities

- **Triggers**: Automatically assign attendance status during insert.
- **Functions**: Calculate:
  - Total hours worked daily
  - Monthly summary of working hours
- **Custom Queries**:
  - Filter attendance by employee, date, status
  - View late days count
  - Calculate working hours

---

## 📊 Use Cases

- View attendance for a selected month
- Identify employees with most late marks
- Generate attendance reports for HR reviews

---

## 🔮 Future Enhancements

- Frontend dashboard using Tableau
- Login system for role-based access

---



## 📁 Project Structure

📦 Employee-Management-SQL/
├── schema.sql
├── insert_dummy_data.sql
├── functions_and_triggers.sql
├── reporting_queries.sql
└── README.md




