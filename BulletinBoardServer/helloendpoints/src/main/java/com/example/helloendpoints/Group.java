package com.example.helloendpoints;

import java.util.Calendar;
import java.util.Date;

public class Group {

	public int id;
	public String name;
	public Date time;
	
	public Group(String name) {
		this.id = Messages.getUniqueGroupId();
		this.name = name;
		this.time = Calendar.getInstance().getTime();
	}
	
	public int getId() {
		return id;
	}

	public void setId(int id) {
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
