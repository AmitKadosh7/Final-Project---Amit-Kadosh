from __future__ import absolute_import, division, print_function, unicode_literals
import os
import tensorflow
import scipy.io
import numpy
from tensorflow import keras 
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Conv2D
from tensorflow.keras.models import load_model
import time
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
tensorflow.keras.backend.set_floatx('float32')

trainData = numpy.empty((0,81),dtype=numpy.float32)
validationData = numpy.empty((0,81),dtype=numpy.float32)
trainLabel = numpy.empty((0,81),dtype=numpy.float32)
validationLabel = numpy.empty((0,81),dtype=numpy.float32)

dir = "C:/Users/user/Desktop/Studies/Semester 8/myProject/de-noise/DATA_SET_GRAY_VECTOR/DataSetStd25/matFiles"
for file in os.listdir(dir):
    mat = scipy.io.loadmat(dir + "/" + file)['newDataAndLabel']
    currentTrainData = numpy.array([mat[row][0].flatten() for row in range(0,len(mat))][0:int(round(0.8*len(mat)))],dtype=numpy.float32)
    currentValidationData = numpy.array([mat[row][0].flatten() for row in range(0,len(mat))][int(round(0.8*len(mat)))+1:],dtype=numpy.float32)
    currentTrainLabel = numpy.array([mat[row][1].flatten() for row in range(0,len(mat))][0:int(round(0.8*len(mat)))],dtype=numpy.float32)
    currentValidationLabel = numpy.array([mat[row][0].flatten() for row in range(0,len(mat))][int(round(0.8*len(mat)))+1:],dtype=numpy.float32)

    trainData = numpy.vstack((trainData,currentTrainData))
    validationData = numpy.vstack((validationData,currentValidationData))
    trainLabel = numpy.vstack((trainLabel,currentTrainLabel))
    validationLabel = numpy.vstack((validationLabel,currentValidationLabel))

model = Sequential()
model.add(Dense(256, input_shape=(81,), activation='sigmoid'));
model.add(Dense(256, activation='sigmoid'));
model.add(Dense(256, activation='sigmoid'));
model.add(Dense(256, activation='sigmoid'));
model.add(Dense(256, activation='sigmoid'));
model.add(Dense(256, activation='sigmoid'));
model.add(Dense(81));
model.compile(optimizer='adam', loss='mse')
print(model.summary())
numOfEpochs = 5;
trained_model = model.fit(trainData, trainLabel, validation_data=(validationData, validationLabel), epochs=numOfEpochs)

fig = plt.figure()
myTitle = "Loss (Mean Squared Error)  of NN"
plt.title(myTitle)
plt.plot(range(numOfEpochs), [x for x in trained_model.history['loss']], "-o", label='train')
plt.plot(range(numOfEpochs), [x for x in trained_model.history['val_loss']], "-o", label='validation')
plt.xlabel('Epoch Number')
plt.ylabel('loss')
plt.legend()
plt.grid()
plt.show()
pdfFile = PdfPages("PlotsResults.pdf")
pdfFile.savefig(fig)
pdfFile.close()
model.save("model.h5")
print("Saved model to disk")