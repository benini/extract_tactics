### Tactics
A tactic position in chess refers to a particular arrangement of pieces on the chessboard where a player can make a specific, advantageous move that can gain an advantage over their opponent. Tactics in chess are short-term strategies that allow a player to gain an advantage, usually by exploiting an opponent's weakness or error. In a tactic position, a player has the opportunity to make a move that can lead to a material advantage, such as capturing an opponent's piece, or a positional advantage, such as gaining control over key squares or putting pressure on the opponent's pieces. A tactic position can occur in any phase of the game, from the opening to the endgame, and recognizing these opportunities is an important skill for successful chess play.

### Identifing tactics
Using a chess engine with multipv ability we can then define a tactic as a position where **the best move is significantly better than the second best**. But in winning positions there may be many way to reach the victory and we should consider only moves that gives a significant advantage. Requiring that **the evaluation of the second best is within a speficied range**.  
We have three hyper-parameters:
- the difference between the best move and the second best -> 2.00
- the range for the evaluation of the second best move -> between -1.00 and 1.00
- how long should be spend analyzing the position -> depth 30

### Classifying tactics
The extracted positions can be classified based on tactical motifs, such as: Discovered Attack (a move where a piece moves out of the way to reveal an attack by another piece), Last Rank Mate (a checkmate delivered by a rook or queen on the opponent's eighth rank), Double Attack (a move that attacks two pieces at the same time), Pin (a piece is unable to move without exposing a more valuable piece to attack).  
Another important factor is the difficulty of the tactic, which is non-trivial and somewhat subjective.
Lichess use a hard-coded technique: https://github.com/ornicar/lichess-puzzler/blob/master/tagger/cook.py  
But it is somehow unsatisfactory and it should be possible to **do better with a unsupervised machine learning**.

### Training
At the moment both lichess and chess.com tactical training is very boring. The tactics are repetitive and their estimated difficulty is very inaccurate. With better categories, that consider both the tactical motif and the difficulty, the user experience can be improved simply avoiding tactics from categories that were previously easily solved.
