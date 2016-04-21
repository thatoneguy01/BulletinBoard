package com.example.helloendpoints;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.google.api.server.spi.config.Api;
import com.google.api.server.spi.config.ApiMethod;
import com.google.api.server.spi.config.Named;
import com.google.api.server.spi.config.Nullable;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.GeoPt;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.CompositeFilterOperator;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Query.GeoRegion.Circle;
import com.google.appengine.api.datastore.Query.StContainsFilter;

/**
 * Defines v5 of the Bulletin Board API, which provides the server funtions for the app.
 */
@Api(
		name = "bulletinBoard",
		version = "v5",
		scopes = {Constants.EMAIL_SCOPE},
		clientIds = {Constants.WEB_CLIENT_ID, Constants.ANDROID_CLIENT_ID, Constants.IOS_CLIENT_ID, Constants.API_EXPLORER_CLIENT_ID},
		audiences = {Constants.ANDROID_AUDIENCE}
		)
public class Messages {

	public static final DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	
	@ApiMethod(name = "createMessage", httpMethod = "post", path = "messages/createMessage")
	public Map<String, Boolean> createMessage(Message message) {
		if (message.timePosted == null)
			message.timePosted = new Date();
		Key k = datastore.put(message.toEntity());
		Map<String, Boolean> m = new HashMap<String, Boolean>();
		if (k != null) {
			m.put("succeeded", true);
		} else {
			m.put("succeeded", false);
		}
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

	@ApiMethod(name = "messagesForUser", httpMethod = "get", path = "messages/messagesForUser")
	public List<Message> messageForUser(@Named("username") String username) {
		Filter filter = new FilterPredicate("postingUser", FilterOperator.EQUAL, username);
		Query q = new Query("Message").setFilter(filter).addSort("timePosted", Query.SortDirection.DESCENDING);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (!results.isEmpty()) {
			List<Message> messages = new LinkedList<>();
			for (Entity e : results) {
				messages.add(new Message(e));
			}
			return messages;
		}
		else {
			Logger.getGlobal().log(Level.SEVERE, "No Messages Found");
			return new LinkedList<Message>();
		}
	}

	@ApiMethod(name = "modifyMessage", httpMethod = "post", path = "messages/modifyMessage")
	public Map<String, Boolean> modifyMessage(@Named("messageId") long messageId, @Named("modifiedMessage")String modifiedMessage) {
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
			Filter f = new FilterPredicate("parentId", FilterOperator.EQUAL, messageId);
			Query q = new Query("Reply").setFilter(f);
			List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
			for (Entity e : results)
				datastore.delete(e.getKey());
			result.put("succeeded", new Boolean(true));
			return result;
		} catch (Exception e) {
			result.put("succeeded", new Boolean(false));
			return result;
		}
	}

	@ApiMethod(name = "changeScore", httpMethod = "get", path = "messages/score")
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

//  GeoPt is in closed alpha, unable to deploy at this time.
//	@ApiMethod(name = "messagesNear", httpMethod = "get", path = "messages/messagesNear")
//	public List<Message> messagesNear(@Named("username") @Nullable String username, @Named("latitude") float latitude, @Named("longitude") float longitude) {
//		List<Message> result = new ArrayList<Message>();
//		GeoPt center = new GeoPt(latitude, longitude);
//		double radius = 300;
//		Filter f1 = new StContainsFilter("location", new Circle(center, radius));
//		Query q = new Query("Message").setFilter(f1);//.addSort("timePosted", Query.SortDirection.DESCENDING);
//		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
//		for (Entity e : results) {
//			result.add(new Message(e));
//		}
//		if (username != null) {
//			List<Group> groups = new LinkedList<>();
//			groups = listGroups(username);
//			List<Long> groupIds = new ArrayList<>();
//			groupIds.add((long) -1);
//			for (Group g : groups) {
//				groupIds.add(g.id);
//			}
//			List<Message> viewable = new LinkedList<>();
//			for (Message m : result) {
//				if (groupIds.contains(new Long(m.groupId)))
//					viewable.add(m);
//			}
//			return viewable;
//		}
//		return result;
//	}

	@ApiMethod(name = "messagesNear", httpMethod = "get", path = "messages/messagesNear")
	public List<Message> messagesNear(@Named("username") @Nullable String username, @Named("latitude") double latitude, @Named("longitude") double longitude) {
		List<Message> result = new ArrayList<Message>();
		float latDelta = .0018f;
		float lonDelta = (float)Math.abs(200 / (111111 * Math.cos(latitude)));
		Filter north = new FilterPredicate("latitude", FilterOperator.LESS_THAN_OR_EQUAL, latitude + latDelta);
		Filter south = new FilterPredicate("latitude", FilterOperator.GREATER_THAN_OR_EQUAL, latitude - latDelta);
		Filter east = new FilterPredicate("longitude", FilterOperator.LESS_THAN_OR_EQUAL, longitude + lonDelta);
		Filter west = new FilterPredicate("longitude", FilterOperator.GREATER_THAN_OR_EQUAL, longitude - lonDelta);
		List<Filter> filterList= new LinkedList<>();
		filterList.add(north);
		filterList.add(south);
		Filter zone = new Query.CompositeFilter(CompositeFilterOperator.AND, filterList);
		Query q = new Query("Message").setFilter(zone);//.addSort("timePosted", Query.SortDirection.DESCENDING);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		filterList= new LinkedList<>();
		filterList.add(east);
		filterList.add(west);
		zone = new Query.CompositeFilter(CompositeFilterOperator.AND, filterList);
		q = new Query("Message").setFilter(zone);//.addSort("timePosted", Query.SortDirection.DESCENDING);
		List<Entity> results2 = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		results.retainAll(results2);
		for (Entity e : results) {
			result.add(new Message(e));
		}
		if (username != null) {
			List<Group> groups = new LinkedList<>();
			groups = listGroups(username);
			List<Long> groupIds = new ArrayList<>();
			groupIds.add((long) -1);
			for (Group g : groups) {
				groupIds.add(g.id);
			}
			List<Message> viewable = new LinkedList<>();
			for (Message m : result) {
				if (groupIds.contains(new Long(m.groupId)))
					viewable.add(m);
			}
			return viewable;
		}
		return result;
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
	
	@ApiMethod(name = "getFirst20Replies", httpMethod = "get", path = "replies/getFirst20Replies")
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
		reply.timePosted = new Date();
		Key k = datastore.put(reply.toEntity());
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		if (k != null) {
			result.put("succeeded", new Boolean(true));
		} else {
			result.put("succeeded", new Boolean(false));
		}
		return result;
	}
	
	@ApiMethod(name = "checkLogin", httpMethod = "get", path = "accounts/checkPassword")
	public Map<String, Boolean> checkPassword(@Named("username") String username, @Named("password") String password) throws NoSuchAlgorithmException, UnsupportedEncodingException {
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (results.isEmpty()) {
			Map<String, Boolean> toReturn = new HashMap<>();
			toReturn.put("accepted", new Boolean(false));
			return toReturn;
		} else {
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
			} else {
				Map<String, Boolean> toReturn = new HashMap<>();
				toReturn.put("accepted", new Boolean(false));
				return toReturn;
			}
		}
	}
	
	@ApiMethod(name = "createAccount", httpMethod = "get", path = "accounts/createAccount")
	public Map<String, Object> createAccount(@Named("username") String username, @Named("password") String password) {
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (!results.isEmpty()) {
			Map<String, Object> toReturn = new HashMap<String, Object>();
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

			Map<String, Object> toReturn = new HashMap<String, Object>();
			toReturn.put("succeeded", new Boolean(true));
			toReturn.put("reason", "");

			return toReturn;
		}
		catch (Exception e) {
			Map<String, Object> toReturn = new HashMap<String, Object>();
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
		if (results.isEmpty()) {
			toReturn.put("exists", new Boolean(false));
			return toReturn;
		} else {
			toReturn.put("exists", new Boolean(true));
			return toReturn;
		}
	}

	@ApiMethod(name = "socialAccountExists", httpMethod = "get", path = "accounts/socialAccountExists")
	public Map<String, Object> socialExists(@Named("userId") long userId) {
		Filter filter = new FilterPredicate("social", FilterOperator.EQUAL, userId);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		Map<String, Object> toReturn = new HashMap<String, Object>();
		if (results.isEmpty()) {
			toReturn.put("exists", new Boolean(false));
			toReturn.put("username", "");
			return toReturn;
		} else {
			toReturn.put("exists", new Boolean(true));
			toReturn.put("username", new Account(results.get(0)).username);
			return toReturn;
		}
	}
	
	@ApiMethod(name = "createSocialAccount", httpMethod = "get", path = "accounts/createSocialAccount")
	public Map<String, Object> createSocialAccount(@Named("username") String username, @Named("token") long token) {
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (!results.isEmpty()) {
			Map<String, Object> toReturn = new HashMap<String, Object>();
			toReturn.put("succeeded", new Boolean(false));
			toReturn.put("reason", "username already in use");
			return toReturn;
		}
		Account account = new Account(username, token);
		datastore.put(account.toEntity());

		Map<String, Object> toReturn = new HashMap<String, Object>();
		toReturn.put("succeeded", new Boolean(true));
		toReturn.put("reason", "");

		return toReturn;
	}

	@ApiMethod(name = "listAllAccounts", httpMethod = "get", path = "accounts/list")
	public List<Account> getAllAccounts() {
		Query q = new Query("Account").addSort("username", Query.SortDirection.ASCENDING);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		List<Account> accounts = new LinkedList<>();
		if (results.isEmpty()) {
			return new LinkedList<>();
		}
		for (Entity e : results) {
			accounts.add(new Account(e));
		}
		return accounts;
	}
	
	@ApiMethod(name = "checkSocialLogin", httpMethod = "get", path = "accounts/checkSocialLogin")
	public Map<String, Boolean> checkSocialLogin(@Named("username") String username, @Named("token") long token) {
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (results.isEmpty()) {
			Map<String, Boolean> toReturn = new HashMap<>();
			toReturn.put("accepted", new Boolean(false));
			return toReturn;
		} else {
			Account account = new Account(results.get(0));
			if (token == account.social) {
				Map<String, Boolean> toReturn = new HashMap<>();
				toReturn.put("accepted", new Boolean(true));
				return toReturn;
			} else {
				Map<String, Boolean> toReturn = new HashMap<>();
				toReturn.put("accepted", new Boolean(false));
				return toReturn;
			}
		}
	}
	
	@ApiMethod(name = "createEmptyGroup", httpMethod = "post", path = "groups/createEmptyGroup")
	public Map<String, Boolean> createGroup(Group group) {
		Key k = datastore.put(group.toEntity());
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		if (k != null) {
			result.put("succeeded", new Boolean(true));
		} else {
			result.put("succeeded", new Boolean(false));
		}
		return result;
	}
	
//	@ApiMethod(name = "addToGroup", httpMethod = "post", path = "groups/addToGroup")
//	public Map<String, Boolean> addToGroup(@Named("groupName") String groupName, @Named("memberNames") List<Long> memberNames) {
//		// TODO assuming group names are unique, another version is commented out below where this assumption is not made
//		// and the first parameter is the groupid instead of the group name
//		// get group id
//		// create groupmembership with memberids for group id
//		Filter filter = new FilterPredicate("name", FilterOperator.EQUAL, groupName);
//		Query q = new Query("Group").setFilter(filter);
//		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
//		Map<String, Boolean> result = new HashMap<String, Boolean>();
//		if (results.size() != 1) {
//			result.put("succeeded", new Boolean(false));
//		} else {
//			Entity e = results.get(0);
//			int failedToAdd = 0;
//			for (Long memberId : memberNames) {
//				GroupMembership groupMembership = new GroupMembership(e.getKey().getId(), memberId);
//				Key k = datastore.put(groupMembership.toEntity());
//				if (k == null) {
//					failedToAdd++;
//				}
//			}
//			if (failedToAdd == memberNames.size()) {
//				result.put("succeeded", new Boolean(false));
//			} else {
//				result.put("succeeded", new Boolean(true));
//			}
//		}
//		return result;
//	}
	
//	@ApiMethod(name = "addToGroup", httpMethod = "post", path = "groups/addToGroup")
//	public Map<String, Boolean> addToGroup(@Named("groupId") long groupId, List<Long> memberNames) {
//		Filter filter = new FilterPredicate("id", FilterOperator.EQUAL, groupId);
//		Query q = new Query("Group").setFilter(filter);
//		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
//		Map<String, Boolean> result = new HashMap<String, Boolean>();
//		if (results.size() != 1) {
//			result.put("succeeded", new Boolean(false));
//		} else {
//			Entity e = results.get(0);
//			for (Long memberId : memberNames) {
//				GroupMembership groupMembership = new GroupMembership(e.getKey().getId(), memberId);
//				datastore.put(groupMembership.toEntity());
//			}
//		}
//		return result;
//	}

	@ApiMethod(name = "createGroup", httpMethod = "post", path = "groups/createGroup")
	public Map<String, Boolean> newGroup(@Named("name") String name, MemberList memberNames) {
		Group g = new Group(name);
		Key k = datastore.put(g.toEntity());
		Map<String, Boolean> result = new HashMap<String, Boolean>();
		Filter filter = new FilterPredicate("username", FilterOperator.IN, memberNames.memberNames);
		Query q1 = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q1).asList(FetchOptions.Builder.withDefaults());
		if (!results.isEmpty()) {
			for (Entity e : results) {
				GroupMembership gm = new GroupMembership(k.getId(), e.getKey().getId());
				datastore.put(gm.toEntity());
			}
			result.put("succeeded", new Boolean(true));
		}
		else {
			result.put("succeeded", new Boolean(false));
		}
		return result;
	}
	
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
			long accountId = results1.get(0).getKey().getId();
			Filter memberIdFilter = new FilterPredicate("groupId", FilterOperator.EQUAL, groupId);
			Filter groupIdFilter = new FilterPredicate("memberId", FilterOperator.EQUAL, accountId);
			Filter groupMembershipFilter = CompositeFilterOperator.and(groupIdFilter, memberIdFilter);
			Query q2 = new Query("GroupMembership").setFilter(groupMembershipFilter);
			List<Entity> results2 = datastore.prepare(q2).asList(FetchOptions.Builder.withDefaults());
			if (results2.isEmpty()) {
				result.put("succeeded", new Boolean(false));
				return result;
			} else {
				//long groupMembershipId = ((long) results2.get(0).getProperty("groupId"));
				try {
					//Key groupMembershipIdKey = KeyFactory.createKey("GroupMembership", groupMembershipId);
					datastore.delete(results2.get(0).getKey());
					result.put("succeeded", new Boolean(true));
					return result;
				} catch (Exception e) {
					result.put("succeeded", new Boolean(false));
					return result;
				}
			}
		}
	}
	
	// TODO this is for testing group creation, can be removed after testing is done
	@ApiMethod(name = "listAllGroups", httpMethod = "get", path = "groups/listAllGroups")
	public List<Group> listAllGroups() {
		Query q = new Query("Group");
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		List<Group> groups = new ArrayList<Group>();
		for (Entity e : results) {
			Group toAdd = new Group(e);
			groups.add(toAdd);
		}
		return groups;
	}
	
	// TODO always returns empty list
	@ApiMethod(name = "groupsForUser", httpMethod = "get", path = "groups/groupsForUser")
	public List<Group> listGroups(@Named("username") String username) {
		Filter filter = new FilterPredicate("username", FilterOperator.EQUAL, username);
		Query q = new Query("Account").setFilter(filter);
		List<Entity> results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		if (!results.isEmpty()) {
			long accountId = results.get(0).getKey().getId();
			filter = new FilterPredicate("memberId", FilterOperator.EQUAL, accountId);
			q = new Query("GroupMembership").setFilter(filter);
			results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		} else {
			return new ArrayList<>();
		}
		if (!results.isEmpty()) {
			List<Key> groupIds = new LinkedList<>();
			for (Entity e : results) {
				groupIds.add(KeyFactory.createKey("Group", (long)e.getProperty("groupId")));
			}
			filter = new FilterPredicate(Entity.KEY_RESERVED_PROPERTY, FilterOperator.IN, groupIds);
			q = new Query("Group").setFilter(filter).addSort("name", Query.SortDirection.ASCENDING);
			results = datastore.prepare(q).asList(FetchOptions.Builder.withDefaults());
		}
		if (!results.isEmpty()) {
			List<Group> groups = new LinkedList<Group>();
			for (Entity e : results) {
				groups.add(new Group(e));
			}
			return groups;
		}
		return null;
	}
}
