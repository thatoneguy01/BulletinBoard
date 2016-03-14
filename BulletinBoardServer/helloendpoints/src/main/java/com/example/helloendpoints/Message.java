package com.example.helloendpoints;

import java.util.Calendar;
import java.util.Date;

public class Message {

	public String id;
	public String message;
	public String poster;
	public int score;
	public String location; //TODO change to whatever location is represented as
	public boolean viewable;
	public Date time;
	
	public Message() {
		new Message("", "");
	}
	
	public Message(String message, String poster) {		
		new Message(message, poster, true);
	}
	
	public Message(String message, String poster, boolean viewable) {
		this.id = ""; //TODO randomly generate id
		this.message = message;
		this.poster = poster;
		this.score = 0;
		this.location = ""; //TODO handle location
		this.viewable = viewable;
		this.time = Calendar.getInstance().getTime();
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
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

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public boolean isViewable() {
		return viewable;
	}

	public void setViewable(boolean viewable) {
		this.viewable = viewable;
	}

	public Date getTime() {
		return time;
	}

	public void setTime(Date time) {
		this.time = time;
	}
}
