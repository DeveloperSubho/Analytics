/*Setting Library*/
LIBNAME API "C:\SAS_101\SAS Class Sessions\SESSION 9";
RUN;

/*To Export SAS Data to Excel FIle*/
ODS HTML FILE = "C:\SAS_101\SAS Class Sessions\SESSION 9\AcademicPredictionData.XLS";
PROC PRINT DATA = API.ELEMAPI;
RUN;ODS HTML CLOSE;

/*Univariate Test to check outliers exist or not*/
ODS HTML FILE = "C:\SAS_101\SAS Class Sessions\SESSION 9\Univariate.XLS";
PROC UNIVARIATE DATA = API.ELEMAPI NEXTROBS = 15;
RUN;ODS HTML CLOSE;


/*Checking whether sum of % is 100 or Not*/
DATA API.A;SET API.ELEMAPI;
S=NOT_HSG+HSG+SOME_COL+COL_GRAD+GRAD_SCH;RUN;

PROC FREQ DATA = API.A;TABLES S;RUN;

/*CHECKING WHETHER MISSING AVG ED AND SUM OF*/
/*% EDUCTIUON = 0 ARE FOR THE SAME SET*/
/*OF SCHOOLS*/
PROC FREQ DATA = API.A;TABLES S;
WHERE AVG_ED = .;RUN;

/*Checking outliers*/
ODS HTML FILE = "C:\SAS_101\SAS Class Sessions\SESSION 9\OutliersChecking.XLS";
PROC MEANS DATA = API.ELEMAPI MIN MAX
MEAN MEDIAN Q1 Q3 STD;RUN;ODS HTML CLOSE;

/*Outlier checking */
PROC FREQ DATA = API.A;TABLES DNUM;
WHERE FULL <=1;RUN;

/*Outlier Treatment*/
DATA API.A;SET API.A;
ACS_K3 = ABS(ACS_K3);				/*-ve to +ve*/
IF AVG_ED = . THEN AVG_ED = 0; 		/*Missing value to 0*/
IF FULL <=1 THEN FULL = FULL*100;	/*Invalid Ratios to %*/
/*OUTLIERS*/
IF ENROLL>1264 THEN ENROLL=1264;
IF API00>918 THEN API00=918;RUN;

/*Missing Values Checking*/
PROC MEANS DATA = API.A MEAN NMISS;RUN;

/*Checking the Distribution of Mealcal Variable*/
PROC MEANS DATA = API.A MIN MAX MEAN NMISS;
VAR MEALS;CLASS MEALCAT;RUN;

/*Missing Values Treatment*/
DATA API.A;SET API.A;
IF ACS_K3 = . THEN ACS_K3 =19.1608040;
IF ACS_46 = . THEN ACS_46 =29.6851385;
IF MOBILITY = . THEN MOBILITY =18.2531328;
IF MEALCAT = 1 AND MEALS = . THEN 
MEALS = 28.36;
IF MEALCAT = 2 AND MEALS = . THEN 
MEALS = 66.0468750;RUN;

/*Frequency for Category Variables*/
PROC FREQ DATA = API.A;TABLES MEALCAT YR_RND;RUN;

/*Correlation with Continuous variables*/
ODS HTML FILE = "C:\SAS_101\SAS Class Sessions\SESSION 9\CorrelationContinuous.XLS";
PROC CORR DATA = API.A;
WITH API00;RUN;ODS HTML CLOSE;

/*
1.	Sign OK Significance OK =>Include
2. 	Sign Not OK SIgnificance Not OK =>Exclude
3.	Sign OK Significane Not OK =>Scatter Plot and Study Non Linear Pattern, Correlation between some transformed variables
4.	Sign Not OK Significance OK =>Report
*/

/*Mean Test with Category Variables to check the Correlation*/
PROC MEANS DATA = API.A MEAN;VAR API00;
CLASS MEALCAT;RUN;

/*ANOVA to check Significance of Mealcat Category Variable*/
PROC ANOVA DATA = API.A;CLASS MEALCAT;
MODEL API00=MEALCAT;RUN;

PROC MEANS DATA = API.A MEAN;VAR API00;
CLASS YR_RND;RUN;

/*Mean of other variables to validate yr_rnd data*/
PROC MEANS DATA = API.A MEAN;
VAR MOBILITY FULL MEALS;
CLASS YR_RND;RUN;

PROC MEANS DATA = API.A MEAN;
VAR FULL;
CLASS YR_RND;RUN;

/*ANOVA to check Sigificance of yr_rnd variable*/
PROC ANOVA DATA = API.A;CLASS YR_RND;
MODEL API00=YR_RND;RUN;

PROC CONTENTS DATA = API.A;RUN;

DATA API.A;SET API.A;
logmeals=log(meals);RUN;

/*Y = A+B1X1+B2X2+….+BKXK + U*/
/*Regression Analysis*/
ODS HTML FILE = "C:\SAS_101\SAS Class Sessions\SESSION 9\RegressionWithVIFCollinIter11.XLS";
PROC REG DATA = API.A;
MODEL API00 = 
meals
/*ell*/
yr_rnd
/*mobility*/
/*acs_k3*/
/*acs_46*/
/*not_hsg*/
/*hsg*/
/*some_col*/
/*col_grad*/
grad_sch
/*avg_ed */
full
/*emer*/
/*enroll*/
/*mealcat*/	
/VIF COLLIN;
RUN;
ODS HTML CLOSE;

/*Variables for Model Generation*/
/*ALPHA = 0.01%*/
/*VIF <=1.5, P <0.0001*/
ODS HTML FILE = "C:\SAS_101\SAS Class Sessions\SESSION 9\RegressionModelVariables.XLS";
PROC REG DATA = API.A;
MODEL API00 = 
/*meals*/
ell
/*yr_rnd*/
mobility
/*acs_k3*/
/*acs_46*/
/*not_hsg*/
/*hsg*/
/*some_col*/
/*col_grad*/
/*grad_sch*/
avg_ed
full
/*emer*/
/*enroll*/
/*mealcat*/
/VIF COLLIN;
RUN;
ODS HTML CLOSE;

/*HOMOSCEDASTICITY - i.e. THE*/
/*VARIANCE OF THE ERROR COMPONENT */
/*MUST BE CONSTANT ACROSS THE CROSS SECTION*/
/*WHITE'S TEST*/
/*H0: MODEL IS HOMOSCEDASTIC*/
/*H1: MODEL IS HETEROSCEDASTIC;*/
/*P < ALPHA => HETEROSCEDASTICITY WHICH*/
/*CAN BE REDUCED BY TRANSFORMATION OF X*/
/*VARIABLES PARTICULARLY LOG OR*/
/*SQUARE ROOT*/
ODS HTML FILE = "C:\SAS_101\SAS Class Sessions\SESSION 9\ModelChecking.xls";
PROC REG DATA = API.A;
MODEL API00 = 
/*meals*/
ell
/*yr_rnd*/
mobility
/*acs_k3*/
/*acs_46*/
/*not_hsg*/
/*hsg*/
/*some_col*/
/*col_grad*/
/*grad_sch*/
avg_ed
full
/*emer*/
/*enroll*/
/*mealcat*/
/SPEC;
RUN;
ODS HTML CLOSE;

/*CREATE THE OUTPUT FILE*/
PROC REG DATA = API.A;
MODEL API00 = 
/*meals*/
ell
/*yr_rnd*/
mobility
/*acs_k3*/
/*acs_46*/
/*not_hsg*/
/*hsg*/
/*some_col*/
/*col_grad*/
/*grad_sch*/
avg_ed
full
/*emer*/
/*enroll*/
/*mealcat*/
;
OUTPUT OUT = API.O 
P = PRED R = RES;RUN;QUIT;

/*NORMALITY OF RESIDUAL*/
PROC UNIVARIATE DATA = API.O NORMAL;
VAR RES;HISTOGRAM RES/NORMAL;RUN;

/*MAPE*/
/*MEAN ABSOLUTE PERCENTAGE ERROR*/
/*ERROR = ACTUAL - PREDICTED*/
/*ABS(ERROR/ACTUAL)*100*/
/*MEAN OF THE ABOVE = MAPE*/
DATA API.O;SET API.O;
ERROR = ABS(RES/API00)*100;RUN;
PROC MEANS DATA = API.O MEAN;VAR ERROR;RUN;

/*
1. OVERALL SIGNIFICANCE P < ALPHA
2. MULTICOLLINEARITY - VIF <=1.5
3. INDIVIDUAL SIGNIFICANCE - P < ALPHA
4. HOMOSCEDASTICITY CHECK - P > ALPHA
5. NORMALITY CHECK - P > APLHA
6. MAPE <=10%
7. R - SQUARE >= 65%
*/

/*
1.	EXCEL FILE - VIF AND SPEC - R2 > 65%, 
VIF <=1.5(2), P < 0.0001, SPEC - P > 0.0001
2.	EXCEL FILE - UNIVARIATE WITH NORMAL - 
NORMAL P VALUE NOT SIGNIFICANT
3.	NORMAL GRAPH 
4.	MAPE - BELOW 10%
5.	DASHBOARD
6.	PPT ;
*/

/*Splitting the Dataset into Development and Validation*/
DATA D V;
SET SASHELP.AIR;
IF RANUNI(458712) <=0.6 THEN OUTPUT D;
ELSE OUTPUT V;RUN;

/*
1. OBJECTIVE
2. OUTCOME - MAPE. R -SQUARE
3. CONCLUSION
4. STRATEGY
5. APPENDIX 

*/
proc reg data="C:\SAS_101\SAS Class Sessions\SESSION 9\elemapi";
  model api00 = acs_k3 meals full;
run;

DATA API.CaseStudy1;
SET "C:\SAS_101\SAS Class Sessions\SESSION 9\elemapi";
RUN;


proc reg data=API.CaseStudy1;
  MODEL api00 = ell meals yr_rnd mobility acs_k3 acs_46 full emer enroll ;
run;  


/*Clear Output Window*/
ODS HTML CLOSE;
ODS HTML;

/*Contents of the file*/
PROC CONTENTS DATA=API.CaseStudy1;
RUN;

/*Print first 5 obs*/
PROC PRINT DATA=API.CaseStudy1(obs=5) ;
RUN;
