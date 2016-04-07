package com.example.helloendpoints;

import java.util.Calendar;
import java.util.Date;

public class Reply {
	
	public int id;
	public String message;
	public String parentId;
	public Date time;
	
	public Reply(String message, String parentId) {
		this.id = Messages.getUniqueReplyId();
		this.message = message;
		this.parentId = parentId;
		this.time = Calendar.getInstance().getTime();
	}
	
	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getParentId() {
		return parentId;
	}

	public void setParentId(String parentId) {
		this.parentId = parentId;
	}

	public Date getTime() {
		return time;
	}

	public void setTime(Date time) {
		this.time = time;
	}
	
}
