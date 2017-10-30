pragma solidity ^0.4.16;

//определяем нужные параметры для стандарта ERC20
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

//Унаследуем параметры и дополняем их
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//пишем базовый токен

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  //Функция трансфера токенов
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub остановит если не достаточно ткенов на балансе
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

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




/**
 * @title SimpleToken
 * @dev Простой токен с функией трансфера и унаследующий все возможности Standart token
 */
contract Zangll is StandardToken {

  string public constant name = "Zangll";
  string public constant symbol = "ZNGL";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 200000000 * (10 ** uint256(decimals));

  /**
   * @dev Cконструктор который передает все токены msg.sender у
   */
  function Zangll() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

}

/**
 * @title Ownable
 * @dev представляет собой базовую авторизацию для управления конрактом
 */
contract Ownable {
    
  address public owner;
 
  /**
   * @dev консруктор для определения управляющего конрактом
   */
  function Ownable() {
    owner = msg.sender;
  }
 
  /**
   * @dev прекращать выполнение если кто-то другой вызвал функции управления
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
  /**
   * @dev перевод управления на прелствителя с другого адреса
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}

//краусейл не закончен 

contract CrowdsaleZangll is Ownable {
    
  using SafeMath for uint;
    
  address multisig;
 
  uint restrictedPercent;
 
  address restricted;
 
  Zangll public token = new Zangll();
 
  uint start;
    
  uint period;
 
  uint rate;

  uint ETHUSD;
 
  function CrowdsaleZangll() {
  	ETHUSD = 30000;
    multisig = msg.sender;
    //restricted = 0xb3eD172CC64839FB0C0Aa06aa129f402e994e7De;
    restrictedPercent = 30;
   // rate = 27;
    start = 1500379200;
    period = 28;
  }
 
  modifier saleIsOn() {
    require(now > start && now < start + period * 1 days);
    _;
  }
 
  function createTokens() saleIsOn payable {
    multisig.transfer(msg.value);
    //uint tokens = rate.mul(msg.value).div(1 ether);
    uint tokens = msg.value.mul(ETHUSD).div(rate).div(1 ether);
    uint bonusTokens = 0;
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
    multisig.transfer(msg.sender, tokensWithBonus);
    //token.transfer(msg.sender, tokensWithBonus);
    // uint restrictedTokens = tokens.mul(restrictedPercent).div(100 - restrictedPercent);
    // token.transfer(restricted, restrictedTokens);
  }
 
  function() external payable {
    createTokens();
  }
    
}

