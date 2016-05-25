import csv
from ClassificationMachine import ClassificationMachine
from sklearn.dummy import DummyClassifier
from sklearn.ensemble import RandomForestClassifier


X_train_path = 'features7.npy'
X_test_path = 'features_test7.npy'
Y_path = 'labels7.npy'
ids_test = 'ids_test7.txt'
submission_file = 'submission7.csv'

cls = list()
#cls.append((DummyClassifier(), 'Dummy'))
#cls.append((RandomForestClassifier(n_estimators=10, min_samples_leaf=100, class_weight='balanced', n_jobs=3),
#	       'RF class balanced, min_samples_leaf=100, n_estimators = 10'))
#cls.append((RandomForestClassifier(n_estimators=25, min_samples_leaf=100, class_weight='balanced', n_jobs=3), # 0.643 :)
#	       'RF class balanced, min_samples_leaf=100, n_estimators = 25'))
#cls.append((RandomForestClassifier(n_estimators=50, min_samples_leaf=100, class_weight='balanced', n_jobs=3),
#	       'RF class balanced, min_samples_leaf=100, n_estimators = 50'))
#cls.append((RandomForestClassifier(n_estimators=75, min_samples_leaf=100, class_weight='balanced', n_jobs=3),
#	       'RF class balanced, min_samples_leaf=100, n_estimators = 75'))


#cls.append((RandomForestClassifier(max_features=0.1, n_estimators=25, min_samples_leaf=100, class_weight='balanced', n_jobs=3),
#          'RF class balanced, min_samples_leaf=100, n_estimators = 25, max_features=0.1'))
#cls.append((RandomForestClassifier(max_features=0.25, n_estimators=25, min_samples_leaf=100, class_weight='balanced', n_jobs=3),
#          'RF class balanced, min_samples_leaf=100, n_estimators = 25, max_features=0.25'))
#cls.append((RandomForestClassifier(max_features=0.5, n_estimators=25, min_samples_leaf=100, class_weight='balanced', n_jobs=3),
#          'RF class balanced, min_samples_leaf=100, n_estimators = 25, max_features=0.5'))


#cls.append((RandomForestClassifier(n_estimators=25, max_leaf_nodes=10, class_weight='balanced', n_jobs=3),
#          'RF class balanced, max_leaf_nodes=10, n_estimators = 25'))
#cls.append((RandomForestClassifier(n_estimators=25, max_leaf_nodes=50, class_weight='balanced', n_jobs=3),
#          'RF class balanced, max_leaf_nodes=50, n_estimators = 25'))
#cls.append((RandomForestClassifier(n_estimators=25, max_leaf_nodes=100, class_weight='balanced', n_jobs=3),
#          'RF class balanced, max_leaf_nodes=100, n_estimators = 25'))
#cls.append((RandomForestClassifier(n_estimators=25, max_leaf_nodes=500, class_weight='balanced', n_jobs=3), # 0.651 :)
#          'RF class balanced, max_leaf_nodes=500, n_estimators = 25'))
#cls.append((RandomForestClassifier(n_estimators=25, max_leaf_nodes=1000, class_weight='balanced', n_jobs=3),
#          'RF class balanced, max_leaf_nodes=1000, n_estimators = 25'))

#cls.append((RandomForestClassifier(n_estimators=25, max_leaf_nodes=500, class_weight='balanced', n_jobs=3), # 0.651 :)
#          'RF class balanced, n_estimators = 25'))
#cls.append((RandomForestClassifier(n_estimators=50, max_leaf_nodes=500, class_weight='balanced', n_jobs=3),
#          'RF class balanced, n_estimators = 50'))
#cls.append((RandomForestClassifier(n_estimators=25, max_leaf_nodes=500, class_weight='balanced_subsample', n_jobs=3),
#          'RF class balanced_subsample, n_estimators = 25'))
cls.append((RandomForestClassifier(n_estimators=50, max_leaf_nodes=500, class_weight='balanced_subsample', n_jobs=3),
          'RF class balanced_subsample, n_estimators = 50'))


best_cls = None
best_cls_name = None
best_error = None
for c, name in cls:
    cm = ClassificationMachine(c, X_train_path, X_test_path, Y_path)
    error = cm.cross_validate2()
    print name, error
    
    if best_error is None or error > best_error:
        best_error = error
        best_cls = c
        best_cls_name = name

print best_cls_name, "won!"

cm = ClassificationMachine(best_cls, X_train_path, X_test_path, Y_path)
pred = cm.predict2()

with open(ids_test, 'r') as ids_file:
    with open(submission_file, 'w') as sub_file:
        for nr, row in enumerate(ids_file):
            fullvisitorid, visitid = row.split('_')
            score = str(pred[nr])
            out_row = ','.join([fullvisitorid, visitid[:-1], score])
            sub_file.write(out_row + '\n')


