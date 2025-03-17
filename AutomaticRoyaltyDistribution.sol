// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract AutomaticRoyaltyDistribution {
    struct Content {
        address payable creator;
        uint256 royaltyPercentage;
    }

    mapping(uint256 => Content) public contents;
    mapping(uint256 => uint256) public totalEarnings;
    uint256 public contentCounter;

    event ContentRegistered(uint256 contentId, address creator, uint256 royaltyPercentage);
    event RoyaltyPaid(uint256 contentId, address payer, uint256 amount);

    function registerContent(uint256 _royaltyPercentage) external {
        require(_royaltyPercentage <= 100, "Invalid royalty percentage");
        contents[contentCounter] = Content(payable(msg.sender), _royaltyPercentage);
        emit ContentRegistered(contentCounter, msg.sender, _royaltyPercentage);
        contentCounter++;
    }

    function payRoyalty(uint256 contentId) external payable {
        Content memory content = contents[contentId];
        require(content.creator != address(0), "Content not found");
        require(msg.value > 0, "Payment must be greater than zero");

        uint256 royaltyAmount = (msg.value * content.royaltyPercentage) / 100;
        totalEarnings[contentId] += royaltyAmount;
        content.creator.transfer(royaltyAmount);

        emit RoyaltyPaid(contentId, msg.sender, msg.value);
    }

    // Receive Ether directly
    receive() external payable {
        // Automatically forward received ETH to the first registered creator (optional logic)
    }

    // Fallback function to catch non-matching calls
    fallback() external payable {
        // Can be used for logging unexpected transactions
    }
}
