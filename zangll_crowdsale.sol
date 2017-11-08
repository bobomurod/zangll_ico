pragma solidity ^0.4.16;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface Zangll {

	function balanceOf(address who) public constant returns (uint256);
  	function transfer(address to, uint256 value) public returns (bool);
  	function allowance(address owner, address spender) public constant returns (uint256);
  	function transferFrom(address from, address to, uint256 value) public returns (bool);
  	function approve(address spender, uint256 value) public returns (bool);

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
  address public owner;
 
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }
 
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}

contract CrowdsaleZangll is Ownable {
	mapping(address => uint256) purchases;  // сколько токенов купили на данный адрес 

	event Debag (string message);
	event TokenPurchased(address purchaser, uint256 value, uint amount);
	//event LowTokensOnContract(uint amount);

    
  	using SafeMath for uint;
    
  	address multisig;   			//тот кому идут эфиры (creator of contract)
 
  	//uint restrictedPercent;		
 
  	//address restricted;
 
  	Zangll token = Zangll(0x632E15775Acb67303178aa8b08A26ba594f18D84);
 
  	uint start;		// start of CrowdsaleZangll
    
  	uint period;		// period of sale 
 
  	uint priceInCents;		

  	uint ETHUSD;		// how many USD cents in 1 ETH 

  	uint256 purchaseCap; // max purchase for a single address

  	uint256 public totalPurchased;  // total tokens purchased on crowdsale PUBLIC!!!

  	uint256 maxPurchase; // max tokens to crowdsale
 
  	function CrowdsaleZangll() {
	  	ETHUSD = 30000;
	    multisig = msg.sender;
	    //restricted = 0xb3eD172CC64839FB0C0Aa06aa129f402e994e7De;
	    //restrictedPercent = 30;
	    priceInCents = 27;  	// price in USD cents for 1 token 
	    start = 1510052062;		// 7 ноября 10 утра 2017
	    period = 28;
	    purchaseCap = 3000000 * 10 ** 18;  // 3_000_000 tokens to one address 
	    totalPurchased = 0;
	    maxPurchase = 140000000; // 140_000_000 tokens sales on crowdsale 
	    Debag("crowdsale inits");
  	}

  	function purchasesOf(address purchaser) public constant returns (uint256 value) {
    	return purchases[purchaser];
  	}
 
  	modifier saleIsOn() {
    	require(now > start && now < start + period * 1 days);
    	require(totalPurchased <= maxPurchase);
    	_;
  	}

  	/*
		посылая 1 эфир инвестор получает 30000 центов = 30_000 / 27 ~ 1_111.(1) токенов
  	*/
 
  	function createTokens() saleIsOn payable {

  		require(purchases[msg.sender] < purchaseCap); 		// не купил ли на 3 млн уже
	    //uint tokens = rate.mul(msg.value).div(1 ether);
	    uint tokens = msg.value.mul(ETHUSD).div(priceInCents);  // вычисление токенов за присланный эфир
	    uint bonusTokens = 0;
	    //Debag("base tokens = " + string(tokens));
	    if(now < start + 1 hours ) {   									//1 hour 
	      bonusTokens = tokens.mul(35).div(100);
	    } else if(now >= start + 1 hours && now < start + 1 days) {		//1 day 
	      bonusTokens = tokens.mul(30).div(100);
	    } else if(now >= start + start + 1 days && now < start + 2 days) { // 2 day 
	      bonusTokens = tokens.mul(25).div(100);
	    } else if(now >= start + 2 days && now < start + 1 weeks) {		//1 week
	      bonusTokens = tokens.mul(20).div(100);
	    } else if(now >= start + 1 weeks && now < start + 2 weeks) {	//2 weeks
	      bonusTokens = tokens.mul(15).div(100);
	    } else if(now >= start + 2 weeks && now < start + 3 weeks) {		// 3 week
	      bonusTokens = tokens.mul(10).div(100);
	    }
	    uint tokensWithBonus = tokens.add(bonusTokens);

	    // if (token.balanceOf(this) < tokensWithBonus) {
	    // 	LowTokensOnContract(token.balanceOf(this));
	    // }
	    require(token.balanceOf(this) >= tokensWithBonus);
	    require(purchases[msg.sender] + tokensWithBonus <= purchaseCap);
	    require(maxPurchase >= totalPurchased + tokensWithBonus);	// 
	    //Debag("total tokens = " + string(tokensWithBonus));	    
	    TokenPurchased(msg.sender, msg.value, tokensWithBonus);  // ивент покупки токенов (покупатель, цена в эфирах, кол-во токенов)
	    purchases[msg.sender].add(tokensWithBonus);			// записать на адрес сумму купленных токенов
	    totalPurchased.add(tokensWithBonus);				// суммировать все купленные токены
	    multisig.transfer(msg.value);						// перевод создателю всего эфира 
	    token.transfer(msg.sender, tokensWithBonus);		// контракт с себя переводит токены инвестору
	    //token.transfer(msg.sender tokensWithBonus);
	    // uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
	    // token.transfer(restricted, restrictedTokens);
  	}
 
  function() external payable {
    createTokens();
  }
    
}

