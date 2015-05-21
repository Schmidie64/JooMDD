package de.thm.icampus.ejsl.generator

import de.thm.icampus.ejsl.eJSL.DetailsPage
import de.thm.icampus.ejsl.eJSL.Component
import de.thm.icampus.ejsl.eJSL.Section

class DetailsPageTemplateBackendHelper {
	private DetailsPage dpage
	private Component  com
	private String sec
	
	new(DetailsPage dp, Component cp, String section){
		
		dpage = dp
		com = cp
		sec = section
	}
		
	def CharSequence generateAdminModelprepareTableFunction() '''
	/**
	 * Prepare and sanitise the table prior to saving.
	 *
	 * @since	1.6
	 */
	protected function prepareTable($table)
	{
		jimport('joomla.filter.output');

		if (empty($table->id)) {

			// Set ordering to the last item if not set
			if (@$table->ordering === '') {
				$db = JFactory::getDbo();
				$db->setQuery('SELECT MAX(ordering) FROM #__«dpage.entities.get(0).name.toLowerCase»');
				$max = $db->loadResult();
				$table->ordering = $max+1;
			}

		}
	}
	'''
	
	def CharSequence generateAdminModelGetItemFunction() '''
	/**
	 * Method to get a single record.
	 *
	 * @param	integer	The id of the primary key.
	 *
	 * @return	mixed	Object on success, false on failure.
	 * @since	1.6
	 */
	public function getItem($pk = null)
	{
		if ($item = parent::getItem($pk)) {


		}

		return $item;
	}
	'''
	
	
	def generateAdminModelTableFunction()'''
	/**
	 * Returns a reference to the a Table object, always creating it.
	 *
	 * @param	type	The table type to instantiate
	 * @param	string	A prefix for the table class name. Optional.
	 * @param	array	Configuration array for model. Optional.
	 * @return	JTable	A database object
	 * @since	1.6
	 */
	public function getTable($type = '«dpage.name.toFirstUpper»', $prefix = '«com.name.toFirstUpper»Table', $config = array())
	{
		return JTable::getInstance($type, $prefix, $config);
	}
	'''
	def generateAdminViewAddToolbar() '''
	/**
	     * Add the page title and toolbar.
	     */
	    protected function addToolbar() {
	        JFactory::getApplication()->input->set('hidemainmenu', true);
	
	        $user = JFactory::getUser();
	        $isNew = ($this->item->id == 0);
	        if (isset($this->item->checked_out)) {
	            $checkedOut = !($this->item->checked_out == 0 || $this->item->checked_out == $user->get('id'));
	        } else {
	            $checkedOut = false;
	        }
	        $canDo = «com.name.toFirstUpper»Helper::getActions();
	
	        JToolBarHelper::title(JText::_('COM_«com.name.toUpperCase»_TITLE_«dpage.name.toUpperCase»'), '«dpage.name.toLowerCase».png');
	
	        // If not checked out, can save the item.
	        if (!$checkedOut && ($canDo->get('core.edit') || ($canDo->get('core.create')))) {
	
	            JToolBarHelper::apply('«dpage.name.toLowerCase».apply', 'JTOOLBAR_APPLY');
	            JToolBarHelper::save('«dpage.name.toLowerCase».save', 'JTOOLBAR_SAVE');
	        }
	        if (!$checkedOut && ($canDo->get('core.create'))) {
	            JToolBarHelper::custom('«dpage.name.toLowerCase».save2new', 'save-new.png', 'save-new_f2.png', 'JTOOLBAR_SAVE_AND_NEW', false);
	        }
	        // If an existing item, can save to a copy.
	        if (!$isNew && $canDo->get('core.create')) {
	            JToolBarHelper::custom('«dpage.name.toLowerCase».save2copy', 'save-copy.png', 'save-copy_f2.png', 'JTOOLBAR_SAVE_AS_COPY', false);
	        }
	        if (empty($this->item->id)) {
	            JToolBarHelper::cancel('«dpage.name.toLowerCase».cancel', 'JTOOLBAR_CANCEL');
	        } else {
	            JToolBarHelper::cancel('«dpage.name.toLowerCase».cancel', 'JTOOLBAR_CLOSE');
			}
		}
		
	'''
	
	def generateAdminViewDisplay() '''
	/**
		* Display the view
		*/
		public function display($tpl = null) {
		$this->setLayout('Edit');
		$this->state = $this->get('State');
		$this->item = $this->get('Item');
		$this->form = $this->get('Form');
		
		// Check for errors.
		if (count($errors = $this->get('Errors'))) {
		throw new Exception(implode("\n", $errors));
		}
		
		$this->addToolbar();
		parent::display($tpl);
		}
		
	'''
	
	def generateAdminViewLayoutFormular() '''
	<form action="<?php echo JRoute::_('index.php?option=com_«com.name.toLowerCase»&layout=edit&id=' . (int) $this->item->id); ?>" method="post" enctype="multipart/form-data" name="adminForm" id="«dpage.name.toLowerCase»-form" class="form-validate">

	    <div class="form-horizontal">
	        <?php echo JHtml::_('bootstrap.startTabSet', 'myTab', array('active' => 'general')); ?>
	
	        <?php echo JHtml::_('bootstrap.addTab', 'myTab', 'general', JText::_('COM_«com.name.toUpperCase»_TITLE_«dpage.name.toUpperCase»', true)); ?>
	        <div class="row-fluid">
	            <div class="span10 form-horizontal">
	                <fieldset class="adminform">
			«Slug.generateEntytiesHiddenAttribute(dpage.entities.get(0),dpage.entities)»
			<?php if(empty($this->item->created_by)){ ?>
					<input type="hidden" name="jform[created_by]" value="<?php echo JFactory::getUser()->id; ?>" />

				<?php } 
				else{ ?>
					<input type="hidden" name="jform[created_by]" value="<?php echo $this->item->created_by; ?>" />

				<?php } ?>
				«Slug.generateEntytiesInputAttribute(dpage.entities.get(0), dpage.entities)»
				   </fieldset>
			</div>
			</div>
	        <?php echo JHtml::_('bootstrap.endTab'); ?>
	        
		    <?php if (JFactory::getUser()->authorise('core.admin','«com.name.toLowerCase»')) : ?>
				<?php echo JHtml::_('bootstrap.addTab', 'myTab', 'permissions', JText::_('JGLOBAL_ACTION_PERMISSIONS_LABEL', true)); ?>
				<?php echo $this->form->getInput('rules'); ?>
				<?php echo JHtml::_('bootstrap.endTab'); ?>
			<?php endif; ?>

			<?php echo JHtml::_('bootstrap.endTabSet'); ?>

	        <input type="hidden" name="task" value="" />
	        <?php echo JHtml::_('form.token'); ?>
	
	    </div>
	</form>
	'''
	
}