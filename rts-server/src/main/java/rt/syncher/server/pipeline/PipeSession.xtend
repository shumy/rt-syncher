package rt.syncher.server.pipeline

import org.eclipse.xtend.lib.annotations.Accessors
import java.io.Serializable

class PipeSession implements Serializable {
	@Accessors(PUBLIC_GETTER) val String token
	@Accessors(PUBLIC_GETTER) val String user
	@Accessors(PUBLIC_GETTER) val String service
	@Accessors(PUBLIC_GETTER) val String resourceUid
	
	new(String token, String user, String service, String resourceUid) {
		this.token = token
		this.user = user
		this.service = service
		this.resourceUid = resourceUid
	}
}