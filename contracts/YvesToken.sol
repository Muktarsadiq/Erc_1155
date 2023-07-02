// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract YvesToken is ERC1155, Ownable, ERC1155Supply {
    uint256 public publicPrice = 0.01 ether;
    uint256 public allowListPrice = 0.005 ether;
    uint256 public maxSupply = 50;
    bool public mintOpen = true;
    bool public allowListopen = true;
    uint256 public MaxPerWallet = 2;

    mapping(address => bool) public allowList;
    mapping(address => uint256) purchasePerWallet;

    constructor()
        ERC1155(
            "https://ipfs.io/ipfs/Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/"
        )
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function editMint(bool _mintOpen, bool _allowListopen) external onlyOwner {
        mintOpen = _mintOpen;
        allowListopen = _allowListopen;
    }

    function mint(uint256 id, uint256 amount) public payable {
        require(mintOpen == true, "sorry the mint function is closed");
        require(id < maxSupply, "sorry you're trying to mint the wrong Token");
        require(msg.value == publicPrice * amount, "Not enough funds to mint");
        require(
            purchasePerWallet[msg.sender] + amount <= MaxPerWallet,
            "Mint limit reached"
        );
        require(
            totalSupply(id) + amount <= maxSupply,
            "sorry we have minted out"
        );
        _mint(msg.sender, id, amount, "");
        purchasePerWallet[msg.sender] += amount;
    }

    function allowListMint(uint id, uint amount) public payable {
        require(allowList[msg.sender], "You are not on the Allow List");
        require(allowListopen == true, "SOrry the allow List is closed");
        require(id < maxSupply, "sorry you're trying to mint the wrong Token");
        require(
            purchasePerWallet[msg.sender] + amount <= MaxPerWallet,
            "Mint limit reached"
        );
        require(msg.value == allowListPrice * amount);
        require(
            totalSupply(id) + amount <= maxSupply,
            "sorry we have minted out"
        );
        _mint(msg.sender, id, amount, "");
        purchasePerWallet[msg.sender] += amount;
    }

    function setAllowList(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            allowList[addresses[i]] = true;
        }
    }

    // Function to add an address to the allowlist
    function addToAllowlist(address addressToAdd) public onlyOwner {
        allowList[addressToAdd] = true;
    }

    function uri(uint256 _id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(exists(_id), "wrong id Uri input");
        return
            string(
                abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json")
            );
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function withdraw() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
