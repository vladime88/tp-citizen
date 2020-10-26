 // SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
/*
*/
import "./CitizenErc20.sol";

contract Sage {
    
CitizenErc20 public token;

 /// @dev address who collects CTZ from elections fees
address payable etat;

struct Citoyen {
        bool isSage; // false if the member is not an sage, true is an sage
        bool workeur; // false if the workeur is not an sage, true is an workeur
        bool jobless; // false if the jobless is not an sage, true is an jobless
        bool banned; //
        uint256 age; // for pension retreat
        uint256 idEnterprise; // for workeur true, and jobless false and inverse
        uint256 wallet; // wallet Citoyen
    }

struct Sage {
    bool isSage; // 
    uint electionFee; // 100 CTZ depot require.
    uint256 delayRegistration; // until when the sage will be elected (elected for 8 weeks)
    
    
}

struct Proposal {
    uint256 id; // id of proposal.
    string question; // proposal question:"Would you want me to be a sage?"
    uint256 counterForVotes; // counter of answer yes.
    uint256 counterAgainstVotes; // counter of answer no.
    uint256 counterBlankVotes; // counter of blank votes.
    uint256 delay; //until when the proposal will be active.
    mapping(address =>bool) didVote;// mapping for checking that an address(a citoyen) can not vote twice .
    
    
}

// @dev mapping from an address to a Sage
mapping(address => Sage) public sages;

//@dev mapping from an id of proposal to a Proposal
mapping(uint256=>Proposal) public proposals;

//@dev only one vote per citoyen possible
mapping (uint => mapping(address => bool)) public votes;

//@dev counter 
uint256 private counterIdProposal;

// valeurs des options de votes: Option.Yes, Option.No, Option.Blank
enum Option { Yes, No, Blank } Option voteOption; 

/// @dev instructions to vote
    /// @notice instructions to vote : 0 -> Blank, 1 -> Yes, 2 -> No, other -> Invalid vote
    string public howToVote = "0 -> Blank, 1 -> Yes, 2 -> No";

 /// @dev vote options: Yes, No, Blank using enum type
    enum Option {Blank, Yes, No}  // variables de type Option prennent valeurs: 0 -> Option.Blank, 1 -> Option.Yes, 2 -> Option.No

/*
    /// @dev event for EVM log when payment for registration
    event Registration(
        address indexed _buyer,
        uint256 _amount_wei,
        uint256 _amount_delay
    );
*/


    // Constructor
    /// @dev address 
    constructor(address payable _addr) public {
        Sage = _addr;
        Citoyen[_addr].isSage = true;
        Citoyen[_addr].delayRegistration = block.timestamp + 8 weeks;
    }

    //Modifiers

  

   modifier onlySage (){
            require (sages[msg.sender].isSage == true, "only Sage can do this");
            require(sages[msg.sender].delayRegistration > block.timestamp, "you are not sage anymore");
            _;
        }


    // Functions

    /// @dev only an citoyen can create a proposal. The id is given by counterIdProposal variable and delay 1 week from creation date
    /// @notice proposal active for one week
    /// @param _question : short question of the proposal
    
    function propose(string memory _question)
        public
       
       
    {
        counterIdProposal++;
        uint256 count = counterIdProposal;
        proposals[count] = Proposal(
            count,
            _question,
            0,
            0,
            0,
            block.timestamp + 1 weeks
        );
    }

    /// @dev only a citoyen can vote for an active proposal and only once.
    /// @notice proposal active for one week, see voting instructions with howToVote
    /// @param _id : proposal id
    /// @param _voteOption : option for voting
    function vote(uint256 _id, Option _voteOption)
        public
  
    {
        //verifier si votant n'est pas blacklisted et pas deja vote pour cette proposition
     
        require(
            proposals[_id].didVote[msg.sender] == false,
            "citoyen already voted for this proposal"
        );
        if (_voteOption == Option.Blank) {
            proposals[_id].counterBlankVotes++;
        } else if (_voteOption == Option.Yes) {
            proposals[_id].counterForVotes++;
        } else if (_voteOption == Option.No) {
            proposals[_id].counterAgainstVotes++;
        } else revert("Invalid vote");
        proposals[_id].didVote[msg.sender] = true;
    }

   

    // setSage met en depot 100 citizen
    // Election dur 1 semaine

    function setSage(uint _id) public  {
     uint depot=100;
        if (proposals[_id].counterForVotes>proposals[_id].counterAgainstVotes && proposals[_id].counterForVotes > proposals[_id].counterBlankVotes){
            Citoyen[_addr].isSage = true;
          //  token.transferFrom( citoyen address, etat address, depot  );
        }
        else {}
    }

    function unsetSage(address _addr) public  {
        Citoyen[_addr].isSage = false;
    }
   

}
//  Collect sage election's depot 
  
