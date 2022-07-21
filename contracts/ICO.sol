//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./Token.sol";

contract ICO {
    using SafeMath for uint256;
    struct sale {
        address investor;
        uint256 amount;
        bool withdraw;
    }

    mapping(address => sale) public sales;
    address public admin;
    uint256 public end;
    uint256 public duration;
    uint256 public price;
    uint256 public minPurchase;
    uint256 public maxPurchase;
    uint256 public availableToken;
    Token public token;
    IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    constructor(
        address tokenAddress,
        uint256 _duration,
        uint256 _availableToken,
        uint256 _price,
        uint256 _minPurchase,
        uint256 _maxPurchase
    ) {
        admin = msg.sender;
        token = Token(tokenAddress);
        require(_duration > 0, "duration should be > 0");
        duration = _duration;
        require(_price > 0, "price should be > 0");
        price = _price;
        require(
            _availableToken > 0 && _availableToken <= token.maxSupply(),
            "Available Token should > 0 and less then Max Token Supply"
        );
        availableToken = _availableToken;
        require(_minPurchase > 0, "min Purchase should be > 0");
        minPurchase = _minPurchase;
        require(
            _maxPurchase > 0 && _maxPurchase <= 500,
            "Max Purchase should be >0 or less the 500 dia Token for ICO"
        );
        maxPurchase = _maxPurchase;
    }

    function start() external onlyAdmin icoStarted {
        end = block.timestamp + duration;
    }

    function buy(uint256 daiAmount) external icoActive {
        require(
            daiAmount >= minPurchase && daiAmount <= maxPurchase,
            "Dai Amount must be > Min Purchase and < Max Purchase"
        );
        uint256 tokenAmount = daiAmount.div(price);
        require(tokenAmount <= availableToken, "Not Enough token left to buy");
        availableToken = availableToken.sub(tokenAmount);
        dai.transferFrom(msg.sender, address(this), daiAmount);
        token.mint(address(this), tokenAmount);
        sales[msg.sender] = sale(msg.sender, tokenAmount, false);
    }

    function withdrawToken() external icoEnded {
        sale storage Sale = sales[msg.sender];
        require(Sale.amount > 0, "only Investor Allowed");
        require(Sale.withdraw == false, "Token already Withdraw");
        Sale.withdraw = true;
        token.transfer(Sale.investor, Sale.amount);
    }

    function withdrawDai(uint256 daiAmountWithdraw)
        external
        onlyAdmin
        icoEnded
    {
        dai.transfer(admin, daiAmountWithdraw);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin Allowed");
        _;
    }

    modifier icoStarted() {
        require(end == 0, "ICO must be started");
        _;
    }

    modifier icoActive() {
        require(
            end > 0 && end > block.timestamp && availableToken > 0,
            "ICO Ended or Token Completed"
        );
        _;
    }

    modifier icoEnded() {
        require(
            end > 0 && (end <= block.timestamp || availableToken == 0),
            "ICO must be Active"
        );
        _;
    }
}
