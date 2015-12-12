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
import rt.syncher.ctx.Session
import rt.syncher.data.DService

class PipeRegistry {
	@Accessors val String domain
	@Accessors val EventBus eb

	val ClusterManager mgr
	
	val Map<String, Session> sessions 								//<token, PipeSession>
	val components = new HashMap<String, IComponent> 				//<name, IComponent>
	val services = new HashMap<String, DService>					//<name, Dservice>
	
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

	def getComponent(String component) {
		return components.get(component)
	}
		
	def addComponent(IComponent component) {
		components.put(component.name, component)
		return this
	}
	
	def getService(String name) {
		return services.get(name)
	}
	
	def void createService(DService service) {
		services.put(service.name, service)
	}
	
	def void deleteService(String name) {
		services.remove(name)
	}
	
	def createSession(String user, String service, String resourceUID) {
		val token = UUID.randomUUID.toString

		val session = new Session(token, user, service, resourceUID)
		sessions.put(token, session)

		return session
	}
	
	def void deleteSession(Session session) {
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