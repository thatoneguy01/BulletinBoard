package com.example.helloendpoints;

import com.google.appengine.api.datastore.Entity;

import java.util.Calendar;
import java.util.Date;

public class Group {

	public long id;
	public String name;
	public Date time;
	
	public Group(String name) {
		//this.id = Messages.getUniqueGroupId();
		this.name = name;
		this.time = Calendar.getInstance().getTime();
	}
	public Group(long id, String name, Date time) {
		this.id = id;
		this.name = name;
		this.time = time;
	}
	public Group() {}

	public Group(Entity e) {
		try {
			this.id = e.getKey().getId();
			this.name = (String)e.getProperty("name");
			this.time = (Date)e.getProperty("timePosted");
		}
		catch (Exception e1) {
			e1.printStackTrace();
		}
	}

	public Entity toEntity() {
		Entity e = new Entity("Group");
		e.setProperty("name", this.name);
		e.setProperty("timePosted", this.time);
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
