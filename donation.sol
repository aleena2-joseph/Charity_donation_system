// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharityDonationApp {
    address public admin;   // Admin who controls the contract

    // Charity structure to manage donations
    struct Charity {
        uint256 maxAmount;    // Maximum amount requested
        uint256 collected;    // Amount collected so far
        uint256 balance;      // Current balance available for withdrawal
        bool status;          // Status of the charity request (active/inactive)
    }

    mapping(uint256 => Charity) public charityRequests;  // Store charity requests by ID
    uint256 public charityCount;                         // Track the number of charity requests

    event DonationReceived(uint256 indexed charityId, address indexed donor, uint256 amount);
    event FundsWithdrawn(uint256 indexed charityId, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can perform this action.");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Function to create a new charity request
    function createCharityRequest(uint256 _maxAmount) public onlyAdmin {
        charityCount++;
        charityRequests[charityCount] = Charity({
            maxAmount: _maxAmount,
            collected: 0,
            balance: 0,
            status: true
        });
    }

    // Function to allow donations to a specific charity request
    function donate(uint256 _charityId) public payable {
        Charity storage charity = charityRequests[_charityId];
        require(charity.status, "Charity request is not active.");
        require(msg.value > 0, "Donation must be greater than zero.");
        require(charity.collected + msg.value <= charity.maxAmount, "Donation exceeds required amount.");

        charity.collected += msg.value;
        charity.balance += msg.value;

        emit DonationReceived(_charityId, msg.sender, msg.value);
    }

    // Function to allow the admin to withdraw funds from a specific charity request
    function withdraw(uint256 _charityId, uint256 _amount) public onlyAdmin {
        Charity storage charity = charityRequests[_charityId];
        require(_amount <= charity.balance, "Insufficient balance.");

        charity.balance -= _amount;
        payable(admin).transfer(_amount);

        emit FundsWithdrawn(_charityId, _amount);
    }

    // Function to check contract balance (optional, for transparency)
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
