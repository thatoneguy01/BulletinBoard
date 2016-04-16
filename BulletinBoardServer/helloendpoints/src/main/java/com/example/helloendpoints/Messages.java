package com.example.helloendpoints;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.List;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.google.appengine.api.datastore.*;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Query.FilterOperator;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.Named;

/**
 * Defines v1 of a helloworld API, which provides simple "greeting" methods.
 */
@Api(
		name = "helloworld",
		version = "v3",
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
	public static final DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	
	public static long getUniqueMessageId() {
		long largest = -1;
		for (Message message : messages) {
			if (message.getId() > largest) {
				largest = message.getId();
			}
		}
		return (largest + 1);
	}
	
	public static long getUniqueAccountID() {
		long largest = -1;
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
	
	/*public static int getUniqueGroupId() {
		int largest = -1;
		for (Group group : groups) {
			if (group.getId() > largest) {
				largest = group.getId();
			}
		}
		return (largest + 1);
	}*/
	
	@ApiMethod(name = "createMessage", httpMethod = "post", path = "messages/createMessage")
	public Map createMessage(Message message) {
		//Message m = new Message(message, postingUser, latitude, longitude, groupId, timePosted);
		Key k = datastore.put(message.toEntity());
		Map m = new HashMap<>();
		if (k != null)
			m.put("succeeded", new Boolean(true));
		else
			m.put("succeeded", new Boolean(false));
		return m;

		//Logger.getGlobal().log(Level.SEVERE, "WORKING");
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
	
	@ApiMethod(name = "replies", httpMethod = "get", path = "replies/replies")
	public List<Reply> replies(@Named("messageId") String messageId) {
		List<Reply> messageReplies = new ArrayList<Reply>();
		for (Reply reply : replies) {
			if (reply.getParentId().equals(messageId)) {
				messageReplies.add(reply);
			}
		}
		return messageReplies;
	}
	
	@ApiMethod(name = "createReply", httpMethod = "post", path = "replies/createReply")
	public void createReply() {
		//TODO
	}
	
	@ApiMethod(name = "messageForUser", httpMethod = "get", path = "messages/messagesForUser")
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
	
	@ApiMethod(name = "checkPassword", httpMethod = "get", path = "accounts/checkPassword")
	public Map<String, Boolean> checkPassword(@Named("username") String username, @Named("password") String password) throws NoSuchAlgorithmException, UnsupportedEncodingException {
		/*List<String> result = new ArrayList<String>();
		Account account = getAccount(username);
		if (account.getHashedPassword().equals(hashedPassword)) {
			result.add("true");
		} else {
			result.add("false");
		}
		return result;*/

		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (results.isEmpty()) {
			Map<String, Boolean> toReturn = new HashMap<>();
			toReturn.put("accepted", new Boolean(false));
			return toReturn;
		}
		else {
			Account account = new Account(results.get(0));
			MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
			String saltPassword = account.salt + password;
			messageDigest.update(saltPassword.getBytes("UTF-8"));
			byte[] digest = messageDigest.digest();
			String hashedPassword = new String(digest);
			if (hashedPassword.equals(account.hashedPassword)) {
				Map<String, Boolean> toReturn = new HashMap<>();
				toReturn.put("accepted", new Boolean(true));
				return toReturn;
			}
			else
			{
				Map<String, Boolean> toReturn = new HashMap<>();
				toReturn.put("accepted", new Boolean(false));
				return toReturn;
			}
		}
	}
	
	private Account getAccount(String username) {
		for (Account account : accounts) {
			if (account.getUsername().equals(username)) {
				return account;
			}
		}
		return null;
	}
	
	@ApiMethod(name = "createAccount", httpMethod = "get", path = "accounts/createAccount")
	public Map createAccount(@Named("username") String username, @Named("password") String password) {
		/*boolean taken = false;
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
		}*/
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (!results.isEmpty()) {
			Map toReturn = new HashMap<>();
			toReturn.put("succeeded", new Boolean(false));
			toReturn.put("reason", "username already in use");
			return toReturn;
		}
		try {
			MessageDigest messageDigest = MessageDigest.getInstance("SHA-256");
			SecureRandom secureRandom = SecureRandom.getInstance("SHA1PRNG");
			byte[] bytes = new byte[64];
			secureRandom.nextBytes(bytes);
			String salt = new String(bytes);
			String saltPassword = salt + password;
			messageDigest.update(saltPassword.getBytes("UTF-8"));
			byte[] digest = messageDigest.digest();
			Account account = new Account(username, new String(digest), salt);
			datastore.put(account.toEntity());

			Map toReturn = new HashMap<>();
			toReturn.put("succeeded", new Boolean(true));
			toReturn.put("reason", "");

			return toReturn;
		}
		catch (Exception e) {
			Map toReturn = new HashMap<>();
			toReturn.put("succeeded", new Boolean(false));
			toReturn.put("reason", e.getMessage());

			return toReturn;
		}
	}
	
	@ApiMethod(name = "checkAccount", httpMethod = "get", path = "accounts/accountExists")
	public Map<String, Boolean> accountExists(@Named("username") String username) {
		/*List<String> result = new ArrayList<String>();
		for (Account account : accounts) {
			if (account.getUsername().equals(username)) {
				result.add(account.getSalt());
			}
		}
		return result;*/

		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		Map<String, Boolean> toReturn = new HashMap<>();
		if (results.isEmpty())
		{
			toReturn.put("exists", new Boolean(false));
			return toReturn;
		}
		else
		{
			toReturn.put("exists", new Boolean(true));
			return toReturn;
		}
	}

	@ApiMethod(name = "checkSocial", httpMethod = "get", path = "accounts/socialAccountExists")
	public Map socialExists(@Named("userId") long userId) {
		Filter filter = new FilterPredicate("social", FilterOperator.EQUAL, userId);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		Map toReturn = new HashMap<>();
		if (results.isEmpty())
		{
			toReturn.put("exists", new Boolean(false));
			toReturn.put("username", "");
			return toReturn;
		}
		else
		{
			toReturn.put("exists", new Boolean(true));
			toReturn.put("username", new Account(results.get(0)).username);
			return toReturn;
		}
	}
	
	@ApiMethod(name = "createSocialAccount", httpMethod = "get", path = "accounts/createSocialAccount")
	public Map createSocialAccount(@Named("username") String username, @Named("token") long token) {
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (!results.isEmpty()) {
			Map toReturn = new HashMap<>();
			toReturn.put("succeeded", new Boolean(false));
			toReturn.put("reason", "username already in use");
			return toReturn;
		}
		Account account = new Account(username, token);
		datastore.put(account.toEntity());

		Map toReturn = new HashMap<>();
		toReturn.put("succeeded", new Boolean(true));
		toReturn.put("reason", "");

		return toReturn;
	}

	@ApiMethod(name = "listAccounts", httpMethod = "get", path = "accounts/list")
	public List<Account> getAllAccounts() {
		Query q = new Query("Account").addSort("username", Query.SortDirection.ASCENDING);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		List<Account> accounts = new LinkedList<>();
		if (results.isEmpty())
			return new LinkedList<>();
		for (Entity e : results)
			accounts.add(new Account(e));
		return accounts;
	}
	
	@ApiMethod(name = "checkSocialLogin", httpMethod = "get", path = "accounts/checkSocialLogin")
	public Map checkSocialLogin(@Named("username") String username, @Named("token") long token) {
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (results.isEmpty()) {
			Map<String, Boolean> toReturn = new HashMap<>();
			toReturn.put("accepted", new Boolean(false));
			return toReturn;
		}
		else {
			Account account = new Account(results.get(0));
			if (token == account.social) {
				Map<String, Boolean> toReturn = new HashMap<>();
				toReturn.put("accepted", new Boolean(true));
				return toReturn;
			}
			else
			{
				Map<String, Boolean> toReturn = new HashMap<>();
				toReturn.put("accepted", new Boolean(false));
				return toReturn;
			}
		}
	}
	
	/*@ApiMethod(name = "createGroup", httpMethod = "get", path = "groups/createGroup")
	public Map createGroup(@Named("groupName") String groupName) {
		Group group = new Group(groupName);
		groups.add(group);
		HashMap toReturn = new HashMap<>();
		toReturn.put("groupId", new Long(group.getId()));
		return toReturn;
		//return group.getId();
	}*/
	
	@ApiMethod(name = "addToGroup", httpMethod = "post", path = "groups/createGroup")
	public void addToGroup(@Named("name") String name, List<Group> members) {
		//TODO parse body for list of username strings
	}
	
	@ApiMethod(name = "leaveGroup", httpMethod = "get", path = "groups/leaveGroup")
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
	
	@ApiMethod(name = "listGroups", httpMethod = "get", path = "groups/groupsForUser")
	public List<Group> listGroups(@Named("username") String username) {
		// just list groupId and groupName
		//TODO
		/*Account account = this.getAccount(username);
		List<Group> userGroups = new ArrayList<Group>();
		for (GroupMembership groupMembership : groupMemberships) {
			if (groupMembership.getMemberId() == account.getId()) {
				userGroups.addAll(this.getGroups(groupMembership.getGroupId()));
			}
		}
		return userGroups;*/

		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (!results.isEmpty()) {
			long accountId = results.get(0).getKey().getId();
			filter = new FilterPredicate("memberId", FilterOperator.EQUAL, accountId);
			q = new Query("GroupMembership").setFilter(filter);
			results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		}
		else
			return new ArrayList<>();
		if (!results.isEmpty()) {
			List groupIds = new LinkedList();
			for (Entity e : results) {
				groupIds.add(e.getProperty("groupId"));
			}
			filter = new FilterPredicate("ID", FilterOperator.IN, groupIds);
			q = new Query("Group").setFilter(filter).addSort("name", Query.SortDirection.ASCENDING);
			results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		}
		if (!results.isEmpty()) {
			List<Group> groups = new LinkedList();
			for (Entity e : results) {
				groups.add(new Group(e));
			}
			return groups;
		}
		return null;
	}
}
