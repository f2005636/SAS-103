/*dataset-har-PUC-Rio-ugulino*/
proc freq data=rg.dataset; tables class; run;

%macro var1(var);
proc sql;
select &var., class, count(class) as cnt
from rg.dataset
group by &var., class;
quit;
%mend;
%var1(gender);
%var1(age);
%var1(how_tall_in_meters);
%var1(weight);
%var1(body_mass_index);

data temp1;
set rg.dataset (drop = gender age how_tall_in_meters weight body_mass_index);
if class in ('sitting','sittingdown') then sitting = 1; else sitting = 0;
if class in ('standing','standingup') then standing = 1; else standing = 0;
if class in ('walking') then walking = 1; else walking = 0;
run;

proc sql;
create table temp2 as 
select user_id, class, sitting, standing, walking,
x1, x2, x3, x4, y1, y2, y3, y4, z1, z2, z3, z4, 
max(x1) as max_x1, max(x2) as max_x2, max(x3) as max_x3, max(x4) as max_x4, 
max(y1) as max_y1, max(y2) as max_y2, max(y3) as max_y3, max(y4) as max_y4, 
max(z1) as max_z1, max(z2) as max_z2, max(z3) as max_z3, max(z4) as max_z4, 
min(x1) as min_x1, min(x2) as min_x2, min(x3) as min_x3, min(x4) as min_x4, 
min(y1) as min_y1, min(y2) as min_y2, min(y3) as min_y3, min(y4) as min_y4, 
min(z1) as min_z1, min(z2) as min_z2, min(z3) as min_z3, min(z4) as min_z4
from temp1
group by user_id;
quit;

data temp3 (drop = max_x1 max_x2 max_x3 max_x4 max_y1 max_y2 max_y3 max_y4 max_z1 max_z2 max_z3 max_z4  
min_x1 min_x2 min_x3 min_x4 min_y1 min_y2 min_y3 min_y4 min_z1 min_z2 min_z3 min_z4 user_id);
set temp2;
x1 = (x1 - min_x1) / (max_x1 - min_x1);
x2 = (x2 - min_x2) / (max_x2 - min_x2);
x3 = (x3 - min_x3) / (max_x3 - min_x3);
x4 = (x4 - min_x4) / (max_x4 - min_x4);
y1 = (y1 - min_y1) / (max_y1 - min_y1);
y2 = (y2 - min_y2) / (max_y2 - min_y2);
y3 = (y3 - min_y3) / (max_y3 - min_y3);
y4 = (y4 - min_y4) / (max_y4 - min_y4);
z1 = (z1 - min_z1) / (max_z1 - min_z1);
z2 = (z2 - min_z2) / (max_z2 - min_z2);
z3 = (z3 - min_z3) / (max_z3 - min_z3);
z4 = (z4 - min_z4) / (max_z4 - min_z4);
x12 = x1 - x2; x13 = x1 - x3; x14 = x1 - x4;  x23 = x2 - x3; x24 = x2 - x4; x34 = x3 - x4;
y12 = y1 - y2; y13 = y1 - y3; y14 = y1 - y4;  y23 = y2 - y3; y24 = y2 - y4; y34 = y3 - y4;
z12 = z1 - z2; z13 = z1 - z3; z14 = z1 - z4;  z23 = z2 - z3; z24 = z2 - z4; z34 = z3 - z4;
d12 = sqrt((x1-x2)**2 + (y1-y2)**2 + (z1-z2)**2);
d13 = sqrt((x1-x3)**2 + (y1-y3)**2 + (z1-z3)**2);
d14 = sqrt((x1-x4)**2 + (y1-y4)**2 + (z1-z4)**2);
d23 = sqrt((x2-x3)**2 + (y2-y3)**2 + (z2-z3)**2);
d24 = sqrt((x2-x4)**2 + (y2-y4)**2 + (z2-z4)**2);
d34 = sqrt((x3-x4)**2 + (y3-y4)**2 + (z3-z4)**2);
run;

proc corr data=temp3 out=correl;
var sitting standing walking x1 x2 x3 x4 y1 y2 y3 y4 z1 z2 z3 z4
x12 x13 x14 x23 x24 x34 y12 y13 y14 y23 y24 y34  z12 z13 z14 z23 z24 z34 
d12 d13 d14 d23 d24 d34;
run;
