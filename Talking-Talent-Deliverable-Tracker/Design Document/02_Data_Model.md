# Talking Talent Deliverable Tracker
## Data Model Design

### 1. Purpose

The Data Model defines how employee, assignment, organizational, job,
talent, performance, development, and talent review information is combined
to support the Talking Talent Deliverable Tracker.

The model is designed around an employee-centric reporting dataset.

The Detailed Report consumes the employee-level dataset, while the Summary
Report uses the same reporting foundation for aggregated presentation.

---

# 2. Logical Data Model

The solution follows an employee-centric model:

```text
                         +----------------------+
                         |      EMPLOYEE        |
                         |----------------------|
                         | Person Number        |
                         | Person ID            |
                         | Name                 |
                         | Person Type          |
                         +----------+-----------+
                                    |
                 +------------------+------------------+
                 |                  |                  |
                 v                  v                  v
        +----------------+  +---------------+  +----------------+
        |   ASSIGNMENT   |  | ORGANIZATION  |  |     JOB        |
        |----------------|  |---------------|  |----------------|
        | Assignment ID  |  | Department    |  | Job            |
        | Status         |  | OC            |  | Job Family     |
        | Grade          |  | Business Unit |  | Sub Job Family |
        | Legal Entity   |  | Product Line  |  | Discipline     |
        +----------------+  | Region        |  +----------------+
                             +---------------+
                                    |
              +---------------------+----------------------+
              |                     |                      |
              v                     v                      v
       +-------------+       +-------------+       +----------------+
       |   TALENT    |       | PERFORMANCE |       | DEVELOPMENT    |
       |-------------|       |-------------|       |----------------|
       | Current Flag|       | Last Rating |       | Career Move    |
       | Previous    |       | Review Date |       | Mobility       |
       | Evolution   |       |             |       |                |
       +-------------+       +-------------+       +----------------+
              |
              v
       +-----------------------+
       | TALENT REVIEW MEETING |
       |-----------------------|
       | Meeting               |
       | Meeting Date          |
       | Business Leader       |
       +-----------------------+