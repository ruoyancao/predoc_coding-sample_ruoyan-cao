/* ----------------------------------------
从 SAS Enterprise Guide 导出的代码
DATE: 2026年2月28日     TIME: 10:35:37
PROJECT: Ruoyan Cao_Coding Sample_SAS
PROJECT PATH: D:\SAS\egp\Ruoyan Cao_Coding Sample_SAS.egp
---------------------------------------- */

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide


/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;


/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend _sas_pushchartsize;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend _sas_popchartsize;


ODS PROCTITLE;
OPTIONS DEV=SVG;
GOPTIONS XPIXELS=0 YPIXELS=0;
%macro HTML5AccessibleGraphSupported;
    %if %_SAS_VERCOMP_FV(9,4,4, 0,0,0) >= 0 %then ACCESSIBLE_GRAPH;
%mend;
FILENAME EGHTMLX TEMP;
ODS HTML5(ID=EGHTMLX) FILE=EGHTMLX
    OPTIONS(BITMAP_MODE='INLINE')
    %HTML5AccessibleGraphSupported
    ENCODING='utf-8'
    STYLE=Journal2a
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
;

/*   节点开始: WP 1_ESG-ratings Disagreement,  institutional investor ownership and cash holdings   */
%LET _CLIENTTASKLABEL='WP 1_ESG-ratings Disagreement,  institutional investor ownership and cash holdings';
%LET _CLIENTPROCESSFLOWNAME='过程流';
%LET _CLIENTPROJECTPATH='D:\SAS\egp\Ruoyan Cao_Coding Sample_SAS.egp';
%LET _CLIENTPROJECTPATHHOST='叮叮当当闪亮登';
%LET _CLIENTPROJECTNAME='Ruoyan Cao_Coding Sample_SAS.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

*Working paper 1: The Impact of ESG-ratings Disagreement on Corporate Cash Holdings;

*OBJECTIVE: This script performs data construction and identifies the effect of 
             ESG-ratings disagreement on liquidity management using a 
             Heckman Selection Model to address sample selection bias;
*DATA SOURCES: WRDS (Compustat, CRSP, Thomson Reuters, Sustainalytics, MSCI, Asset4);

*01.Independent Variable: ESG-ratings Disagreement;

*%read_zip: macro syntax for calling data from ZIP archives;
%read_zip(file=gvkey_esg,rename=x,folder=D:\SAS\database\NEW_WRDS\ESG rating);
*ESG rating data from TR Asset4, MSCI IVA, and Sustainalytics;
proc sql;
   create table ESG1 as select distinct
   a.*,
   min(a4_ESG) as min_a4,max(a4_ESG) as max_a4,
   min(IVA_ESG) as min_IVA,max(IVA_ESG) as max_IVA,
   min(sus_ESG) as min_sus,max(sus_ESG) as max_sus
   from x as a
   group by fyear
   order by fyear,gvkey;
quit;
*Normalize ESG rating to be in the range of 0 to 1 to ensure comparability;
data ESG1;
    set ESG1;
    a4_ESG_stand=(a4_ESG-min_a4)/(max_a4-min_a4);
    IVA_ESG_stand=(IVA_ESG-min_IVA)/(max_IVA-min_IVA);
    sus_ESG_stand=(sus_ESG-min_sus)/(max_sus-min_sus);
run;
*ESG-ratings disagreement is measured as the standard deviation of ESG ratings;
proc sql;
   create table ESG as select distinct
   c.*,
   std(a4_ESG_stand,IVA_ESG_stand,sus_ESG_stand) as ESG_div,
   mean(a4_ESG_stand,IVA_ESG_stand,sus_ESG_stand) as ESG_avg
   from  ESG1 as c
   group by fyear
   order by fyear,gvkey;
quit;

*02.Dependent Variable (Corporate Cash Holdings) and Control Variables;

%read_zip(file=compustat_na,folder=D:\SAS\database\NEW_WRDS\compustat\North America);
*Compustat provides the data for corporate cash holdings and most control variables in our sample;
proc sort data=compustat_na(keep=FIC cusip gvkey fyear state sic xad xrd 
ib sale oancf dvt at ebitda leverage CAPEX INTAN cash prcc_f csho ceq
where=(FIC='USA')) out=compustat;by gvkey fyear;
run;
*Constructing key financial metrics following standard corporate finance literature;
data cc_compustat;
   set compustat;by gvkey;
      size=log(at);
	  roa=ebitda/at;
	  lev=leverage;
      intangibles=INTAN/at;
	  ad=coalesce(xad,0);
	  rd=coalesce(xrd,0);
	  exp=sum(ad,rd)/ib;
	  capitalexp=CAPEX;
	  salesgrowth=sale/lag(sale)-1;
	  if first.gvkey then salesgrowth=.;
	  if dif(fyear)^=1 then salesgrowth=.; 
      cashflow=OANCF/at;
	  if ib<0 then loss=1;
	  else loss=0;
	  mtb=sum(prcc_f*csho,at,-ceq)/at;*Market-to-Book ratio (Tobin's Q proxy);
	  dividend=dvt/sale;
      cash=cash;
	  cusip8=substr(cusip,1,8);
      keep gvkey fyear cusip8  state sic
      size roa lev intangibles exp capitalexp intcov salesgrowth cashflow 
      loss mtb dividend cash;
run;
*Systematic risk, measured by equity beta, is retrieved from CRSP;
*Load Momentum Factor and Fama-French Factors;
data mom;
format date yymmddn8. ;
infile "D:\SAS\database\F-F_Momentum_Factor_daily.txt" firstobs=2;
input date1 $8. mom;
date=input(date1,yymmdd32.);
drop date1;
run;
data ff3;
format date yymmddn8. ;
infile "D:\SAS\database\F-F_Research_Data_Factors_daily.txt" firstobs=2;
input date1 $8. rmrf smb hml rf;
date=input(date1,yymmdd32.);
drop date1;
run;
proc sort data=mom;by date;
run;
proc sort data=ff3;by date;
run;
data factor;
   merge ff3 mom;by date;
   if date^=.;
   if year(date)>=1927;
run;
*MACRO: crsp_fmodel
 PURPOSE: Efficiently processes large-scale CRSP daily stock returns to estimate annual 
          firm-level systematic risk (Equity Beta) using the Fama-French 3-Factor and 
          Momentum models via rolling regressions;
%macro crsp_fmodel(sy=1927,ey=2022);
options nonotes;
proc delete data=crsp_fmodel;
run;

%do year=&sy %to &ey;
*Step A: Extract daily stock returns for the specific year;
%read_zip(file=d&year,rename=data,
folder=D:\SAS\database\NEW_WRDS\CRSP\CRSP daily);

*Step B: Align stock returns with risk factors and calculate Excess Returns (Ri - Rf);
proc sql;
   create table reg_data as select
   a.permno,a.date,a.ret*100-b.rf as rirf,b.rmrf,b.smb,b.hml,b.mom
   from data as a,factor as b
   where a.date=b.date
   order by a.permno,a.date;
quit;

*Step C: Run Time-Series Regressions for each firm (PERMNO) 
         The 'outest' option captures the coefficients (Beta) for each model;
proc reg data=reg_data outest=reg_esti noprint adjrsq;
   model rirf=rmrf;
   model rirf=rmrf smb hml;
   model rirf=rmrf smb hml mom;
   by permno;
quit;

*Step D: Data stacking and post-processing of coefficients;
data reg_esti;
   format date yymmddn8.;
   set reg_esti;
   date=mdy(12,31,&year);
   nobs=_p_+_edf_;
   drop _type_ _depvar_ rirf _in_ _edf_ _P_;
run;

proc append base=crsp_fmodel data=reg_esti;
quit;
%end;

proc delete data=data reg_esti;
run;

options notes;
%mend;
%crsp_fmodel(sy=2007,ey=2021);*beta;
proc sql;
   create table cf as select distinct
   a.*,substr(a._model_,6,1) as m 
   from crsp_fmodel as a;
quit;
data cf;
   set cf;
   if m='2' then delete;
   if m='3' then delete;
run;*In this study, we primarily focus on the CAPM Beta (Model 1) to represent systematic risk;

*03.Moderating Variable: Institutional Investor Ownership;

%read_zip(file=ownership,rename=owner,
folder=D:\SAS\database\NEW_WRDS\Thomson Reuters);
*Institutional ownership data are sourced from Thomson Reuters;
data owner;
   set owner;
   per=(INSTOWN/shrout)/1000;
run;
data owner12;
   set owner;
   fyear=year(rdate)-1;
   if month(rdate)=12 then output;
run;

*04.Database Merging and Data Pre-processing;

*Merging Step 1: Combining the dependent variable with all control variables;
%read_zip(file=crsp_compustat,rename=ccm,
folder=D:\SAS\database\NEW_WRDS\Link Table);
*We employ the CRSP/Compustat Merged (CCM) Link Table as the bridge to resolve the 
 mapping identification issue between GVKEY (Compustat) and PERMNO (CRSP);
proc sql;
   create table cash_control as select distinct
   a.gvkey,a.*,b._model_,b.rmrf as beta
   from cc_compustat as a,cf as b,ccm as c
   where a.gvkey=c.gvkey and b.permno=c.permno and 
   a.fyear=year(b.date)=year(c.date)
   order by gvkey,fyear;
quit;
*Merging Step 2: Incorporating the independent variable into the dataset;
proc sql;
   create table xyc as select distinct
   b.gvkey,b.*,a.ESG_div,a.ESG_avg
   from ESG as a,cash_control as b
   where a.gvkey=b.gvkey and a.fyear=b.fyear
   order by fyear,gvkey;
quit;
*Merging Step 3: Incorporating the moderating variable into the dataset;
proc sort data=owner12(keep=cusip fyear INSTOWN_PERC) 
out=IO;by cusip ;
run;
data IO;
   set IO;
   cusip8=cusip;
run;
proc sort data=xyc;by cusip8 fyear;
run;
proc sort data=IO;by cusip8 fyear;
run;
data final1;
   merge xyc IO;by cusip8 fyear;
run;

*Cleaning 1: Imputing zero for missing institutional ownership;
data final2;
  set final1;
  INSTOWN_PERC=coalesce(INSTOWN_PERC,0);
run;
*Cleaning 2: Dropping unrealistic data: IO > 1, Leverage > 1, and EXP < -1;
data final3;
   set final2;
   if INSTOWN_PERC>1 then delete;
run;
data final4;
  set final3;
  if lev>1 then delete;
  if exp<-1 then delete;
run;
*Cleaning 3: Dropping observations with missing values for other variables;
data final5;
   set final4;
      if nmiss(ESG_div,ESG_avg,cash,INSTOWN_PERC,size,beta,roa, 
       lev,intangibles,exp,capitalexp,salesgrowth,cashflow,
       loss,mtb,dividend)=0 then output;
run;
*Cleaing 4: Winsorizing all continuous variables at the 1st and 99th percentiles;
%winsor(file=final5,firm=gvkey,time=fyear,var=ESG_div ESG_avg cash INSTOWN_PERC size roa 
       lev intangibles exp capitalexp salesgrowth cashflow mtb beta dividend);
*Cleaing 5: Excluding financial and utility firms (SIC code);
data sample;
   set final5;
   if substr(sic,1,1)='6' then delete;
   if substr(sic,1,2)='49' then delete;
   by fyear gvkey;
run;

*Final Step: Sample export;
*Our sample consists of 5,390 firm-year observations from 2009 to 2019;
%copydata(file=sample,
folder=D:\SAS\my research\ESG rating and cash holding);

*05.Empirical Analysis;

*Our empirical analysis encompasses descriptive statistics, correlation analysis, 
OLS regressions, heterogeneity analysis, and endogeneity tests;
*Here, I present the endogeneity test to address potential sample selection bias, 
as ESG rating disagreement is not available for all firms;

*0501.The First Stage: Selection Equation;

*The objective is to predict the probability of a firm being included in the sample
(i.e., having ESG rating disagreement data available);

*We first adjust the sample by including observations with missing ESG-ratings disagreement;
*Here,the sample reconstruction process is omitted for brevity;

*Defined a selection dummy: 1 if ESG disagreement data exists and 0 otherwise;
data imr2;
   set imr1;
   if ESG_div^=. then ESG_div1=1;
   if ESG_div=. then ESG_div1=0;
run;

*The reconstructed sample is named sample_imr;
%read_zip(file=sample_imr,
folder=D:\SAS\my research\ESG rating and cash holding);

*First-stage estimation via a Probit model;
proc logistic data=sample_imr noprint;
   class sic fyear;
   model ESG_div1=size beta roa lev intangibles 
       exp capitalexp salesgrowth cashflow loss mtb dividend;
   output out=sample_imr1 p=lambda;*Inverse Mills Ratio, IMR;
quit;

*0502.The Second Stage: Outcome Equation;

*The objective is to examine the impact of ESG rating disagreement on 
corporate cash holdings after correcting for self-selection bias;

*Sample Selection: We restrict the second-stage regression to the subsample 
where the indicator ESG_div1 equals one;
data sample_imr1(where=(lambda^=.));
   set sample_imr1;
   if ESG_div1=1;
run;

*Incorporating the Correction Term): The Inverse Mills Ratio (lambda), derived from 
the first-stage selection equation, is included as an additional control variable 
in the main regression to adjust for selection bias;
%lead_lag(file=sample_imr1,firm=gvkey,time=fyear,lag=1,var=cash);
%let y=cash;
%let x=ESG_div ESG_div*INSTOWN_PERC;
%let m=;
%let c=ESG_avg lambda size beta roa lev intangibles exp capitalexp salesgrowth 
       cashflow loss mtb dividend;
%let fixeffect=fyear sic;
%let cluster=;
%let weight=1;
%let doboot=0; %let boot=100;
%let fm=0;%let lag=0;
%reg(sample_imr1,,3,1);
%let x=;
%reg(sample_imr1,,3,2);
%let x=ESG_div;
%reg(sample_imr1,,3,3);
%let x=ESG_div ESG_div*INSTOWN_PERC;
%reg(sample_imr1,,3,4);
%reg_file(,4);
data table5_2;
   set _last_;
run;

%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;


/*   节点开始: WP 2_Strategic peer effects, knowledge capital and investment efficiency   */
%LET _CLIENTTASKLABEL='WP 2_Strategic peer effects, knowledge capital and investment efficiency';
%LET _CLIENTPROCESSFLOWNAME='过程流';
%LET _CLIENTPROJECTPATH='D:\SAS\egp\Ruoyan Cao_Coding Sample_SAS.egp';
%LET _CLIENTPROJECTPATHHOST='叮叮当当闪亮登';
%LET _CLIENTPROJECTNAME='Ruoyan Cao_Coding Sample_SAS.egp';
%LET _SASPROGRAMFILE='';
%LET _SASPROGRAMFILEHOST='';

*Working Paper 2: Be Armed with Knowledge Capital: the Coopetition Peer Effect in 
Corporate Investment Efficiency

*OBJECTIVE: This script investigates how firms' investment efficiency is influenced by 
            their peers (Strategic Peer Effects) using Chinese CSMAR database;
*METHODOLOGY: To address simultaneity bias and correlated shocks, a 2SLS (Two-Stage Least Squares) 
              instrumental variable approach is implemented, using peer advertising expenses as instruments;

*ECONOMIC RATIONALE FOR INSTRUMENTAL VARIABLE (IV) SELECTION:
   We utilize Peer Advertising Expenses as an instrument for Peer Investment for two reasons:
   
   1. RELEVANCE (First Stage): Peer advertising is a strategic expenditure that 
      highly correlates with their own investment decisions and market positioning.
      
   2. EXCLUSIVITY/VALIDITY (Exclusion Restriction): A peer firm's advertising 
      spending is likely to affect the focal firm's investment efficiency ONLY 
      through its impact on the peer's own investment behavior, rather than 
      directly affecting the focal firm's internal production technology or 
      correlated industry-wide shocks;

*01. Initial Data Loading;
%frm_control;*Loading standard control variables for Chinese listed firms;
%read_zip(file=final_biddle_kk,
folder=D:\SAS\my research\Peer effect and investment efficiency);

*02. Constructing Instrumental Variables: Peer Advertising;
proc sort data=frm_control(keep=stkcd date ad) out=ad;by stkcd date;
run;
data ad;
  set ad;
  if ad=. then ad=0;
run;
%frm_csm;*Competitive Strategy Measure (CSM), originally developed by Sundaram et al. (1996);
proc sql;
   *A. Calculate Peer Advertising for Strategic Complementary Peers;
   create table com_ad as select distinct
   a.stkcd1 as stkcd,a.date,a.stkcd2,
   mean(b.ad) as com_ad
   from csm4(where=(csm>0)) as a,ad as b
   where a.stkcd2=b.stkcd and a.date=b.date
   group by a.stkcd1,a.date;
   *B. Calculate Peer Advertising for Strategic Substitute Peers;
   create table sub_ad as select distinct
   a.stkcd1 as stkcd,a.date,a.stkcd2,
   mean(b.ad) as sub_ad
   from csm4(where=(csm<0)) as a,ad as b
   where a.stkcd2=b.stkcd and a.date=b.date
   group by a.stkcd1,a.date;
quit;
data peer_ad;
   merge com_ad sub_ad;by stkcd date;
run;
data peer_ad;
  set peer_ad;
  if com_ad=. then delete;
  if sub_ad=. then delete;
run;
proc sql;
   create table iv_ad as select distinct
   a.*,b.com_ad,b.sub_ad
   from final_biddle_kk as a,peer_ad as b
   where a.stkcd=b.stkcd and a.date=b.date;
quit;

*03. Two-Stage Least Squre (2SLS) Estimation;

*STAGE 1: Regression of Peer Investment on Peer Advertising (IVs);
*We obtain the fitted values (p_com, p_sub) to isolate the exogenous variation 
 in peer investment behavior;

%reg_pres(file=iv_ad,y=com_ie,
     x=com_ad size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana,by=,
     fix=date gics,pre=p_com,res=r_com);
%reg_pres(file=iv_ad,y=sub_ie,
     x=sub_ad size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana,by=,
     fix=date gics,pre=p_sub,res=r_sub);

*Exporting First-Stage statistics for diagnostic checks;
     %let y=com_ie;
     %let x=com_ad sub_ad;
     %let m=;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %let weight=1;
     %let fixeffect=date gics;
     %let doboot=0;
     %let boot=0;
     %let fm=0;
     %let lag=0;
     %reg(iv_ad,,3,1);

	 %let y=com_ie;
     %let x=com_ad;
     %reg(iv_ad,,3,2);
	 %let y=sub_ie;
     %let x=sub_ad;
     %reg(iv_ad,,3,3);
     %reg_file(,3);
     data firststage_ad;
        set _last_;
     run;


*STAGE 2: Impact of Predicted Peer Investment on Firm Investment Efficiency;
*The objective is to estimate the causal impact using predicted values (p_com, p_sub);

*Model 8.1: Basic 2SLS results;
     %let y=ie;
     %let x=p_com p_sub;
     %let m=;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %let weight=1;
     %let fixeffect=gics date;
     %let doboot=0;
     %let boot=0;
     %let fm=0;
     %let lag=0;
     %reg(iv_ad,,3,1);
     %let x=;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %reg(iv_ad,,3,2);
     %let x=p_com;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %reg(iv_ad,,3,3);
     %let x=p_sub;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %reg(iv_ad,,3,4);
     %let x=p_com p_sub;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %reg(iv_ad,,3,5);
     %reg_file(,5);
data table8_1_ad;
   set _last_;
run;

*Model 8.2: 2SLS results with moderating variable (knowledge capital);
     %let y=ie;
     %let x=p_com p_sub kk p_com*kk p_sub*kk;
     %let m=;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %let weight=1;
     %let fixeffect=gics date;
     %let doboot=0;
     %let boot=0;
     %let fm=0;
     %let lag=0;
     %reg(iv_ad,,3,1);
     %let x=p_com kk p_com*kk;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %reg(iv_ad,,3,2);
     %let x=p_sub kk p_sub*kk;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %reg(iv_ad,,3,3);
     %let x=p_com p_sub kk p_com*kk p_sub*kk;
     %let c=size s_cash ln_age asset_tang Q f_cons loss cash_at
            blev ind_board manager_hold soe ana;
     %reg(iv_ad,,3,4);
     %reg_file(,4);
data table8_2_ad;
   set _last_;
run;

%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
