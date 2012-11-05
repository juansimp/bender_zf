{% include 'header.tpl' %}
{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{% set logger = classes.get(table.getOptions().get('crud_logger')) %}
{% set loggerFactory = classes.get(table.getOptions().get('crud_logger')~'Factory') %}
{% set loggerCatalog = classes.get(table.getOptions().get('crud_logger')~'Catalog') %}
{% set loggerQuery = classes.get(table.getOptions().get('crud_logger')~'Query') %}
{% set UserQuery = classes.get('UserQuery') %}
{{ Catalog.printUse() }}
{{ Factory.printUse() }}
{{ Bean.printUse() }}
{{ Query.printUse() }}
{{ Form.printUse() }}
{% if table.getOptions().has('crud_logger') %}
{{ logger.printUse }}
{{ loggerFactory.printUse }}
{{ loggerCatalog.printUse }}
{{ loggerQuery.printUse }}
{% if UserQuery != Query %}
{{ UserQuery.printUse }}
{% endif %}
{% endif %}
use Application\Controller\CrudController;

/**
 *
 * @author chente
 */
class {{ Controller }} extends CrudController {
    public function indexAction(){
        $this->view->page = $page = $this->getRequest()->getParam('page') ?: 1;

        if( $this->getRequest()->isPost() ){
            $this->view->post = $post = $this->getRequest()->getParams();
        }

        $total = {{ Query }}::create()->filter($post)->count();
        $this->view->{{ Bean.getName().pluralize() }} = ${{ Bean.getName().pluralize() }} = {{ Query }}::create()
            ->filter($post)
            ->page($page, $this->getMaxPerPage())
            ->find();

        $this->view->paginator = $this->createPaginator($total, $page);
{% for foreignKey in fullForeignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
{% set queryForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()~'Query') %}
        $this->view->{{ classForeign.getName().pluralize() }} = \{{ queryForeign.getFullName() }}::create()->find()->toCombo();
{% endfor %}
    }

    public function newAction() {
		${{ bean }} = new {{ Bean }}();
		
		$this->view->{{ bean }} = ${{ bean }};
{% for foreignKey in fullForeignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
{% set queryForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()~'Query') %}
        $this->view->{{ classForeign.getName().pluralize() }} = \{{ queryForeign.getFullName() }}::create()->find()->toCombo();
{% endfor %}
		$this->view->setTpl("Form");
    }

    /**
     *
     * @return array
     */
    public function editAction() {
        $id = $this->getRequest()->getParam('id');
        ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("The {{ Bean }} with id {$id} doesn't exist"));
        
		$this->view->{{ bean }} = ${{ bean }};
{% for foreignKey in fullForeignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
{% set queryForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()~'Query') %}
        $this->view->{{ classForeign.getName().pluralize() }} = \{{ queryForeign.getFullName() }}::create()->find()->toCombo();
{% endfor %}
		$this->view->setTpl("Form");
	}

    /**
     *
     * @return array
     */
    public function saveAction() {
		if(0 == $id = (int) $this->getRequest()->getParam('id')) {
			${{ bean }} = new {{ Bean }}();
{% if fields.hasColumnName('/status/i') %}
{% set statusField = fields.getByColumnName('/status/i') %}
            ${{ bean }}->{{ statusField.setter }}({{ Bean }}::${{ statusField.getName().toUpperCamelCase }}['Active']);
{% endif %}
		} else {
			${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("The {{ Bean }} with id {$id} doesn't exist"));
		}
		
		try {
			$this->get{{ Catalog }}()->beginTransaction();
			
			{{ Factory }}::populate(${{ bean }}, $this->getRequest()->getParams());
            $this->get{{ Catalog }}()->save(${{ bean }});
{% if table.getOptions().has('crud_logger') %}
            $this->newLogForUpdate(${{ bean }});
{% endif %}
			$this->get{{ Catalog }}()->commit();
            $this->setFlash('ok', $this->i18n->_("{{ Bean}} has been saved"));
        } catch(Exception $e) {
            $this->get{{ Catalog }}()->rollBack();
            $this->setFlash('error', $this->i18n->_($e->getMessage()));
        }
        $this->getHelper('redirector')->goto('index');
    }

    /**
     *
     */
    public function deleteAction() {
        $id = $this->getRequest()->getParam('id');
        ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("The {{ Bean }} with id {$id} doesn't exist"));

        try {
            $this->get{{ Catalog }}()->beginTransaction();

{% if fields.hasColumnName('/status/i') %}
{% set statusField = fields.getByColumnName('/status/i') %}
            ${{ bean }}->{{ statusField.setter }}({{ Bean }}::${{ statusField.getName().toUpperCamelCase }}['Inactive']);
{% endif %}
            $this->get{{ Catalog }}()->update(${{ bean }});
{% if table.getOptions().has('crud_logger') %}
            $this->newLogForDelete(${{ bean }});
{% endif %}

            $this->get{{ Catalog }}()->commit();
            $this->setFlash('ok', $this->i18n->_("{{ Bean }} has been disabled"));
        } catch(Exception $e) {
            $this->get{{ Catalog }}()->rollBack();
            $this->setFlash('error', $this->i18n->_($e->getMessage()));
        }
        $this->getHelper('redirector')->goto('index');
    }
    
    /**
     *
     */
    public function reactivateAction() {
        $id = $this->getRequest()->getParam('id');
        ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("The {{ Bean }} with id {$id} doesn't exist"));

        try {
            $this->get{{ Catalog }}()->beginTransaction();

{% if fields.hasColumnName('/status/i') %}
{% set statusField = fields.getByColumnName('/status/i') %}
            ${{ bean }}->{{ statusField.setter }}({{ Bean }}::${{ statusField.getName().toUpperCamelCase }}['Active']);
{% endif %}
            $this->get{{ Catalog }}()->update(${{ bean }});
{% if table.getOptions().has('crud_logger') %}
            $this->newLogForReactivate(${{ bean }});
{% endif %}

            $this->get{{ Catalog }}()->commit();
            $this->setFlash('ok', $this->i18n->_("Se reactivo correctamente el {{ Bean}}"));
        } catch(Exception $e) {
            $this->get{{ Catalog }}()->rollBack();
            $this->setFlash('error', $this->i18n->_($e->getMessage()));
        }
        $this->getHelper('redirector')->goto('index');
    }
{% if table.getOptions().has('crud_logger') %}

    /** 
     *
     */
    protected function trackingAction(){
        $id = $this->getRequest()->getParam('id');
        ${{ bean }} = {{ Query }}::create()->findByPKOrThrow($id, $this->i18n->_("Not exists the {{ Bean }} with id {$id}"));
        $this->view->{{ logger.getName().pluralize() }} = {{ loggerQuery }}::create()->whereAdd('{{ primaryKey }}', $id)->find();
        $this->view->users = UserQuery::create()->find()->toCombo();
    }

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForCreate({{ Bean }} ${{ bean }}){
        return $this->newLog(${{ bean }}, \{{ logger.getFullname() }}::$EventTypes['Create'] );
    }

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForUpdate({{ Bean }} ${{ bean }}){
        return $this->newLog(${{ bean }}, \{{ logger.getFullname() }}::$EventTypes['Update'] );
    }

    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForDelete({{ Bean }} ${{ bean }}){
        return $this->newLog(${{ bean }}, {{ logger }}::$EventTypes['Delete'] );
    }
    
    /**
     * @param {{ Bean }} ${{ bean }}
     * @return \{{ logger.getFullname() }}
     */
    protected function newLogForReactivate({{ Bean }} ${{ bean }}){
        return $this->newLog(${{ bean }}, {{ logger }}::$EventTypes['Reactivate'] );
    }
    
    /**
     * @return \{{ logger.getFullname() }}
     */
    private function newLog({{ Bean }} ${{ bean }}, $eventType){
        $now = \Zend_Date::now();
        $log = {{ loggerFactory }}::createFromArray(array(
            '{{ primaryKey }}' => ${{ bean }}->{{ primaryKey.getter }}(),
            'id_user' => $this->getUser()->getBean()->getIdUser(),
            'date_log' => $now->get('yyyy-MM-dd HH:mm:ss'),
            'event_type' => $eventType,
            'note' => '',
        ));
        $this->getCatalog('{{ loggerCatalog }}')->create($log);
        return $log;
    }
{% endif %}
    /**
     * @return \{{ Catalog.getFullname() }}
     */
    protected function get{{ Catalog }}(){
        return $this->getContainer()->get('{{ Catalog }}');
    }

}
