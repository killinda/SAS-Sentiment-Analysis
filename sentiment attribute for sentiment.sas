 PROC IMPORT OUT= WORK.dev 
            DATAFILE= "C:\Users\macair\Desktop\knowledge technology\Assi
gnment 2\dev.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES; 
     DATAROW=2; 
RUN;
PROC IMPORT OUT= WORK.nega 
            DATAFILE= "C:\Users\macair\Desktop\knowledge technology\Assi
gnment 2\negative words.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
PROC IMPORT OUT= WORK.posi 
            DATAFILE= "C:\Users\macair\Desktop\knowledge technology\Assi
gnment 2\positive words.txt" 
            DBMS=TAB REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
/*procee the data*/
data dev (rename=(Var2=status Var3=com));
set dev;
run;
data dev;
set dev;
low=lowcase(com);
run;
/*do the sentiment analysis*/
/*positive*/
data a;
set posi;
n=_N_;
if n=1;
run;
proc sql;
create table b as 
select * from a inner join dev
on a.n=1;
quit;
data b;
set b;
value1=count(low,' '||trimn(positive)||' ');
drop positive n status com low;
run;
data final;
set b;
value=0;
run;

%macro positive;
%do i =2 %to 2006; 
data a;
set posi;
n=_N_;
if n=&i;
run;
proc sql;
create table b as 
select * from a inner join dev
on a.n=&i;
quit;
data b;
set b;
value&i=count(low,' '||trimn(positive)||' ');
drop positive n status com low;
run;
data final;
merge final b;
by id;
run;
%end;
%mend;
%positive

%macro final;
%do i=1 %to 2006;
data final;
set final;
value=value+value&i;
drop value&i;
run;
%end;
%mend;
%final;

/*negative*/
data a;
set nega;
n=_N_;
if n=1;
run;
proc sql;
create table b as 
select * from a inner join dev
on a.n=1;
quit;
data b;
set b;
value1=count(low,' '||trimn(negative)||' ');
drop negative n status com low;
run;
data final1;
set b;
value=0;
run;

%macro negative;
%do i =2 %to 4783; 
data a;
set nega;
n=_N_;
if n=&i;
run;
proc sql;
create table b as 
select * from a inner join dev
on a.n=&i;
quit;
data b;
set b;
value&i=count(low,' '||trimn(negative)||' ');
drop negative n status com low;
run;
data final1;
merge final1 b;
by id;
run;
%end;
%mend;
%negative

%macro final1;
%do i=1 %to 4783;
data final1;
set final1;
value=value+value&i;
drop value&i;
run;
%end;
%mend;
%final1;

data final1;
set final1;
rename value=value1; 
run;

/*calculate the sentiment*/
proc sql;
create table sentiment as 
select final.id,final.value,final1.value1 from final left join final1
on final.id=final1.id;
quit;
data sentiment;
set sentiment;
total=value-value1;
if total>0 then sentiment='P';
if total=0 then sentiment='M';
if total<0 then sentiment='N';
run;
