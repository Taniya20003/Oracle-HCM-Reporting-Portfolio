# SQL Implementation

## Overview

The Talking Talent Deliverable Tracker uses a modular SQL architecture to
combine employee, organizational, job, talent, performance, development
review, and talent review meeting information into a single reporting
dataset.

The SQL is designed for an Oracle HCM reporting environment and is structured
using Common Table Expressions (CTEs) to keep individual business logic
components separated and easier to maintain.

> **Note:** The SQL included in this public repository is a sanitized
> portfolio implementation. Company-specific identifiers, internal IDs,
> employee information, organization names, question codes, and proprietary
> implementation details have been replaced with generic values or
> placeholders.

---

## Query Architecture

The main query is divided into several logical components.

```text
Employee / Assignment
        |
        +--------------------+
        |                    |
        v                    v
Organization            Job Information
        |                    |
        +----------+---------+
                   |
                   v
             Talent Data
                   |
        +----------+----------+
        |                     |
        v                     v
Performance            Development Review
        |                     |
        +----------+----------+
                   |
                   v
          Talent Review Meeting
                   |
                   v
             Final Dataset