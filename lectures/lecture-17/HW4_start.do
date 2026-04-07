* ==============================================================================
*
* 3.2 Airbnb Price Prediction — Predictive Analysis Pipeline
* Jackson School of Global Affairs
* Ardina Hasanbasri (GLBL 5021)
* Reference: Békés & Kézdi (2021) https://gabors-data-analysis.com/
*
* ==============================================================================
* Stages:
*   1. Create holdout and working samples
*   2. Build and Estimate 8 OLS candidate models via 4-fold CV
*   3. Select the best model by CV RMSE, R-squared, and BIC
*   4. Evaluate the final model on the holdout sample
* ==============================================================================

clear all
set more off
set seed 20180123


* ==============================================================================
* 0.  Load data
* ==============================================================================

import delimited "airbnb_hackney_workfile_adj_book1.csv", clear varnames(1)

destring usd_cleaning_fee usd_price_day p_host_response_rate n_accommodates n_bathrooms ///
    n_review_scores_rating n_number_of_reviews n_guests_included n_reviews_per_month ///
    n_extra_people n_minimum_nights n_beds n_days_since price ln_price ///
    n_accommodates2 ln_accommodates ln_accommodates2 ln_beds ln_number_of_reviews ///
    ln_days_since ln_days_since2 ln_days_since3 n_days_since2 n_days_since3 ///
    ln_review_scores_rating f_bathroom f_number_of_reviews f_minimum_nights, replace force


* ==============================================================================
* 1.  List all models we will build in this exercise.
* ==============================================================================

* --- Impute missing values with median and create flags ----------------------

gen flag_days_since = missing(n_days_since)
egen median_days = median(n_days_since)
replace n_days_since = median_days if missing(n_days_since)
drop median_days

gen flag_review_scores_rating = missing(n_review_scores_rating)
egen median_rating = median(n_review_scores_rating)
replace n_review_scores_rating = median_rating if missing(n_review_scores_rating)
drop median_rating

gen flag_reviews_per_month = missing(n_reviews_per_month)
egen median_rpm = median(n_reviews_per_month)
replace n_reviews_per_month = median_rpm if missing(n_reviews_per_month)
drop median_rpm

* --- Encode string categoricals and expand to dummies -----------------------

encode f_property_type,       gen(prop_type_code)
encode f_room_type,           gen(room_type_code)
encode f_bed_type,            gen(bed_type_code)
encode f_cancellation_policy, gen(cancel_code)

tab prop_type_code,      gen(prop_)     // prop_1=Apartment(base), prop_2=House
tab room_type_code,      gen(room_)     // room_1=Entire home(base), room_2=Private, room_3=Shared
tab bed_type_code,       gen(bed_)      // bed_1=Couch(base), bed_2=Real Bed
tab cancel_code,         gen(cancel_)   // cancel_1=flexible(base), cancel_2=moderate, cancel_3=strict
tab f_bathroom,          gen(bath_)     // bath_1=0(base), bath_2=1, bath_3=2
tab f_number_of_reviews, gen(nrev_)     // nrev_1=0(base), nrev_2=1, nrev_3=2

* --- Create X1 interaction terms ---------------------------------------------
* R: f_room_type*f_property_type  → room_2 and room_3 each x prop_2

gen room2_prop2        = room_2 * prop_2   // Private room x House
gen room3_prop2        = room_3 * prop_2   // Shared room  x House

* R: f_room_type*d_familykidfriendly → room_2 and room_3 each x d_familykidfriendly

gen room2_family       = room_2 * d_familykidfriendly
gen room3_family       = room_3 * d_familykidfriendly

* --- Create X2 interaction terms ---------------------------------------------
* R: d_airconditioning*f_property_type, d_cats*f_property_type, d_dogs*f_property_type

gen aircond_prop2      = d_airconditioning * prop_2
gen cats_prop2         = d_cats            * prop_2
gen dogs_prop2         = d_dogs            * prop_2

* --- Create X3 interaction terms for model8 ----------------------------------
* R: (f_property_type + f_room_type + f_cancellation_policy + f_bed_type) x all amenities
* Each amenity is interacted with: prop_2, room_2, room_3, cancel_2, cancel_3, bed_2

local amenities  "d_24hourcheckin d_breakfast d_buzzerwirelessintercom d_cabletv d_carbonmonoxidedetector d_cats d_dogs d_doorman d_doormanentry d_dryer d_elevatorinbuilding d_essentials d_familykidfriendly d_fireextinguisher d_firstaidkit d_freeparkingonpremises d_freeparkingonstreet d_gym d_hairdryer d_hangers d_heating d_hottub d_indoorfireplace d_internet d_iron d_keypad d_kitchen d_laptopfriendlyworkspace d_lockonbedroomdoor d_lockbox d_otherpets d_paidparkingoffpremises d_petsliveonthisproperty d_pool d_privateentrance d_privatelivingroom d_safetycard d_selfcheckin d_shampoo d_smartlock d_smokedetector d_smokingallowed d_suitableforevents d_tv d_washer d_washerdryer d_wheelchairaccessible d_wirelessinternet"

local shortnames "a24h abreak abuzzer acable acarbon acats adogs adoorman adoormane adryer aelev aessent afamily afireext afirstaid afpremise afpstreet agym ahairdryr ahangers aheating ahottub aindfire ainternet airon akeypad akitchen alaptop alockon alockbox aotherpet apaidpark apetslive apool aprivente aprivlive asafety aselfchk ashampoo asmartlk asmokedet asmokallw asuitevt atv awasher awasherdr awheelchr awireless"

local x3_vars ""

local n_amen : word count `amenities'
forvalues j = 1/`n_amen' {
    local amen  : word `j' of `amenities'
    local short : word `j' of `shortnames'

    gen `short'_p2  = `amen' * prop_2      // x property type (House)
    gen `short'_r2  = `amen' * room_2      // x room type (Private room)
    gen `short'_r3  = `amen' * room_3      // x room type (Shared room)
    gen `short'_c2  = `amen' * cancel_2    // x cancellation (moderate)
    gen `short'_c3  = `amen' * cancel_3    // x cancellation (strict)
    gen `short'_b2  = `amen' * bed_2       // x bed type (Real Bed)

    local x3_vars "`x3_vars' `short'_p2 `short'_r2 `short'_r3 `short'_c2 `short'_c3 `short'_b2"
}

* --- Model formulas ----------------------------------------------------------
* Matches R model groups exactly. All plain variable names — no i. or ## needed.

* basic_lev
local basic_lev "n_accommodates n_beds prop_2 room_2 room_3 n_days_since flag_days_since"

* basic_add
local basic_add "bath_2 bath_3 cancel_2 cancel_3 bed_2"

* reviews
local reviews "nrev_2 nrev_3 n_review_scores_rating flag_review_scores_rating"

* poly_lev
local poly_lev "n_accommodates2 n_days_since2 n_days_since3"

* X1: room_type x property_type + room_type x d_familykidfriendly
local X1 "room2_prop2 room3_prop2 room2_family room3_family"

* X2: d_airconditioning, d_cats, d_dogs each x property_type
local X2 "aircond_prop2 cats_prop2 dogs_prop2"

* amenities (main effects, used in model7)
local amenity_main "d_24hourcheckin d_breakfast d_buzzerwirelessintercom d_cabletv d_carbonmonoxidedetector d_cats d_dogs d_doorman d_doormanentry d_dryer d_elevatorinbuilding d_essentials d_familykidfriendly d_fireextinguisher d_firstaidkit d_freeparkingonpremises d_freeparkingonstreet d_gym d_hairdryer d_hangers d_heating d_hottub d_indoorfireplace d_internet d_iron d_keypad d_kitchen d_laptopfriendlyworkspace d_lockonbedroomdoor d_lockbox d_otherpets d_paidparkingoffpremises d_petsliveonthisproperty d_pool d_privateentrance d_privatelivingroom d_safetycard d_selfcheckin d_shampoo d_smartlock d_smokedetector d_smokingallowed d_suitableforevents d_tv d_washer d_washerdryer d_wheelchairaccessible d_wirelessinternet"

local model1 "n_accommodates"
local model2 "`basic_lev'"
local model3 "`basic_lev' `basic_add' `reviews'"
local model4 "`basic_lev' `basic_add' `reviews' `poly_lev'"
local model5 "`basic_lev' `basic_add' `reviews' `poly_lev' `X1'"
local model6 "`basic_lev' `basic_add' `reviews' `poly_lev' `X1' `X2'"
local model7 "`basic_lev' `basic_add' `reviews' `poly_lev' `X1' `X2' `amenity_main'"
local model8 "`basic_lev' `basic_add' `reviews' `poly_lev' `X1' `X2' `amenity_main' `x3_vars'"


* ==============================================================================
* 2.  Split into holdout (20%) and working (80%) samples
* ==============================================================================

* Drop rows with missing values in variables used across all models.
* This ensures all models are trained on the same observations so
* BIC and RMSE are directly comparable.

egen nmissing = rowmiss(n_accommodates n_beds n_days_since n_review_scores_rating ///
    n_reviews_per_month prop_type_code room_type_code cancel_code bed_type_code ///
    f_bathroom f_number_of_reviews n_accommodates2 n_days_since2 n_days_since3 price)

drop if nmissing > 0
drop nmissing

