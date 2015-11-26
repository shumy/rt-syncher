package rt.syncher.server.pipeline

import io.vertx.core.Vertx
import io.vertx.core.buffer.Buffer
import io.vertx.core.eventbus.EventBus
import io.vertx.core.eventbus.MessageCodec
import io.vertx.core.eventbus.MessageConsumer
import io.vertx.core.spi.cluster.ClusterManager

import java.util.HashMap
import java.util.Map
import rt.syncher.server.IComponent
import org.eclipse.xtend.lib.annotations.Accessors

class PipeRegistry {
	@Accessors(PUBLIC_GETTER) val String domain
	@Accessors(PUBLIC_GETTER) val EventBus eb
	
	val ClusterManager mgr
	
	val services = new HashMap<String, IComponent> 						//<service, IComponent>
	val consumers = new HashMap<String, MessageConsumer<Object>>		//<address, MessageConsumer>
	
	val Map<String, String> serviceSpace								//<service, user>
	
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
				return null //not needed in this architecture
			}
		})
		
		this.serviceSpace = mgr.getSyncMap("serviceSpace")
	}
	
	def installService(IComponent service) {
		services.put(service.name, service)
		return this
	}
	
	def getService(String address) {
		return services.get(address)
	}
	
	def void bind(String address, String resourceUID) {
		val consumer = eb.consumer(address)[
			eb.send(resourceUID, body)
		]

		consumers.put(address, consumer)
	}
	
	def void unbind(String address) {
		val consumer = consumers.remove(address)
		if(consumer != null) {
			consumer.unregister
		}
	}
	
	def resolve(String url) {
		return ""
	}
}