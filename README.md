# genlayer-price-oracle
Decentralized Price Oracle using 2/3 Validator Consensus for GenLayer. Reusable Intelligent Contract with state management and equivalence checks.
# Consensus Price Oracle - GenLayer Intelligent Contract

## Purpose
This contract solves the problem of unreliable single-source oracles by using GenLayer consensus logic. 3 validators submit price data. The price is only finalized if 2 out of 3 validators agree within a 1% threshold.

## How Consensus is Used
1.  Each validator calls `submitPrice()` with data from their API
2.  Contract stores submissions per `round`
3.  When 2 submissions are within 1%, consensus is reached
4.  `finalizedPrice` is set to the average of the 2 agreeing prices
5.  Round increments and process repeats

## State Design
- `validators`: Mapping of authorized validator addresses
- `submissions`: round => validator => price + timestamp
- `finalizedPrice`: Last consensus price
- `currentRound`: Prevents replay

## Reusability
Can be used by any DEX, lending protocol, or derivatives platform on GenLayer that needs reliable price feeds.

## Testing
Run 3 test cases:
1.  Success: 2 validators submit same price -> price finalized
2.  Fail: 3 validators submit different prices -> no consensus
3.  Outlier: 1 validator submits 10% different -> rejected

## Deployment
1.  Deploy with 3 validator wallet addresses
2.  Validators call submitPrice() each round
