// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TodoList {

    struct Todo{
        string text;
        bool completed;
    }

    Todo[] public todos;

    function createTodo(string memory text) external {
        todos.push(Todo(text, false));
    }

    function updateText(uint index, string memory newText) external {
        todos[index].text = newText;
    }

    function revertCompleted(uint index) external {
        todos[index].completed = !todos[index].completed;
    }
    
}