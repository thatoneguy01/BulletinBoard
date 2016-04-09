package com.example.helloendpoints;

import java.util.ArrayList;
import java.util.List;
import java.util.*;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.Named;
import com.google.api.server.spi.response.BadRequestException;

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
	public static ArrayList<Account> accounts = new ArrayList<Account>();
	public static ArrayList<Reply> replies = new ArrayList<Reply>();
	public static ArrayList<Group> groups = new ArrayList<Group>();
	public static ArrayList<GroupMembership> groupMemberships = new ArrayList<GroupMembership>();
	
	public static int getUniqueMessageId() {
		int largest = -1;
		for (Message message : messages) {
			if (message.getId() > largest) {
				largest = message.getId();
			}
		}
		return (largest + 1);
	}
	
	public static int getUniqueAccountID() {
		int largest = -1;
		for (Account account : accounts) {
			if (account.getId() > largest) {
				largest = account.getId();
			}
		}
		return (largest + 1);
	}
	
	public static int getUniqueReplyId() {
		int largest = -1;
		for (Reply reply : replies) {
			if (reply.getId() > largest) {
				largest = reply.getId();
			}
		}
		return (largest + 1);
	}
	
	public static int getUniqueGroupId() {
		int largest = -1;
		for (Group group : groups) {
			if (group.getId() > largest) {
				largest = group.getId();
			}
		}
		return (largest + 1);
	}
	
	@ApiMethod(name = "createMessage", httpMethod = "post", path = "messages/createMessage")
	public void createMessage() {
		//TODO parse input
	}
	
	@ApiMethod(name = "getAllMessages", httpMethod = "get", path = "messages/getAllMessages")
	public List<Message> getAllMessages() {
		return messages;
	}
	
	@ApiMethod(name = "getFirst20Messages", httpMethod = "get", path = "messages/getFirst20Messages")
	public List<Message> getFirst20Messages() {
		//TODO messages must be ordered for this to make sense
		if (messages.size() > 20) {
			return messages.subList(0, 20);
		} else {
			return messages;
		}
	}
	
	@ApiMethod(name = "messagesNear", httpMethod = "get", path = "messages/messagesNear")
	public List<Message> messagesNear() {
		//TODO
		return null;
	}
	
	@ApiMethod(name = "replies", httpMethod = "get", path = "messages/replies")
	public List<Reply> replies(@Named("messageId") String messageId) {
		List<Reply> messageReplies = new ArrayList<Reply>();
		for (Reply reply : replies) {
			if (reply.getParentId().equals(messageId)) {
				messageReplies.add(reply);
			}
		}
		return messageReplies;
	}
	
	@ApiMethod(name = "createReply", httpMethod = "post", path = "messages/createReply")
	public void createReply() {
		//TODO
	}
	
	@ApiMethod(name = "messageForUser", httpMethod = "get", path = "messages/messageForUser")
	public List<Message> messageForUser(@Named("username") String username) {
		//TODO
		return null;
	}
	
	@ApiMethod(name = "modifyMessage", httpMethod = "post", path = "messages/modifyMessage")
	public void modifyMessage(@Named("messageId") int messageId) {
		//TOOD
		//parse message param out of body
		//the body is just a string, not json
	}
	
	@ApiMethod(name = "deleteMessage", httpMethod = "get", path = "messages/deleteMessage")
	public void deleteMessage(@Named("messageId") int messageId) {
		for (Message message : messages) {
			if (message.getId() == messageId) {
				messages.remove(message);
			}
		}
	}
	
	@ApiMethod(name = "score", httpMethod = "get", path = "messages/score")
	public void score(@Named("messageId") int messageId, @Named("scoreMod") int scoreMod) {
		for (Message message : messages) {
			if (message.getId() == messageId) {
				message.setScore(message.getScore() + scoreMod);
			}
		}
	}
	
	@ApiMethod(name = "checkPassword", httpMethod = "get", path = "messages/checkPassword")
	public List<String> checkPassword(@Named("username") String username, @Named("hashedPassword") String hashedPassword) {
		List<String> result = new ArrayList<String>();
		Account account = getAccount(username);
		if (account.getHashedPassword().equals(hashedPassword)) {
			result.add("true");
		} else {
			result.add("false");
		}
		return result;
	}
	
	private Account getAccount(String username) {
		for (Account account : accounts) {
			if (account.getUsername().equals(username)) {
				return account;
			}
		}
		return null;
	}
	
	@ApiMethod(name = "createAccount", httpMethod = "get", path = "messages/createAccount")
	public void createAccount(@Named("username") String username, @Named("hashedPassword") String hashedPassword, @Named("salt") String salt) throws BadRequestException {
		boolean taken = false;
		for (Account account : accounts) {
			if (account.getUsername().equals(username)) {
				taken = true;
			}
		}
		if (!(taken) && hashedPassword.length() > 0 && salt.length() > 0) {
			Account account = new Account(username, hashedPassword, salt);
			accounts.add(account);
		} else {
			throw new BadRequestException("username already exists");
		}
	}
	
	@ApiMethod(name = "checkAccount", httpMethod = "get", path = "messages/accountExists")
	public List<String> accountExists(@Named("username") String username) {
		List<String> result = new ArrayList<String>();
		for (Account account : accounts) {
			if (account.getUsername().equals(username)) {
				result.add(account.getSalt());
			}
		}
		return result;
	}
	
	@ApiMethod(name = "createSocialAccount", httpMethod = "get", path = "messages/createSocialAccount")
	public List<String> createSocialAccount(@Named("username") String username, @Named("token") String token) {
		//TODO 200 = success
		// 400 = failure com.google.api.server.spi.response.BadRequestException
		return null;
	}
	
	@ApiMethod(name = "checkSocialLogin", httpMethod = "get", path = "messages/checkSocialLogin")
	public List<String> checkSocialLogin(@Named("username") String username, @Named("token") String token) {
		List<String> result = new ArrayList<String>();
		Account account = getAccount(username);
		if (account.getSocial().equals(token)) {
			result.add("true");
		} else {
			result.add("false");
		}
		return result;
	}
	
	@ApiMethod(name = "createGroup", httpMethod = "get", path = "messages/createGroup")
	public Map<String, Integer> createGroup(@Named("groupName") String groupName) {
		Group group = new Group(groupName);
		groups.add(group);
		HashMap<String, Integer> toReturn = new HashMap<String, Integer>();
		toReturn.put("groupId", new Integer(group.getId()));
		return toReturn;
		//return group.getId();
	}
	
	@ApiMethod(name = "addToGroup", httpMethod = "post", path = "messages/addToGroup")
	public void addToGroup() {
		//TODO parse body for list of username strings
	}
	
	@ApiMethod(name = "leaveGroup", httpMethod = "get", path = "messages/leaveGroup")
	public void leaveGroup(@Named("username") String username, @Named("groupId") int groupId) {
		Account account = getAccount(username);
		for (GroupMembership groupMembership : groupMemberships) {
			if (groupMembership.getMemberId() == account.getId() && groupMembership.getGroupId() == groupId) {
				groupMemberships.remove(groupMembership);
			}
		}
	}
	
	private List<Group> getGroups(int groupMembershipId) {
		List<Group> memberGroups = new ArrayList<Group>();
		for (Group group : groups) {
			if (group.getId() == groupMembershipId) {
				memberGroups.add(group);
			}
		}
		return memberGroups;
	}
	
	@ApiMethod(name = "listGroups", httpMethod = "get", path = "messages/listGroups")
	public List<Group> listGroups(@Named("username") String username) {
		// just list groupId and groupName
		//TODO
		Account account = this.getAccount(username);
		List<Group> userGroups = new ArrayList<Group>();
		for (GroupMembership groupMembership : groupMemberships) {
			if (groupMembership.getMemberId() == account.getId()) {
				userGroups.addAll(this.getGroups(groupMembership.getGroupId()));
			}
		}
		return userGroups;
	}
}
