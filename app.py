from flask import Flask, render_template, request, jsonify
from flask_socketio import SocketIO
import requests
import subprocess


app = Flask(__name__)
socketio = SocketIO(app)

def run_command(command, emit_result):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    emit_result(result.stdout)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/validate_transfer', methods=['GET'])
def validate_transfer():
    # Check if an argument is provided
    id = request.args.get('id')
    if not id:
        return jsonify({'error': 'Usage: /validate_transfer?id=<id>'}), 400

    # Make the curl request with the provided id
    url = f"https://khalti.com/api/fund/validate_transfer/?amount=1000&id={id}&type=transfer"
    headers = {
        'Host': 'khalti.com',
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0',
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Authorization': 'Token 4fc9a8970e630c711acb4c87c068c0adfed44663',
        'DEVICEID': 'kwa-70baca45-9f5a-42ea-8528-2f4eaab3aa12',
        'Origin': 'https://web.khalti.com',
        'Connection': 'close',
        'Referer': 'https://web.khalti.com/',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-site'
    }

    response = requests.get(url, headers=headers)

    # Parse the JSON response
    data = response.json()

    # Check if 'name' is present in the JSON response
    if 'name' in data:
        # If 'name' is present, extract it
        result = {
            'name': data['name']
        }
        # Return the result as JSON
        return jsonify(result)
    else:
        # If 'name' is missing, return an error response
        return jsonify({'error': 'Name not found in the response'}), 500

@socketio.on('start_scan')
def start_scan(data):
    target_domain = data['target_domain']
    scan_status = {
        'technology': False,
        'subdomains': False,
        'WebArchive': False,
        'HiddenDirectory': False,
        'cve': False
    }

    def emit_result(category, result):
        socketio.emit(f'{category}_result', result)
        scan_status[category] = True
        socketio.emit('scan_status', scan_status)

    # 1. Check Technology
    run_command(f"whatweb {target_domain}", lambda result: emit_result('technology', result))

    # 2. Subdomains
    run_command(f"assetfinder --subs-only {target_domain}", lambda result: emit_result('subdomains', result))

    # 3. WebArchive URL
    run_command(f"waybackurls {target_domain}", lambda result: emit_result('WebArchive', result))

    # 4. Hidden Directory
    run_command(f"dirb https://{target_domain} -f", lambda result: emit_result('HiddenDirectory', result))

    # 5. Nuclei CVE Scan
    run_command(f"nuclei -u {target_domain} -t cves/", lambda result: emit_result('cve', result))

if __name__ == '__main__':
    socketio.run(app, debug=True)
