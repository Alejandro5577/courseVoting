// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract TimeManipulator {
    uint256 private currentTime;

    // Esta función devuelve el tiempo actual en tu contrato
    function getCurrentTime() public view returns (uint256) {
        return currentTime;
    }

    // Esta función te permite avanzar el tiempo en segundos
    function increaseTime(uint256 _dias) public {
        currentTime += _dias * 24 * 60 * 60; // Lo paso a segundos
    }
}