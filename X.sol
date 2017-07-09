// ----------------------------------------------------------------------------------------------
// X Foundation token for the advancement of decentralised AI and robotics
// Symbol: |X|
// Total Supply: 1,000,000,000 Fixed.
// 
// Partly dedicated to GameKyuubi - Spartans Hodl.
// ----------------------------------------------------------------------------------------------
pragma solidity ^0.4.13;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";



/* Contract Ownership */
contract owned 
{
	address public owner;

	function owned() 
	{
        	owner = msg.sender;
	}

	modifier onlyOwner 
	{
        	if (msg.sender != owner) throw;
        	_;
	}

	function transferOwnership(address newOwner) onlyOwner 
	{
        	owner = newOwner;
	}
}

/* ERC20 interface */
contract ERC20Interface 
{
	// Get the total token supply
	function totalSupply() constant returns (uint256 totalSupply);

	// Get the account balance of another account with address _owner
	function balanceOf(address _owner) constant returns (uint256 balance);

	// Send _value amount of tokens to address _to
	function transfer(address _to, uint256 _value) returns (bool success);
 
	// Send _value amount of tokens from address _from to address _to 
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
 
	// Allow _spender to withdraw from your account, multiple times, up to the _value amount. 
	// If this function is called again it overwrites the current allowance with _value. 
	// this function is required for some DEX functionality 
	function approve(address _spender, uint256 _value) returns (bool success);
 
	// Returns the amount which _spender is still allowed to withdraw from _owner
	function allowance(address _owner, address _spender) constant returns (uint256 remaining);
 
	// Triggered when tokens are transferred.
	event Transfer(address indexed _from, address indexed _to, uint256 _value);

	// Triggered whenever approve(address _spender, uint256 _value) is called. 
	event Approval(address indexed _owner, address indexed _spender, uint256 _value); 
}

contract X is owned, ERC20Interface, usingOraclize 
{
    event test(uint value);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
	mapping (address => uint256) public balances;
	struct donation
	{
        address _donationAddress;
        uint _donationAmount;
    }
    donation[] public _donations;
	donation[] public regularDonations;
	
	mapping(address => mapping (address => uint256)) allowed;
	
	string public constant name = "X";
	string public constant symbol = "|X|";
	uint public constant decimals = 8;

	uint _totalSupply = 100000000000000000;
	uint _totalDonationSupply = 1000000000000000;
	
	//Ether values
	uint public _totalDonations = 0;
	uint public _regularDonationsTotal = 0;
	
	uint public _crowdSaleSupply = 100000000000000;
	uint public _donationSupply = 1000000000000000;
	uint public _foundationSupply = 13000000000000000;
	uint public _AIExchangeSupply = 10900000000000000;
	uint public _lotterySupply = 18750000000000000;
	uint public _mineableSupply = 56250000000000000;
	
	uint _presalePrice = 0.0035 ether; //not used - here for posterity
	uint _julPrice = 0.00525 ether;
	uint _augPrice = 0.065 ether;
	uint _sepPrice = 0.007 ether;
	uint _octPrice = 0.0077 ether;
	uint _novPrice = 0.00875 ether;
	uint _decPrice = 0.01 ether;

	uint _aug17 = 1501545600;
	uint _sep17 = 1504224000;
	uint _oct17 = 1506816000;
	uint _nov17 = 1509494400;
	uint _dec17 = 1512086400;
	uint _jan18 = 1514764800;
	
	//gas price
	uint public oraclizeGasPrice = 200000;

	function X() 
	{
		//Addresses to send tokens to
		address AIExchange = 0x0035c4C86f15ba80319853df6092C838bA9B39C8;
		address preSale1 = 0x0664B21FD33865c2259d2674f75b8C2a1A4e27A7; // 11 tokens, donated 0.0015 ether
		address preSale2 = 0xaA41e0F9f4A19719007C53064B6979bDB6DF8b8c; // 628 tokens, 0.002 ether
		address preSale3 = 0x32Be343B94f860124dC4fEe278FDCBD38C102D88; // 80 tokens, 0 donation
		address preSale4 = 0x7eD1E469fCb3EE19C0366D829e291451bE638E59; // 10 tokens, 0 donation
		address preSale5 = 0x8aa50dfc95Ab047128ccDc6Af4BA2dDbA8D0A874; // Bitcoin sale, 200 tokens, 0 donation 
		
		//Allocation to the X Foundation and AI Exchange
		balances[msg.sender] = _foundationSupply;
		balances[AIExchange] = _AIExchangeSupply;
		_foundationSupply -= _foundationSupply;
		_AIExchangeSupply -= _AIExchangeSupply;
		
		//Allocation to presale addresses (before contract deployment.)
		balances[preSale1] = 1100000000; 
		_donations.push(donation({_donationAddress: preSale1, _donationAmount: 0.0015 ether}));
		_totalDonations += 0.0015 ether;
		_crowdSaleSupply -= balances[preSale1];

		balances[preSale2] = 62800000000;
		_donations.push(donation({_donationAddress: preSale2, _donationAmount: 0.002 ether}));
		_totalDonations += 0.002 ether;
		_crowdSaleSupply -= balances[preSale2];

		balances[preSale3] = 8000000000;
		_crowdSaleSupply -= balances[preSale3];

		balances[preSale4] = 1000000000;
		_crowdSaleSupply -= balances[preSale4];

		balances[preSale5] = 20000000000;
		_crowdSaleSupply -= balances[preSale5];
	}

    /* Runs when Ether is sent to the contract address */
	function () payable
	{
		uint amount = msg.value;
		if (now > _jan18)
		{
			regularDonations.push(donation({_donationAddress: msg.sender, _donationAmount: amount}));
			_regularDonationsTotal += amount;
			return;
		}
		uint crowdSaleCost = getCurrentTokenCost();
		if (amount < crowdSaleCost)
		{
			revert(); //whole token purchases only
		}
		uint wholeNumTokens = amount/crowdSaleCost; 
		uint remainderEth = amount - ((amount/crowdSaleCost)*crowdSaleCost);
		
		if ((_crowdSaleSupply/(10**decimals)) >= wholeNumTokens)
		{
			balances[msg.sender] = wholeNumTokens * (10**decimals);
			_crowdSaleSupply -= wholeNumTokens * (10**decimals);
			if(remainderEth > 0)
			{
				_donations.push(donation({_donationAddress: msg.sender, _donationAmount: remainderEth}));
				_totalDonations += remainderEth;
			}
		}
		else
		{
			if(_crowdSaleSupply > 0 && (_crowdSaleSupply/(10**decimals)) < wholeNumTokens)
			{
			    balances[msg.sender] = _crowdSaleSupply;
			    uint donationEth = (wholeNumTokens - (_crowdSaleSupply/(10**decimals))) * crowdSaleCost;
			    _donations.push(donation({_donationAddress: msg.sender, _donationAmount: donationEth}));
			    _totalDonations += donationEth;
			    _crowdSaleSupply = 0;
			}
			else
			{
			    _donations.push(donation({_donationAddress: msg.sender, _donationAmount: amount}));
			    _totalDonations += amount;
			}
		}
		
	}	

    function simpleTest() returns (uint num)
    {
        return _donations.length;
    }
	function crowdSaleDonate() payable returns (bool success)
	{
		if (now > _jan18)
		{
			revert();
		}

		uint amount = msg.value;
		if (amount > 0)
		{
		    _donations.push(donation({_donationAddress: msg.sender, _donationAmount: amount}));
		    _totalDonations += amount;
		    return true;
		}
		else
		{
		    return false;
		}
	}

	function getCurrentTokenCost() returns (uint crowdSaleCost)
	{
		if(now < _aug17)
		{
			return _julPrice;
		}
		else if(now < _sep17)
		{
			return _augPrice;
		}
		else if(now < _oct17)
		{
			return _sepPrice;
		}
		else if(now < _nov17)
		{
			return _octPrice;
		}
		else if(now < _dec17)
		{
			return _novPrice;
		}
		else
		{
			return _decPrice;
		}
	}
	
	function distributeDonationTokens() onlyOwner returns (bool success)
	{
	    if (now > _jan18)
	    {
	        return false;
	    }
	    else if (_donations.length == 0)
	    {
	        return false;
	    }
	    else
	    {
	        //distribute to 1000 addresses at a time to reduce impact on blockchain service.
	        uint currentDistribution = 0;
	        while(_donations.length - currentDistribution > 0)
	        {
	            donation currentDonor = _donations[_donations.length - currentDistribution - 1];
	            uint transferAmount = ((_totalDonationSupply * currentDonor._donationAmount)/(_totalDonations));
	            balances[currentDonor._donationAddress] += transferAmount;
	            delete _donations[_donations.length - currentDistribution - 1];
	            currentDistribution += 1;
	        }
	        return true;
	    }
	}
	
	function changeOraclizeGasPrice(uint price) onlyOwner returns (bool success)
	{
	    oraclizeGasPrice = price;
	    return true;
	}
	
	function withdrawFunds() onlyOwner returns (bool success)
	{
	    owner.call.gas(200000).value(this.balance)();
	    return true;
	}

	/* ========== ERC20 implementations ========== */
	function totalSupply() constant returns (uint256 totalSupply)
	{
        	totalSupply = _totalSupply;
    } 
 
    function balanceOf(address _owner) constant returns (uint256 balance) 
	{
        	return balances[_owner];
	}

	function transfer(address _to, uint256 _value) returns (bool success)
	{
		if (balances[msg.sender] < _value || balances[_to] + _value < balances[_to])
		{
        	revert();
        	return false;
		}
    	balances[msg.sender] -= _value;
    	balances[_to] += _value;
    	Transfer(msg.sender, _to, _value);
    	return true;
	}

	function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) 
	{ 
        	if (balances[_from] >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) 
		{
            		balances[_from] -= _amount; 
            		allowed[_from][msg.sender] -= _amount;
           		balances[_to] += _amount; 
            		Transfer(_from, _to, _amount);
            		return true;
        	} 
		else 
		{
            		return false;
        	}
    	}

	function approve(address _spender, uint256 _amount) returns (bool success)
	{
        	allowed[msg.sender][_spender] = _amount; 
        	Approval(msg.sender, _spender, _amount); 
        	return true; 
	}

	function allowance(address _owner, address _spender) constant returns (uint256 remaining) 
	{
        	return allowed[_owner][_spender]; 
	}
    
    function __callback(bytes32 myid, string result) 
    {
        if (msg.sender != oraclize_cbAddress()) 
        {
            throw;
        }
        address lotteryWinner = parseAddr(result);
		if (_lotterySupply >= (1 * 10**decimals))
		{
			_lotterySupply -= 1 * (10**decimals);
			balances[lotteryWinner] += 1 * (10**decimals);
		}
		else
		{
			balances[lotteryWinner] += _lotterySupply;
			_lotterySupply -= _lotterySupply;	
		}
    }

	/* ========== Block Rewards =============*/
	function giveBlockReward() payable
	{
		//lottery reward
		oraclize_query("URL", "json(https://digitx.io/GetLotteryWinner.aspx).winner", oraclizeGasPrice);
		
		//miner reward
		if (_mineableSupply >= (3 * 10**decimals))
		{
			_mineableSupply -= 3 * (10**decimals);
			balances[block.coinbase] += 3 * (10**decimals);
		}
		else
		{
		    balances[block.coinbase] += _mineableSupply;
			_mineableSupply -= _mineableSupply;	
		}
	}
	
}
