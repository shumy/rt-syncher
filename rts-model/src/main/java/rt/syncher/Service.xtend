package rt.syncher

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import rt.syncher.data.DService

@Target(TYPE)
@Active(ServiceProcessor)
annotation Service {	
}

class ServiceProcessor extends AbstractClassProcessor {
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		clazz.extendedClass = ctx.newTypeReference(DService)
		
		clazz.addConstructor[
			addParameter("name", ctx.newTypeReference(String))
			body = '''
				super(name);
			'''
		]
	}
}