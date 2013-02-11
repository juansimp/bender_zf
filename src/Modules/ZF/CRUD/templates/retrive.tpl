{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{% set statusField = fields.getByColumnName('/status/i') %}

<form class="form-horizontal" method="POST" action="{url action=save}">
<input type="hidden" name="id" value="{${{ bean }}->{{ primaryKey.getter() }}()}"/>
	<fieldset>
		<legend>{$i18n->_('{{ Bean }}')}</legend>
{% for field in fields.nonPrimaryKeys() %}
{% if field.getName().toString() != parentPrimaryKey.getName().toString() and field != statusField %}
		<div class="control-group">
{% if field.isBoolean == false %}
			<label class="control-label" for="{{ field.getName().toUpperCamelCase() }}">{$i18n->_('{{ field.getName().toUnderscore() }}')}</label>
{% endif %}
			<div class="controls">
{% if fields.inForeignKeys.containsIndex(field.getName().toString()) %}
{% set foreignKey = foreignKeys.getByColumnName(field.getName().toString()) %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
	        {${{ classForeign.getName().toCamelCase() }}->_toString()}	        
	        <span class="uneditable-input input-block-level {% if field.isDate or field.isDatetime %}datepicker{% endif %} {% if field.isRequired %}required{% endif %}">{${{ bean }}->{{ field.getter() }}()}</span>
{% endif %}
			</div>
		</div>
{% endif %}
{% endfor %}
	</fieldset>
    <div class="form-actions">
	    <button type="submit" class="btn btn-primary">{$i18n->_('Save')}</button>
	    <a class="btn" href="javascript:history.go(-1)">{$i18n->_('Cancel')}</a>
    </div>
</form>
