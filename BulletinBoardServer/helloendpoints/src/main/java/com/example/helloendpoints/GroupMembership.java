package com.example.helloendpoints;

public class GroupMembership {
	
	public int groupId;
	public int memberId;
	
	public GroupMembership(int groupId, int memberId) {
		this.groupId = groupId;
		this.memberId = memberId;
	}

	public int getGroupId() {
		return groupId;
	}

	public void setGroupId(int groupId) {
		this.groupId = groupId;
	}

	public int getMemberId() {
		return memberId;
	}

	public void setMemberId(int memberId) {
		this.memberId = memberId;
	}

}
