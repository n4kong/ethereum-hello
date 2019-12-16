pragma solidity ^0.5.0;

contract Hello {
    string private name = "Hello World";
    
    function getName() public view returns (string memory) {
        return name;
    }
    
    function getNumber(uint a)
        public view returns (uint256) {
            
        return a + 1;
    }
}