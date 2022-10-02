// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./IERC20.sol";

contract CrowdFund {
    event Launch(uint id, address indexed creator, uint goal, uint startAt, uint endAt);
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint startTime;
        uint endTime;
        bool claimed;
    }

    IERC20 public immutable token;
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public pledgedAmount;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }

    function launch(uint goal,uint startTime,uint endTime) external {
        require(startTime >= block.timestamp, "Start Time must be in future.");
        require(endTime >= startTime, "End time must be after start time.");
        campaigns[count] = Campaign(msg.sender, goal, 0, startTime, endTime, false);
        count++;
        emit Launch(count, msg.sender, goal, startTime, endTime);
    }

    function cancel(uint id) external {
        require(campaigns[id].creator == msg.sender, "only creator can cancel.");
        require(campaigns[id].startTime > block.timestamp, "cannot be canceled after started.");
        delete campaigns[id];
        emit Cancel(id);
    }

    function pledge(uint id, uint amount) external {
        require(campaigns[id].startTime < block.timestamp, "cannot be pledged before started.");
        require(campaigns[id].endTime > block.timestamp, "cannot be pledged after ended.");
        token.transferFrom(msg.sender, address(this), amount);
        campaigns[id].pledged+=amount;
        pledgedAmount[id][msg.sender]+=amount;
        emit Pledge(id, msg.sender, amount);
    }

    function unpledge(uint id, uint amount) external {
        require(campaigns[id].endTime > block.timestamp, "cannot be unpledged after ended.");
        require(pledgedAmount[id][msg.sender] > amount, "you cannot unpledge more than you pledged.");
        token.transfer(msg.sender, amount);
        pledgedAmount[id][msg.sender]-=amount;
        campaigns[id].pledged-=amount;
        emit Pledge(id, msg.sender, amount);
    }

    function claim(uint id) external {
        Campaign storage campaign=campaigns[id];
        require(campaign.creator == msg.sender, "only creator can claim.");
        require(campaign.pledged >= campaign.goal, "goal is not reached");
        require(campaign.endTime < block.timestamp, "cannot be claimed before ended.");
        require(campaign.claimed == false, "already claimed.");

        token.transfer(campaign.creator, campaign.pledged);
        campaign.claimed=true;
        emit Claim(id);
    }
       
        
    function refund(uint id) external {
        require(campaigns[id].endTime < block.timestamp, "cannot be refunded before ended.");
        require(campaigns[id].pledged < campaigns[id].goal, "campaign goal is reached, so cannot be refunded.");
        token.transfer(msg.sender, pledgedAmount[id][msg.sender]);
        uint refundedAmount=pledgedAmount[id][msg.sender];
        pledgedAmount[id][msg.sender] = 0;
        campaigns[id].pledged-=refundedAmount;
        emit Refund(id, msg.sender, refundedAmount);
    }
}