package com.example.helloendpoints;

import java.util.Date;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.GeoPt;

public class Message {

	public long id;
	public String message;
	public String postingUser;
	public long score;
	public GeoPt location;
	public float latitude;
	public float longitude;
	public long groupId;
	public Date timePosted;

	public Message() {

	}

	public Message(long id, String message, String postingUser, long score, GeoPt location, float latitude, float longitude, long groupId, Date timePosted) {
		this.id = id;
		this.message = message;
		this.postingUser = postingUser;
		this.score = score;
		this.location = location;
		this.latitude = latitude;
		this.longitude = longitude;
		this.groupId = groupId;
		this.timePosted = timePosted;
	}

	public Message(Entity e) {
		try {
			this.id = e.getKey().getId();
			this.message = (String)e.getProperty("message");
			this.postingUser = (String)e.getProperty("postingUser");
			this.score = (long) e.getProperty("score");
			this.location = (GeoPt) e.getProperty("location");
			this.groupId = (long)e.getProperty("groupId");
			this.timePosted = (Date)e.getProperty("timePosted");
		}
		catch (Exception exception) {
			exception.printStackTrace();
		}
	}

	public Entity toEntity() {
		Entity e = new Entity("Message");
		e.setProperty("message", this.message);
		e.setProperty("postingUser", this.postingUser);
		e.setProperty("score", this.score);
		e.setProperty("location", this.getLocation());
		e.setProperty("groupId", this.getGroupId());
		e.setProperty("timePosted", this.timePosted);
		return e;
	}

	public long getId() {
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

	public String getPostingUser() {
		return postingUser;
	}

	public void setPostingUser(String postingUser) {
		this.postingUser = postingUser;
	}

	public long getScore() {
		return score;
	}

	public void setScore(long score) {
		this.score = score;
	}

	public GeoPt getLocation() {
		return location;
	}

	public void setLocation(GeoPt location) {
		this.location = location;
	}

	public long getGroupId() {
		return groupId;
	}

	public void setGroupId(int groupId) {
		this.groupId = groupId;
	}

	public Date getTimePosted() {
		return timePosted;
	}

	public void setTimePosted(Date timePosted) {
		this.timePosted = timePosted;
	}
}
