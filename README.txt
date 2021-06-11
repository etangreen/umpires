Etan Green // August 18, 2018

Guide to replication files for “Bayesian Instinct”. Note that .m files run on Matlab, .do files run on Stata, and .sh files are shell scripts for running Matlab files on a Unix server.

FIRST, run “prelim.m” to estimate the priors and enforced strike zone.

Section 3: Stylized facts
1. Run "table.do" to produce table 2.
2. Run "coefplots.do" to produce the data for Figures 4 and 5.
3. Run “descriptives.m” to generate the figures in Section 3 and in the appendices.

Section 4: Theoretical framework
1. Run “example.m” to generate the plots in 4.2.

Section 5: Accuracy
1. Run “accuracy.m” to generate the plots in 4.3.

Section 6: Model estimates
1. Run “model.m” using “server.sh” to estimate the model under different prior beliefs. Use the argument -t 1-5043 to parallelize the script.
2. Run “structural.m” to generate the plots in Section 6 and the remaining plots in the appendices.