pragma solidity ^0.5.2;

contract Boson {
    

struct product {
	string name;
	uint price;
	address owner;
}

mapping (address => uint) public balance;
mapping (string => product) products;

address public arbitrator;

address private owner = msg.sender;

function credit(uint amount) private {
    balance[msg.sender] = amount;
}

constructor() {
  // Developer needs to run this first so that their address becomes the arbitrator.
  arbitrator = msg.sender;
}

modifier accountOwner {
	require(msg.sender == owner);
	_;
}

function credit(uint amount) public payable {
  require(msg.value == amount);
  balance[msg.sender] = amount;
  emit returnBalance(balance[msg.sender]);
}

function deposit(uint amount) public payable accountOwner {
  require(msg.value == amount);
	balance[msg.sender] += amount;
  emit returnBalance(balance[msg.sender]);
}

event offered(product product);

function offer(string memory name, uint price ) public returns (bool success) {
    //   if (bytes(products[name].name.length) == 0) {
      // require(msg.value == price);
	    products[name].name = name;
        products[name].price = price;
        products[name].owner = owner;
        emit offered(products[name]);
        return true;
    //   } else {
    //      return false;
    //   }
}

uint public escrowAmount;

struct tradeDetails {
  uint price;
  address sellerId;
  bool complete;
}

mapping (bytes32 => tradeDetails) Trades;

event productOrdered(string productName);

function order(string memory productName) public returns (bool success) {
  product memory productDetails = products[productName];
  if (balance[msg.sender] >= productDetails.price) {
    escrowAmount += productDetails.price;
    bytes memory stringAddress = abi.encodePacked(msg.sender);
    bytes32 tradeID = keccak256(abi.encodePacked(stringAddress, productName));
    Trades[tradeID].price = productDetails.price;
    Trades[tradeID].sellerId = productDetails.owner;
    Trades[tradeID].complete = false;

    balance[msg.sender] -= productDetails.price;
    emit productOrdered(productName);
    return true;
  }
  return false;
}

function complain(string memory productName) public returns (bool success) { 
  bytes memory stringAddress = abi.encodePacked(msg.sender);
  bytes32 tradeID = keccak256(abi.encodePacked(stringAddress, productName));
  if (Trades[tradeID].complete == false && Trades[tradeID].price > 0) {
    escrowAmount += Trades[tradeID].price;
    balance[msg.sender] += Trades[tradeID].price;
    Trades[tradeID].complete = true;
    return true;
  } else {
  return false;
}
}

event tradeComplete(string trade)

function complete(string memory productName) public {
  bytes memory stringAddress = abi.encodedPacked(msg.sender);
  bytes32 tradeID = keccak256(abi.encodePacked(stringAddress, productName));
  if (Trades[tradeID].complete == false && Trades[tradeID].price > 0) {
    escrowAmount -= Trades[tradeID].price;
    balance[Trades[tradeID].sellerId] += Trades[tradeID].price;
    Trades[tradeID].complete = true;
    emit tradeComplete('trade complete');
    return true;
  } else {
  return false;
}

event returnBalance(uint amountInEscrow);

function AmountInEscrow() public returns (uint) {
  emit returnBalance(escrowAmount);
  return escrowAmount;
}

function getBalance() public return uint {
  emit returnBalance(balance[msg.sender]);
  return balance[msg.sender];
}

}
