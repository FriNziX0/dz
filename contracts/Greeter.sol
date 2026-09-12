// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}

/// @title Greeter
/// @notice Greeter з контролем доступу та базовою імплементацією ERC-20.
contract Greeter is IERC20Metadata {
  error NotOwner(address caller);
  error UnauthorizedGreetingEditor(address caller);
  error ZeroAddress();
  error NodeAlreadyAllowed(address node);
  error NodeNotAllowed(address node);
  error ERC20InvalidSender(address sender);
  error ERC20InvalidReceiver(address receiver);
  error ERC20InvalidApprover(address approver);
  error ERC20InvalidSpender(address spender);
  error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
  error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

  event GreetingChanged(address indexed editor, string newGreeting);
  event NodePermissionChanged(address indexed node, bool allowed);

  /// @notice Адреса вузла, який опублікував (розгорнув) контракт.
  address public immutable owner;

  string public greeting;

  uint8 private constant TOKEN_DECIMALS = 18;
  string private tokenName;
  string private tokenSymbol;
  uint256 private tokenTotalSupply;
  mapping(address => uint256) private tokenBalances;
  mapping(address => mapping(address => uint256)) private tokenAllowances;

  /// @notice Показує, чи може адреса змінювати текст привітання.
  mapping(address => bool) public isAllowedNode;

  address[] private allowedNodes;
  mapping(address => uint256) private nodeIndexPlusOne;

  /// @param initialGreeting Початковий текст привітання.
  /// @param name_ Назва ERC-20 токена.
  /// @param symbol_ Коротке позначення ERC-20 токена.
  /// @param initialSupply Початкова кількість токенів для власника (без урахування 18 decimals).
  constructor(
    string memory initialGreeting,
    string memory name_,
    string memory symbol_,
    uint256 initialSupply
  ) {
    owner = msg.sender;
    greeting = initialGreeting;
    tokenName = name_;
    tokenSymbol = symbol_;
    _mint(msg.sender, initialSupply * 10 ** uint256(TOKEN_DECIMALS));
  }

  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert NotOwner(msg.sender);
    }
    _;
  }

  modifier onlyGreetingEditor() {
    if (msg.sender != owner && !isAllowedNode[msg.sender]) {
      revert UnauthorizedGreetingEditor(msg.sender);
    }
    _;
  }

  /// @notice Змінює текст привітання. Доступно власнику та дозволеним вузлам.
  function setGreeting(string calldata newGreeting) external onlyGreetingEditor {
    greeting = newGreeting;
    emit GreetingChanged(msg.sender, newGreeting);
  }

  /// @notice Додає вузол до переліку адрес, яким дозволено змінювати привітання.
  function allowNode(address node) external onlyOwner {
    if (node == address(0)) {
      revert ZeroAddress();
    }
    if (isAllowedNode[node]) {
      revert NodeAlreadyAllowed(node);
    }

    isAllowedNode[node] = true;
    allowedNodes.push(node);
    nodeIndexPlusOne[node] = allowedNodes.length;
    emit NodePermissionChanged(node, true);
  }

  /// @notice Забирає у вузла право змінювати привітання.
  function removeNode(address node) external onlyOwner {
    if (!isAllowedNode[node]) {
      revert NodeNotAllowed(node);
    }

    uint256 nodeIndex = nodeIndexPlusOne[node] - 1;
    uint256 lastIndex = allowedNodes.length - 1;

    if (nodeIndex != lastIndex) {
      address lastNode = allowedNodes[lastIndex];
      allowedNodes[nodeIndex] = lastNode;
      nodeIndexPlusOne[lastNode] = nodeIndex + 1;
    }

    allowedNodes.pop();
    isAllowedNode[node] = false;
    delete nodeIndexPlusOne[node];
    emit NodePermissionChanged(node, false);
  }

  /// @notice Повертає актуальний перелік вузлів, яким дозволена зміна привітання.
  function getAllowedNodes() external view returns (address[] memory) {
    return allowedNodes;
  }

  // ---- ERC-20 metadata ----

  function name() public view override returns (string memory) {
    return tokenName;
  }

  function symbol() public view override returns (string memory) {
    return tokenSymbol;
  }

  function decimals() public pure override returns (uint8) {
    return TOKEN_DECIMALS;
  }

  // ---- ERC-20 required methods ----

  function totalSupply() public view override returns (uint256) {
    return tokenTotalSupply;
  }

  function balanceOf(address account) public view override returns (uint256) {
    return tokenBalances[account];
  }

  function transfer(address to, uint256 value) public override returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  function allowance(address tokenOwner, address spender) public view override returns (uint256) {
    return tokenAllowances[tokenOwner][spender];
  }

  function approve(address spender, uint256 value) public override returns (bool) {
    _approve(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public override returns (bool) {
    _spendAllowance(from, msg.sender, value);
    _transfer(from, to, value);
    return true;
  }

  function _transfer(address from, address to, uint256 value) internal {
    if (from == address(0)) {
      revert ERC20InvalidSender(address(0));
    }
    if (to == address(0)) {
      revert ERC20InvalidReceiver(address(0));
    }

    uint256 fromBalance = tokenBalances[from];
    if (fromBalance < value) {
      revert ERC20InsufficientBalance(from, fromBalance, value);
    }

    unchecked {
      tokenBalances[from] = fromBalance - value;
      tokenBalances[to] += value;
    }
    emit Transfer(from, to, value);
  }

  function _mint(address account, uint256 value) internal {
    if (account == address(0)) {
      revert ERC20InvalidReceiver(address(0));
    }

    tokenTotalSupply += value;
    unchecked {
      tokenBalances[account] += value;
    }
    emit Transfer(address(0), account, value);
  }

  function _approve(address tokenOwner, address spender, uint256 value) internal {
    if (tokenOwner == address(0)) {
      revert ERC20InvalidApprover(address(0));
    }
    if (spender == address(0)) {
      revert ERC20InvalidSpender(address(0));
    }

    tokenAllowances[tokenOwner][spender] = value;
    emit Approval(tokenOwner, spender, value);
  }

  function _spendAllowance(address tokenOwner, address spender, uint256 value) internal {
    uint256 currentAllowance = allowance(tokenOwner, spender);
    if (currentAllowance < type(uint256).max) {
      if (currentAllowance < value) {
        revert ERC20InsufficientAllowance(spender, currentAllowance, value);
      }
      unchecked {
        tokenAllowances[tokenOwner][spender] = currentAllowance - value;
      }
    }
  }
}
