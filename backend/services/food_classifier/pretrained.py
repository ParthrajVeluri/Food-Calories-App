from keras_image_helper import create_preprocessor
import tensorflow.lite as tflite
import numpy as np

interpreter = tflite.Interpreter(model_path='backend/services/food_classifier/model.tflite')
interpreter.allocate_tensors()
input_index = interpreter.get_input_details()[0]['index']
output_index = interpreter.get_output_details()[0]['index']

preprocessor = create_preprocessor('xception', target_size=(299,299))

classes = [
 'Bean',
 'Bitter_Gourd',
 'Bottle_Gourd',
 'Brinjal',
 'Broccoli',
 'Cabbage',
 'Capsicum',
 'Carrot',
 'Cauliflower',
 'Cucumber',
 'Papaya',
 'Potato',
 'Pumpkin',
 'Radish',
 'Tomato']

X = preprocessor.from_url('https://punjabigroceries.com/cdn/shop/products/store-baby-e_1024x.jpg?v=1660754627')
interpreter.set_tensor(input_index, X)
interpreter.invoke()
preds = interpreter.get_tensor(output_index)
float_predictions = preds[0].tolist()
print(classes[np.argmax(float_predictions)])