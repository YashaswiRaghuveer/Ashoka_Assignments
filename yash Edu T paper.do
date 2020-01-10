cd "C:\Users\Amarendra\Desktop\Yashaswi Education Term Paper"
use "constructedPanel.dta", clear
log using "educationTermPaper.log", replace

xtset district year

xtreg gdp_pc total_stem_inst dens edu_lit_7_t s* hh_wtr_t hh_snt2_t, fe
xtreg gdp_pc total_stem_inst dens s* hh_wtr_t hh_snt2_t, fe

// The coefficient on central_tech, the instrument we intend on using is 
// statistically indistinguishable from 0. When we drop edu_lit_7_t, we 
// get a statistically significant coefficient on central_tech, but then 
// the F-statistic is 3.75, which is far lower than the desired 20
xtreg total_stem_inst central_stem dens edu_lit_7_t s* hh_wtr_t hh_snt2_t, fe
xtreg total_stem_inst central_stem dens s* hh_wtr_t hh_snt2_t, fe

// Nonetheless, here's the result of the instrumented regression
xtivreg gdp_pc (total_stem_inst = central_stem) dens edu_lit_7_t s* hh_wtr_t hh_snt2_t, fe
xtivreg gdp_pc (total_stem_inst = central_stem) dens s* hh_wtr_t hh_snt2_t, fe

gen batikInstr = batik * central_stem
xtreg gdp_pc batikInstr dens edu_lit_7_t s* hh_wtr_t hh_snt2_t, fe
xtreg gdp_pc batikInstr dens s* hh_wtr_t hh_snt2_t, fe

gen batikInstr2 = batik * total_inst
xtreg gdp_pc batikInstr2 dens edu_lit_7_t s* hh_wtr_t hh_snt2_t, fe
xtreg gdp_pc batikInstr2 dens s* hh_wtr_t hh_snt2_t, fe

gen batikInstr3 = batik * total_central_inst
xtreg gdp_pc batikInstr3 dens edu_lit_7_t s* hh_wtr_t hh_snt2_t, fe
xtreg gdp_pc batikInstr3 dens s* hh_wtr_t hh_snt2_t, fe

xtivreg gdp_pc (total_stem_inst = total_central_inst) dens edu_lit_7_t s* hh_wtr_t hh_snt2_t, fe
xtivreg gdp_pc (total_stem_inst = total_central_inst) dens s* hh_wtr_t hh_snt2_t, fe

log close
