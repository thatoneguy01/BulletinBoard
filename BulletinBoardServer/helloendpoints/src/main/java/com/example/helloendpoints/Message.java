package com.example.helloendpoints;

import java.util.Calendar;
import java.util.Date;

public class Message {

	public int id;
	public String message;
	public String poster;
	public int score;
	public double latitude;
	public double longitude;
	public int groupId;
	public Date time;
	
	public Message(String message, String poster, double latitude, double longitude) {		
		new Message(message, poster, latitude, longitude, -1);
	}
	
	public Message(String message, String poster, double latitude, double longitude, int groupId) {
		this.id = Messages.getUniqueMessageId();
		this.message = message;
		this.poster = poster;
		this.score = 0;
		this.latitude = latitude;
		this.longitude = longitude;
		this.groupId = groupId;
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

	public String getPoster() {
		return poster;
	}

	public void setPoster(String poster) {
		this.poster = poster;
	}

	public int getScore() {
		return score;
	}

	public void setScore(int score) {
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

	public int getGroupId() {
		return groupId;
	}

	public void setGroupId(int groupId) {
		this.groupId = groupId;
	}

	public Date getTime() {
		return time;
	}

	public void setTime(Date time) {
		this.time = time;
	}
}
