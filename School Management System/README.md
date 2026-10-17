# Practice 2: School Management System

Hi Ms. Phượng, my name is Võ Châu Anh. This is my submission for building the School Management System.

This project is an iOS application built with SwiftUI that simulates a comprehensive School Management System. It allows users to manage Students, Subjects, Teachers, and Student Records (Enrollment & Marks). The app strictly enforces relational constraints (e.g., preventing duplicate enrollments, validating IDs). It features a custom Glassmorphism UI, dynamic backgrounds, advanced search/sorting capabilities, and statistical reports (GPA rankings and failed students). 

---

## 🎓 Students View
*Main interface for managing student profiles.*

<img src="https://github.com/user-attachments/assets/bc3e2cc5-db73-4816-908f-c15196f6eeb0" width="350" />

**🔍 Search by Name**

<img src="https://github.com/user-attachments/assets/d1fcdf28-d411-4044-b465-baf5805fa818" width="350" />

**🔍 Search by ID**

<img src="https://github.com/user-attachments/assets/fb28a067-a07b-4fda-a2e6-cab08305c69e" width="350" />

**➕ Add New Student**

<img src="https://github.com/user-attachments/assets/ea237c4e-9d60-4b9a-ac3b-0500843a0751" width="350" />

**⚙️ Additional Features (Menu)**

<img src="https://github.com/user-attachments/assets/eac056c7-2df6-4dd5-9794-2e0e2381162d" width="350" />

- **Sort by GPA (Descending)**
  
<img src="https://github.com/user-attachments/assets/82a4df3e-83bf-4f9d-a8eb-0e616a16bd21" width="350" />

- **Excellent Students (GPA >= 8)**
  
<img src="https://github.com/user-attachments/assets/c4fa81c3-58e9-4f03-88dd-cb6b988d9396" width="350" />

- **Students in 2023**
  
<img src="https://github.com/user-attachments/assets/104cb9ce-552f-44a1-b384-6d0f551a59f6" width="350" />

---

## 📚 Subjects View
*Manage curriculum subjects and their assigned teachers.*

<img src="https://github.com/user-attachments/assets/9b9131d2-a0b5-43a9-bf8f-3ee80ddc5d38" width="350" />

**🔍 Search by Name**

<img src="https://github.com/user-attachments/assets/f1914980-59f3-4e65-ae98-e6d332dc4b05" width="350" />

**🔍 Search by ID**

<img src="https://github.com/user-attachments/assets/49ebf31d-4887-451b-8b58-b035f3f4ef38" width="350" />

**➕ Add New Subject**

<img src="https://github.com/user-attachments/assets/91e5ce46-70c7-49df-9bc6-7b37348d825b" width="350" />

**⚙️ Additional Features (Menu)**

<img src="https://github.com/user-attachments/assets/9a0d1d5b-5358-4b34-8210-2b48f8aa1eae" width="350" />

- **Sort by Credits (Descending)**
  
<img src="https://github.com/user-attachments/assets/8441b0e2-59db-45c5-9472-8402b1b8a7dd" width="350" />

- **Subjects in Semester 3**
  
<img src="https://github.com/user-attachments/assets/748c9dcf-8e43-42cf-bb1b-05299fe24db4" width="350" />

---

## 👨‍🏫 Teachers View
*Manage teacher profiles and assign subjects they can teach.*

<img src="https://github.com/user-attachments/assets/f08e0681-5266-411b-8f42-6e4638e36d7d" width="350" />

**🔍 Search by Name**

<img src="https://github.com/user-attachments/assets/8f0c7db3-7fcb-4cb0-8965-5e64d1dbcad2" width="350" />

**🔍 Search by ID**

<img src="https://github.com/user-attachments/assets/f7eec4bf-9a36-482f-9f17-9640bf5e6f1a" width="350" />

**➕ Add New Teacher**

<img src="https://github.com/user-attachments/assets/7f24d85f-48b5-4260-987a-4da3fd00d4fa" width="350" />

**✏️ Edit Assigned Subjects**

<img src="https://github.com/user-attachments/assets/6ce89b12-6593-43ca-9336-637e06849496" width="350" />

**⚙️ Organizing Features (Menu)**

<img src="https://github.com/user-attachments/assets/964b0706-ae98-4c64-900c-5a8b4ac8dbf0" width="350" />

- **Default: Name (A - Z)**
  
<img src="https://github.com/user-attachments/assets/f08e0681-5266-411b-8f42-6e4638e36d7d" width="350" />

- **Sort by Total Credits (High → Low)**
  
<img src="https://github.com/user-attachments/assets/64d294f1-858f-4201-a260-d430761fa8ca" width="350" />

---

## 📝 Records View (Enrollment & Marks)
*Core features for linking students to subjects and inputting grades.*

### Enrollment
**State 1: Unselected**

<img src="https://github.com/user-attachments/assets/9875b48b-7299-4473-a0b7-41ee465d6dc3" width="350" />

**State 2: Selected Student & Subjects**

<img src="https://github.com/user-attachments/assets/c463b6e9-c138-4f64-b991-e5b76deb0844" width="350" />

**State 3: Successfully Enrolled**

<img src="https://github.com/user-attachments/assets/443beca9-386d-4580-8354-c9f310313e3c" width="350" />

### Marks
**State 1: Unselected**

<img src="https://github.com/user-attachments/assets/bcd6e9d9-d720-4697-a915-f2c274ea1f23" width="350" />

**State 2: Selected Student & View Records**

<img src="https://github.com/user-attachments/assets/8e07bfa6-bdeb-454c-ab6d-5f91ec1bb828" width="350" />

**State 3: Enter & Save Marks**

<img src="https://github.com/user-attachments/assets/2aa0c43f-33b5-4483-a791-7251da1d087f" width="350" />

---

## 📊 Statistics View
*Data insights and reporting.*

### 1. Students with GPA > 8

<img src="https://github.com/user-attachments/assets/44185b57-5df0-4c61-9306-7aee1b2b68be" width="350" />

### 2. Failed Students (Mark < 5)

<img src="https://github.com/user-attachments/assets/659719f6-3875-44b4-8cee-0b5fe623ca03" width="350" />

### 3. Additional Feature: Export Report

<img src="https://github.com/user-attachments/assets/f8779590-9e7e-4849-b7b8-d29c76ac7db7" width="350" />
