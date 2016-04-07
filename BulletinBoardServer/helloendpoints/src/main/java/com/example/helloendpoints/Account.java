package com.example.helloendpoints;

public class Account {

	public int id;
	public String username;
	public String hashedPassword;
	public String salt;
	public String clientID;
	public String social;
	
	public Account(String username, String hashedPassword, String salt) {
		this.id = Messages.getUniqueAccountID();
		this.username = username;
		this.hashedPassword = hashedPassword;
		this.salt = salt;
		this.clientID = "";
		this.social = "";
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
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

	public String getSocial() {
		return social;
	}

	public void setSocial(String social) {
		this.social = social;
	}
}
