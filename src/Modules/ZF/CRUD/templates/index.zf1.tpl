{% set slug = Controller.getName().toSlug('newString').replace('-controller','') %}
{% set statusField = fields.getByColumnName('/status/i') %}

<h3>{$i18n->_('{{ Bean }}')}</h3>

<!-- Filter Begin -->
<div class="row-fluid">
<div class="span12 well well-small filter" style="text-align: center;">
<div class="row-fluid">
<div class="span11">
<form method="GET" action="{url action=index}" class="form-inline">
    <input type="hidden" name="page" id="page" value="{$page|default:1}" />
    <div class="input-append">
{% for foreignKey in fullForeignKeys %}
{% set classForeign = classes.get(foreignKey.getForeignTable().getObject().toUpperCamelCase()) %}
{% set field = foreignKey.getLocal %}
<!-- {$i18n->_('{{ field }}')} -->
{html_options name={{ field }} id={{ field }} options=${{ classForeign.getName().pluralize() }} selected=$params['{{ field }}'] class="span2"}
{% endfor %}
{% for field in fullFields.nonForeignKeys() %}
{% if field != statusField %}
{% if field.isDate or field.isDatetime %}
<input type="text" name="{{ field }}" id="{{ field }}" value="{$params['{{ field }}']}" class="datePicker dateISO span2" placeholder="{$i18n->_('{{ field }}')}"/>
{% elseif field.isBoolean %}
<label class="checkbox"><input type="checkbox" name="{{ field }}" id="{{ field }}" value="1" {if $params['{{ field }}']}checked="checked"{/if} /> {$i18n->_('{{ field }}')}</label>
{% elseif field.isTime %}
{html_select_time prefix={{ field }} display_seconds=false display_meridian=false time=$params['{{ field }}'] placeholder="{$i18n->_('{{ field }}')}"}
{% else %}
<input type="text" name="{{ field }}" id="{{ field }}" value="{$params['{{ field }}']}" class="span2" placeholder="{$i18n->_('{{ field }}')}"/>
{% endif %}
{% endif %}
{% endfor %}    
<button type="submit" class="btn btn-primary">{$i18n->_('Filter')}</button>
</div>
</form>

</div>
<div class="span1">
<a class="btn btn-success" href="{url action=create}">{$i18n->_('Create')}</a>
</div>
</div>
</div>
</div>

<!-- Filter End -->

    <table class="table table-condensed table-striped">
        <thead>
            <tr>
{% for field in fullFields %}
{% if field != statusField %}
                <th>{$i18n->_('{{ field.getName().toUpperCamelCase() }}')}</th>
{% endif %}
{% endfor %}
                <th>{$i18n->_('Actions')}</div></th>
            </tr>
        </thead>
        <tbody>
            {foreach ${{ Bean.getName().pluralize() }} as ${{ bean }}}
                <tr>
{% set inForeignKeys = fullFields.inForeignKeys %}
{% for field in fullFields %}
{% if field != statusField %}
{% if inForeignKeys.containsIndex(field.getName().toString()) %}
{% set foreignClass = classes.get(fullForeignKeys.getByColumnName(field.getName().toString()).getForeignTable().getObject()) %}
                    <td>{${{ foreignClass.getName().pluralize() }}[${{ bean}}->{{ field.getter() }}()]}</td>
{% elseif field == statusField %}
                    <td>{$i18n->_(${{ bean }}->{{ statusField.getter() }}Name())}</td>
{% else %}
                    <td>{${{ bean }}->{{ field.getter() }}()}</td>
{% endif %}
{% endif %}
{% endfor %}
                    <td>
						<div class="btn-toolbar">
						<div class="btn-group">
	                        <a href="{url action=update id=${{ bean }}->{{table.getPrimaryKey().getter()}}()}" class="btn"><i class="icon-pencil"></i></a>
        	            {if ${{ bean }}->isActive()}
    	                    <a href="{url action=delete id=${{ bean }}->{{table.getPrimaryKey().getter()}}()}" class="btn"><i class="icon-remove"></i></a>
	                    {else}
    	                    <a href="{url action=reactivate id=${{ bean }}->{{table.getPrimaryKey().getter()}}()}" class="btn"><i class="icon-ok"></i></a>
        	            {/if}
{% if table.getOptions().has('crud_logger') %}
	                        <a href="{url action=tracking id=${{ bean }}->{{table.getPrimaryKey().getter()}}()}" class="btn"><i class="icon-list"></i></a>
{% endif %}
						</div>
                    </td>
                </tr>
            {/foreach}
        </tbody>
    </table>


{include file='layout/Pager.tpl' paginator=$paginator}
