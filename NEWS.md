0.1.6:

- Remove `wildcard` function in Makevars so that GNU make is no longer a `SystemRequirements`
- `plot.bamdata` and `plot.bamval` have been moved from `plot` to a new generic, `bam_plot`. 
- Documentation has been updated based on notes in `R CMD check`. 
- NSE-referenced objects now use `rlang::.data` to avoid check complaints. 

0.1.3: 

- Support missing data in observations
- Switched to new package skeleton (from rstanarm -> rstantools)
- Combined stan models into a single model, drastically reducing memory overhead when compiling.
- Improvements to default priors based on HydroSWOT, literature
- Now reference A0 at median, rather than minimum
- Minor bug fixes

