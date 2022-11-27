// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./ERC4907.sol";

contract TestAxie is ERC4907, ERC721Enumerable, Ownable {
    struct ScholarInfo {
        uint256 fee;
        uint256 ratio;
    }

    event UpdateScholar(uint256 fee, uint256 ratio);

    mapping(uint256 => ScholarInfo) internal _scholars;

    uint256 public constant MAX_SUPPLY = 10;
    uint256 public constant MAX_MINT_PER_TRANSACTION = 5;

    constructor(string memory name_, string memory symbol_)
        ERC4907(name_, symbol_)
    {}

    // mint時のロジック
    function mint(uint256 numberOfTokens) public {
        uint256 ts = totalSupply();
        require(
            numberOfTokens <= MAX_MINT_PER_TRANSACTION,
            "Exceeded max token per transaction"
        );
        require(ts + numberOfTokens <= MAX_SUPPLY, "Exceed max tokens");

        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, ts + i);
            ScholarInfo storage scholarInfo = _scholars[i];
            scholarInfo.fee = 0;
            emit UpdateScholar(0, 0);
        }
    }

    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) public override onlyOwner {
        super.setUser(tokenId, user, expires);
    }

    function setScholar(
        uint256 tokenId,
        address scholar,
        uint64 expires,
        uint64 ratio
    ) public payable {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        ScholarInfo storage scholarInfo = _scholars[tokenId];
        if (msg.sender == scholar) {
            require(scholarInfo.fee == msg.value);
            address payable manager = payable(ownerOf(tokenId));
            manager.transfer(msg.value);
        }
        UserInfo storage userInfo = _users[tokenId];
        userInfo.user = scholar;
        userInfo.expires = expires;
        emit UpdateUser(tokenId, scholar, expires);

        scholarInfo.ratio = ratio;
        emit UpdateScholar(scholarInfo.fee, ratio);
    }

    function setRentalFee(uint256 tokenId, uint256 fee) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        require(msg.sender == ownerOf(tokenId));
        ScholarInfo storage scholarInfo = _scholars[tokenId];
        scholarInfo.fee = fee;
        emit UpdateScholar(fee, scholarInfo.ratio);
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC4907, ERC721Enumerable)
        returns (bool)
    {
        return
            interfaceId == type(IERC4907).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC4907, ERC721Enumerable) {
        require(uint256(_users[tokenId].expires) < block.timestamp);
    }

    function win(uint256 tokenId) public payable onlyOwner {
        UserInfo storage userInfo = _users[tokenId];
        ScholarInfo storage scholarInfo = _scholars[tokenId];

        uint256 profits = msg.value;
        uint256 reward = 0;
        if (userInfo.user != address(0)) {
            reward = profits * scholarInfo.ratio;
            payable(userInfo.user).transfer(reward);
        }
        profits = profits - reward;
        payable(ownerOf(tokenId)).transfer(profits);
    }
}
