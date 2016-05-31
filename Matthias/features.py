import numpy as np
import pandas as pd
import datetime
import bitarray


FEATURES = True
FEW_ROWS = False

# Existing columns
COL_DATE = 'date'
COL_HOUR = 'hour'
COL_MINUTE = 'minute'
COL_ACCOUNTID = 'accountId'
COL_FULLVISITORID = 'fullVisitorId'
COL_VISITID = 'visitId'
COL_PAGETYPE = 'pagetype'
COL_PRODUCTID = 'productid'
COL_WEBDOMAIN = 'webshop'
COL_TRANSACTIONID = 'transactionId'
COL_TRAFFICSOURCE1 = 'trafficSource_source'
COL_TRAFFICSOURCE2 = 'trafficSource_medium'
COL_NR_OF_PAGEVIEWS_IN_SESSION = 'totals_pageviews'
COL_SECONDS_SPENT_IN_SESSION = 'totals_timeOnSite'
COL_COUNTRY = 'geoNetwork_country'
COL_BROWSER = 'device_browser'
COL_DEVICE = 'device_deviceCategory'
COL_OS = 'device_operatingSystem'
COL_PRODUCTGROUPID = 'PRODUCTGROUPID'
COL_PRODUCTTYPEID = 'PRODUCTTYPEID'
COL_BRANDID = 'BRANDID'
COL_CUSTOMERID = 'CUSTOMERID'
COL_GENDER = 'GENDER'

# New columns
COL_DATE_DATETYPE = 'date_datetype'
COL_NIGHT = 'night'
COL_MORNING = 'morning'
COL_AFTERNOON = 'afternoon'
COL_EVENING = 'evening'
COL_WEEKEND = 'weekend'
COL_MAY_HOLIDAY = 'mayholiday'
COL_SPRING_HOLIDAY = 'springholiday'
COL_SUMMER_HOLIDAY = 'summerholiday'
COL_FALL_HOLIDAY = 'fallholiday'
COL_CHRISTMAS_HOLIDAY = 'christmasholiday'
COL_KINGSDAY = 'kingsday'
COL_SINTERKLAAS_UPCOMING = 'sinterklaas'
COL_UNIXEPOCH = 'unixepoch'
COL_WEEKDAY = 'weekday'
COL_MONTHDAY = 'monthday'
COL_DAYS_SINCE_25TH = 'dayssince25th'
COL_AVERAGE_SECONDS_PER_PAGE = 'averagesecondsperpage'
COL_CHECKOUT_EVENT = 'checkoutevent'
COL_TRANSACTIONID_PRESENT = 'transactionidpresent'
COL_TRAFFICSOURCE1_BINARY = 'trafficsource1binary'
COL_TRAFFICSOURCE2_BINARY = 'trafficsource2binary'
COL_COUNTRY_BINARY = 'countrybinary'
COL_DEVICE_BINARY = 'devicebinary'
COL_OS_BINARY = 'osbinary'
COL_BROWSER_BINARY = 'browserbinary'
COL_SESSION_NR = 'sessionnumber'


def remove_unknown_gender(df):
    return df[df[COL_GENDER] != '?']


def add_feature_date_datetype(df):
    df[COL_DATE_DATETYPE] = pd.to_datetime(df[COL_DATE], format='%Y%m%d')
    df[COL_DATE] = df[COL_DATE].astype(int)


def add_feature_night(df):
    morning_dict = {0: 1, 1: 1, 2: 1, 3: 1, 4: 1, 5: 1}
    df[COL_NIGHT] = df[COL_HOUR].map(morning_dict)


def add_feature_morning(df):
    morning_dict = {6: 1, 7: 1, 8: 1, 9: 1, 10: 1, 11: 1}
    df[COL_MORNING] = df[COL_HOUR].map(morning_dict)


def add_feature_afternoon(df):
    morning_dict = {12: 1, 13: 1, 14: 1, 15: 1, 16: 1, 17: 1}
    df[COL_AFTERNOON] = df[COL_HOUR].map(morning_dict)


def add_feature_evening(df):
    morning_dict = {18: 1, 19: 1, 20: 1, 21: 1, 22: 1, 23: 1}
    df[COL_EVENING] = df[COL_HOUR].map(morning_dict)


def add_feature_weekend(df):
    weekend_dict = {5: 1, 6: 1}
    df[COL_WEEKEND] = df[COL_DATE_DATETYPE].dt.dayofweek.map(weekend_dict)


def add_feature_spring_holiday(df):
    """
    Add to the provided df whether a pageview in the provided df was in spring holiday (voorjaarsvakantie)
    :param df: The dataframe with the pageviews
    :return: Nothing
    """
    spring_holiday_dict = {7: 1, 8: 1}
    df[COL_SPRING_HOLIDAY] = df[COL_DATE_DATETYPE].dt.week.map(spring_holiday_dict)


def add_feature_may_holiday(df):
    may_holiday_dict = {18: 1, 19: 1}
    df[COL_MAY_HOLIDAY] = df[COL_DATE_DATETYPE].dt.week.map(may_holiday_dict)


def add_feature_summer_holiday(df):
    summer_holiday_dict = {29: 1, 30: 1, 31: 1, 32: 1, 33: 1, 34: 1, 35: 1}
    df[COL_SUMMER_HOLIDAY] = df[COL_DATE_DATETYPE].dt.week.map(summer_holiday_dict)


def add_feature_fall_holiday(df):
    fall_holiday_dict = {43: 1}
    df[COL_FALL_HOLIDAY] = df[COL_DATE_DATETYPE].dt.week.map(fall_holiday_dict)


def add_feature_christmas_holiday(df):
    christmas_holiday_dict = {51: 1, 52: 1, 53: 1}
    df[COL_CHRISTMAS_HOLIDAY] = df[COL_DATE_DATETYPE].dt.week.map(christmas_holiday_dict)


def add_feature_kingsday(df):
    kingsday_dict = {116: 1}
    df[COL_KINGSDAY] = df[COL_DATE_DATETYPE].dt.dayofyear.map(kingsday_dict)


def add_feature_sinterklaas(df):
    sinterklaas_dict = {334: 1, 335: 1, 336: 1, 337: 1, 338: 1}
    df[COL_SINTERKLAAS_UPCOMING] = df[COL_DATE_DATETYPE].dt.dayofyear.map(sinterklaas_dict)


def add_feature_unixepoch(df):
    df[COL_UNIXEPOCH] = (df[COL_DATE_DATETYPE] - datetime.datetime(1970, 1, 1)) / np.timedelta64(1, 's')


def add_feature_weekday(df):
    df[COL_WEEKDAY] = df[COL_DATE_DATETYPE].dt.dayofweek


def add_feature_monthday(df):
    df[COL_MONTHDAY] = df[COL_DATE_DATETYPE].dt.day


def add_feature_dayssince25th(df):
    dayssince25th_dict = {1: 6, 2: 7, 3: 8, 4: 9, 5: 10, 6: 11, 7: 12, 8: 13, 9: 14, 10: 15, 11: 16, 12: 17, 13: 18,
                          14: 19, 15: 20, 16: 21, 17: 22, 18: 23, 19: 24, 20: 25, 21: 26, 22: 27, 23: 28, 24: 29, 25: 0,
                          26: 1, 27: 2, 28: 3, 29: 4, 30: 5, 31: 6}
    df[COL_DAYS_SINCE_25TH] = df[COL_DATE_DATETYPE].dt.day.map(dayssince25th_dict)


def add_feature_average_seconds_per_page(df):
    df[COL_AVERAGE_SECONDS_PER_PAGE] = df[COL_SECONDS_SPENT_IN_SESSION] / df[COL_NR_OF_PAGEVIEWS_IN_SESSION]


def add_feature_checkout_event(df):
    checkout_event_dict = {'Winkelmandje': 1}
    df[COL_CHECKOUT_EVENT] = df[COL_PAGETYPE].map(checkout_event_dict)


def add_feature_transactionid_present(df):
    df[COL_TRANSACTIONID_PRESENT] = df[COL_TRANSACTIONID] is not None


def add_feature_session_number(df):
    df[COL_SESSION_NR] = df[COL_FULLVISITORID].astype(str) + df[COL_VISITID].astype(str)


def add_feature_binaries(df):
    """
    Add binary strings for columns. Collect all such columns in one method to prevent going over the dataframe multiple times

    :param df: The dataframe to add features to
    :return: The dataframe with features added
    """
    # Create placeholders
    df[COL_TRAFFICSOURCE1_BINARY] = ''
    df[COL_TRAFFICSOURCE2_BINARY] = ''
    df[COL_COUNTRY_BINARY] = ''
    df[COL_DEVICE_BINARY] = ''
    df[COL_OS_BINARY] = ''
    df[COL_BROWSER_BINARY] = ''

    # Create empty bitarray object
    ba = bitarray.bitarray()

    # Set feature values for all placeholders
    for index, row in df.iterrows():
        # Create  bitstring representation of the source string
        ba.fromstring(row[COL_TRAFFICSOURCE1])
        df.set_value(index, COL_TRAFFICSOURCE1_BINARY, ba.to01())

        # For some inexplicable reason, some values in this column are read as float even though there are values in
        # the source data. It thus requires a cast to string
        ba.fromstring(str(row[COL_TRAFFICSOURCE2]))
        df.set_value(index, COL_TRAFFICSOURCE2_BINARY, ba.to01())

        ba.fromstring(row[COL_COUNTRY])
        df.set_value(index, COL_COUNTRY_BINARY, ba.to01())

        ba.fromstring(row[COL_DEVICE])
        df.set_value(index, COL_DEVICE_BINARY, ba.to01())

        ba.fromstring(row[COL_OS])
        df.set_value(index, COL_OS_BINARY, ba.to01())

        ba.fromstring(row[COL_BROWSER])
        df.set_value(index, COL_BROWSER_BINARY, ba.to01())


def remove_unusable_features(df):
    return df.drop([COL_ACCOUNTID, COL_DATE_DATETYPE, COL_TRANSACTIONID, COL_CUSTOMERID], 1)


def get_series_ids(x):
    """Function returns a pandas series consisting of ids,
       corresponding to objects in input pandas series x
       Example:
       get_series_ids(pd.Series(['a','a','b','b','c']))
       returns Series([0,0,1,1,2], dtype=int)"""

    values = pd.unique(x.astype(str))
    values2nums = dict(zip(values, range(len(values))))
    return x.replace(values2nums)


if __name__ == "__main__":
    if FEW_ROWS:
        test_dataframe = pd.read_csv('..\data\kaggle.test.txt', nrows=100)
        training_dataframe = pd.read_csv('..\data\kaggle.training.txt', nrows=100)
        dataframe = pd.concat([test_dataframe, training_dataframe])
    else:
        test_dataframe = pd.read_csv('..\data\kaggle.test.txt')
        training_dataframe = pd.read_csv('..\data\kaggle.training.txt')
        dataframe = pd.concat([test_dataframe, training_dataframe])

        dataframe = remove_unknown_gender(dataframe)

    add_feature_date_datetype(dataframe)
    if FEATURES:
        add_feature_night(dataframe)
        add_feature_morning(dataframe)
        add_feature_afternoon(dataframe)
        add_feature_evening(dataframe)
        add_feature_weekend(dataframe)
        add_feature_may_holiday(dataframe)
        add_feature_spring_holiday(dataframe)
        add_feature_summer_holiday(dataframe)
        add_feature_fall_holiday(dataframe)
        add_feature_christmas_holiday(dataframe)
        add_feature_kingsday(dataframe)
        add_feature_sinterklaas(dataframe)

        add_feature_unixepoch(dataframe)
        add_feature_weekday(dataframe)
        add_feature_monthday(dataframe)
        add_feature_dayssince25th(dataframe)
        add_feature_average_seconds_per_page(dataframe)
        add_feature_checkout_event(dataframe)
        add_feature_transactionid_present(dataframe)

    # Clean the data for further use by the classifiers
    dataframe[COL_PAGETYPE] = get_series_ids(dataframe[COL_PAGETYPE])
    dataframe[COL_WEBDOMAIN] = get_series_ids(dataframe[COL_WEBDOMAIN])
    dataframe[COL_TRAFFICSOURCE1] = get_series_ids(dataframe[COL_TRAFFICSOURCE1])
    dataframe[COL_TRAFFICSOURCE2] = get_series_ids(dataframe[COL_TRAFFICSOURCE2])
    dataframe[COL_COUNTRY] = get_series_ids(dataframe[COL_COUNTRY])
    dataframe[COL_DEVICE] = get_series_ids(dataframe[COL_DEVICE])
    dataframe[COL_OS] = get_series_ids(dataframe[COL_OS])
    dataframe[COL_BROWSER] = get_series_ids(dataframe[COL_BROWSER])

    dataframe = dataframe.fillna(0)

    dataframe = remove_unusable_features(dataframe)

    test_dataframe = dataframe[dataframe[COL_GENDER] == 0].drop([COL_GENDER], 1)
    training_dataframe = dataframe[dataframe[COL_GENDER] != 0]

    # Store the usable data in a numpy array
    test_dataframe.to_csv('..\data\kaggle.{0}{1}{2}.csv'.format('test', '.features' if FEATURES else '.nofeatures', '.fewrows' if FEW_ROWS else ''), index=False)
    training_dataframe.to_csv('..\data\kaggle.{0}{1}{2}.csv'.format('training', '.features' if FEATURES else '.nofeatures', '.fewrows' if FEW_ROWS else ''), index=False)



