package com.example.helloendpoints;

import com.google.appengine.api.datastore.Entity;

import java.util.Date;

public class Message {

	public long id;
	public String message;
	public String postingUser;
	public long score;
	public double latitude;
	public double longitude;
	public long groupId;
	public Date timePosted;

	public Message() {

	}
	
	public Message(String message, String postingUser, double latitude, double longitude) {
		new Message(message, postingUser, latitude, longitude, -1, new Date());
	}
	
	public Message(String message, String postingUser, double latitude, double longitude, long groupId, Date timePosted) {
		this.message = message;
		this.postingUser = postingUser;
		this.score = 0;
		this.latitude = latitude;
		this.longitude = longitude;
		this.groupId = groupId;
		this.timePosted = timePosted;
	}

	public Message(long id, String message, String postingUser, int score, double latitude, double longitude, long groupId, Date timePosted) {
		this.id = id;
		this.message = message;
		this.postingUser = postingUser;
		this.score = score;
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
			this.latitude = (double)e.getProperty("latitude");
			this.longitude = (double)e.getProperty("longitude");
			this.groupId = (long)e.getProperty("groupId");
			this.timePosted = (Date)e.getProperty("timePosted");
		}
		catch (Exception e1) {
			e1.printStackTrace();
		}
	}

	public Entity toEntity() {
		Entity e = new Entity("Message");
		e.setProperty("message", this.message);
		e.setProperty("postingUser", this.postingUser);
		e.setProperty("score", this.score);
		e.setProperty("latitude", this.latitude);
		e.setProperty("longitude", this.longitude);
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

	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	public double getLongitude() {
		return longitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
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
