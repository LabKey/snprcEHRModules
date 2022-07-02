package org.labkey.snprc_ehr.query;

public class QueryConstants
{
    public static final String AGE_AT_TIME_COLUMN = "Age At Time";
    public static final String AGE_AT_TIME_YEARS_COLUMN = "Age At Time Years";
    public static final String AGE_AT_TIME_YEARS_ROUNDED_COLUMN = "Age At Time Years Rounded";
    public static final String AGE_AT_TIME_DAYS_COLUMN = "Age At Time Days";
    public static final String AGE_AT_TIME_MONTHS_COLUMN = "Age At Time Months";
    public static final String AGE_CLASS_AT_TIME_COLUMN = "Age Class At Time";

    public static final String ASSIGNMENT_AT_TIME_COLUMN = "Assignment At Time";




    public static final String STUDY_SCHEMA = "study";
    public static final String CODE_COLUMN = "code";
    public static final String SPECIES_TABLE = "species";
    public static final String PROJECT_TABLE = "project";
    public static final String ANIMAL_TABLE = "animal";
    public static final String ASSIGNMENT_TABLE = "assignment";
    public static final String DATE_COLUMN = "date";
    public static final String DEMOGRAPHICS_TABLE = "demographics";
    public static final String ID_COLUMN = "Id";
    public static final String PROJECTS_AT_TIME_CALCULATED = "Projects At Time";
    public static final String PROTOCOLS_AT_TIME_CALCULATED = "Protocols At Time";
    public static final String PROJECT_NUMBERS_AT_TIME_CALCULATED = "Project Numbers At Time";

    public static final String PRIMARY_KEY_VARIABLE = "primaryKeyColumnName";
    public static final String SCHEMA_VARIABLE = "schemaName";
    public static final String EHR_PATH_VARIABLE = "ehrPath";
    public static final String QUERY_VARIABLE = "queryName";
    public static final String ID_COLUMN_VARIABLE = "idColumnName";
    public static final String TARGET_CONTAINER_VARIABLE ="targetContainerName";
    public static final String DATE_COLUMN_VARIABLE = "dateColumnName";

    public static final String ASSIGNMENT_AT_TIME_SQL = "SELECT\n" +
            "sd.${" + PRIMARY_KEY_VARIABLE + "},\n" +
            "group_concat(DISTINCT h.project.displayName, chr(10)) as projectsAtTime,\n" +
            "group_concat(DISTINCT h.protocol.displayName, chr(10)) as protocolsAtTime,\n" +
            "group_concat(DISTINCT h.project.project, chr(10)) as projectNumbersAtTime\n" +
            "FROM \"${" + SCHEMA_VARIABLE + "}\".\"${" + QUERY_VARIABLE + "}\" sd\n" +
            "JOIN \"${" + TARGET_CONTAINER_VARIABLE + "}\".study.assignment h\n" +
            "  ON (sd.id = h.id AND h.dateOnly <= CAST(sd.${" + DATE_COLUMN_VARIABLE + "} AS DATE) AND (CAST(sd.${" + DATE_COLUMN_VARIABLE +"} AS DATE) <= h.enddateCoalesced) AND h.qcstate.publicdata = true)\n" +
            "group by sd.${"+ PRIMARY_KEY_VARIABLE + "}";
    public static final String AGE_AT_TIME_SQL = "SELECT\n" +
            "c.${" + PRIMARY_KEY_VARIABLE + "},\n" +
            "\n" +
            "CAST(\n" +
            "CASE\n" +
            "WHEN d.birth is null or c.${" + DATE_COLUMN_VARIABLE + "} is null\n" +
            "  THEN null\n" +
            "WHEN (d.lastDayAtCenter IS NOT NULL AND d.lastDayAtCenter < c.${" + DATE_COLUMN_VARIABLE + "}) THEN\n" +
            " ROUND(CONVERT(age_in_months(d.birth, d.lastDayAtCenter), DOUBLE) / 12, 1)\n" +
            "ELSE\n" +
            "  ROUND(CONVERT(age_in_months(d.birth, CAST(c.${" + DATE_COLUMN_VARIABLE + "} as DATE)), DOUBLE) / 12, 1)\n" +
            "END AS float) as " + AGE_AT_TIME_COLUMN + ",\n" +
            "\n" +

            "CAST(\n" +
            "CASE\n" +
            "WHEN d.birth is null or c.${" + DATE_COLUMN_VARIABLE + "} is null\n" +
            "  THEN null\n" +
            "WHEN (d.lastDayAtCenter IS NOT NULL AND d.lastDayAtCenter < c.${" + DATE_COLUMN_VARIABLE + "}) THEN\n" +
            " ROUND(CONVERT(timestampdiff('SQL_TSI_DAY', d.birth, d.lastDayAtCenter), DOUBLE) / 365.25, 2)\n" +
            "ELSE\n" +
            "  ROUND(CONVERT(timestampdiff('SQL_TSI_DAY', d.birth, CAST(c.${" + DATE_COLUMN_VARIABLE + "} as DATE)), DOUBLE) / 365.25, 2)\n" +
            "END AS float) as " + AGE_AT_TIME_YEARS_COLUMN + ",\n" +
            "\n" +
            "CAST(\n" +
            "CASE\n" +
            "WHEN d.birth is null or c.${" + DATE_COLUMN_VARIABLE + "} is null\n" +
            "  THEN null\n" +
            "WHEN (d.lastDayAtCenter IS NOT NULL AND d.lastDayAtCenter < c.${" + DATE_COLUMN_VARIABLE + "}) THEN\n" +
            " floor(age(d.birth, d.lastDayAtCenter))\n" +
            "ELSE\n" +
            "  floor(age(d.birth, CAST(c.${" + DATE_COLUMN_VARIABLE + "} as DATE)))\n" +
            "END AS float) as " + AGE_AT_TIME_YEARS_ROUNDED_COLUMN + ",\n" +
            "\n" +
            //Added 'Age at time Days' by kollil on 02/15/2019
            "CAST(\n" +
            "CASE\n" +
            "WHEN d.birth is null or c.${" + DATE_COLUMN_VARIABLE + "} is null\n" +
            "  THEN null\n" +
            "WHEN (d.lastDayAtCenter IS NOT NULL AND d.lastDayAtCenter < c.${" + DATE_COLUMN_VARIABLE + "}) THEN\n" +
            "  CONVERT(TIMESTAMPDIFF('SQL_TSI_DAY',d.birth, d.lastDayAtCenter), INTEGER)\n" +
            "ELSE\n" +
            "  CONVERT(TIMESTAMPDIFF('SQL_TSI_DAY',d.birth, CAST(c.${" + DATE_COLUMN_VARIABLE + "} AS DATE)), INTEGER)\n" +
            "END AS float) as " + AGE_AT_TIME_DAYS_COLUMN + ",\n" +
            "\n" +
            //
            "CAST(\n" +
            "CASE\n" +
            "WHEN d.birth is null or c.${" + DATE_COLUMN_VARIABLE + "} is null\n" +
            "  THEN null\n" +
            "WHEN (d.lastDayAtCenter IS NOT NULL AND d.lastDayAtCenter < c.${" + DATE_COLUMN_VARIABLE + "}) THEN\n" +
            "  CONVERT(age_in_months(d.birth, d.lastDayAtCenter), INTEGER)\n" +
            "ELSE\n" +
            "  CONVERT(age_in_months(d.birth, CAST(c.${" + DATE_COLUMN_VARIABLE + "} AS DATE)), INTEGER)\n" +
            "END AS float) as " + AGE_AT_TIME_MONTHS_COLUMN + ",\n" +
            //NOTE: written as subselect so we ensure a single row returned in case data in ehr_lookups.ageclass has rows that allow dupes
            "(SELECT ac.ageclass FROM ehr_lookups.ageclass ac\n" +
            "  WHERE " +
            "  (CONVERT(age_in_months(d.birth, COALESCE(d.lastDayAtCenter, now())), DOUBLE) / 12) >= ac.\"min\" AND\n" +
            "  ((CONVERT(age_in_months(d.birth, COALESCE(d.lastDayAtCenter, now())), DOUBLE) / 12) < ac.\"max\" OR ac.\"max\" is null) AND\n" +
            "  d.species.arc_species_code = ac.species AND\n" +
            "  (d.gender = ac.gender OR ac.gender IS NULL)\n" +
            ") AS " + AGE_CLASS_AT_TIME_COLUMN + " \n" +
            "FROM \"${" + SCHEMA_VARIABLE + "}\".\"${" + QUERY_VARIABLE + "}\" c " +
            "LEFT JOIN \"${" + EHR_PATH_VARIABLE + "}\".study.demographics d ON (d.Id = c.${" + ID_COLUMN_VARIABLE + "})";


}
