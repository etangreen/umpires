clear all
//set working directory
set more off
global dir = "data/coef"

* count coefficients

import delim using data/calls.csv, ///
	varn(1) case(preserve) stringc(6) clear

do repo/functions/clean.do

areg strike balls#strikes, cl(umpid) a(fe)
testparm balls#strikes
lincom _b[3.balls#0.strikes] - _b[0.balls#2.strikes]
mat A = e(b)' , vecdiag(e(V))'

clear
svmat A
replace A2 = A2 + A2[_N]
drop if _n == _N
egen balls = seq(), f(0) t(3) b(3)
egen strikes = seq(), f(0) t(2) b(1)

rename (A1 A2) (bstrike vstrike)
g text = string(balls) + "-" + string(strikes)
drop balls strikes
export delim using $dir/counts.csv, replace

* by experience

import delim using data/calls.csv, ///
	varn(1) case(preserve) stringc(6) clear

do repo/functions/clean.do

g byte exp = 1 if firstyr < 1999
replace exp = 2 if firstyr == 1999
replace exp = 3 if firstyr > 1999

areg strike balls#strikes if exp == 1, cl(umpid) a(fe)
mat A = e(b)' , vecdiag(e(V))'
areg strike balls#strikes if exp == 2, cl(umpid) a(fe)
mat A = A , e(b)' , vecdiag(e(V))'
areg strike balls#strikes if exp == 3, cl(umpid) a(fe)
mat A = A , e(b)' , vecdiag(e(V))'

clear
svmat A
drop if _n == _N
rename (A1 A2 A3 A4 A5 A6) (b1 v1 b2 v2 b3 v3)
export delim using $dir/experience.csv, replace

* by umpire

import delim using data/calls.csv, ///
	varn(1) case(preserve) stringc(6) clear

by umpid, sort: egen int calls = sum(1)

do repo/functions/clean.do

levelsof umpid if calls >= 10000, l(umps)
foreach u of local umps {
	areg strike balls#strikes if umpid == `u', a(fe)
	capture confirm mat B
	if _rc {
		mat B = e(b)'
	}
	else {
		mat B = B , e(b)'
	}
}

clear
svmat B
drop if _n == _N
export delim using $dir/byUmp.csv, replace

* asymmetric impact coefficients

import delim using data/calls.csv, ///
	varn(1) case(preserve) stringc(6) clear

do repo/functions/clean.do

areg strike balls#strikes balls#strikes#c.ai_std, cl(umpid) a(fe)
mat A = e(b)' , vecdiag(e(V))'

clear
svmat A
drop if _n == _N
rename (A1 A2) (b v)

g byte temp = _n > 12
egen temp2 = seq(), f(1) t(12)
reshape wide b v, i(temp2) j(temp)
drop temp2
export delim using $dir/impact.csv, replace

* non four-seam fastballs

import delim using data/breaking.csv, varn(1) case(preserve) clear

do repo/functions/clean.do

areg strike balls#strikes, cl(umpid) a(fe)
mat A = e(b)' , vecdiag(e(V))'

clear
svmat A
replace A2 = A2 + A2[_N]
drop if _n == _N
egen balls = seq(), f(0) t(3) b(3)
egen strikes = seq(), f(0) t(2) b(1)

rename (A1 A2) (b v)
g text = string(balls) + "-" + string(strikes)
drop balls strikes
export delim using $dir/breaking.csv, replace
