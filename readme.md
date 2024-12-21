
# Live-streamed Quiz Tournaments

## Project Description
**Quiz Tournament** is a decentralized platform for hosting competitive quiz tournaments where participants can join by paying an entry fee in ERC-20 tokens, submit their scores during the event, and compete for a prize pool. The smart contract ensures transparent management of the tournament, including tournament creation, player participation, score submission, and prize distribution, all on the blockchain.

## Contract Address
0x376D97498C6acB7747Bd07c604acf3D031fa3e49

## Project Vision
The vision of the **Quiz Tournament** project is to bring competitive quiz games to the blockchain, enabling users to participate in engaging and fair tournaments. By leveraging the transparency and security of blockchain technology, the platform aims to offer an environment where players from all around the world can join quiz tournaments, showcase their knowledge, and earn rewards, all while ensuring fairness through smart contract automation.

The platform is designed to be scalable and supports various quiz topics, making it ideal for live-streamed quiz competitions, game shows, and educational competitions.

## Key Features

- **Tournament Creation**: The contract allows the owner (administrator) to create new tournaments by defining parameters like the title, entry fee, start and end times, and the maximum number of participants.
  
- **Player Participation**: Players can join tournaments by paying the entry fee in ERC-20 tokens. They must join before the tournament starts and cannot join once the tournament has begun.

- **Score Submission**: Players can submit their scores during the tournament. Scores are recorded on-chain to maintain transparency.

- **Leaderboard**: The contract automatically maintains and displays a leaderboard of players with their scores. It ranks the players based on their performance.

- **Prize Distribution**: The prize pool, which is accumulated from the entry fees, is distributed to the top 3 players at the end of the tournament. The platform charges a 5% fee on the prize pool.
    - 50% of the remaining prize pool goes to the 1st place winner.
    - 30% goes to the 2nd place winner.
    - 20% goes to the 3rd place winner.

- **Platform Fee**: The owner of the platform can set and update the platform fee (maximum of 10%).

- **Security**: The contract uses **ReentrancyGuard** to prevent reentrancy attacks and protect against malicious transactions during the score submission and prize distribution process.

---
### Future Improvements

- *Rating and Feedback System*: After a session ends, students and tutors can rate each other, helping to build trust and improve the quality of the platform.
- *Dispute Resolution*: Implement a mechanism for resolving disputes between tutors and students (e.g., through arbitration or community voting).
- *Extended Functionality*: Add additional features like scheduling, group tutoring, and subscription models.
