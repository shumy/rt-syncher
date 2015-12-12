package rt.syncher.ctx

import org.eclipse.xtend.lib.annotations.Accessors
import java.io.Serializable

class Session implements Serializable {
	@Accessors val String token
	@Accessors val String user
	@Accessors val String service
	@Accessors val String resourceUid
	
	new(String token, String user, String service, String resourceUid) {
		this.token = token
		this.user = user
		this.service = service
		this.resourceUid = resourceUid
	}
}