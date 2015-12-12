package rt.syncher.server

import io.vertx.spi.cluster.hazelcast.HazelcastClusterManager
import io.vertx.core.VertxOptions
import io.vertx.core.spi.cluster.ClusterManager
import io.vertx.core.AbstractVerticle
import rt.syncher.server.pipeline.PipeRegistry
import rt.syncher.server.pipeline.Pipeline
import io.vertx.core.http.HttpServerOptions

import static io.vertx.core.Vertx.*
import rt.syncher.server.handler.ValidatorHandler
import rt.syncher.server.comp.SessionManager
import rt.syncher.server.comp.CommandManager

class RtsStarter extends AbstractVerticle {
	def static void main(String[] args) {
		var name = args.get(0)
		var port = 9090
		
		if(args.length > 1) {
			port = Integer.parseInt(args.get(1))
		}
		
		val mgr = new HazelcastClusterManager
		val node = new RtsStarter(mgr, name, port)
		
		val options = new VertxOptions => [
			clusterManager = mgr
		]
		
		factory.clusteredVertx(options)[
			if (succeeded) {
				result.deployVerticle(node)
			} else {
				System.exit(-1)
			}
		]
	}
	
	val ClusterManager mgr
	val String name
	val int port
	
	new(ClusterManager mgr, String name, int port) {
		this.mgr = mgr
		this.name = name
		this.port = port
	}

	override def start() {
		val registry = new PipeRegistry(vertx, mgr, name) => [
			addComponent(new SessionManager)
			addComponent(new CommandManager)
		]

		val pipeline = new Pipeline(registry) => [
			addHandler(new ValidatorHandler)
			failHandler = [println("PIPELINE-FAIL: " + it)]
		]

		val httpOptions = new HttpServerOptions => [
			tcpKeepAlive = true
		]
		
		val server = vertx.createHttpServer(httpOptions)
		WebSocketServer.init(server, pipeline)
		server.listen(port)
		println('''Node («name», «port»)''')
	}
}