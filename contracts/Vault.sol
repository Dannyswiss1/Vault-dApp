//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Vault {


    struct Grant {
        address payable beneficiary;
        uint256 amount;
        uint256 vestingTime;
    }

    mapping(address => Grant) public grants;

    event GrantCreated(address donor, address beneficiary, uint256 amount, uint256 vestingTime);

    event GrantClaimed(address beneficiary, uint256 amount);

    function depositGrant(address payable beneficiary, uint256 amount, uint256 vestingTime) public payable {
        require(amount > 0, "Grant amount must be greater than zero");

        require(vestingTime > block.timestamp, "Vesting time must be in the future");

        require(msg.value >= amount, "Insufficient funds transferred");

        grants[beneficiary] = Grant(beneficiary, amount, vestingTime);

        emit GrantCreated(msg.sender, beneficiary, amount, vestingTime);
    }

    function claimGrant() public {

        Grant storage grant = grants[msg.sender];

        require(grant.beneficiary == msg.sender, "Only beneficiary can claim the grant");
        require(block.timestamp >= grant.vestingTime, "Vesting period not yet passed");

        payable(msg.sender).transfer(grant.amount);

        delete grants[msg.sender];

        emit GrantClaimed(msg.sender, grant.amount);
    }

}
