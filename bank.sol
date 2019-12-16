pragma solidity ^0.5.0;

contract Bank {
    // Dic that map address to balances
    mapping (address => uint256) private balances;
    // Users in the system
    address[] accounts;
    // Interest
    uint256 rate = 3;
    // system owner
    address public owner;
    
    // event
    event DepositMade(address indexed account, uint amount);
    event WithdrawMade(address indexed account, uint amount);
    event SystemWithdrawMade(address indexed account, uint256 amount);
    event SystemDeposit(address indexed account, uint256 amount);
    // one time
    constructor() public {
        owner = msg.sender;
    }
    
    function deposit() public payable returns (uint256) {
        if (0 == balances[msg.sender]) {
            accounts.push(msg.sender);
        }
        balances[msg.sender] = balances[msg.sender] + msg.value;
        
        emit DepositMade(msg.sender, msg.value);
        
        return balances[msg.sender];
    }
    
    function withdraw(uint amount) public returns (uint256) {
        require(balances[msg.sender] >= amount, "Balance is not enought");
        balances[msg.sender] -= amount;
        
        // send money back to user
        msg.sender.transfer(amount);
        // event
        emit WithdrawMade(msg.sender, amount);
        
        return balances[msg.sender];
    }
    
    function systemBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    function userBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
    
    function systemWithdraw(uint amount) 
        public returns (uint256) {
        require(owner==msg.sender, "Your are not authorized");
        require(systemBalance() >= amount, "System not enough.");
        
        msg.sender.transfer(amount);
        
        emit SystemWithdrawMade(msg.sender, amount);
        
        return systemBalance();
    }
    
    function systemDeposit() public payable returns (uint256) {
        require(owner==msg.sender, "Your are not authorized");
        
        emit SystemDeposit(msg.sender, msg.value);
        
        return systemBalance();
    }
    
    function calculateInterest(address user, uint256 _rate) 
        private view returns (uint256) {
        uint256 interest = balances[user] * _rate / 100;
        return interest;
    }
    
    function totalInterestPerYear() external view returns(uint256) {
        uint256 total =0;
        for(uint256 i=0; i<accounts.length; i++) {
            address account = accounts[i];
            uint256 interest = calculateInterest(account, rate);
            total += interest;
        }
        
        return total;
    }
    
    function payDividendsperYear() payable public {
        require(owner==msg.sender, "Your are not authorized");
        uint256 totalInterest = 0;
        for(uint256 i=0; i<accounts.length; i++) {
            address account = accounts[i];
            uint256 interest = calculateInterest(account, rate);
            balances[account] += interest;
            totalInterest += interest;
        }
        require(msg.value == totalInterest, "Not enough interest to pay!!!");
    }
}