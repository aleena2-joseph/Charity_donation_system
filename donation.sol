// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Donation {
    struct Donor {
        address payable donorAddress;
        uint amount;
        bool confirmed; // Check if the donor has been confirmed
    }

    address payable public receiver; // Receiver to receive the donation
    enum State { Created, Completed } 
    State public state; // State of the transaction

    Donor[] public donors; // Array to track multiple donors
    uint public totalDonations; // Total donation amount collected

    event DonationInitiated(address indexed donor, uint amount);
    event DonationCompleted(address indexed receiver, uint amount);
    event ConfirmationMessage(address indexed donor, string message);

    // Set receiver as the contract deployer and mark the transaction as 'Created'
    constructor() {
        receiver = payable(msg.sender);
        state = State.Created;
    }

    modifier onlyReceiver() {
        require(msg.sender == receiver, "Only the receiver can call this.");
        _;
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid transaction state.");
        _;
    }

    // Donor sends funds
    function donate() external payable inState(State.Created) {
        require(msg.value > 0, "Donation amount must be greater than 0.");

        // Add donor to the donors array
        donors.push(Donor({
            donorAddress: payable(msg.sender),
            amount: msg.value,
            confirmed: false
        }));

        // Update total donation amount
        totalDonations += msg.value;

        emit DonationInitiated(msg.sender, msg.value);
    }

    // Receiver confirms receiving the donation, completing the transaction
    function confirmReceived() external onlyReceiver inState(State.Created) {
        require(totalDonations > 0, "No donations to receive.");

        // Transfer total donation amount to the receiver
        receiver.transfer(totalDonations);
        state = State.Completed; // Mark transaction as completed

        emit DonationCompleted(receiver, totalDonations);

        // Send confirmation message to each donor
        for (uint i = 0; i < donors.length; i++) {
            Donor storage donor = donors[i];
            donor.confirmed = true; // Mark donor as confirmed
            emit ConfirmationMessage(donor.donorAddress, "The amount is received by the receiver.");
        }
    }

    // Get the contract's balance
    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }

    // Get the number of donors
    function getNumberOfDonors() external view returns (uint) {
        return donors.length;
    }

    // Get donor details by index
    function getDonorDetails(uint index) external view returns (address, uint, bool) {
        require(index < donors.length, "Donor does not exist.");
        Donor memory donor = donors[index];
        return (donor.donorAddress, donor.amount, donor.confirmed);
    }
}
