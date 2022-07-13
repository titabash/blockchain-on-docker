from flask import Flask
from flask import jsonify

app = Flask(__name__)


@app.route("/<token_id>")
def index(token_id):
    file_names = ["luffy", "zoro"]
    token_json = {
        "name": "NFT Name",
        "description": "NFT Description.",
        "image": f"http://localhost:8005/ipfs/QmVvceXX5Mxie4WA7jcQFwp9HTGCyyV7qjHgdP6UQQZdVc/{file_names[int(token_id)]}.png"
    }

    return jsonify(token_json)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)
