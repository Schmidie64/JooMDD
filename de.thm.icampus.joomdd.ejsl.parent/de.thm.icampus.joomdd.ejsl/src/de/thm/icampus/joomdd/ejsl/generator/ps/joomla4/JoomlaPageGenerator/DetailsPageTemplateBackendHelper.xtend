package de.thm.icampus.joomdd.ejsl.generator.ps.joomla4.JoomlaPageGenerator

import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedExtension.ExtendedComponent
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedPage.ExtendedDynamicPage
import de.thm.icampus.joomdd.ejsl.generator.ps.joomla4.JoomlaUtil.Slug
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedReference
import de.thm.icampus.joomdd.ejsl.generator.pi.ExtendedEntity.ExtendedEntity

/**
 * This class contains the templates to generate the necessary code for backend view templates.
 * 
 * @author Dieudonne Timma, Dennis Priefer
 */
class DetailsPageTemplateBackendHelper {

    ExtendedDynamicPage dpage
    ExtendedComponent com
    String sec
    ExtendedEntity mainEntity

    new(ExtendedDynamicPage dp, ExtendedComponent cp, String section) {
        dpage = dp
        com = cp
        sec = section
        mainEntity = dp.extendedEntityList.get(0)
    }

    def CharSequence generateAdminModelprepareTableFunction() '''
        /**
         * Prepare and sanitise the table prior to saving.
         *
         * @since 1.6
         */
        protected function prepareTable($table)
        {
            if (empty($table->«mainEntity.primaryKey.name»)) {
                // Set ordering to the last item if not set
                if ($table->ordering === '') {
                    $db = $this->getDbo();
                    $query = $db->getQuery(true);
                    $query->select("MAX(ordering)")->from("#__«com.name»_«mainEntity.name»");
                    $db->setQuery($query);
                    $max = $db->loadResult();
                    $table->ordering = $max+1;
                }
            }
        }
    '''

    def CharSequence genAdminControllerSave() '''
        /**
         * Method to edit an existing record.
         *
         * @param   string $key The name of the primary key of the URL variable.
         * @param   string $urlVar The name of the URL variable if different from the primary key
         *                           (sometimes required to avoid router collisions).
         *
         * @return  boolean  True if access level check and checkout passes, false otherwise.
         *
         * @since   12.2
         */
        public function save($key = null, $urlVar = null)
        {
            $input = Factory::getApplication()->input;
            $model = $this->getModel();
            $table = $model->getTable();
        
            // Determine the name of the primary key for the data.
            if (empty($key)) {
            $key = $table->getKeyName();
            }
        
            // To avoid data collisions the urlVar may be different from the primary key.
            if (empty($urlVar)) {
            $urlVar = $key;
            }
        
            $recordId = $this->input->getInt($urlVar);
        
            // Populate the row id from the session.
            $data[$key] = $recordId;
            $params = ComponentHelper::getParams('«Slug.nameExtensionBind("com",com.name).toLowerCase»');
            $mediaHelper = new MediaHelper;
            $uploadMaxSize = $params->get('upload_maxsize', 0) * 1024 * 1024;
            $uploadMaxFileSize = $mediaHelper->toBytes(ini_get('upload_max_filesize'));
            $files = $input->files->get("jform", array(), 'array');
            if (isset($files)) {
                foreach ($files as $file) {
                    if (!isset($file['name'])) {
                        $this->setMessage(Text::_('COM_TEMPLATES_INVALID_FILE_NAME'), 'error');
                        $this->setRedirect(
                           Route::_(
                           'index.php?option=' . $this->option . '&view=' . $this->view_item
                           . $this->getRedirectToItemAppend($recordId, $urlVar), false
                           ));
                        return false;
                    }
                    if(strpos($file['type'],"image")!==false) {
                        $path = $params->get("«dpage.name.toLowerCase»_image_path");
                    } else {
                        $path = $params->get("«dpage.name.toLowerCase»_file_path");
                    }
                    $file['name'] = JFile::makeSafe($file['name']);
                    $file['name'] = str_replace(' ', '-', $file['name']);
                    $file['filepath'] = JPath::clean(implode(DIRECTORY_SEPARATOR, array(JPATH_ROOT, $path, $file['name'])));
                    if (($file['error'] == 1)
                        || ($uploadMaxSize > 0 && $file['size'] > $uploadMaxSize)
                        || ($uploadMaxFileSize > 0 && $file['size'] > $uploadMaxFileSize))
                    {
                        // File size exceed either 'upload_max_filesize' or 'upload_maxsize'.
                        $this->setMessage(Text::_('COM_MEDIA_ERROR_WARNFILETOOLARGE'), 'error');
                        $this->setRedirect(
                            Route::_(
                                'index.php?option=' . $this->option . '&view=' . $this->view_item
                                . $this->getRedirectToItemAppend($recordId, $urlVar), false
                            ));
                        return false;
                    }
                }
                return parent::save($key, $urlVar);
            }
        }
    '''

    def generateAdminModelTableFunction() '''
        /**
         * Returns a reference to the a Table object, always creating it.
         *
         * @param  type  The table type to instantiate
         * @param  string  A prefix for the table class name. Optional.
         * @param  array  Configuration array for model. Optional.
         * @return  Table  A database object
         * @since 1.6
         */
        public function getTable($name = '«dpage.entities.get(0).name»', $prefix = '', $config = array())
        {
            return parent::getTable($name, $prefix, $config);
        }
    '''

    def generateAdminViewAddToolbar() '''
        /**
         * Add the page title and toolbar.
         */
        protected function addToolbar()
        {
            $app        = Factory::getApplication();
            $app->input->set('hidemainmenu', true);

            $user       = $app->getIdentity();
            $userId     = $user->id;
            $isNew      = ($this->item->«mainEntity.primaryKey.name» == 0);
            $checkedOut = !($this->item->checked_out == 0 || $this->item->checked_out == $userId);
        
            // Built the actions for new and existing records.
            $canDo = «this.com.getComponentHelperClassName»::getActions('«Slug.nameExtensionBind("com", com.name)»', '«dpage.name»', $this->item->«mainEntity.primaryKey.name»);
        
            ToolBarHelper::title(Text::_('«Slug.addLanguage(com.languages, newArrayList("com", com.name, "TITLE", dpage.name), dpage.name)»'), '«dpage.name.toLowerCase».png');
        
            // Build the actions for new and existing records.
            if ($isNew) {
                // For new records, check the create permission.
                if ($canDo->get('core.create')) {
                    ToolbarHelper::apply('«dpage.name».apply');
        
                    ToolbarHelper::saveGroup(
                        [
                            ['save', '«dpage.name».save'],
                            ['save2new', '«dpage.name».save2new']
                        ],
                        'btn-success'
                    );
                }

                ToolbarHelper::cancel('«dpage.name».cancel');
            } else {
                // Since it's an existing record, check the edit permission, or fall back to edit own if the owner.
                $itemEditable = $canDo->get('core.edit') || ($canDo->get('core.edit.own') && $this->item->created_by == $userId);

                $toolbarButtons = [];

                // Can't save the record if it's checked out and editable
                if (!$checkedOut && $itemEditable) {
                    ToolbarHelper::apply('«dpage.name».apply');

                    $toolbarButtons[] = ['save', '«dpage.name».save'];

                    // We can save this record, but check the create permission to see if we can return to make a new one.
                    if ($canDo->get('core.create')) {
                        $toolbarButtons[] = ['save2new', '«dpage.name».save2new'];
                    }
                }

                // If checked out, we can still save
                if ($canDo->get('core.create')) {
                    $toolbarButtons[] = ['save2copy', '«dpage.name».save2copy'];
                }

                ToolbarHelper::saveGroup(
                    $toolbarButtons,
                    'btn-success'
                );

                ToolbarHelper::cancel('«dpage.name».cancel', 'JTOOLBAR_CLOSE');
            }
        }
    '''

    def generateAdminViewDisplay() '''
        /**
         * Display the view
         */
        public function display($tpl = null)
        {
            $this->setLayout('Edit');
            $this->state = $this->get('State');
            $this->item = $this->get('Item');
            $this->form = $this->get('Form');
        
            if (count($errors = $this->get('Errors'))) {
                throw new Exception(implode("\n", $errors));
            }
        
            $this->addToolbar();
            parent::display($tpl);
        }
        
    '''

    def generateAdminViewLayoutForm() '''
        <form action="<?php echo Route::_('index.php?option=com_«com.name.toLowerCase»&layout=edit&«mainEntity.primaryKey.name»=' . (int) $this->item->«mainEntity.primaryKey.name»); ?>"
              method="post"
              enctype="multipart/form-data"
              name="adminForm"
              id="«dpage.name.toLowerCase»-form"
              class="form-validate">
        
            <div class="form-horizontal">
                <?php
                echo HTMLHelper::_(
                    'bootstrap.startTabSet',
                    'myTab',
                    array(
                        'active' => 'general'
                    )
                ); ?>
        
                <?php
                echo HTMLHelper::_(
                    'bootstrap.addTab',
                    'myTab',
                    'general',
                    Text::_('«Slug.addLanguage(com.languages, newArrayList("com", com.name, "TITLE", dpage.name), dpage.name)»', true)
                ); ?>
                <div class="row-fluid">
                    <div class="span10 form-horizontal">
                        <fieldset class="adminform">
                            <input
                                type="hidden"
                                name="jform[ordering]"
                                value="<?php echo $this->item->ordering; ?>"
                            />
                            <input
                                type="hidden"
                                name="jform[state]"
                                value="<?php echo $this->item->state; ?>"
                            />
                            <input
                                type="hidden"
                                name="jform[published]"
                                value="<?php echo ($this->item->«mainEntity.primaryKey.name» != 0) ? $this->item->state : 1; ?>"
                            />
                            «IF !dpage.extendedEditedFieldsList.isNullOrEmpty && (dpage.extendedEditedFieldsList.filter[t | t.extendedAttribute.name.equalsIgnoreCase("title")]).size == 0»
                                <input type="hidden" id="jform[title]" value="<?php echo $this->item->«dpage.extendedEditedFieldsList.get(0).attribute.name»; ?>" />
                            «ENDIF»
                            <input type="hidden" name="jform[checked_out]" value="<?php echo isset($this->item->checked_out) ?
                                                            $this->item->checked_out :
                                                            Factory::getUser()->id; ?>"/>
                            <input type="hidden" name="jform[checked_out_time]" value="<?php echo isset($this->item->checked_out_time) ?
                                                            $this->item->checked_out_time :
                                                            date("Y-m-d H:i:s"); ?>"/>    
                            <?php
                            if (empty($this->item->created_by)) { ?>
                                <input type="hidden" name="jform[created_by]" value="<?php echo Factory::getUser()->id; ?>" />
                            <?php
                            } else { ?>
                                <input type="hidden" name="jform[created_by]" value="<?php echo $this->item->created_by; ?>" />
                            <?php
                            } ?>
                            «Slug.generateEntytiesInputAttribute(dpage.extendedEditedFieldsList, dpage.extendedEntityList.get(0))»
                        </fieldset>
                    </div>
                </div>
                <?php
                    echo HTMLHelper::_('bootstrap.endTab'); ?>
                «FOR ExtendedReference ref : dpage.extendedEntityList.get(0).allExtendedReferences.filter[t | t.upper.equalsIgnoreCase("*") || t.upper.equalsIgnoreCase("-1")]»
                    «Slug.generateEntytiesBackendInputRefrence(ref,com)»
                «ENDFOR» 
                <?php
                if ($app->getIdentity()->authorise('core.admin', '«com.name.toLowerCase»')) : ?>
                    <?php
                    echo HTMLHelper::_(
                        'bootstrap.addTab',
                        'myTab',
                        'permissions',
                        JText::_('JGLOBAL_ACTION_PERMISSIONS_LABEL', true)
                    ); ?>
                    <?php
                    echo $this->form->getInput('rules'); ?>
                    <?php
                    echo HTMLHelper::_('bootstrap.endTab'); ?>
                <?php
                endif; ?>
        
                <?php
                echo HTMLHelper::_('bootstrap.endTabSet'); ?>
                <input type="hidden" name="task" value="" />
                <?php
                echo HTMLHelper::_('form.token'); ?>
            </div>
        </form>
    '''
}
