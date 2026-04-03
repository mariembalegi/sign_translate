import os, cv2, numpy as np
import pickle
from sklearn.model_selection import train_test_split
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, LSTM, Dense, TimeDistributed, Dropout, Input

# Paramètres
IMG_SIZE = 64
SEQUENCE_LENGTH = 20
dataset_path = "./dataset"

# Préparation des données
X, y = [], []
words_set = set()

for category in os.listdir(dataset_path):
    category_path = os.path.join(dataset_path, category)
    for word in os.listdir(category_path):
        word_path = os.path.join(category_path, word)
        files = sorted(os.listdir(word_path))
        if len(files) < SEQUENCE_LENGTH:
            continue
        for i in range(0, len(files) - SEQUENCE_LENGTH + 1):
            seq = []
            for j in range(SEQUENCE_LENGTH):
                img = cv2.imread(os.path.join(word_path, files[i+j]))
                img = cv2.resize(img, (IMG_SIZE, IMG_SIZE))
                img = img / 255.0
                seq.append(img)
            X.append(seq)
            y.append(word)
            words_set.add(word)

X = np.array(X)
words = list(words_set)
word_to_idx = {w:i for i,w in enumerate(words)}
y_idx = np.array([word_to_idx[w] for w in y])

X_train, X_test, y_train, y_test = train_test_split(X, y_idx, test_size=0.2, random_state=42)
print("X_train shape:", X_train.shape)
print("Nombre de mots uniques:", len(words))

# ---------------------
# Modèle simplifié CNN + LSTM
# ---------------------
model = Sequential()

# ✅ Input propre
model.add(Input(shape=(SEQUENCE_LENGTH, IMG_SIZE, IMG_SIZE, 3)))

# ✅ CNN léger
model.add(TimeDistributed(Conv2D(16, (3,3), activation='relu')))
model.add(TimeDistributed(MaxPooling2D()))

# ✅ Flatten
model.add(TimeDistributed(Flatten()))

# ✅ LSTM plus petit
model.add(LSTM(32))

# ✅ Régularisation
model.add(Dropout(0.5))

# ✅ Sortie
model.add(Dense(len(words), activation='softmax'))

# Compilation
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.summary()

# Entraînement
history = model.fit(X_train, y_train, epochs=30, validation_data=(X_test, y_test))

with open("models/words.pkl", "wb") as f:
    pickle.dump(words, f)

# Sauvegarde
model.save("models/model.keras")