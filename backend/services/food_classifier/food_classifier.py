import tensorflow as tf
import cv2
import numpy as np



model = tf.keras.models.load_model('backend/services/food_classifier/best_model.h5')

img = cv2.imread("backend/services/food_classifier/apple.jpg")
img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
img =  cv2.resize(img, (256, 256))
print("Image shape after resizing:", img.shape)
# Add batch dimension
img = np.expand_dims(img, axis=0)  

# Ensure the final shape is (1, 256, 256, 3)
print("Image shape after adding batch dimension:", img.shape)
prediction = model.predict(img)
cv2.imshow("input", prediction)