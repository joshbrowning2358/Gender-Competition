import numpy as np
import sklearn.preprocessing
import sklearn.cross_validation
import sklearn.metrics


class PredictionMachine(object):
    # This class reads X feature matrix and Y target vector in
    # Creates an 5x2 fold on the dataset
    # Trains and runs a classifier supplied in the init
    # Returns the error
    
    def __init__(self, classifier, features_path, labels_path):
        self.cls = classifier
        self.X_path = features_path
        self.Y_path = labels_path
        self.X = None
        self.Y = None
            
    def run(self):
        self.read_data()
        cf = self.create_folds()
        
        print(type(self.cls))
        for train_idx, test_idx in cf:
            x_train, y_train = self.X[train_idx], self.Y[train_idx]
            x_test,  y_test = self.X[test_idx], self.Y[test_idx]
            
            self.cls.fit(x_train, y_train)
            y_result = self.cls.predict(x_test)  # predict_proba

            self.print_error(y_result, y_test, self.cls.classes_)
    
    def read_data(self):
        self.X = np.load(self.X_path)
        self.Y = np.load(self.Y_path)
    
    def create_folds(self):
        # 5x2 folds
        folds = sklearn.cross_validation.ShuffleSplit(
             n=self.X.shape[0], n_iter=5, train_size=0.5, test_size=0.5)
        
        return folds

    @staticmethod
    def print_error(y_prob, y_test, classes_):
        lb = sklearn.preprocessing.LabelBinarizer()
        lb.fit(list(classes_))
        lb.classes_ = classes_
        y_test_matrix = lb.transform(y_test)
        y_prob_matrix = lb.transform(y_prob)

        ll = sklearn.metrics.roc_auc_score(y_test_matrix, y_prob_matrix)
        print(ll)
