{% include 'header.tpl' %}
{% set AbstractCatalog = classes.get('AbstractCatalog') %}
{% set Catalog = classes.get('Catalog') %}
{% set Singleton = classes.get('Singleton') %}
{% set BaseCollection = classes.get('Collection') %}
{% set FactoryStorage = classes.get('FactoryStorage') %}
{% set Storage = classes.get('Storage') %}
{% set DBAO = classes.get('DBAO') %}
{% set Bean = classes.get('Bean') %}
{% set bean = Bean.getName().toCamelCase() %}
{{ AbstractCatalog.printNamespace() }}

{% if AbstractCatalog.getNamespace() != Catalog.getNamespace() %}{{ Catalog.printUse() }}{% endif %}
{{ Bean.printUse() }}
{{ Storage.printUse() }}
{{ FactoryStorage.printUse() }}
use Query\Query;

{% include "header_class.tpl" with {'infoClass': AbstractCatalog} %}
abstract class {{ AbstractCatalog }} implements {{ Catalog }}
{

    /**
     *
     * Validate Query
     * @param Query $query
     * @throws Exception
     */
    abstract protected function validateQuery(Query $query);
    
    /**
     *
     * Validate {{ Bean }}
     * @param {{ Bean }} ${{ bean }}
     * @throws Exception
     */
    abstract protected function validateBean({{ Bean }} ${{ bean }} = null);

    /**
     *
     * throwException
     * @throws Exception
     */
    abstract protected function throwException($message, \Exception $exception = null);

    /**
     *
     * makeCollection
     * @return \{{ BaseCollection.getFullName() }}
     */
    abstract protected function makeCollection();

    /**
     *
     * makeBean
     * @return \{{ Bean.getFullName() }}
     */
    abstract protected function makeBean($resultset);

    /**
     * @var string $field
     * @return boolean
     */
    public function isNotNull($field){
        return !is_null($field);
    }
    
    /**
     * Engines
     * @var array
     */
    protected static $engines = array("pgsql", "mysql");
    
    /**
    
    private $dbao;

    /**
     * The current transaction level
     */
    protected static $transLevel = 0;

    /**
     *
{%if isZF2 %}
     * @return \Zend\Db\Adapter\AbstractAdapter
{% else %}
     * @return \Zend_Db_Adapter_Abstract
{% endif %}
     */
    public function getDb(){
        return $this->dbao->getDbAdapter();
    }
    
    /**
     * @param \Application\Database\DBAO $dbao
     */
    public function setDBAO(\Application\Database\DBAO $dbao){
        $this->dbao = $dbao;
    }

    /**
     * Soporta transacciones nested
     * @return array
     */
    protected function isNestable()
    {
        $engineName = $this->getDb()->getConnection()->getAttribute(\PDO::ATTR_DRIVER_NAME); 
        return in_array($engineName, self::$engines);
    }

    /**
     * beginTransaction
     */
    public function beginTransaction()
    {
        if( !$this->isNestable() || self::$transLevel == 0 ){
            $this->getDb()->beginTransaction();
        }else{
            $this->getDb()->exec("SAVEPOINT LEVEL".self::$transLevel);
        }
        self::$transLevel++;
    }

    /**
     * commit
     */
    public function commit()
    {
        self::$transLevel--;

        if( !$this->isNestable() || self::$transLevel == 0 ){
            $this->getDb()->commit();
        }else{
            $this->getDb()->exec("RELEASE SAVEPOINT LEVEL".self::$transLevel);
        }
    }

    /**
     * rollBack
     */
    public function rollBack()
    {
        self::$transLevel--;

        if( !$this->isNestable() || self::$transLevel == 0 ){
            $this->getDb()->rollBack();
        }else{
            $this->getDb()->exec("ROLLBACK TO SAVEPOINT LEVEL".self::$transLevel);
        }
    }

    /**
     *
     * @param Query $query
     * @param {{  Storage }} $storage
     * @return \{{ BaseCollection.getFullName() }}
     */
    public function getByQuery(Query $query, {{ Storage }} $storage = null)
    {
        $storage = {{ FactoryStorage }}::create($storage);
        
        $key = "getByQuery:". $query->createSql();
        if( $storage->exists($key) ){
            $collection = $storage->load($key);
            $collection->rewind();
        }else{
            $collection = $this->makeCollection();
            foreach( $this->fetchAll($query, $storage) as $row ){
                $collection->append($this->makeBean($row));
            }
            $storage->save($key, $collection);
        }
        return $collection;
    }

    /**
     *
     * @param Query $query
     * @param {{  Storage }} $storage
     * @return \{{ Bean.getFullName() }}
     */
    public function getOneByQuery(Query $query, {{ Storage }} $storage = null)
    {
        $storage = {{ FactoryStorage }}::create($storage);
        
        $key = "getOneByQuery:". $query->createSql();
        if( $storage->exists($key) ){
            ${{ bean }} = $storage->load($key);
        }else{
            ${{ bean }} = $this->getByQuery($query, $storage)->getOne();
            $storage->save($key, ${{ bean }});
        }   
        
        return ${{ bean }};
    }

    /**
     * @param Query $query
     * @param {{  Storage }} $storage 
     * @return array
     */
    public function fetchAll(Query $query, {{ Storage }} $storage = null){
        return $this->executeDbMethod($query, 'fetchAll', $storage);
    }

    /**
     * @param Query $query
     * @param {{  Storage }} $storage
     * @return array
     */
    public function fetchCol(Query $query, {{ Storage }} $storage = null){
        return $this->executeDbMethod($query, 'fetchCol', $storage);
    }

    /**
     * @param Query $query
     * @param {{  Storage }} $storage
     * @return mixed
     */
    public function fetchOne(Query $query, {{ Storage }} $storage = null){
        return $this->executeDbMethod($query, 'fetchOne', $storage);
    }

    /**
     * @param Query $query
     * @param {{  Storage }} $storage
     * @return mixed
     */
    public function fetchPairs(Query $query, {{ Storage }} $storage = null){
        return $this->executeDbMethod($query, 'fetchPairs', $storage); 
    }
    
    /**
     * 
     * @param Query $query
     * @param string $method
     * @return mixed
     * @throws Exception
     */
    protected function executeDbMethod(Query $query, $method, {{ Storage }} $storage = null)
    {
        $this->validateQuery($query);
        if( !method_exists($this->getDb(), $method) ){
            $this->throwException("El metodo {$method} no existe");
        }
        
        $storage = {{ FactoryStorage }}::create($storage);
        try
        {
            $sql = $query->createSql();
            if( $storage->exists($sql) ){
                $resultset = $storage->load($sql);
            }else{   
                $resultset = call_user_func_array(array($this->getDb(), $method), array($sql));
                $storage->save($sql, $resultset);
            }
        }catch(\Exception $e){
            $this->throwException("Cant execute query \n", $e);
        }
        
        return $resultset;
    }

}
