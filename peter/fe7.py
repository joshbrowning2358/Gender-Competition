# Feature engineering 2:
# Session: country
# First day of month, day of week, hour, minute
# Was there a transaction (binary)
# Rough percentile of: pageviews, timeOnSite, average time per page
# Count how often pages with producttypes have been seen. One column per producttype.
# Same with webshop, brand, productgroup
# Same with pagetype and trafficsource_medium (top 14 and 15)

import scipy.stats
import numpy as np
import datetime
import io

TRAIN_CSV = 'competition.csv'
TEST_CSV = 'competition_test.csv'
FEATURES_NP = 'features7.npy'
FEATURES_TEST_NP = 'features_test7.npy'
IDS_TEST_NP = 'ids_test7.txt'
LABELS_NP = 'labels7.npy'

n_manual_features = 9

def now():
    return datetime.datetime.now()

def lowest_except_0(old, new):
    return min(old, new) if old != 0 else new

print now(), "Starting"
# Create a list of all producttypes in the data
seen_producttypes = set()
seen_fullvisitor_visitids = set()
seen_webshops = set()
seen_brandids = set()
seen_productgroupids = set()
timePerPages = []

with open(TRAIN_CSV, 'r') as in_file:
    for line in in_file:
       line_split = line.split(';')

       gender = line_split[22][0]
       if gender not in ('M','F'):
           continue

       producttype = int(line_split[19])
       seen_producttypes.add(producttype)

       fullvisitor_visitid = line_split[4] + '_' + line_split[5]
       seen_fullvisitor_visitids.add(fullvisitor_visitid)

       webshop = line_split[8]
       seen_webshops.add(webshop)

       brandid = int(line_split[20])
       seen_brandids.add(brandid)

       productgroupid = int(line_split[18])
       seen_productgroupids.add(productgroupid)

print now(), "Building dicts and lists"
seen_trafficsourcemediums = set(['cpm', 'Banner', 'wheretobuy', 'video_review', 'URL', 'mail', 'Affiliate', 'referral', 'retargeting', 'pricecomparison', '(none)', 'email', 'organic', 'cpc'])
seen_trafficsourcemediums_sorted = sorted(seen_trafficsourcemediums)
seen_trafficsourcemediums_indexes = {pt:idx for idx, pt in enumerate(seen_trafficsourcemediums_sorted)}
n_seen_trafficsourcemediums = len(seen_trafficsourcemediums) + 1 # For unknown

seen_pagetypes = set(['download', 'abonnementsvorm', 'abonnementaanbiedingen', 'kassakoopje', 'productvideo', 'activemailer', 'product-met-abonnement', 'vragen', 'accessoires', 'abonnement-kiezen', 'accessoire', 'vergelijken', 'product-reviews', 'category', 'product'])
seen_pagetypes_sorted = sorted(seen_pagetypes)
seen_pagetypes_indexes = {pt:idx for idx, pt in enumerate(seen_pagetypes_sorted)}
n_seen_pagetypes = len(seen_pagetypes) + 1 # For unknown

seen_producttypes_sorted = sorted(seen_producttypes)
seen_producttypes_indexes = {pt:idx for idx, pt in enumerate(seen_producttypes_sorted)}
n_seen_producttypes = len(seen_producttypes)

seen_fullvisitor_visitids_sorted = sorted(seen_fullvisitor_visitids)
seen_fullvisitor_visitids_indexes = {pt:idx for idx, pt in enumerate(seen_fullvisitor_visitids_sorted)}
n_seen_fullvisitor_visitids = len(seen_fullvisitor_visitids)

seen_webshops_sorted = sorted(seen_webshops)
seen_webshops_indexes = {pt:idx for idx, pt in enumerate(seen_webshops_sorted)}
n_seen_webshops = len(seen_webshops)

seen_brandids_sorted = sorted(seen_brandids)
seen_brandids_indexes = {pt:idx for idx, pt in enumerate(seen_brandids_sorted)}
n_seen_brandids = len(seen_brandids)

seen_productgroupids_sorted = sorted(seen_productgroupids)
seen_productgroupids_indexes = {pt:idx for idx, pt in enumerate(seen_productgroupids_sorted)}
n_seen_productgroupids = len(seen_productgroupids)

n_features = n_manual_features + n_seen_producttypes + n_seen_webshops\
    + n_seen_brandids + n_seen_productgroupids + n_seen_trafficsourcemediums + n_seen_pagetypes

print now(), "Creating matrix"
print n_seen_fullvisitor_visitids, n_features
print n_seen_producttypes, n_seen_webshops, n_seen_brandids, n_seen_productgroupids, n_seen_trafficsourcemediums, n_seen_pagetypes
# Count per session, create two files: features, target
features = np.zeros((n_seen_fullvisitor_visitids, n_features), dtype='uint8', order='F')
labels = np.zeros((n_seen_fullvisitor_visitids), dtype='uint8', order='F')

print now(), "Filling matrix"
with io.open(TRAIN_CSV, mode='r', encoding="utf-8-sig") as in_file:
    for line in in_file:
       line_split = line.split(';')

       date_raw, hour, minute = line_split[0], int(line_split[1]), int(line_split[2])
       year, month, day_of_month = int(date_raw[:4]), int(date_raw[4:6]), int(date_raw[-2:])
       date_obj = datetime.date(year, month, day_of_month)
       day_of_week = date_obj.weekday()

       pageviews_raw = 1 if line_split[12] == 'NULL' else int(line_split[12])
       pageviews = pageviews_raw/2
       timeOnSite_raw = 1 if line_split[13] == 'NULL' else int(line_split[13])
       timeOnSite = timeOnSite_raw/35
       timePerPage = float(timeOnSite_raw)/pageviews_raw
       timePerPagePercentile = min(int(timePerPage), 254)

       country = 1 if line_split[14] == 'Belgium' else 0
       transaction = 1 if line_split[9] != 'NULL' else 0

       pagetype = line_split[6]
       webshop = line_split[8]
       trafficsourcemedium = line_split[11]
       brandid = int(line_split[20])

       productgroupid = int(line_split[18])
       producttype = int(line_split[19])
       fullvisitor_visitid = line_split[4] + '_' + line_split[5]

       gender = line_split[22][0]
       if gender not in ('M','F'):
           continue
       gender_enc = 1 if gender == 'M' else 0

       row = seen_fullvisitor_visitids_indexes[fullvisitor_visitid]

       col = n_manual_features + seen_producttypes_indexes[producttype]
       features[row, col] += 1

       col = n_manual_features + n_seen_producttypes + seen_webshops_indexes[webshop]
       features[row, col] += 1

       col = n_manual_features + n_seen_producttypes + n_seen_webshops + seen_brandids_indexes[brandid]
       features[row, col] += 1

       col = n_manual_features + n_seen_producttypes + n_seen_webshops + n_seen_brandids + seen_productgroupids_indexes[productgroupid]
       features[row, col] += 1

       col = n_manual_features + n_seen_producttypes + n_seen_webshops + n_seen_brandids + n_seen_productgroupids
       if trafficsourcemedium in seen_trafficsourcemediums:
           col += seen_trafficsourcemediums_indexes[trafficsourcemedium]
           features[row, col] += 1
       else:
           col += n_seen_trafficsourcemediums-1
           features[row, col] += 1

       col = n_manual_features + n_seen_producttypes + n_seen_webshops + n_seen_brandids + n_seen_productgroupids + n_seen_trafficsourcemediums
       if pagetype in seen_pagetypes:
           col += seen_pagetypes_indexes[pagetype]
           features[row, col] += 1
       else:
           col += n_seen_pagetypes-1
           features[row, col] += 1


       features[row, 0] = min(pageviews, 254)
       features[row, 1] = min(timeOnSite, 254)
       features[row, 2] = country
       features[row, 3] = day_of_month
       features[row, 4] = day_of_week
       features[row, 5] = lowest_except_0(features[row, 5], hour)
       features[row, 6] = lowest_except_0(features[row, 6], minute)
       features[row, 7] = timePerPagePercentile
       features[row, 8] = max(features[row, 8], transaction) # Ergens een transactie is hele sessie een transactie

       labels[row] = gender_enc

print now(), "Writing out train matrixes"
np.save(open(FEATURES_NP, 'wb'), features)
np.save(open(LABELS_NP, 'wb'), labels)


#exit()
print now(), "Starting on testset"
seen_fullvisitor_visitids = set()
with open(TEST_CSV, 'r') as in_file:
    for line in in_file:
       line_split = line.split(';')

       fullvisitor_visitid = line_split[3] + '_' + line_split[4]
       seen_fullvisitor_visitids.add(fullvisitor_visitid)

seen_fullvisitor_visitids_sorted = sorted(seen_fullvisitor_visitids)
seen_fullvisitor_visitids_indexes = {pt:idx for idx, pt in enumerate(seen_fullvisitor_visitids_sorted)}
n_seen_fullvisitor_visitids = len(seen_fullvisitor_visitids)

print now(), "Creating test matrix"
print n_seen_fullvisitor_visitids, n_features
print n_seen_producttypes, n_seen_webshops, n_seen_brandids, n_seen_productgroupids, n_seen_trafficsourcemediums, n_seen_pagetypes
features = np.zeros((n_seen_fullvisitor_visitids, n_features), dtype='uint8', order='F')

print now(), "Filling test matrix"
with io.open(TEST_CSV, mode='r', encoding="utf-8-sig") as in_file:
    for line in in_file:
       line_split = line.split(';')

       date_raw, hour, minute = line_split[0], int(line_split[1]), int(line_split[2])
       year, month, day_of_month = int(date_raw[:4]), int(date_raw[4:6]), int(date_raw[-2:])
       date_obj = datetime.date(year, month, day_of_month)
       day_of_week = date_obj.weekday()

       pageviews_raw = 1 if line_split[11] == 'NULL' else int(line_split[11])
       pageviews = pageviews_raw/2
       timeOnSite_raw = 1 if line_split[12] == 'NULL' else int(line_split[12])
       timeOnSite = timeOnSite_raw/35
       timePerPage = float(timeOnSite_raw)/pageviews_raw
       timePerPagePercentile = min(int(timePerPage), 254)

       country = 1 if line_split[13] == 'Belgium' else 0
       transaction = 1 if line_split[9] != 'NULL' else 0
       
       pagetype = line_split[5]
       webshop = line_split[7]
       trafficsourcemedium = line_split[10]
       brandid = int(line_split[19])

       productgroupid = int(line_split[17])
       producttype = int(line_split[18])
       fullvisitor_visitid = line_split[3] + '_' + line_split[4]

       row = seen_fullvisitor_visitids_indexes[fullvisitor_visitid]
       
       if producttype in seen_producttypes:
           col = n_manual_features + seen_producttypes_indexes[producttype]
           features[row, col] += 1

       if webshop in seen_webshops:
           col = n_manual_features + n_seen_producttypes + seen_webshops_indexes[webshop]
           features[row, col] += 1

       if brandid in seen_brandids:
           col = n_manual_features + n_seen_producttypes + n_seen_webshops + seen_brandids_indexes[brandid]
           features[row, col] += 1

       if productgroupid in seen_productgroupids:
           col = n_manual_features + n_seen_producttypes + n_seen_webshops + n_seen_brandids + seen_productgroupids_indexes[productgroupid]
           features[row, col] += 1

       col = n_manual_features + n_seen_producttypes + n_seen_webshops + n_seen_brandids + n_seen_productgroupids
       if trafficsourcemedium in seen_trafficsourcemediums:
           col += seen_trafficsourcemediums_indexes[trafficsourcemedium]
           features[row, col] += 1
       else:
           col += n_seen_trafficsourcemediums-1
           features[row, col] += 1

       col = n_manual_features + n_seen_producttypes + n_seen_webshops + n_seen_brandids + n_seen_productgroupids + n_seen_trafficsourcemediums
       if pagetype in seen_pagetypes:
           col += seen_pagetypes_indexes[pagetype]
           features[row, col] += 1
       else:
           col += n_seen_pagetypes-1
           features[row, col] += 1

       features[row, 0] = min(pageviews, 254)
       features[row, 1] = min(timeOnSite, 254)
       features[row, 2] = country
       features[row, 3] = day_of_month
       features[row, 4] = day_of_week
       features[row, 5] = lowest_except_0(features[row, 5], hour)
       features[row, 6] = lowest_except_0(features[row, 6], minute)
       features[row, 7] = timePerPagePercentile
       features[row, 8] = max(features[row, 8], transaction) # Ergens een transactie is hele sessie een transactie

print now(), "Writing out test matrixes"
np.save(open(FEATURES_TEST_NP, 'wb'), features)

with io.open(IDS_TEST_NP, mode='w') as out_file:
    for fullvisitor_visitid in seen_fullvisitor_visitids_sorted:
        out_file.write(unicode(fullvisitor_visitid + '\n'))
