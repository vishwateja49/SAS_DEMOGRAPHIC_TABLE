/**********************************************************
Filename:- Project 2

Author:- Vishwa Teja

Date:-11DEC2022

SAS:-SAS9.4

Platform:- Windows 11

Project/Study:-002/001

Description:-To develop Demographic Table 0.2

Input:-ADAM.xls

Output:- Demographic Table

Macros used:-&TRT1,&TRT2,&TRT3,&TRT4

---------------------------------------------------------
Modification History:-

<DD-MON-YYYY> <FIRSTNAME LASTNAME>

<DESCRIPTION>

**********************************************************/


/*****************************IMPORTING THE DATA******************************/

PROC IMPORT OUT=DM
			DATAFILE='C:\Users\vishw\OneDrive\Desktop\SAS\proj\PROJECT 2\RAW.XLS'
			DBMS=XLS REPLACE;
			GETNAMES=YES;
			RUN;
/*****************************AGE******************************/
DATA AGE1;
SET DM;
KEEP AGE SEX ARM RACE ETHNIC USUBJID;
WHERE ARM NE 'Screen Failure';
RUN;

DATA AGE2;
SET AGE1;
OUTPUT;
ARM='OVERALL';
OUTPUT;
RUN;

PROC MEANS DATA=AGE2 maxdec=2 NOPRINT ;
VAR AGE;
OUTPUT OUT=AGE21(DROP=_TYPE_ _FREQ_)
N=N
MEAN=MEAN
STD=SD
MIN=MIN
median=median
MAX=MAX;
CLASS ARM;
RUN;
data age3;
set age21;
Means=   MEAN ||'('||strip(input(SD,4.2))||')';
Maxmin= max||','||strip(min);
Medians=median;
keep ARM n Means medians maxmin ;
label Means=' Mean(SD)'  Maxmin=' Max,Min' Medians=' Median';
run;
options center;
PROC TRANSPOSE DATA=AGE3 OUT=AGE4(DROP=_LABEL_);
VAR _ALL_;
ID ARM;
RUN;


DATA AGE5;
retain _name_ Miracle_Drug_10_mg Miracle_Drug_20_mg Placebo OVERALL;
length _name_ $14.;
SET AGE4;
IF _N_ = 1 THEN _name_='Age(Years)' ;
IF _N_ = 1 THEN Miracle_Drug_10_mg=' ' ;
IF _N_ = 1 THEN Miracle_Drug_20_mg=' ' ;
IF _N_ = 1 THEN OVERALL=' ' ;
IF _N_ = 1 THEN Placebo=' ' ;
if _n_>1 then _name_=' '||_name_;
format _name_ name.;
key=_name_;
cnt=1;
RUN;
/*****************************GENDER******************************/
proc freq data=age2  order=freq noprint;
table sex*arm / nopercent nocum norow nocol out=gen12  ;
run;
PROC SQL NOPRINT ;
SELECT COUNT(DISTINCT USUBJID) INTO: TRT1 FROM age2 WHERE ARM='OVERALL';
SELECT COUNT(DISTINCT USUBJID) INTO: TRT2 FROM age2 WHERE ARM='Placebo';
SELECT COUNT(DISTINCT USUBJID) INTO: TRT3 FROM age2 WHERE ARM='Miracle Drug 10 mg' ;
SELECT COUNT(DISTINCT USUBJID) INTO: TRT4 FROM age2 WHERE ARM='Miracle Drug 20 mg' ;
%PUT &TRT1 &TRT2 &TRT3 &TRT4;
QUIT;
data gen1(drop=count);
set gen12;
counts=put(count,$8.);
rename counts=count;
run;
DATA gen1_2;
SET gen1;
IF ARM='OVERALL' THEN DENOM=&TRT1;
IF ARM='Placebo' THEN DENOM=&TRT2;
IF ARM='Miracle Drug 10 mg' THEN DENOM=&TRT3;
IF ARM='Miracle Drug 20 mg' THEN DENOM=&TRT4;
PERCENT=PUT((COUNT/DENOM)*100,7.1);
CP=COUNT||' ('||STRIP(PERCENT)||')';
DROP DENOM;
RUN;
proc sort data=gen1_2; by sex; run;
options missing='0 (0.0)';
proc transpose data=gen1_2 out=gen1_3;
var CP  ;
by sex;
id arm;
run; 
data gen2;
set gen1_3;
if Miracle_Drug_10_mg=' ' then Miracle_Drug_20_mg='0 (0.0)';
if Miracle_Drug_20_mg=' ' then Miracle_Drug_20_mg='0 (0.0)';
if OVERALL=' ' then OVERALL='0 (0.0)';
if Placebo=' ' then Placebo='0 (0.0)';
run;
data dummy;
sex='Gender[n(a%)^]';
run;
proc sort data=gen3; by overall; run;

data gen3;
retain sex Miracle_Drug_10_mg Miracle_Drug_20_mg Placebo OVERALL;
length sex$17.;
set  dummy gen2;
drop _name_ _label_;
if sex='F' then  sex=' Female'    ;
if sex='M' then  sex=' Male'    ;
key=sex;
cnt=2;
run;

/*****************************ETHINIC******************************/
proc freq data=age2;
table ETHNIC*arm / nopercent nocol norow nocum out=ethnic12;
run;
data ethnic1(drop=count);
set ethnic12;
counts=put(count,$8.);
rename counts=count;
run;
DATA ethnic1_2;
SET ethnic1;
IF ARM='OVERALL' THEN DENOM=&TRT1;
IF ARM='Placebo' THEN DENOM=&TRT2;
IF ARM='Miracle Drug 10 mg' THEN DENOM=&TRT3;
IF ARM='Miracle Drug 20 mg' THEN DENOM=&TRT4;
PERCENT=PUT((COUNT/DENOM)*100,7.1);
CP=COUNT||' ('||STRIP(PERCENT)||')';
DROP DENOM;
RUN;
proc transpose data=ethnic1_2 out=ethnic2;
var cp;
id arm;
by ethnic;
run;
data dumm3;
length ethnic $18.;
input ethnic&$18.;
datalines;
Ethnicity[n(a%)^]
Hispanic or Latino
;
run;
data ethnic3;
retain ethnic Miracle_Drug_10_mg Miracle_Drug_20_mg Placebo OVERALL;
length ethnic $23. key $23.;
set dumm3 ethnic2;
ethnic=propcase(ethnic);
drop _name_ _label_;
if Miracle_Drug_10_mg=' ' then Miracle_Drug_10_mg='0 (0.0)';
if Miracle_Drug_20_mg=' ' then Miracle_Drug_20_mg='0 (0.0)';
if OVERALL=' ' then OVERALL='0 (0.0)';
if Placebo=' ' then Placebo='0 (0.0)';
if _n_ >1 then ethnic=' '||ethnic;
if _n_ =1 then Miracle_Drug_10_mg=' ';
if _n_ =1 then Miracle_Drug_20_mg=' ';
if _n_ =1 then OVERALL=' ';
if _n_ =1 then Placebo=' ';
key=ethnic;
cnt=3;
run;

/*****************************RACE******************************/
proc freq data=age2;
table RACE*arm / nopercent nocol norow nocum out=RACE12;
run;
data RACE1(drop=count);
set RACE12;
counts=put(count,$8.);
rename counts=count;
run;
DATA RACE1_2;
SET RACE1;
IF ARM='OVERALL' THEN DENOM=&TRT1;
IF ARM='Placebo' THEN DENOM=&TRT2;
IF ARM='Miracle Drug 10 mg' THEN DENOM=&TRT3;
IF ARM='Miracle Drug 20 mg' THEN DENOM=&TRT4;
PERCENT=PUT((COUNT/DENOM)*100,7.1);
CP=COUNT||'  ('||STRIP(PERCENT)||')';
DROP DENOM;
RUN;
proc transpose data=RACE1_2 out=RACE2;
var cp;
id arm;
by RACE;
run;
data dumm4;
length RACE $42.;
input RACE&$42.;
datalines; 
Asian
American Indian or Alaskan Native
Native Hawaiian or Other Pacific Islander
;
run;
data race3;
retain race Miracle_Drug_10_mg Miracle_Drug_20_mg Placebo OVERALL;
length race $42.;
set dumm4 race2;
Race=propcase(race);
drop _name_ _label_; 
if race='White' then ord=1;
if race='Black Or African American' then ord=2;
if race='Asian' then ord=3;
if _n_ =2 then ord=4;
if _n_ =3 then ord=5;
if race='Other' then ord=6;
if race='Multiple' then ord=7;

run;
proc sort data=race3; by ord; run;

data dumm5;
race='Race[n(a%)^]';
run;
 
data race4;
length race $42. key $42.;
set dumm5 race3;
if Miracle_Drug_10_mg=' ' then Miracle_Drug_10_mg='0 (0.0)';
if Miracle_Drug_20_mg=' ' then Miracle_Drug_20_mg='0 (0.0)';
if OVERALL=' ' then OVERALL='0 (0.0)';
if Placebo=' ' then Placebo='0 (0.0)';
if _n_ >1 then race=' '||race;
if _n_ =1 then Miracle_Drug_10_mg=' ';
if _n_ =1 then Miracle_Drug_20_mg=' ';
if _n_ =1 then OVERALL=' ';
if _n_ =1 then Placebo=' ';
drop ord;
key=race;
cnt=4;
run;

/*****************************report******************************/

data report;
length key $42.;
retain key;
set age5 gen3 ethnic3 race4;
drop _name_ ethnic race sex; 
run;
proc format;
value $ac 'Age(Years)'='bold'  'Gender[n(a%)^]'='bold' 'Ethnicity[n(A%)^]'='bold' 'Race[n(a%)^]'='bold';
run;
proc format ;
value $name ' Means'='Mean(SD)' 
			' Maxmin'='Max,Min'
			' Medians'='Median'
  			'Gender[n('='Gender[n(a%)^]'
			'Ethnicity[n(A%'='Ethnicity[n(a%)^]' 
    		'Hispanic Or L'='Hispanic or Latino'
            'Not Hispanic' ='Not Hispanic Or Latin'
   			'Black Or Afri'='Black Or African American'
			'American Indi'='American Indian or Alaskan Native'
   			'Native Hawaii'='Native Hawaiian or Other Pacific Islander';
run;
options nodate nonumber orientation=landscape;
ods pdf file='C:\Users\vishw\OneDrive\Desktop\SAS\proj\PROJECT 2\mock.pdf' style=monospace   ;
proc report data=report out=report2 center  style(report)={outputwidth=100%  }  
style(column)={font_face=timesnewroman font_size=3}style(header)={font_face=timesnewroman font_weight=bold font_size=3}  ;
columns key Miracle_Drug_10_mg Miracle_Drug_20_mg Placebo OVERALL cnt ;
define key/' ' width=30 display WIDTH=45 style(column)={font_weight=$ac.} format=$name.   ;
define Miracle_Drug_10_mg/"Miracle_Drug_10_mg/(N=%cmpres(&TRT3))" WIDTH=25 center display  ;
define Miracle_Drug_20_mg/"Miracle_Drug_20_mg/(N=%cmpres(&TRT4))" WIDTH=25 center display;
define Placebo/"Placebo      /(N=%cmpres(&TRT2))" WIDTH=25 center display;
define OVERALL/"OVERALL/(N=%cmpres(&TRT1))" WIDTH=25 center display; 
define cnt/ group  noprint;  ;
TITLE1 f=timesnewroman h=3 justify=left"Bigg Pharmaceutical Company" justify=right
"Date:16DEC2022         " ;
title2 f=timesnewroman h=3justify=left"Miracle_Drug-002" justify=right 
"Program Demographic.SAS";
title3 f=timesnewroman h=3  justify=right
"Page 1 of 1            "; 
compute after _page_
/style=[ font_size=10pt font_face=timesnewroman just=left];
line "Reference:Listing 16.2.4.1";
line "^Percentages are based on the number of subjects in the population";
endcomp; 
compute before _page_
/ style={font_Size=12pt font_weight=bold font_face=timesnewroman just=center};
line "14.1.5.2 Subject Demographic and Baseline Characteristics";
line "Safety Population";
line "_____________________________________________________________________________________________________________";
endcomp;  
break after cnt/ summarize;
run;
ods pdf close; 
