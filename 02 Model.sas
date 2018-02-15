%macro var2(y,x);
proc logistic data=temp3 desc;
model &y = &x;
run;
%mend;

/*tracker info*/
%var2(sitting,x1); %var2(sitting,x2); %var2(sitting,x3); %var2(sitting,x4); 
%var2(sitting,y1); %var2(sitting,y2); %var2(sitting,y3); %var2(sitting,y4);
%var2(sitting,z1); %var2(sitting,z2); %var2(sitting,z3); %var2(sitting,z4); 
%var2(sitting,x12); %var2(sitting,x13); %var2(sitting,x14); 
%var2(sitting,x23); %var2(sitting,x24); %var2(sitting,x34);
%var2(sitting,y12); %var2(sitting,y13); %var2(sitting,y14); 
%var2(sitting,y23); %var2(sitting,y24); %var2(sitting,y34); 
%var2(sitting,z12); %var2(sitting,z13); %var2(sitting,z14);
%var2(sitting,z23); %var2(sitting,z24); %var2(sitting,z34);
%var2(sitting,d12); %var2(sitting,d13); %var2(sitting,d14);
%var2(sitting,d23); %var2(sitting,d24); %var2(sitting,d34);

%var2(standing,x1); %var2(standing,x2); %var2(standing,x3); %var2(standing,x4); 
%var2(standing,y1); %var2(standing,y2); %var2(standing,y3); %var2(standing,y4);
%var2(standing,z1); %var2(standing,z2); %var2(standing,z3); %var2(standing,z4); 
%var2(standing,x12); %var2(standing,x13); %var2(standing,x14); 
%var2(standing,x23); %var2(standing,x24); %var2(standing,x34);
%var2(standing,y12); %var2(standing,y13); %var2(standing,y14); 
%var2(standing,y23); %var2(standing,y24); %var2(standing,y34); 
%var2(standing,z12); %var2(standing,z13); %var2(standing,z14);
%var2(standing,z23); %var2(standing,z24); %var2(standing,z34);
%var2(standing,d12); %var2(standing,d13); %var2(standing,d14);
%var2(standing,d23); %var2(standing,d24); %var2(standing,d34);

%var2(walking,x1); %var2(walking,x2); %var2(walking,x3); %var2(walking,x4); 
%var2(walking,y1); %var2(walking,y2); %var2(walking,y3); %var2(walking,y4);
%var2(walking,z1); %var2(walking,z2); %var2(walking,z3); %var2(walking,z4); 
%var2(walking,x12); %var2(walking,x13); %var2(walking,x14); 
%var2(walking,x23); %var2(walking,x24); %var2(walking,x34);
%var2(walking,y12); %var2(walking,y13); %var2(walking,y14); 
%var2(walking,y23); %var2(walking,y24); %var2(walking,y34); 
%var2(walking,z12); %var2(walking,z13); %var2(walking,z14);
%var2(walking,z23); %var2(walking,z24); %var2(walking,z34);
%var2(walking,d12); %var2(walking,d13); %var2(walking,d14);
%var2(walking,d23); %var2(walking,d24); %var2(walking,d34);

/*additional info*/
proc corr data=temp3 out=correl;
var y1 y13 d14 z2 x4 d13 y4 z23 x14 z24 x34 z14 d12 z13 y34 d34 y3 z1;
run;
proc logistic data=temp3 desc;
model sitting = y1	z2	x4	y4	y3;
output out=sitting (keep = class p_sitting) pred=p_sitting;
run;
proc sql;
create table c_sitting as 
select  class, avg(p_sitting) as p_sitting
from sitting
group by class;
quit;

proc corr data=temp3 out=correl;
var y23 x24 y2 d24 y13 y1 d14 x2 x12 d13 d23 x23 x4 y12 x14 z14 y24 x34;
run;
proc logistic data=temp3 desc;
model standing = y23	d14	d13	x4	z14;
output out=standing (keep = class p_standing) pred=p_standing;
run;
proc sql;
create table c_standing as 
select  class, avg(p_standing) as p_standing
from standing
group by class;
quit;

proc corr data=temp3 out=correl;
var z2 x12 d23 d24 x2 z23 y12 y3 y23 d12 z24 x24 x23 y1 y24 y2 z12 y4;
run;
proc logistic data=temp3 desc;
model walking = z2	y3	d12	y1	y4;
output out=walking (keep = class p_walking) pred=p_walking;
run;
proc sql;
create table c_walking as 
select  class, avg(p_walking) as p_walking
from walking
group by class;
quit;

/*multinomial model*/
data class; set temp3 (keep=class); row_num = _n_; run;
data sitting; set sitting; row_num = _n_; run;
data standing; set standing; row_num = _n_; run;
data walking; set walking; row_num = _n_; run;

proc sql;
create table temp4 as 
select a.*, b.* , d.*, f.*
from class as a 
left join sitting as b on a.row_num = b.row_num
left join standing as d on a.row_num = d.row_num
left join walking as f on a.row_num = f.row_num;
quit;

data temp5 (drop = p_sitting p_standing p_walking p_sum p_max );
format p_class $20.;
set temp4;
p_sum = sum(p_sitting,p_standing,p_walking);
sitting = p_sitting/p_sum;
standing = p_standing/p_sum;
walking = p_walking/p_sum;

p_max = max(sitting,standing,walking);
if p_max = sitting then p_class = 'sitting';
else if p_max = standing then p_class = 'standing';
else if p_max = walking then p_class = 'walking';

if class = 'sittingdown' then class = 'sitting';
if class = 'standingup' then class = 'standing';
run;

proc sql;
select class, p_class, count(row_num) as cnt
from temp5
group by class, p_class;
run;