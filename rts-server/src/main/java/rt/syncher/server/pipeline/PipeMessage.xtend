package rt.syncher.server.pipeline

import io.vertx.core.json.JsonObject
import io.vertx.core.json.JsonArray

class PipeMessage {
	public static final String TOKEN = "token"
	
	public static final String ID = "id"
	public static final String CMD = "cmd"
	public static final String FROM = "from"
	public static final String SERVICE = "service"
	public static final String TO = "to"
	
	public static final String ENTITY = "entity"
	public static final String ARGS = "args"
	
	public static final String CMD_OK = "ok"
	public static final String CMD_ERROR = "error"
	
	public static final String BODY = "body"
	
	val JsonObject msg
	
	new() { this(new JsonObject) }
	new(String json) { this(new JsonObject(json)) }
	new(JsonObject msg) { this.msg = msg }
	
	def getJson() { return msg }
	
	def getToken() { return msg.getString(TOKEN) }
	
	def getId() { return msg.getLong(ID, 0L) }
	def void setId(long id) { msg.put(ID, id) }
	
	def getCmd() { return msg.getString(CMD) }
	def void setCmd(String type) { msg.put(CMD, type) }
	
	def getFrom() { return msg.getString(FROM) }
	def void setFrom(String from) { msg.put(FROM, from) }
	
	def getService() { return msg.getString(SERVICE) }
	def void setService(String service) { msg.put(SERVICE, service) }
	
	def getTo() { return msg.getString(TO) }
	def void setTo(String to) { msg.put(TO, to) }
	
	def getEntity() { return msg.getString(ENTITY) }
	def void setEntity(String entity) { msg.put(ENTITY, entity) }
	
	def getArgs() { return msg.getJsonArray(ARGS) }
	def void setArgs(JsonArray args) { msg.put(ARGS, args) }
	
	//body--------------------------------------------------
	def hasBody() { return msg.containsKey(rt.syncher.server.pipeline.PipeMessage.BODY) }
	def getBody() { return msg.getJsonObject(rt.syncher.server.pipeline.PipeMessage.BODY) }
	def void setBody(String body) { msg.put(rt.syncher.server.pipeline.PipeMessage.BODY, body) }
	
	override toString() { return msg.toString }
}