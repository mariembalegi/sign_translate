import os, cv2, numpy as np, mediapipe as mp, pickle
from tensorflow.keras.models import load_model

# Charger modèle et labels
model = load_model("models/model.keras")
with open("models/words.pkl", "rb") as f:
    words = pickle.load(f)

# MediaPipe
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(max_num_hands=1)
mp_draw = mp.solutions.drawing_utils

IMG_SIZE = 64
SEQUENCE_LENGTH = 20
sequence = []

cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(img_rgb)

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            h, w, _ = frame.shape
            x_min = max(0, int(min([lm.x for lm in hand_landmarks.landmark]) * w) - 10)
            y_min = max(0, int(min([lm.y for lm in hand_landmarks.landmark]) * h) - 10)
            x_max = min(w, int(max([lm.x for lm in hand_landmarks.landmark]) * w) + 10)
            y_max = min(h, int(max([lm.y for lm in hand_landmarks.landmark]) * h) + 10)

            hand_img = frame[y_min:y_max, x_min:x_max]

            if hand_img.size == 0:
                continue  # ignore si vide

            hand_img = cv2.resize(hand_img, (IMG_SIZE, IMG_SIZE))
            hand_img = hand_img / 255.0
            hand_img = np.array(hand_img, dtype=np.float32)

            # Affiche la main pour debug
            cv2.imshow("Hand", hand_img)

            sequence.append(hand_img)

            if len(sequence) == SEQUENCE_LENGTH:
                pred = model.predict(np.expand_dims(sequence, axis=0), verbose=0)
                word_pred = words[np.argmax(pred)]
                print("Prediction:", word_pred)
                # sliding window pour garder les 20 dernières frames
                sequence = sequence[1:]  

            mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

    cv2.imshow("Camera", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()