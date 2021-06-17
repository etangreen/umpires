* boundaries of official strike zone

local side = 8.5
local top = 10.98
local e = 3

keep if (abs(abs(px) - `side') <= `e' ///
		& abs(pz_std) <= `top' + `e') | ///
	(abs(abs(pz_std) - `top') <= `e' ///
		& abs(px) <= `side' + `e')

* create variables

g byte x = round(px)
g byte z = round(pz_std)
egen int fe = group(batsR x z)
drop x z batsR px pz_std

capture confirm var balls
if _rc {
	g byte balls = real(substr(count,1,1))
	g byte strikes = real(substr(count,2,1))
	drop count
}
