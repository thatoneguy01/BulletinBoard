package com.example.helloendpoints;

public class Account {

	public String id;
	public String username;
	public String hashedPass;
	public String salt;
	public String clientID;
	public String social;
	
	public Account(String username) {
		this.id = "";
		this.username = username;
		this.hashedPass = "";
		this.salt = "";
		this.clientID = "";
		this.social = "";
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getHashedPass() {
		return hashedPass;
	}

	public void setHashedPass(String hashedPass) {
		this.hashedPass = hashedPass;
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

	public String getSocial() {
		return social;
	}

	public void setSocial(String social) {
		this.social = social;
	}
}
