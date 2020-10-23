from __future__ import absolute_import, division, print_function, unicode_literals #maybe not need it's
import os
import tensorflow
import scipy.io
import numpy
from tensorflow import keras #maybe not need it's
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Conv2D
from tensorflow.keras.models import load_model #maybe not need it's
import time
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
tensorflow.keras.backend.set_floatx('float32')

imageDim = 100    
dir = "C:/Users/user/Desktop/Studies/Semester 8/myProject/super resolution/Super Resolution - Python/result_100X100_scale2/trainUpsampledImages"
trainData = numpy.empty([5159, imageDim, imageDim], dtype=numpy.float32)
i = 0
for file in os.listdir(dir):
    mat = scipy.io.loadmat(dir + "/" + file)['UpsampledImageDouble']
    mat = numpy.array([list(mat[i]) for i in range(0,len(mat))])
    trainData[i] = mat
    i += 1
    print("trainData - " + file)
trainData = numpy.expand_dims(trainData, axis=3)

dir = "C:/Users/user/Desktop/Studies/Semester 8/myProject/super resolution/Super Resolution - Python/result_100X100_scale2/trainResidualImages"
trainLabel = numpy.empty([5159, imageDim, imageDim], dtype=numpy.float32)
i = 0
for file in os.listdir(dir):
    mat = scipy.io.loadmat(dir + "/" + file)['ResidualImageDouble']
    mat = numpy.array([list(mat[i]) for i in range(0,len(mat))])
    trainLabel[i] = mat
    i += 1
    print("trainLabel - " + file)
trainLabel = numpy.expand_dims(trainLabel, axis=3)

dir = "C:/Users/user/Desktop/Studies/Semester 8/myProject/super resolution/Super Resolution - Python/result_100X100_scale2/validationUpsampledImages"
validationData = numpy.empty([1291, imageDim, imageDim], dtype=numpy.float32)
i = 0
for file in os.listdir(dir):
    mat = scipy.io.loadmat(dir + "/" + file)['UpsampledImageDouble']
    mat = numpy.array([list(mat[i]) for i in range(0,len(mat))])
    validationData[i] = mat
    i += 1
    print("validationData - " + file)
validationData = numpy.expand_dims(validationData, axis=3)

dir = "C:/Users/user/Desktop/Studies/Semester 8/myProject/super resolution/Super Resolution - Python/result_100X100_scale2/validationResidualImages"
validationLabel = numpy.empty([1291, imageDim, imageDim], dtype=numpy.float32)
i = 0
for file in os.listdir(dir):
    mat = scipy.io.loadmat(dir + "/" + file)['ResidualImageDouble']
    mat = numpy.array([list(mat[i]) for i in range(0,len(mat))])
    validationLabel[i] = mat
    i += 1
    print("validationLabel - " + file)
validationLabel = numpy.expand_dims(validationLabel, axis=3)
 
WeightsForFirst = scipy.io.loadmat("C:/Users/user/Desktop/Studies/Semester 8/myProject/super resolution/Super Resolution - Python/result_100X100_scale2/H_and_Htrans_for_python_9x9.mat")['H_new_dim']
WeightsForLast = scipy.io.loadmat("C:/Users/user/Desktop/Studies/Semester 8/myProject/super resolution/Super Resolution - Python/result_100X100_scale2/H_and_Htrans_for_python_9x9.mat")['H_trans_new_dim']
WeightsForLast = numpy.expand_dims(WeightsForLast, axis=3)

model = Sequential()
model.add(Conv2D(81,(9,9),padding='same', input_shape=(imageDim,imageDim,1), weights=[WeightsForFirst,numpy.zeros(81,)], trainable=False))
model.add(Conv2D(256,(1,1),activation='relu'))
model.add(Conv2D(256,(1,1),activation='relu'))
model.add(Conv2D(256,(1,1),activation='relu'))
model.add(Conv2D(256,(1,1),activation='relu'))
model.add(Conv2D(81,(1,1)))
model.add(Conv2D(1,(9,9),padding='same', weights=[WeightsForLast,numpy.zeros(1,)], trainable=False))   
model.compile(optimizer='adam', loss='mse')
print(model.summary())

numOfEpochs = 1
trained_model = model.fit(trainData, trainLabel, validation_data=(validationData, validationLabel), epochs=numOfEpochs, batch_size=4)

fig = plt.figure()
myTitle = "Loss (Mean Squared Error) of NN"
plt.title(myTitle)
plt.plot(range(numOfEpochs), [x for x in trained_model.history['loss']], "-o", label='train')
plt.plot(range(numOfEpochs), [x for x in trained_model.history['val_loss']], "-o", label='validation')
plt.xlabel('Epoch Number')
plt.ylabel('loss')
plt.legend()
plt.grid()
plt.show()
pdfName="PlotsResults.pdf"
pdfFile = PdfPages(pdfName)
pdfFile.savefig(fig)
pdfFile.close()
fileName = "model.h5"
model.save(fileName)
print("Saved model to disk")
    
    

