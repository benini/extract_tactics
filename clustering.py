import csv
import numpy as np
from sklearn.cluster import KMeans
import chess

"""
Read FENs from lichess' puzzle database.
Use clustering to classify the tactics.
Create a file output.epd with the FENs sorted by category.
"""
num_clusters = 1000
limit_num_games = 100000

# Function to convert FEN position to numerical features
def fen_to_features(fen):
    # convert FEN position to chess position
    board = chess.Board(fen)
    features = [0] * 2 * 6 * 64
    
    # loop over all pieces on the chessboard
    for square, piece in board.piece_map().items():
        color = 0 if piece.color == chess.BLACK else 1
        piece_type = {
            chess.KING: 0,
            chess.QUEEN: 1,
            chess.ROOK: 2,
            chess.BISHOP: 3,
            chess.KNIGHT: 4,
            chess.PAWN: 5,
        }[piece.piece_type]
        features[color * 6 * 64 + piece_type * 64 + square] = 1
    return features

# read csv file
data = []
fen_list = []
with open('lichess_db_puzzle.csv') as csvfile:
    reader = csv.reader(csvfile)
    for row in reader:
        fen_list.append([row[1],row[2],row[3],row[7]])
        data.append(fen_to_features(row[1]))
        if len(data) > limit_num_games:
            break

# convert to numpy array
data = np.array(data)

# perform k-means clustering
kmeans = KMeans(n_clusters=num_clusters, random_state=0).fit(data)

# classify input
labels = kmeans.predict(data)

sort_by_class = [(val, idx) for idx, val in enumerate(labels)]
sort_by_class.sort(key=lambda x: x[0])

# write to csv file
with open('output.epd', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    for category, fen_idx in sort_by_class:
        writer.writerow(fen_list[fen_idx] + [category])
