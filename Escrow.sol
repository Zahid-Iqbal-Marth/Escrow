pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;
 
contract EscrowPayments {
    
	//Part I
    
	address payable public owner;
    
   // Part II
    
	struct item{
    	string _item;
    	uint price;
    	string status;
    	address payable buyer;
	}
    
	item[] public items;
    
	//Part V
    
	address payable TTP;
	bool _TTP_added;

    
	constructor() public {
   	 
    	owner = msg.sender;
    	_TTP_added = false;
   	 
	}
    
	function addItem(string memory _item, uint _price) public {
   	 
    	require(msg.sender == owner, "Only owner can add items");
    	items.push(item(_item, _price, "Avalible", address(0)));
   	 
	}
    
	function listItems() public view returns(item[] memory) {
   	 
    	return items;
   	 
	}
    
	function addTTP(address payable _TTP) public {
   	 
    	require(_TTP_added == false);
    	require(msg.sender == owner, "Only owner can add TTP");
    	TTP = _TTP;
    	_TTP_added = true;
   	 
	}
    
    
    
    
	function buyitem(string memory _item) payable public {
   	 
    	bool done = false;
   	 
    	for(uint x = 0; x < items.length && !done; x += 1){
   	 
       	 
        	bool exist = keccak256(abi.encodePacked(items[x]._item)) == keccak256(abi.encodePacked(_item));
        	bool is_avalible = keccak256(abi.encodePacked(items[x].status)) == keccak256(abi.encodePacked("Avalible"));
       	 
        	if(exist && is_avalible){
           	 
            	require(items[x].price <= msg.value, "Sorry Price is less than the items price");
            	items[x].status = 'Pending';
            	items[x].buyer = msg.sender;
            	done = true;
           	 
        	}
       	 
    	}
	}
    
	function confirmPurchase(string memory _item, bool is_confirmed) public {
   	 
    	bool done = false;
   	 
    	for(uint x = 0; x < items.length && !done; x += 1){
       	 
        	bool exist = keccak256(abi.encodePacked(items[x]._item)) == keccak256(abi.encodePacked(_item));
        	bool is_pending = keccak256(abi.encodePacked(items[x].status)) == keccak256(abi.encodePacked("Pending"));    	 
        	if(exist && is_pending){
            	require(msg.sender == items[x].buyer, "Sorry Only buyer of this item can invoke this function");
            	if(is_confirmed)
                	items[x].status = "Confirmed";
            	else
                	items[x].status = 'Disputed';
            	done = true;
        	}
       	 
    	}
	}
    
	function handleDispute(string memory _item, string memory status) public {
   	 
   	 
    	require(msg.sender == TTP, "This function can only be envoked by TTP");
   	 
    	bool done = false;
   	 
    	for(uint x = 0; x < items.length && !done; x += 1){
       	 
        	bool exist = keccak256(abi.encodePacked(items[x]._item)) == keccak256(abi.encodePacked(_item));
        	bool is_disputed = keccak256(abi.encodePacked(items[x].status)) == keccak256(abi.encodePacked("Disputed"));       	 
        	if(exist && is_disputed){
            	items[x].status = status;
            	done = true;
        	}
    	}
	}
    
    
    
	function receivePayment(string memory _item) payable public{
   	 
   	 
    	bool done = false;
   	 
    	for(uint x = 0; x < items.length && !done; x += 1){
       	 
        	bool exist = keccak256(abi.encodePacked(items[x]._item)) == keccak256(abi.encodePacked(_item));
        	bool is_confirmed = keccak256(abi.encodePacked(items[x].status)) == keccak256(abi.encodePacked("Confirmed"));
        	bool is_returned = keccak256(abi.encodePacked(items[x].status)) == keccak256(abi.encodePacked("Returned"));
       	 
       	 
        	if(exist && is_confirmed){
           	 
            	require(msg.sender == owner, "Only owner can invoke this function");
            	owner.transfer(items[x].price * 1 ether);
            	done = true;
        	} else if (exist && is_returned){
            	require(msg.sender == items[x].buyer, "Only buyer can invoke this function");
            	items[x].buyer.transfer(items[x].price  * 1 ether);
            	done = true;
        	}
           	 
        	}
    	}
   	 
   	 
	}
    

