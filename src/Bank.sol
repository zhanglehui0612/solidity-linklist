// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "./ReentrancyGuard.sol";

contract Bank is Ownable, ReentrancyGuard {

    // account balance
    mapping(address => uint256) balances;

    // top 10 account rank linkedlist
    mapping(address => address) depositors;

    // dummy address in the linkedlist
    address constant DUMMY = address(0);

    // the tail address in the datalist, default is dummy
    address tail = DUMMY;

    // linkedlist count
    uint8 size;

    // rank limit
    uint8 topN;

    constructor(uint8 _topN) Ownable(msg.sender){
        depositors[DUMMY] = DUMMY;
        topN = _topN;

    }

    
    error AmountMustThanZero();

    function deposit() public payable {
        if (msg.value == 0) 
            revert AmountMustThanZero();

        // update balance
        balances[msg.sender] += msg.value;

        // update rank
        update(msg.sender);
    }



    /*
     * Return the account balance
     * @param account 
     */
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }



    /*
     * Update the address rank by the balance amount
     * @param current 
     */
    function update(address current) internal noReentrancy {
        // 如果链表下一个节点是DUMMY自己，那么说明这是第一个储户,tail指向自己
        // linkedlist have no any data, so the current is the first address
        if (depositors[DUMMY] == DUMMY) {
            update(DUMMY, msg.sender, address(0));
            return;
        }

        // The first still is the msg.sender, so no need update linkedlist
        if (depositors[DUMMY] == msg.sender) {
            return;
        }

        address before = findInsertAddress(msg.sender);
        (address prev, bool exist) = getPreviousAddressIfExist(current);
        
        // if exist
        if (exist) {
            // No need to update if the order no change
            if (depositors[before] ==  msg.sender) {
                return;
            }

            update(before, msg.sender, msg.sender);
            return;
        }

        //  if not exist
        update(before, msg.sender, tail);
    }


    function update(address beforeAddAddr, address addAddr, address removeAddr) internal {
        if (size == topN) {
            require(removeAddr != address(0));
            remove(removeAddr);
        }
        add(beforeAddAddr, addAddr);
    }



    /*
     * Add the address to linkedlist
     * @param prev 
     * @param current 
     */
    function add(address prev, address current) internal {
       require(!isExits(current), "This account address have existed");

        // add current to linkedlist
        address next = depositors[prev];
        depositors[prev] = current;
        depositors[current] = next;
        
        // update tail 
        if (next == DUMMY) {
            tail = current;
        }

        size++;
    }

    /*
     * To find the insertion location
     * @param target 
     */
    function findInsertAddress(address target) internal view returns (address) {
        address current = DUMMY;
        address prev = DUMMY;

        while(depositors[current] != DUMMY) {
            if (balances[target] > balances[depositors[current]]) {
                return prev;
            }

            current = depositors[current];
            prev = current;
            
        }

        return address(0);
    }



    /*
     * Check if one address is in the linkedlist
     * @param depositor 
     */
    function remove(address target) internal {
        (address prev, bool exist) = getPreviousAddressIfExist(target);
        require(exist, "this address would be removed not exist");

        // let the prev next address point to next address of current
        // 0x1 -> 0x2 and 0x2 -0x4
        // now the mapping is 0x1 -> 0x4 and 0x2  -> 0x0
        depositors[prev] = depositors[target];

        // remove the current address from linkedlist 
        depositors[target] = address(0);

        // 如果删除的元素是最后一个节点，那么需要更新tail
        if (depositors[target] == DUMMY) {
            tail = prev;
        }

        size--;
    }



    /*
     * Check if one address is in the linkedlist
     * @param depositor 
     */
    function isExits(address depositor) internal view returns (bool){
        address current = DUMMY;
        // if current address is not the DUMMY, which means this address is not the last address
        while (depositors[current] != DUMMY) {
            // if find the depositor, return true
            if (depositors[current] == depositor) {
                return true;
            }
            // current reset to the its value (next address)
            current = depositors[current];
        }
        return false;
    }



    /*
     * Check if the address is exist, if true return its previous address
     * @param target 
     * @return 
     * @return 
     */
    function getPreviousAddressIfExist(address target) internal view returns (address, bool){
        address current = DUMMY;
        // if current address is not the DUMMY, which means this address is not the last address
        while (depositors[current] != DUMMY) {
            // if find the depositor, return true
            if (depositors[current] == target) {
                return (current, true);
            }
            // current reset to the its value (next address)
            current = depositors[current];
        }
        return (address(0), false);
    }




    /**
     * Return topN account rank
     */
    function getTopN() public returns (address[] memory) {
        address[] memory accounts = new address[](topN);
        address current = DUMMY;
        uint256 i = 0;
        while(depositors[current] != DUMMY) {
            accounts[i] = depositors[current];
            current = depositors[current];
            i++;
        }
        return accounts;
    }
}



