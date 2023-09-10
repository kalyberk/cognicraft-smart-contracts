// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@oz-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@oz-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@oz-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@oz-upgradeable/access/OwnableUpgradeable.sol";
import "@oz-upgradeable/proxy/utils/Initializable.sol";
import "@oz-upgradeable/utils/CountersUpgradeable.sol";

contract CogniCraft is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    ERC721BurnableUpgradeable,
    OwnableUpgradeable
{
    using CountersUpgradeable for CountersUpgradeable.Counter;

    CountersUpgradeable.Counter private _tokenIdCounter;

    uint256 public constant MINT_PRICE = 0.005 ether;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC721_init("CogniCraft", "CC");
        __ERC721URIStorage_init();
        __ERC721Burnable_init();
        __Ownable_init();
    }

    function safeMint(address to, string memory uri) external payable {
        require(msg.value == MINT_PRICE, "Pay the goddamn bill");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function withdraw() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s, "Withdraw failed");
    }

    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function setTokenURI(uint256 tokenId, string calldata uri) external {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        _setTokenURI(tokenId, uri);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
