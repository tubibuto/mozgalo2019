import pandas as pd
import numpy as np
from matplotlib import pyplot
from sklearn import metrics
from sklearn.model_selection import train_test_split
import xgboost as xgb
from xgboost import XGBClassifier
from xgboost import Booster
from sklearn.feature_selection import RFE
from sklearn.preprocessing import LabelEncoder

def read_data (file_name):
    data = pd.read_csv (file_name)
    columns = data.columns
    print(columns)    
    
    return data, columns

def preprocess_data (data_frame, cat_columns, num_columns, bad_columns, target_column):
    df = data_frame.drop(bad_columns, axis = 1)
    y = df[target_column].apply(lambda x: int(x == 'Y'))
    df.drop([target_column], axis = 1, inplace = True)
    features = cat_columns + num_columns
    X = pd.get_dummies(df[features], columns = cat_columns)
    
    return X, y, X.columns

def train_model (model, X, y, test_size = 0.3, random_state = 0): 
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=7)
    
    eval_set = [(X_train, y_train), (X_test, y_test)]
    model.fit (X_train, y_train, eval_metric = "error", eval_set = eval_set, verbose = True)

    y_pred = model.predict(X_test)  
    acc = metrics.accuracy_score(y_test, y_pred)
    print("Accuracy:", acc)
    
    return model, y_pred

def run_train (X, y, X2, y2):
    print("Training models...")
    
    params = {'learning_rate': 1.5, 'max_depth' : 10, 'n_estimators' : 200}
    params2 = {'learning_rate': 1.5, 'max_depth' : 10, 'n_estimators' : 3}  
    
    # this model will be predicting results for data
    # with PLANIRANI_DATUM_ZATVARANJA before 20/04/2019
    model = XGBClassifier(**params)
    model, y_pred = train_model (model, X, y)
    
    # this model will be predicting results for data
    # with PLANIRANI_DATUM_ZATVARANJA after 20/04/2019
    model2 = XGBClassifier(**params2)
    model2, y_pred2 = train_model (model2, X2, y2)
    
    return model, model2

# util method which loads model from file which holds its internal paramters
def load_model_from_file (file_name):
    model = XGBClassifier()
    booster = Booster()
    booster.load_model(file_name)
    model._Booster = booster
    model._le = LabelEncoder().fit(['0', '1'])
    
    return model
        
# this is mainly used if there is any dummy category missing
# in this case we just fill them with 0s
def handle_diffs (train, test):
    dif_list1 = list(set(list(train.columns)) - set(list(test.columns)))
    dif_list2 = list(set(list(test.columns)) - set(list(train.columns)))
    test.drop(dif_list2, axis = 1, inplace = True)
    ret = pd.DataFrame (columns = train.columns, index = test.index)
    ret[list(test.columns)] = test
    ret[dif_list1] = 0
    
    return ret

def to_target (x):
    return 'Y' if x == 1 else 'N'

def run_validation (categories, features, features2, X, X2, model = None, model2 = None):
    # loading models if none is provided
    if model == None:
        print("Loading 1st model...")
        model = load_model_from_file("Models/best_evaaa_undersample_merge.model")
    
    if model2 == None:
        print("Loading 2nd model...")
        model2 = load_model_from_file("Models/best_evaaa_latest_dates.model")
    
    print("Running validation...")
    # loading processed file on which we run given model's predictions
    validation_set = pd.read_csv("D:/Mozgalo2019/validation_set_prepared_extended_merge.csv")
    validation_set = validation_set.drop(['KLIJENT_ID', 'OZNAKA_PARTIJE', 'Unnamed: 0', 'X', 'Unnamed: 0.1' , 'instance_id'], axis = 1)
    validation_set = validation_set.drop(['PRIJEVREMENI_RASKID'], axis = 1)
    
    # running predictions of 1st model
    # (for samples with PLANIRANI_DATUM_ZATVARANJA before 20/04/2019)
    prepared_validation_set = validation_set.drop(list(set(validation_set.columns) - (set(features) | set(['VALUTA', 'VRSTA_KLIJENTA', 'PROIZVOD', 'TIP_KAMATE', 'VRSTA_PROIZVODA']))), axis = 1)
    prepared_validation_set = pd.get_dummies(validation_set, columns = categories)
    prepared_validation_set = handle_diffs (X, prepared_validation_set)
    eva = model.predict(prepared_validation_set)
    predictions = np.zeros(len(prepared_validation_set), dtype = int)
    predictions[:] = eva
    print("  Y/N ratio on 1st model: " + str(sum(predictions) / len(predictions)))
    
    # running predictions of 2nd model
    # (for samples with PLANIRANI_DATUM_ZATVARANJA after 20/04/2019)
    prepared_validation_set = validation_set.drop(list(set(validation_set.columns) - (set(features2) | set(['VALUTA', 'VRSTA_KLIJENTA', 'PROIZVOD', 'TIP_KAMATE', 'VRSTA_PROIZVODA']))), axis = 1)
    prepared_validation_set = pd.get_dummies(validation_set, columns = categories)
    prepared_validation_set = handle_diffs (X2, prepared_validation_set)
    pl_dat = validation_set["PLANIRANI_DATUM_ZATVARANJA"] > 18006
    eva2 = model2.predict(prepared_validation_set.loc[pl_dat])
    predictions[pl_dat] = eva2
    print("  Y no. on 2nd model: " + str(sum(predictions[pl_dat])))
    
    # writing results into submission file
    print("Writing results into submission file...")
    codalab_original = pd.read_excel("D:/Mozgalo2019/eval_dataset_nan.xlsx")
    codalab_original["PRIJEVREMENI_RASKID"] = pd.Series(predictions).apply(to_target)
    codalab_original.to_csv("D:/Mozgalo2019/student.csv")

# entrypoint method of program
def main (load_models = False):
    # loading training set
    print("Loading training set...")
    file_name = 'D:/Mozgalo2019/training_set_economy_features_extended_undersampled.csv'
    data, columns = read_data (file_name)
    
    # setting categorical, numerical and unnecessary features for both models
    print("Preprocessing training data...")
    categories = ['VALUTA', 'VRSTA_KLIJENTA', 'PROIZVOD', 'TIP_KAMATE', 'VRSTA_PROIZVODA'] 
    bad_cols = ['KLIJENT_ID', 'OZNAKA_PARTIJE', 'Unnamed: 0', 'Unnamed: 0.1']
    target_col = 'PRIJEVREMENI_RASKID'
    numericals = ['DATUM_OTVARANJA', 'PLANIRANI_DATUM_ZATVARANJA', 'UGOVORENI_IZNOS', 'VISINA_KAMATE', 'STAROST',
           'RAST_BDPA_U_GODINI_OTVARANJA', 'RAST_BDPA_U_GODINI_ZATVARANJA',
           'MAX_RAST_BDP', 'MIN_RAST_BDP', 'NUM_PARTIJA', 'NUM_PARTIJA_A', 'NUM_PARTIJA_L',
           'DULJINA_PARTIJE', 'KLIJENT_UKUPNI_IZNOS', 'KLIJENT_UKUPNI_IZNOS_A',
           'KLIJENT_UKUPNI_IZNOS_L',
             'POREZ_NA_DOBIT_OTV',
             'INVESTIRANJA_OTV',
             'GDP-OTV',
             'Export-OTV',
             'Tax-dorian-OTV',
             'GrossSaving-OTV']
    numericals2 = ['UGOVORENI_IZNOS', 'VISINA_KAMATE', 'STAROST']
    
    # now we preserve only features we want from data we loaded
    X, y, features = preprocess_data (data, categories, numericals, bad_cols, target_col)
    X2, y2, features2 = preprocess_data (data, categories, numericals2, bad_cols, target_col)
    
    if load_models == True:
        run_validation(categories, features, features2, X, X2)
    else:
        model, model2 = run_train(X, y, X2, y2)
        run_validation(categories, features, features2, X, X2, model, model2)

##################################################
# extra methods which came useful for optimizing trained models
    
# we provide model which gives output in range [0.0, 1.0] and set threshold for
# for output model probability to declare sample as 1 if it passes it and 0
# if it does not
def apply_threshold (model, data_to_predict, threshold = 0.5):
    probabilities = model.predict_proba(data_to_predict)
    probabilities = probabilities[:, 1]
    logical = probabilities > threshold
    
    return logical.astype(int)

# we provide model and its features and the function returns all of them sorted
# by their importance in model
def feature_importances (model, columns, max_num_features = 10, height = 0.5):
    importances = model.feature_importances_
    indices = np.argsort(importances)[::-1]
    feature_array = np.array([columns[indices], importances[indices]]).transpose()
    xgb.plot_importance (model, max_num_features = max_num_features, height = height)
    
    return pd.DataFrame (feature_array, columns = ['Feature', 'Importance'])

# algorithm which does automatized feature selection
# we provide training set, labels, model and number of top features we want
# to retrieve
def recursive_feature_elimination (X, y, estimator, num_features = 20):
    selector = RFE (estimator, num_features, step = 1)
    data_filled = X.interpolate ()
    selector = selector.fit(data_filled, y)
    all_features = X.columns
    rfe_features = list(all_features[selector.support_]) 
    
    return rfe_features

# we provide trained model and this method plots learning curves for it
def learning_curves (model):
    results = model.evals_result()
    epochs = len(results['validation_0']['error'])
    x_axis = range(0, epochs)
    
    fig, ax = pyplot.subplots()
    ax.plot(x_axis, results['validation_0']['error'], label='Train')
    ax.plot(x_axis, results['validation_1']['error'], label='Test')
    ax.legend()
    
    pyplot.ylabel('Classification Error')
    pyplot.title('XGBoost Classification Error')
    pyplot.show()

##################################################

main(load_models = True)
