/* Query to extract the most frequent clonal hematopoiesis mutations from blood samples */
proc sql;
    create table ch_mutations as
    select mutation_id, count(*) as mutation_count
    from blood_samples
    where mutation_type = 'Clonal Hematopoiesis'
    group by mutation_id
    order by mutation_count desc;
quit;

/* Display top 10 most frequent mutations */
proc print data=ch_mutations(obs=10);
run;


/* Query to check the correlation between Clonal Hematopoiesis mutations and cancer types */
proc sql;
    create table ch_cancer_correlation as
    select cancer_type, count(distinct patient_id) as num_patients_with_ch,
           count(distinct case when mutation_type = 'Clonal Hematopoiesis' then patient_id end) as ch_patients
    from tumor_blood_pairs
    group by cancer_type;
quit;

/* Calculate percentage of patients with Clonal Hematopoiesis mutations for each cancer type */
data ch_cancer_correlation_percentage;
    set ch_cancer_correlation;
    percentage_ch = (ch_patients / num_patients_with_ch) * 100;
run;

/* Display the results */
proc print data=ch_cancer_correlation_percentage;
run;


/* Query to analyze the relationship between Clonal Hematopoiesis mutations and overall survival */
proc sql;
    create table survival_analysis as
    select patient_id, overall_survival, pfs, mutation_type
    from clinical_data
    where mutation_type = 'Clonal Hematopoiesis';
quit;

/* Kaplan-Meier survival analysis for OS and PFS */
proc lifetest data=survival_analysis;
    time overall_survival * (status = 1); /* 1 = death, 0 = censored */
    strata mutation_type;
    run;

proc lifetest data=survival_analysis;
    time pfs * (status = 1); /* 1 = progression, 0 = censored */
    strata mutation_type;
    run;


/* Query to check if age and gender are associated with Clonal Hematopoiesis mutations */
proc sql;
    create table demographic_ch_association as
    select age, gender, count(*) as num_patients_with_ch
    from blood_samples
    where mutation_type = 'Clonal Hematopoiesis'
    group by age, gender;
quit;

/* Statistical analysis to see if demographic factors correlate with Clonal Hematopoiesis mutations */
proc freq data=demographic_ch_association;
    tables age*gender / chisq;
run;


/* Query to compare Clonal Hematopoiesis mutations between tumor and blood samples */
proc sql;
    create table mutation_comparison as
    select mutation_id,
           sum(case when sample_type = 'Blood' then 1 else 0 end) as blood_mutation_count,
           sum(case when sample_type = 'Tumor' then 1 else 0 end) as tumor_mutation_count
    from tumor_blood_pairs
    where mutation_type = 'Clonal Hematopoiesis'
    group by mutation_id;
quit;

/* Display mutation comparison */
proc print data=mutation_comparison;
run;