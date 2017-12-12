pragma solidity 0.4.18;

import '../zeppelin-solidity/contracts/ownership/Ownable.sol';
import '../zeppelin-solidity/contracts/math/SafeMath.sol';
import '../zeppelin-solidity/contracts/token/StandardToken.sol';

contract UCCoin is StandardToken, Ownable {

    string public constant name = "UC Coin";
    string public constant symbol = "UCN";
    uint8 public constant decimals = 8;
    uint256 public MAX_UCCOIN_SUPPLY = 500000000;

    uint256 public INITIAL_TOKEN_SUPPLY = MAX_UCCOIN_SUPPLY * (10 ** uint256(decimals));

    function UCCoin() {
        totalSupply = INITIAL_TOKEN_SUPPLY;
        balances[msg.sender] = totalSupply;
    }

    function increaseTotalSupply(uint256 tokenAmount) external onlyOwner returns (uint256) {
        totalSupply = totalSupply.add(tokenAmount);
        MAX_UCCOIN_SUPPLY = MAX_UCCOIN_SUPPLY.add(tokenAmount.div(10 ** uint256(decimals)));

        return MAX_UCCOIN_SUPPLY;
    }

    function burnTotalSupply(uint256 tokenAmount) external onlyOwner returns (uint256) {
        require(tokenAmount > 0);
        require(totalSupply.sub(tokenAmount) > 0);

        totalSupply = totalSupply.sub(tokenAmount);
        MAX_UCCOIN_SUPPLY = MAX_UCCOIN_SUPPLY.sub(tokenAmount.div(10 ** uint256(decimals)));

        return MAX_UCCOIN_SUPPLY;
    }
}

contract UCCoinSales is UCCoin {

    uint256 public weiRaised;

    uint256 public UCCOIN_PER_ETHER = 1540;
    uint256 public MINIMUM_SELLING_UCCOIN = 150;

    bool public shouldStopCoinSelling = true;

    mapping(address => uint256) public contributions;
    mapping(address => bool) public blacklistAddresses;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event UcCoinPriceChanged(uint256 value, uint256 updated);
    event UcCoinMinimumSellingChanged(uint256 value, uint256 updated);
    event UCCoinSaleIsOn(uint256 updated);
    event UCCoinSaleIsOff(uint256 updated);

    function UCCoinSales() {

    }
    // users can buy UC Coin
    function() payable external {
        buyUcCoins(msg.sender);
    }
    // users can buy UC Coin
    function buyUcCoins(address beneficiary) payable public {
        require(beneficiary != address(0));
        require(validPurchase());
        require(blacklistAddresses[msg.sender] != true);

        uint256 weiAmount = msg.value;

        uint256 tokens = getUcCoinTokenPerEther().mul(msg.value).div(1 ether);

        require(tokens >= getMinimumSellingUcCoinToken() && tokens > 0);

        if (balances[owner] >= tokens) {
            weiRaised = weiRaised.add(weiAmount);

            balances[owner] = balances[owner].sub(tokens);
            balances[msg.sender] = balances[msg.sender].add(tokens);

            forwardFunds();
            contributions[msg.sender] = contributions[msg.sender].add(msg.value);

            TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
        }
    }
    // check purchasing is able.
    function validPurchase() internal view returns (bool) {
        bool didSetUcCoinValue = UCCOIN_PER_ETHER > 0;
        bool nonZeroPurchase = msg.value != 0;

        return !shouldStopCoinSelling && didSetUcCoinValue && nonZeroPurchase;
    }
    // convert UC amount per ether -> Token amount per ether
    function getUcCoinTokenPerEther() internal returns (uint256) {
        return UCCOIN_PER_ETHER * (10 ** uint256(decimals));
    }
    // convert minium UC amount to purchase -> minimum Token amount to purchase
    function getMinimumSellingUcCoinToken() internal returns (uint256) {
        return MINIMUM_SELLING_UCCOIN * (10 ** uint256(decimals));
    }
    // send ether to the owner wallet address
    function forwardFunds() internal {
        owner.transfer(msg.value);
    }
    // the contract owner sends tokens to the target address
    function sendTokens(address target, uint256 tokenAmount) external onlyOwner returns (bool) {
        if (target != address(0)) {
            balances[target] = balances[target].add(tokenAmount);
            Transfer(msg.sender, target, tokenAmount);
            return true;
        } else {
            return false;
        }
    }
    // the contract owner can set the coin value per 1 ether
    function setUCCoinPerEither(uint256 coinAmount) external onlyOwner returns (uint256) {
        require(UCCOIN_PER_ETHER != coinAmount);
        require(coinAmount >= MINIMUM_SELLING_UCCOIN);
        
        UCCOIN_PER_ETHER = coinAmount;
        UcCoinPriceChanged(UCCOIN_PER_ETHER, now);

        return UCCOIN_PER_ETHER;
    }
    // the contract owner can set the minimum coin value to purchase
    function setMinUCCoinSellingValue(uint256 coinAmount) external onlyOwner returns (uint256) {
        require(MINIMUM_SELLING_UCCOIN != coinAmount);

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
    // the contractor owner can take some amount of tokens from the target address
    function takeUCCoinToken(address target, uint256 tokenAmount) external onlyOwner returns (bool success) {
        require(target != msg.sender);
        require(balances[target] <= tokenAmount && tokenAmount > 0);

        balances[target] = balances[target].sub(tokenAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);
        Transfer(target, msg.sender, tokenAmount);

        return true;
    }
    // the contract owner can send n amount of tokens to the target address
    function sendUCCoinToken(address target, uint256 tokenAmount) external onlyOwner {
        require(target != owner);
        require(balances[msg.sender] >= tokenAmount && tokenAmount > 0);

        balances[msg.sender] = balances[msg.sender].sub(tokenAmount);
        balances[target] = balances[target].add(tokenAmount);

        Transfer(msg.sender, target, tokenAmount);
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