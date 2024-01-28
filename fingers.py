from flask import Flask, request, jsonify
import pandas as pd
import hashlib

app = Flask(__name__)

# File path to store fingerprint data
EXCEL_FILE_PATH = 'fingerprint_data.xlsx'

def hash_fingerprint(fingerprint_data):
    # Hash the fingerprint data using SHA-256
    hashed_fingerprint = hashlib.sha256(fingerprint_data.encode()).hexdigest()
    return hashed_fingerprint

@app.route('/register', methods=['POST'])
def register_fingerprint():
    data = request.get_json()
    user_id = data.get('userId')
    fingerprint = data.get('fingerprint')

    # Hash the fingerprint data for security
    hashed_fingerprint = hash_fingerprint(fingerprint)

    # Store the hashed fingerprint data in the Excel file
    df = pd.DataFrame({'User ID': [user_id], 'Hashed Fingerprint': [hashed_fingerprint]})
    df.to_excel(EXCEL_FILE_PATH, index=False, header=not df.index.exists())

    return jsonify({'message': 'Fingerprint registered successfully'}), 200

if __name__ == '__main__':
    # Initialize the Excel file with column names if it doesn't exist
    if not os.path.isfile(EXCEL_FILE_PATH):
        df = pd.DataFrame(columns=['User ID', 'Hashed Fingerprint'])
        df.to_excel(EXCEL_FILE_PATH, index=False)

    app.run(debug=True,host='0.0.0.0')
