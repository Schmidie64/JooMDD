package de.thm.icampus.joomdd.ejsl.generator.ps

import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.emf.common.util.EList
import de.thm.icampus.joomdd.ejsl.eJSL.Extension
import de.thm.icampus.joomdd.ejsl.generator.ps.JoomlaExtensionGenerator.ExtensionGeneratorClient

class ExtensionGenerator extends AbstracteGenerator{
	
	EList<Extension> extensions
	String path
	IFileSystemAccess fileGen
	
	new(EList<Extension> list, String pathToGenerate,  IFileSystemAccess fsa) {
		extensions= list
		fileGen = fsa
		path = pathToGenerate
		
	}
	
	override dogenerate() {

	for(ext: extensions){
			
		var ExtensionGeneratorClient extClient = new ExtensionGeneratorClient(fileGen,ext)
		extClient.generateExtension
		}
	}
	
	
	
}