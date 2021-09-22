// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract ProofOfExistence {
        enum StateType { Requested, InProgress, Successful, Rejected, Terminated }
        uint256 adhaarid;
        uint256 phone;
        string firstname;
        string lastname;
        string housenumber;
        string streetnumber;
        string city;
        string state;
        uint256 pincode;
        string pdflink;
        uint256 deadline;
        string rejectionReason;
        string status;
        StateType public states;
    
        address owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        address verifier = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
        
        
    constructor(uint256 _adhaarid,uint256 _phone,string memory _firstname,string memory _lastname,string memory _housenumber,string memory _streetnumber,string memory _city,string memory _state,uint256 _pincode,string memory _pdflink) public{
        adhaarid = _adhaarid;
        phone = _phone;
        firstname = _firstname;
        lastname = _lastname;
        housenumber = _housenumber;
        streetnumber = _streetnumber;
        city = _city;
        state = _state;
        pincode = _pincode;
        pdflink = _pdflink;
        deadline = block.timestamp + 7200; //Time is in seconds, deadline is 2hours.
        status = "Requested";
        states = StateType.Requested;
    }
    
    modifier canSee{
        require(msg.sender==owner || msg.sender==verifier);
        _;
    }
    
    function getDetails() view public canSee returns (uint256,uint256,string memory,string memory,string memory,string memory,string memory,string memory,uint256,string memory) {
        return (adhaarid,phone,firstname,lastname,housenumber,streetnumber,city,state,pincode,pdflink);
    }
    
    function getStatus() view public canSee returns (string memory,string memory){
        return (status,rejectionReason);
    }
    
    function beginReview() public canSee {
        require(block.timestamp <= deadline);
        if(owner == msg.sender)
        {
            revert();
        }
        status = "InProgress";
        states = StateType.InProgress;
    }
    
    function acceptDocument() public canSee {
        require(block.timestamp <= deadline && states==StateType.InProgress);
        if(owner == msg.sender)
        {
            revert();
        }
        status = "Successful";
        states = StateType.Successful;
    }
    
    function rejectDocument(string memory _rejectionReason) public canSee {
        require(block.timestamp <= deadline && states != StateType.Successful);
        if(owner == msg.sender)
        {
            revert();
        }
        status = "Rejected";
        states = StateType.Rejected;
        rejectionReason = _rejectionReason;
    }
    
    function Terminate() public canSee{
        require(block.timestamp <= deadline);
        if (states==StateType.Successful || states==StateType.Rejected || block.timestamp==deadline)
        {
            owner = address(0);
            verifier = address(0);
            status = "Terminated";
            states = StateType.Terminated;
        }
        
    }
    
}
