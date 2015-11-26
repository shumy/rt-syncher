package rt.syncher.server.pipeline

import io.vertx.core.Vertx
import io.vertx.core.buffer.Buffer
import io.vertx.core.eventbus.EventBus
import io.vertx.core.eventbus.MessageCodec
import io.vertx.core.spi.cluster.ClusterManager

import java.util.HashMap
import rt.syncher.server.IComponent
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.UUID
import java.util.Map

class PipeRegistry {
	@Accessors(PUBLIC_GETTER) val String domain
	@Accessors(PUBLIC_GETTER) val EventBus eb

	val ClusterManager mgr
	
	val Map<String, PipeSession> sessions 								//<token, PipeSession>
	val services = new HashMap<String, IComponent> 						//<service, IComponent>
	
	new(Vertx vertx, ClusterManager mgr, String domain) {
		this.domain = domain
		this.mgr = mgr
		
		this.eb = vertx.eventBus
		this.eb.registerDefaultCodec(PipeContext, new MessageCodec<PipeContext, PipeContext>() {

			override def systemCodecID() {
				val int negative = -1
				return negative as byte
			}
			
			override def name() { return PipeContext.name }
			
			override def transform(PipeContext ctx) { return ctx }
			
			override def encodeToWire(Buffer buffer, PipeContext ctx) {
				println("encodeToWire")
				buffer.appendString(ctx.message.toString)
			}

			override def decodeFromWire(int pos, Buffer buffer) {
				println("decodeFromWire")
				return null //not needed in this architecture
			}
		})
		
		this.sessions = mgr.getSyncMap("sessions")
	}

	def getService(String service) {
		return services.get(service)
	}
		
	def addService(IComponent service) {
		services.put(service.name, service)
		return this
	}
	
	def createSession(String user, String service, String resourceUID) {
		val token = UUID.randomUUID.toString

		val session = new PipeSession(token, user, service, resourceUID)
		sessions.put(token, session)

		return session
	}
	
	def void deleteSession(PipeSession session) {
		if (session != null && sessions.containsKey(session.token)) {
			sessions.remove(session.token)
		}
	}
	
	def resolve(String token) {
		return sessions.get(token)
	}
	
	def void send(String token, PipeMessage msg) {
		val session = resolve(token)
		eb.send(session.resourceUid, msg.toString)
	}
}