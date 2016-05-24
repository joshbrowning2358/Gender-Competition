import numpy as np
import sklearn.preprocessing
import sklearn.cross_validation
import sklearn.metrics

class ClassificationMachine(object):
    
    def __init__(self, classifier, features_train_path,
                 features_test_path, labels_path):
        self.cls = classifier
        self.X1_path = features_train_path
        self.X2_path = features_test_path
        self.Y_path = labels_path
        self.errors = []
        self.read_data()

    def cross_validate(self):
        cf = self.create_folds()
        
        for train_idx, test_idx in cf:
            X_train, Y_train = self.X1[train_idx], self.Y[train_idx]
            X_test,  Y_test  = self.X1[test_idx], self.Y[test_idx]
            
            self.cls.fit(X_train, Y_train)
            Y_pred = self.cls.predict(X_test)
            
            self.determine_error(Y_pred, Y_test)
        
        return float(sum(self.errors))/len(self.errors)
    
    def cross_validate2(self):
        cf = self.create_folds()
        
        for train_idx, test_idx in cf:
            X_train, Y_train = self.X1[train_idx], self.Y[train_idx]
            X_test,  Y_test  = self.X1[test_idx], self.Y[test_idx]
            
            self.cls.fit(X_train, Y_train)
            Y_pred = self.cls.predict_proba(X_test)
            classes = self.cls.classes_

            self.determine_error2(Y_pred, Y_test, classes)
        
        return float(sum(self.errors))/len(self.errors)

    def read_data(self):
        self.X1 = np.load(self.X1_path)
        self.X2 = np.load(self.X2_path)
        self.Y = np.load(self.Y_path)
    
    def create_folds(self):
        folds = sklearn.cross_validation.ShuffleSplit(
             n=self.X1.shape[0], n_iter=5, train_size=0.25, test_size=0.25)
        
        return folds

    def determine_error(self, Y_pred, Y_test):
        err = sklearn.metrics.roc_auc_score(Y_test, Y_pred)
        print err
        self.errors.append(err)

    def determine_error2(self, Y_pred, Y_test, classes):
        if classes[0] == 0:
            Y_score = Y_pred[:,1]
        else:
            Y_score = Y_pred[:,0]

        err = sklearn.metrics.roc_auc_score(Y_test, Y_score)
        print err
        self.errors.append(err)

    def predict(self):
        self.cls.fit(self.X1, self.Y)
        pred = self.cls.predict(self.X2)
        return pred

    def predict2(self):
        self.cls.fit(self.X1, self.Y)
        Y_pred = self.cls.predict_proba(self.X2)
        classes = self.cls.classes_
        if classes[0] == 1:
            Y_score = Y_pred[:,1]
        else:
            Y_score = Y_pred[:,0]
        
        return Y_score