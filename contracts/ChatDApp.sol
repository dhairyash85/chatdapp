// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract ChatDApp{
    struct user{
        string name;
        friend[] friendlist;
    }

    struct friend{
        address pubkey;
        string name;
    }

    struct message{
        address sender;
        uint256 timestamp;
        string mssg;
    }

    struct AllUserStruck{
        string name;
        address acc;
    }

    AllUserStruck[] getAllUsers;

    mapping(address => user) userList;
    mapping(bytes32 => message[]) allMessages;

    function cheskUserExists(address _pubkey) public view returns(bool){
        return bytes(userList[_pubkey].name).length>0;
    }

    function checkAlreadyFriends(address _user1, address _user2)internal view returns(bool){
        if(userList[_user1].friendlist.length>userList[_user2].friendlist.length){
            address temp=_user1;
            _user1=_user2;
            _user2=temp;
        }
        for(uint256 i=0;i<userList[_user1].friendlist.length;i++){
            if(userList[_user1].friendlist[i].pubkey==_user2) return true;
        }
        return false;
    }

    function createAccount(string calldata _name) external {
        require(!cheskUserExists(msg.sender), "User already exists");
        require(bytes(_name).length>0, "Think of a username nigga");
        userList[msg.sender].name=_name;
        getAllUsers.push(AllUserStruck(_name, msg.sender));
    }

    function getUserName(address _user) external view returns(string memory){
        require(!cheskUserExists(msg.sender), "User already exists");
        return userList[_user].name;
    }
    function addFriend(string calldata _name, address _pubkey) external{
        require(cheskUserExists(msg.sender), "Create an account first");
        require(cheskUserExists(_pubkey), "User not registered");
        require(msg.sender!=_pubkey, "Get some friends nigga");
        require(!checkAlreadyFriends(msg.sender, _pubkey), "Get some new friends nigga");
        userList[msg.sender].friendlist.push(friend(_pubkey, _name));
        userList[_pubkey].friendlist.push(friend(msg.sender, userList[msg.sender].name));   
    }

    function getMyFriends() external view returns(friend[] memory){
        return userList[msg.sender].friendlist;
    }

    function _getChatCode(address _pubkey1, address _pubkey2)internal pure returns(bytes32) {
        if(_pubkey1<_pubkey2){
            return keccak256(abi.encodePacked(_pubkey1, _pubkey2));
        } else 
        return keccak256(abi.encodePacked(_pubkey2, _pubkey1));
    }

    function sendMessage(address _friend, string calldata _mssg) external{
        require(cheskUserExists(msg.sender), "Create an account first");
        require(cheskUserExists(_friend), "User not registered");
        require(checkAlreadyFriends(msg.sender, _friend), "You are not homies nigga");
        bytes32 chatcode = _getChatCode(msg.sender, _friend);
        allMessages[chatcode].push(message(msg.sender, block.timestamp, _mssg));
    }

    function readMessage(address _friend) external view returns(message[] memory){
        bytes32 chatCode=_getChatCode(msg.sender, _friend);
        return allMessages[chatCode];
    }

    function getAllAppUsers() public view returns(AllUserStruck[] memory){
        return getAllUsers;
    }
}