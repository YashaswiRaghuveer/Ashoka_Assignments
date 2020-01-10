import os
import re
import pandas as pd
import numpy as np
from fuzzywuzzy import process
from fuzzywuzzy import fuzz
import matplotlib.pyplot as plt

#%%
districtColleges = pd.read_stata("dist_all_coll_regex.dta")
districtColleges.drop(columns='district_name', inplace=True)

districtColleges.district = districtColleges.district.astype('int32')

districtColleges = pd.wide_to_long(districtColleges,
                                   stubnames = ['sci', 'govtsci', 'privatesci', 'iitsci',
                                                'centralsci', 'govttech', 'tech', 'central'
                                                , 'inst'],
                                   i='district', j='year', sep='_')

districtColleges.sort_values(by=['district', 'year'])

districtColleges.sort_index(level=0, inplace=True)

twentyYearDiff = districtColleges.loc[(slice(None), 2011), :].droplevel(1) - districtColleges.loc[(slice(None), 1991), :].droplevel(1)

twentyYearDiff.corr()


#%%
"""
  This cell:
    1. Loads the original STATA file
    2. Changes index to make it easier to manipulate
    3. The final result is the dot product of the $(numObservations, 63)$ matrix and a column
    vector whose $i$th entry corresponds to the brightness of the cell $i$.
"""

nightLights = pd.read_stata("allnightlights1992-2012.dta")

nightLights.dropna(inplace=True)

nightLights.sort_values(['district', 'year'])
nightLights = nightLights.groupby(['district', 'year']).sum()

nightLights = pd.DataFrame(nightLights.dot(np.arange(63)), columns=['brightness'])

nightLights.to_stata("nightLightsBrightness.dta")

#%%
districts = pd.read_stata("district_name_code.dta")
districts.district = districts.district.astype('int32')

districts.district_name = districts.district_name.str.upper()
districts = districts.set_index('district_name')
districts.index.rename('district', inplace=True)

nightLights.index.get_level_values(0).nunique()
districts
nightLights.loc['ADILABAD']['districtCode'] = districts.loc['ADILABAD']

f1 = districts.index.unique()
f2 = nightLights.index.get_level_values(0).unique()

len(set(f1).intersection(set(f2)))

len(districts)

foo = nightLights.join(districts, on='district')

"""
  So the problem over here is that the nightlights dataset has 641 districts whereas the districts
  dataset that Yashaswi has compiled has 446 districts. Need to figure out how to deal with this
  situation
"""

#%%
colleges = pd.read_csv('college_institution.csv', low_memory=False)

colleges.columns

colleges.university_id.nunique()

colleges.head()

colleges.sort_values('id')

colleges.year_of_establishment[colleges.year_of_establishment.notna()]

colleges.groupby(['year_of_establishment']).count()['id'].loc[1960:].plot()

#%%

collegeCourse = pd.read_csv("educational_institution_course.csv")

collegeCourse.columns

collegeCourse.institution_id.nunique()

collegeCourse.head()


collegeCourse.groupby('institution_category').count()

collegeCourse[collegeCourse.institution_category == 'University'].institution_id.unique()

courses = pd.read_csv("course.csv", low_memory=False)

courses.head()

courses.discipline = courses.discipline.str.lower()


len(courses.broad_discipline_group.unique())
courses.programme_id.nunique()
courses.broad_discipline_group.nunique()


#%% There are 37 broad categories
courses.broad_discipline_group_category_id.nunique()

# and the categories are
categories = pd.read_csv("ref_broad_discipline_group_category.csv", index_col='id')
categories
# Those of interest are 7 (engineering and technology), 19 (marine science/oceanography),
# 20 (medical science), 24 (science), 31 (fisheries science), 32 (IT and computer), and
# 36 (paramedical science)

#%%

collegeData = pd.read_stata("level_02/univ_college_standalone_merged.dta")

collegeData.science_eng = collegeData.science_eng.astype('bool')
collegeData.central = collegeData.central.astype('bool')

collegeData.science_eng

centralInst2001 = collegeData[(collegeData.central == True) & (collegeData.year_of_establishment <= 2001) &
            (collegeData.science_eng == True)]


len(centralInst2001)

centralInst2001.groupby('dist_code11').count()['state_code11']

centralInst2011 = collegeData[(collegeData.central == True) & (collegeData.year_of_establishment <= 2011) &
            (collegeData.science_eng == True)]

len(centralInst2011)

centralInst2011.groupby('dist_code11').count()
newInstitutes = centralInst2011.groupby('dist_code11').count()['state_code11'] - centralInst2001.groupby('dist_code11').count()['state_code11']


newInstitutes.describe(percentiles=np.arange(.75, 1, .005))


collegeData.dist_code11.nunique()


#%%
collegeData

centralSTEM = collegeData[(collegeData.science_eng == True) &
                          (collegeData.central == True)]


centralSTEM.dropna(subset=['year_of_establishment'], inplace=True)

centralSTEM.sort_values('district_name')

firstCentralSTEM = centralSTEM.groupby('dist_code11').min()
firstCentralSTEM.year_of_establishment = firstCentralSTEM.year_of_establishment.astype('int32')
firstCentralSTEM.dropna(subset=['year_of_establishment'], inplace=True)

firstCentralSTEM

a = firstCentralSTEM[firstCentralSTEM.year_of_establishment > 1996].groupby('year_of_establishment').count()
plt.xticks(a.state_code11, a.index.values)
plt.plot(a.state_code11)
plt.show()
a.state_code11

#%%
nightLights = pd.read_stata("nightLightsBrightness.dta")

nightLights


collegeDistricts = collegeData.district_name.str.upper().unique()

collegeDistricts

nightLightsDistricts = nightLights.district.unique()

len(set(collegeDistricts).intersection(set(nightLightsDistricts)))

set(collegeDistricts).difference(set(nightLightsDistricts))

nightLightsDistricts
collegeDistricts

process.extract('WAYA0D', collegeDistricts, scorer=fuzz.ratio)

nightLightsDistricts = sorted(nightLightsDistricts, key=lambda e: (len(e), e), reverse=True)

mapping = {}
foo = list(collegeDistricts)
flagged = []

for district in nightLightsDistricts:
  result = process.extractOne(district, foo, scorer=fuzz.ratio)
  if result[1] > 74:
    mapping[district] = process.extractOne(district, foo, scorer=fuzz.ratio)[0]
    foo.pop(foo.index(mapping[district]))
  else:
    flagged.append([district, result])

mapping
sorted(flagged, key=lambda e: e[1][1], reverse=True)

nightLightsDistricts
sorted(collegeDistricts)


#%%
bar = firstCentralSTEM[(firstCentralSTEM.year_of_establishment > 1996) &
                       (firstCentralSTEM.year_of_establishment < 2013)]
centralSTEMdistricts = bar.district_name.str.upper()
centralSTEMdistricts = sorted(centralSTEMdistricts, reverse=True)

mapping = {}
foo = list(nightLightsDistricts)
flagged = []

for district in centralSTEMdistricts:
  result = process.extractOne(district, foo, scorer=fuzz.ratio)
  if result[1] > 74:
    mapping[district] = result[0]
  else:
    flagged.append([district, result])

mapping

# The next few lines fix the mismatches; has been done by hand
mapping['PATNA'] = 'PAT0'
mapping['SRI POTTI SRIRAMULU NELLORE'] = 'SRI_POTTI_SRI'
mapping['DADRA & NAGAR HAVELI'] = 'DADRA_0GAR_H'
mapping['YANAM'] = 'YA0M'
mapping['NADIA'] = '0DIA'
mapping['SOUTH DISTRICT'] = 'SOUTH_SIKKIM'

mapping

centralSTEMdistricts
bar[bar.district_name.str.contains('Aur')]

len(mapping)

bar


#%%

nightLights = pd.read_stata("nightLightsBrightness.dta")
nightLights.sort_values('district', inplace=True)

nightLights.year = pd.to_datetime(nightLights.year, format='%Y')
nightLights = nightLights.set_index(['district', 'year'])
nightLights.sort_values('year', inplace=True)

nightLights.sort_values(['district', 'year'], inplace=True)
nightLights['change'] = nightLights.groupby(['district']).pct_change(5)

nightLights

yearAverages = nightLights.groupby('year').mean().pct_change(5)


nightLights.groupby('year').mean().plot()

yearAverages.brightness.plot()

nightLights

#%%
""" Panel construction """

colleges = pd.read_stata("level_02/univ_college_standalone_merged.dta")

colleges[colleges.dist_code11 > 640]

colleges.central = colleges.central.astype('bool')
colleges.science_eng = colleges.science_eng.astype('bool')

upto2001 = colleges[(colleges.year_of_establishment <= 2001) &
                    (colleges.science_eng == True) &
                    (colleges.central == True)]

upto2001 = upto2001.groupby('dist_code11').count()

panel = pd.DataFrame(upto2001.state_code11, index=colleges.dist_code11.unique())

panel = panel.rename(columns={'state_code11': 'central_stem_2001'})

upto2011 = colleges[(colleges.year_of_establishment <= 2011) &
                    (colleges.science_eng == True) &
                    (colleges.central == True)]

upto2011 = upto2011.groupby('dist_code11').count()['state_code11']

panel['central_stem_2011'] = upto2011

totalSTEMInst2001 = colleges[(colleges.year_of_establishment <= 2001) &
                             (colleges.science_eng == True)]
totalSTEMInst2001 = totalSTEMInst2001.groupby('dist_code11').count()


panel = panel.join(totalSTEMInst2001.state_code11, rsuffix='_2001')

totalSTEMInst2011 = colleges[(colleges.year_of_establishment <= 2011) &
                             (colleges.science_eng == True)]
totalSTEMInst2011 = totalSTEMInst2011.groupby('dist_code11').count()


panel = panel.join(totalSTEMInst2011.state_code11, rsuffix='_2011')

panel.rename(columns={'state_code11': 'total_stem_inst_2001',
                      'state_code11_2011': 'total_stem_inst_2011'},
             inplace=True)
panel.sort_index(inplace=True)


totalInst2001 = colleges[(colleges.year_of_establishment <= 2001)]
totalInst2001 = totalInst2001.groupby('dist_code11').count()

panel = panel.join(totalInst2001.state_code11, rsuffix='_2001')

totalInst2011 = colleges[(colleges.year_of_establishment <= 2011)]
totalInst2011 = totalInst2011.groupby('dist_code11').count()
panel = panel.join(totalInst2011.state_code11, rsuffix='_2011')

panel.rename(columns={'state_code11': 'total_inst_2001',
                     'state_code11_2011': 'total_inst_2011'},
            inplace=True)

totalCentralInst2001 = colleges[(colleges.year_of_establishment <= 2001) &
                                (colleges.central == True)]
totalCentralInst2001 = totalCentralInst2001.groupby('dist_code11').count()
panel = panel.join(totalCentralInst2001.state_code11, rsuffix='_2001')

totalCentralInst2011 = colleges[(colleges.year_of_establishment <= 2011) &
                                (colleges.central == True)]
totalCentralInst2011 = totalCentralInst2011.groupby('dist_code11').count()
panel = panel.join(totalCentralInst2011.state_code11, rsuffix='_2011')

panel.rename(columns={'state_code11': 'total_central_inst_2001',
                      'state_code11_2011': 'total_central_inst_2011'},
            inplace=True)


panel = panel.fillna(0)
panel.sort_index(inplace=True)

total2001 = totalSTEMInst2001.state_code11.sum()
totalSTEMInst2001['batik'] = total2001 - totalSTEMInst2001.state_code11
panel = panel.join(totalSTEMInst2001.batik, rsuffix='_2001')


total2011 = totalSTEMInst2011.state_code11.sum()
totalSTEMInst2011['batik'] = total2011 - totalSTEMInst2011.state_code11
panel = panel.join(totalSTEMInst2011.batik, rsuffix='_2011')
panel.rename(columns={'batik': 'batik_2001'}, inplace=True)

# nightLights = pd.read_excel("level_02/ntl_1992_2012_finaldata.xlsx")
# nightLights.district = nightLights.district.str.replace('0', 'NA')
# nightLights.set_index(['district', 'year'], inplace=True)
# nightLights = nightLights.dot(np.arange(1, 64))
# nightLights.sort_index(inplace=True)
#
# names = nightLights.index.get_level_values(0).unique()
# keyedNames = list(nightLights2001.L2_name.unique())
#
# mapping = {}
# assigned = {}
# for name in names:
#   result = process.extractOne(name, keyedNames)
#   mapping[name] = result[0]
#   if result[0] in assigned:
#     assigned[result[0]].append(name)
#   else:
#     assigned[result[0]] = [name]
#
# nightLights2001
#
# assigned
# assignedCorrectly = [(f, assigned[f]) for f in assigned.keys() if len(assigned[f])==1]
# assignedCorrectly = {f[1][0]: f[0] for f in assignedCorrectly}
#
# nightLights = nightLights.reset_index()
#
# mapping = pd.DataFrame.from_dict(assignedCorrectly, orient='index')
# mapping = mapping.reset_index()
# mapping.rename(columns={'L2_code': 'L2_name'}, inplace=True)
#
# mapping
# mapping.merge(nightLights2001, on='L2_name')
# l2codes = nightLights2001[['L2_name', 'L2_code']]
# l2codes.drop_duplicates(inplace=True)
#
# l2codes.merge(mapping, on='L2_name')
#
# mapping
#
# nightLights['districtCode'] = np.nan
# nightLights
#
# def helper(x):
#   if x['district'] in assignedCorrectly:
#     x['districtCode'] = nightLights2001[nightLights2001.L2_name.str.match(assignedCorrectly[x.district])].L2_code.iloc[0]
#
# nightLights.districtCode = nightLights.district.apply(lambda x: assignedCorrectly[x] if x in assignedCorrectly else np.nan)
#
# nightLights
# foo
#
# nightLights2011[nightLights2011.L2_name.str.match(assignedCorrectly['UDAIPUR'])].L2_code.iloc[0]
#
# nightLights
#
# nightLights.loc[5670]
#
# nightLights2001[nightLights2001.L2_name.str.contains('Sheohar')].L2_code.iloc[0]
#
# nightLights.reset_index()
#
#

nightLights2001 = pd.read_stata("level_02/IND_night_light_intensity_2001_L2.dta")
total2001 = nightLights2001[nightLights2001.geography=='Total']
total2001.drop(total2001[total2001.id.str.contains('_1$')].index, inplace=True)
total2001.set_index('L2_code', inplace=True)
panel = panel.join(total2001.ntl_pc, rsuffix='_2001')

nightLights2011 = pd.read_stata("level_02/IND_night_light_intensity_2011_L2.dta")
total2011 = nightLights2011[nightLights2011.geography=='Total']
total2011.drop(total2011[total2011.id.str.contains('_1$')].index, inplace=True)
total2011.set_index('L2_code', inplace=True)
panel = panel.join(total2011.ntl_pc, rsuffix='_2011')
panel.rename(columns={'ntl_pc': 'ntl_pc_2001'}, inplace=True)


distGDP = pd.read_stata("level_02/IND_output_2001_L2.dta")
distGDP.drop(index=distGDP[distGDP.id.str.contains('_1$')].index, inplace=True)
distGDP.set_index('L2_code', inplace=True)

panel = panel.join(distGDP.gdp_pc, rsuffix='_2001')

distGDP = pd.read_stata("level_02/IND_output_2011_L2.dta")
distGDP.drop(index=distGDP[distGDP.id.str.contains('_1$')].index, inplace=True)
distGDP['gdp_pc']

panel = panel.join(distGDP.gdp_pc, rsuffix='_2011')

panel.rename(columns={'gdp_pc': 'gdp_pc_2001'}, inplace=True)

density = pd.read_stata("level_02/IND_administrative_2001_L2.dta")

density = density[density.geography == 'Total']
density.sort_values('L2_code', inplace=True)
density.drop(density[density.id.str.contains('_1$')].index, inplace=True)
density.set_index('L2_code', inplace=True)
panel = panel.join(density['dens'], rsuffix='_2001')


density = pd.read_stata("level_02/IND_administrative_2011_L2.dta")

density = density[density.geography == 'Total']
density.sort_values('L2_code', inplace=True)
density.drop(density[density.id.str.contains('_1$')].index, inplace=True)
density.set_index('L2_code', inplace=True)
panel = panel.join(density['dens'], rsuffix='_2011')


panel.rename(columns={'dens': 'dens_2001'}, inplace=True)


sanitation = pd.read_stata("level_02/IND_water_sanitation_2001_L2.dta")
sanitation = sanitation[sanitation.geography == 'Total']
sanitation.sort_values('L2_code', inplace=True)
sanitation.drop(sanitation[sanitation.id.str.contains('_1$')].index, inplace=True)
sanitation.set_index('L2_code', inplace=True)
panel = panel.join(sanitation['hh_snt2_t'], rsuffix='_2001')

sanitation = pd.read_stata("level_02/IND_water_sanitation_2011_L2.dta")
sanitation = sanitation[sanitation.geography == 'Total']
sanitation.sort_values('L2_code', inplace=True)
sanitation.drop(sanitation[sanitation.id.str.contains('_1$')].index, inplace=True)
sanitation.set_index('L2_code', inplace=True)
panel = panel.join(sanitation['hh_snt2_t'], rsuffix='_2011')
panel.rename(columns={'hh_snt2_t': 'hh_snt2_t_2001'}, inplace=True)


sanitation = pd.read_stata("level_02/IND_water_sanitation_2001_L2.dta")
sanitation = sanitation[sanitation.geography == 'Total']
sanitation.sort_values('L2_code', inplace=True)
sanitation.drop(sanitation[sanitation.id.str.contains('_1$')].index, inplace=True)
sanitation.set_index('L2_code', inplace=True)
panel = panel.join(sanitation['hh_wtr_t'], rsuffix='_2001')

sanitation = pd.read_stata("level_02/IND_water_sanitation_2011_L2.dta")
sanitation = sanitation[sanitation.geography == 'Total']
sanitation.sort_values('L2_code', inplace=True)
sanitation.drop(sanitation[sanitation.id.str.contains('_1$')].index, inplace=True)
sanitation.set_index('L2_code', inplace=True)
panel = panel.join(sanitation['hh_wtr_t'], rsuffix='_2011')
panel.rename(columns={'hh_wtr_t': 'hh_wtr_t_2001'}, inplace=True)


literacy = pd.read_stata("level_02/IND_attainment_2001_L2.dta")
literacy = literacy[literacy.geography == 'Total']
literacy.drop(index=literacy[literacy.id.str.contains('_1$')].index, inplace=True)
literacy.set_index(['L2_code'], inplace=True)
panel = panel.join(literacy['edu_lit_7_t'], rsuffix='_2001')


literacy = pd.read_stata("level_02/IND_attainment_2011_L2.dta")
literacy = literacy[literacy.geography == 'Total']
literacy.drop(index=literacy[literacy.id.str.contains('_1$')].index, inplace=True)
literacy.set_index(['L2_code'], inplace=True)
panel = panel.join(literacy['edu_lit_7_t'], rsuffix='_2011')



panel.rename(columns={'edu_lit_7_t': 'edu_lit_7_t_2001',
                      'edu_lit_7_t2011': 'edu_lit_7_t_2011'},
             inplace=True)

composition = pd.read_stata("level_02/IND_social_backgrounds_2001_L2.dta")
composition = composition[composition.geography == 'Total']
composition.drop(index=composition[composition.id.str.contains('_1$')].index, inplace=True)
composition.set_index('L2_code', inplace=True)
composition.sort_values('L2_code')
panel = panel.join(composition[['st', 'sc']], rsuffix='2001')

composition = pd.read_stata("level_02/IND_social_backgrounds_2011_L2.dta")
composition = composition[composition.geography == 'Total']
composition.drop(index=composition[composition.id.str.contains('_1$')].index, inplace=True)
composition.set_index('L2_code', inplace=True)
panel = panel.join(composition[['st', 'sc']], rsuffix='_2011')



panel.rename(columns={'sc': 'sc_2001', 'st': 'st_2001'}, inplace=True)


panel.reset_index(inplace=True)
panel.rename(columns={'index': 'district'}, inplace=True)


export = pd.wide_to_long(panel, stubnames=['central_stem', 'total_stem_inst', 'total_inst',
                                           'total_central_inst', 'batik', 'ntl_pc', 'gdp_pc',
                                           'den', 'hh_snt2_t', 'hh_wtr_t', 'edu_lit_7_t',
                                           'sc', 'st'
                                           ],
                         i = 'district', j = 'year', sep='_')

export.drop(range(640,len(panel)), inplace=True)

export.to_stata('constructedPanel.dta')
