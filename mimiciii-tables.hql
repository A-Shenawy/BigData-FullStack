CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.D_CPT (
row_id	INT,
category	INT,
sectionrange	STRING,
sectionheader	STRING,
subsectionrange	STRING,
subsectionheader	STRING,
codesuffix	STRING,
mincodeinsubsection	INT,
maxcodeinsubsection	INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.D_ITEMS (
row_id	INT,
itemid	INT,
label	STRING,
abbreviation	STRING,
dbsource	STRING,
linksto	STRING,
category	STRING,
unitname	STRING,
param_type	STRING,
conceptid	INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';

CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.CPTEVENTS (
         row_id INT,
         subject_id INT,
         hadm_id INT,
         costcenter STRING,
         chartdate TIMESTAMP,
         cpt_cd STRING,
         cpt_number	INT,
         cpt_suffix STRING,
         ticket_id_seq	INT,
         sectionheader STRING,
         subsectionheader STRING,
         description STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';

CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.DRGCODES (
         row_id INT,
         subject_id INT,
         hadm_id INT,
         drg_type STRING,
         drg_code STRING,
         description STRING,
         drg_severity SMALLINT,
         drg_mortality SMALLINT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';

CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.TRANSFERS (
	row_id INT,
    subject_id INT,
    hadm_id INT,
    icustay_id INT,
    dbsource STRING,
    eventtype STRING,
    prev_careunit STRING,
    curr_careunit STRING,
    prev_wardid INT,
    curr_wardid INT,
    intime TIMESTAMP,
    OUTTIME TIMESTAMP,
    los DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.SERVICES (
	row_id INT,
    subject_id INT,
    hadm_id INT,
    transfertime TIMESTAMP,
    prev_service STRING,
    curr_service STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.OUTPUTEVENTS (
	row_id INT,
	subject_id INT,
	hadm_id INT,
	icustay_id INT,
	charttime TIMESTAMP,
	itemid INT,
	value INT,
	valueuom STRING,
	storetime TIMESTAMP,
	cgid INT,
	stopped DOUBLE,
	newbottle DOUBLE,
	iserror DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';

CREATE EXTERNAL TABLE IF NOT EXISTS  mimiciii.LABEVENTS (
	row_id INT,
	subject_id INT,
	hadm_id DOUBLE,
	itemid INT,
	charttime TIMESTAMP,
	value STRING,
	valuenum DOUBLE,
	valueuom TIMESTAMP,
	flag STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.CHARTEVENTS (
	row_id INT,
	subject_id INT,
	hadm_id INT,
	icustay_id INT,
	itemid INT,
	charttime TIMESTAMP,
	storetime TIMESTAMP,
	cgid INT,
	value DOUBLE,
	valuenum DOUBLE,
	valueuom STRING,
	warning INT,
	error INT,
	resultstatus DOUBLE,
	stopped DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.PATIENTS (
	row_id INT,
	subject_id INT,
	gender STRING,
	dob TIMESTAMP,
	dod TIMESTAMP,
	dod_hosp TIMESTAMP,
	dod_ssn TIMESTAMP,
	expire_flag INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.ICUSTAYS (
 	row_id INT,
	subject_id INT,
	hadm_id INT,
	icustay_id INT,
	dbsource STRING,
	first_careunit STRING,
	last_careunit STRING,
	first_wardid INT,
	last_wardid INT,
	intime TIMESTAMP,
	outtime TIMESTAMP,
	los DOUBLE
	)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.CALLOUT(
row_id	INT,
subject_id	INT,
hadm_id	INT,
submit_wardid	INT,
submit_careunit	STRING,
curr_wardid	INT,
curr_careunit	STRING,
callout_wardid	INT,
callout_service	STRING,
request_tele	INT,
request_resp	INT,
request_cdiff	INT,
request_mrsa	INT,
request_vre	INT,
callout_status	STRING,
callout_outcome	STRING,
discharge_wardid	INT,
acknowledge_status	STRING,
createtime	TIMESTAMP,
updatetime	TIMESTAMP,
acknowledgetime	TIMESTAMP,
outcometime	TIMESTAMP,
firstreservationtime	TIMESTAMP,
currentreservationtime	TIMESTAMP
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.ADMISSIONS (
row_id	INT,
subject_id	INT,
hadm_id	INT,
admittime	TIMESTAMP,
dischtime	TIMESTAMP,
deathtime	TIMESTAMP,
admission_type	STRING,
admission_location	STRING,
discharge_location	STRING,
insurance	STRING,
language	STRING,
religion	STRING,
marital_status	STRING,
ethnicity	STRING,
edregtime	TIMESTAMP,	
edouttime	TIMESTAMP,			
diagnosis	STRING,
hospital_expire_flag INT,			
has_chartevents_data INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';


CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.diagnoses_icd (
    row_id INT,
    subject_id INT,
    hadm_id INT,
    seq_num INT,
    icd9_code STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/mimiciii/';

-- Queries
----- Before optimization (finally run)
-- Query 1 :-

CREATE TABLE diagnosis_avg_length_of_stays AS
SELECT 
    di.icd9_code AS diagnosis_code, 
    ROUND(AVG(DATEDIFF(a.dischtime, a.admittime)), 2) AS avg_length_of_stay
FROM 
    admissions a
JOIN 
    diagnoses_icd di 
ON 
    a.hadm_id = di.hadm_id
GROUP BY 
    di.icd9_code
ORDER BY 
    avg_length_of_stay DESC;


-- Query 2:-

CREATE TABLE readmissions_summary AS
SELECT
   a.subject_id,
   COUNT(i.icustay_id) AS num_readmissions
FROM
   admissions a
JOIN
   icustays i
ON
   a.hadm_id = i.hadm_id
WHERE
   a.hadm_id IS NOT NULL
   AND i.hadm_id IS NOT NULL
GROUP BY
   a.subject_id
HAVING
   COUNT(i.icustay_id) > 1
ORDER BY
   num_readmissions DESC;

-- Query 3:-

CREATE TABLE mortality_rate_summary AS
SELECT 
   p.gender, 
   YEAR(FROM_UNIXTIME(UNIX_TIMESTAMP(p.dob, 'yyyy-MM-dd'))) AS birth_year,
   COUNT(CASE WHEN a.hospital_expire_flag = 1 THEN 1 END) AS mortality_count,
   COUNT(*) AS total_admissions,
   ROUND(100.0 * COUNT(CASE WHEN a.hospital_expire_flag = 1 THEN 1 END) / COUNT(*), 2) AS mortality_rate_percentage
FROM 
   patients p
JOIN 
   admissions a
ON 
   p.subject_id = a.subject_id
GROUP BY 
   p.gender, YEAR(FROM_UNIXTIME(UNIX_TIMESTAMP(p.dob, 'yyyy-MM-dd')))
ORDER BY 
   mortality_rate_percentage DESC;


---- After Optimization

---- Before run query, creating the needed table with orc format, bucketed for all tables

-- Reducing the number of buckets to 10
CREATE TABLE IF NOT EXISTS mimiciii.admissions_partitioned_buckets (
    row_id INT,
    subject_id INT,
    hadm_id INT,
    admittime TIMESTAMP,
    dischtime TIMESTAMP,
    deathtime TIMESTAMP,
    admission_type STRING,
    admission_location STRING,
    discharge_location STRING,
    insurance STRING,
    language STRING,
    religion STRING,
    marital_status STRING,
    ethnicity STRING,
    edregtime TIMESTAMP,  
    edouttime TIMESTAMP,  
    diagnosis STRING,
    hospital_expire_flag INT,  
    has_chartevents_data INT
)
CLUSTERED BY (hadm_id) INTO 10 BUCKETS
STORED AS ORC;

-- Adjust partitioning or avoid it based on data distribution
-- Example without partitioning by 'admit_year'
INSERT OVERWRITE TABLE mimiciii.admissions_partitioned_buckets
SELECT 
    row_id,
    subject_id,
    hadm_id,
    admittime,
    dischtime,
    deathtime,
    admission_type,
    admission_location,
    discharge_location,
    insurance,
    language,
    religion,
    marital_status,
    ethnicity,
    edregtime,  
    edouttime,  
    diagnosis,
    hospital_expire_flag,  
    has_chartevents_data
FROM admissions;


-- Create the bucketed table stored as ORC
CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.diagnoses_icd_bucketed (
    row_id INT,
    subject_id INT,
    hadm_id INT,
    seq_num INT,
    icd9_code STRING
)
CLUSTERED BY (hadm_id) INTO 10 BUCKETS
STORED AS ORC;

-- Overwrite data into the bucketed ORC table
INSERT OVERWRITE TABLE mimiciii.diagnoses_icd_bucketed
SELECT 
    row_id, 
    subject_id, 
    hadm_id, 
    seq_num, 
    icd9_code
FROM 
    mimiciii.diagnoses_icd;


-- Create the bucketed table stored as ORC
CREATE EXTERNAL TABLE IF NOT EXISTS mimiciii.PATIENTS_bucketed (
    row_id INT,
    subject_id INT,
    gender STRING,
    dob TIMESTAMP,
    dod TIMESTAMP,
    dod_hosp TIMESTAMP,
    dod_ssn TIMESTAMP,
    expire_flag INT
)
CLUSTERED BY (subject_id) INTO 10 BUCKETS
STORED AS ORC;

-- Overwrite data into the bucketed ORC table
INSERT OVERWRITE TABLE mimiciii.PATIENTS_bucketed
SELECT 
    row_id, 
    subject_id, 
    gender, 
    dob, 
    dod, 
    dod_hosp, 
    dod_ssn, 
    expire_flag
FROM 
    mimiciii.PATIENTS;


---Query 1 :-

CREATE TABLE diagnosis_avg_length_of_stays_bucketed AS
SELECT 
    di.icd9_code AS diagnosis_code, 
    ROUND(AVG(DATEDIFF(a.dischtime, a.admittime)), 2) AS avg_length_of_stay
FROM 
    mimiciii.admissions_bucketed a
JOIN 
    mimiciii.diagnoses_icd_bucketed di 
ON 
    a.hadm_id = di.hadm_id
GROUP BY 
    di.icd9_code
ORDER BY 
    avg_length_of_stay DESC;


-- Query 2:-

CREATE TABLE readmissions_summary AS
SELECT
   a.subject_id,
   COUNT(i.icustay_id) AS num_readmissions
FROM
   admissions_bucketed a
JOIN
   icustays_bucketed i
ON
   a.hadm_id = i.hadm_id
WHERE
   a.hadm_id IS NOT NULL
   AND i.hadm_id IS NOT NULL
GROUP BY
   a.subject_id
HAVING
   COUNT(i.icustay_id) > 1
ORDER BY
   num_readmissions DESC;

Query 3:-

CREATE TABLE mortality_rate_summary_bucketed AS
SELECT 
   p.gender, 
   YEAR(FROM_UNIXTIME(UNIX_TIMESTAMP(p.dob, 'yyyy-MM-dd'))) AS birth_year,
   COUNT(CASE WHEN a.hospital_expire_flag = 1 THEN 1 END) AS mortality_count,
   COUNT(*) AS total_admissions,
   ROUND(100.0 * COUNT(CASE WHEN a.hospital_expire_flag = 1 THEN 1 END) / COUNT(*), 2) AS mortality_rate_percentage
FROM 
   patients_bucketed p
JOIN 
   admissions_bucketed a
ON 
   p.subject_id = a.subject_id
GROUP BY 
   p.gender, YEAR(FROM_UNIXTIME(UNIX_TIMESTAMP(p.dob, 'yyyy-MM-dd')))
ORDER BY 
   mortality_rate_percentage DESC;
