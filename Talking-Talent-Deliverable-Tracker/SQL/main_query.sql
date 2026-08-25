/*
=======================================================================================================================================
Project             : Talking Talent Deliverable Tracker
Report              : Talking Talent Deliverable Tracker - Detailed Report
Dataset              : TT_Tracker

Purpose:
    Portfolio implementation demonstrating an Oracle HCM reporting solution
    for a Talking Talent / Talent Review Deliverable Tracker.

Developer           : Taniya Sharma
Version             : 1.0
Original Development: 2026

IMPORTANT:
    This is a sanitized portfolio version created for demonstration purposes.
    Company-specific identifiers, employee data, organization IDs, question
    codes and proprietary values have been replaced with generic equivalents.

=======================================================================================================================================
*/


WITH
/*=====================================================================
  1. ORGANIZATION DETAILS
  ---------------------------------------------------------------------
  Builds the organizational context for each employee's department.
=====================================================================*/
department_details AS
(
    SELECT
        dept.organization_id,
        dept.department_name,

        org.attribute_oc AS organizational_cluster,

        bu.organization_name AS business_unit,
        pl.organization_name AS product_line,
        rc.organization_name AS regional_cluster

    FROM department_master dept

    LEFT JOIN organization_attributes org
        ON dept.organization_id = org.organization_id

    LEFT JOIN organization_master bu
        ON bu.organization_id =
           CASE
               WHEN REGEXP_LIKE(org.attribute_business_unit, '^[0-9]+$')
               THEN TO_NUMBER(org.attribute_business_unit)
           END

    LEFT JOIN organization_master pl
        ON pl.organization_id =
           CASE
               WHEN REGEXP_LIKE(org.attribute_product_line, '^[0-9]+$')
               THEN TO_NUMBER(org.attribute_product_line)
           END

    LEFT JOIN organization_master rc
        ON rc.organization_id =
           CASE
               WHEN REGEXP_LIKE(org.attribute_regional_cluster, '^[0-9]+$')
               THEN TO_NUMBER(org.attribute_regional_cluster)
           END

    WHERE dept.status = 'ACTIVE'

      AND TRUNC(SYSDATE)
          BETWEEN dept.effective_start_date
              AND dept.effective_end_date
),


/*=====================================================================
  2. CURRENT TALENT FLAG
  ---------------------------------------------------------------------
  Retrieves the most recent talent nomination/designation.
=====================================================================*/
current_talent_flag AS
(
    SELECT
        person_id,
        talent_flag,
        last_updated_date

    FROM
    (
        SELECT
            profile.person_id,

            rating.rating_description AS talent_flag,

            item.last_update_date AS last_updated_date,

            ROW_NUMBER() OVER
            (
                PARTITION BY profile.person_id
                ORDER BY item.date_from DESC,
                         item.creation_date DESC
            ) AS rn

        FROM talent_profile profile

        JOIN talent_profile_item item
            ON profile.profile_id = item.profile_id

        LEFT JOIN talent_rating rating
            ON item.rating_level_id = rating.rating_level_id

        WHERE item.section_code = '<TALENT_SECTION>'
          AND item.active_flag = 'Y'
    )

    WHERE rn = 1
),


/*=====================================================================
  3. PREVIOUS TALENT FLAG
  ---------------------------------------------------------------------
  Retrieves the previous talent nomination/designation.
=====================================================================*/
previous_talent_flag AS
(
    SELECT
        person_id,
        talent_flag AS previous_talent_flag

    FROM
    (
        SELECT
            profile.person_id,

            rating.rating_description AS talent_flag,

            ROW_NUMBER() OVER
            (
                PARTITION BY profile.person_id
                ORDER BY item.date_from DESC,
                         item.creation_date DESC
            ) AS rn

        FROM talent_profile profile

        JOIN talent_profile_item item
            ON profile.profile_id = item.profile_id

        LEFT JOIN talent_rating rating
            ON item.rating_level_id = rating.rating_level_id

        WHERE item.section_code = '<TALENT_SECTION>'
          AND item.active_flag = 'Y'
    )

    WHERE rn = 2
),


/*=====================================================================
  4. LATEST PERFORMANCE APPRAISAL
  ---------------------------------------------------------------------
  Retrieves the latest completed performance appraisal rating.
=====================================================================*/
latest_performance_appraisal AS
(
    SELECT
        worker_id,
        performance_rating

    FROM
    (
        SELECT
            evaluation.worker_id,

            rating.rating_description AS performance_rating,

            ROW_NUMBER() OVER
            (
                PARTITION BY evaluation.worker_id
                ORDER BY evaluation.evaluation_date DESC
            ) AS rn

        FROM performance_evaluation evaluation

        LEFT JOIN performance_rating rating
            ON evaluation.rating_id = rating.rating_id

        WHERE evaluation.evaluation_type =
              '<PERFORMANCE_APPRAISAL>'

          AND evaluation.status = 'COMPLETED'
    )

    WHERE rn = 1
),


/*=====================================================================
  5. DEVELOPMENT REVIEW DETAILS
  ---------------------------------------------------------------------
  Retrieves the latest responses to selected development-review
  questions.
=====================================================================*/
development_review AS
(
    SELECT
        worker_id,
        question_code,
        answer_text

    FROM
    (
        SELECT

            evaluation.worker_id,

            question.question_code,

            response.answer_text,

            ROW_NUMBER() OVER
            (
                PARTITION BY
                    evaluation.worker_id,
                    question.question_code

                ORDER BY
                    evaluation.evaluation_id DESC,
                    response.attempt_number DESC
            ) AS rn

        FROM development_evaluation evaluation

        JOIN questionnaire_response response
            ON evaluation.evaluation_id =
               response.evaluation_id

        JOIN questionnaire_question question
            ON response.question_id =
               question.question_id

        WHERE evaluation.document_type =
              '<DEVELOPMENT_REVIEW>'

          AND evaluation.status = 'COMPLETED'

          AND question.question_code IN
          (
              '<CAREER_MOBILITY_QUESTION>',
              '<GEOGRAPHIC_MOBILITY_QUESTION>'
          )
    )

    WHERE rn = 1
),


/*=====================================================================
  6. LATEST TALENT REVIEW MEETING
  ---------------------------------------------------------------------
  Retrieves the latest meeting where the employee is a participant.
=====================================================================*/
latest_talent_review AS
(
    SELECT
        participant_person_id,
        meeting_id,
        meeting_title,
        meeting_creation_date,
        meeting_date,
        business_leader_person_id

    FROM
    (
        SELECT

            participant.participant_person_id,

            meeting.meeting_id,

            meeting.meeting_title,

            meeting.creation_date AS meeting_creation_date,

            meeting.meeting_date,

            leader.participant_person_id
                AS business_leader_person_id,

            ROW_NUMBER() OVER
            (
                PARTITION BY participant.participant_person_id

                ORDER BY meeting.creation_date DESC,
                         meeting.meeting_id DESC
            ) AS rn

        FROM talent_review_participant participant

        JOIN talent_review_meeting meeting
            ON participant.meeting_id =
               meeting.meeting_id

        LEFT JOIN talent_review_participant leader
            ON participant.meeting_id =
               leader.meeting_id

           AND leader.participant_type =
               'BUSINESS_LEADER'

        WHERE participant.participant_type =
              'PARTICIPANT'
    )

    WHERE rn = 1
),


/*=====================================================================
  7. JOB SENIORITY
  ---------------------------------------------------------------------
  Determines the earliest effective date for the employee's
  assignment/job combination.
=====================================================================*/
job_seniority AS
(
    SELECT

        assignment_id,
        job_id,

        MIN(effective_start_date) AS job_start_date

    FROM employee_assignment_history

    WHERE assignment_type = 'EMPLOYEE'

    GROUP BY
        assignment_id,
        job_id
)


/*=====================================================================
  8. FINAL DATASET
=====================================================================*/

SELECT

    /*---------------------------------------------------------------
      Employee Information
    ---------------------------------------------------------------*/

    employee.person_number,

    person.first_name,

    person.last_name,

    person.display_name,

    assignment.assignment_status,

    assignment.person_type,


    /*---------------------------------------------------------------
      Organizational Information
    ---------------------------------------------------------------*/

    dept.organizational_cluster,

    dept.business_unit,

    dept.product_line,

    dept.regional_cluster,


    /*---------------------------------------------------------------
      Employee Demographics
    ---------------------------------------------------------------*/

    CASE
        WHEN person.date_of_birth IS NULL
        THEN NULL

        ELSE FLOOR
        (
            MONTHS_BETWEEN
            (
                TRUNC(SYSDATE),
                person.date_of_birth
            ) / 12
        )
    END AS age,


    CASE
        WHEN person.gender IS NULL
        THEN 'Not Reported'

        WHEN person.gender = 'M'
        THEN 'Male'

        WHEN person.gender = 'F'
        THEN 'Female'

        ELSE 'Others'
    END AS gender,


    /*---------------------------------------------------------------
      Job Information
    ---------------------------------------------------------------*/

    job_family.job_family_name,

    job_sub_family.sub_job_family_name,

    assignment.local_job_title,

    grade.grade_name,

    job.discipline,


    /*---------------------------------------------------------------
      Talent Information
    ---------------------------------------------------------------*/

    current_talent.talent_flag
        AS current_top_talent_flag,

    previous_talent.previous_talent_flag,


    /*---------------------------------------------------------------
      Talent Evolution
    ---------------------------------------------------------------*/

    CASE

        WHEN NVL
        (
            previous_talent.previous_talent_flag,
            'Not Nominated'
        ) = 'Not Nominated'

        AND current_talent.talent_flag
            IN ('T1', 'T2', 'T3')

        THEN 'New'


        WHEN current_talent.talent_flag =
             previous_talent.previous_talent_flag

        THEN 'Same'


        WHEN
            CASE current_talent.talent_flag
                WHEN 'T1' THEN 4
                WHEN 'T2' THEN 3
                WHEN 'T3' THEN 2
                ELSE 1
            END

            >

            CASE NVL
            (
                previous_talent.previous_talent_flag,
                'Not Nominated'
            )
                WHEN 'T1' THEN 4
                WHEN 'T2' THEN 3
                WHEN 'T3' THEN 2
                ELSE 1
            END

        THEN 'Up'


        WHEN
            CASE current_talent.talent_flag
                WHEN 'T1' THEN 4
                WHEN 'T2' THEN 3
                WHEN 'T3' THEN 2
                ELSE 1
            END

            <

            CASE NVL
            (
                previous_talent.previous_talent_flag,
                'Not Nominated'
            )
                WHEN 'T1' THEN 4
                WHEN 'T2' THEN 3
                WHEN 'T3' THEN 2
                ELSE 1
            END

        THEN 'Down'


        ELSE NULL

    END AS top_talent_evolution,


    /*---------------------------------------------------------------
      Performance
    ---------------------------------------------------------------*/

    performance.performance_rating,


    /*---------------------------------------------------------------
      Development Review
    ---------------------------------------------------------------*/

    career_move.answer_text
        AS ready_for_career_move,

    geographic_mobility.answer_text
        AS geographic_mobility,


    /*---------------------------------------------------------------
      Job Seniority
    ---------------------------------------------------------------*/

    seniority.job_start_date
        AS last_job_change_date,


    TRUNC
    (
        MONTHS_BETWEEN
        (
            TRUNC(SYSDATE),
            seniority.job_start_date
        ) / 12
    )
    || ' Years '
    ||
    MOD
    (
        TRUNC
        (
            MONTHS_BETWEEN
            (
                TRUNC(SYSDATE),
                seniority.job_start_date
            )
        ),
        12
    )
    || ' Months '
    ||
    (
        TRUNC(SYSDATE)
        -
        ADD_MONTHS
        (
            seniority.job_start_date,

            TRUNC
            (
                MONTHS_BETWEEN
                (
                    TRUNC(SYSDATE),
                    seniority.job_start_date
                )
            )
        )
    )
    || ' Days'
    AS job_seniority_tenure,


    /*---------------------------------------------------------------
      Country / Legal Entity
    ---------------------------------------------------------------*/

    country.country_name
        AS legislative_country,

    legal_entity.legal_entity_name,


    /*---------------------------------------------------------------
      Talent Review Meeting
    ---------------------------------------------------------------*/

    meeting.meeting_title
        AS talent_review_meeting,

    meeting.meeting_creation_date
        AS talent_review_meeting_creation_date,

    meeting.meeting_date
        AS talent_review_meeting_date,

    business_leader.display_name
        AS business_leader_name


FROM employee_master employee


/*=====================================================================
  Employee / Assignment
=====================================================================*/

JOIN person_master person
    ON employee.person_id =
       person.person_id

JOIN employee_assignment assignment
    ON employee.person_id =
       assignment.person_id


/*=====================================================================
  Organization
=====================================================================*/

LEFT JOIN department_details dept
    ON assignment.organization_id =
       dept.organization_id


/*=====================================================================
  Job
=====================================================================*/

LEFT JOIN job_master job
    ON assignment.job_id =
       job.job_id

LEFT JOIN job_family job_family
    ON job.job_family_id =
       job_family.job_family_id

LEFT JOIN job_sub_family job_sub_family
    ON job.sub_job_family_code =
       job_sub_family.sub_job_family_code

LEFT JOIN grade_master grade
    ON assignment.grade_id =
       grade.grade_id


/*=====================================================================
  Talent
=====================================================================*/

LEFT JOIN current_talent_flag current_talent
    ON employee.person_id =
       current_talent.person_id

LEFT JOIN previous_talent_flag previous_talent
    ON employee.person_id =
       previous_talent.person_id


/*=====================================================================
  Performance
=====================================================================*/

LEFT JOIN latest_performance_appraisal performance
    ON employee.person_id =
       performance.worker_id


/*=====================================================================
  Development Review
=====================================================================*/

LEFT JOIN development_review career_move
    ON employee.person_id =
       career_move.worker_id

   AND career_move.question_code =
       '<CAREER_MOBILITY_QUESTION>'


LEFT JOIN development_review geographic_mobility
    ON employee.person_id =
       geographic_mobility.worker_id

   AND geographic_mobility.question_code =
       '<GEOGRAPHIC_MOBILITY_QUESTION>'


/*=====================================================================
  Job Seniority
=====================================================================*/

LEFT JOIN job_seniority seniority
    ON assignment.assignment_id =
       seniority.assignment_id

   AND assignment.job_id =
       seniority.job_id


/*=====================================================================
  Talent Review
=====================================================================*/

JOIN latest_talent_review meeting
    ON employee.person_id =
       meeting.participant_person_id

LEFT JOIN person_master business_leader
    ON meeting.business_leader_person_id =
       business_leader.person_id


/*=====================================================================
  Country / Legal Entity
=====================================================================*/

LEFT JOIN country_master country
    ON assignment.legislation_code =
       country.country_code

LEFT JOIN legal_entity_master legal_entity
    ON assignment.legal_entity_id =
       legal_entity.legal_entity_id


/*=====================================================================
  BASE POPULATION FILTERS
=====================================================================*/

WHERE assignment.effective_latest_change = 'Y'

  AND assignment.assignment_status
      IN ('ACTIVE', 'SUSPENDED')

  AND assignment.assignment_type =
      'EMPLOYEE'

  AND TRUNC(SYSDATE)
      BETWEEN employee.effective_start_date
          AND employee.effective_end_date

  AND TRUNC(SYSDATE)
      BETWEEN assignment.effective_start_date
          AND assignment.effective_end_date


/*=====================================================================
  EXCLUSIONS
=====================================================================*/

  AND employee.person_number
      NOT LIKE 'TEST_%'

  AND legal_entity.legal_entity_name
      NOT IN
      (
          '<EXCLUDED_LEGAL_ENTITY_1>',
          '<EXCLUDED_LEGAL_ENTITY_2>'
      )


/*=====================================================================
  REPORT PROMPTS
=====================================================================*/

  AND
  (
      EXTRACT
      (
          YEAR FROM meeting.meeting_creation_date
      )
      IN (:P_YEAR)

      OR LEAST(:P_YEAR) IS NULL
  )


  AND
  (
      country.country_name
      IN (:P_LEGISLATIVE_COUNTRY)

      OR LEAST(:P_LEGISLATIVE_COUNTRY) IS NULL
  )


  AND
  (
      dept.organizational_cluster
      IN (:P_OC)

      OR LEAST(:P_OC) IS NULL
  )


  AND
  (
      job.discipline
      IN (:P_DISCIPLINE)

      OR LEAST(:P_DISCIPLINE) IS NULL
  )


  AND
  (
      CASE
          WHEN person.gender IS NULL
          THEN 'Not Reported'

          WHEN person.gender = 'M'
          THEN 'Male'

          WHEN person.gender = 'F'
          THEN 'Female'

          ELSE 'Others'
      END

      IN (:P_GENDER)

      OR LEAST(:P_GENDER) IS NULL
  )


  AND
  (
      job_sub_family.sub_job_family_name
      IN (:P_SUB_JOB_FAMILY)

      OR LEAST(:P_SUB_JOB_FAMILY) IS NULL
  )


  AND
  (
      job_family.job_family_name
      IN (:P_JOB_FAMILY)

      OR LEAST(:P_JOB_FAMILY) IS NULL
  )


  AND
  (
      legal_entity.legal_entity_name
      IN (:P_LEGAL_ENTITY)

      OR LEAST(:P_LEGAL_ENTITY) IS NULL
  )


/*=====================================================================
  FINAL ORDERING
=====================================================================*/

ORDER BY

    country.country_name,

    employee.person_number;