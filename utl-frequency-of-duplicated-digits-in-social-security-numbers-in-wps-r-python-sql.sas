%let pgm=utl-frequency-of-duplicated-digits-in-social-security-numbers-in-wps-r-python-sql;

 The SSN, '003-32-7807' has 7 duplicates 003377

 Another way to view the problem is to remove digits that only occur once.

  SOLUTIONS

        1 wps sql
        2 wps r sql
        3 wps python sql

 These are sql solutions. proc sort nouniquekey by rec on long structure will provide output with only the dups.

 github
 https://tinyurl.com/2y5tkn6r
 https://github.com/rogerjdeangelis/utl-frequency-of-duplicated-digits-in-social-security-numbers-in-wps-r-python-sql

 SOAPBOX ON

   I realize sqllite3 in R and especially in python is very slow.
   R tends to be an in-memory language so optimum performance may be less than an issue.
   Adding sqllite3 to your tools should be useful?
   Loops in R are also slow. Python is faster.
   Python may eventaully be a good platform for big data?
   Perhaps SAS/WPS mutiple tasking, teradata and exedata handle big data better?
   Also for clinical trials, sqllite3 may be useful, because of amaller datasets?

   However, R and Python packages, some written in C, do not have the issues above?

SOAPBOX OFF


/**************************************************************************************************************************/
/*                                    |                        |                                                          */
/*   SOCIAL SECURITYDIGITS            |   RULES EXAMPLES       |     OUTPUT                                               */
/*                                    |                        |                                                          */
/*                                    |                        |     DUP   NUM                                            */
/*   REC  D1 D2 D3 D4 D5 D6 D7 D8 D9  |  SSN COUNT DUPS        |     COUNT RECS                                           */
/*                                    |  OTHER DIGITS NO DUP   |                                                          */
/*                                    |                        |                                                          */
/*     1   2  0  3  0  2  0  0  1  4  |        11 Count=2      |         2   12 Records with just 2 dups '00','11','99'   */
/*     2   1  0  4  0  9  9  7  4  3  |                        |         3    6 Records with just 3 dups '000','111'      */
/*     3   3  5  2  3  2  4  1  7  0  |                        |         4   22 Records could have '0000' '0011' ..       */
/*     4   5  9  2  7  1  1  5  6  7  |                        |         5   19 Records could have '00000', '00111' ..    */
/*     5   5  9  5  4  4  9  7  3  1  |    444499 Count=6      |         6   22 Records could have '333333', '443355' ..  */
/*     6   8  1  3  9  5  3  6  5  6  |   1122000 Count=7      |         7    8 Records could have '3332244', '8888899'   */
/*     7   6  2  3  2  7  9  6  7  0  |                        |         8    9 Records could have '33557722'             */
/*     8   7  3  3  5  7  4  1  8  7  |                        |         9    1 Records could have '444991188'            */
/*     9   1  5  3  9  2  5  3  3  2  |                        |         0    1 No Dups '012345678' or '23456789'         */
/*    10   3  5  9  1  8  0  0  7  9  |                        |        SUM 100                                           */
/*    ...                             |                        |                                                          */
/*   100                              |                        |                                                          */
/*                                    |                        |                                                          */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

options validvarname=upcase;

libname sd1 'd:/sd1';

data sd1.have;
  retain rec .;
  array vs d1-d9;

  do rec=1 to 100;
    do over vs;
       vs = int(10*uniform(1234));
    end;
    output;
  end;

stop;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* SD1.HAVE total obs=100                                                                                                 */
/*                                                                                                                        */
/*  REC  D1 D2 D3 D4 D5 D6 D7 D8 D9                                                                                       */
/*                                                                                                                        */
/*    1   2  0  3  0  2  0  0  1  4                                                                                       */
/*    2   1  0  4  0  9  9  7  4  3                                                                                       */
/*    3   3  5  2  3  2  4  1  7  0                                                                                       */
/*    4   5  9  2  7  1  1  5  6  7                                                                                       */
/*    5   5  9  5  4  4  9  7  3  1                                                                                       */
/*    6   8  1  3  9  5  3  6  5  6                                                                                       */
/*    7   6  2  3  2  7  9  6  7  0                                                                                       */
/*    8   7  3  3  5  7  4  1  8  7                                                                                       */
/*    9   1  5  3  9  2  5  3  3  2                                                                                       */
/*   10   3  5  9  1  8  0  0  7  9                                                                                       */
/*  ...                                                                                                                   */
/*  100                                                                                                                   */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                                  _
/ | __      ___ __  ___   ___  __ _| |
| | \ \ /\ / / `_ \/ __| / __|/ _` | |
| |  \ V  V /| |_) \__ \ \__ \ (_| | |
|_|   \_/\_/ | .__/|___/ |___/\__, |_|
             |_|                 |_|
*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%array(_vr,values=%utl_varlist(sd1.have,keep=d:));

/*----                                                                   ----*/
/*----  Sample values from macro array                                   ----*/
/*----                                                                   ----*/

%put &=_vr6;
%put &=_vrn;


proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

%utl_submit_wps64x(resolve('

options validvarname=any;
libname sd1 "d:/sd1";

/*----                                                                   ----*/
/*----  Pivot wide to long                                               ----*/
/*----  Transpose Row d1-d9 (you can nest the transpose in 1 query       ----*/
/*----                                                                   ----*/

proc sql;
  create
     table havXpo as
  %do_over(_vr,phrase=%str(
      select rec ,? as digit from sd1.have),between=union all)
  order
      by rec, digit
;quit;

proc sql;
  create
     table sd1.want as
  select
     dupSum
    ,count(dupSum) as dupCnt
  from (
     select
        rec
       ,sum(dupPerRec) as dupSum
     from (
        select
           rec
          ,count(*) as dupPerRec
        from
           havXpo
        group
           by rec, digit
        having
           count(digit) > 1 )
     group
        by rec )
  group
     by dupSum
;quit;

'));

proc print data=sd1.want;
run;quit;

/*___                                          _
|___ \  __      ___ __  ___   _ __   ___  __ _| |
  __) | \ \ /\ / / `_ \/ __| | `__| / __|/ _` | |
 / __/   \ V  V /| |_) \__ \ | |    \__ \ (_| | |
|_____|   \_/\_/ | .__/|___/ |_|    |___/\__, |_|
                 |_|                        |_|
*/

proc datasets lib=sd1 nolist nodetails;delete want; run;quit;

options validvarname=any;
libname sd1 "d:/sd1";

%utl_submit_wps64x("
libname sd1 'd:/sd1';

proc r;
export data=sd1.have r=have;
submit;

library(sqldf);

havXpo<-sqldf('
  %do_over(_vr,phrase=%str(
      select rec ,? as digit from have),between=union all)
  order
      by rec, digit
');

want<-sqldf('
  select
     dupSum
    ,count(dupSum) as dupCnt
  from (
     select
        rec
       ,sum(dupPerRec) as dupSum
     from (
        select
           rec
          ,count(*) as dupPerRec
        from
           havXpo
        group
           by rec, digit
        having
           count(digit) > 1 )
     group
        by rec )
  group
     by dupSum
');
want;
endsubmit;

import data=sd1.want r=want;
run;quit;

");

proc print data=sd1.want width=min;
run;quit;

/*____                                    _   _                             _
|___ /  __      ___ __  ___   _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
  |_ \  \ \ /\ / / `_ \/ __| | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
 ___) |  \ V  V /| |_) \__ \ | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
|____/    \_/\_/ | .__/|___/ | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
                 |_|         |_|    |___/                                |_|
*/

%utl_submit_wps64x("
options validvarname=any lrecl=32756;
libname sd1 'd:/sd1';
proc sql;select max(cnt) into :_cnt from (select count(nam) as cnt from sd1.have group by nam);quit;
%array(_unq,values=1-&_cnt);
proc python;
export data=sd1.have python=have;
submit;
from os import path;
import pandas as pd;
import numpy as np;
import pandas as pd;
from pandasql import sqldf;
mysql = lambda q: sqldf(q, globals());
from pandasql import PandaSQL;
pdsql = PandaSQL(persist=True);
sqlite3conn = next(pdsql.conn.gen).connection.connection;
sqlite3conn.enable_load_extension(True);
sqlite3conn.load_extension('c:/temp/libsqlitefunctions.dll');
mysql = lambda q: sqldf(q, globals());

havXpo=pdsql('''
  %do_over(_vr,phrase=%str(
      select rec ,? as digit from have),between=union all)
  order
      by rec, digit
''');

want=pdsql('''
  select
     dupSum
    ,count(dupSum) as dupCnt
  from (
     select
        rec
       ,sum(dupPerRec) as dupSum
     from (
        select
           rec
          ,count(*) as dupPerRec
        from
           havXpo
        group
           by rec, digit
        having
           count(digit) > 1 )
     group
        by rec )
  group
     by dupSum
''');
print(want);
endsubmit;
import data=sd1.want r=want;
run;quit;
"));

proc print data=sd1.want width=min;
run;quit;

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
