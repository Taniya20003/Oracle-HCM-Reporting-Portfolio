# Talking Talent Deliverable Tracker
## Solution Design

---

## 1. Document Information

| Item | Details |
|---|---|
| Report Name | Talking Talent Deliverable Tracker |
| Report Types | Detailed Report and Summary Report |
| Technology | Oracle BI Publisher |
| Data Source | Oracle HCM Cloud |
| Detailed Report | BI Publisher Data Model + SQL |
| Summary Report | RTF Template |
| Primary Dataset | TT_Tracker |
| User Story | 312148 |
| Author | Taniya Sharma |
| Initial Version | 1.0 |
| Initial Date | 27-Jul-2026 |
| Document Purpose | Solution and technical design |

---

# 2. Business Overview

The Talking Talent Deliverable Tracker is an Oracle BI Publisher reporting solution designed to provide visibility into the talent population participating in the Talking Talent process.

The solution provides both:

1. A **Detailed Report** containing employee-level talent information.
2. A **Summary Report** providing a business-oriented aggregated view of the same population.

The solution brings together information from multiple Oracle HCM areas, including:

- Person
- Assignment
- Organization
- Job
- Job Family
- Grade
- Legal Entity
- Talent Profile
- Top Talent nominations
- Performance Appraisal
- Mid Year Development Review (MYDR)
- Talent Review Meetings
- Business Leader information

The objective is to provide stakeholders with a consolidated view of the talent population and the key information required to support talent discussions and follow-up actions.

---

# 3. Business Objective

The primary objectives of the Talking Talent Deliverable Tracker are:

- Provide a consolidated view of the Talking Talent population.
- Provide employee-level talent information.
- Identify current Top Talent nominations.
- Compare current and previous Top Talent nominations.
- Identify Top Talent evolution.
- Display the latest Performance Appraisal rating.
- Display relevant MYDR information.
- Provide job seniority information.
- Identify the latest Talent Review Meeting.
- Identify the associated Business Leader.
- Provide organizational information such as OC, Business Unit, Product Line and Regional Cluster.
- Provide filters to allow users to analyze the population.
- Provide a detailed dataset that can also support the Summary Report.

---

# 4. Solution Scope

The solution covers two report outputs.

## 4.1 Detailed Report

The Detailed Report provides employee-level information.

The report includes information such as:

- Person Number
- First Name
- Last Name
- Display Name
- Assignment Status
- Person Type
- OC
- Business Unit
- Product Line
- Regional Cluster
- Age
- Job Family
- Sub Job Family
- Local Job Title
- Grade
- Discipline
- Current Top Talent Flag
- Previous Top Talent Flag
- Top Talent Evolution
- Development Action
- Last Performance Appraisal Rating
- Last Job Change Date
- Ready for Career Move
- Geographic Mobility
- Job Seniority Tenure
- Legislative Country
- Legal Entity
- Gender
- Talent Review Meeting
- Talent Review Meeting Creation Date
- Talent Review Meeting Date
- Business Leader

---

## 4.2 Summary Report

The Summary Report provides a summarized business view of the Talking Talent population.

The Summary Report uses an RTF template for presentation.

The RTF template is responsible for presenting the underlying dataset in a business-friendly format.

The Summary Report may include:

- Population summaries
- Talent category summaries
- Top Talent Evolution summaries
- Organizational summaries
- Other aggregated views required by the business

The Summary Report should use the same underlying business logic as the Detailed Report wherever possible.

This ensures that the detailed and summary outputs remain consistent.

---

# 5. High-Level Architecture

The overall solution architecture is:

```text
                    Oracle HCM Cloud
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
     Workforce          Talent          Performance
      Data              Data               Data
          |                |                |
          |                |                |
          +----------------+----------------+
                           |
                           v
                    Talent Review
                       Meetings
                           |
                           v
                  TT_Tracker Dataset
                           |
                           v
                 Detailed SQL Dataset
                           |
                +----------+----------+
                |                     |
                v                     v
        Detailed Report       Summary Report
                                RTF Template