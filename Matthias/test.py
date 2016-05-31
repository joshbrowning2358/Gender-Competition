import sklearn.neighbors
import sklearn.tree
import sklearn.ensemble
import sklearn.svm
from KaggleCompetitionMachine import KaggleCompetitionMachine
from sklearn.linear_model import SGDClassifier

training_data_path = '..\data\kaggle.training.features.csv'
test_data_path = '..\data\kaggle.test.features.csv'
results_path = '..\data\\results_{0}.csv'

#classifier = sklearn.neighbors.KNeighborsClassifier(n_jobs=3)
#classifier = sklearn.tree.DecisionTreeClassifier()
#classifier = sklearn.ensemble.AdaBoostClassifier()
#classifier = sklearn.ensemble.RandomForestClassifier(n_jobs=3)


classifiers = [#SGDClassifier(loss='log')
     #sklearn.neighbors.KNeighborsClassifier(n_jobs=3, n_neighbors=7)
               #,sklearn.tree.DecisionTreeClassifier()
               sklearn.ensemble.RandomForestClassifier(n_jobs=3)
              ]


for classifier in classifiers:
    KCM = KaggleCompetitionMachine(classifier, x_train_path=training_data_path, x_test_path=test_data_path, results_path=results_path.format(type(classifier).__name__))
    KCM.run()
