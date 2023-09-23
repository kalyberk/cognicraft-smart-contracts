// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console2} from "forge-std/Test.sol";
import {CogniCraft} from "../src/CogniCraft.sol";
import "@oz/proxy/transparent/ProxyAdmin.sol";
import "@oz/proxy/transparent/TransparentUpgradeableProxy.sol";

contract CogniCraftTest is Test {
    CogniCraft public cogniCraft; // The most recent version
    CogniCraft public cogniCraftV1;
    ProxyAdmin public proxyAdmin;
    TransparentUpgradeableProxy public proxy;
    uint256 public mintPrice;

    address public owner = address(1);
    address public bob = address(2);
    address public alice = address(3);

    function setUp() public {
        cogniCraftV1 = new CogniCraft();
        proxyAdmin = new ProxyAdmin();
        proxy = new TransparentUpgradeableProxy(
            address(cogniCraftV1),
            address(proxyAdmin),
            ""
        );
        CogniCraft(address(proxy)).initialize();
        CogniCraft(address(proxy)).transferOwnership(owner);
        cogniCraft = CogniCraft(address(proxy));
        mintPrice = cogniCraft.MINT_PRICE();
        // console2.log("address of proxy admin", address(proxyAdmin));
        // console2.log("address of proxy", address(proxy));
        // console2.log("owner of cognicraft", cogniCraft.owner());
        // console2.log("owner", owner);
        // console2.log("mint price", mintPrice);

        vm.deal(owner, 100 ether);
        vm.deal(bob, 100 ether);
        // console2.log("balance of owner", address(owner).balance);
        // console2.log("balance of bob", address(bob).balance);
    }

    // TODO: Add tests for events. Define them here first.
    // `event Blah(...)`, and then inside the related funcs `vm.expectEmit(...)`

    function testSafeMint() public {
        vm.startPrank(owner);
        cogniCraft.safeMint{value: mintPrice}(owner);

        assertEq(cogniCraft.ownerOf(0), owner);
        assertEq(bytes(cogniCraft.tokenURI(0)).length, 0);
        assertEq(cogniCraft.balanceOf(owner), 1);
    }

    function testSafeMintOtherThanOwner() public {
        vm.startPrank(bob);
        cogniCraft.safeMint{value: mintPrice}(bob);

        assertEq(cogniCraft.ownerOf(0), bob);
        assertEq(bytes(cogniCraft.tokenURI(0)).length, 0);
        assertEq(cogniCraft.balanceOf(bob), 1);
    }

    function testFailSafeMint() public {
        vm.startPrank(owner);
        cogniCraft.safeMint{value: 0}(owner);
    }

    function testTransferFrom() public {
        vm.startPrank(owner);
        cogniCraft.safeMint{value: mintPrice}(owner);
        cogniCraft.safeTransferFrom(owner, bob, 0);

        assertEq(cogniCraft.ownerOf(0), bob);
        assertEq(cogniCraft.balanceOf(bob), 1);
        assertEq(cogniCraft.balanceOf(owner), 0);
    }

    function testGetBalance() public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < 3; i++) {
            cogniCraft.safeMint{value: mintPrice}(owner);
        }

        assertEq(cogniCraft.balanceOf(owner), 3);
    }

    function testOnlyOwnerBurn() public {
        vm.startPrank(owner);
        cogniCraft.safeMint{value: mintPrice}(owner);
        cogniCraft.burn(0);

        assertEq(cogniCraft.balanceOf(owner), 0);
    }

    function testFailBurn() public {
        vm.startPrank(owner);
        cogniCraft.safeMint{value: mintPrice}(owner);
        vm.stopPrank();

        vm.prank(bob);
        cogniCraft.burn(0);
    }

    function testApprove() public {
        vm.startPrank(owner);
        cogniCraft.safeMint{value: mintPrice}(bob);
        vm.stopPrank();

        assertEq(cogniCraft.ownerOf(0), bob);

        vm.prank(bob);
        cogniCraft.approve(alice, 0);

        assertEq(cogniCraft.ownerOf(0), bob);
        assertEq(cogniCraft.getApproved(0), alice);
    }

    function testSetApprovalForAll() public {
        vm.startPrank(owner);
        cogniCraft.safeMint{value: mintPrice}(bob);
        vm.stopPrank();

        vm.prank(bob);
        cogniCraft.setApprovalForAll(alice, true);

        assertEq(cogniCraft.isApprovedForAll(bob, alice), true);
    }

    function testWithdraw() public {
        vm.startPrank(bob);
        for (uint256 i = 0; i < 6; i++) {
            // Let it make some money
            cogniCraft.safeMint{value: mintPrice}(bob);
        }
        vm.stopPrank();

        uint256 initialContractBalance = address(cogniCraft).balance;
        uint256 initialOwnerBalance = address(owner).balance;

        vm.startPrank(owner);
        cogniCraft.withdraw();

        assertEq(address(cogniCraft).balance, 0);
        assertEq(address(owner).balance, initialOwnerBalance + initialContractBalance);
    }

    function testFailWithdraw() public {
        vm.startPrank(bob);
        cogniCraft.withdraw();
    }

    function testSetTokenURI() public {
        vm.startPrank(bob);
        cogniCraft.safeMint{value: mintPrice}(bob);
        cogniCraft.setTokenURI(0, "https://foo.com");

        assertEq(cogniCraft.tokenURI(0), "https://foo.com");
    }

    function testFailSetTokenURI() public {
        vm.startPrank(bob);
        cogniCraft.safeMint{value: mintPrice}(bob);
        vm.stopPrank();

        vm.prank(owner);
        cogniCraft.setTokenURI(0, "https://foo.com");
    }

    function testFailSetTokenURIOnlyOnce() public {
        vm.startPrank(bob);
        cogniCraft.safeMint{value: mintPrice}(bob);
        cogniCraft.setTokenURI(0, "https://foo.com");
        cogniCraft.setTokenURI(0, "https://bar.com");
    }
}
