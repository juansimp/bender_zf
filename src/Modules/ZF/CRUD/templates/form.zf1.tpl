{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{% set statusField = fields.getByColumnName('/status/i') %}

<form class="form-horizontal" method="POST" action="{$baseUrl}/{{slug}}/save">
<input type="hidden" name="id" value="{${{ bean }}->{{ primaryKey.getter() }}()}"/>
	<fieldset>
		<legend>{$i18n->_('{{ Bean.getName().toUnderscore() }}')}</legend>
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
	        {html_options options=${{ classForeign.getName().pluralize() }} name="{{ field.getName().toUnderscore() }}" id="{{ field.getName().toUpperCamelCase() }}"}	        
{% elseif field.isBoolean %}
			<label class="checkbox"><input type="checkbox" id="{{ field.getName() }}" name="{{ field.getName().toUnderscore() }}"/></label>
{% else %}
	        <input type="text" value="{${{ bean }}->{{ field.getter() }}()}" placeholder="" id="{{ field.getName() }}" name="{{ field.getName().toUnderscore() }}" class="{% if field.isDate or field.isDatetime %}datepicker{% endif %} {% if field.isRequired %}required{% endif %}"/>
{% endif %}
			<span class="help-inline"></span>
			</div>
		</div>
{% endif %}
{% endfor %}
	</fieldset>
    <div class="form-actions">
	    <button type="submit" class="btn btn-primary">{$i18n->_('Save')}</button>
	    <a class="btn" href="{$baseUrl}/{{slug}}/index">{$i18n->_('Cancel')}</a>
    </div>
</form>
