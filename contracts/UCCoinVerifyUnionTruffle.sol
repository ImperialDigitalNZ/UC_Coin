// pragma solidity 0.4.19;   // mainnet 4.19
pragma solidity 0.4.18;     // truffle 4.18

import '../zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../zeppelin-solidity/contracts/math/SafeMath.sol';
import '../zeppelin-solidity/contracts/token/StandardToken.sol';

contract UCCoin is StandardToken, Ownable {

    string public constant name = "DOGE COIN";
    string public constant symbol = "DGE";
    uint8 public constant decimals = 8;

    uint256 public INITIAL_TOKEN_SUPPLY = 500000000 * (10 ** uint256(decimals));

    function MAX_UCCOIN_SUPPLY() public view returns (uint256) {
        return totalSupply.div(10 ** uint256(decimals));
    }

    function UCCoin() {
        totalSupply = INITIAL_TOKEN_SUPPLY;
        balances[msg.sender] = totalSupply;
    }
}

contract UCCoinVerifyUnionTruffle is UCCoin {

    uint256 public weiRaised;

    uint256 public UCCOIN_PER_ETHER = 1540;
    uint256 public MINIMUM_SELLING_UCCOIN = 150;

    bool public shouldStopCoinSelling = true;

    mapping(address => uint256) public contributions;
    mapping(address => bool) public blacklistAddresses;

    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);
    event UcCoinPriceChanged(uint256 value, uint256 updated);
    event UcCoinMinimumSellingChanged(uint256 value, uint256 updated);
    event UCCoinSaleIsOn(uint256 updated);
    event UCCoinSaleIsOff(uint256 updated);

    function UCCoinVerifyUnionTruffle() {

    }
    // users can buy UC Coin
    function() payable external {
        buyUcCoins();
    }
    // users can buy UC Coin
    function buyUcCoins() payable public {
        require(msg.sender != address(0));

        bool didSetUcCoinValue = UCCOIN_PER_ETHER > 0;
        require(!shouldStopCoinSelling && didSetUcCoinValue);
        require(blacklistAddresses[tx.origin] != true);

        uint256 weiAmount = msg.value;

        uint256 tokens = getUcCoinTokenPerEther().mul(msg.value).div(1 ether);

        require(tokens >= getMinimumSellingUcCoinToken());
        require(balances[owner] >= tokens);

        weiRaised = weiRaised.add(weiAmount);

        balances[owner] = balances[owner].sub(tokens);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        // send fund...
        owner.transfer(msg.value);

        contributions[msg.sender] = contributions[msg.sender].add(msg.value);

        TokenPurchase(msg.sender, weiAmount, tokens);
    }

    // convert UC amount per ether -> Token amount per ether
    function getUcCoinTokenPerEther() internal returns (uint256) {
        return UCCOIN_PER_ETHER * (10 ** uint256(decimals));
    }
    // convert minium UC amount to purchase -> minimum Token amount to purchase
    function getMinimumSellingUcCoinToken() internal returns (uint256) {
        return MINIMUM_SELLING_UCCOIN * (10 ** uint256(decimals));
    }

    // the contract owner sends tokens to the target address
    function sendTokens(address target, uint256 tokenAmount) external onlyOwner returns (bool) {
        require(target != address(0));
        require(balances[owner] >= tokenAmount);
        balances[owner] = balances[owner].sub(tokenAmount);
        balances[target] = balances[target].add(tokenAmount);

        Transfer(msg.sender, target, tokenAmount);
    }
    // the contract owner can set the coin value per 1 ether
    function setUCCoinPerEther(uint256 coinAmount) external onlyOwner returns (uint256) {
        require(UCCOIN_PER_ETHER != coinAmount);
        require(coinAmount >= MINIMUM_SELLING_UCCOIN);
        
        UCCOIN_PER_ETHER = coinAmount;
        UcCoinPriceChanged(UCCOIN_PER_ETHER, now);

        return UCCOIN_PER_ETHER;
    }
    // the contract owner can set the minimum coin value to purchase
    function setMinUCCoinSellingValue(uint256 coinAmount) external onlyOwner returns (uint256) {
        MINIMUM_SELLING_UCCOIN = coinAmount;
        UcCoinMinimumSellingChanged(MINIMUM_SELLING_UCCOIN, now);

        return MINIMUM_SELLING_UCCOIN;
    }
    // the contract owner can add a target address in the blacklist. if true, this means the target address should be blocked.
    function addUserIntoBlacklist(address target) external onlyOwner returns (address) {
        return setBlacklist(target, true);
    }
    // the contract owner can delete a target address from the blacklist. if the value is false, this means the target address is not blocked anymore.
    function removeUserFromBlacklist(address target) external onlyOwner returns (address) {
        return setBlacklist(target, false);
    }
    // set up true or false for a target address
    function setBlacklist(address target, bool shouldBlock) internal onlyOwner returns (address) {
        blacklistAddresses[target] = shouldBlock;
        return target;
    }  
    // if true, token sale is not available
    function setStopSelling() external onlyOwner {
        shouldStopCoinSelling = true;
        UCCoinSaleIsOff(now);
    }
    // if false, token sale is available
    function setContinueSelling() external onlyOwner {
        shouldStopCoinSelling = false;
        UCCoinSaleIsOn(now);
    }

    // the contract owner can push all remain UC Coin to the target address.
    function pushAllRemainToken(address target) external onlyOwner {
        uint256 remainAmount = balances[msg.sender];
        balances[msg.sender] = balances[msg.sender].sub(remainAmount);
        balances[target] = balances[target].add(remainAmount);

        Transfer(msg.sender, target, remainAmount);
    }
    // check target Address contribution
    function getBuyerContribution(address target) onlyOwner public returns (uint256 contribute) {
        return contributions[target];
    }
}