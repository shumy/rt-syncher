package rt.syncher

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import rt.syncher.data.DEntity
import rt.syncher.ctx.Context
import rt.syncher.data.schema.Schema
import rt.syncher.data.schema.SField
import java.util.ArrayList
import org.eclipse.xtend.lib.macro.declaration.Visibility

@Target(TYPE)
@Active(EntityProcessor)
annotation Entity {
	String value
}

class EntityProcessor extends AbstractClassProcessor {
	
	override doTransform(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val anno = clazz.findAnnotation(Entity.findTypeGlobally)
		val name = anno.getStringValue("value")
		
		setupSchema(clazz, ctx)
		
		clazz.extendedClass = ctx.newTypeReference(DEntity)
		clazz.addConstructor[
			//addParameter("id", ctx.newTypeReference(long))
			body = '''
				if (schema == null) setup();
				
				table = «Context».getService().getOrCreateTable("«name»", schema);
				table.createEntity(this);
			'''
		]
		
		clazz.addMethod("delete")[
			body = '''
				table.deleteEntity(this);
			'''
		]
	}
	
	def void setupSchema(MutableClassDeclaration clazz, extension TransformationContext ctx) {
		val fieldAnno = Field.findTypeGlobally //@Field
		
		//annotated with @Field
		val fields = clazz.declaredFields.map[
			val anno = findAnnotation(fieldAnno)
			if (anno != null) {
				return '''fields.add(new SField("«simpleName»", "«type»"));'''
			}
		].filterNull
		
		//TODO: add all schema fields...
		clazz.addMethod("setup")[
			visibility = Visibility.PRIVATE
			body = '''
				final ArrayList<«SField»> fields = new «ArrayList»(«fields.size»); 
				«FOR field: fields»
					«field»
				«ENDFOR»
				
				schema = new «Schema»(fields);
			'''
		]
	}
}