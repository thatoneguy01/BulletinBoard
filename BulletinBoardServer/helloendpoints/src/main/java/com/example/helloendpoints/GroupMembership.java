package com.example.helloendpoints;

import com.google.appengine.api.datastore.Entity;

public class GroupMembership {
	
	public long id;
	public long groupId;
	public long memberId;
	
	public GroupMembership(long groupId, long memberId) {
		this.groupId = groupId;
		this.memberId = memberId;
	}

	public GroupMembership(Entity e) {
		try {
			this.id = e.getKey().getId();
			this.groupId = (long)e.getProperty("groupId");
			this.memberId = (long)e.getProperty("memberId");
		}
		catch (Exception e1) {
			e1.printStackTrace();
		}
	}

	public Entity toEntity() {
		Entity e = new Entity("GroupMembership");
		e.setProperty("groupId", this.groupId);
		e.setProperty("memberId", this.memberId);
		return e;
	}
	
	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public long getGroupId() {
		return groupId;
	}

	public void setGroupId(long groupId) {
		this.groupId = groupId;
	}

	public long getMemberId() {
		return memberId;
	}

	public void setMemberId(long memberId) {
		this.memberId = memberId;
	}

}
