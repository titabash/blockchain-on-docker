// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./IERC4907.sol";

contract ERC4907 is ERC721, IERC4907, ERC721Enumerable, Ownable {
    struct UserInfo {
        address user; // address of user role
        uint64 expires; // unix timestamp, user expires
        uint64 royalty;
    }

    mapping(uint256 => UserInfo) internal _users;

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MAX_MINT_PER_TRANSACTION = 5;

    address public owner;

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {
        owner = msg.sender;
    }

    // mint時のロジック
    function mint(uint256 numberOfTokens) public payable {
        uint256 ts = totalSupply();
        require(
            numberOfTokens <= MAX_MINT_PER_TRANSACTION,
            "Exceeded max token per transaction"
        );
        require(ts + numberOfTokens <= MAX_SUPPLY, "Exceed max tokens");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
        }
    }

    /// @notice set the user and expires of a NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) public virtual {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) public view virtual returns (address) {
        if (uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        } else {
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId)
        public
        view
        virtual
        returns (uint256)
    {
        return _users[tokenId].expires;
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC4907).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId, amount);

        // if (from != to && _users[tokenId].user != address(0)) {
        //     delete _users[tokenId];
        //     emit UpdateUser(tokenId, address(0), 0);
        // }
        require(uint256(_users[tokenId].expires) < block.timestamp);
    }

    // Payコントラクトアドレスから_toアドレスに_amount分のetherを送金する関数
    function withdraw(address payable _to, uint256 _amount) public {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}
