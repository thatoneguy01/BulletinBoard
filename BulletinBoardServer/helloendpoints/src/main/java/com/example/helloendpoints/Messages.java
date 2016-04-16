package com.example.helloendpoints;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.Named;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;

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
	
//	public static long getUniqueMessageId() {
//		long largest = -1;
//		for (Message message : messages) {
//			if (message.getId() > largest) {
//				largest = message.getId();
//			}
//		}
//		return (largest + 1);
//	}
//	
//	public static long getUniqueAccountID() {
//		long largest = -1;
//		for (Account account : accounts) {
//			if (account.getId() > largest) {
//				largest = account.getId();
//			}
//		}
//		return (largest + 1);
//	}
//	
//	public static int getUniqueReplyId() {
//		int largest = -1;
//		for (Reply reply : replies) {
//			if (reply.getId() > largest) {
//				largest = reply.getId();
//			}
//		}
//		return (largest + 1);
//	}
//	
//	public static int getUniqueGroupId() {
//		int largest = -1;
//		for (Group group : groups) {
//			if (group.getId() > largest) {
//				largest = group.getId();
//			}
//		}
//		return (largest + 1);
//	}
	
	@ApiMethod(name = "createMessage", httpMethod = "post", path = "messages/createMessage")
	public Map createMessage(Message message) {
		Key k = datastore.put(message.toEntity());
		Map m = new HashMap<>();
		if (k != null)
			m.put("succeeded", new Boolean(true));
		else
			m.put("succeeded", new Boolean(false));
		return m;
	}
	
	@ApiMethod(name = "getAllMessages", httpMethod = "get", path = "messages/getAllMessages")
	public List<Message> getAllMessages() {
		Query q = new Query("Message").addSort("timePosted", Query.SortDirection.DESCENDING);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		List<Message> messages = new ArrayList<Message>();
		for (Entity e : results) {
			messages.add(new Message(e));
		}
		return messages;
	}
	
	@ApiMethod(name = "getFirst20Messages", httpMethod = "get", path = "messages/getFirst20Messages")
	public List<Message> getFirst20Messages() {
		Query q = new Query("Message").addSort("timePosted", Query.SortDirection.DESCENDING);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		List<Message> messages = new ArrayList<Message>();
		if (results.size() > 20) {
			for (int i = 0; i < 20; i++) {
				messages.add(new Message(results.get(i)));
			}
		} else {
			for (Entity e : results) {
				messages.add(new Message(e));
			}
		}
		return messages;
	}
	
	@ApiMethod(name = "messagesNear", httpMethod = "get", path = "messages/messagesNear")
	public List<Message> messagesNear() {
		//TODO
		return null;
	}
	
	@ApiMethod(name = "replies", httpMethod = "get", path = "replies/replies")
	public List<Reply> replies(@Named("messageId") long messageId) {
		Filter filter = new FilterPredicate("parentId", FilterOperator.EQUAL, messageId);
		Query q = new Query("Reply").setFilter(filter).addSort("timePosted", Query.SortDirection.DESCENDING);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		List<Reply> replies = new ArrayList<Reply>();
		for (Entity e : results) {
			replies.add(new Reply(e));
		}
		return replies;
	}
	
	@ApiMethod(name = "getFirst20Replies", httpMethod = "get", path = "messages/getFirst20Replies")
	public List<Reply> getFirst20Replies(@Named("messageId") long messageId) {
		Filter filter = new FilterPredicate("parentId", FilterOperator.EQUAL, messageId);
		Query q = new Query("Reply").setFilter(filter).addSort("timePosted", Query.SortDirection.DESCENDING);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		List<Reply> replies = new ArrayList<Reply>();
		if (results.size() > 20) {
			for (int i = 0; i < 20; i++) {
				replies.add(new Reply(results.get(i)));
			}
		} else {
			for (Entity e : results) {
				replies.add(new Reply(e));
			}
		}
		return replies;
	}
	
	@ApiMethod(name = "createReply", httpMethod = "post", path = "replies/createReply")
	public Map<String, Boolean> createReply(Reply reply) {
		Key k = datastore.put(reply.toEntity());
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		if (k != null) {
			result.put("succeeded", new Boolean(true));
		} else {
			result.put("succeeded", new Boolean(false));
		}
		return result;
	}
	
	@ApiMethod(name = "messageForUser", httpMethod = "get", path = "messages/messagesForUser")
	public List<Message> messageForUser(@Named("username") String username) {
		//TODO
		return null;
	}
	
	@ApiMethod(name = "modifyMessage", httpMethod = "post", path = "messages/modifyMessage")
	public Map<String, Boolean> modifyMessage(@Named("messageId") long messageId, @Named("modifiedMessage") String modifiedMessage) {
		Key messageIdKey = KeyFactory.createKey("Message", messageId);
		Filter filter = new FilterPredicate(Entity.KEY_RESERVED_PROPERTY, FilterOperator.EQUAL, messageIdKey);
		Query q = new Query("Message").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		if (results.isEmpty()) {
			result.put("succeeded", new Boolean(false));
		} else {
			Entity e = results.get(0);
			e.setProperty("message", modifiedMessage);
			datastore.put(e);
			result.put("succeeded", new Boolean(true));
		}
		return result;
	}
	
	@ApiMethod(name = "deleteMessage", httpMethod = "get", path = "messages/deleteMessage")
	public Map<String, Boolean> deleteMessage(@Named("messageId") long messageId) {
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		try {
			Key messageIdKey = KeyFactory.createKey("Message", messageId);
			datastore.delete(messageIdKey);
			result.put("succeeded", new Boolean(true));
			return result;
		} catch (Exception e) {
			result.put("succeeded", new Boolean(false));
			return result;
		}
	}
	
	@ApiMethod(name = "score", httpMethod = "get", path = "messages/score")
	public Map<String, Boolean> score(@Named("messageId") long messageId, @Named("scoreMod") int scoreMod) {
		Key messageIdKey = KeyFactory.createKey("Message", messageId);
		Filter filter = new FilterPredicate(Entity.KEY_RESERVED_PROPERTY, FilterOperator.EQUAL, messageIdKey);
		Query q = new Query("Message").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		if (results.isEmpty()) {
			result.put("succeeded", new Boolean(false));
		} else {
			Entity e = results.get(0);
			e.setProperty("score", ((long) e.getProperty("score") + scoreMod));
			datastore.put(e);
			result.put("succeeded", new Boolean(true));
		}
		return result;
	}
	
	@ApiMethod(name = "checkPassword", httpMethod = "get", path = "accounts/checkPassword")
	public Map<String, Boolean> checkPassword(@Named("username") String username, @Named("password") String password) throws NoSuchAlgorithmException, UnsupportedEncodingException {
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
	
	@ApiMethod(name = "createGroup", httpMethod = "get", path = "groups/createGroup")
	public Map createGroup(Group group) {
		Key k = datastore.put(group.toEntity());
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		if (k != null) {
			result.put("succeeded", new Boolean(true));
		} else {
			result.put("succeeded", new Boolean(false));
		}
		return result;
	}
	
	/*@ApiMethod(name = "addToGroup", httpMethod = "post", path = "groups/createGroup")
	public void addToGroup(@Named("name") String name, List<Group> members) {
		//TODO parse body for list of username strings
	}*/
	
	@ApiMethod(name = "leaveGroup", httpMethod = "get", path = "groups/leaveGroup")
	public Map<String, Boolean> leaveGroup(@Named("username") String username, @Named("groupId") long groupId) {
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q1 = new Query("Account").setFilter(filter);
		List<Entity> results1 = datastore.prepare(q1).asList(FetchOptions.Builder.withDefaults());
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		if (results1.isEmpty()) {
			result.put("succeeded", new Boolean(false));
			return result;
		} else {
			long accountId = (long) results1.get(0).getProperty("id");
			Filter memberIdFilter = new FilterPredicate("groupId", FilterOperator.EQUAL, groupId);
			Filter groupIdFilter = new FilterPredicate("memberId", FilterOperator.EQUAL, accountId);
			Filter groupMembershipFilter = CompositeFilterOperator.and(groupIdFilter, memberIdFilter);
			Query q2 = new Query("GroupMembership").setFilter(groupMembershipFilter);
			List<Entity> results2 = datastore.prepare(q2).asList(FetchOptions.Builder.withDefaults());
			if (results2.isEmpty()) {
				result.put("succeeded", new Boolean(false));
				return result;
			} else {
				long groupMembershipId = ((long) results2.get(0).getProperty("id"));
				try {
					Key groupMembershipIdKey = KeyFactory.createKey("GroupMembership", groupMembershipId);
					datastore.delete(groupMembershipIdKey);
					result.put("succeeded", new Boolean(true));
					return result;
				} catch (Exception e) {
					result.put("succeeded", new Boolean(false));
					return result;
				}
			}
		}
	}
	
	@ApiMethod(name = "listGroups", httpMethod = "get", path = "groups/groupsForUser")
	public List<Group> listGroups(@Named("username") String username) {
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
