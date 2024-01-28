import face_recognition as fc
import cv2
import numpy as np 
import csv
import os
import glob
from datetime import datetime

video_capture=cv2.VideoCapture(0)
mona_img=fc.load_image_file("images/mona.jpg")
mona_encoding=fc.face_encodings(mona_img)[0]

AK_img=fc.load_image_file("images/AK.jpg")
AK_encoding=fc.face_encodings(AK_img)[0]

MJ_img=fc.load_image_file("images/MJ.jpg")
MJ_encoding=fc.face_encodings(MJ_img)[0]

known_face_encoding=[mona_encoding,AK_encoding,MJ_encoding]
known_face_names=["Mona Lisa","Dr.A.P.J.Abdul Kalam","Michael Jackson"]
students=known_face_names.copy()

face_locations=[]
face_names=[]
face_encodings=[]
s=True

now=datetime.now()
current_date=now.strftime("%Y-%m-%d")

f=open(current_date+'.csv','w+',newline='')
lnwriter=csv.writer(f)

while True:
    _,frame=video_capture.read()
    small_frame=cv2.resize(frame,(0,0),fx=0.25,fy=0.25)
    rgb_small_frame=small_frame[:,:,::-1]
    if s:
        face_locations=fc.face_locations(rgb_small_frame)
        face_encodings=fc.face_encodings(rgb_small_frame,face_locations)
        face_names=[]
        for face_encoding in face_encodings:
            matches=fc.compare_faces(known_face_encoding,face_encoding)
            name=""
            face_distance=fc.face_distance(known_face_encoding,face_encoding)
            best_match_index=np.argmin(face_distance)
            if matches[best_match_index]:
                name=known_face_names[best_match_index]
            face_names.append(name)
            if name in known_face_names:
                if name in students:
                    students.remove(name)
                    print(students)
                    current_time=now.strftime("%H-%M-%S")
                    lnwriter.writerow([name,current_time])
    cv2.imshow("attendance system",frame)
    if cv2.waitKey(1) and 0xFF == ord('q'):
        break

video_capture.release()
cv2.destroyAllWindows()
f.close()