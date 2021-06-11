* boundaries of official strike zone

local side = 8.5 / 12
local top = 10.98 / 12
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

capture confirm var on1
if !_rc {
	g byte b3on1 = balls == 3 & on1
	g byte s2o2 = strikes == 2 & outs == 2
}

capture confirm var ai
if !_rc {
	by balls strikes, sort: egen mean = mean(ai)
	by balls strikes, sort: egen sd = sd(ai)
	g ai_std = (ai - mean) / sd
	drop mean sd
}
