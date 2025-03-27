// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ImranKhanToken is ERC20 {
    address public owner;
    uint256 public presaleEndTime;
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18; // 1 Billion tokens

    uint256 public transactionFee = 2; // 2%
    uint256 public ownerFeePercentage = 75; // 75% of fee goes to owner
    uint256 public marketingFeePercentage = 25; // 25% of fee goes to marketing wallet
    address public marketingWallet = 0x7B4D149d92BAA66494C35E97a7BedfFf92B07578; // Marketing wallet
    address public presaleWallet = 0x7B4D149d92BAA66494C35E97a7BedfFf92B07578; // Wallet for presale earnings

    mapping(address => bool) public isFeeExempt;

    constructor() ERC20("Imran Khan", "IK") {
        owner = msg.sender;
        _mint(owner, (MAX_SUPPLY * 25) / 100); // 25% for owner
        _mint(address(this), (MAX_SUPPLY * 65) / 100); // 65% for presale
        _mint(marketingWallet, (MAX_SUPPLY * 10) / 100); // 10% for marketing
        presaleEndTime = block.timestamp + 21 days; // 21-day presale
        isFeeExempt[owner] = true;
        isFeeExempt[marketingWallet] = true;
        isFeeExempt[presaleWallet] = true;
    }

    function buyTokens() public payable {
        require(block.timestamp <= presaleEndTime, "Presale has ended");
        require(msg.value > 0, "Must send BNB to buy tokens");

        uint256 tokensToBuy = msg.value * 20; // Assuming $0.05 per token, 1 BNB = 20 tokens
        require(balanceOf(address(this)) >= tokensToBuy, "Not enough tokens left for presale");

        super.transfer(msg.sender, tokensToBuy);
        payable(presaleWallet).transfer(msg.value); // Send earnings to presale wallet
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 transferAmount = amount;

        if (!isFeeExempt[msg.sender] && block.timestamp > presaleEndTime) {
            uint256 fee = (amount * transactionFee) / 100;
            uint256 ownerFee = (fee * ownerFeePercentage) / 100;
            uint256 marketingFee = (fee * marketingFeePercentage) / 100;
            transferAmount = amount - fee;

            super.transfer(owner, ownerFee);
            super.transfer(marketingWallet, marketingFee);
        }

        return super.transfer(recipient, transferAmount);
    }
}
