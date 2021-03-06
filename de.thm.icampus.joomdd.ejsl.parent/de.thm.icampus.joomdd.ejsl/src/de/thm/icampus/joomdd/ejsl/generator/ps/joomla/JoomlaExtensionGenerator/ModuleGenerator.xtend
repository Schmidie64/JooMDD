package de.thm.icampus.joomdd.ejsl.generator.ps.joomla.JoomlaExtensionGenerator

import de.thm.icampus.joomdd.ejsl.eJSL.DynamicPage
import de.thm.icampus.joomdd.ejsl.eJSL.Link
import de.thm.icampus.joomdd.ejsl.eJSL.Module
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedAttribute
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedExtension.ExtendedModule
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedPage.ExtendedDynamicPage
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla.JoomlaExtensionGenerator.AbstractExtensionGenerator
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla.JoomlaUtil.LanguageGenerator
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla.JoomlaUtil.Slug
import java.util.Calendar
import org.eclipse.emf.common.util.EList
import org.eclipse.xtext.generator.IFileSystemAccess2
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla.PageGeneratorHandler
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedExtension.impl.ExtendedComponentImpl
import de.thm.icampus.joomdd.ejsl.eJSL.DataAccessKinds
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedEntity
import de.thm.icampus.joomdd.ejsl.eJSL.Attribute
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedReference
import org.apache.log4j.Logger
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla.JoomlaUtil.StaticLanguage
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedExtension.ExtendedComponent
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla.JoomlaUtil.DatabaseQuery.Query
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla.JoomlaUtil.DatabaseQuery.Select
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla.JoomlaUtil.DatabaseQuery.Column
import de.thm.icampus.joomdd.ejsl.generator.pi.util.MappingEntity

/**
 * This class contains the templates to generate the necessary folders and files for a Joomla module.
 *
 * @author Dieudonne Timma, Dennis Priefer
 */
public class ModuleGenerator extends AbstractExtensionGenerator {  
			 
	PageGeneratorHandler pageClient
	String modelOfComponent = '\'<modelOfComponent>\''
	String modelPath = '\'/components/com_<nameOfComponent>/models\''
	String modelOfComponent2 = null;
	
	ExtendedModule extMod
	ExtendedDynamicPage dynpage
	String com
	String helperClassName

	new(ExtendedModule module, IFileSystemAccess2 fsa, String path) {
		this.fsa = fsa
		this.name = 'mod_' + Slug.slugify(module.name)
		this.extMod = module
		dynpage = module.extendedPageReference.extendedPage.extendedDynamicPageInstance
		com = module.extendedComponentName
		this.ComponentInformation(module)
		this.extMod.formatName
		this.path = path
		this.helperClassName = '''Mod«module.name.toFirstUpper»Helper'''
	}
	
	def void formatName(Module module) {
		module.name = Slug.slugify(module.name)
	}

	public def PageGeneratorHandler getPageClient() {
		return this.pageClient
	}

	public def void setPageClient(PageGeneratorHandler value) {
		this.pageClient = value;
	}

	override generate() {
		generateFile(path + name.toLowerCase + ".xml", this.extMod.xmlContent)
		generateFile(path + name.toLowerCase + ".php", this.extMod.phpContent)
		generateFile(path + "helper.php", helperPHP(extMod, extMod.pageRef.page as DynamicPage))
		generateFile(path + "tmpl/default.php", defaultTemplate())
		
		var LanguageGenerator lang = new LanguageGenerator(fsa)
		lang.genModuleLanguage(extMod, path)
       
		return ''
	}
		
	def CharSequence xmlContent(ExtendedModule module) {
		'''
		<?xml version="1.0" encoding="utf-8"?>
		<extension type="module" version="3.8" client="site" method="upgrade">
		    <name>«module.name.toFirstUpper»</name>
		    <creationDate>
		        «if (module.manifest.creationdate !== null) {
		            module.manifest.creationdate
		        } else {
		            Calendar::instance.get(Calendar.YEAR)
		        }»
		    </creationDate>
		    <copyright>
		        «if (module.manifest.copyright !== null) {
		            module.manifest.copyright
		        } else {
		            "Generated with JooMDD by Institute for Information Sciences, THM, Germany"
		        }»
		    </copyright>
		    <license>
		        «if (module.manifest.license !== null) {
		            module.manifest.license
		        } else {
		            "GNU General Public License version 2 or later"
		        }»
		    </license>
		    «Slug.generateAuthors(module.manifest.authors)»
		    <version>
		        «if (module.manifest.version !== null) {
		            module.manifest.version
		        } else {
		            "1.0.0"
		        }»
		    </version>
		    <description>
		        «if (module.manifest.description !== null) {
		            module.manifest.description
		        } else {
		            "Place Description here"
		        }»
		    </description>
		    <!-- Listing of all files that should be installed for the module -->
		    <files>
		        <filename module="«name»">«name.toLowerCase».php</filename>
		        <filename>helper.php</filename>
		        <folder>
		            <filename>tmpl/default.php</filename>
		        </folder>
		        <folder>language</folder>
		    </files>
		    <dependency>

		    </dependency>
		    <!-- All language files shipped with the module -->
		    <languages>
		        «FOR lang : module.languages»
		        «IF lang.sys == false»
		        <language tag="«lang.name»">language/«lang.name»/«lang.name».«name.toLowerCase».ini</language>
		        «ELSE»
		        <language tag="«lang.name»">language/«lang.name»/«lang.name».«name.toLowerCase».sys.ini</language>
		        «ENDIF»
		        «ENDFOR»
		    </languages>
		    <!-- Optional parameters -->
		    <config>
		        <fields name="params">
		            <fieldset name="basic">
		                «IF dynpage !== null»
		                <field name="ordering" type="list"
		                    label="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.ORDERING_LABEL)»"
		                    description="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.ORDERING_DESC)»"
		                    class="inputbox"
		                    default="«dynpage.extendFiltersList.get(0).name.toLowerCase»">
		                    «FOR ExtendedAttribute attr: dynpage.extendFiltersList»
		                    <option value="«attr.name.toLowerCase»">«Slug.addLanguage(module.languages, newArrayList("mod", module.name, "FORM", "LBL", attr.name), attr.name)»</option>
		                    «ENDFOR»
		                </field>
		                «ENDIF»
		                <field name="direction" type="list"
		                    label="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.DIRECTION)»"
		                    description="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.DIRECTION_DESC)»"
		                    class="inputbox"
		                    size="1"
		                    default="ASC">
		                    <option value="ASC">«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.DIRECTION_ASC)»</option>
		                    <option value="DESC">«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.DIRECTION_DESCENDING)»</option>
		                </field>
		                <field
		                    name="start"
		                    type="int"
		                    default="0"
		                    label="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.START_LABEL)»"
		                    description="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.START_DESC)»" />
		                <field
		                    name="limit"
		                    type="int"
		                    default="10"
		                    label="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.LIMIT_LABEL)»"
		                    description="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.LIMIT_DESC)»" />
		                <field
		                    name="search"
		                    type="text"
		                    label="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.SEARCH_LABEL)»"
		                    description="«Slug.addLanguage(module.languages, newArrayList("mod", module.name), StaticLanguage.SEARCH_DESC)»" />
		                <field name="state" type="list"
		                    label="JSTATUS"
		                    description="JFIELD_PUBLISHED_DESC"
		                    class="inputbox"
		                    size="1"
		                    default="1">
		                    <option value="1">JPUBLISHED</option>
		                    <option value="0">JUNPUBLISHED</option>
		                    <option value="2">JARCHIVED</option>
		                    <option value="-2">JTRASHED</option>
		                </field>
		            </fieldset>
		            «IF com !== null && dynpage !==null»
		            <fieldset name="filter" label="JSEARCH_FILTER_LABEL">
		                <field
		                    name="created_by"
		                    addfieldpath="administrator/components/«Slug.nameExtensionBind("com", com).toLowerCase»/models/fields"
		                    type="«module.name.toLowerCase»user"
		                    label="JGLOBAL_FIELD_CREATED_BY_LABEL"
		                    description="JGLOBAL_FIELD_CREATED_BY_DESC"
		                    entity="«dynpage.extendedEntityList.get(0).name»">
		                    <option value="">JOPTION_SELECT_AUTHOR</option>
		                </field>
		                «Slug.generateFilterFields(dynpage, extMod.languages, extMod.component, '''mod_«extMod.name»''', true, true, true, false)»
		            </fieldset>
		        «ENDIF»
		        </fields>
		    </config>
		</extension>
		'''
	}

    // ToDo: Check if parameter is necessary. The module is already given as member of the class....
	def CharSequence phpContent(ExtendedModule module) {
		var section =  module.extendedPageReference.sect
		'''
			<?php
			«Slug.generateFileDoc(extMod)»
			
			«Slug.generateRestrictedAccess()»
			
			«Slug.generateUses(newArrayList("ModuleHelper"))»
			
			// Include the «extMod.name» functions only once
			require_once __DIR__ . '/helper.php';
			// Models, Functions should be implementated here
			// «helperClassName»::updateReset();
			$items = «helperClassName»::getList($params);
			«IF section === DataAccessKinds.BACKEND_DAO || section === DataAccessKinds.FRONTEND_DAO»
			$model = «helperClassName»::getModel();
			«ENDIF»
			$moduleclass_sfx = htmlspecialchars($params->get('moduleclass_sfx'));
			require ModuleHelper::getLayoutPath('«name.toLowerCase»', $params->get('layout', 'default'));
		'''
	}
	
	 def CharSequence defaultTemplate() {
	'''
		<?php
		«Slug.generateFileDoc(extMod)»
		
		«Slug.generateRestrictedAccess()»
		
		«Slug.generateUses(newArrayList("Uri", "Html", "Factory"))»
		
		// No direct access to this file
		defined('_JEXEC') or die;
		
		/**
		 * if component helper shall be used
		 *
		 * require_once JPATH_ROOT . '/components/com_<nameOfComponent>/helpers/<nameOfComponentHelper.php>';
		 * $baseurl = Uri::base();
		 */

		$db       = Factory::getDbo();
		$user     = Factory::getUser();
		$canEdit  = $user->authorise('core.edit', '«extMod.extendedComponentName»');
		?>

		<?php if (count($items) !== 1) : ?>
		<ul class="«extMod.name»<?php echo $moduleclass_sfx; ?>">
		    <?php foreach ($items as $item) : ?>
		    <li>
		        <div class="«extMod.pageRef.page.name»item">
		        <?php if (empty($item)) : ?>
		            <?php // itemlist is empty ;?>
		        «IF !(dynpage.entities.isEmpty)»
		        <?php else : ?>
                    «FOR ExtendedAttribute attr : dynpage.extendedTableColumnList»
                    «IF !attr.name.equalsIgnoreCase("params")»
                         «checkLinkOfAttributes(attr)»
                    «ENDIF»
                    «ENDFOR»
                «ENDIF»
		        <?php endif; ?>
		        </div>
		    </li>
		    <?php endforeach; ?>
		</ul>
		<?php else : 
		    $item = array_shift($items); ?>
		    <div class="«extMod.pageRef.page.name»item">
            «FOR ExtendedAttribute attr : dynpage.extendedTableColumnList»
            «IF !attr.name.equalsIgnoreCase("params")»
                «checkLinkOfAttributes(attr)»
            «ENDIF»
            «ENDFOR»
		    </div>
		<?php endif; ?>
		'''
	}
	
    def checkLinkOfAttributes(ExtendedAttribute attribute) {
        var String result = '''<?php echo $db->escape($item->«attribute.name.toString»); ?>'''
        
        if(extMod.pageRef.sect === null || extMod.pageRef.pagescr === null) {
            return result
        }
        
        result = '''
        «IF Slug.isAttributeLinked(attribute, this.dynpage)»
            «Slug.linkOfAttribut(attribute, this.dynpage, this.com, "$item->", "$db")»
        «ELSE»
            «IF attribute.entity instanceof MappingEntity»
            «var listVariableName = '''$«attribute.name.toFirstLower»List'''»
            <?php
                «listVariableName» = array();
                foreach ($item->«attribute.name» as $value) { ?>
                    <?php «listVariableName»[] = $db->escape($value); ?>
                <?php
                }
                echo implode(" ", «listVariableName»); ?>
            «ELSE»
                <?php echo $db->escape($item->«attribute.name»); ?>
            «ENDIF»
        «ENDIF»
        '''
        return result
    }
	
	def CharSequence helperPHP(Module modul, DynamicPage mpage) {
		'''
		<?php
		«Slug.generateFileDoc(extMod)»
		
		«Slug.generateRestrictedAccess()»
		
		«Slug.generateUses(newArrayList("ModelLegacy", "Factory"))»
		
		/**
		 * Helper for «extMod.name»
		 *
		 * @category
		 * @package
		 * @since
		 *
		 */
		class «helperClassName»
		{
		    «genGetList»
		}
		'''
	}
	
	def genGetModel()'''
	/**
	 * @param
	 *
	 * @return
	 *
	 * @since
	 **/
	public static function getModel()
	{
	    /**
	     * placeholder "<>" are to be replaced
	     */
	    BaseDatabaseModel::addIncludePath(JPATH_ROOT . «modelPath», «modelOfComponent»);

	    «IF (extMod.pageRef.pagescr !== null )»
	    $model = BaseDatabaseModel::getInstance('«extMod.pageRef.page.name»', «modelOfComponent2», array('ignore_request' => true));
	    «ELSE»
	    $model = BaseDatabaseModel::getInstance('<type>', <modelOfComponent>, array('ignore_request' => true));
	    «ENDIF»
	    return $model;
	}
	
	'''
	
    def ComponentInformation (ExtendedModule modul) {
        if( modul.pageRef.pagescr !== null) {
            var section =  modul.extendedPageReference.sect
            var String compName =  modul.extendedComponentName
            
            switch (section) {
            	case BACKEND_DAO: {
                	modelPath = "'/administrator/components/com_" + compName.toLowerCase + "/models'"
            	}
				case FRONTEND_DAO: {
                	modelPath = "'/components/com_" + compName.toLowerCase + "/models'"
				}
            }
            
            modelOfComponent = ("\"" + compName.toFirstUpper + "\"")
            modelOfComponent2 = ("\"" +compName.toFirstUpper + "Model\"")
        }
    }
	
	public def genGetList() {
        if( extMod.pageRef.pagescr !== null) {
            var section =  extMod.extendedPageReference.sect
            switch (section) {
            	case BACKEND_DAO: {
                	genModel
            	}
            	case DATABASE: {
            		genQuery
            	}
				case FRONTEND_DAO: {
                	genModel
				}
				case WEBSERVICE: {
					''''''
				}
            }
        }
		
	}
	
	def genQuery() {
		var extendedComponent = new ExtendedComponentImpl(extMod.pageRef.pagescr.ref)
		var extendedDynamicPage = extMod.extendedPageReference.extendedPage.extendedDynamicPageInstance
		var indexpage = extendedDynamicPage
		var ExtendedEntity mainEntity = extendedDynamicPage.extendedEntityList.get(0)

        var multiValueElementList = Slug.getMultiValueElements(this.dynpage)
        
		return '''
		/**
		 * @param
		 *
		 * @return
		 *
		 * @since
		 **/
		public static function getList($params_module = null)
		{
		    $db = Factory::getDbo();
		    $start = $params_module->get('start');
		    $limit = $params_module->get('limit');
		    
		    $query = «helperClassName»::getListQuery($params_module);
		    $db->setQuery($query, $start, $limit);
		    
		    $items = $db->loadObjectList();
		    «IF multiValueElementList.size > 0»
		    foreach ($items as $item) {
		        «multiValueElementList.join('''
		        
		        ''')»
		    }
            «ENDIF»

		    return $items;
		}
		
		«genAdminModelGetListQuery(indexpage, mainEntity, extendedComponent)»
		'''
	}
	
	def CharSequence genAdminModelGetListQuery(ExtendedDynamicPage indexpage, ExtendedEntity mainEntity, ExtendedComponent extendedComponent) {
    	var query = new Query(extendedComponent)
    	var selectColumn = new Column(indexpage.entities.get(0).name, '''*''')
    	query.addToMainSelect(new Select(selectColumn))
    	'''
	    /**
	     * Build an SQL query to load the list data.
	     *
	     * @return  JDatabaseQuery
	     * @since 1.6
	     * @generated
	     */
	    private static function getListQuery($params_module = null)
	    {
	        // Create a new query object.
	        $db = Factory::getDbo();
	        $query = $db->getQuery(true);
	        $published = $params_module->get('state');
	        $created_by = $params_module->get('created_by');
	        «FOR ExtendedAttribute attr : indexpage.extendFiltersList»
	        $«attr.name» = $params_module->get('«attr.name»');
	        «ENDFOR»
	        $search = $params_module->get('search');
	        $orderCol = $params_module->get('ordering');
	        $orderDirn = $params_module->get('direction');

	        // Select the required fields from the table.
	        $query->select("distinct «query.mainSelect»");
	        «query.getListQuery(indexpage, mainEntity, ",", true)»
	        
	        return $query;
	    }
        '''
    }
	
	def genModel() '''
	/**
	 * @param
	 *
	 * @return
	 *
	 * @since
	 **/
	public static function getList($params_module = null)
	{
	    $model = «helperClassName»::getModel();
	    $state = $params_module->get('state');
	    if (!empty($state)) {
	        $model->setState('filter.state', $state);
	    }

	    $search = $params_module->get('search');
	    if (!empty($search)) {
	        $model->setState('filter.search', $search);
	    }

	    $created_by = $params_module->get('created_by');
	    if (!empty($created_by)) {
	        $model->setState('filter.search', $created_by);
	    }

	    $ordering = $params_module->get('ordering');
	    if (!empty($ordering)) {
	        $model->setState('list.ordering', $ordering);
	    }

	    $direction = $params_module->get('direction');
	    if (!empty($direction)) {
	        $model->setState('list.direction', $direction);
	    }
	
	    $start = $params_module->get('start');
	    if (!empty($start)) {
	        $model->setState('list.start', $start);
	    }

	    $limit = $params_module->get('limit');
	    if (!empty($limit)) {
	        $model->setState('list.limit', $limit);
	    }

	    «IF dynpage !== null»
	    «FOR ExtendedAttribute attr: dynpage.extendFiltersList»
	    «IF !attr.name.equalsIgnoreCase("params")»
	    $«attr.name.toLowerCase» = $params_module->get('«attr.name.toLowerCase»');
	    if (!empty($«attr.name.toLowerCase» )) {
	        $model->setState('filter.«attr.name.toLowerCase»', $«attr.name.toLowerCase» );
	    }
	    «ENDIF»
	    «ENDFOR»
	    «ENDIF»
	    $items = $model->getItems();

	    return $items;
	}
	
	«genGetModel»
	'''
} 