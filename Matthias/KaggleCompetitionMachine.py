import pandas as pd
from sklearn.kernel_approximation import RBFSampler

COL_FULLVISITORID = 'fullVisitorId'
COL_VISITID = 'visitId'
COL_GENDER = 'GENDER'
COL_SIZE = 'size'
COL_MAX = 'max'


class KaggleCompetitionMachine(object):
    def __init__(self, classifier, x_train_path, x_test_path, results_path):
        self.cls = classifier
        self.x_train_path = x_train_path
        self.x_test_path = x_test_path
        self.results_path = results_path
        self.x_train = None
        self.x_test = None

    def run(self):
        print('Reading data')
        self.read_data()
        print('Read')

        # Remove fullvisitorid and visitid, they don't add value for the classification
        print('Cleaning data')
        training_data = self.x_train.drop([COL_FULLVISITORID, COL_VISITID], axis=1)
        test_data = self.x_test.drop([COL_FULLVISITORID, COL_VISITID], axis=1)
        print('Cleaned')

        # Apply kernel approximation for better linear separability
        #print('Preparing data')
        #rbf_feature = RBFSampler(gamma=1, random_state=1)
        #training_data = pd.DataFrame(rbf_feature.fit_transform(training_data))
        #test_data = pd.DataFrame(rbf_feature.fit_transform(test_data))
        #print('Prepared')

        print('Training to classify gender')
        self.cls.fit(training_data.drop([COL_GENDER], 1), training_data[COL_GENDER])
        print('Trained')

        print('Classifying gender')
        y_result = self.cls.predict_proba(test_data)
        y_result = pd.DataFrame(y_result)
        y_result = pd.DataFrame(y_result[1])
        #y_result = pd.DataFrame(1 - y_result[1])  # 0 is 100% chance of man, 1 is 100% chance of woman. predict_proba does the other way
        y_result.columns = [COL_GENDER]
        print('Classified')

        print('Aggregating to session')
        result = self.aggregate_to_session(self.x_test, y_result)
        print('Aggregated')

        print('Writing to file')
        result.to_csv(self.results_path, float_format='%.5f', encoding='utf-8', index=False)
        print('Written')

    def read_data(self):
        self.x_train = pd.read_csv(self.x_train_path)
        self.x_test = pd.read_csv(self.x_test_path)

    def aggregate_to_session(self, test_data, predicted_labels):
        # Get only fullvisitorid and visitid
        test_data_filtered = pd.concat([test_data[COL_FULLVISITORID], test_data[COL_VISITID]], axis=1)
        # Add the predicted labels
        combined = pd.concat([test_data_filtered, predicted_labels], axis=1)

        # Aggregate by taking average over the probabilities
        aggregated_average_gender = pd.DataFrame({COL_GENDER: combined.groupby([COL_FULLVISITORID, COL_VISITID], sort=False)[COL_GENDER].mean()}).reset_index()
        return aggregated_average_gender

        # Aggregate by counting distinct combinations of fullvisitorid, visitid and gender
        # aggregated_count_gender = pd.DataFrame({COL_SIZE: combined.groupby([COL_FULLVISITORID, COL_VISITID, COL_GENDER], sort=False).size()}).reset_index()

        # Aggregate by taking only the max count
        # filtered_only_max = pd.DataFrame({COL_MAX: aggregated_count_gender.groupby([COL_FULLVISITORID, COL_VISITID, COL_GENDER], sort=False)[COL_SIZE].max()}).reset_index()
        # Aggregate by taking only the min gender probability in case of double counts. Min, because that puts male in favor
        # filtered_min_prob = pd.DataFrame({COL_GENDER: filtered_only_max.groupby([COL_FULLVISITORID, COL_VISITID], sort=False)[COL_GENDER].min()}).reset_index()
        # return filtered_min_prob
