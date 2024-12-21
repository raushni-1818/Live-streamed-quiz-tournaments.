// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract QuizTournament is Ownable, ReentrancyGuard {
    struct Tournament {
        uint256 id;
        string title;
        uint256 entryFee;
        uint256 prizePool;
        uint256 startTime;
        uint256 endTime;
        uint256 maxParticipants;
        uint256 currentParticipants;
        bool isActive;
        mapping(address => bool) participants;
        mapping(address => uint256) scores;
    }

    struct Leaderboard {
        address player;
        uint256 score;
    }

    uint256 public tournamentCounter;
    mapping(uint256 => Tournament) public tournaments;
    IERC20 public paymentToken;
    uint256 public platformFee = 5; // 5% platform fee

    event TournamentCreated(uint256 indexed tournamentId, string title, uint256 entryFee);
    event PlayerJoined(uint256 indexed tournamentId, address indexed player);
    event ScoreSubmitted(uint256 indexed tournamentId, address indexed player, uint256 score);
    event PrizeDistributed(uint256 indexed tournamentId, address indexed winner, uint256 amount);

    constructor(address _paymentToken, address initialOwner) Ownable(initialOwner) {
        paymentToken = IERC20(_paymentToken);
    }

    function createTournament(
        string memory _title,
        uint256 _entryFee,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _maxParticipants
    ) external onlyOwner {
        require(_startTime > block.timestamp, "Invalid start time");
        require(_endTime > _startTime, "Invalid end time");
        require(_maxParticipants > 0, "Invalid max participants");

        tournamentCounter++;
        Tournament storage newTournament = tournaments[tournamentCounter];
        newTournament.id = tournamentCounter;
        newTournament.title = _title;
        newTournament.entryFee = _entryFee;
        newTournament.startTime = _startTime;
        newTournament.endTime = _endTime;
        newTournament.maxParticipants = _maxParticipants;
        newTournament.isActive = true;

        emit TournamentCreated(tournamentCounter, _title, _entryFee);
    }

    function joinTournament(uint256 _tournamentId) external nonReentrant {
        Tournament storage tournament = tournaments[_tournamentId];
        require(tournament.isActive, "Tournament not active");
        require(block.timestamp < tournament.startTime, "Tournament has started");
        require(!tournament.participants[msg.sender], "Already joined");
        require(tournament.currentParticipants < tournament.maxParticipants, "Tournament full");

        paymentToken.transferFrom(msg.sender, address(this), tournament.entryFee);
        tournament.participants[msg.sender] = true;
        tournament.currentParticipants++;
        tournament.prizePool += tournament.entryFee;

        emit PlayerJoined(_tournamentId, msg.sender);
    }

    function submitScore(uint256 _tournamentId, uint256 _score) external {
        Tournament storage tournament = tournaments[_tournamentId];
        require(tournament.isActive, "Tournament not active");
        require(tournament.participants[msg.sender], "Not a participant");
        require(block.timestamp >= tournament.startTime && block.timestamp <= tournament.endTime, "Invalid submission time");

        tournament.scores[msg.sender] = _score;
        emit ScoreSubmitted(_tournamentId, msg.sender, _score);
    }

    function getLeaderboard(uint256 _tournamentId) public view returns (Leaderboard[] memory) {
        Tournament storage tournament = tournaments[_tournamentId];
        Leaderboard[] memory leaderboard = new Leaderboard[](tournament.currentParticipants);
        
        uint256 index = 0;
        for (uint256 i = 0; i < tournament.currentParticipants; i++) {
            if (tournament.participants[msg.sender]) {
                leaderboard[index] = Leaderboard({
                    player: msg.sender,
                    score: tournament.scores[msg.sender]
                });
                index++;
            }
        }
        return leaderboard;
    }

    function distributePrizes(uint256 _tournamentId) external onlyOwner {
        Tournament storage tournament = tournaments[_tournamentId];
        require(tournament.isActive, "Tournament not active");
        require(block.timestamp > tournament.endTime, "Tournament not ended");

        Leaderboard[] memory leaderboard = getLeaderboard(_tournamentId);
        require(leaderboard.length > 0, "No participants");

        // Calculate platform fee
        uint256 platformFeeAmount = (tournament.prizePool * platformFee) / 100;
        uint256 remainingPrizePool = tournament.prizePool - platformFeeAmount;

        // Transfer platform fee
        paymentToken.transfer(owner(), platformFeeAmount);

        // Distribute prizes (50% to 1st, 30% to 2nd, 20% to 3rd)
        if (leaderboard.length >= 1) {
            uint256 firstPrize = (remainingPrizePool * 50) / 100;
            paymentToken.transfer(leaderboard[0].player, firstPrize);
            emit PrizeDistributed(_tournamentId, leaderboard[0].player, firstPrize);
        }
        
        if (leaderboard.length >= 2) {
            uint256 secondPrize = (remainingPrizePool * 30) / 100;
            paymentToken.transfer(leaderboard[1].player, secondPrize);
            emit PrizeDistributed(_tournamentId, leaderboard[1].player, secondPrize);
        }
        
        if (leaderboard.length >= 3) {
            uint256 thirdPrize = (remainingPrizePool * 20) / 100;
            paymentToken.transfer(leaderboard[2].player, thirdPrize);
            emit PrizeDistributed(_tournamentId, leaderboard[2].player, thirdPrize);
        }

        tournament.isActive = false;
    }

    function setPlatformFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 10, "Fee too high"); // Max 10%
        platformFee = _newFee;
    }
}