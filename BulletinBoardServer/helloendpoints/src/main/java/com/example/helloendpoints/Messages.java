package com.example.helloendpoints;

import java.util.ArrayList;
import java.util.List;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;

/**
 * Defines v1 of a helloworld API, which provides simple "greeting" methods.
 */
@Api(
		name = "helloworld",
		version = "v1",
		scopes = {Constants.EMAIL_SCOPE},
		clientIds = {Constants.WEB_CLIENT_ID, Constants.ANDROID_CLIENT_ID, Constants.IOS_CLIENT_ID, Constants.API_EXPLORER_CLIENT_ID},
		audiences = {Constants.ANDROID_AUDIENCE}
		)
public class Messages {

	public static ArrayList<Message> messages = new ArrayList<Message>();
	static {
		messages.add(new Message("test message", "me"));
		messages.add(new Message("another test", "other person"));
	}
	public static ArrayList<Account> accounts = new ArrayList<Account>();
	static {
		accounts.add(new Account("username"));
	}
	
	@ApiMethod(name = "postMessage", httpMethod = "post")
	public void postMessage(Message message) {
		messages.add(message);
	}
	
	public static int getMessageIndex(String id) {
		int index = -1;
		for (int i = 0; i < messages.size(); i++) {
			if (messages.get(i).getId() == id) {
				index = i;
				break;
			}
		}
		return index;
	}
	
	public void removeMessage(String id) {
		int messageIndex = getMessageIndex(id);
		if (messageIndex != -1) {
			messages.remove(messageIndex);	
		} else {
			//error
		}
	}
	
	@ApiMethod(name = "getAllMessages", httpMethod = "get")
	public List<Message> getAllMessages() {
		return messages;
	}
	
	@ApiMethod(name = "getFirst20Messages", httpMethod = "get")
	public List<Message> getFirst20Messages() {
		return messages.subList(0, 20);
	}
	
	@ApiMethod(name = "getPassword", httpMethod = "get")
	public boolean checkPassword(String hashedPassword, String salt) { //TODO
		return false;
	}
	
	@ApiMethod(name = "createAccount", httpMethod = "post")
	public void createAccount(String username, String hashedPassword, String salt) { //TODO
		
	}
	
	@ApiMethod(name = "checkAccount", httpMethod = "get")
	public boolean checkAccount(String username) {
		for (Account account : accounts) {
			if (account.getUsername().equals(username)) {
				return true;
			}
		}
		return false;
	}
}
