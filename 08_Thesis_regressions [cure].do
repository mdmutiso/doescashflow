clear

import excel "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Excel xlsx and csv\Final Produced\Final uncure.xlsx", sheet("Sheet1") firstrow


label variable Path "Path"
label variable Target "Target"
label variable cik "Company CIK"
label variable tic "Company Ticker"
label variable datadate "Data Date"
label variable datacqtr "Data Quarter"
label variable Filingdate "Filing Date"
label variable Expo_Loc "Exposure"
label variable B_Deb_Lev "Leverage"
label variable profitability "Profitability"
label variable F_Deb_Lev "FRD Leverage"
label variable Book_leverage "Book Leverage"
label variable Mar_book_ratio "Market to Book"
label variable Asset_Maturity "Asset Maturity"
label variable Financial_Slack "Financial Slack"
label variable Ret_earnings "Retained earnings"
label variable FixedExpo_Loc "Fixed Exposure"
label variable FixedExpo_Loc "Fixed Debt"
label variable Credit_rat "Credit Rating"
label variable MP1 "MP1 Surprise"
label variable car "Cum Abn Ret"
label variable bhar "BuynHold Abn"
label variable TwodayRet_sim "Stock Return"
label variable TwodayRet_log "Stock Return"
label variable onedayRet_sim "Oneday Simple Return"
label variable onedayRet_log "Oneday Log Return"
label variable Short_term_debt "Short term debt"


gen TwodayRet_sim_new = TwodayRet_sim*100
gen TwodayRet_log_new = TwodayRet_log*100
label variable TwodayRet_sim_new "Stock Return"
label variable TwodayRet_log_new "Stock Return"


gen onedayRet_sim_new = onedayRet_sim*100
gen onedayRet_log_new = onedayRet_log*100
label variable onedayRet_sim_new "Daily Stock Return"
label variable onedayRet_log_new "Daily Stock Return"

gen car_s = car*car
label variable car_s "CAR"

gen car_s_new = car_s*100
label variable car_s "CAR"

format Date %tdnn/dd/YY

pctile pct1 =F_Deb_Lev, nq(20)
gen SPEC=0
replace SPEC=1 if F_Deb_Lev==0 & Hedge==1

*sysdir set PLUS c:\ado\plus\

winsor2 Expo_Loc, replace cuts(1 99)
winsor2 Target, replace cuts(1 99)
winsor2 Path, replace cuts(1 99)
winsor2 Size, replace cuts(1 99)
winsor2 F_Deb_Lev, replace cuts(1 99)
winsor2 B_Deb_Lev, replace cuts(1 99)
winsor2 profitability, replace cuts(1 99)
winsor2 Mar_book_ratio, replace cuts(1 99)
winsor2 Book_leverage, replace cuts(1 99)
winsor2 TwodayRet_log, replace cuts(1 99)
winsor2 TwodayRet_sim, replace cuts(1 99)
winsor2 Short_term_debt, replace cuts(1 99)
winsor2 FixedExpo_Loc, replace cuts(1 99)
winsor2 Ret_earnings, replace cuts(1 99)
winsor2 Financial_Slack, replace cuts(1 99)
winsor2 Asset_Maturity, replace cuts(1 99)
winsor2 car, replace cuts(1 99)
winsor2 bhar, replace cuts(1 99)
winsor2 MP1, replace cuts(1 99)
winsor2 TwodayRet_log_new, replace cuts(1 99)
winsor2 TwodayRet_sim_new, replace cuts(1 99)
winsor2 onedayRet_log_new, replace cuts(1 99)
winsor2 onedayRet_log, replace cuts(1 99)
winsor2 onedayRet_sim, replace cuts(1 99)
winsor2 car_s, replace cuts(1 99)
winsor2 car_s_new, replace cuts(1 99)




est clear

estpost tabstat Expo_Loc  B_Deb_Lev F_Deb_Lev FixedExpo_Loc FixedDeb_Lev Asset_Maturity Size profitability Book_leverage Mar_book_ratio  Short_term_debt Ret_earnings Financial_Slack, by(Hedge) c(stat) stat(mean sd)


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Excel xlsx and csv/Summarystat.tex", replace ///
	cells("mean(fmt(%8.2fc)) sd(pattern(1 1 0))") nostar nonumber unstack ///
	compress nonote noobs gap label booktabs ///
	collabels("Mean" "SD" " ", span) ///
	nomtitles ///
	eqlabels("Hedge=0" "Hedge=1") ///
	title("Summary statistics of \label{Summarystat}")

est clear

*Regression1: Relationship of MP1 with Stock Returns
eststo: areg TwodayRet_log_new MP1 profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "NO"

*interactions
eststo: areg TwodayRet_log_new MP1 profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.MP1#c.Size  c.MP1#c.profitability c.MP1#c.Book_leverage c.MP1#c.Mar_book_ratio ///
c.MP1#c.Asset_Maturity c.MP1#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*interactions and ZLB
eststo: areg TwodayRet_log_new MP1 profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
 c.MP1#c.Size  c.MP1#c.profitability c.MP1#c.Book_leverage c.MP1#c.Mar_book_ratio ///
c.MP1#c.Asset_Maturity c.MP1#c.Financial_Slack if ZLB==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/1. Simplesurprise.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of One Dimensional Policy Surprise on Stock Returns \label{reg: SimplePanel}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls*MP1") sfmt(3 0)
 
 
esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/21. Simplesurprise.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of One Dimensional Policy Surprise on Stock Returns \label{reg: SimplePanelApp}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls*MP1") sfmt(3 0) 

************************************************************************************************************************************************************************************************************

est clear

*Regression1: Relationship of Target & Path with Stock Returns
eststo: areg TwodayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if Date!=Filingdate, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
 c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if ZLB==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"




esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/2. Twodimensions.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: Twodimensions}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls*Target/Path") sfmt(3 0)
 
 
esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/22. Twodimensions.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: TwodimensionsApp}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls*Target/Path") sfmt(3 0)
 
************************************************************************************************************************************************************************************************************

est clear

*Regression1: Relationship of Target & Path with Stock Returns
eststo: areg TwodayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack if GUR==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if GUR==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
 c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if GUR==1 & ZLB==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"



esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/22. TwodimensionsGURrob.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: TwodimensionsGur}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls*Target/Path") sfmt(3 0)
 
 esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/22. TwodimensionsGUR.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: TwodimensionsGur}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls*Target/Path") sfmt(3 0)
 

************************************************************************************************************************************************************************************************************

est clear

*Regression1: Relationship of Target & Path with Stock Returns
eststo: areg car_s Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg car_s Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg car_s Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
 c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if ZLB==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg onedayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
 c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if SPEC!=1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/22. TwodimensionsRobust.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: TwodimensionsRobust}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls*Target/Path") sfmt(3 0)

 
************************************************************************************************************************************************************************************************************
est clear

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path F_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.F_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.F_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev F_Deb_Lev Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.F_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.F_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/3. Floatingvar.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: Floatingvar}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
 
 
esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/23. Floatingvar.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: FloatingvarApp}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
 
************************************************************************************************************************************************************************************************************
est clear

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg car_s_new B_Deb_Lev  Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev  c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev  c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg car_s_new B_Deb_Lev  Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev  c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev  c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock if SPEC==0, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg onedayRet_log_new B_Deb_Lev  Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev  c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev  c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg onedayRet_log_new B_Deb_Lev  Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev  c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev  c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock if SPEC==0, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "YES"
estadd local  FC  "YES"

 
esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/23. Floatingvarrob.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title(" \label{reg: FloatingvarAppRob}")   ///
 scalars("r2 R$^2$" "TE Time FE" "FE Firm FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
 
************************************************************************************************************************************************************************************************************
est clear

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "NO"


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new 1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/4. Hedge.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: Hedge}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "TE Time FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
 
 
esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/24. Hedge.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: HedgeApp}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "TE Time FE" "FC Controls/Controls*Target/Path") sfmt(3 0)

 
************************************************************************************************************************************************************************************************************
est clear


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg car_s_new B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg car_s_new B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock if SPEC==0, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg onedayRet_log_new B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg onedayRet_log_new B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock if SPEC==0, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if Expo_Loc<=0.0342982, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/24. HedgeRob.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: HedgeRob}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "TE Time FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
 

 
************************************************************************************************************************************************************************************************************
est clear

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.ZLB#c.Target 1.ZLB#c.Path 1.ZLB#c.B_Deb_Lev 1.ZLB#1.Hedge 1.ZLB#c.Expo_Loc 1.ZLB#c.Size 1.ZLB#c.profitability 1.ZLB#c.Book_leverage 1.ZLB#c.Mar_book_ratio 1.ZLB#c.Asset_Maturity 1.ZLB#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Path 1.ZLB#1.Hedge#c.Target 1.ZLB#1.Hedge#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Expo_Loc 1.ZLB#1.Hedge#c.Size 1.ZLB#1.Hedge#c.profitability 1.ZLB#1.Hedge#c.Book_leverage 1.ZLB#1.Hedge#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Asset_Maturity 1.ZLB#1.Hedge#c.Financial_Slack ///
1.ZLB#c.Path#c.B_Deb_Lev 1.ZLB#c.Path#c.Expo_Loc 1.ZLB#c.Path#c.Size 1.ZLB#c.Path#c.profitability 1.ZLB#c.Path#c.Book_leverage 1.ZLB#c.Path#c.Mar_book_ratio 1.ZLB#c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
1.ZLB#c.Target#c.B_Deb_Lev 1.ZLB#c.Target#c.Expo_Loc 1.ZLB#c.Target#c.Size 1.ZLB#c.Target#c.profitability 1.ZLB#c.Target#c.Book_leverage 1.ZLB#c.Target#c.Mar_book_ratio 1.ZLB#c.Target#c.Asset_Maturity 1.ZLB#c.Target#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Path#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Path#c.Expo_Loc 1.ZLB#1.Hedge#c.Path#c.Size 1.ZLB#1.Hedge#c.Path#c.profitability 1.ZLB#1.Hedge#c.Path#c.Book_leverage 1.ZLB#1.Hedge#c.Path#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Path#c.Asset_Maturity 1.ZLB#1.Hedge#c.Path#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Target#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Target#c.Expo_Loc 1.ZLB#1.Hedge#c.Target#c.Size 1.ZLB#1.Hedge#c.Target#c.profitability 1.ZLB#1.Hedge#c.Target#c.Book_leverage 1.ZLB#1.Hedge#c.Target#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Target#c.Asset_Maturity 1.ZLB#1.Hedge#c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.ZLB#c.B_Deb_Lev 1.ZLB#1.Hedge 1.ZLB#c.Expo_Loc 1.ZLB#c.Size 1.ZLB#c.profitability 1.ZLB#c.Book_leverage 1.ZLB#c.Mar_book_ratio 1.ZLB#c.Asset_Maturity 1.ZLB#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Path 1.ZLB#1.Hedge#c.Target 1.ZLB#1.Hedge#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Expo_Loc 1.ZLB#1.Hedge#c.Size 1.ZLB#1.Hedge#c.profitability 1.ZLB#1.Hedge#c.Book_leverage 1.ZLB#1.Hedge#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Asset_Maturity 1.ZLB#1.Hedge#c.Financial_Slack ///
1.ZLB#c.Path#c.B_Deb_Lev 1.ZLB#c.Path#c.Expo_Loc 1.ZLB#c.Path#c.Size 1.ZLB#c.Path#c.profitability 1.ZLB#c.Path#c.Book_leverage 1.ZLB#c.Path#c.Mar_book_ratio 1.ZLB#c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
1.ZLB#c.Target#c.B_Deb_Lev 1.ZLB#c.Target#c.Expo_Loc 1.ZLB#c.Target#c.Size 1.ZLB#c.Target#c.profitability 1.ZLB#c.Target#c.Book_leverage 1.ZLB#c.Target#c.Mar_book_ratio 1.ZLB#c.Target#c.Asset_Maturity 1.ZLB#c.Target#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Path#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Path#c.Expo_Loc 1.ZLB#1.Hedge#c.Path#c.Size 1.ZLB#1.Hedge#c.Path#c.profitability 1.ZLB#1.Hedge#c.Path#c.Book_leverage 1.ZLB#1.Hedge#c.Path#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Path#c.Asset_Maturity 1.ZLB#1.Hedge#c.Path#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Target#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Target#c.Expo_Loc 1.ZLB#1.Hedge#c.Target#c.Size 1.ZLB#1.Hedge#c.Target#c.profitability 1.ZLB#1.Hedge#c.Target#c.Book_leverage 1.ZLB#1.Hedge#c.Target#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Target#c.Asset_Maturity 1.ZLB#1.Hedge#c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.ZLB#c.B_Deb_Lev 1.ZLB#1.Hedge 1.ZLB#c.Expo_Loc 1.ZLB#c.Size 1.ZLB#c.profitability 1.ZLB#c.Book_leverage 1.ZLB#c.Mar_book_ratio 1.ZLB#c.Asset_Maturity 1.ZLB#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Path 1.ZLB#1.Hedge#c.Target 1.ZLB#1.Hedge#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Expo_Loc 1.ZLB#1.Hedge#c.Size 1.ZLB#1.Hedge#c.profitability 1.ZLB#1.Hedge#c.Book_leverage 1.ZLB#1.Hedge#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Asset_Maturity 1.ZLB#1.Hedge#c.Financial_Slack ///
1.ZLB#c.Path#c.B_Deb_Lev 1.ZLB#c.Path#c.Expo_Loc 1.ZLB#c.Path#c.Size 1.ZLB#c.Path#c.profitability 1.ZLB#c.Path#c.Book_leverage 1.ZLB#c.Path#c.Mar_book_ratio 1.ZLB#c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
1.ZLB#c.Target#c.B_Deb_Lev 1.ZLB#c.Target#c.Expo_Loc 1.ZLB#c.Target#c.Size 1.ZLB#c.Target#c.profitability 1.ZLB#c.Target#c.Book_leverage 1.ZLB#c.Target#c.Mar_book_ratio 1.ZLB#c.Target#c.Asset_Maturity 1.ZLB#c.Target#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Path#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Path#c.Expo_Loc 1.ZLB#1.Hedge#c.Path#c.Size 1.ZLB#1.Hedge#c.Path#c.profitability 1.ZLB#1.Hedge#c.Path#c.Book_leverage 1.ZLB#1.Hedge#c.Path#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Path#c.Asset_Maturity 1.ZLB#1.Hedge#c.Path#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Target#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Target#c.Expo_Loc 1.ZLB#1.Hedge#c.Target#c.Size 1.ZLB#1.Hedge#c.Target#c.profitability 1.ZLB#1.Hedge#c.Target#c.Book_leverage 1.ZLB#1.Hedge#c.Target#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Target#c.Asset_Maturity 1.ZLB#1.Hedge#c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.ZLB#c.B_Deb_Lev 1.ZLB#1.Hedge 1.ZLB#c.Expo_Loc 1.ZLB#c.Size 1.ZLB#c.profitability 1.ZLB#c.Book_leverage 1.ZLB#c.Mar_book_ratio 1.ZLB#c.Asset_Maturity 1.ZLB#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Path 1.ZLB#1.Hedge#c.Target 1.ZLB#1.Hedge#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Expo_Loc 1.ZLB#1.Hedge#c.Size 1.ZLB#1.Hedge#c.profitability 1.ZLB#1.Hedge#c.Book_leverage 1.ZLB#1.Hedge#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Asset_Maturity 1.ZLB#1.Hedge#c.Financial_Slack ///
1.ZLB#c.Path#c.B_Deb_Lev 1.ZLB#c.Path#c.Expo_Loc 1.ZLB#c.Path#c.Size 1.ZLB#c.Path#c.profitability 1.ZLB#c.Path#c.Book_leverage 1.ZLB#c.Path#c.Mar_book_ratio 1.ZLB#c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
1.ZLB#c.Target#c.B_Deb_Lev 1.ZLB#c.Target#c.Expo_Loc 1.ZLB#c.Target#c.Size 1.ZLB#c.Target#c.profitability 1.ZLB#c.Target#c.Book_leverage 1.ZLB#c.Target#c.Mar_book_ratio 1.ZLB#c.Target#c.Asset_Maturity 1.ZLB#c.Target#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Path#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Path#c.Expo_Loc 1.ZLB#1.Hedge#c.Path#c.Size 1.ZLB#1.Hedge#c.Path#c.profitability 1.ZLB#1.Hedge#c.Path#c.Book_leverage 1.ZLB#1.Hedge#c.Path#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Path#c.Asset_Maturity 1.ZLB#1.Hedge#c.Path#c.Financial_Slack ///
1.ZLB#1.Hedge#c.Target#c.B_Deb_Lev 1.ZLB#1.Hedge#c.Target#c.Expo_Loc 1.ZLB#1.Hedge#c.Target#c.Size 1.ZLB#1.Hedge#c.Target#c.profitability 1.ZLB#1.Hedge#c.Target#c.Book_leverage 1.ZLB#1.Hedge#c.Target#c.Mar_book_ratio 1.ZLB#1.Hedge#c.Target#c.Asset_Maturity 1.ZLB#1.Hedge#c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack if GUR==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "NO"





 
esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/24. HedgeRob2.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: HedgeAppRob2}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "TE Time FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
 
************************************************************************************************************************************************************************************************************

est clear

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev 1.Hedge Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev  1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "NO"


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev 1.Hedge Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev  1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  FC  "YES"
estadd local  TE  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new 1.Hedge Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.Expo_Loc 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new B_Deb_Lev 1.Hedge Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
1.Hedge#c.Path 1.Hedge#c.Target 1.Hedge#c.B_Deb_Lev 1.Hedge#c.Size 1.Hedge#c.profitability 1.Hedge#c.Book_leverage 1.Hedge#c.Mar_book_ratio 1.Hedge#c.Asset_Maturity 1.Hedge#c.Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack ///
1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Path#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Path#c.Mar_book_ratio 1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack ///
1.Hedge#c.Target#c.B_Deb_Lev 1.Hedge#c.Target#c.Size 1.Hedge#c.Target#c.profitability 1.Hedge#c.Target#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  FC  "YES"
estadd local  TE  "YES"


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/24. Hedge2.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: HedgeRob}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "TE Time FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
************************************************************************************************************************************************************************************************************


est clear

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new B_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  TE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new F_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.F_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.F_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  TE  "YES"
estadd local  FC  "YES"


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new  Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  TE  "YES"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new B_Deb_Lev F_Deb_Lev Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.F_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.F_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  TE  "YES"
estadd local  FC  "YES"


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new B_Deb_Lev Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "NO"
estadd local  TE  "YES"
estadd local  FC  "YES"




*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new B_Deb_Lev Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "YES"
estadd local  FC  "YES"
 
 
esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/23. Floatingvar 2.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: FloatingRobApp2}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "TE Time Effects" "FC Controls/Controls*Target/Path") sfmt(3 0)
 
************************************************************************************************************************************************************************************************************

est clear


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev Expo_Loc Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Expo_Loc c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Expo_Loc c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  FC  "YES"


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/3. Floatingvar.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: Floatingvar}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
 
 
esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/23. Floatingvar.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Two Dimensional Policy Surprise on Stock Returns \label{reg: FloatingvarApp}")   ///
 scalars("r2 R$^2$" "FE Firm FE" "FC Controls/Controls*Target/Path") sfmt(3 0)
 
************************************************************************************************************************************************************************************************************
est clear


*Regression1: Relationship of Target & Path with Stock Returns
eststo: areg TwodayRet_log_new Target Path F_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "YES"

*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path F_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.F_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.F_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "YES"


*Regression 2: Relationship of Target & Path with Stock Returns (BDEBTLEV)
eststo: areg TwodayRet_log_new Target Path B_Deb_Lev F_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack ///
c.Path#c.B_Deb_Lev c.Path#c.F_Deb_Lev c.Path#c.Size c.Path#c.profitability c.Path#c.Book_leverage c.Path#c.Mar_book_ratio c.Path#c.Asset_Maturity c.Path#c.Financial_Slack ///
c.Target#c.B_Deb_Lev c.Target#c.F_Deb_Lev c.Target#c.Size c.Target#c.profitability c.Target#c.Book_leverage c.Target#c.Mar_book_ratio c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "YES"



************************************************************************************************************************************************************************************************************


*Regression 2: Relationship of Target & Path with Stock Returns (FDEBTLEV)
eststo: areg TwodayRet_log_new Target Path F_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (interactions)
eststo: areg TwodayRet_log_new Target Path c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev c.Path#c.FixedExpo_Loc c.Target#c.FixedExpo_Loc ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "NO"


*Regression 2: Relationship of Target & Path with Stock Returns (interactions/Gur period) watch the target and bdebt lev
eststo: areg TwodayRet_log_new Target Path c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if GUR==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (interactions/Gur period) watch the target and bdebt lev
eststo: areg TwodayRet_sim Target Path c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if ZLB==1 & GUR==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns (interactions/Gur period) watch the target and bdebt lev
eststo: areg TwodayRet_sim Target Path c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack if ZLB==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "NO"


eststo: areg TwodayRet_sim Target Path i.numstock c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev  ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "NO"
estadd local  FC  "NO"


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/firstpanel.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Monetary Policy Surprise on Stock Returns \label{reg: firstpanel}")   ///
 scalars("r2 R$^2$" "TE Firm FE" "FE Firm FE") sfmt(3 0) ///
 addnotes("We can make comments about the data here")
 
 est clear

*Regression 4: Exposure
eststo: areg TwodayRet_sim Target Path c.Path#c.Expo_Loc c.Target#c.Expo_Loc c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev  ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"

*Regression 4: Exposure
eststo: areg TwodayRet_sim Target Path c.Path#c.Expo_Loc c.Target#c.Expo_Loc c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev  ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(numstock) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"

*Regression 4: Exposure
eststo: areg TwodayRet_sim Target Path  c.Path#c.Expo_Loc c.Target#c.Expo_Loc c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev  ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "NO"



esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/Secondpanel.tex", replace  ///
 b(3) se(3) nomtitle label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs  ///
 longtable ///
 keep($controls) ///
 title("Effects of Debt Type and Hedge on Monetary Policy Reactions \label{reg2}")   ///
 scalars("r2 \$R^2\$" "TE Time FE" "FE Firm FE") sfmt(3 0) ///
 addnotes("Comments on the graph")
 
 est clear
 
*Regression 7: Exposure with Hedge
eststo: areg TwodayRet_sim Target Path c.Path#c.Expo_Loc c.Target#c.Expo_Loc c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev  1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Target#c.B_Deb_Lev  ///
 1.Hedge#c.Path#c.Size 1.Hedge#c.Target#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Target#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio ///
1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"

*Regression 7: Exposure with Hedge
eststo: areg TwodayRet_sim Target Path c.Path#c.Expo_Loc c.Target#c.Expo_Loc c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev  1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Target#c.B_Deb_Lev  ///
 1.Hedge#c.Path#c.Size 1.Hedge#c.Target#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Target#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio ///
1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack if Date!=Filingdate, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"
 
*Regression 7: Exposure with Hedge
eststo: areg TwodayRet_sim Target Path c.Path#c.Expo_Loc c.Target#c.Expo_Loc c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Target#c.B_Deb_Lev  ///
 1.Hedge#c.Path#c.Size 1.Hedge#c.Target#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Target#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio ///
1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack i.numstock, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "NO"

*Regression 7: Exposure with Hedge
eststo: areg TwodayRet_sim Target Path c.Path#c.Expo_Loc c.Target#c.Expo_Loc c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev  1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Target#c.B_Deb_Lev  ///
 1.Hedge#c.Path#c.Size 1.Hedge#c.Target#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Target#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio ///
1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack i.numstock if Date!=Filingdate, absorb(cik) vce(cluster numstock)
estadd local  FE  "YES"
estadd local  TE  "NO"

esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/thirdpanel.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Monetary Policy Surprise on Stock Returns \label{reg: thirdpanel}")   ///
 scalars("r2 \$R^2\$" "TE Time FE" "FE Firm FE") sfmt(3 0) ///
 addnotes("We can make comments about the data here")
 
 est clear
 
 
*Regression1: Relationship of Target & Path with Stock Returns
eststo: areg car_s Target Path if Date!=Filingdate, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns
eststo: areg car_s Target Path B_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"

*Regression 3: Relationship of Target & Path with Stock Returns
eststo: areg car_s Target Path B_Deb_Lev F_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack if Date!=Filingdate, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"


*Regression 2: Relationship of Target & Path with Stock Returns (interactions)
eststo: areg car_s Target Path c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"


*Regression 4: Exposure
eststo: areg car Target Path c.Path#c.Expo_Loc c.Target#c.Expo_Loc c.Path#c.B_Deb_Lev c.Target#c.B_Deb_Lev  ///
 c.Path#c.Size c.Target#c.Size c.Path#c.profitability c.Target#c.profitability c.Path#c.Book_leverage c.Target#c.Mar_book_ratio ///
c.Path#c.Asset_Maturity c.Path#c.Financial_Slack c.Target#c.Asset_Maturity c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"


*Regression 7: Exposure with Hedge
eststo: areg car_s Target Path 1.Hedge#c.Path#c.Expo_Loc 1.Hedge#c.Target#c.Expo_Loc 1.Hedge#c.Path#c.B_Deb_Lev 1.Hedge#c.Target#c.B_Deb_Lev  ///
 1.Hedge#c.Path#c.Size 1.Hedge#c.Target#c.Size 1.Hedge#c.Path#c.profitability 1.Hedge#c.Target#c.profitability 1.Hedge#c.Path#c.Book_leverage 1.Hedge#c.Target#c.Mar_book_ratio ///
1.Hedge#c.Path#c.Asset_Maturity 1.Hedge#c.Path#c.Financial_Slack 1.Hedge#c.Target#c.Asset_Maturity 1.Hedge#c.Target#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"




esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/fourthpanel.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Monetary Policy Surprise on Stock Returns \label{reg: fourthpanel}")   ///
 scalars("r2 R$^2$" "TE Time FE" "FE Firm FE") sfmt(3 0) ///
 addnotes("We can make comments about the data here")
 
est clear

*Regression1: Relationship of Target & Path with Stock Returns
eststo: areg TwodayRet_sim MP1 if Date!=Filingdate, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"

*Regression 2: Relationship of Target & Path with Stock Returns
eststo: areg TwodayRet_sim MP1 B_Deb_Lev Size profitability Book_leverage Mar_book_ratio Asset_Maturity Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"


*Regression 2: Relationship of  with Stock Returns (interactions)
eststo: areg TwodayRet_sim c.MP1#c.B_Deb_Lev c.MP1#c.B_Deb_Lev ///
 c.MP1#c.Size  c.MP1#c.profitability c.MP1#c.Book_leverage c.MP1#c.Mar_book_ratio ///
 c.MP1#c.Asset_Maturity c.MP1#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"


*Regression 2: Relationship of  with Stock Returns (interactions)
eststo: areg car_s c.MP1#c.B_Deb_Lev c.MP1#c.B_Deb_Lev ///
 c.MP1#c.Size  c.MP1#c.profitability c.MP1#c.Book_leverage c.MP1#c.Mar_book_ratio ///
 c.MP1#c.Asset_Maturity c.MP1#c.Financial_Slack, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"



*Regression 2: Relationship of  with Stock Returns (interactions)
eststo: areg TwodayRet_sim c.MP1#c.B_Deb_Lev c.MP1#c.B_Deb_Lev ///
 c.MP1#c.Size  c.MP1#c.profitability c.MP1#c.Book_leverage c.MP1#c.Mar_book_ratio ///
c.MP1#c.Asset_Maturity c.MP1#c.Financial_Slack if ZLB==1, absorb(cik) vce(robust)
estadd local  FE  "YES"
estadd local  TE  "NO"


esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/fifthpanel.tex", replace  ///
 b(3) se(3)  label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs ///
 longtable ///
 keep($controls) ///
 title("Effects of Monetary Policy Surprise on Stock Returns \label{reg: fifthpanel}")   ///
 scalars("r2 R$^2$" "TE Time FE" "FE Firm FE") sfmt(3 0) ///
 addnotes("We can make comments about the data here")



esttab using "C:\Users\Återställd\University of Gothenburg\OneDrive - University of Gothenburg\Masters Thesis\Code\Thesis code and data\Data\Tex/fifthpanel.tex", replace  ///
 b(3) se(3) nomtitle label star(* 0.10 ** 0.05 *** 0.01) ///
 booktabs  ///
 longtable ///
 keep($controls) ///
 title("Effects of Debt Type and Hedge on Monetary Policy Reactions \label{reg2}")   ///
 scalars("r2 \$R^2\$" "TE Time FE" "FE Firm FE") sfmt(3 0) ///
 addnotes("Comments on the graph")
 
est clear