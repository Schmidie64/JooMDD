package de.thm.icampus.ejsl.generator.ps.JoomlaPageGenerator

import de.thm.icampus.ejsl.eJSL.IndexPage
import de.thm.icampus.ejsl.eJSL.Component
import de.thm.icampus.ejsl.eJSL.DetailsPage
import de.thm.icampus.ejsl.generator.ps.JoomlaUtil.Slug
import de.thm.icampus.ejsl.eJSL.Attribute
import de.thm.icampus.ejsl.eJSL.Entity
import org.eclipse.emf.common.util.EList

class IndexPageTemplateSiteHelper {
	
	 IndexPage indexpage
	private Component  com
	private String sec
	private DetailsPage details
	
	new(IndexPage dp, Component cp, String section){
		
		indexpage = dp
		com = cp
		sec = section
		details = Slug.getPageForDetails(indexpage,com)
		
	}
	
	public def CharSequence generateSiteViewDisplay() '''
	/**
	* Display the view
	*/
	    public function display($tpl = null) {
			
	        $user = JFactory::getUser();
	
	         $app = JFactory::getApplication();

        	 $this->state = $this->get('State');
       		 $this->items = $this->get('Items');
        	 $this->pagination = $this->get('Pagination');
        
	        $this->params = $app->getParams('«Slug.nameExtensionBind("com", com.name).toLowerCase»');
	        
	        // Check for errors.
	        if (count($errors = $this->get('Errors'))) {
	            throw new Exception(implode("\n", $errors));
	        }
	
	        $this->_prepareDocument();
	
	        parent::display($tpl);
	}

	'''
	
	public def CharSequence generateSiteViewprepareDocument() '''
	 /**
	 * Prepares the document
	 */
	    protected function _prepareDocument() {
	        $app = JFactory::getApplication();
	        $menus = $app->getMenu();
	        $title = null;
	 
	        // Because the application sets a default page title,
	        // we need to get it from the menu item itself
	        $menu = $menus->getActive();
	        if ($menu) {
	            $this->params->def('page_heading', $this->params->get('page_title', $menu->title));
	        } else {
	            $this->params->def('page_heading', JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_DEFAULT_PAGE_TITLE'));
	        }
	        $title = $this->params->get('page_title', '');
	        if (empty($title)) {
	            $title = $app->getCfg('sitename');
	        } elseif ($app->getCfg('sitename_pagetitles', 0) == 1) {
	            $title = JText::sprintf('JPAGETITLE', $app->getCfg('sitename'), $title);
	        } elseif ($app->getCfg('sitename_pagetitles', 0) == 2) {
	            $title = JText::sprintf('JPAGETITLE', $title, $app->getCfg('sitename'));
	        }
	        $this->document->setTitle($title);
	 
	        if ($this->params->get('menu-meta_description')) {
	            $this->document->setDescription($this->params->get('menu-meta_description'));
	        }
	 
	        if ($this->params->get('menu-meta_keywords')) {
	            $this->document->setMetadata('keywords', $this->params->get('menu-meta_keywords'));
	        }
	 
	        if ($this->params->get('robots')) {
	            $this->document->setMetadata('robots', $this->params->get('robots'));
	        }
	    }
	'''
	
	public def CharSequence genViewTemplateInit()'''
	
		JHtml::addIncludePath(JPATH_COMPONENT . '/helpers/html');
		JHtml::_('bootstrap.tooltip');
		JHtml::_('behavior.multiselect');
		JHtml::_('formbehavior.chosen', 'select');
		
		$user = JFactory::getUser();
		$userId = $user->get('id');
		$listOrder = $this->state->get('list.ordering');
		$listDirn = $this->state->get('list.direction');
		$canCreate = $user->authorise('core.create', '«Slug.nameExtensionBind("com",com.name).toLowerCase»');
		$canEdit = $user->authorise('core.edit', '«Slug.nameExtensionBind("com",com.name).toLowerCase»');
		$canCheckin = $user->authorise('core.manage', '«Slug.nameExtensionBind("com",com.name).toLowerCase»');
		$canChange = $user->authorise('core.edit.state', '«Slug.nameExtensionBind("com",com.name).toLowerCase»');
		$canDelete = $user->authorise('core.delete', '«Slug.nameExtensionBind("com",com.name).toLowerCase»');
	?>
	
	'''
	
	public def CharSequence genViewTemplateHead()'''
	<form action="<?php echo JRoute::_('index.php?option=«Slug.nameExtensionBind("com",com.name).toLowerCase»&view=«indexpage.name.toLowerCase»'); ?>" method="post" name="adminForm" id="adminForm">

    <table class="table table-striped" id = "sliderList" >
        <thead >
            <tr >
                <?php if (isset($this->items[0]->state)): ?>
        <th width="1%" class="nowrap center">
            <?php echo JHtml::_('grid.sort', 'JSTATUS', 'a.state', $listDirn, $listOrder); ?>
        </th>
    <?php endif; ?>
    «FOR Attribute attr: indexpage.tablecolumns»
    	<th class='left'>
			<?php echo JHtml::_('grid.sort',  '«Slug.nameExtensionBind("com", com.name).toUpperCase»_FORM_LBL_« (attr.eContainer as Entity).name.toUpperCase»_«attr.name.toUpperCase»', 'a.«attr.name.toLowerCase»', $listDirn, $listOrder); ?>
		</th>
    «ENDFOR»
    <?php if (isset($this->items[0]->id)): ?>
        <th width="1%" class="nowrap center hidden-phone">
            <?php echo JHtml::_('grid.sort', 'JGRID_HEADING_ID', 'a.id', $listDirn, $listOrder); ?>
        </th>
    <?php endif; ?>

		<?php if ($canEdit || $canDelete): ?>
		<th class="center">
	<?php echo JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_«indexpage.name.toUpperCase»_ACTIONS'); ?>
	</th>
	<?php endif; ?>

    </tr>
    </thead>
     <tfoot>
    <tr>
        <td colspan="<?php echo isset($this->items[0]) ? count(get_object_vars($this->items[0])) : 10; ?>">
            <?php echo $this->pagination->getListFooter(); ?>
        </td>
    </tr>
    </tfoot>
	«genViewTemplateBody()»
	 </tbody>
    </table>

    <?php if ($canCreate): ?>
        <a href="<?php echo JRoute::_('index.php?option=«Slug.nameExtensionBind("com", com.name).toLowerCase»&task=«details.name.toLowerCase»edit.edit&id=0', false, 2); ?>"
           class="btn btn-success btn-small"><i
                class="icon-plus"></i> <?php echo JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_ADD_ITEM'); ?></a>
    <?php endif; ?>

    <input type="hidden" name="task" value=""/>
    <input type="hidden" name="boxchecked" value="0"/>
    <input type="hidden" name="filter_order" value="<?php echo $listOrder; ?>"/>
    <input type="hidden" name="filter_order_Dir" value="<?php echo $listDirn; ?>"/>
    <?php echo JHtml::_('form.token'); ?>
</form>
<script type="text/javascript">

    jQuery(document).ready(function () {
        jQuery('.delete-button').click(deleteItem);
    });

    function deleteItem() {
        var item_id = jQuery(this).attr('data-item-id');
        if (confirm("<?php echo JText::_('«Slug.nameExtensionBind("com", com.name).toUpperCase»_DELETE_MESSAGE'); ?>")) {
            window.location.href = '<?php echo JRoute::_('index.php?option=«Slug.nameExtensionBind("com", com.name).toLowerCase»&task=«details.name.toLowerCase»edit.remove&id=', false, 2) ?>' + item_id;
        }
    }
</script>    
	'''
	public def CharSequence genViewTemplateBody()'''
	 <tbody>
    <?php foreach ($this->items as $i => $item) : ?>
        <?php $canEdit = $user->authorise('core.edit', '«Slug.nameExtensionBind("com", com.name).toLowerCase»'); ?>

				<?php if (!$canEdit && $user->authorise('core.edit.own', '«Slug.nameExtensionBind("com", com.name).toLowerCase»')): ?>
			<?php $canEdit = JFactory::getUser()->id == $item->created_by; ?>
		<?php endif; ?>
		 <tr class="row<?php echo $i % 2; ?>">

            <?php if (isset($this->items[0]->state)): ?>
                <?php $class = ($canEdit || $canChange) ? 'active' : 'disabled'; ?>
                <td class="center">
                    <a class="btn btn-micro <?php echo $class; ?>"
                       href="<?php echo ($canEdit || $canChange) ? JRoute::_('index.php?option=«Slug.nameExtensionBind("com", com.name).toLowerCase»&task=«details.name.toLowerCase»edit.publish&id=' . $item->id . '&state=' . (($item->state + 1) % 2), false, 2) : '#'; ?>">
                        <?php if ($item->state == 1): ?>
                            <i class="icon-publish"></i>
                        <?php else: ?>
                            <i class="icon-unpublish"></i>
                        <?php endif; ?>
                    </a>
                </td>
            <?php endif; ?>
         
           «genSiteModelAttributeReference(indexpage.tablecolumns, indexpage,com)»

            <?php if (isset($this->items[0]->id)): ?>
                <td class="center hidden-phone">
                    <?php echo (int)$item->id; ?>
                </td>
            <?php endif; ?>

            				<?php if ($canEdit || $canDelete): ?>
					<td class="center">
						<?php if ($canEdit): ?>
							<a href="<?php echo JRoute::_('index.php?option=«Slug.nameExtensionBind("com", com.name).toLowerCase»&task=«details.name.toLowerCase»edit.edit&id=' . $item->id, false, 2); ?>" class="btn btn-mini" type="button"><i class="icon-edit" ></i></a>
						<?php endif; ?>
						<?php if ($canDelete): ?>
							<button data-item-id="<?php echo $item->id; ?>" class="btn btn-mini delete-button" type="button"><i class="icon-trash" ></i></button>
						<?php endif; ?>
					</td>
				<?php endif; ?>

        </tr>
    <?php endforeach; ?>
   
		
	'''
	public   def CharSequence genSiteModelAttributeReference(EList<Attribute>column, IndexPage indexpage, Component com )'''
 	« FOR Attribute attr : column»
	«IF Slug.isAttributeLinked(attr, indexpage)»
	
	<td>
		<a href="<?php echo JRoute::_(«Slug.linkOfAttribut(attr, indexpage, com.name, "$item->")»); ?>">
			<?php echo $this->escape($item->«attr.name.toLowerCase»); ?></a>
	«ELSE»
		<td>
		<?php echo $item->«attr.name.toLowerCase»; ?>
		</td>
	«ENDIF»
	«ENDFOR»
 '''
}