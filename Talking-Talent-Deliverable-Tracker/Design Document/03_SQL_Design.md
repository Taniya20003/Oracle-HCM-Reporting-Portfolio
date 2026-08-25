# Talking Talent Deliverable Tracker
## SQL Design

---

## 1. Document Information

| Item | Details |
|---|---|
| Report | Talking Talent Deliverable Tracker |
| Dataset | TT_Tracker |
| SQL File | `SQL/main_query.sql` |
| Report Type | Detailed Report |
| Summary Output | RTF Template |
| Author | Taniya Sharma |
| Version | 1.0 |
| Date | 25-Aug-2026 |
| User Story | 312148 |

---

# 2. Purpose

This document describes the SQL implementation of the Talking Talent Deliverable Tracker.

The SQL is responsible for:

- Building the Talking Talent employee population.
- Retrieving current employee information.
- Retrieving organizational information.
- Retrieving job and grade information.
- Retrieving current and previous Top Talent nominations.
- Calculating Top Talent Evolution.
- Retrieving the latest Performance Appraisal rating.
- Retrieving relevant MYDR responses.
- Retrieving the latest Talent Review Meeting.
- Retrieving the associated Business Leader.
- Calculating job seniority.
- Applying report prompts.
- Applying population exclusions.
- Producing the final dataset consumed by the Detailed Report.

The Summary Report uses the resulting dataset through an RTF template.

---

# 3. SQL Architecture

The SQL follows a modular Common Table Expression (CTE) approach.

The high-level structure is:

```text
department_details
        |
        v
TOP_TALENT_FLAG
        |
        v
PREV_TOP_TALENT_FLAG_VIEW
        |
        v
LAST_PA_VIEW
        |
        v
MYDR_DETAILS
        |
        v
LATEST_MEETING
        |
        v
JOB_SENIORITY
        |
        v
Final SELECT