# Talking Talent Deliverable Tracker

## Oracle HCM Analytics & BI Publisher Reporting Project

The Talking Talent Deliverable Tracker is an Oracle HCM reporting solution
designed to provide a consolidated view of employee talent, performance,
development, organizational, and talent review information.

The project demonstrates the design and implementation of an employee-centric
reporting solution using Oracle SQL and BI Publisher concepts.

> **Portfolio Note:** This repository contains a sanitized and generalized
> representation of the solution for public portfolio purposes. Production
> employee data, internal identifiers, credentials, URLs, and confidential
> implementation details are not included.

---

## Project Overview

The solution provides two complementary reporting views:

### Detailed Report

An employee-level report providing detailed information across multiple HCM
functional areas.

The report includes:

- Employee information
- Assignment information
- Organizational information
- Job and grade
- Talent designation
- Previous talent designation
- Talent evolution
- Performance rating
- Development information
- Job seniority
- Talent review meeting
- Business leader

### Summary Report

A management-oriented report that summarizes the employee-level dataset.

The summary view is designed to provide a high-level understanding of:

- Talent population
- Talent distribution
- Talent evolution
- Organizational distribution
- Performance information
- Talent review information

---

# Business Problem

Talent information is often distributed across multiple areas of an HCM
system.

A Talent or HR stakeholder may need to review information such as:

```text
Employee
   |
   +-- Assignment
   +-- Organization
   +-- Job
   +-- Grade
   +-- Talent
   +-- Performance
   +-- Development
   +-- Talent Review
