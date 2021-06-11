clear all
//set working directory
import delim using data/calls.csv, varn(1) case(preserve) stringc(6)
global dir = "~/Dropbox/umpires/figures"

do repo/functions/clean.do

eststo m1: areg strike balls#strikes Lstrike, cl(umpid) a(fe)
testparm balls#strikes
estadd scalar Fstat = `r(F)': m1
estadd scalar obs = e(N): m1

eststo m2: areg strike balls#strikes bottomhalf, cl(umpid) a(fe)
testparm balls#strikes
estadd scalar Fstat = `r(F)': m2
estadd scalar obs = e(N): m2

eststo m3: areg strike balls#strikes pahead bahead, cl(umpid) a(fe)
testparm balls#strikes
estadd scalar Fstat = `r(F)': m3
estadd scalar obs = e(N): m3

eststo m4: areg strike balls#strikes b3on1 s2o2, cl(umpid) a(fe)
testparm balls#strikes
estadd scalar Fstat = `r(F)': m4
estadd scalar obs = e(N): m4

label var bottomhalf "Home team batting"
label var Lstrike "Strike on last pitch"
label var b3on1 "3 balls \& runner on 1st"
label var s2o2 "2 strikes \& 2 outs"
label var pahead "Pitching team ahead"
label var bahead "Batting team ahead"

esttab using $dir/table.tex, ///
	b(a2) replace alignment(S) substitute(\_ _) ///
	keep(bottomhalf Lstrike ?ahead b3on1 s2o2) ///
	gaps compress se nostar bookt fragment label nomtitles ///
	nodepvars stats(Fstat obs, layout(@ @ ) fmt(2 0) ///
	labels("$\text{F-test: } \beta_{b,s}$" "Calls"))
