package de.thm.icampus.joomdd.ejsl.generator.ps.JoomlaPageGenerator

import de.thm.icampus.joomdd.ejsl.eJSL.Attribute
import de.thm.icampus.joomdd.ejsl.eJSL.Component
import de.thm.icampus.joomdd.ejsl.eJSL.DetailsPage
import de.thm.icampus.joomdd.ejsl.eJSL.Entity
import de.thm.icampus.joomdd.ejsl.eJSL.IndexPage
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedExtension.ExtendedComponent
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedPage.ExtendedDynamicPage
import de.thm.icampus.joomdd.ejsl.generator.ps.JoomlaUtil.Slug
import org.eclipse.emf.common.util.EList
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedAttribute

class IndexPageTemplateAdminHelper {
	
	 ExtendedDynamicPage indexpage
	private ExtendedComponent  com
	private String sec
	private DetailsPage details
	
	new(ExtendedDynamicPage dp, ExtendedComponent cp, String section){
		
		indexpage = dp
		com = cp
		sec = section
		details = Slug.getPageForDetails(indexpage,com)
		
	}
	
	def CharSequence genAdminControllerContructer()'''
	 /**
	 * Constructor.
	 *
	 * @param   array  $config	An optional associative array of configuration settings.
	 * @return  «com.name.toFirstUpper»Controller«indexpage.name.toFirstUpper»
	 * @see     JController
	 * @since   1.6
	 * @generated
	 */
	    public function __construct($config = array())
	    {
	        parent::__construct($config);
	 
	    }
	 
	'''
	public def genAdminControllerGetModel()'''
	/**
	 * Overwrite the  getModel.
	 * @since	1.6
	 */
	public function getModel($name = '«details.name.toFirstUpper»', $prefix = '«com.name.toFirstUpper»Model', $config = array())
	{
		$model = parent::getModel($name, $prefix, array('ignore_request' => true));
		return $model;
	}
	'''
	
	def CharSequence genAdminControllerSaveOrdering()'''
	/**
	* save the order.
	*
	* @return  Integer
	* @generated
	*/
	    public function saveordering(){
	        $app = JFactory::getApplication();
	        $ids = $app->input->get('cid', array(), 'array');
	        $model = $this->getModel('«indexpage.name.toLowerCase»');
	        $result = $model->saveOrdering($ids);
	        if($result)
	        {
	        echo new JResponseJson($result);
	        }
	    }
	'''
	def CharSequence genAdminModelConstruct()'''
	/**
	* Constructor.
	*
	* @param    array    An optional associative array of configuration settings.
	* @see        JController
	* @since    1.6
	* @generated
	*/
	    public function __construct($config = array()) {
	        if (empty($config['filter_fields'])) {
	            $config['filter_fields'] = array(
	                                'id', 'a.id',
	                'ordering', 'a.ordering',
	                'state', 'a.state',
	                'created_by', 'a.created_by'
	                , 'published', 'a.published'
	                «FOR ExtendedAttribute attr: indexpage.allAttributeOfFilterAndColum»
	                ,'«attr.name.toLowerCase»', 'a.«attr.name.toLowerCase»'
	                «ENDFOR»
	                );}
	                parent::__construct($config);
	}
	'''
	
	def CharSequence genAdminModelGetListQuery(EList<Attribute>filters)'''
	/**
	 * Build an SQL query to load the list data.
	 *
	 * @return	JDatabaseQuery
	 * @since	1.6
	 * @generated
	 */
	    protected function getListQuery() {
	        // Create a new query object.
	        $db = $this->getDbo();
	        $query = $db->getQuery(true);
	
	        // Select the required fields from the table.
	        $query->select(
	                $this->getState(
	                        'list.select', 'a.*'
	                )
	        );
	        $query->from('`#__«com.name.toLowerCase»_«indexpage.entities.get(0).name.toLowerCase»` AS a');
	        // Join over the users for the checked out user
		$query->select("uc.name AS editor");
		$query->join("LEFT", "#__users AS uc ON uc.id=a.checked_out");
		// Join over the user field 'created_by'
		$query->select('created_by.name AS created_by');
		$query->join('LEFT', '#__users AS created_by ON created_by.id = a.created_by');
		// Join over the user field 'user'
		$query->select('user.name AS user');
		$query->join('LEFT', '#__users AS user ON user.id =  a.created_by');

	

		// Filter by published state
		$published = $this->getState('filter.state');
		if (is_numeric($published)) {
			$query->where('a.state = ' . (int) $published);
		} else if ($published === '') {
			$query->where('(a.state IN (0, 1))');
		}
		// Filter by User 
		$created_by = $this->getState('filter.created_by');
		if (!empty($created_by)) {
            $query->where("a.created_by = '$created_by'");
            }
        «FOR ExtendedAttribute attr : indexpage.extendFiltersList»
        // Filter by «attr.name» 
		$«attr.name» = $this->getState('filter.«attr.name»');
		if (!empty($«attr.name»)) {
            $query->where("a.«attr.name» = '$«attr.name»'");
            }
        «ENDFOR»
		
		// Filter by search in attribute
        $search = $this->getState('filter.search');
        if (!empty($search)) {
            if (stripos($search, 'id:') === 0) {
                $query->where('a.id = ' . (int) substr($search, 3));
            } else {
                $search = $db->Quote('%' . $db->escape($search, true) . '%');
                «IF !filters.empty»
                $query->where('( a.«filters.get(0).name.toLowerCase» LIKE '.$search. 
                «FOR Attribute attr : indexpage.filters»
                «IF filters.indexOf(attr) > 0»
                 'OR  a.«attr.name.toLowerCase» LIKE '.$search.
                 «ENDIF»
                 «ENDFOR»
                 
                 ')');   
                 «ENDIF»
            }}
	        // Add the list ordering clause.
	        $orderCol = $this->state->get('list.ordering');
	        $orderDirn = $this->state->get('list.direction');
	        if ($orderCol && $orderDirn) {
	            $query->order($db->escape($orderCol . ' ' . $orderDirn));
	        }
	
	        return $query;
	    }
	            
	'''
	def CharSequence genAdminModelGetItem()'''
	/**
	 * Method to get a single record.
	 *
	 * @param	integer	The id of the primary key.
	 *
	 * @return	mixed	Object on success, false on failure.
	 * @since	1.6
	 * @generated
	 */
		 public function getItems() {
	        $items = parent::getItems();
	        
	        return $items;
	    }
	'''
	def CharSequence genAdminModelSaveOrder()'''
	/**
	* Function to save the new Order of the Profile
	*
	* @param   Array  $datas_ID  content the ID in the new Ordering
	*
	* @return array including headers
	* @generated
	*/
	    public function saveOrdering($datas_ID)
	    {
	        $db = JFactory::getDbo();
	        $query = $db->getQuery(true);
	
	        $statement = 'Update #__«com.name.toLowerCase»_«indexpage.entities.get(0).name.toLowerCase» Set `ordering` = CASE';
	        foreach ($datas_ID  as $order => $profileID)
	        {
	            $statement .= ' WHEN id = ' . intval($profileID) . ' THEN ' . (intval($order) + 1);
	        }
	        $statement .= ' ELSE ' . 0 . ' END Where id IN(' . implode(',', $datas_ID) . ')';
	        $db->setQuery($statement);
	        $response = $db->execute();
	
	        if ($response)
	        {
	            $query = $db->getQuery(true);
	            $query->select('`id`, `ordering`')->from('#__«com.name.toLowerCase»_«indexpage.entities.get(0).name.toLowerCase»');
	            $db->setQuery($query);
	            return $db->loadObjectList();
	        }
	        return false;
	    }
	'''
	def CharSequence genAdminViewDisplay()'''
	/**
	* loads model data into view context
	*
	* @param   string  $tpl  the name of the template to be used
	*
	* @return void
	* @generated
	*/
	    public function display($tpl = null) {
	        $this->state = $this->get('State');
	        $this->items = $this->get('Items');
	        $this->pagination = $this->get('Pagination');
	        $this->filterForm    = $this->get('FilterForm');
	
	        // Check for errors.
	        if (count($errors = $this->get('Errors'))) {
	            throw new Exception(implode("\n", $errors));
	        }
	
	        «com.name.toFirstUpper»Helper::addSubmenu('«indexpage.name.toLowerCase»');
	
	        $this->addToolbar();
	
	        $this->sidebar = JHtmlSidebar::render();
	        parent::display($tpl);
	    }
	'''
	def CharSequence genAdminViewAddtoolbar()'''
		 /**
		 * Add the page title and toolbar.
		 *
		 * @since	1.6
		 * @generated
		 */
		    protected function addToolbar() {
		        require_once JPATH_COMPONENT . '/helpers/«com.name.toLowerCase».php';
		 
		        $state = $this->get('State');
		        $canDo = «com.name.toFirstUpper»Helper::getActions($state->get('filter.category_id'));
		 
		        JToolBarHelper::title(JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_TITLE_«indexpage.name.toUpperCase»'));
		 
		        //Check if the form exists before showing the add/edit buttons
		        $formPath = JPATH_COMPONENT_ADMINISTRATOR . '/views/«details.name.toLowerCase»';
		        if (file_exists($formPath)) {
		 
		            if ($canDo->get('core.create')) {
		                JToolBarHelper::addNew('«details.name.toLowerCase».add', 'JTOOLBAR_NEW');
		            }
		 
		            if ($canDo->get('core.edit') && isset($this->items[0])) {
		                JToolBarHelper::editList('«details.name.toLowerCase».edit', 'JTOOLBAR_EDIT');
		            }
		        }
		 
		        if ($canDo->get('core.edit.state')) {
		 
		            if (isset($this->items[0]->state)) {
		                JToolBarHelper::divider();
		                JToolBarHelper::custom('«indexpage.name.toLowerCase».publish', 'publish.png', 'publish_f2.png', 'JTOOLBAR_PUBLISH', true);
		                JToolBarHelper::custom('«indexpage.name.toLowerCase».unpublish', 'unpublish.png', 'unpublish_f2.png', 'JTOOLBAR_UNPUBLISH', true);
		            } else if (isset($this->items[0])) {
		                //If this component does not use state then show a direct delete button as we can not trash
		                JToolBarHelper::deleteList('', '«indexpage.name.toLowerCase».delete', 'JTOOLBAR_DELETE');
		            }
		 
		            if (isset($this->items[0]->state)) {
		                JToolBarHelper::divider();
		                JToolBarHelper::archiveList('«indexpage.name.toLowerCase».archive', 'JTOOLBAR_ARCHIVE');
		            }
		            if (isset($this->items[0]->checked_out)) {
		                JToolBarHelper::custom('«indexpage.name.toLowerCase».checkin', 'checkin.png', 'checkin_f2.png', 'JTOOLBAR_CHECKIN', true);
		            }
		        }
		
		        //Show trash and delete for components that uses the state field
		        if (isset($this->items[0]->state)) {
		            if ($state->get('filter.state') == -2 && $canDo->get('core.delete')) {
		                JToolBarHelper::deleteList('', '«indexpage.name.toLowerCase».delete', 'JTOOLBAR_EMPTY_TRASH');
		                JToolBarHelper::divider();
		            } else if ($canDo->get('core.edit.state')) {
		                JToolBarHelper::trash('«indexpage.name.toLowerCase».trash', 'JTOOLBAR_TRASH');
		                JToolBarHelper::divider();
		            }
		        }
		 
		        if ($canDo->get('core.admin')) {
		            JToolBarHelper::preferences('«Slug.nameExtensionBind("com",com.name).toLowerCase»');
		        }
		 
		        JHtmlSidebar::setAction('index.php?option=«Slug.nameExtensionBind("com",com.name).toLowerCase»&view=«indexpage.name.toLowerCase»');
		 
		}
		 
	'''
	def CharSequence genAdminViewSortFields()'''
	protected function getSortFields()
	{
		return array(
		'a.id' => JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_FORM_LBL_NONE_ID'),
		'a.ordering' => JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_FORM_LBL_NONE_ORDERING'),
		'a.state' => JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_FORM_LBL_NONE_STATE')
        «FOR ExtendedAttribute attr : indexpage.allAttributeOfFilterAndColum»
		  , 'a.«attr.name.toLowerCase»' => JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_FORM_LBL_«(attr.entity).name.toUpperCase»_«attr.name.toUpperCase»')
         «ENDFOR»
		
		);
	}
	'''
	def private CharSequence genAdminViewLayoutFilters()'''
	  <?php
	        echo JLayoutHelper::render('joomla.searchtools.default', array('view' => $this));
	        ?>
	<div id="filter-bar" class="btn-toolbar">
			<div class="btn-group pull-right hidden-phone">
				<label for="directionTable" class="element-invisible"><?php echo JText::_('JFIELD_ORDERING_DESC');?></label>
				<select name="directionTable" id="directionTable" class="input-medium" onchange="Joomla.orderTable()">
					<option value=""><?php echo JText::_('JFIELD_ORDERING_DESC');?></option>
					<option value="asc" <?php if ($listDirn == 'asc') echo 'selected="selected"'; ?>><?php echo JText::_('JGLOBAL_ORDER_ASCENDING');?></option>
					<option value="desc" <?php if ($listDirn == 'desc') echo 'selected="selected"'; ?>><?php echo JText::_('JGLOBAL_ORDER_DESCENDING');?></option>
				</select>
			</div>
			<div class="btn-group pull-right">
				<label for="sortTable" class="element-invisible"><?php echo JText::_('JGLOBAL_SORT_BY');?></label>
				<select name="sortTable" id="sortTable" class="input-medium" onchange="Joomla.orderTable()">
					<option value=""><?php echo JText::_('JGLOBAL_SORT_BY');?></option>
					<?php echo JHtml::_('select.options', $sortFields, 'value', 'text', $listOrder);?>
				</select>
			</div>
		</div>        
	
	 '''
	 def private CharSequence genAdminViewLayoutData(EList<ExtendedAttribute>column)'''
 <table class="table table-striped" id="«indexpage.name.toFirstUpper»List">
		<thead>
			<tr>
            <?php if (isset($this->items[0]->ordering)): ?>
				<th width="1%" class="nowrap center hidden-phone">
					<?php echo JHtml::_('grid.sort', '<i class="icon-menu-2"></i>', 'a.ordering', $listDirn, $listOrder, null, 'asc', 'JGRID_HEADING_ORDERING'); ?>
				</th>
            <?php endif; ?>
				<th width="1%" class="hidden-phone">
					<input type="checkbox" name="checkall-toggle" value="" title="<?php echo JText::_('JGLOBAL_CHECK_ALL'); ?>" onclick="Joomla.checkAll(this)" />
				</th>
            <?php if (isset($this->items[0]->state)): ?>
				<th width="1%" class="nowrap center">
					<?php echo JHtml::_('grid.sort', 'JSTATUS', 'a.state', $listDirn, $listOrder); ?>
				</th>
            <?php endif; ?>
       «FOR ExtendedAttribute attr : column»
	<th class='left'>
	<?php echo JHtml::_('grid.sort',  '«Slug.nameExtensionBind("com", com.name).toUpperCase»_FORM_LBL_« (attr.entity).name.toUpperCase»_«attr.name.toUpperCase»', 'a.«attr.name.toLowerCase»', $listDirn, $listOrder); ?>
	</th>
     «ENDFOR»
     
    <?php if (isset($this->items[0]->id)): ?>
		<th width="1%" class="nowrap center hidden-phone">
			<?php echo JHtml::_('grid.sort', 'JGRID_HEADING_ID', 'a.id', $listDirn, $listOrder); ?>
		</th>
    <?php endif; ?>
	</tr>
</thead>
<tfoot>
    <?php 
    if(isset($this->items[0])){
        $colspan = count(get_object_vars($this->items[0]));
    }
    else{
        $colspan = 10;
    }
?>
<tr>
	<td colspan="<?php echo $colspan ?>">
		<?php echo $this->pagination->getListFooter(); ?>
	</td>
</tr>
</tfoot>
<tbody>
<?php foreach ($this->items as $i => $item) :
	$ordering   = ($listOrder == 'a.ordering');
    $canCreate	= $user->authorise('core.create',		'«Slug.nameExtensionBind("com", com.name).toLowerCase»');
    $canEdit	= $user->authorise('core.edit',			'«Slug.nameExtensionBind("com", com.name).toLowerCase»');
    $canCheckin	= $user->authorise('core.manage',		'«Slug.nameExtensionBind("com", com.name).toLowerCase»');
    $canChange	= $user->authorise('core.edit.state',	'«Slug.nameExtensionBind("com", com.name).toLowerCase»');
	?>
	<tr class="row<?php echo $i % 2; ?>">
        
    <?php if (isset($this->items[0]->ordering)): ?>
		<td class="order nowrap center hidden-phone">
		<?php if ($canChange) :
			$disableClassName = '';
			$disabledLabel	  = '';
			if (!$saveOrder) :
				$disabledLabel    = JText::_('JORDERINGDISABLED');
				$disableClassName = 'inactive tip-top';
			endif; ?>
			<span class="sortable-handler hasTooltip <?php echo $disableClassName?>" title="<?php echo $disabledLabel?>">
				<i class="icon-menu"></i>
			</span>
			<input type="text" style="display:none" name="order[]" size="5" value="<?php echo $item->ordering;?>" class="width-20 text-area-order " />
		<?php else : ?>
			<span class="sortable-handler inactive" >
				<i class="icon-menu"></i>
			</span>
		<?php endif; ?>
		</td>
    <?php endif; ?>
		<td class="center hidden-phone">
			<?php echo JHtml::_('grid.id', $i, $item->id); ?>
		</td>
    <?php if (isset($this->items[0]->state)): ?>
		<td class="center">
			<?php echo JHtml::_('jgrid.published', $item->state, $i, '«indexpage.name.toLowerCase».', $canChange, 'cb'); ?>
		</td>
    <?php endif; ?>
		«genAdminModelAttributeReference(column, indexpage, com)»
        <?php if (isset($this->items[0]->id)): ?>
			<td class="center hidden-phone">
				<?php echo (int) $item->id; ?>
			</td>
        <?php endif; ?>
		</tr>
		<?php endforeach; ?>
	</tbody>
</table>
'''
def  CharSequence genAdminViewLayoutForm()''' 
<form action="<?php echo JRoute::_('index.php?option=«Slug.nameExtensionBind("com", com.name).toLowerCase»&view=«indexpage.name.toLowerCase»'); ?>" method="post" name="adminForm" id="adminForm">
<?php if(!empty($this->sidebar)): ?>
	<div id="j-sidebar-container" class="span2">
		<?php echo $this->sidebar; ?>
	</div>
	<div id="j-main-container" class="span10">
<?php else : ?>
	<div id="j-main-container">
<?php endif;?>
«genAdminViewLayoutFilters»
«genAdminViewLayoutData(indexpage.extendedTableColumnList)»
<input type="hidden" name="task" value="" />
		<input type="hidden" name="boxchecked" value="0" />
		<input type="hidden" name="filter_order" value="<?php echo $listOrder; ?>" />
		<input type="hidden" name="filter_order_Dir" value="<?php echo $listDirn; ?>" />
		<?php echo JHtml::_('form.token'); ?>
	</div>
</form>  

'''

def CharSequence genAdminViewLayoutHeader()'''
$user	= JFactory::getUser();
$userId	= $user->get('id');
$listOrder	= $this->state->get('list.ordering');
$listDirn	= $this->state->get('list.direction');
$canOrder	= $user->authorise('core.edit.state', '«Slug.nameExtensionBind("com", com.name).toLowerCase»');
$saveOrder	= $listOrder == 'a.ordering';
if ($saveOrder)
{
	$saveOrderingUrl = 'index.php?option=«Slug.nameExtensionBind("com", com.name).toLowerCase»&task=«indexpage.name.toLowerCase()».saveOrderAjax&tmpl=component';
	JHtml::_('sortablelist.sortable', '«indexpage.name.toFirstUpper»List', 'adminForm', strtolower($listDirn), $saveOrderingUrl);
}
$sortFields = $this->getSortFields();
?>
<script type="text/javascript">
	Joomla.orderTable = function() {
		table = document.getElementById("sortTable");
		direction = document.getElementById("directionTable");
		order = table.options[table.selectedIndex].value;
		if (order != '<?php echo $listOrder; ?>') {
			dirn = 'asc';
		} else {
			dirn = direction.options[direction.selectedIndex].value;
		}
		Joomla.tableOrdering(order, dirn, '');
	}
</script>
 '''
 
 public def CharSequence genAdminModelPopulateState()'''
  /**
     * Method to auto-populate the model state.
     *
     * Note. Calling getState in this method will result in recursion.
     */
    protected function populateState($ordering = null, $direction = null) {
        // Initialise variables.
        $app = JFactory::getApplication('administrator');

        // Load the filter state.
         $published = $app->getUserStateFromRequest($this->context . '.filter.state', 'filter_published');
        	      $this->setState('filter.published', $published);
        
  		$state = $app->getUserStateFromRequest($this->context . '.filter.state', 'filter_state');
                  $this->setState('filter.state', $state);
        $created_by = $app->getUserStateFromRequest($this->context . '.filter.created_by', 'filter_created_by');
                          $this->setState('filter.created_by', $created_by);
         «FOR ExtendedAttribute attr: indexpage.extendFiltersList»
         $«attr.name» = $app->getUserStateFromRequest($this->context . '.filter.«attr.name»', 'filter_«attr.name»');
                      $this->setState('filter.«attr.name»', $«attr.name»);
         «ENDFOR»
        // Load the parameters.
        $params = JComponentHelper::getParams('«Slug.nameExtensionBind("com", com.name.toLowerCase)»');
        $this->setState('params', $params);

        // List state information.
        parent::populateState('a.id', 'asc');
    }
 '''
 

 public def CharSequence genGetIdOfReferenceItem ()'''
  /**
     * Method to get the id of Reference
     * @param String  $linkName   containt the name of a Attribute
     * @param String  $attrvaluen  containt the value of a Row
     *
     * @return the ID of a Row
     *
     */
   public function getIdOfReferenceItem($linkName, $attrvalue){
      $dbtable = $this->entitiesRef["$linkName"]["db"];
      $attribute = $this->entitiesRef["$linkName"]["refattr"];
      $db = JFactory::getDbo();
      $query = $db->getQuery(true);
      $query->select("id")
          ->from($dbtable);
       foreach ($attribute as $index=>$attributItem){ 
          $query->where($attributItem . " like '$attrvalue[$index]'");
       }
      $db->setQuery($query);
      $result = $db->loadObject();
  
      return intval($result->id);
    }
  '''
  public  def CharSequence genAdminModelAttributeReference(EList<ExtendedAttribute>column, ExtendedDynamicPage indexpage, ExtendedComponent com )'''
 	« FOR ExtendedAttribute attr : column»
	«IF Slug.isAttributeLinked(attr, indexpage)»
	<?php if ($canEdit) : ?>
	<td>
		<a href="<?php echo JRoute::_(«Slug.linkOfAttribut(attr, indexpage,  com.name, "$item->")»); ?>">
			<?php echo $this->escape($item->«attr.name.toLowerCase»); ?></a>
		<?php else : ?>
			<?php echo $this->escape($item->«attr.name.toLowerCase»); ?>
		<?php endif; ?>
		</td>
	«ELSE»
		<td>
		<?php echo $item->«attr.name.toLowerCase»; ?>
		</td>
	«ENDIF»
	«ENDFOR»
 '''
}

		