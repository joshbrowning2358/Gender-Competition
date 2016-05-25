import os
import json
import csv
import numpy as np
os.chdir('E:/Github/coolblue-generalized-forecasting/model_machine/python_model_module')
from dataset import Dataset
dataset = Dataset('files/input/example_dataset.json')
data = np.genfromtxt('E:/Github/Working/Gender Competition/data/python_wide_input.csv', delimiter=',', skip_header=1, dtype='char')
data[0:3, ]