import cv2
import face_recognition
import os
import csv
from datetime import datetime
# import wifi_check

# if not wifi_check.is_connected_to_desired_wifi("b2:5a:96:dc:a6:64"):
#     exit(0)

# Function to load known faces from the directory
def load_known_faces(directory):
    known_faces = []
    known_names = []

    for filename in os.listdir(directory):
        if filename.endswith(".jpg") or filename.endswith(".png"):
            image_path = os.path.join(directory, filename)
            face_image = face_recognition.load_image_file(image_path)
            face_encoding = face_recognition.face_encodings(face_image)[0]
            known_faces.append(face_encoding)
            known_names.append(os.path.splitext(filename)[0])  # Use file name as the person's name

    return known_faces, known_names

# Function to mark attendance in CSV file
def mark_attendance(name, csv_file):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    with open(csv_file, mode='a', newline='') as file:
        writer = csv.writer(file)

        # Write the header if the file is empty
        if os.path.getsize(csv_file) == 0:
            writer.writerow(['Timestamp', 'Name'])

        # Write attendance data if not detected already on the same day
        if not is_already_detected_today(name, csv_file):
            writer.writerow([timestamp, name])

# Function to check if the face is already detected on the same day
def is_already_detected_today(name, csv_file):
    today = datetime.now().strftime("%Y-%m-%d")

    with open(csv_file, mode='r') as file:
        reader = csv.reader(file)

        try:
            next(reader)  # Skip the header
        except StopIteration:
            return False  # Return False if the file is empty

        for row in reader:
            timestamp, detected_name = row
            date, _ = timestamp.split()  # Extract date part only
            if date == today and detected_name == name:
                return True

    return False


# Directory containing your known faces
known_faces_directory = "images"

# CSV file to store attendance
csv_file = "2024-01-03.csv"

# Load known faces and names
known_faces, known_names = load_known_faces(known_faces_directory)

# Open laptop's camera
video_capture = cv2.VideoCapture(0)

while True:
    # Capture each frame from the camera
    ret, frame = video_capture.read()

    # Find all face locations in the current frame
    face_locations = face_recognition.face_locations(frame)
    face_encodings = face_recognition.face_encodings(frame, face_locations)

    # Loop through each face in the frame
    for (top, right, bottom, left), face_encoding in zip(face_locations, face_encodings):
        # Compare the face with known faces
        matches = face_recognition.compare_faces(known_faces, face_encoding)

        name = "Unknown"

        # If a match is found, use the name of the known face
        if True in matches:
            first_match_index = matches.index(True)
            name = known_names[first_match_index]

            # Mark attendance if not detected already on the same day
            mark_attendance(name, csv_file)

        # Draw rectangle and label on the face
        cv2.rectangle(frame, (left, top), (right, bottom), (0, 255, 0), 2)
        font = cv2.FONT_HERSHEY_DUPLEX
        cv2.putText(frame, name, (left + 6, bottom - 6), font, 0.5, (255, 255, 255), 1)

    # Display the resulting frame
    cv2.imshow('Video', frame)

    # Break the loop when 'q' key is pressed
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the camera and close all windows
video_capture.release()
cv2.destroyAllWindows()
