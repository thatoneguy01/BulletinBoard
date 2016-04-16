package com.example.helloendpoints;

import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;

public class Account {

	public long id;
	public Key key;
	public String username;
	public String hashedPassword;
	public String salt;
	public String clientID;
	public long social;
	
	public Account(String username, String hashedPassword, String salt) {
		this.username = username;
		this.hashedPassword = hashedPassword;
		this.salt = salt;
		this.clientID = "";
		this.social =-1;
	}

	public Account(String username, long socialId) {
		this.username = username;
		this.social = socialId;
		hashedPassword = null;
		salt = null;
		clientID = null;
	}

	public Account(Entity e) {
		try {
			this.username = (String) e.getProperty("username");
			this.hashedPassword = (String) e.getProperty("hashedPassword");
			this.salt = (String) e.getProperty("salt");
			this.clientID = (String) e.getProperty("clientId");
			this.social = (long) e.getProperty("social");
			this.key = e.getKey();
			this.id = this.key.getId();
		}
		catch (NullPointerException e1) {
			e1.printStackTrace();
		}
	}

	public Entity toEntity() {
		Entity e = new Entity("Account");
		e.setProperty("username", username);
		e.setProperty("hashedPassword", hashedPassword);
		e.setProperty("salt", salt);
		e.setProperty("clientId", clientID);
		e.setProperty("social", social);
		return e;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getHashedPassword() {
		return hashedPassword;
	}

	public void setHashedPassword(String hashedPassword) {
		this.hashedPassword = hashedPassword;
	}

	public String getSalt() {
		return salt;
	}

	public void setSalt(String salt) {
		this.salt = salt;
	}

	public String getClientID() {
		return clientID;
	}

	public void setClientID(String clientID) {
		this.clientID = clientID;
	}

	public long getSocial() {
		return social;
	}

	public void setSocial(long social) {
		this.social = social;
	}
}
