// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ConsensusPriceOracle {
    struct PriceSubmission {
        uint256 price;
        uint256 timestamp;
        bool submitted;
    }

    mapping(address => bool) public validators;
    mapping(address => mapping(uint256 => PriceSubmission)) public submissions;
    
    uint256 public currentRound = 1;
    uint256 public finalizedPrice;
    uint256 public finalizedTimestamp;
    uint256 public constant THRESHOLD = 100; // 1%
    uint256 public constant REQUIRED_VOTES = 2;
    address[3] public validatorList;

    event PriceFinalized(uint256 round, uint256 price, uint256 timestamp);
    event SubmissionReceived(address validator, uint256 round, uint256 price);

    modifier onlyValidator() {
        require(validators[msg.sender], "Not a validator");
        _;
    }

    constructor(address[3] memory _validators) {
        validatorList = _validators;
        for (uint i = 0; i < 3; i++) {
            validators[_validators[i]] = true;
        }
    }

    function submitPrice(uint256 _price) external onlyValidator {
        require(!submissions[msg.sender][currentRound].submitted, "Already submitted");
        
        submissions[msg.sender][currentRound] = PriceSubmission({
            price: _price,
            timestamp: block.timestamp,
            submitted: true
        });
        
        emit SubmissionReceived(msg.sender, currentRound, _price);
        _checkConsensus();
    }

    function _checkConsensus() internal {
        uint256 count = 0;
        uint256[3] memory prices;
        
        for(uint i = 0; i < 3; i++) {
            if(submissions[validatorList[i]][currentRound].submitted) {
                prices[count] = submissions[validatorList[i]][currentRound].price;
                count++;
            }
        }
        
        if(count >= REQUIRED_VOTES) {
            for(uint i = 0; i < count; i++) {
                for(uint j = i+1; j < count; j++) {
                    if(_withinThreshold(prices[i], prices[j])) {
                        finalizedPrice = (prices[i] + prices[j]) / 2;
                        finalizedTimestamp = block.timestamp;
                        currentRound++;
                        emit PriceFinalized(currentRound-1, finalizedPrice, finalizedTimestamp);
                        return;
                    }
                }
            }
        }
    }

    function _withinThreshold(uint256 a, uint256 b) internal pure returns(bool) {
        uint256 diff = a > b ? a - b : b - a;
        uint256 avg = (a + b) / 2;
        return (diff * 10000) / avg <= THRESHOLD;
    }

    function getPrice() external view returns(uint256, uint256) {
        return (finalizedPrice, finalizedTimestamp);
    }
}
