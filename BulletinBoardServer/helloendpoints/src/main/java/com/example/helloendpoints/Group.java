package com.example.helloendpoints;

import java.util.Date;

import com.google.appengine.api.datastore.Entity;

public class Group {

	public long id;
	public String name;
	public Date time;
	
	public Group() {
		
	}
	
	public Group(String name) {
		this.name = name;
		this.time = new Date();
	}
	
	public Group(String name, Date time) {
		this.name = name;
		this.time = time;
	}

	public Group(Entity e) {
		try {
			this.id = e.getKey().getId();
			this.name = (String) e.getProperty("name");
			this.time = (Date) e.getProperty("time");
		} catch (Exception exception) {
			exception.printStackTrace();
		}
	}

	public Entity toEntity() {
		Entity e = new Entity("Group");
		e.setProperty("name", this.name);
		e.setProperty("time", this.time);
		return e;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Date getTime() {
		return time;
	}

	public void setTime(Date time) {
		this.time = time;
	}
	
}
