// Autor: Miguel Vanderlei de Oliveira (mvo.snf18@uea.edu.br)
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract Bet {
        
    address public owner;

    uint256 public totalBetValue;
    uint256 public totalBetsPlaced;
    string[] public teams;

    struct Team {
        string name;
        uint256 teamTotalBetValue;
        uint256 betsPlacedCount;
        bool exists;
        address[] players;
    }

    struct Player {
        uint256 betValue;
        string teamName;
        bool exists;
    }

    mapping(address => Player) playersAddresses;

    mapping(string => Team) teamsBets;


    modifier isOwner() {
        require(msg.sender == owner, "Somente o owner pode chamar esse metodo!");
        _;
    }
    
    modifier canOnlyBetOnce() {

        Player memory player = playersAddresses[msg.sender];
        require(!player.exists, "Voce so pode apostar uma vez!");
        _;
    }

    constructor (string[] memory teamsList) {
        owner = msg.sender;
        // teamsNames = new string[](0);

        for (uint i=0; i< teamsList.length; i++) {

            string memory teamName = string(teamsList[i]);

            // teamsNames.push(teamName);

            Team memory newTeam = Team({
                name: teamName,
                teamTotalBetValue: 0,
                betsPlacedCount: 0,
                exists: true,
                players: new address[](0)
            });
            
            teamsBets[teamName] = newTeam;
        }
    }

   function bet(string calldata teamName) public payable canOnlyBetOnce {

        require(teamsBets[teamName].exists, "Voce deve apostar em um Time cadastrado!");

        uint256 value = msg.value;
        address playerAddress = msg.sender;

        Player memory newPlayer = Player({
            betValue: value,
            teamName: teamName,
            exists: true
        });
        
        playersAddresses[playerAddress] = newPlayer;

        totalBetValue += value;
        totalBetsPlaced++;

        Team storage chosenTeam = teamsBets[teamName];

        chosenTeam.teamTotalBetValue += value;
        chosenTeam.betsPlacedCount++;
        chosenTeam.players.push(playerAddress);
        
        teamsBets[teamName] = chosenTeam;
    }

    function payWinners(string memory winningTeamName) public isOwner {
        require(teamsBets[winningTeamName].exists, "Somente times cadastrados podem vencer!");

        Team memory winningTeam = teamsBets[winningTeamName];

        address[] memory winners = winningTeam.players;
        uint256 winningTeamTotalBetsValue = winningTeam.teamTotalBetValue;
        uint256 losingTeamsTotalBetsValue = totalBetValue - winningTeam.teamTotalBetValue;


         for (uint i=0; i< winners.length; i++) {

            Player memory player = playersAddresses[winners[i]];
            uint256 betValue = player.betValue;
            
            uint256 paymentValue = betValue + (betValue/winningTeamTotalBetsValue) * losingTeamsTotalBetsValue;

            payable(winners[i]).transfer(paymentValue);

         }        


    }
}
