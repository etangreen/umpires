Guide to replication files for *Bayesian Instinct*. 

## First:
1. Create a master directory (e.g., `umpires/`).
2. Clone this repository in the master directory and call it `repo` (i.e., `umpires/repo/`).
3. Download the data directory from XXX into the master directory.
4. Run `prelim.m` to estimate the priors and enforced strike zone.

## Section 3: Stylized facts
1. Run `table.do` to produce table 2.
2. Run `coefplots.do` to produce the data for Figures 4 and 5.
3. Run `descriptives.m` to generate the figures in Section 3 and in the appendices.

## Section 4: Theoretical framework
1. Run `example.m` to generate the plots in 4.2.

## Section 5: Accuracy
1. Run `accuracy.m` to generate the plots in 4.3.

## Section 6: Structural estimates
1. Run `grid.m` using a bash script to estimate the model under different parameters and prior beliefs. Use the argument `-t 1-5043` to parallelize the script.
2. Run `collate.m` to combine the saved grid search estimates.
3. Run `structural.m` to generate the figures in Section 6 and other in the appendices.