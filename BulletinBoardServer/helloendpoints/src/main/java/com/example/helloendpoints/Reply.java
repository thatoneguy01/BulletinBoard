package com.example.helloendpoints;

import java.util.Calendar;
import java.util.Date;

import com.google.appengine.api.datastore.Entity;

public class Reply {
	
	public long id;
	public String message;
	public long parentId;
	public Date timePosted;
	
	public Reply() {
		
	}
	
	public Reply(String message, long parentId) {
//		this.id = Messages.getUniqueReplyId();
		this.message = message;
		this.parentId = parentId;
		this.timePosted = Calendar.getInstance().getTime();
	}
	
	public Reply(Entity e) {
		try {
			this.id = e.getKey().getId();
			this.message = (String) e.getProperty("message");
			this.parentId = (long) e.getProperty("parentId");
			this.timePosted = (Date) e.getProperty("timePosted");
		} catch (Exception exception) {
			exception.printStackTrace();
		}
	}
	
	public Entity toEntity() {
		Entity e = new Entity("Reply");
		e.setProperty("message", this.message);
		e.setProperty("parentId", this.parentId);
		e.setProperty("timePosted", this.timePosted);
		return e;
	}
	
	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public long getParentId() {
		return parentId;
	}

	public void setParentId(long parentId) {
		this.parentId = parentId;
	}

	public Date getTimePosted() {
		return timePosted;
	}

	public void setTimePosted(Date timePosted) {
		this.timePosted = timePosted;
	}
	
}
